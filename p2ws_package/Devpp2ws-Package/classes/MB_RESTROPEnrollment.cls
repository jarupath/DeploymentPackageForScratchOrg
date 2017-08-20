@RestResource(urlMapping = '/ropenrollment/*')
global class MB_RESTROPEnrollment {

	@HttpGet
	global static List<MB_RESTResponseInfoModel.ropEnrollment> getROPEnrollment() {
		Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(UserInfo.getUserId());
		return ROPEnrollmentService.getROPEnrollmentMobileList(flightIdSet);
	}

	@HttpPost
	global static List<MB_RestResponseInfoModel.ropEnrollment> enrollROPNumber(List<MB_RestRequestInfoModel.ropEnrollment> ropEnrollmentList) {
		AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTROPEnrollment', 'enrollROPNumber', '', 'ROP_Number_Inventory__c', 'The ROP Enrollments that are sent from mobile.', System.JSON.serialize(ropEnrollmentList), null, System.currentTimeMillis());

		List<ROP_Number_Inventory__c> ropNumberInventoryList = ROPEnrollmentService.getUnregisteredROPNumberList(ropEnrollmentList.size());

		Integer numberOfROPNumberRequired = ropEnrollmentList.size();
		Integer numberOfROPNumberAvailable = ropNumberInventoryList.size();
		Boolean hasSufficientNumberOfROPNumber = numberOfROPNumberRequired <= numberOfROPNumberAvailable;
		Boolean isLowNumberOfROPNumber = numberOfROPNumberAvailable > 0 && (numberOfROPNumberRequired * 1.0 / numberOfROPNumberAvailable * 1.0) < 0.2;
		if (!hasSufficientNumberOfROPNumber) {
			String message = 'The number of ROP Enrollment Inventory is inadequate. (Required: ' + numberOfROPNumberRequired + ' Available: ' + numberOfROPNumberAvailable + ')';
			BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTROPEnrollment', 'enrollROPNumber', '', 'ROP_Number_Inventory__c', message, System.JSON.serialize(ropEnrollmentList), null, System.currentTimeMillis());
			ROPEnrollmentService.sendEmailNotifyInsufficientNumberOfROPNumber(numberOfROPNumberAvailable);
			return null;
		}
		if (isLowNumberOfROPNumber) {
			ROPEnrollmentService.sendEmailNotifyInsufficientNumberOfROPNumber(numberOfROPNumberAvailable);
		}

		Map<String, Account> accountMapByROPNumber = new Map<String, Account>();
		Map<String, Membership__c> membershipMapByROPNumber = new Map<String, Membership__c>();
		Map<String, ROP_Number_Inventory__c> ropNumberSObjectMapByROPNumber = new Map<String, ROP_Number_Inventory__c>();
		Map<String, ROP_Enrollment__c> ropEnrollmentSObjectMapByROPNumber = new Map<String, ROP_Enrollment__c>();

		Set<Id> passengerIdSet = new Set<Id>();
		for (MB_RestRequestInfoModel.ropEnrollment eachEnrollment : ropEnrollmentList) {
			passengerIdSet.add(eachEnrollment.paxId);
		}
		Map<Id, Passenger__c> passengerMap = new Map<Id, Passenger__c>([SELECT Id, Name, First_Name__c, Last_Name__c, Passenger_Salutation_Auto__c, Passenger_First_Name_Auto__c FROM Passenger__c WHERE Id IN :passengerIdSet AND Passenger_Salutation_Auto__c != null AND Passenger_First_Name_Auto__c != null]);

		for (Integer i = 0; i < numberOfROPNumberRequired; i++) {
			ROP_Number_Inventory__c ropNumberSObject = ropNumberInventoryList.get(i);
			MB_RestRequestInfoModel.ropEnrollment ropEnrollment = ropEnrollmentList.get(i);
			Boolean isNotVoid = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_NUMBER.get(ropEnrollment.status) != ROPEnrollmentService.STATUS_VOID;
			if (isNotVoid) {
				String ropNumber = ropNumberSObject.ROP_Number__c;
				ropEnrollment.ropNumber = ropNumber;
				ropEnrollment.sfdcId = ropNumberSObject.Id;
				ropenrollment.isSynced = '1';
				try {
					Boolean isEnrollmentByWebService = passengerMap.containsKey(ropEnrollment.paxId);
					Boolean isManualEnrollment = !isEnrollmentByWebService;

					ROP_Enrollment__c ropEnrollmentSObject = null;

					if (isEnrollmentByWebService) {
						Passenger__c passengerWithCorrectSalutation = passengerMap.get(ropEnrollment.paxId);
						ropEnrollment.salut = passengerWithCorrectSalutation.Passenger_Salutation_Auto__c;
						ropEnrollment.firstN = passengerWithCorrectSalutation.Passenger_First_Name_Auto__c;
						ropEnrollment.lastN = passengerWithCorrectSalutation.Last_Name__c;

						WS_ROPEnrollmentResponseModel response = ROPEnrollmentService.enrollROPMemberFromMobileModel(ropEnrollment);
						System.debug('response: ' + response);
						ropEnrollmentSObject = ROPEnrollmentService.createROPEnrollmentRecord(ropNumberSObject, ropEnrollment, response);
						ropEnrollmentSObjectMapByROPNumber.put(ropNumber, ropEnrollmentSObject);
						System.debug(ropEnrollmentSObject);

						if (!ropEnrollmentSObject.Integration_Error__c && ropEnrollmentSObject.Status__c == ROPEnrollmentService.STATUS_ENROLL) {
							Account newAccount = new Account();
							newAccount.Name = ropEnrollment.lastN + ' ' + ropEnrollment.firstN + ' ' + ropEnrollment.salut;
							newAccount.Id = ropEnrollment.accId;
							newAccount.ROP_Number__c = ropNumber;
							accountMapByROPNumber.put(ropNumber, newAccount);

							Membership__c newMembership = new Membership__c();
							newMembership.Name = ropNumber;
							newMembership.Airline__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY;
							newMembership.EXTMember__c = newMembership.Airline__c + '_' + newMembership.Name;
							newMembership.Status__c = BE8_GlobalConstants.MEMBERSHIP_STATUS_INACTIVE;
							membershipMapByROPNumber.put(ropNumber, newMembership);

							ropNumberSObject.Register_DateTime__c = System.now();
						}
					} else if(isManualEnrollment){
						ropEnrollment.ropNumber = null;
						ropEnrollment.sfdcId = null;
						ropEnrollmentSObject = ROPEnrollmentService.createROPEnrollmentRecord(null, ropEnrollment, null, true);
						ropEnrollmentSObjectMapByROPNumber.put(ropNumber, ropEnrollmentSObject);
					}


					if (ropEnrollmentSObject.Status__c == ROPEnrollmentService.STATUS_ENROLL) {
						ropNumberSObjectMapByROPNumber.put(ropNumber, ropNumberSObject);
					}
				} catch (Exception e) {
					String message = 'Problem occured during integration with THAI.\n' + e.getMessage() + '\n' + e.getStackTraceString();
					AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTROPEnrollment', 'enrollROPNumber', '', 'ROP_Number_Inventory__c', message, System.JSON.serialize(ropEnrollment), null, System.currentTimeMillis());
				}
			} else {
				ROP_Enrollment__c ropEnrollmentSObject = ROPEnrollmentService.createROPEnrollmentRecord(null, ropEnrollment, null);
				ropEnrollmentSObjectMapByROPNumber.put(ropEnrollmentSObject.PaxKey__c, ropEnrollmentSObject);
			}
		}

		List<Passenger__c> passengerList = new List<Passenger__c>();
		try {
			if (!accountMapByROPNumber.isEmpty()) {
				upsert accountMapByROPNumber.values();
			}

			for (String ropNumber : accountMapByROPNumber.keySet()) {
				Account account = accountMapByROPNumber.get(ropNumber);
				if (account != null) {
					Membership__c newMembership = membershipMapByROPNumber.get(ropNumber);
					if (newMembership != null) {
						newMembership.AccountId__c = account.Id;
					}

					ROP_Enrollment__c ropEnrollmentSObject = ropEnrollmentSObjectMapByROPNumber.get(ropNumber);
					ropEnrollmentSObject.AccountId__c = account.Id;
					if (ropEnrollmentSObject != null && ropEnrollmentSObject.PassengerId__c != null) {
						passengerList.add(new Passenger__c(Id = ropEnrollmentSObject.PassengerId__c, AccountId__c = account.Id));
					}
				}
			}

			if (!membershipMapByROPNumber.isEmpty()) {
				insert membershipMapByROPNumber.values();
			}

			if (!passengerList.isEmpty()) {
				update passengerList;
			}

			for (String ropNumber : membershipMapByROPNumber.keySet()) {
				Membership__c membership = membershipMapByROPNumber.get(ropNumber);
				ROP_Enrollment__c ropEnrollmentSObject = ropEnrollmentSObjectMapByROPNumber.get(ropNumber);
				if (membership != null && ropEnrollmentSObject != null) {
					ropEnrollmentSObject.MembershipId__c = membership.Id;
				}
			}

			if (!ropNumberSObjectMapByROPNumber.isEmpty()) {
				update ropNumberSObjectMapByROPNumber.values();
			}

			if (!ropEnrollmentSObjectMapByROPNumber.isEmpty()) {
				upsert ropEnrollmentSObjectMapByROPNumber.values() ExternalId__c;
				for (ROP_Enrollment__c each : ropEnrollmentSObjectMapByROPNumber.values()) {
					if (each.Integration_Error__c) {
						AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTROPEnrollment', 'enrollROPNumber', each.Id, 'ROP_Enrollment__c', 'ROP Enrollment with Integration Error to THAI\n' + each.Response_from_THAI__c, System.JSON.serialize(each), null, System.currentTimeMillis());
						String toEmails = MailList_Repository.getEmailAddress('ROP Enrollment', 'ROPEnrollment_Monitoring');
						Email_Service.sendEmail('SFDC | ROP Enrollment Error', toEmails, each.Id + ' ' + each.Integration_Error_Reason__c);
					} else if(each.Manual_Enrollment__c){
						ROPEnrollment_Manual_Queueable.process(each.Id);
					}
				}
			}
		} catch (Exception e) {
			String message = e.getMessage() + '\n' + e.getStackTraceString();
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTROPEnrollment', 'enrollROPNumber', '', 'ROP_Number_Inventory__c', message, System.JSON.serialize(ropEnrollmentList), null, System.currentTimeMillis());
			AppLogger.insertLogs();
			//return new Map<String, String> {
			//	'status' => '500',
			//	'message' => message
			//};
			Set<Id> ropEnrollmentSObjectIdSet = BE8_GlobalUtility.getIdSet('Id', ropEnrollmentSObjectMapByROPNumber.values());
			return ROPEnrollmentService.convertROPEnrollmentSObjectToResponseModel([SELECT FlightId__c, FlightId__r.Name, FlightId__r.Flight_External_ID__c, PassengerId__r.First_Name__c, PassengerId__r.Last_Name__c, PassengerId__r.PNR__c, ROP_Number_F__c, AccountId__c, Area_Code__c, Birthdate__c, Country_Code__c, CreatedById, CreatedDate, Email__c, Enrollment_Date__c, First_Name__c, Gender__c, Id, Integration_Error_Reason__c, Integration_Error__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Last_Name__c, MembershipId__c, Name, Nationality__c, OwnerId, PassengerId__c, PaxKey__c, Phone_Number__c, Phone_Type__c, Response_from_THAI__c, ROP_Number__c, Salutation__c, Status__c FROM ROP_Enrollment__c WHERE Id IN : ropEnrollmentSObjectIdSet]);
		}

		AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTROPEnrollment', 'enrollROPNumber', '', 'ROP_Number_Inventory__c', 'The ROP Enrollments after ROP Number assignment', System.JSON.serialize(ropEnrollmentList), null, System.currentTimeMillis());
		AppLogger.insertLogs();
		Monitoring.sendEmail();
		//return new Map<String, String> {
		//	'status' => '200',
		//	'message' => 'ROP Enrollments are successful.',
		//	'result' => System.JSON.serialize(ropEnrollmentList)
		//};
		Set<Id> ropEnrollmentSObjectIdSet = BE8_GlobalUtility.getIdSet('Id', ropEnrollmentSObjectMapByROPNumber.values());
		return ROPEnrollmentService.convertROPEnrollmentSObjectToResponseModel([SELECT Created_By_Crew__c, Reported_By_Crew__c, FlightId__c, FlightId__r.Name, FlightId__r.Flight_External_ID__c, PassengerId__r.First_Name__c, PassengerId__r.PaxKey__c, PassengerId__r.Last_Name__c, PassengerId__r.PNR__c, ROP_Number_F__c, AccountId__c, Area_Code__c, Birthdate__c, Country_Code__c, CreatedById, CreatedDate, Email__c, Enrollment_Date__c, First_Name__c, Gender__c, Id, Integration_Error_Reason__c, Integration_Error__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Last_Name__c, MembershipId__c, Name, Nationality__c, OwnerId, PassengerId__c, PaxKey__c, Phone_Number__c, Phone_Type__c, Response_from_THAI__c, ROP_Number__c, Salutation__c, Status__c FROM ROP_Enrollment__c WHERE Id IN : ropEnrollmentSObjectIdSet]);
	}
}