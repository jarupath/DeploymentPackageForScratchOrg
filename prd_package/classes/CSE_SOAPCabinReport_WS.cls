public without sharing class CSE_SOAPCabinReport_WS extends CSE_SOAP_WS {

	private static final String CLASS_NAME = 'CSE_SOAPCabinReport_WS';
	private static final String EXCEPTION_MSG = 'Exception';
	private static final String SUCCESS_MSG = 'return';
	private static final String TGID_START_MSG = '<return>';
	private static final String TGID_END_MSG = '</return>';
	private static final String ERROR_START_MSG = '<message>';
	private static final String ERROR_END_MSG = '</message>';

	public class CabinReportModel {
		public String apName;
		public String acRegis;
		public String acType;
		public String csvName;
		public String captain;
		public String classType;
		public String emerRpt;
		public String file1;
		public String file2;
		public String file3;
		public String fltDate;
		public String fltNo;
		public String imName;
		public String indDesc;
		public String paxName;
		public String paxSeat;
		public String refNo;
		public String remark;
		public String resultCase;
		public String rptContent;
		public String rptID;
		public String rptName;
		public String rptType;
		public String rptUpdBy = 'TG'; //size is the clause of error
		public String sector;
	}

	public class CabinReportResponseModel {
		public String tgID; // TG ID, used by CabinReportModel.refNo for sending more attachment.
		public boolean status; // true = success, false = fail
		public String errorMessage; // Error message
		public BE8_ApplicationLogWrapper applog;
		public Attachment attachment;
	}

	public class tgIDMap {
		public String caseId;
		public String tgID;
		public BE8_ApplicationLogWrapper applog;
		public Attachment attachment;
	}

	public override String getEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_ENDPOINT);
	}

	public override String getUsername() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_USERNAME);
	}

	public override String getPassword() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_PASSWORD);
	}

	public String getReqTxnID() {
		return BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_REQ_TXN_ID));
	}

	public String getSvcVer() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_SVC_VER);
	}

	public String getReqID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_REQ_ID);
	}

	public String getReqPwd() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_REQ_PWD);
	}

	public String getUserID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_REQ_USER_ID);
	}

	public String getMWTxnID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CABINRPT_MW_TXN_ID);
	}

	private static String getShortCrewName(Crew__c crew) {
		return crew.Personel_Id__c + ' ' + crew.Crew_First_Name__c  + (crew.Crew_Last_Name__c != null ? ' ' + crew.Crew_Last_Name__c.substring(0, 1) + '.' : '');
	}

	private static String getShortCrewNameWithNoId(Crew__c crew){
		return crew.Crew_First_Name__c  + (crew.Crew_Last_Name__c != null ? ' ' + crew.Crew_Last_Name__c.substring(0, 1) + '.' : '');
	}

	public static Map<String, CSE_SOAPCabinReport_WS.tgIDMap> sendCabinReportToThai(Set<Id> caseIdSet, Map<Id, String> caseLinkMap){

		Map<String, CSE_SOAPCabinReport_WS.tgIDMap> tgIdMap = new Map<String, CSE_SOAPCabinReport_WS.tgIDMap>();
		List<Case> caseUpdateList = new List<Case>();
		System.debug('[SJ] UserInfo.getUserId() :' + UserInfo.getUserId() + ' ' + UserInfo.getName());
		System.debug('[SJ] caseIdSet :' + caseIdSet);
		System.debug('[SJ] UserRecordAccess :' + [SELECT MaxAccessLevel, RecordId from UserRecordAccess where userId = :UserInfo.getUserId() AND recordId IN :caseIdSet]);
		System.debug('[SJ] Case :' + [SELECT Id FROM Case WHERE Id IN :caseIdSet]);
		List<Case> caseList = [
						SELECT Id,
								Position_Case_Group_Member__c, 
								Case_Type__c, 
								Mobile_App_Key__c, 
								Aircraft_Registration_F__c, 
								Aircraft_Type_F__c, 
								Priority, 
								Flightid__c,
								Flightid__r.Flight_Date_UTC__c,
								Flightid__r.Flight_Date_LT__c, 
								Flightid__r.Departure_STN__c,
								Flightid__r.Arrival_STN__c,
								Flightid__r.Flight_Number__c, 
								Flightid__r.Flight_External_ID__c,
								Emergency_Type__c, 
								Passengerid__c, 
								Passengerid__r.Booking_Class__c,
								Passengerid__r.Cabin_Code__c, 
								Passengerid__r.First_Name__c, 
								Passengerid__r.Last_Name__c, 
								Passengerid__r.Checkin_Seat__c,
								Description, 
								Created_By_Crew__c,
								Created_By_Crew__r.Personel_Id__c,
								Created_By_Crew__r.Crew_First_Name__c,
								Created_By_Crew__r.Crew_Last_Name__c,
								Created_By_Crew__r.Rank__c,
								Reported_By_Crew__c, 
								Reported_By_Crew__r.Personel_Id__c,
								Reported_By_Crew__r.Crew_First_Name__c,
								Reported_By_Crew__r.Crew_Last_Name__c,
								Reported_By_Crew__r.Rank__c,
								Json_Body__c, 
								Cabin_Report_Ref_No__c,
								Sector__c,
								Status
						FROM Case WHERE Id IN :caseIdSet];
		if(caseList == null || caseList.isEmpty()){
			BE8_ApplicationLogWrapper errorLog = new BE8_ApplicationLogWrapper();
            errorLog.source = CLASS_NAME;
            errorLog.sourceFunction = 'sendCabinReportToThai';
            errorLog.referenceId = '';
            errorLog.referenceInfo = '';
            errorLog.logMessage = 'Case List is Empty';
            errorLog.ex = null;
            errorLog.debugLevel = BE8_GlobalConstants.LEVEL_ERROR;
            errorLog.logCode = '';
            errorLog.timer = System.currentTimeMillis();
            tgIDMap returnForEmptyList = new tgIDMap();
            returnForEmptyList.applog = errorLog;
            tgIdMap.put('error', returnForEmptyList);
		}
		Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Flightid__c', caseList);
		Map<String, SObject> crewlistMap = toUpperCase(BE8_GlobalUtility.getSObjectMap('Crew_External_ID__c', [SELECT Id, Crew_External_ID__c, Acting_Rank__c, Personnel_ID__c, CrewId__c, CrewId__r.Personel_Id__c, CrewId__r.Crew_First_Name__c, CrewId__r.Crew_Last_Name__c FROM Crew_List__c WHERE FlightId__c IN :flightIdSet]));
		Map<String, SObject> crewlistMapWithId = BE8_GlobalUtility.getSObjectMap('CrewId__c', [SELECT Id, Name, Crew_External_ID__c, Acting_Rank__c, Personnel_ID__c, CrewId__c FROM Crew_List__c WHERE FlightId__c IN :flightIdSet]);
		Map<String, SObject> paxListMapWithId = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id, Name, Booking_Seat__c, Checkin_Seat__c, First_Name__c, Last_Name__c FROM Passenger__c WHERE FlightId__c IN :flightIdSet]);
 		Map<String, SObject> captainMap = BE8_GlobalUtility.getSObjectMap('FlightId__c', [SELECT Id, Crew_External_ID__c, Acting_Rank__c, Personnel_ID__c, FlightId__r.Flight_External_ID__c, CrewId__c, CrewId__r.Personel_Id__c, CrewId__r.Crew_First_Name__c, CrewId__r.Crew_Last_Name__c   FROM Crew_List__c WHERE FlightId__c IN :flightIdSet AND Acting_Rank__c = 'FC']);
		Map<String, SObject> csvMap = BE8_GlobalUtility.getSObjectMap('FlightId__c', [SELECT Id, Crew_External_ID__c, Acting_Rank__c, Personnel_ID__c, FlightId__r.Flight_External_ID__c, CrewId__c, CrewId__r.Personel_Id__c, CrewId__r.Crew_First_Name__c, CrewId__r.Crew_Last_Name__c   FROM Crew_List__c WHERE FlightId__c IN :flightIdSet AND Acting_Rank__c = 'CSV']);
		Map<String, SObject> apMap = BE8_GlobalUtility.getSObjectMap('FlightId__c', [SELECT Id, Crew_External_ID__c, Acting_Rank__c, Personnel_ID__c, FlightId__r.Flight_External_ID__c, CrewId__c, CrewId__r.Personel_Id__c, CrewId__r.Crew_First_Name__c, CrewId__r.Crew_Last_Name__c  FROM Crew_List__c WHERE FlightId__c IN :flightIdSet AND Acting_Rank__c = 'AP']);
		Map<String, SObject> imMap = BE8_GlobalUtility.getSObjectMap('FlightId__c', [SELECT Id, Crew_External_ID__c, Acting_Rank__c, Personnel_ID__c, FlightId__r.Flight_External_ID__c, CrewId__c, CrewId__r.Personel_Id__c, CrewId__r.Crew_First_Name__c, CrewId__r.Crew_Last_Name__c   FROM Crew_List__c WHERE FlightId__c IN :flightIdSet AND Acting_Rank__c = 'IM']);
		CSE_SOAPCabinReport_WS ws = new CSE_SOAPCabinReport_WS();
		System.debug('crewlistMap: ' + crewlistMap);
		System.debug('captainMap: ' + captainMap);
		System.debug('csvMap: ' + csvMap);
		System.debug('apMap: ' + apMap);

		for(Case eachCase : caseList){
			System.debug('EACHCASE Id: ' + eachCase.Id);
			System.debug('JSON Body: ' + eachCase.Json_Body__c);
			System.debug('Mobile App Key: ' + eachCase.Mobile_App_Key__c);
			if(eachCase.Json_Body__c != null){
				MB_RESTRequestInfoModel.incident_model incident_model = (MB_RESTRequestInfoModel.incident_model)JSON.deserialize(eachCase.Json_Body__c, MB_RESTRequestInfoModel.incident_model.class);
				System.debug('Each Case: ' + eachCase);
				CabinReportModel cabinreport = new CabinReportModel();
				String crewExternalId = eachCase.Created_By_Crew__r.Personel_Id__c + '_' + eachCase.Flightid__r.Flight_External_ID__c;
				crewExternalId = crewExternalId.toUpperCase();
				System.debug('Detail: ' + crewExternalId);
				
				Boolean isAP = ((Crew_List__c)crewlistMap.get(crewExternalId)).Acting_Rank__c == 'AP' ? true : false;
				if(isAP == true){
					cabinreport.apName = getShortCrewName(eachCase.Created_By_Crew__r);
					if(imMap.get(eachCase.Flightid__c) != null){
						cabinreport.imName = getShortCrewName(((Crew_List__c)imMap.get(eachCase.Flightid__c)).CrewId__r);
					}
				}
				else{
					cabinreport.imName = getShortCrewName(eachCase.Created_By_Crew__r);
					if(apMap.get(eachCase.Flightid__c) != null){
						cabinreport.apName = getShortCrewName(((Crew_List__c)apMap.get(eachCase.Flightid__c)).CrewId__r);
					}
				}
				if(csvMap.get(eachCase.Flightid__c) != null){
					cabinreport.csvName = getShortCrewName(((Crew_List__c)csvMap.get(eachCase.Flightid__c)).CrewId__r);
				}
				if(captainMap.get(eachCase.Flightid__c) != null){
					cabinreport.captain = getShortCrewName(((Crew_List__c)captainMap.get(eachCase.Flightid__c)).CrewId__r);
				}
				cabinreport.acRegis = eachCase.Aircraft_Registration_F__c.remove('-');//incident 1064 [done]
				cabinreport.acType = eachCase.Aircraft_Type_F__c;
				cabinreport.fltDate = BE8_DateUtility.convertToTGFlightDateformat(String.valueOf(eachCase.Flightid__r.Flight_Date_LT__c), '-');//incident 1064 [done]
				Integer fltNoInt = Integer.valueOf(eachCase.Flightid__r.Flight_Number__c.remove('TG'));
				cabinreport.fltNo =  String.valueOf(fltNoInt); //incident 1064 [done]
				if(eachCase.Passengerid__c != null){
					cabinreport.paxName = eachCase.Passengerid__r.Last_Name__c + ' ' + eachCase.Passengerid__r.First_Name__c;
					if(eachCase.Passengerid__r.Checkin_Seat__c != null){
						cabinreport.paxSeat = eachCase.Passengerid__r.Checkin_Seat__c;
						cabinreport.classType = eachCase.Passengerid__r.Cabin_Code__c;
					}
					else{
						cabinreport.paxSeat = 'null,null';
						//cabinreport.classType = '';
					}
				}
				if(eachCase.Cabin_Report_Ref_No__c != null){
					cabinreport.refNo = eachCase.Cabin_Report_Ref_No__c;
				}
				else{
					cabinreport.refNo = '';	
				}
				cabinreport.resultCase = eachCase.Status;
				if(cabinreport.resultCase != null && cabinreport.resultCase == BE8_GlobalConstants.CASE_STATUS_RESOLVED){
					//concatinate cabinreport.resultCase with compensation
					if(incident_model.compen != null){
						cabinreport.resultCase += '|Compensation: |';
						for(MB_RESTRequestInfoModel.incident_compensation eachCompensation : incident_model.compen){
							cabinreport.resultCase += 'Type: ' + eachCompensation.type + '|';
							cabinreport.resultCase += 'Detail: ' + eachCompensation.detail + '|';
						}
						cabinreport.resultCase += '|';
					}
				}

				cabinreport.rptContent = '';
				if(incident_model.inCate != null){
					cabinreport.rptContent += 'Category: ' + BE8_GlobalConstants.INCIDENT_CATEGORY.get(incident_model.inCate) + '||';
				}

				if(incident_model.paxMem != null && incident_model.paxMem.size() > 0){
					//cabinreport.rptContent += 'Passenger Involved: ';
					Integer loopcount = 1;
					Boolean isPrefixIncluded = false;
					for(MB_RESTRequestInfoModel.incident_paxMem pax : incident_model.paxMem){
						Boolean isContent = false;
						Passenger__c paxTemp = (Passenger__c)paxListMapWithId.get(pax.Id);
						if(paxTemp != null){
							String paxtempNameFL = paxTemp.First_Name__c + ' ' + paxTemp.Last_Name__c;
							String paxtempNameLF = paxTemp.Last_Name__c + ' ' + paxTemp.First_Name__c;
							if(isPrefixIncluded == false){
								System.debug('paxName: ' + cabinreport.paxName);
								cabinreport.paxName = cabinreport.paxName == null || cabinreport.paxName == '' ? paxtempNameLF : cabinreport.paxName;
								cabinreport.paxSeat = cabinreport.paxSeat == null ? 'null, null' : cabinreport.paxSeat;
							} 
							if(cabinreport.paxName != paxtempNameLF && cabinreport.paxName != paxtempNameFL){
								if(isPrefixIncluded == false){
									cabinreport.rptContent += 'Passenger Involved:|';
									isPrefixIncluded = true;
								}
								cabinreport.rptContent += 'Name: ' + paxTemp.Last_Name__c + ' ' + paxTemp.First_Name__c + '|';
								isContent = true;
								cabinreport.rptContent += paxTemp.Checkin_Seat__c != null ? 'Seat: ' + paxTemp.Checkin_Seat__c + '|' : '';
								cabinreport.rptContent += pax.role != null ? 'Content: ' + pax.role + '|' : '';
								cabinreport.rptContent += pax.detail != null ? 'Detail: ' + pax.detail + '|' : '';
							}

						}
						else{
							cabinreport.rptContent += pax.Id + ' Not Found in SFDC';
							isContent = true;
						}
						if(isContent == true){
							cabinreport.rptContent += loopcount >= incident_model.paxMem.size() ? '||' : '';
						}

						loopcount++;
					}

				}
				if(incident_model.crewMem != null && incident_model.crewMem.size() > 0){
					Boolean isPrefixIncluded = false;
					Boolean isPaxIncluded = cabinreport.paxName == null ? false : true;
					Integer loopcount = 1;
					for(MB_RESTRequestInfoModel.incident_crewMem crew : incident_model.crewMem){
						Crew_List__c crewListTemp = (Crew_List__c)crewlistMapWithId.get(crew.Id);
						if(crewListTemp != null){
							if(isPrefixIncluded == false && isPaxIncluded == true){
								cabinreport.rptContent += 'Crew Involved:|';
								isPrefixIncluded = true;
							}
							if(isPaxIncluded == false){
								cabinreport.rptContent += 'Crew:|';
								isPaxIncluded = true;
							}
							cabinreport.rptContent += 'Name: ' + crewListTemp.Personnel_ID__c + ' ' + crewListTemp.Name + '|';
							if(crew.role != null && crew.role != ''){
								cabinreport.rptContent += 'Role: ' + crew.role + '|';
							}
							if(crew.detail != null && crew.detail != ''){
								cabinreport.rptContent += 'Detail: ' + crew.detail + '|';
							}
						}
						else{
							cabinreport.rptContent += crew.Id + ' Not Found in SFDC';	
						}
						cabinreport.rptContent += loopcount >= incident_model.crewMem.size() ? '||' : '';
						loopcount++;
					}
				}
				if(incident_model.staffMem != null && incident_model.staffMem.size() > 0){
					cabinreport.rptContent += 'Staff Involved:|';
					Integer loopcount = 1;
					for(MB_RESTRequestInfoModel.incident_staffMem staff : incident_model.staffMem){
						cabinreport.rptContent += 'Name: ' + staff.Id + ' ' + staff.staffName + '|';
						if(staff.role != null && staff.role != ''){
							cabinreport.rptContent += 'Role: ' + staff.role + '|';
						}
						if(staff.detail != null && staff.detail != ''){
							cabinreport.rptContent += 'Detail: ' + staff.detail + '|';
						}
						cabinreport.rptContent += loopcount >= incident_model.crewMem.size() ? '||' : '';
						loopcount++;
					}
				}
				cabinreport.rptContent += incident_model.safetyZone != null ? 'Zone: ' + incident_model.safetyZone + '||' : '';
				if(incident_model.posMem != null && incident_model.posMem.size() > 0){
					cabinreport.rptContent += 'Equipment Involved: ' + '|Equipment ID: ' + incident_model.equipId + '|Part ID: ' + incident_model.partId + '|Position: ';
					Integer loopcount = 1;
					for(MB_RESTRequestInfoModel.incident_posMem pos : incident_model.posMem){
						cabinreport.rptContent += '' + pos.Id;
						if(loopcount < incident_model.posMem.size()){
							cabinreport.rptContent += ', ';
						}
						else{
							cabinreport.rptContent += '||';	
						}
						loopcount++;
					}
				}

				//condition
				if(incident_model.condi != null && incident_model.condi != ''){
					cabinreport.rptContent += 'Condition: ' + incident_model.condi + '||';
				}

				//sequence no
				if(incident_model.seqNo != null && incident_model.seqNo != ''){
					cabinreport.rptContent += 'Cabin Log No.: ' + incident_model.seqNo + '||';
				}

				//subject
				if(incident_model.subject != null && incident_model.subject != ''){
					cabinreport.rptContent += 'Subject: ' + incident_model.subject + '||';
				}

				//descr
				if(incident_model.descr != null && incident_model.descr != ''){
					cabinreport.rptContent += 'Description: ' + incident_model.descr + '||';
				}

				if(eachCase.Created_By_Crew__c != null){
					cabinreport.rptID = eachCase.Created_By_Crew__r.Personel_Id__c; //incident 1064 [done]
					cabinreport.rptName = eachCase.Created_By_Crew__r.Rank__c + '/' + getShortCrewName(eachCase.Created_By_Crew__r); //incident 1064 

				}
				if(eachCase.Reported_By_Crew__c != null){
					cabinreport.rptContent += 'Inform by: ' + eachCase.Reported_By_Crew__r.Personel_Id__c + ' ' + eachCase.Reported_By_Crew__r.Rank__c + '/' + getShortCrewNameWithNoId(eachCase.Reported_By_Crew__r) + ' || ';//incident 1064 [done]
				}
				else{
					cabinreport.rptContent += 'Inform by: ' + eachCase.Created_By_Crew__r.Personel_Id__c + ' ' + eachCase.Created_By_Crew__r.Rank__c + '/' + getShortCrewNameWithNoId(eachCase.Created_By_Crew__r) + ' || ';//incident 1064 [done]
				}
				if(eachCase.Case_Type__c != null && eachCase.Emergency_Type__c == null){
					cabinreport.rptType = BE8_GlobalConstants.CABIN_REPORT_TYPE.get(eachCase.Case_Type__c);
					cabinreport.emerRpt = ''; //Leave it Blank
					if(BE8_GlobalConstants.EMERGENCY_TYPE.get(eachCase.Case_Type__c) != null){
						System.debug('Case Type: ' + eachCase.Case_Type__c);
						cabinreport.indDesc = BE8_GlobalConstants.CABIN_REPORT_INCIDENT_DESCRIPTION_WITHOUT_NO.get(eachCase.Case_Type__c);
					}
					else{
						cabinreport.indDesc = BE8_GlobalConstants.CABIN_REPORT_INCIDENT_DESCRIPTION_WITHOUT_NO.get('');
					}
				}
				else if(eachCase.Emergency_Type__c != null){
					cabinreport.rptType = BE8_GlobalConstants.CABIN_REPORT_TYPE.get(eachCase.Emergency_Type__c);
					cabinreport.emerRpt = 'Y';
					cabinreport.indDesc = eachCase.Emergency_Type__c;
				}
				String updateBy = '';
				cabinreport.rptUpdBy = eachCase.Created_By_Crew__r.Personel_Id__c;
				cabinreport.sector = eachCase.Flightid__r.Departure_STN__c + eachCase.Flightid__r.Arrival_STN__c;

				if(caseLinkMap != null && caseLinkMap.get(eachCase.Id) != null){
					cabinReport.remark = caseLinkMap.get(eachCase.Id);
				}
				printCabinReportModelLog(cabinreport);
				try{
					CSE_SOAPCabinReport_WS.CabinReportResponseModel response = ws.upsertCabinReport(cabinreport);
					CSE_SOAPCabinReport_WS.tgIDMap tgid = new CSE_SOAPCabinReport_WS.tgIDMap();
					System.debug('Response From THAI: ' + response);
					tgid.caseId = eachCase.Id;
					tgid.tgID = response.tgID;
					tgid.applog = response.applog;
					tgid.applog.referenceId = eachCase.Id;
					tgid.applog.referenceInfo = 'Mobile_App_Key__c: ' + eachCase.Mobile_App_Key__c + ' | ' + response.tgID;
					tgid.attachment = response.attachment;
					tgIdMap.put(eachCase.Id, tgid);
					//get response model and keep it in the list in order to update case reference No
				}catch(Exception e){
					BE8_ApplicationLogWrapper errorLog = new BE8_ApplicationLogWrapper();
					errorLog.source = CLASS_NAME;
					errorLog.sourceFunction = 'sendCabinReportToThai';
					errorLog.referenceId = eachCase.Id;
					errorLog.referenceInfo = 'Mobile_App_Key__c: ' + eachCase.Mobile_App_Key__c;
					errorLog.logMessage = 'ERROR FROM WHILE CALLOUT: ' + e.getMessage() + ' ' + e.getStackTraceString();
					errorLog.payload = JSON.serialize(cabinreport);
					errorLog.ex = null;
					errorLog.debugLevel = BE8_GlobalConstants.LEVEL_ERROR;
					errorLog.logCode = '';
					errorLog.timer = System.currentTimeMillis();

					CSE_SOAPCabinReport_WS.tgIDMap tgid = new CSE_SOAPCabinReport_WS.tgIDMap();
					tgid.caseId = eachCase.Id;
					tgid.applog = errorLog;
					tgIdMap.put(eachCase.Id, tgid);
				}
			}
		}
		//update caseUpdateList;
		return tgIdMap;
	}

	public static void sendCabinReportToThai(Set<Id> caseIdSet){
		sendCabinReportToThai(caseIdSet, null);
	}

	public static void printCabinReportModelLog(CabinReportModel cabinreport){
		System.debug('--------------CABIN REPORT MODEL LOG---------------------');
		System.debug('apName: ' + cabinreport.apName);
		System.debug('acRegis: ' + cabinreport.acRegis);
		System.debug('acType: ' + cabinreport.acType);
		System.debug('csvName: ' + cabinreport.csvName);
		System.debug('captain: ' + cabinreport.captain);
		System.debug('classType: ' + cabinreport.classType);
		System.debug('emerRpt: ' + cabinreport.emerRpt);
		System.debug('fltDate: ' + cabinreport.fltDate);
		System.debug('fltNo: ' + cabinreport.fltNo);
		System.debug('imName: ' + cabinreport.imName);
		System.debug('indDesc: ' + cabinreport.indDesc);
		System.debug('paxName: ' + cabinreport.paxName);
		System.debug('paxSeat: ' + cabinreport.paxSeat);
		System.debug('refNo: ' + cabinreport.refNo);
		System.debug('remark: ' + cabinreport.remark);
		System.debug('resultCase: ' + cabinreport.resultCase);
		System.debug('rptContent: ' + cabinreport.rptContent);
		System.debug('rptID: ' + cabinreport.rptID);
		System.debug('rptName: ' + cabinreport.rptName);
		System.debug('rptType: ' + cabinreport.rptType);
		System.debug('rptUpdBy: ' + cabinreport.rptUpdBy);
		System.debug('sector: ' + cabinreport.sector);
	}

	public CabinReportResponseModel upsertCabinReport(CabinReportModel pCabinReport) {
		TG_UsernameToken_element token = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = token.nonce;
		String created = token.created;
		String soapResponse = '';
		String soapbody = null;

		if(pCabinReport != null){
			soapbody = '' +
			                  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:cab="http://xml.thaiairways.com/crew/update/cabrpt" xmlns:v1="http://xml.thaiairways.com/crew/update/cabrpt/insertcabrpt/v1_0">' +
			                  '<soapenv:Header>' +
			                  '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871"><wsse:Username>' + getUsername() + '</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password><wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce><wsu:Created>' + created + '</wsu:Created></wsse:UsernameToken></wsse:Security>' +
			                  '<head:ReqHeader>' +
			                  '<head:ReqDateTime>' + created + '</head:ReqDateTime>' +
			                  '<head:ReqTxnID>' + getReqTxnID() + '</head:ReqTxnID>' +
			                  '<head:SvcVer>' + getSvcVer() + '</head:SvcVer>' +
			                  '<head:Credentials>' +
			                  '<head:MWCredential>' +
			                  '<head:ReqID>' + getReqID() + '</head:ReqID>' +
			                  '<head:ReqPwd>' + getReqPwd() + '</head:ReqPwd>' +
			                  '<head:UserID>' + getUserID() + '</head:UserID>' +
			                  '</head:MWCredential>' +
			                  '</head:Credentials>' +
			                  '<head:MWTxnID>' + getMWTxnID() + '</head:MWTxnID>' +
			                  '</head:ReqHeader>' +
			                  '</soapenv:Header>' +
			                  '<soapenv:Body>' +
			                  '<cab:InsertCabRPTReq>' +
			                  '<v1:arg0>' +
			                  '<v1:APName>' + BE8_GlobalUtility.str(pCabinReport.apName) + '</v1:APName>' +
			                  '<v1:acRegis>' + BE8_GlobalUtility.str(pCabinReport.acRegis) + '</v1:acRegis>' +
			                  '<v1:acType>' + BE8_GlobalUtility.str(pCabinReport.acType) + '</v1:acType>' +
			                  '<v1:CSVName>' + BE8_GlobalUtility.str(pCabinReport.csvName) + '</v1:CSVName>' +
			                  '<v1:captain>' + BE8_GlobalUtility.str(pCabinReport.captain) + '</v1:captain>' +
			                  '<v1:classType>' + BE8_GlobalUtility.str(pCabinReport.classType) + '</v1:classType>';
			if (pCabinReport.emerRpt != null) {
				soapBody += '<v1:emerRpt>' + pCabinReport.emerRpt + '</v1:emerRpt>';
			}
			if (pCabinReport.file1 != null) {
				soapbody += ('<v1:file1>' + pCabinReport.file1 + '</v1:file1>');
			}

			if (pCabinReport.file2 != null) {
				soapBody += ('<v1:file2>' + pCabinReport.file2 + '</v1:file2>');
			}

			if (pCabinReport.file3 != null) {
				soapBody += ('<v1:file3>' + pCabinReport.file3 + '</v1:file3>');
			}

			soapBody +=
			    '<v1:fltDate>' + BE8_GlobalUtility.str(pCabinReport.fltDate) + '</v1:fltDate>' +
			    '<v1:fltNo>' + BE8_GlobalUtility.str(pCabinReport.fltNo) + '</v1:fltNo>' +
			    '<v1:IMName>' + BE8_GlobalUtility.str(pCabinReport.imName) + '</v1:IMName>' +
			    '<v1:indDesc>' + BE8_GlobalUtility.str(pCabinReport.indDesc) + '</v1:indDesc>' +
			    '<v1:PAXName>' + BE8_GlobalUtility.str(pCabinReport.paxName) + '</v1:PAXName>' +
			    '<v1:PAXSeat>' + BE8_GlobalUtility.str(pCabinReport.paxSeat) + '</v1:PAXSeat>' +
			    '<v1:refNo>' + BE8_GlobalUtility.str(pCabinReport.refNo) + '</v1:refNo>' +
			    '<v1:remark>' + BE8_GlobalUtility.str(pCabinReport.remark) + '</v1:remark>' +
			    '<v1:resultCase>' + BE8_GlobalUtility.str(pCabinReport.resultCase) + '</v1:resultCase>' +
			    '<v1:rptContent>' + BE8_GlobalUtility.str(pCabinReport.rptContent) + '</v1:rptContent>' +
			    '<v1:rptID>' + BE8_GlobalUtility.str(pCabinReport.rptID) + '</v1:rptID>' +
			    '<v1:rptName>' + BE8_GlobalUtility.str(pCabinReport.rptName) + '</v1:rptName>' +
			    '<v1:rptType>' + BE8_GlobalUtility.str(pCabinReport.rptType) + '</v1:rptType>' +
			    '<v1:rptUpdBy>' + BE8_GlobalUtility.str(pCabinReport.rptUpdBy) + '</v1:rptUpdBy>' +
			    '<v1:sector>' + BE8_GlobalUtility.str(pCabinReport.sector) + '</v1:sector>' +
			    '</v1:arg0>' +
			    '</cab:InsertCabRPTReq>' +
			    '</soapenv:Body>' +
			    '</soapenv:Envelope>';

		    System.debug('Cabin Report request body :' + soapBody);
		}


		try {
			soapResponse = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), 'InsertCabRPTReq', soapBody);
		} catch (Exception e) {
			CabinReportResponseModel m = new CabinReportResponseModel();
			m.status = false;
			m.errorMessage = e.getMessage();

			Attachment attach = new Attachment();
			attach.Name = CLASS_NAME + ' - upsertCabinReport_' + System.currentTimeMillis();
			attach.Body = soapbody != null ? Blob.valueOf(soapbody) : Blob.valueOf('Soap Body is NULL');
			attach.ContentType = 'Text';
			m.attachment = attach;


			BE8_ApplicationLogWrapper errorLog = new BE8_ApplicationLogWrapper();
			errorLog.source = CLASS_NAME;
			errorLog.sourceFunction = 'upsertCabinReport';
			errorLog.referenceId = '';
			errorLog.referenceInfo = '';
			errorLog.logMessage = 'ERROR FROM WHILE CALLOUT';
			errorLog.ex = null;
			errorLog.debugLevel = BE8_GlobalConstants.LEVEL_ERROR;
			errorLog.logCode = '';
			errorLog.timer = System.currentTimeMillis();

			m.applog = errorLog;
			return m;
		}

		return getResponseModel(soapResponse, soapbody);
	}

	public static CabinReportResponseModel getResponseModel(String pXml, String request) {
		CabinReportResponseModel m = new CabinReportResponseModel();
		BE8_ApplicationLogWrapper errorLog = new BE8_ApplicationLogWrapper();
		errorLog.source = CLASS_NAME;
		errorLog.sourceFunction = 'getResponseModel';
		errorLog.referenceId = '';
		errorLog.referenceInfo = '';
		errorLog.ex = null;
		errorLog.debugLevel = BE8_GlobalConstants.LEVEL_ERROR;
		errorLog.logCode = '';
		errorLog.timer = System.currentTimeMillis();
		Attachment attach = new Attachment();
		attach.Name = CLASS_NAME + ' - getResponseModel_' + System.currentTimeMillis();
		attach.Body = Blob.valueOf(request);
		attach.ContentType = 'Text';

		m.attachment = attach;


		System.debug(CLASS_NAME + ' response :' + pXml);

		if (pXml != null) {
			if (pXml.indexOf(SUCCESS_MSG) > -1) {
				m.tgID = BE8_GlobalUtility.getMsgBetween(pXml, TGID_START_MSG, TGID_END_MSG);
				m.status = true;
				errorLog.debugLevel = BE8_GlobalConstants.LEVEL_INFO;
				errorLog.logMessage = 'Web Service Response FROM THAI: ' + m.tgID + ' | ' + m.status;
				m.applog = errorLog;
			} else if (pXml.indexOf(EXCEPTION_MSG) > -1) {
				m.status = false;
				m.errorMessage = BE8_GlobalUtility.getMsgBetween(pXml, ERROR_START_MSG, ERROR_END_MSG);
				errorLog.logMessage = m.errorMessage;
				m.applog = errorLog;
			} else {
				m.status = false;
				m.errorMessage = 'Error data has return invalid description.';
				errorLog.logMessage = m.errorMessage;
				m.applog = errorLog;
			}
		} else {
			m.status = false;
			m.errorMessage = 'Error no data response';
			errorLog.logMessage = m.errorMessage;
			m.applog = errorLog;
		}

		return m;
	}

	public static void logMessage(List<CabinReportResponseModel> responseList) {
		String LOG_NAME_PREFIX = 'ALOG-';
        Map<String, Application_Log__c> insertAppLogs = new Map<String, Application_Log__c>();
        Map<String, Attachment> insertAttachment = new Map<String, Attachment>();
        Integer loopcount = 0;
        for (CabinReportResponseModel response : responseList) {
        	String key = 'KEY-' + loopcount;
        	BE8_ApplicationLogWrapper appLog = response.applog;
            Application_Log__c log = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            log.Name = LOG_NAME_PREFIX + formattedDt;
            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Reference_Information__c = appLog.referenceInfo;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = appLog.payload;

            if (appLog.ex != null) {
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                log.Message__c = applog.ex.getMessage();
            }

            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;
            if (BE8_GlobalUtility.isValidInsert(appLog.debugLevel)) {
                insertAppLogs.put(key, log);
                if(response.attachment != null){
                	insertAttachment.put(key, response.attachment);
                }
            }
            loopcount++;
        }

        System.debug('Insert App Log List: ' + insertAppLogs);
        System.debug('Insert Attachment List: ' + insertAttachment);

        if ( insertAppLogs.size() != 0) {
            Database.SaveResult[] result =  Database.insert(insertAppLogs.values(), false);
            System.debug('Insert App Log: ' + insertAppLogs);
        }
        if( insertAttachment.size() != 0){
	        Set<String> insertAppLogKeySet = insertAppLogs.keySet();
	        for(String str : insertAppLogKeySet){
	        	String applogId = insertAppLogs.get(str).Id;
	        	insertAttachment.get(str).ParentId = applogId;
	        }	
	        Database.SaveResult[] attachResult = Database.insert(insertAttachment.values(), false);
        }
    }

   	public static void logMessage(List<tgIDMap> responseList) {
		String LOG_NAME_PREFIX = 'ALOG-';
        Map<String, Application_Log__c> insertAppLogs = new Map<String, Application_Log__c>();
        Map<String, Attachment> insertAttachment = new Map<String, Attachment>();
        Integer loopcount = 0;
        for (tgIDMap response : responseList) {
        	String key = 'KEY-' + loopcount;
        	BE8_ApplicationLogWrapper appLog = response.applog;
            Application_Log__c log = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            log.Name = LOG_NAME_PREFIX + formattedDt;
            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Reference_Information__c = appLog.referenceInfo;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = appLog.payload;

            if (appLog.ex != null) {
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                log.Message__c = applog.ex.getMessage();
            }

            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;
            if (BE8_GlobalUtility.isValidInsert(appLog.debugLevel)) {
                insertAppLogs.put(key, log);
                if(response.attachment != null){
                	insertAttachment.put(key, response.attachment);
                }
            }
            loopcount++;
        }
        System.debug('Insert App Log List: ' + insertAppLogs);
        System.debug('Insert Attachment List: ' + insertAttachment);

        if ( insertAppLogs.size() != 0) {
            Database.SaveResult[] result =  Database.insert(insertAppLogs.values(), false);
            System.debug('Insert App Log: ' + insertAppLogs);
        }
        if( insertAttachment.size() != 0){
	        Set<String> insertAppLogKeySet = insertAppLogs.keySet();
	        for(String str : insertAppLogKeySet){
	        	String applogId = insertAppLogs.get(str).Id;
	        	insertAttachment.get(str).ParentId = applogId;
	        }	
	        Database.SaveResult[] attachResult = Database.insert(insertAttachment.values(), false);
        }
    }

    public static Map<String, SObject> toUpperCase(Map<String, SObject> inputMap){
    	Map<String, SObject> returnMap = null;
    	if(inputMap != null && !inputMap.isEmpty()){
    		returnMap = new Map<String, SObject>();
    		for(String key : inputMap.keySet()){
    			returnMap.put(key.toUpperCase(), inputMap.get(key));
    		}
    	}
    	return returnMap;
    }
}