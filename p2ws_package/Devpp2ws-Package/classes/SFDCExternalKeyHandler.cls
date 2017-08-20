/**
 *  08-Feb-2017 : Sarun Wi. Create this 
 *          Description: to reserve External key for each record before
 *           **     - should be in Header of each Class ( ex. trigger, Controller ) to reserved.
 *                  - should specified sizes of records 10 times than normal to prevent duplicate External key in case synconize transaction
 *
 * 
 */
public class SFDCExternalKeyHandler{
    public SFDCExternalKeyHandler(){}
    public static Integer attempNumber;
    public static Integer attempMax = 3; /* this specified maximum time of attemp */
    /**
     * [reservedExternalKey description : to reserve external key and return map of start number of reserved should be start  ]
     * @param  objectType  [Object API of object ]
     * @param  setGroupKey [GroupKey ( 'ACC100001','ACC20001' groupKey should be {'ACC1','ACC2'} ) ]
     * @param  sizes       [size of records,  actual size ]
     *                     - Function Description
     *                     		- this function will Create record of SFDC_External_Key__c if there're no any record of this GroupKey yet
     *                     		- this function will Create record of SFDC_External_Key__c if there has Existing record of this GroupKey
     *                       	
     * @return             [ return Map of start number by groupKey]
     *                       ex. SFDCExternalKeyHandler.reservedExternalKey('Account',{'ACC1','ACC2'},10);
     *                       return { 'ACC1' => 0 , 'ACC2'=>0 }
     * 
     */
    public static Map<String, Integer> reservedExternalKey(String objectType, Set<String> setGroupKey,Integer sizes){
        if(attempNumber == null) attempNumber = 0;
        Map<String,Integer> mapLastestKey = new Map<String,Integer>();
        List<SFDC_External_Key__c> listScopeSFDCExternalKeyToInsert = new List<SFDC_External_Key__c>();
        List<SFDC_External_Key__c> listScopeSFDCExternalKeyToUpdate = new List<SFDC_External_Key__c>();
        Map<String, SFDC_External_Key__c> mapSFDCExternalKeyByGroupKey = getMapSFDCExternalKeyByGroupKey(objectType,setGroupKey);
        for(String groupKey:setGroupKey){
            if(mapSFDCExternalKeyByGroupKey.containsKey(groupKey)){
                SFDC_External_Key__c record = mapSFDCExternalKeyByGroupKey.get(groupKey);
                mapLastestKey.put(record.Group_Key__c, Integer.valueOf(record.Last_Key__c) );
                record.Last_Key__c += sizes;
                listScopeSFDCExternalKeyToUpdate.add(record);
            }else{
                mapLastestKey.put(groupKey,1);
                SFDC_External_Key__c record = new SFDC_External_Key__c( Object_Type__c = objectType,Group_Key__c = groupKey, Last_Key__c = sizes+1 );
                listScopeSFDCExternalKeyToInsert.add(record);
            }
        }
        System.debug('DEBUG - reservedExternalKey');
        System.debug('tobeinserted: ' + listScopeSFDCExternalKeyToInsert);
        System.debug('tobeupdated: ' + listScopeSFDCExternalKeyToUpdate);
        //System.debug();
        Savepoint sp = Database.setSavepoint();
        try{
            if(!listScopeSFDCExternalKeyToUpdate.isEmpty()){
                update listScopeSFDCExternalKeyToUpdate;
            }
            if(!listScopeSFDCExternalKeyToInsert.isEmpty()){
                insert listScopeSFDCExternalKeyToInsert;
            }
        }catch(DmlException ex){
            Database.rollback(sp);
            if(attempNumber<attempMax){
                attempNumber += 1;
                mapLastestKey = reservedExternalKey(objectType, setGroupKey,sizes);
            }else{
                System.debug('a lot of user using system now, try again later.');
            }
        }
        return mapLastestKey;
    }
    

    public static Map<String, SFDC_External_Key__c> getMapSFDCExternalKeyByGroupKey(String objectType, Set<String> setGroupKey){
        Map<String , SFDC_External_Key__c> mapSFDCExternalKeyByGroupKey = new Map<String , SFDC_External_Key__c>();
        List<SFDC_External_Key__c> listScopeKey = getListSFDCExternalKeyByGroupKey(objectType,setGroupKey);
        for(SFDC_External_Key__c keyRecord :listScopeKey){
            mapSFDCExternalKeyByGroupKey.put(keyRecord.Group_Key__c, keyRecord);
        }
        return mapSFDCExternalKeyByGroupKey; 
    }
    public static List<SFDC_External_Key__c> getListSFDCExternalKeyByGroupKey(String objectType, Set<String> setGroupKey){
        return [Select Id, 
                        Name, 
                        Object_Type__c,
                        Group_Key__c,
                        Last_Key__c,
                        SystemModStamp
                    From SFDC_External_Key__c
                    Where Object_Type__c =:objectType and
                    Group_Key__c in:setGroupKey 
                ];
    }
    public static String getMonthYearKey(Date thisDate){
        Date fixdate = Date.newInstance(2559,9,10);
        Integer startNumber = 260;
        startNumber += fixdate.monthsBetween(thisDate);
        return String.valueOf(startNumber);
    }
    public static String leadingZeroFormat(Integer givingNumber, Integer length) {
        String returnString = String.valueOf(givingNumber);
        Integer thisLength = returnString.length();
        for (; thisLength < length; thisLength++) {
            returnString = '0' + returnString;
        }
        return returnString;
    }
}