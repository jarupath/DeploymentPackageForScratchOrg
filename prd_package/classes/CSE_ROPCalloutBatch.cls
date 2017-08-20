global class CSE_ROPCalloutBatch implements Database.Batchable<PassengerInTheSameRoute>, Database.AllowsCallouts {

	global class PassengerInTheSameRoute {
		public String ropNumber;
		public List<Passenger__c> passengerList;

		public PassengerInTheSameRoute(String ropNumber, List<Passenger__c> passengerList){
			this.ropNumber = ropNumber;
			this.passengerList = passengerList;
		}
	}

	private static final String CLASS_NAME = 'CSE_ROPCalloutBatch';
	private List<String> rops;
	private Set<Id> flightIdSet;

	global CSE_ROPCalloutBatch(List<String> pRops) {
		this.rops = pRops;
	}

	global CSE_ROPCalloutBatch(Set<Id> flightIdSet) {
		this.flightIdSet = flightIdSet;
	}

	public Map<String, Id> findExistingROPAndAccount(List<String> pRops) {
		Map<String, Id> mMemberAcc = new Map<String, Id>();
		for (Membership__c existROP : [Select EXTMember__c, AccountId__c, AccountId__R.Name From Membership__c Where Name In :pRops AND Status__c = :BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE]) {
			mMemberAcc.put(existROP.EXTMember__c, existROP.AccountId__c);
			System.debug('CSE_ROPCalloutBatch.findExistingROPAndAccount :Maching membership ext/accountId :' +
			             existROP.EXTMember__c + '/' + existROP.AccountId__c + '/' + existROP.AccountId__R.Name);
		}
		return mMemberAcc;
	}

	private String getStringDate(Date pDate) {
		if (pDate == null) {
			return '';
		}
		return pDate.year() + '-' + pDate.month() + '-' + pDate.day();
	}

	public void updateMemberAccount(List<Passenger__c> passengerListOnFlight) {
		if (passengerListOnFlight != null && passengerListOnFlight.size() > 0) {
			AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '' + flightIdSet, 'Flight Id Set', 'Passenger List', System.JSON.serialize(passengerListOnFlight), null, System.currentTimeMillis());
		}
		Set<String> departureStationSet = new Set<String>();
		Set<String> arrivalStationSet = new Set<String>();
		for (Passenger__c eachPassenger : passengerListOnFlight) {
			departureStationSet.add(eachPassenger.FlightId__r.Departure_STN__c);
			arrivalStationSet.add(eachPassenger.FlightId__r.Arrival_STN__c);
		}
		MileageUpgradeSeatCalculator mileageCalculator = new MileageUpgradeSeatCalculator(departureStationSet, arrivalStationSet);
		Set<String> passengerROPNumberSet = BE8_GlobalUtility.getStringSet('FFP_Number__c', passengerListOnFlight);
		Map<String, SObject> membershipMapByFFPNumber = BE8_GlobalUtility.getSObjectMap('Name', [SELECT Name, EXTMember__c, AccountId__c, AccountId__r.First_Name__c, AccountId__r.Last_Name__c, AccountId__r.Date_of_Birth__c From Membership__c Where Name In :passengerROPNumberSet AND Status__c = :BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE]);
		Map<String, List<Passenger__c>> passengerMapByROPExternalId = new Map<String, List<Passenger__c>>();
		for (Passenger__c eachPassenger : passengerListOnFlight) {
			eachPassenger.Eligible_for_Upgrade_Seat__c = null;
			eachPassenger.Eligible_for_Upgrade_Seat_Priority__c = null;

			String ropNumber = eachPassenger.FFP_Number__c;
			List<Passenger__c> passengerListWithThisROPNumber = passengerMapByROPExternalId.get(ropNumber);
			if (passengerListWithThisROPNumber == null) {
				passengerListWithThisROPNumber = new List<Passenger__c>();
				passengerMapByROPExternalId.put(ropNumber, passengerListWithThisROPNumber);
			}
			passengerListWithThisROPNumber.add(eachPassenger);
		}
		System.debug('passengerMapByROPExternalId: ' + passengerMapByROPExternalId);
		AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '' + flightIdSet, 'Flight Id Set', 'passengerMapByROPExternalId', System.JSON.serialize(passengerMapByROPExternalId), null, System.currentTimeMillis());

		List<String> pRops = new List<String>(passengerROPNumberSet);
		//Map<String, Id> mMemberAcc = findExistingROPAndAccount(pRops);

		CSE_SOAPROP_WS ws = new CSE_SOAPROP_WS();
		CSE_SOAPROPMILEAGE_WS wsml = new CSE_SOAPROPMILEAGE_WS();
		CSE_SOAPROPAdditionalProfile_WS wsap = new CSE_SOAPROPAdditionalProfile_WS();
		Map<String, Membership__c> mMember = new Map<String, Membership__c>();
		List<Account> accounts = new List<Account>();

		for (String rop : passengerMapByROPExternalId.keySet()) {
			Membership__c m = new Membership__c();
			WS_ROPMileageModel mi = null;
			String key = CSE_SOAPUpdatePax_WS.getMemberExtId(BE8_GlobalConstants.DEFAULT_TG_COMPANY, rop);
			if (membershipMapByFFPNumber.containsKey(rop)) {
				m = (Membership__c) membershipMapByFFPNumber.get(rop);

				// Update Account
				Account ac = new Account();
				accounts.add(ac);
				ac.Id = m.AccountId__c;

				// ===== ===== ===== Get Profile ===== ===== =====
				WS_ROPProfileModel p;
				try {
					p = ws.getROPProfile(rop);
					System.debug('getROPProfile: ' + p);

					if (p != null && p.MemberProfileRS != null) {
						ac.Date_of_Birth__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, p.MemberProfileRS.BirthDate); //Date
						ac.Email_1__c = p.MemberProfileRS.Email;
						ac.ROP_Email_1__c = p.MemberProfileRS.Email;
						ac.First_Name__c = p.MemberProfileRS.FirstName;
						ac.Gender__c = BE8_GlobalConstants.MAP_ACCOUNT_GENDER.get(p.MemberProfileRS.Gender); // Picklist
						ac.Last_Name__c = p.MemberProfileRS.LastName;
						ac.ROP_Number__c = rop;
						ac.Salutation__c = p.MemberProfileRS.Salutation;

						if (p.MemberProfileRS.Address != null) {
							// AddressLine1 AddressLine2 AddressLine3 CityName ProvinceState CountryName PostalZipCode
							ac.Mailling_Address__c = '';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(p.MemberProfileRS.Address.AddressLine1) + ' ';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(p.MemberProfileRS.Address.AddressLine2) + ' ';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(p.MemberProfileRS.Address.AddressLine3) + ' ';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(p.MemberProfileRS.Address.CityName) + ' ';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(p.MemberProfileRS.Address.ProvinceCode) + ' ';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(BE8_GlobalConstants.COUNTRY_CODE_NAME.get(p.MemberProfileRS.Address.CountryCode)) + ' ';
							ac.Mailling_Address__c += BE8_GlobalUtility.str(p.MemberProfileRS.Address.Postal);

							// Company 1, Company 2
							ac.ROP_Company_Name_1__c = BE8_GlobalUtility.str(p.MemberProfileRS.Address.CompanyName1);
							ac.ROP_Company_Name_2__c = BE8_GlobalUtility.str(p.MemberProfileRS.Address.CompanyName2);
						}

						// Home phone
						if (p.MemberProfileRS.HomePhone != null) {
							ac.ROP_Home_Country_Code__c = BE8_GlobalUtility.str(p.MemberProfileRS.HomePhone.CountryCode);
							ac.ROP_Home_Area_Code__c = BE8_GlobalUtility.str(p.MemberProfileRS.HomePhone.AreaCode);
							ac.ROP_Home_Phone__c = BE8_GlobalUtility.str(p.MemberProfileRS.HomePhone.PhoneNumber);
							ac.ROP_Home_Extension__c = BE8_GlobalUtility.str(p.MemberProfileRS.HomePhone.Extension);
						}

						if (p.MemberProfileRS.Phone != null && !p.MemberProfileRS.Phone.isEmpty()) {
							for (WS_ROPProfileModel.Phone ph : p.MemberProfileRS.Phone) {
								// CountryCode AreaCode PhoneNumber Extension
								// FAX
								if ('F'.equals(ph.Type)) {
									ac.ROP_Fax_Country_Code__c = BE8_GlobalUtility.str(ph.CountryCode);
									ac.ROP_Fax_Area_Code__c = BE8_GlobalUtility.str(ph.AreaCode);
									ac.ROP_Fax__c = BE8_GlobalUtility.str(ph.PhoneNumber);
									ac.ROP_Fax_Extension__c = BE8_GlobalUtility.str(ph.Extension);
								}

								// Business phone 1
								else if ('BPH'.equals(ph.Type)) {
									ac.ROP_Business_Country_Code__c = BE8_GlobalUtility.str(ph.CountryCode);
									ac.ROP_Business_Area_Code__c = BE8_GlobalUtility.str(ph.AreaCode);
									ac.ROP_Business_Phone__c = BE8_GlobalUtility.str(ph.PhoneNumber);
									ac.ROP_Business_Extension__c = BE8_GlobalUtility.str(ph.Extension);
								}

								// Mobile phone 1
								else if ('C'.equals(ph.Type)) {
									ac.ROP_Mobile_Country_Code__c = BE8_GlobalUtility.str(ph.CountryCode);
									ac.ROP_Mobile_Area_Code__c = BE8_GlobalUtility.str(ph.AreaCode);
									ac.ROP_Mobile__c = BE8_GlobalUtility.str(ph.PhoneNumber);
									ac.ROP_Mobile_Extension__c = BE8_GlobalUtility.str(ph.Extension);
								}
							}// End for
						}// End if

						// Update Membership
						m.Airline__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY;
						m.Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, p.MemberProfileRS.CardExpiryDate); //Date
						m.Language__c = p.MemberProfileRS.Language;
						m.Status__c = BE8_GlobalConstants.MAP_ROP_STATUS.get(p.MemberProfileRS.Status); // Active, Inactive, Dead, Closed, Merge
						m.Tier__c = p.MemberProfileRS.PrivilegeCard;
					} else {
						System.debug('CSE_ROPCalloutBatch.updateMemberAccount getProfile :ROP :' + rop + ' does not exist.');
					}
				} catch (Exception e) {
					System.debug('ERROR while get profile from ROP number :' + rop + ' failed :' + e);
					String message = 'ERROR while get profile from ROP number :' + rop + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
					AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_ROPCalloutBatch', 'updateMemberAccount', rop, 'ROP', message, System.JSON.serialize(p), e, System.currentTimeMillis());
				}


				// ===== ===== ===== Get additional profile ===== ===== =====
				WS_ROPAdditionalProfileModel ap;
				try {
					ap = wsap.getAdditionalProfile(rop);
					if (ap != null && ap.GetAdditionalMemberProfileRes != null && ap.GetAdditionalMemberProfileRes.Success != null) {
						ac.ROP_Marital_Status__c = BE8_GlobalConstants.MAP_ROP_MARITIAL.get(ap.GetAdditionalMemberProfileRes.Success.MaritalStatus); //Picklist
						m.Occupation__c = BE8_GlobalConstants.MAP_ROP_OCCUPATION.get(ap.GetAdditionalMemberProfileRes.Success.Occupation);
					} else {
						System.debug('CSE_ROPCalloutBatch.updateMemberAccount getAdditionalProfile :ROP :' + rop + ' does not exist.');
					}
				} catch (Exception e) {
					System.debug('ERROR while get additional profile from ROP number :' + rop + ' failed :' + e);
					String message = 'ERROR while get additional profile from ROP number :' + rop + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
					AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_ROPCalloutBatch', 'updateMemberAccount', rop, 'ROP', message, System.JSON.serialize(ap), e, System.currentTimeMillis());
				}

				// ===== ===== ===== Get mileage ===== ===== =====
				try {
					List<Passenger__c> passengerListWithThisROPNumber = passengerMapByROPExternalId.get(rop);
					List<Passenger__c> validPassengerList = new List<Passenger__c>();
					for (Passenger__c eachPassenger : passengerListWithThisROPNumber) {
						System.debug('pax lastname mod: ' + eachPassenger.Last_Name__c.replaceAll('\\W+', ''));
						if(ac != null) System.debug('acc lastname: ' + ac.Last_Name__c.replaceAll('\\W+', ''));
						Boolean passengerNameMatchesWithNameOnROP = eachPassenger.AccountId__c != null && eachPassenger.Last_Name__c.replaceAll('\\W+', '') == ac.Last_Name__c.replaceAll('\\W+', '');
						Boolean passengerMatchDateOfBirthWithROP = eachPassenger.AccountId__c != null && eachPassenger.Date_of_Birth_Input__c == ac.Date_of_Birth__c;

						System.debug(rop + ' passengerNameMatchesWithNameOnROP: ' + passengerNameMatchesWithNameOnROP + ' passengerMatchDateOfBirthWithROP: ' + passengerMatchDateOfBirthWithROP);
						System.debug('Passenger: ' + eachPassenger.First_Name__c + ' ' + eachPassenger.Last_Name__c + ' ' + eachPassenger.Date_of_Birth_Input__c + ' Account: ' + ac.First_Name__c + ' ' + ac.Last_Name__c + ' ' + ac.Date_of_Birth__c);
						if (passengerNameMatchesWithNameOnROP && passengerMatchDateOfBirthWithROP) {
							validPassengerList.add(eachPassenger);
						}
					}

					if (!validPassengerList.isEmpty()) {
						mMember.put(key, m);
						mi = wsml.getCurrentMileage(rop);

						m.EXTMember__c = key;
						if (mi != null && mi.CurrentMileageRS != null) {
							m.Mileages__c = BE8_GlobalUtility.toNumber(mi.CurrentMileageRS.CurrentMileage);
							ac.ROP_Tier__c = mi.CurrentMileageRS.PrivilegeCard;


							if (mi.CurrentMileageRS.MilesExpiry != null && !mi.CurrentMileageRS.MilesExpiry.isEmpty()) {
								List<String> expireDates = new List<String>();
								Map<String, String> mExpire = new Map<String, String>();
								String strCurrentDate = getStringDate(Date.today());

								for (WS_ROPMileageModel.MilesExpiry mileEx : mi.CurrentMileageRS.MilesExpiry) {
									expireDates.add(mileEx.MilesExpiryDate); // Add all expire dates to the list
									mExpire.put(mileEx.MilesExpiryDate, mileEx.Amount); // Map between expire date and expire amount
									if ('1' == mileEx.Quarter) {
										m.Mileages_Q_1__c = BE8_GlobalUtility.toNumber(mileEx.Amount);
										m.Mileages_Q_1_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, mileEx.MilesExpiryDate); //Date
									} else if ('2' == mileEx.Quarter) {
										m.Mileages_Q_2__c = BE8_GlobalUtility.toNumber(mileEx.Amount);
										m.Mileages_Q_2_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, mileEx.MilesExpiryDate); //Date
									} else if ('3' == mileEx.Quarter) {
										m.Mileages_Q_3__c = BE8_GlobalUtility.toNumber(mileEx.Amount);
										m.Mileages_Q_3_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, mileEx.MilesExpiryDate); //Date
									} else if ('4' == mileEx.Quarter) {
										m.Mileages_Q_4__c = BE8_GlobalUtility.toNumber(mileEx.Amount);
										m.Mileages_Q_4_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, mileEx.MilesExpiryDate); //Date
									}

								}// End for(WS_ROPMileageModel.MilesExpiry)


								//if (!expireDates.isEmpty()) {
								//	expireDates.sort();
								//	for (String expireDate : expireDates) {
								//		if (strCurrentDate.compareTo(expireDate) <= 0) {
								//			m.Mileages_Current_Quater__c = BE8_GlobalUtility.toNumber(mExpire.get(expireDate));
								//			m.Mileages_Current_Quater_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, expireDate); //Date
								//		}
								//	}
								//}// End if(!expireDates.isEmpty)
								Map<Date, Decimal> mileageMapByExpiryDate = new Map<Date, Decimal>();
								if (m.Mileages_Q_1_Expiry_Date__c != null) {
									mileageMapByExpiryDate.put(m.Mileages_Q_1_Expiry_Date__c, m.Mileages_Q_1__c);
								}
								if (m.Mileages_Q_2_Expiry_Date__c != null) {
									mileageMapByExpiryDate.put(m.Mileages_Q_2_Expiry_Date__c, m.Mileages_Q_2__c);
								}
								if (m.Mileages_Q_3_Expiry_Date__c != null) {
									mileageMapByExpiryDate.put(m.Mileages_Q_3_Expiry_Date__c, m.Mileages_Q_3__c);
								}
								if (m.Mileages_Q_4_Expiry_Date__c != null) {
									mileageMapByExpiryDate.put(m.Mileages_Q_4_Expiry_Date__c, m.Mileages_Q_4__c);
								}

								if (!mileageMapByExpiryDate.isEmpty()) {
									List<Date> mileageExpiryDateList = new List<Date>(mileageMapByExpiryDate.keySet());
									mileageExpiryDateList.sort();
									Date mostRecentExpiryDate = mileageExpiryDateList.get(0);
									m.Mileages_Current_Quater__c = mileageMapByExpiryDate.get(mostRecentExpiryDate);
									m.Mileages_Current_Quater_Expiry_Date__c = mostRecentExpiryDate;
								}
							}// End if(mi.CurrentMileageRS.MilesExpiry != null

							System.debug('Get current mileage :' + key + ' value :' + mi.CurrentMileageRS.CurrentMileage);

							mileageCalculator.calculateEligibleSeatUpgrade(m, validPassengerList);
						} else {
							System.debug('CSE_ROPCalloutBatch.updateMemberAccount getCurrentMileage :ROP :' + rop + ' does not exist.');
						}

						m.Tier__c = mi.CurrentMileageRS.PrivilegeCard;
					}


				} catch (Exception e) {
					System.debug('ERROR while get current mileage from ROP number :' + rop + ' failed :' + e);
					String message = 'ERROR while get current mileage from ROP number :' + rop + '\n' + e.getMessage() + '\n' + e.getStackTraceString();
					AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_ROPCalloutBatch', 'updateMemberAccount', rop, 'ROP', message, System.JSON.serialize(mi), e, System.currentTimeMillis());
				}

			}
		}// End for(String rop)

		if (accounts != null && !accounts.isEmpty()) {
			for (Account a : accounts) {
				System.debug('Account ID :' + a.Id + ' firstName :' + a.First_Name__c + ' lastName :' + a.Last_Name__c);
			}
		}

		try {
			Map<Id, Account> accountDedupMap = new Map<Id, Account>();
			for (Account eachAccount : accounts) {
				if (eachAccount.Id != null) {
					accountDedupMap.put(eachAccount.Id, eachAccount);
				}
			}
			Database.update(accountDedupMap.values(), false);
			System.debug('accounts: ' + accounts);
		} catch (Exception e) {
			String message = e.getMessage() + '\n' + e.getStackTraceString();
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '', 'Account', message, System.JSON.serialize(accounts), e, System.currentTimeMillis());
		}

		try {
			List<Database.UpsertResult> results = Database.upsert(mMember.values(), Membership__c.EXTMember__c, false);
			AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '' + flightIdSet, 'Flight Id Set', 'Update Membership', JSON.serialize(mMember.values()), null, System.currentTimeMillis());
		} catch (Exception e) {
			String message = e.getMessage() + '\n' + e.getStackTraceString();
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '', 'Membership__c', message, System.JSON.serialize(mMember.values()), e, System.currentTimeMillis());
		}

		try {
			update passengerListOnFlight;
			AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '' + flightIdSet, 'Flight Id Set', 'Update Passenger', JSON.serialize(passengerListOnFlight), null, System.currentTimeMillis());
		} catch (Exception e) {
			String message = e.getMessage() + '\n' + e.getStackTraceString();
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_ROPCalloutBatch', 'updateMemberAccount', '', 'Passenger__c', message, System.JSON.serialize(passengerMapByROPExternalId.values()), e, System.currentTimeMillis());
		}

	}

	global Iterable<PassengerInTheSameRoute> start(Database.BatchableContext BC) {
		List<Flight__c> flightList = [SELECT Id, Flight_Master__c, Leg_Number__c FROM Flight__c WHERE Id IN :flightIdSet ORDER BY Leg_Number__c ASC];
		Decimal startingLegNumber = 1;
		if(flightList != null && !flightList.isEmpty()){
			startingLegNumber = flightList[0].Leg_Number__c;
		}
		Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Flight_Master__c', flightList);
		System.debug(flightMasterSet);
		List<Passenger__c> passengerListOnFlight = [SELECT Id, FlightId__r.Routing__c, Pax_Key_txt__c, Eligible_for_Upgrade_Seat__c, Eligible_for_Upgrade_Seat_Priority__c, Last_Name__c, Board_Point__c, Off_Point__c,  Date_of_Birth_Input__c, Name, Cabin_Code__c, Flight_Origin__c, Flight_Destination__c, FFP__c, FFP_Number__c, FFP_Carrier__c, FlightId__r.Origin__c, FlightId__r.Destination__c, AccountId__r.Last_Name__c, AccountId__r.Date_of_Birth__c, FlightId__r.Departure_STN__c, FlightId__r.Arrival_STN__c FROM Passenger__c WHERE FFP_Carrier__c = :BE8_GlobalConstants.DEFAULT_TG_COMPANY AND FlightId__r.Flight_Master__c IN :flightMasterSet AND FlightId__r.Leg_Number__c >= :startingLegNumber ORDER BY Pax_Key_txt__c ASC];
		System.debug('passengerListOnFlight: ' + passengerListOnFlight);
		System.debug(JSON.serialize(passengerListOnFlight));
		Map<String, List<SObject>> passengerListMapByPaxKey = BE8_GlobalUtility.getSObjectListMap('Pax_Key_txt__c', passengerListOnFlight);
		List<PassengerInTheSameRoute> passengerInTheSameRouteList = new List<PassengerInTheSameRoute>();
		for(String paxKey : passengerListMapByPaxKey.keySet()){
			List<Passenger__c> passengerList = passengerListMapByPaxKey.get(paxKey);
			passengerInTheSameRouteList.add(new PassengerInTheSameRoute(passengerList[0].FFP_Number__c, passengerList));
		}
		return passengerInTheSameRouteList;
		//return passengerListOnFlight;
	}

	global void execute(Database.BatchableContext BC, List<PassengerInTheSameRoute> scope) {
		System.debug(JSON.serialize(scope));
		System.debug('scope: ' + scope);
		List<Passenger__c> allPassengerList = new List<Passenger__c>();
		for (PassengerInTheSameRoute each : scope) {
			for(Passenger__c eachPax : each.passengerList){
				System.debug(eachPax.Pax_Key_txt__c);
			}
			allPassengerList.addAll(each.passengerList);
		}
		updateMemberAccount(allPassengerList);
		AppLogger.insertLogs();
	}

	global void finish(Database.BatchableContext BC) {
		System.debug('----- ----- ----- FINISH ROP ----- ----- ----- ');
	}
}