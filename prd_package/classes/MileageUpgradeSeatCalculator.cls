public with sharing class MileageUpgradeSeatCalculator {

	public Map<String, In_flight_Upgrade_Seat_Master__mdt> masterDataMapByRouteAndClass;
	private Map<String, List<String>> nextClassAvailableForUpgradeMap = new Map<String, List<String>> {
		'Y' => new List<String> {'C', 'U'},
		'U' => new List<String> {'C'}
	};

	public MileageUpgradeSeatCalculator(Set<String> originSet, Set<String> destinationSet) {
		Set<String> originAndDestinationSet = new Set<String>();
		masterDataMapByRouteAndClass = new Map<String, In_flight_Upgrade_Seat_Master__mdt>();
		List<In_flight_Upgrade_Seat_Master__mdt> allMasterDataList = new List<In_flight_Upgrade_Seat_Master__mdt>();
		if (originSet == null && destinationSet == null) {
			allMasterDataList = [SELECT DeveloperName, Origin__c, Destination__c, Upgrade_From_Class__c, Upgrade_To_Class__c, Amount__c, ROP_Award_Code__r.Mileages__c FROM In_flight_Upgrade_Seat_Master__mdt];
		} else {
			originAndDestinationSet.addAll(originSet);
			originAndDestinationSet.addAll(destinationSet);
			allMasterDataList = [SELECT DeveloperName, Origin__c, Destination__c, Upgrade_From_Class__c, Upgrade_To_Class__c, Amount__c, ROP_Award_Code__r.Mileages__c FROM In_flight_Upgrade_Seat_Master__mdt WHERE (Origin__c IN :originAndDestinationSet AND Destination__c IN :originAndDestinationSet)];
		}
		for (In_flight_Upgrade_Seat_Master__mdt each : allMasterDataList) {
			String key = getMasterDataMapByRouteAndClassKey(each.Origin__c, each.Destination__c, each.Upgrade_From_Class__c, each.Upgrade_To_Class__c);
			masterDataMapByRouteAndClass.put(key, each);
		}
	}

	public List<Passenger__c> calculateEligibleSeatUpgrade(Membership__c membership, List<Passenger__c> passengerList) {
		if (membership != null && passengerList != null && passengerList.size() > 0) {
			Map<String, List<SObject>> passengerMapByPaxKey = BE8_GlobalUtility.getSObjectListMap('Pax_Key_txt__c', passengerList);
			for (String eachPaxKey : passengerMapByPaxKey.keySet()) {
				List<Passenger__c> passengerListOfSinglePassengerWithinTheRoute = (List<Passenger__c>) passengerMapByPaxKey.get(eachPaxKey);
				System.debug('passengerListOfSinglePassengerWithinTheRoute: ' + passengerListOfSinglePassengerWithinTheRoute);
				List<In_flight_Upgrade_Seat_Master__mdt> masterDataListForThisPassengerList = getMasterDataList(passengerListOfSinglePassengerWithinTheRoute);
				Map<String, List<In_flight_Upgrade_Seat_Master__mdt>> masterDataListMapByFromClassAndToClass = createMasterDataListMapByFromClassAndToClass(masterDataListForThisPassengerList);

				Decimal currentQuaterMileages = membership.Mileages_Current_Quater__c;
				Decimal allMileages = membership.Mileages__c;
				String travelClass = passengerListOfSinglePassengerWithinTheRoute[0].Cabin_Code__c;
				System.debug(eachPaxKey + ' currentQuaterMileages: ' + currentQuaterMileages + ' allMileages: ' + allMileages + ' travelClass: ' + travelClass);
				List<String> nextClassAvailableForUpgradeList = nextClassAvailableForUpgradeMap.get(travelClass);

				if (nextClassAvailableForUpgradeList != null) {
					for (String eachNextAvailableClass : nextClassAvailableForUpgradeList) {
						List<In_flight_Upgrade_Seat_Master__mdt> masterDataListWithMatchedClass = masterDataListMapByFromClassAndToClass.get(travelClass + '-' + eachNextAvailableClass);
						if (masterDataListWithMatchedClass != null) {
							Decimal requiredMileages = 0;
							for (In_flight_Upgrade_Seat_Master__mdt eachMasterData : masterDataListWithMatchedClass) {
								System.debug('eachMasterData: ' + eachMasterData);
								requiredMileages += eachMasterData.ROP_Award_Code__r.Mileages__c;
							}

							System.debug(travelClass + '-' + eachNextAvailableClass + ' requiredMileages:' + requiredMileages);
							if (currentQuaterMileages >= requiredMileages) {
								provideUpgradeSeatEligibilityToPassenger(passengerListOfSinglePassengerWithinTheRoute, masterDataListWithMatchedClass, 'Eligible_for_Upgrade_Seat_Priority__c');
							}
							if (allMileages >= requiredMileages) {
								provideUpgradeSeatEligibilityToPassenger(passengerListOfSinglePassengerWithinTheRoute, masterDataListWithMatchedClass, 'Eligible_for_Upgrade_Seat__c');
							}
						}
					}
				}
			}
		}
		return passengerList;
	}

	private Map<String, List<In_flight_Upgrade_Seat_Master__mdt>> createMasterDataListMapByFromClassAndToClass(List<In_flight_Upgrade_Seat_Master__mdt> masterDataList) {
		Map<String, List<In_flight_Upgrade_Seat_Master__mdt>> masterDataListMapByFromClassAndToClass = new Map<String, List<In_flight_Upgrade_Seat_Master__mdt>>();
		for (In_flight_Upgrade_Seat_Master__mdt each : masterDataList) {
			String key = each.Upgrade_From_Class__c + '-' + each.Upgrade_To_Class__c;
			List<In_flight_Upgrade_Seat_Master__mdt> tempList = masterDataListMapByFromClassAndToClass.get(key);
			if (tempList == null) {
				tempList = new List<In_flight_Upgrade_Seat_Master__mdt>();
				masterDataListMapByFromClassAndToClass.put(key, tempList);
			}
			tempList.add(each);
		}
		return masterDataListMapByFromClassAndToClass;
	}

	//private Decimal getCurrentQuaterMileagesFromMembership(Membership__c membership) {
	//	Map<Date, Decimal> mileageMapByExpiryDate = new Map<Date, Decimal>();
	//	if (membership.Mileages_Q_1_Expiry_Date__c != null) {
	//		mileageMapByExpiryDate.put(membership.Mileages_Q_1_Expiry_Date__c, membership.Mileages_Q_1__c);
	//	}
	//	if (membership.Mileages_Q_2_Expiry_Date__c != null) {
	//		mileageMapByExpiryDate.put(membership.Mileages_Q_2_Expiry_Date__c, membership.Mileages_Q_2__c);
	//	}
	//	if (membership.Mileages_Q_3_Expiry_Date__c != null) {
	//		mileageMapByExpiryDate.put(membership.Mileages_Q_3_Expiry_Date__c, membership.Mileages_Q_3__c);
	//	}
	//	if (membership.Mileages_Q_4_Expiry_Date__c != null) {
	//		mileageMapByExpiryDate.put(membership.Mileages_Q_4_Expiry_Date__c, membership.Mileages_Q_4__c);
	//	}

	//	if(!mileageMapByExpiryDate.isEmpty()){
	//		List<Date> mileageExpiryDateList = new List<Date>(mileageMapByExpiryDate.keySet());
	//		mileageExpiryDateList.sort();
	//		Date mostRecentExpiryDate = mileageExpiryDateList.get(0);
	//		return mileageMapByExpiryDate.get(mostRecentExpiryDate);
	//	}
	//	return 0;
	//}

	//private List<In_flight_Upgrade_Seat_Master__mdt> getMasterDataList(String origin, String destination) {
	//	List<In_flight_Upgrade_Seat_Master__mdt> masterDataList = null;
	//	if (masterDataMapByRoute.containsKey(origin + '-' + destination)) {
	//		return masterDataMapByRoute.get(origin + '-' + destination);
	//	} else if (masterDataMapByRoute.containsKey(destination + '-' + origin)) {
	//		return masterDataMapByRoute.get(destination + '-' + origin);
	//	}
	//	return null;
	//}

	private List<In_flight_Upgrade_Seat_Master__mdt> getMasterDataList(List<Passenger__c> passengerList) {
		List<In_flight_Upgrade_Seat_Master__mdt> masterDataList = new List<In_flight_Upgrade_Seat_Master__mdt>();
		Set<String> keySet = getMasterDataMapByRouteAndClassKeySetFromPassengerList(passengerList);
		for (String eachKey : keySet) {
			if (masterDataMapByRouteAndClass.containsKey(eachKey)) {
				masterDataList.add(masterDataMapByRouteAndClass.get(eachKey));
			}
		}
		return masterDataList;
	}

	private Set<String> getMasterDataMapByRouteAndClassKeySetFromPassengerList(List<Passenger__c> passengerList) {
		Set<String> keySet = new Set<String>();
		for (Passenger__c eachPassenger : passengerList) {
			String origin = eachPassenger.FlightId__r.Departure_STN__c;
			String destination = eachPassenger.FlightId__r.Arrival_STN__c;
			String currentClass = eachPassenger.Cabin_Code__c;
			List<String> nextClassAvailableForUpgradeList = nextClassAvailableForUpgradeMap.get(currentClass);
			if (nextClassAvailableForUpgradeList != null) {
				for (String eachNextAvailableClass : nextClassAvailableForUpgradeList) {
					keySet.add(getMasterDataMapByRouteAndClassKey(origin, destination, currentClass, eachNextAvailableClass));
					keySet.add(getMasterDataMapByRouteAndClassKey(destination, origin, currentClass, eachNextAvailableClass));
				}
			}
		}
		return keySet;
	}

	private String getMasterDataMapByRouteAndClassKey(String origin, String destination, String fromClass, String toClass) {
		return origin + '-' + destination + '_' + fromClass + '-' + toClass;
	}

	private List<Passenger__c> provideUpgradeSeatEligibilityToPassenger(List<Passenger__c> passengerList, List<In_flight_Upgrade_Seat_Master__mdt> upgradeSeatItemList, String fieldName) {
		for (Passenger__c eachPassenger : passengerList) {
			String origin = eachPassenger.FlightId__r.Departure_STN__c;
			String destination = eachPassenger.FlightId__r.Arrival_STN__c;
			String currentClass = eachPassenger.Cabin_Code__c;
			for (In_flight_Upgrade_Seat_Master__mdt upgradeSeatItem : upgradeSeatItemList) {
				Boolean matchOriginDestination = (upgradeSeatItem.Origin__c == origin && upgradeSeatItem.Destination__c == destination) || (upgradeSeatItem.Origin__c == destination && upgradeSeatItem.Destination__c == origin);
				Boolean matchClass = upgradeSeatItem.Upgrade_From_Class__c == currentClass;
				if (matchOriginDestination && matchClass) {
					String fieldValue = eachPassenger.get(fieldName) != null ? (String) eachPassenger.get(fieldName) : null;
					if (fieldValue == null) {
						eachPassenger.put(fieldName, '');
						fieldValue = '';
					}
					if (fieldValue.indexOf(upgradeSeatItem.DeveloperName) == -1) {
						eachPassenger.put(fieldName, fieldValue + upgradeSeatItem.DeveloperName + ',');
					}
				}
			}
		}
		return passengerList;
	}
}