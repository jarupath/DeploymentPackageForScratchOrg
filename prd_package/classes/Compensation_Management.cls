public without sharing class Compensation_Management {
	
	public static map<id,userrole> mapuserroles = new map<id,userrole>();
	public static map<id,Profile> mapuserprofile = new map<id,Profile>();
	public static string Ground_Service = 'GS Compensation';
	public static string In_Flight = 'In-Flight';
	public static string Approved = 'Approved';
	public static string GIFTS = 'Gifts';
	public static string LOUNGE = 'Lounge Access Voucher'; 
	public static string MILEAGE = 'Mileage Compensation';
	public static string EMD = 'EMD';
	public static string BAGGAGE = 'Excess Baggage';
	public static string UPGRADING = 'Upgrading';
	public static string CASH = 'Cash';
	public static string TICKET = 'Complimentary Ticket';
	public static string OTHER = 'Other';
    public static String ABROAD_RECORDTYPE = 'SD/SR Compensation';
    public static Id ABROAD_RECORDTYPE_ID = null;
    public static String ABROAD_FINAL_RECORDTYPE = 'SD/SR Compensation Final';
    public static Id ABROAD_FINAL_RECORDTYPE_ID = null;
	public static double zero = 0.0;
    static list<userrole> listroles;
    static list<Profile> listprof;
	static User thisUser;
    static Map<String, RecordType> recordtypeMap = null;
    static Map<Id, User> roleMap = null; 

    static {
    	mapuserroles = getuserroles();
    	mapuserprofile = getuserprofiles();
    	thisuser = getthisuser();
        roleMap = new Case_TriggerHandler().getRoleMap();
        getRecordTypeMap();
        System.debug('JK: recMap: ' + recordtypeMap);
        ABROAD_RECORDTYPE_ID = recordtypeMap.get(ABROAD_RECORDTYPE).Id;
        ABROAD_FINAL_RECORDTYPE_ID = recordtypeMap.get(ABROAD_FINAL_RECORDTYPE).Id;
    }
    
    public static void autoapprovecompensation(list<compensation__c> listcompensation){

    	for(compensation__c comp : listcompensation){
            if(roleMap.containsKey(UserInfo.getUserId()) && roleMap.get(UserInfo.getUserId()).Station__c == 'BKK'){
                System.debug('BKK STATION');
                if(thisuser.userroleid != null){
                    if(Ground_Service_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## Ground');
                    }
                    else if(In_flight_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## In-Flight');
                    }
                    else if(Tier2_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## Tier 2');
                    }
                    else if(Chief_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## Chief');
                    }
                    else if(Manager_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## Manager');
                    }
                    else if(D7_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## D7');
                    }
                    else if(SZ_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## SZ');
                    }
                    else if(AO_Criteria(comp)){
                        comp.status__c = Approved;
                        comp.recordtypeid = getlockcomp_recordtype();
                        system.debug('## Chief');
                    }
                }
            }
            else if(roleMap.containsKey(UserInfo.getUserId()) && roleMap.get(UserInfo.getUserId()).Station__c != 'BKK'){
                System.debug('Abroad STATION');
                if(Abroad_Criteria(comp)){
                    comp.Status__c = Approved;
                    comp.RecordTypeId = ABROAD_FINAL_RECORDTYPE_ID;
                    System.debug('JK: abroad cfms auto approved: ' + JSON.serialize(comp));
                }
                if(Ground_Service_Criteria(comp)){
                    comp.status__c = Approved;
                    comp.recordtypeid = getlockcomp_recordtype();
                    system.debug('## Ground');
                }
            }
    		
	    	system.debug('## not match condition');
    	}
    }

    private static Boolean Abroad_Criteria(Compensation__c comp){
        Boolean autoApproveFlag = false;
        Map<String, Compensation_SD_SR__c> sdsrCompenMap = Compensation_SD_SR__c.getAll();
        if(comp.RecordTypeId == ABROAD_RECORDTYPE_ID){
            if(sdsrCompenMap.containsKey(comp.Compensation_Tools__c)){
                Compensation_SD_SR__c compenCriteria = sdsrCompenMap.get(comp.Compensation_Tools__c);
                Boolean isZero = compenCriteria.Maximum_Value__c == zero;
                Boolean isCashOrEMD = (comp.Compensation_Tools__c == 'Cash' || comp.Compensation_Tools__c == 'EMD');
                if(compenCriteria.Maximum_Value__c == zero){
                    autoApproveFlag = true;
                }
                else if(isCashOrEMD){
                    if(comp.Currency__c != 'USD'){
                        autoApproveFlag = comp.ROE_US_Dollars__c != null && (comp.Amount__c * comp.ROE_US_Dollars__c) < compenCriteria.Maximum_Value__c ? true : false;
                    }
                    else{
                        autoApproveFlag = comp.Amount__c < compenCriteria.Maximum_Value__c ? true : false;
                    }
                }
                else{
                    autoApproveFlag = comp.Total__c != null && comp.Total__c < compenCriteria.Maximum_Value__c ? true : false;
                }
            }
        }

        return autoApproveFlag;
    }
    
    private static boolean Ground_Service_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	system.debug('## Compensation : ' + comp.Record_Type_Name__c + ' ::: ' + Ground_Service);
    	if(comp.Record_Type_Name__c == Ground_Service){
	    	List<Compensation_Ground_Service__c> listcustomsetting = Compensation_Ground_Service__c.getAll().values();
	    	
	    	for(Compensation_Ground_Service__c comp_ground : listcustomsetting){
		    	if(thisuser.port__c == comp_ground.port__c){
		    		result = true;
		    		break;
		    	}
		    	system.debug('## thisuser port : ' + thisuser.port__c + ' :: ' + 'comp ground :: ' + comp_ground.port__c);
	    	}
	    	
	    	system.debug('## listcustomsetting Ground : ' + listcustomsetting);
    	}
    	
    	return result;
    }
    
    private static boolean In_flight_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	
    	List<Compensation_In_flight__c> listcustomsetting = Compensation_In_flight__c.getAll().values();
    	
    	for(Compensation_In_flight__c comp_IF : listcustomsetting){
    		if(mapuserroles.containskey(thisuser.userroleid)){
		    	if(mapuserroles.get(thisuser.userroleid).name == comp_IF.Role_Name__c){
		    		result = true;
		    		break;
		    	}
		    	system.debug('## role name : ' + mapuserroles.get(thisuser.userroleid).name + ' :: ' + 'comp IF :: ' + comp_IF.Role_Name__c);
    		}
    	}
    	system.debug('## listcustomsetting In-Flight : ' + listcustomsetting.size());
    	
    	
    	return result;
    }
    
    private static boolean Tier2_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	
    	List<Compensation_Tier_2__c> listcustomsetting = Compensation_Tier_2__c.getAll().values();
    	
    	for(Compensation_Tier_2__c comp_T2 : listcustomsetting){
    		if(mapuserprofile.get(thisuser.profileid).name == comp_T2.Role_Name__c){
	    		if(comp.Compensation_Tools__c == comp_T2.name){
	    			if(comp_T2.Maximum_Value__c == zero){
	    				result = true;
	    			}
	    			else if(getcompensationvalue(comp.Compensation_Tools__c, comp) <= comp_T2.Maximum_Value__c){
	    				result = true;
	    			}
	    			system.debug('## total : ' + comp.total__c + ' Max Value : ' + comp_T2.Maximum_Value__c);
	    		}
	    		system.debug('## Tools : ' + comp.Compensation_Tools__c + ' Name : ' + comp_T2.name);
    		}
    		system.debug('## role name : ' + mapuserprofile.get(thisuser.profileid).name + ' :: ' + 'comp_T2 :: ' + comp_T2.Role_Name__c);
    	}
    	system.debug('## listcustomsetting Tier 2 : ' + listcustomsetting);
    	
    	return result;
    }
    
    private static boolean Chief_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	
    	List<Compensation_Chief__c> listcustomsetting = Compensation_Chief__c.getAll().values();
    	
    	for(Compensation_Chief__c comp_ch : listcustomsetting){
    		if(mapuserprofile.get(thisuser.profileid).name == comp_ch.Role_Name__c){
	    		if(comp.Compensation_Tools__c == comp_ch.name){
	    			if(comp_ch.Maximum_Value__c == zero){
	    				result = true;
	    			}
	    			else if(getcompensationvalue(comp.Compensation_Tools__c, comp) <= comp_ch.Maximum_Value__c){
	    				result = true;
	    			}
	    		}
	    		system.debug('## role name : ' + mapuserprofile.get(thisuser.profileid).name + ' :: ' + 'comp_ch :: ' + comp_ch.Role_Name__c);
    		}
    	}
    	system.debug('## listcustomsetting Chief : ' + listcustomsetting);
    	
    	return result;
    }
    
    private static boolean Manager_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	
    	List<Compensation_Manager__c> listcustomsetting = Compensation_Manager__c.getAll().values();
    	
    	for(Compensation_Manager__c comp_mg : listcustomsetting){
    		if(mapuserprofile.get(thisuser.profileid).name == comp_mg.Role_Name__c){
	    		if(comp.Compensation_Tools__c == comp_mg.name){
	    			if(comp_mg.Maximum_Value__c == zero){
	    				result = true;
	    			}
	    			else if(getcompensationvalue(comp.Compensation_Tools__c, comp) <= comp_mg.Maximum_Value__c){
	    				result = true;
	    			}
	    		}
	    		system.debug('## role name : ' + mapuserprofile.get(thisuser.profileid).name + ' :: ' + 'comp_mg :: ' + comp_mg.Role_Name__c);
    		}
    	}
    	system.debug('## listcustomsetting Manager : ' + listcustomsetting);
    	
    	return result;
    }
    
    private static boolean D7_Criteria(compensation__c comp){
        
        Boolean result = false;
        
        List<Compensation_D7__c> listcustomsetting = Compensation_D7__c.getAll().values();
        
        for(Compensation_D7__c comp_d7 : listcustomsetting){
            if(mapuserprofile.get(thisuser.profileid).name == comp_d7.Role_Name__c){
                if(comp.Compensation_Tools__c == comp_d7.name){
                    if(comp_d7.Maximum_Value__c == zero){
                        result = true;
                    }
                    else if(getcompensationvalue(comp.Compensation_Tools__c, comp) <= comp_d7.Maximum_Value__c){
                        result = true;
                    }
                }
                system.debug('## role name : ' + mapuserprofile.get(thisuser.profileid).name + ' :: ' + 'comp_d7 :: ' + comp_d7.Role_Name__c);
            }
        }
        system.debug('## listcustomsetting Manager : ' + listcustomsetting);
        
        return result;
    }

    private static boolean SZ_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	
    	List<Compensation_SZ__c> listcustomsetting = Compensation_SZ__c.getAll().values();
    	
    	for(Compensation_SZ__c comp_sz : listcustomsetting){
    		if(mapuserprofile.get(thisuser.profileid).name == comp_sz.Role_Name__c){
	    		if(comp.Compensation_Tools__c == comp_sz.name){
	    			if(comp_sz.Maximum_Value__c == zero){
	    				result = true;
	    			}
	    			else if(getcompensationvalue(comp.Compensation_Tools__c, comp) <= comp_sz.Maximum_Value__c){
	    				result = true;
	    			}
	    		}
	    		system.debug('## role name : ' + mapuserprofile.get(thisuser.profileid).name + ' :: ' + 'comp_sz :: ' + comp_sz.Role_Name__c);
    		}
    	}
    	system.debug('## listcustomsetting Manager : ' + listcustomsetting);
    	
    	return result;
    }
    
    
    private static boolean AO_Criteria(compensation__c comp){
    	
    	Boolean result = false;
    	
    	List<Compensation_AO__c> listcustomsetting = Compensation_AO__c.getAll().values();
    	
    	for(Compensation_AO__c comp_ch : listcustomsetting){
    		if(mapuserprofile.get(thisuser.profileid).name == comp_ch.Role_Name__c){
	    		if(comp.Compensation_Tools__c == comp_ch.name){
	    			if(comp_ch.Maximum_Value__c == zero){
	    				result = true;
	    			}
	    			else if(getcompensationvalue(comp.Compensation_Tools__c, comp) <= comp_ch.Maximum_Value__c){
	    				result = true;
	    			}
	    		}
	    		system.debug('## role name : ' + mapuserprofile.get(thisuser.profileid).name + ' :: ' + 'comp_ch :: ' + comp_ch.Role_Name__c);
    		}
    	}
    	system.debug('## listcustomsetting Chief : ' + listcustomsetting);
    	
    	return result;
    }
    
    private static user getthisuser(){
        if(thisUser == null){
            thisUser = [Select id,port__c, userroleid, profileid from user where id =: userinfo.getuserid()].get(0);
        }
    	return thisUser;
    }
    
    private static map<id,userrole> getuserroles(){
        if(listroles == null){
            listroles = [Select id,name from userrole];
        }
    	map<id,userrole> maproleswithid = new map<id,userrole>();
    	
    	if(listroles.size() > 0){
    		for(userrole role : listroles){
    			maproleswithid.put(role.id , role);
    		}
    	}
    	
    	return maproleswithid;
    }
    
    private static map<id,profile> getuserprofiles(){
        if(listprof == null){
            listprof = [Select id,name from Profile];
        }
    	map<id,Profile> mapprofwithid = new map<id,Profile>();
    	
    	if(listprof.size() > 0){
    		for(Profile prof : listprof){
    			mapprofwithid.put(prof.id , prof);
    		}
    	}
    	
    	return mapprofwithid;
    }
    
    private static id getlockcomp_recordtype(){
    	return BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Compensation__c' , 'CFMS_Compensation_Final');
    }
    
    private static double getcompensationvalue(string comptools,compensation__c comp){
    	
    	double result = 0.0;
    	
    	if(comptools == GIFTS || comptools == MILEAGE || comptools == BAGGAGE || comptools == UPGRADING || comptools == TICKET || comptools == OTHER){
    		result = comp.total__c;
    	}
    	else{
    		if(comp.ROE__c > 0)
    			result = comp.amount__c * comp.ROE__c;
    		else
    			result = comp.amount__c;
    	}
    	
    	return result;
    }

    public static Map<String, RecordType> getRecordTypeMap(){
        if(recordtypeMap == null){
            List<RecordType> recList = [SELECT Id, Name FROM RecordType];
            recordtypeMap = recList != null && !recList.isEmpty() ? new Map<String, RecordType>() : null;
            for(RecordType rec : recList){
                recordtypeMap.put(rec.Name, rec);
            }
        }
        return recordtypeMap;
    }
    
}