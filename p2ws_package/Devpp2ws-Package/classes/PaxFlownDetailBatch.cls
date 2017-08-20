global class PaxFlownDetailBatch implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	String flightDateText;
	Date flightDateUTC;
	Set<String> paxKeySet;
	Map<String,PAX_Flown_Detail__c> paxFlownDetailMap;
	PAX_Flown_Summary__c masterPaxFlownSummary;
	Boolean executeFlag = true;
	final String developerName ='Count_PAX_Flown_Backdate';
	
	global PaxFlownDetailBatch() {
		Integer pastDay;
		Config_Parameter__mdt[]  paxDetailConfigList = [SELECT DeveloperName,Id,Value__c FROM Config_Parameter__mdt where DeveloperName=:developerName LIMIT 1];
		if(!paxDetailConfigList.isEmpty() && paxDetailConfigList.get(0) !=NULL && paxDetailConfigList.get(0).Value__c !=NULL ){
			pastDay = Integer.valueOf(paxDetailConfigList.get(0).Value__c);
		}else{
			pastDay = 1;
		}

		Date today = System.today();
		flightDateUTC = today.addDays(-pastDay);
		flightDateText = DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),flightDateUTC.day()).format('YYYY-MM-dd');
		initData();
		setupQuery(pastDay);
	}

	global PaxFlownDetailBatch(String fixFlightDate) {//Input Format YYYY-MM-DD
		Date today = System.today();
		Date tempFlightDate = BE8_DateUtility.convertStringToDate(fixFlightDate);
		if(today.daysBetween(tempFlightDate) >= 0){
			executeFlag = false;
		}
		flightDateUTC = tempFlightDate;
		flightDateText = DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),flightDateUTC.day()).format('YYYY-MM-dd');
		initData();
		Integer pastDay = today.dayOfYear() - tempFlightDate.dayOfYear();
		setupQuery(pastDay);
	}

	private void setupQuery(Integer pastDay) {
		this.query = 'SELECT id, PaxKey__c ,Cabin_Class_Description__c, flightid__r.Flight_Date_UTC_F__c, flightid__r.Flight_Area__c, flightid__r.Flight_Region__c, flightid__r.Scheduling_Type__c FROM Passenger__c WHERE flightid__r.STD_LT_DateTime__c = N_DAYS_AGO:'+pastDay+' AND Checkin_Seat__c !=NULL  ORDER BY PaxKey__c';
	}

	private void initData(){
		paxKeySet = new Set<String>();
		paxFlownDetailMap = new Map<String,PAX_Flown_Detail__c>();
		if(executeFlag){
			String conditionDate = DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),01).format('YYYY-MM');
			List<PAX_Flown_Summary__c> paxSummaryList = [SELECT ID,Data_Date_Key__c from PAX_Flown_Summary__c where Data_Date_Key__c =:conditionDate ];
			if(paxSummaryList.isEmpty()){
				masterPaxFlownSummary = new PAX_Flown_Summary__c(Name=(DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),01).format('YYYY-MM')),Data_Date_Key__c=conditionDate,Data_Date__c=date.newInstance(flightDateUTC.year(),flightDateUTC.month(),01));
				insert masterPaxFlownSummary;
			}else{
				masterPaxFlownSummary = paxSummaryList.get(0);
			}
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(executeFlag){
			return Database.getQueryLocator(query);
		}else{
			return null;
		}
		
	}

   	global void execute(Database.BatchableContext BC, List<Passenger__c> passengerList) {
   		String extKeyDetail;
		for(Passenger__c eachPassenger : passengerList){
			extKeyDetail = eachPassenger.Cabin_Class_Description__c+'_'+eachPassenger.flightid__r.Flight_Area__c+'_'+eachPassenger.flightid__r.Flight_Region__c+'_'+eachPassenger.flightid__r.Scheduling_Type__c+'_'+flightDateText;
			//System.debug('extKeyDetail : '+extKeyDetail);
			//System.debug('PaxKey__c : '+eachPassenger.PaxKey__c);
			if(!paxKeySet.contains(eachPassenger.PaxKey__c)){
				//System.debug('Count');
				if(paxFlownDetailMap.containsKey(extKeyDetail)){
					paxFlownDetailMap.get(extKeyDetail).Total_Passengers__c++;
				}else{
					paxFlownDetailMap.put(extKeyDetail,new PAX_Flown_Detail__c(Class__c=eachPassenger.Cabin_Class_Description__c,Flight_Area__c=eachPassenger.flightid__r.Flight_Area__c,Flight_Region__c=eachPassenger.flightid__r.Flight_Region__c,Flight_Scheduling_Type__c=eachPassenger.flightid__r.Scheduling_Type__c,PAX_Flown_Summary__c=masterPaxFlownSummary.id,Total_Passengers__c=1,Data_Date__c=flightDateUTC,Data_Date_Key__c=extKeyDetail));
					//System.debug('New Record');
				}
				//System.debug('Total_Passengers__c :'+paxFlownDetailMap.get(extKeyDetail).Total_Passengers__c);
				paxKeySet.add(eachPassenger.PaxKey__c);
			}

		}
	}
	
	global void finish(Database.BatchableContext BC) {
		if(paxFlownDetailMap.size() >0){
			//System.debug('paxFlownDetailMap :'+ paxFlownDetailMap);
			upsert paxFlownDetailMap.values() Data_Date_Key__c;
		}
	}
	
}