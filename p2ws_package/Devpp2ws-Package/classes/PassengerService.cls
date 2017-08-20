public with sharing class PassengerService {
	public static Set<String> SALUTATION_SET = new Set<String> {'MR', 'MS', 'MISS', 'MRS', 'MSTR'};
	public static Map<String, String> SALUTATION_MAP = new Map<String, String> {'MR' => 'Mr.', 'MS' => 'Ms.', 'MISS' => 'Miss', 'MRS' => 'Mrs.', 'MSTR' => 'Mstr.'};

	public static List<Passenger__c> convertSubTierToActualTier(List<Passenger__c> passengerList){
		for(Passenger__c eachPassenger : passengerList){
			if(eachPassenger.FFP_Carrier__c == BE8_GlobalConstants.DEFAULT_TG_COMPANY){
				eachPassenger.FFP_Tier_WS__c = eachPassenger.FFP_Tier__c;
				eachPassenger.FFP_Tier__c = MembershipService.getHardTierFromSubTierString(eachPassenger.FFP_Tier__c);
			}
		}
		return passengerList;
	}

	public static List<Passenger__c> populateFullNationalityName(List<Passenger__c> passengerList) {
		Set<String> nationalityAbbrStringSet = BE8_GlobalUtility.getStringSet('Nationality__c', passengerList);
		Map<String, SObject> nationalityFullNameMap = BE8_GlobalUtility.getSObjectMap('MasterLabel', [SELECT Id, MasterLabel, Nationality_Full_Name__c, Continent__c FROM Nationality_Master__mdt WHERE MasterLabel IN :nationalityAbbrStringSet]);

		for (Passenger__c each : passengerList) {
			if (nationalityFullNameMap.containsKey(each.Nationality__c)) {
				Nationality_Master__mdt nationalityMaster = (Nationality_Master__mdt) nationalityFullNameMap.get(each.Nationality__c);
				each.Nationality_Fullname__c = nationalityMaster.Nationality_Full_Name__c;
				each.Continent__c = nationalityMaster.Continent__c;
			}
		}

		return passengerList;
	}

	public static List<Passenger__c> populatePaxKeyTXT(List<Passenger__c> passengerList) {
		Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('FlightId__c', passengerList);
		Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>([SELECT Id, Flight_Master__c FROM Flight__c WHERE Id IN :flightIdSet]);
		for (Passenger__c passenger : passengerList) {
			if (flightMap.containsKey(passenger.FlightId__c)) {
				Flight__c flight = flightMap.get(passenger.FlightId__c);
				passenger.Pax_Key_txt__c = passenger.First_Name__c + '_' + passenger.Last_Name__c + '_' + passenger.PNR__c + '_' + flight.Flight_Master__c;
			}
		}
		return passengerList;
	}

	public static void changePassengersSeat(Map<Id, Passenger__c> oldMap, List<Passenger__c> passengerList) {
		if (oldMap != null) {
			for (Passenger__c newPassenger : passengerList) {
				Passenger__c oldPassenger = oldMap.get(newPassenger.Id);
				if (oldPassenger != null) {
					if (oldPassenger.Last_Change_Seat_DateTime__c != null) {
						Boolean isOverrideOldSeat = oldPassenger.Last_Change_Seat_DateTime__c < newPassenger.Last_Change_Seat_DateTime__c;
						if (!isOverrideOldSeat) {
							newPassenger.Change_Seat__c = oldPassenger.Change_Seat__c;
							newPassenger.Change_Cabin_Class__c = oldPassenger.Change_Cabin_Class__c;
						}
					}
				}
			}
		}
	}

	public static List<Passenger__c> dedupPassengerToChangeSeatList(List<Passenger__c> passengerList) {
		Map<Id, Passenger__c> passengerMap = new Map<Id, Passenger__c>();
		for(Passenger__c eachPassenger : passengerList){
			if(!passengerMap.containsKey(eachPassenger.Id)){
				passengerMap.put(eachPassenger.Id, eachPassenger);
			} else {
				Passenger__c passengerFromMap = passengerMap.get(eachPassenger.Id);
				if(passengerFromMap.Last_Change_Seat_DateTime__c < eachPassenger.Last_Change_Seat_DateTime__c){
					passengerMap.put(eachPassenger.Id, eachPassenger);
				}
			}
		}
		return passengerMap.values();
	}

	public static List<Passenger__c> formatPassengerNameFromList(List<Passenger__c> passengerList) {
		for(Passenger__c eachPassenger : passengerList){
			getFormattedPassengerName(eachPassenger);
		}
		return passengerList;
	}

	public static Passenger__c getFormattedPassengerName(Passenger__c passenger) {
		String firstName = passenger.First_Name__c;
		String lastName = passenger.Last_Name__c;
		String newFirstName = '';
		String newLastName = '';
		if (firstName != null && !String.isEmpty(firstName) && lastName != null && !String.isEmpty(lastName)) {
			List<String> splittedFirstName = firstName.split(' ');
			String lastStringOfSplittedFirstName = splittedFirstName.get(splittedFirstName.size() - 1);
			List<String> rearrangedFirstNameList = new List<String>();
			if (isSalutation(lastStringOfSplittedFirstName)) {
				String salutation = lastStringOfSplittedFirstName;
				splittedFirstName.remove(splittedFirstName.size() - 1);
				rearrangedFirstNameList.add(capitalizeFirstLetter(salutation) + '.');

				//passenger.Passenger_Salutation_Auto__c = salutation;
				passenger.Passenger_Salutation_Auto__c = SALUTATION_MAP.get(salutation);
				passenger.Passenger_First_Name_Auto__c = String.join(splittedFirstName, ' ');
			}
			for (String eachString : splittedFirstName) {
				rearrangedFirstNameList.add(capitalizeFirstLetter(eachString));
			}
			newFirstName = String.join(rearrangedFirstNameList, ' ');

			List<String> splittedLastName = lastName.split(' ');
			List<String> rearrangedLastNameList = new List<String>();
			for (String eachString : splittedLastName) {
				rearrangedLastNameList.add(capitalizeFirstLetter(eachString));
			}
			newLastName = String.join(rearrangedLastNameList, ' ');

			passenger.Passenger_Name_Formatted__c = newFirstName + ' ' + newLastName;
		}
		return passenger;
	}

	private static Boolean isSalutation(String text) {
		return SALUTATION_SET.contains(text);
	}

	private static String capitalizeFirstLetter(String text) {
		String lowerCaseText = text.toLowerCase();
		return text.left(1).toUpperCase() + lowerCaseText.substring(1);
	}
}