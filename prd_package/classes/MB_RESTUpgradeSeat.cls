@RestResource(urlMapping = '/upgradeseat/*')
global without sharing class MB_RESTUpgradeSeat {
	@HttpPost
	global static List<MB_RestResponseInfoModel.upgradeSeat> upgradeSeat(List<MB_RESTRequestInfoModel.upgradeSeat> upgradeSeatList) {
		if (upgradeSeatList != null && upgradeSeatList.size() > 0) {
			AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', '', '', 'Upgrade Seat List from Mobile App', System.JSON.serialize(upgradeSeatList), null, System.currentTimeMillis());
			Set<Id> flightIdSet = new Set<Id>();
			Set<String> paxKeySet = new Set<String>();
			Set<String> upgradeSeatCodeSet = new Set<String>();
			for (MB_RESTRequestInfoModel.upgradeSeat each : upgradeSeatList) {
				paxKeySet.add(each.paxKey);
				upgradeSeatCodeSet.add(each.upcode);
				flightIdSet.add(each.fltId);
			}
			Map<Id, Flight__c> flightMapById = new Map<Id, Flight__c>([SELECT Id, AircraftId__c FROM Flight__c WHERE Id IN : flightIdSet]);
			List<Passenger__c> passengerList = [SELECT Id, FFP_Number__c, PaxKey__c, FlightId__r.Name FROM Passenger__c WHERE PaxKey__c IN : paxKeySet];
			List<In_flight_Upgrade_Seat_Master__mdt> masterDataList = [SELECT DeveloperName, Origin__c, Destination__c, Upgrade_From_Class__c, Upgrade_To_Class__c, Amount__c, ROP_Award_Code__r.Promotion_Code__c, ROP_Award_Code__r.Mileages__c, ROP_Award_Code__r.DeveloperName FROM In_flight_Upgrade_Seat_Master__mdt WHERE DeveloperName IN :upgradeSeatCodeSet];
			Map<Id, Passenger__c> passengerMapByPaxId = new Map<Id, Passenger__c>(passengerList);
			Map<String, SObject> masterDataMapByCode = BE8_GlobalUtility.getSObjectMap('DeveloperName', masterDataList);
			List<Passenger__c> passengerListToBeUpdated = new List<Passenger__c>();
			//Map<String, List<Case>> upgradeSeatCaseListMapByPaxKey = new Map<String, List<Case>>();
			Map<Id, Case> upgradeSeatCaseMapByPaxId = new Map<Id, Case>();
			Map<Id, Case_Group_Member__c> caseGroupMemberMapByPaxId = new Map<Id, Case_Group_Member__c>();
			List<Case> failedCaseList = new List<Case>();

			CSE_SOAP_ROPMANAGEAWARD_WS ws = new CSE_SOAP_ROPMANAGEAWARD_WS();
			for (MB_RESTRequestInfoModel.upgradeSeat each : upgradeSeatList) {
				Id aircraftId = flightMapById.get(each.fltId).AircraftId__c;
				Boolean isVoided = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(each.isVoided);
				if (passengerMapByPaxId.containsKey(each.paxId)) {
					Passenger__c passengerToChangeSeat = passengerMapByPaxId.get(each.paxId);
					WS_ROPManageAward_Model response;
					Boolean useMoney = each.payType == 'Cash' || each.payType == 'Credit Card';
					Boolean burnMileageWithTG = !isVoided && !useMoney && masterDataMapByCode.containsKey(each.upCode);
					String awardPackage = null;
					Decimal mileageToBeUsed = null;

					if (burnMileageWithTG) {
						In_flight_Upgrade_Seat_Master__mdt award = ((In_flight_Upgrade_Seat_Master__mdt)masterDataMapByCode.get(each.upcode));
						mileageToBeUsed = award.ROP_Award_Code__r.Mileages__c;
						String promotionCode = award.ROP_Award_Code__r.Promotion_Code__c;
						awardPackage = award.ROP_Award_Code__r.DeveloperName;
						String ropNumber = passengerToChangeSeat.FFP_Number__c;
						each.ropNumber = ropNumber;
						try {
							AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', each.ropNumber, 'ROP Number to Upgrade Seat', 'Burn Mileage with ROP Number: ' + each.ropNumber + ' Promotion Code: ' + promotionCode + ' Award Package: ' + awardPackage + ' Mileage Used: ' + mileageToBeUsed, System.JSON.serialize(each), null, System.currentTimeMillis());
							response = ws.burnMileage(each.ropNumber, promotionCode, awardPackage);
							//AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', each.ropNumber, 'ROP Number to Upgrade Seat', 'Burn Mileage Response of ROP Number: ' + each.ropNumber + ' Promotion Code: ' + promotionCode + ' Award Package: ' + awardPackage, System.JSON.serialize(response), null, System.currentTimeMillis());
						} catch (Exception e) {
							String message = 'Problem occured during integration with THAI.\n' + e.getMessage() + '\n' + e.getStackTraceString();
							AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTUpgradeSeat', 'upgradeSeat', each.ropNumber, 'ROP Number to Upgrade Seat', message, System.JSON.serialize(each), null, System.currentTimeMillis());
						}
					}

					if (!isVoided) {
						passengerToChangeSeat.Change_Seat__c = each.toSeat;
						passengerToChangeSeat.Change_Cabin_Class__c = each.toClass;
						passengerToChangeSeat.Last_Change_Seat_DateTime__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(each.creDT);
						passengerListToBeUpdated.add(passengerToChangeSeat);
					}

					Case upgradeSeatCase = createUpgradeSeatCase(each, passengerToChangeSeat, aircraftId, response, awardPackage, mileageToBeUsed);
					Case_Group_Member__c caseGroupMember = createUpgradeSeatCaseGroupMember(each, passengerToChangeSeat, aircraftId);
					upgradeSeatCaseMapByPaxId.put(passengerToChangeSeat.Id, upgradeSeatCase);
					caseGroupMemberMapByPaxId.put(passengerToChangeSeat.Id, caseGroupMember);

					if (response != null && response.hasError()) {
						String responseJSON = System.JSON.serialize(response);
						String message = 'ROP Burn Mileage Web Service with THAI returned with error.\n' + responseJSON;
						AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTUpgradeSeat', 'upgradeSeat', each.ropNumber, 'ROP Number to Upgrade Seat', message, System.JSON.serialize(each), null, System.currentTimeMillis());
						upgradeSeatCase.Status = BE8_GlobalConstants.CASE_STATUS_VOID;
						upgradeSeatCase.Integration_Error__c = true;
						upgradeSeatCase.Integration_Error_Reason__c = response != null ? response.getErrorMessage() : 'Response is null or it is not serializable.';
						failedCaseList.add(upgradeSeatCase);
					}
				}
			}

			Set<Id> passengerToBeUpdatedIdSet = BE8_GlobalUtility.getIdSet('Id', passengerListToBeUpdated);
			try {
				AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', '' + passengerToBeUpdatedIdSet, 'Passenger__c', 'Passenger List to be updated with change seat and change class.', System.JSON.serialize(passengerListToBeUpdated), null, System.currentTimeMillis());
				update PassengerService.dedupPassengerToChangeSeatList(passengerListToBeUpdated);
			} catch (Exception e) {
				String message = 'Error while updating Passenger.\n' + e.getMessage() + '\n' + e.getStackTraceString();
				AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTUpgradeSeat', 'upgradeSeat', '' + passengerToBeUpdatedIdSet, 'Passenger__c', message, System.JSON.serialize(passengerListToBeUpdated), null, System.currentTimeMillis());
			}

			try {
				AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', '', 'Case', 'Case to be created with change seat and change class.', System.JSON.serialize(upgradeSeatCaseMapByPaxId), null, System.currentTimeMillis());
				insert upgradeSeatCaseMapByPaxId.values();
				AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', '' + BE8_GlobalUtility.getIdSet('Id', upgradeSeatCaseMapByPaxId.values()), 'Case', 'Case after insert with change seat and change class.', System.JSON.serialize(upgradeSeatCaseMapByPaxId), null, System.currentTimeMillis());
			} catch (Exception e) {
				String message = 'Error while inserting Case.\n' + e.getMessage() + '\n' + e.getStackTraceString();
				AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTUpgradeSeat', 'upgradeSeat', '', 'Case', message, System.JSON.serialize(upgradeSeatCaseMapByPaxId), null, System.currentTimeMillis());
			}

			try {
				AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', '', 'Case', 'Case Group Member to be created with change seat and change class.', System.JSON.serialize(caseGroupMemberMapByPaxId), null, System.currentTimeMillis());
				for (Case eachCase : upgradeSeatCaseMapByPaxId.values()) {
					if (caseGroupMemberMapByPaxId.containsKey(eachCase.Passengerid__c)) {
						caseGroupMemberMapByPaxId.get(eachCase.Passengerid__c).CaseId__c = eachCase.Id;
					}
				}
				insert caseGroupMemberMapByPaxId.values();
				AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTUpgradeSeat', 'upgradeSeat', '' + BE8_GlobalUtility.getIdSet('Id', caseGroupMemberMapByPaxId.values()), 'Case', 'Case Group Member after insert with change seat and change class.', System.JSON.serialize(caseGroupMemberMapByPaxId.values()), null, System.currentTimeMillis());
			} catch (Exception e) {
				String message = 'Error while inserting Case Group Member.\n' + e.getMessage() + '\n' + e.getStackTraceString();
				AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTUpgradeSeat', 'upgradeSeat', '', 'Case_Group_Member__c', message, System.JSON.serialize(caseGroupMemberMapByPaxId.values()), null, System.currentTimeMillis());
			}

			sendEmailNotifyFailedBurnMileage(failedCaseList, passengerList);
			AppLogger.insertLogs();
		}
		return createMobileResponseList(upgradeSeatList);
	}

	private static List<MB_RestResponseInfoModel.upgradeSeat> createMobileResponseList(List<MB_RESTRequestInfoModel.upgradeSeat> upgradeSeatList) {
		List<MB_RestResponseInfoModel.upgradeSeat> responseList = new List<MB_RestResponseInfoModel.upgradeSeat>();
		for (MB_RESTRequestInfoModel.upgradeSeat each : upgradeSeatList) {
			MB_RestResponseInfoModel.upgradeSeat responseModel = new MB_RestResponseInfoModel.upgradeSeat();
			responseModel.ropNumber = each.ropNumber;
			responseModel.toClass = each.toClass;
			responseModel.toSeat = each.toSeat;
			responseModel.paxKey = each.paxKey;
			responseModel.fltId = each.fltId;
			responseModel.paxId = each.paxId;
			responseModel.upcode = each.upcode;
			responseModel.creDT = each.creDT;
			responseList.add(responseModel);
		}
		return responseList;
	}

	public static void sendEmailNotifyFailedBurnMileage(List<Case> caseList, List<Passenger__c> passengerList) {
		Map<Id, Passenger__c> passengerMapById = new Map<Id, Passenger__c>(passengerList);
		List<String> emailAddressList = MailList_Repository.getEmailList('Upgrade Seat').values();

		List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
		for (Case eachCase : caseList) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> toAddresses = new List<String>();
			toAddresses.addAll(emailAddressList);
			mail.setToAddresses(toAddresses);
			Passenger__c thisPassenger = passengerMapById.get(eachCase.Passengerid__c);
			if (thisPassenger != null) {
				String flightName = thisPassenger.FlightId__r.Name;
				String ropNumber = thisPassenger.FFP_Number__c;
				String subject = 'Failed Upgrade Seat by Mileage: ' + ropNumber + ' ' + flightName;
				String bodyMsg = 'The upgrade seat that occured during ' + flightName + ' has failed.\n'
				                 + 'Please proceed to check for any error messages and notify administrator to resolve this issue.\n'
				                 + 'You can check the record of this case in Salesforce at ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + eachCase.Id;
				mail.setSubject(subject);
				mail.setPlainTextBody(bodyMsg);
				emailMessageList.add(mail);
			}
		}

		try {
			AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'MB_RESTUpgradeSeat', 'sendEmailNotifyFailedBurnMileage', '', '', 'Sent Email', System.JSON.serialize(emailMessageList), null, System.currentTimeMillis());
			Messaging.sendEmail(emailMessageList);
		} catch (Exception e) {
			String message = e.getMessage() + '\n' + e.getStackTraceString();
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTUpgradeSeat', 'sendEmailNotifyFailedBurnMileage', '', '', message, System.JSON.serialize(caseList), null, System.currentTimeMillis());
			AppLogger.insertLogs();
		}
	}

	private static Case createUpgradeSeatCase(MB_RESTRequestInfoModel.upgradeSeat eachUpgradeSeatRequest, Passenger__c eachPassenger, Id aircraftId, WS_ROPManageAward_Model response, String awardPackage, Decimal mileageToBeUsed) {
		Case upgradeSeatCase = new Case();
		upgradeSeatCase.Mobile_App_Key__c = eachUpgradeSeatRequest.id;
		upgradeSeatCase.Subject = 'Upgrade Seat';
		upgradeSeatCase.Passengerid__c = eachPassenger.Id;
		upgradeSeatCase.Flightid__c = eachUpgradeSeatRequest.fltId;
		upgradeSeatCase.A_C_REG_ID__c = aircraftId;
		upgradeSeatCase.Case_Type__c = BE8_GlobalConstants.CASE_TYPE_INFORMATION;
		upgradeSeatCase.Origin = BE8_GlobalConstants.CASE_CHANNEL_IN_FLIGHT;
		upgradeSeatCase.Priority = BE8_GlobalConstants.CASE_PRIORITY_MEDIUM;
		upgradeSeatCase.Json_Body__c = 'request: ' + JSON.serialize(eachUpgradeSeatRequest);
		if (response != null) {
			upgradeSeatCase.Json_Body__c += '\n\nresponse: ' + JSON.serialize(response);
			Integer jsonBodyFieldLength = Case.Json_Body__c.getDescribe().getLength();
			if (upgradeSeatCase.Json_Body__c.length() > jsonBodyFieldLength) {
				upgradeSeatCase.Json_Body__c = upgradeSeatCase.Json_Body__c.substring(0, jsonBodyFieldLength);
			}
		}
		upgradeSeatCase.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_IN_FLIGHT);
		upgradeSeatCase.Status = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(eachUpgradeSeatRequest.isVoided) ? BE8_GlobalConstants.CASE_STATUS_VOID : BE8_GlobalConstants.CASE_STATUS_CLOSED;
		upgradeSeatCase.Change_Seat__c = eachUpgradeSeatRequest.toSeat;
		upgradeSeatCase.Change_Cabin_Class__c = eachUpgradeSeatRequest.toClass;
		upgradeSeatCase.Payment_Type__c = eachUpgradeSeatRequest.payType;
		upgradeSeatCase.Upgrade_Seat_with_Amount__c = eachUpgradeSeatRequest.amount;
		upgradeSeatCase.Upgrade_Seat_Amount_Currency__c = eachUpgradeSeatRequest.currenc;
		upgradeSeatCase.Description = eachUpgradeSeatRequest.detail;
		upgradeSeatCase.Incident_Category_Mobile__c = '' + 1; // Passenger
		upgradeSeatCase.Upgrade_Change_Seat_Type__c = 'upgradeSeat';
		upgradeSeatCase.Created_At_Mobile__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachUpgradeSeatRequest.creDT);
		upgradeSeatCase.Is_Upgrade_Seat_Case__c = true;
		upgradeSeatCase.ROP_Award_Code__c = awardPackage;
		if(mileageToBeUsed != null){
			upgradeSeatCase.Upgrade_Seat_with_Amount__c = mileageToBeUsed;
		}
		return upgradeSeatCase;
	}

	private static Case_Group_Member__c createUpgradeSeatCaseGroupMember(MB_RESTRequestInfoModel.upgradeSeat eachUpgradeSeatRequest, Passenger__c eachPassenger, Id aircraftId) {
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c();
		caseGroupMember.FlightId__c = eachUpgradeSeatRequest.fltId;
		caseGroupMember.Passengerid__c = eachPassenger.Id;
		caseGroupMember.Aircraft__c = aircraftId;
		caseGroupMember.Change_Seat__c = eachUpgradeSeatRequest.toSeat;
		caseGroupMember.Change_Cabin_Class__c = eachUpgradeSeatRequest.toClass;
		caseGroupMember.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case_Group_Member__c', BE8_GlobalConstants.CASE_GROUP_MEMBER_RECORD_TYPE_GROUND_SERVICE);
		return caseGroupMember;
	}
}
/*
{"upgradeSeatList":[
{"ropNumber":"ZD65332", "toClass":"C", "toSeat":"2A", "paxKey":"LUCE_HAZANPINTO_6E5K4R_TG0930_19FEB17", "fltId":"a0IN0000004bkGs", "paxId":"a0NN0000006caIa", "code":"A001"}
]}
*/