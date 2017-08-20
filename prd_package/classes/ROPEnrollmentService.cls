public with sharing class ROPEnrollmentService {
	public static Integer ROP_PIN_NUMBER_LENGTH = 8;
	private static String ALPHABETS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	public static String STATUS_ENROLL = 'Enroll';
	public static String STATUS_VOID = 'Void';
	public static String STATUS_ACTIVE = 'Active';
	public static String STATUS_INACTIVE = 'Inactive';
	public static String ENROLLMENT_TYPE_WEB_SERVICE = 'Web Service';
	public static String ENROLLMENT_TYPE_MANUAL = 'Manual';

	public static Map<String, String> ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_NUMBER = new Map<String, String> {
		'1' => STATUS_ENROLL,
		'2' => STATUS_VOID
	};
	public static Map<String, String> ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING = new Map<String, String> {
		STATUS_ENROLL => '1',
		STATUS_VOID => '2',
		STATUS_ACTIVE => '3',
		STATUS_INACTIVE => '4'
	};
	public static String REASON_DUPLICATE_MEMBER = 'Possible Duplicate Member with same Name and Birthdate';
	public static String REASON_WRONG_EMAIL_FORMAT = 'Incorrect Email Format';
	public static String REASON_MEMBERID_ALREADY_IN_USE = 'MemberID is already in use';

	public static List<ROP_Number_Inventory__c> getUnregisteredROPNumberList(Integer numberOfROPNumber) {
		List<ROP_Number_Inventory__c> ropNumberInventoryList = [SELECT Name, ROP_Number__c FROM ROP_Number_Inventory__c WHERE Registered__c = false LIMIT :10000];
		List<ROP_Number_Inventory__c> shuffledROPNumberList = new List<ROP_Number_Inventory__c>();

		Integer totalNumberOfROPNumber = ropNumberInventoryList.size();
		for (Integer i = 0 ; i < numberOfROPNumber; i++) {
			Integer numberOfRemainingUnshuffledROPNumber = ropNumberInventoryList.size();
			Integer randomNumber = RandomNumberGenerator.randomWithLimit(numberOfRemainingUnshuffledROPNumber);
			shuffledROPNumberList.add(ropNumberInventoryList.get(randomNumber));
			ropNumberInventoryList.remove(randomNumber);
		}

		return shuffledROPNumberList;
	}

	public static String generatePINNumber() {
		Integer numberOfAlphabet = RandomNumberGenerator.randomWithRange(1, ROP_PIN_NUMBER_LENGTH - 1);
		Integer numberOfDigit = ROP_PIN_NUMBER_LENGTH - numberOfAlphabet;
		String pinNumber = '';
		for (Integer i = 0; i < numberOfAlphabet; i++) {
			pinNumber += gerRandomAlphabet();
		}
		for (Integer i = 0; i < numberOfDigit; i++) {
			pinNumber += RandomNumberGenerator.randomWithLimit(10);
		}

		return shufflePINNumber(pinNumber);
	}

	private static String shufflePINNumber(String pinNumber) {
		String shuffledPinNumber = '';
		List<String> pinNumberChars = pinNumber.split('');
		for (Integer i = 0; i < pinNumber.length(); i++) {
			Integer numberOfRemainingChar = pinNumberChars.size();
			Integer index = RandomNumberGenerator.randomWithLimit(numberOfRemainingChar);
			shuffledPinNumber += pinNumberChars.get(index);
			pinNumberChars.remove(index);
		}
		return shuffledPinNumber;
	}

	private static String gerRandomAlphabet() {
		Integer index = RandomNumberGenerator.randomWithLimit(ALPHABETS.length());
		return ALPHABETS.substring(index, index + 1);
	}

	public static WS_ROPEnrollmentResponseModel enrollROPMemberFromMobileModel(MB_RestRequestInfoModel.ropEnrollment model) {
		WS_ROPEnrollmentRequestModel request = new WS_ROPEnrollmentRequestModel();
		request.EnrolROPMemberRQ = new WS_ROPEnrollmentRequestModel.EnrolROPMemberRQ();
		request.EnrolROPMemberRQ.MemberID = model.ropNumber;
		request.EnrolROPMemberRQ.Salutation = model.salut;
		request.EnrolROPMemberRQ.FirstName = model.firstN;
		request.EnrolROPMemberRQ.LastName = model.lastN;
		request.EnrolROPMemberRQ.PhoneType1 = model.phnType;
		request.EnrolROPMemberRQ.CountryCode1 = model.cCode;
		request.EnrolROPMemberRQ.AreaCode1 = model.aCode;
		request.EnrolROPMemberRQ.Number1 = model.phnNum;
		request.EnrolROPMemberRQ.EmailAddress = model.email;
		request.EnrolROPMemberRQ.BirthDate = model.birth;
		request.EnrolROPMemberRQ.Gender = model.gender;
		request.EnrolROPMemberRQ.Nationality = model.nation;
		request.EnrolROPMemberRQ.EnrollDate = model.enrollD;

		return new CSE_SOAPROPEnrollment_WS().enrollROPMember(request);
	}

	public static ROP_Enrollment__c createROPEnrollmentRecord(ROP_Number_Inventory__c ropNumberInventory, MB_RestRequestInfoModel.ropEnrollment model, WS_ROPEnrollmentResponseModel response) {
		return createROPEnrollmentRecord(ropNumberInventory, model, response, false);
	}

	public static ROP_Enrollment__c createROPEnrollmentRecord(ROP_Number_Inventory__c ropNumberInventory, MB_RestRequestInfoModel.ropEnrollment model, WS_ROPEnrollmentResponseModel response, Boolean isManualEnrollment) {
		ROP_Enrollment__c ropEnrollmentRecord = new ROP_Enrollment__c();

		if (ropNumberInventory != null) {
			ropEnrollmentRecord.ROP_Number__c = ropNumberInventory.Id;
		}

		if (response != null) {
			System.debug('response: ' + response);
			ropEnrollmentRecord.Response_from_THAI__c = System.JSON.serialize(response);
			if (isErrorResponse(response)) {
				ropEnrollmentRecord.Integration_Error__c = true;
				ropEnrollmentRecord.Integration_Error_Reason__c = getIntegrationErrorReason(response);
			}
		} else if (response == null && !isManualEnrollment) {
			ropEnrollmentRecord.Integration_Error__c = true;
			ropEnrollmentRecord.Integration_Error_Reason__c = 'The response is not serializable. Please check Application Log or Debug Log for further information.';
		}

		if (model.ropNumber != null) {
			ropEnrollmentRecord.Name = model.ropNumber + ' ' + model.salut + ' ' + model.firstN + ' ' + model.lastN;
		} else {
			ropEnrollmentRecord.Name = model.salut + ' ' + model.firstN + ' ' + model.lastN;
		}

		ropEnrollmentRecord.Salutation__c = model.salut;
		ropEnrollmentRecord.First_Name__c = model.firstN;
		ropEnrollmentRecord.Last_Name__c = model.lastN;
		ropEnrollmentRecord.Phone_Type__c = model.phnType;
		ropEnrollmentRecord.Country_Code__c = model.cCode;
		ropEnrollmentRecord.Area_Code__c = model.aCode;
		ropEnrollmentRecord.Phone_Number__c = model.phnNum;
		ropEnrollmentRecord.Email__c = model.email;
		ropEnrollmentRecord.Birthdate__c = model.birth;
		ropEnrollmentRecord.Gender__c = model.gender;
		ropEnrollmentRecord.Nationality__c = model.nation;
		ropEnrollmentRecord.Enrollment_Date__c = model.enrollD != null ? Date.valueOf(model.enrollD) : Date.today();
		ropEnrollmentRecord.Status__c = ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_NUMBER.get(model.status);
		ropEnrollmentRecord.PaxKey__c = model.paxKey;
		ropEnrollmentRecord.PassengerId__c = model.paxId;
		ropEnrollmentRecord.AccountId__c = model.accId;
		ropEnrollmentRecord.FlightId__c = model.fltId;
		ropEnrollmentRecord.Created_By_Crew__c = model.creBy;
		ropEnrollmentRecord.Reported_By_Crew__c = model.repBy;
		ropEnrollmentRecord.Manual_Enrollment__c = isManualEnrollment;
		ropEnrollmentRecord.Enrollment_Type__c = isManualEnrollment ? ENROLLMENT_TYPE_MANUAL : ENROLLMENT_TYPE_WEB_SERVICE;

		if (model.ropNumber != null) {
			ropEnrollmentRecord.ExternalId__c = model.ropNumber + '_' + ropEnrollmentRecord.PaxKey__c;
		} else {
			ropEnrollmentRecord.ExternalId__c = ropEnrollmentRecord.PaxKey__c;
		}

		return ropEnrollmentRecord;
	}

	public static Boolean isErrorResponse(WS_ROPEnrollmentResponseModel response) {
		if (response != null && response.EnrollROPMemberRes != null) {
			Boolean nullMainProfile = response.EnrollROPMemberRes.AddMainProfileRS == null;
			Boolean nullUpdateMemberCommunicationPreference = response.EnrollROPMemberRes.UpdateMemberCommunicationPreferenceRS == null;
			Boolean nullPendingEnrolmentError = response.EnrollROPMemberRes.AddPendingEnrolmentRS == null;
			Boolean allNodeNull = nullMainProfile && nullUpdateMemberCommunicationPreference && nullPendingEnrolmentError;

			Boolean addMainProfileError = !nullMainProfile && response.EnrollROPMemberRes.AddMainProfileRS.Error != null;
			Boolean updateMemberCommunicationPreferenceError = !nullUpdateMemberCommunicationPreference && response.EnrollROPMemberRes.UpdateMemberCommunicationPreferenceRS.Error != null;
			Boolean addPendingEnrolmentError = !nullPendingEnrolmentError && response.EnrollROPMemberRes.AddPendingEnrolmentRS.Error != null;
			Boolean containsError = (addMainProfileError  || updateMemberCommunicationPreferenceError || addPendingEnrolmentError);

			Boolean addMainProfileNoSuccess = response.EnrollROPMemberRes.AddMainProfileRS != null && response.EnrollROPMemberRes.AddMainProfileRS.Success == null;
			Boolean updateMemberCommunicationPreferenceNoSuccess = response.EnrollROPMemberRes.UpdateMemberCommunicationPreferenceRS != null && response.EnrollROPMemberRes.UpdateMemberCommunicationPreferenceRS.Success == null;
			Boolean addPendingEnrolmentNoSuccess = response.EnrollROPMemberRes.AddPendingEnrolmentRS != null && response.EnrollROPMemberRes.AddPendingEnrolmentRS.Success == null;
			Boolean containsNoSuccess = (addMainProfileNoSuccess && updateMemberCommunicationPreferenceNoSuccess && addPendingEnrolmentNoSuccess);
			return allNodeNull || containsError || containsNoSuccess;
		}
		return true;
	}

	public static String getIntegrationErrorReason(WS_ROPEnrollmentResponseModel response) {
		String responseString = System.JSON.serialize(response);
		if (responseString.containsIgnoreCase('duplicate')) {
			return REASON_DUPLICATE_MEMBER;
		}
		if (responseString.containsIgnoreCase('Please enter a correct e-mail')) {
			return REASON_WRONG_EMAIL_FORMAT;
		}
		if (responseString.containsIgnoreCase('MemberID is already in use')) {
			return REASON_MEMBERID_ALREADY_IN_USE;
		}
		return null;
	}

	public static List<MB_RestResponseInfoModel.ropEnrollment> convertROPEnrollmentSObjectToResponseModel(List<ROP_Enrollment__c> ropEnrollmentList) {
		List<MB_RestResponseInfoModel.ropEnrollment> ropEnrollmentModelList = new List<MB_RestResponseInfoModel.ropEnrollment>();
		for (ROP_Enrollment__c each : ropEnrollmentList) {
			MB_RestResponseInfoModel.ropEnrollment eachModel = new MB_RestResponseInfoModel.ropEnrollment();
			eachModel.ropNumber = each.ROP_Number_F__c;
			if (each.PassengerId__r != null) {
				eachModel.paxKey = MB_RESTPassengerService.getPaxKey(each.PassengerId__r);
			}
			eachModel.fltId = each.FlightId__c;
			eachModel.accId = each.AccountId__c;
			eachModel.paxId = each.PassengerId__c;
			eachModel.salut = each.Salutation__c;
			eachModel.firstN = each.First_Name__c;
			eachModel.lastN = each.Last_Name__c;
			eachModel.phnType = each.Phone_Type__c;
			eachModel.cCode = each.Country_Code__c;
			eachModel.aCode = each.Area_Code__c;
			eachModel.phnNum = each.Phone_Number__c;
			eachModel.email = each.Email__c;
			eachModel.nation = each.Nationality__c;
			eachModel.enrollD = String.valueOf(each.Enrollment_Date__c);
			eachModel.birth = each.Birthdate__c;
			eachModel.gender = each.Gender__c;
			eachModel.sfdcId = each.Id;
			eachModel.isSynced = '1';
			eachModel.reason = each.Integration_Error_Reason__c;
			eachModel.creBy = each.Created_By_Crew__c;
			eachModel.repBy = each.Reported_By_Crew__c;

			if (each.FlightId__r.Flight_External_ID__c != null) {
				String[] splitted = each.FlightId__r.Flight_External_ID__c.split('_');
				if (splitted != null && splitted.size() >= 2) {
					eachModel.fltNum = splitted[0] + splitted[1];
				}
			}

			if (each.Status__c == STATUS_ENROLL && !each.Integration_Error__c) {
				eachModel.status = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING.get(STATUS_ACTIVE);
			} else if (each.Status__c == STATUS_ENROLL && each.Integration_Error__c) {
				eachModel.status = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING.get(STATUS_INACTIVE);
			} else if (each.Status__c == STATUS_VOID) {
				eachModel.status = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING.get(STATUS_VOID);
			} else {
				eachModel.status = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING.get(STATUS_INACTIVE);
			}


			ropEnrollmentModelList.add(eachModel);
		}
		return ropEnrollmentModelList;
	}

	public static void sendEmailNotifyVoidedROPEnrollment(Map<Id, ROP_Enrollment__c> oldMap, List<ROP_Enrollment__c> ropEnrollmentList) {
		String toEmails = MailList_Repository.getEmailAddress('ROP Enrollment', 'ROPEnrollment_Void');

		List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
		for (ROP_Enrollment__c ropEnrollment : ropEnrollmentList) {
			Boolean isStatusChangedToVoid = oldMap.get(ropEnrollment.Id).Status__c != ropEnrollment.Status__c && ropEnrollment.Status__c == ROPEnrollmentService.STATUS_VOID;
			if (isStatusChangedToVoid) {
				String ropNumber = ropEnrollment.ROP_Number_F__c;
				String subject = 'Void ROP Enrollment: ' + ropNumber;
				String bodyMsg = 'The ROP Member with ID: ' + ropNumber + ' has voided the enrollment.\n'
				                 + 'Please proceed to revoke the membership from this Member ID.\n'
				                 + 'You can check the record of this enrollment in Salesforce at ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + ropEnrollment.Id;

				try {
					Email_Service.sendEmail(subject, toEmails, bodyMsg);
				} catch (Exception e) {
					String message = e.getMessage() + '\n' + e.getStackTraceString();
					AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'ROPEnrollmentService', 'sendEmailNotifyVoidedROPEnrollment', '', '', message, System.JSON.serialize(ropEnrollment), null, System.currentTimeMillis());
					AppLogger.insertLogs();
				}
			}
		}
	}

	public static void sendEmailNotifyInsufficientNumberOfROPNumber(Integer numberOfROPNumberAvailable) {
		List<Custom_Mail_List__mdt> receipientList = [SELECT Id, Email_Address__c FROM Custom_Mail_List__mdt WHERE Email_Type__c = 'ROP Enrollment'];
		for (Custom_Mail_List__mdt eachReceipient : receipientList) {
			Monitoring.notifyErrorByEmail('Insufficient Number of ROP Number', 'Please insert more ROP Number Inventory to Salesforce. Currently, there are ' + numberOfROPNumberAvailable + ' in Salesforce.', eachReceipient.Email_Address__c);
		}
	}

	public static List<MB_RESTResponseInfoModel.ropEnrollment> getROPEnrollmentMobileList(Set<Id> flightIdSet) {
		Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Flight_Master__c', [SELECT Id, Flight_Master__c FROM Flight__c WHERE Id IN : flightIdSet]);
		List<Passenger__c> passengerList = [SELECT Id, PaxKey__c, Staff_Booking__c, Board_Point__c, Off_Point__c, Checkin_Seat__c, AccountId__r.Mailling_Address__c, AccountId__r.ROP_Home_Phone__c, AccountId__r.ROP_Business_Phone__c, Infant__c, Infant_Name__c , Nationality_Fullname__c, Infant_Date_of_Birth__c, Infant_Age__c, Cabin_Code__c, Name, AccountId__r.Favorite_Drink__c, AccountId__r.Favorite_Food__c, FlightId__c, FlightId__r.Leg_Number__c, PNR__c, Booking_Seat__c, First_Name__c, Last_Name__c, Gender__c, AccountId__r.Date_of_Birth__c, Phone__c, Email_1__c, Email_2__c, Booking_Class__c, SSR__c, Special_Meal__c, SSR_Service__c, Nationality__c, Mobile__c, AccountId__c, AccountId__r.Phone, AccountId__r.ROP_Mobile__c, AccountId__r.ROP_Email_1__c, AccountId__r.ROP_Email_2__c, ROP_KEY__c, AccountId__r.ROP_Favorite_Food__c, AccountId__r.ROP_Favorite_Drink__c, AccountId__r.Like__c, AccountId__r.Dislike__c, AccountId__r.Information__c, AccountId__r.by_Ground_Customer_Service__c, AccountId__r.by_Sale_and_Marketing__c, FlightId__r.Flight_External_ID__c, FFP_Number__c, FFP_Tier__c, FFP_Carrier__c FROM Passenger__c WHERE FlightId__r.Flight_Master__c IN : flightMasterSet];
		Set<String> paxKeySet = new Set<String>();
		Set<Id> accountIdSet = new Set<Id>();
		for (Passenger__c each : passengerList) {
			paxKeySet.add(MB_RESTPassengerService.getPaxKey(each));
			accountIdSet.add(each.AccountId__c);
		}
		List<ROP_Enrollment__c> ropEnrollmentOnFlight = [SELECT Created_By_Crew__c, Reported_By_Crew__c, FlightId__c, FlightId__r.Name, FlightId__r.Flight_External_ID__c, PassengerId__r.First_Name__c, PassengerId__r.Last_Name__c, PassengerId__r.PaxKey__c, PassengerId__r.PNR__c, ROP_Number_F__c, AccountId__c, Area_Code__c, Birthdate__c, Country_Code__c, CreatedById, CreatedDate, Email__c, Enrollment_Date__c, First_Name__c, Gender__c, Id, Integration_Error_Reason__c, Integration_Error__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Last_Name__c, MembershipId__c, Name, Nationality__c, OwnerId, PassengerId__c, PaxKey__c, Phone_Number__c, Phone_Type__c, Response_from_THAI__c, ROP_Number__c, Salutation__c, Status__c FROM ROP_Enrollment__c WHERE PaxKey__c IN :paxKeySet OR AccountId__c IN : accountIdSet OR Integration_Error__c = true];
		List<MB_RestResponseInfoModel.ropEnrollment> ropEnrollmentModelList = ROPEnrollmentService.convertROPEnrollmentSObjectToResponseModel(ropEnrollmentOnFlight);
		return ropEnrollmentModelList;
	}
}