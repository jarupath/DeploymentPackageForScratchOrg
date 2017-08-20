public with sharing class CreatePassengerFromPaxProcessBuilder {
	@InvocableMethod
	public static void createAccountFromPax(List<Passenger__c> paxlist){
		System.debug('DEBUG FROM CLASS');
		Set<Id> paxIsSet = BE8_GlobalUtility.getIdSet('Id', paxlist);
		Map<String, List<SObject>> caseListMap = BE8_GlobalUtility.getSObjectListMap('Passengerid__c', [SELECT Id, Passengerid__c FROM Case WHERE Passengerid__c IN :paxIsSet]);
		Map<String, List<SObject>> caseGroupListMap = BE8_GlobalUtility.getSObjectListMap('Passengerid__c', [SELECT Id, Passengerid__c FROM Case_Group_Member__c WHERE Passengerid__c IN :paxIsSet]);
		Map<String, Account> acclist = new Map<String, Account>();
		Map<String, Travel_Document__c> travellist = new Map<String, Travel_Document__c>();
		List<Passenger__c> newPaxList = new List<Passenger__c>();
		for(Passenger__c pax : paxlist){
			if(pax.IgnoreProcessBuilder__c){
				continue;
			}
			String paxExternalId = pax.FlightId__r.Flight_Number__c + '_' + pax.Flight_Date__c + '_' + pax.First_Name__c + '_' + pax.Last_Name__c + '_' + pax.PNR__c + '_' + pax.FlightId__r.Leg_Number__c;
			String paxDOB = BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(pax.Date_of_Birth_Input__c).split(' ')[0]);
			Account acc = new Account(
				Name = pax.Last_Name__c + ' ' + pax.First_Name__c,
				First_Name__c = pax.First_Name__c,
				Last_Name__c = pax.Last_Name__c,
				Mailling_Address__c = pax.Email_1__c,
				Date_of_Birth__c = Date.valueOf(pax.Date_of_Birth_Input__c),
				Travel_Document__c = pax.Travel_Document_Number__c,
				Travel_Document_Expiry_Date__c = null,
				Customer_External_Id__c = pax.First_Name__c + '_' + pax.Last_Name__c + '_' + paxDOB + '_' + pax.Travel_Document_Number__c
				);
			Travel_Document__c travel = new Travel_Document__c(
				ExtDocument__c = pax.Travel_Document_Number__c,
				Travel_Document_Number__c = pax.Travel_Document_Number__c
				);
			System.debug('Account: ' + acc);
			acclist.put(paxExternalId, acc);
			travellist.put(paxExternalId, travel);
			newPaxList.add(new Passenger__c(Id = pax.Id, WS_KEY__c = paxExternalId));
			//newPaxList.add(new Passenger__c(Id = pax.Id));
		}
		upsert acclist.values() Customer_External_Id__c;
		List<Case> caseUpdateList = new List<Case>();
		List<Case_Group_Member__c> caseGroupUpdateList = new List<Case_Group_Member__c>();
		for(Passenger__c pax : newPaxList){
			//String ws_key = pax.FlightId__r.Flight_Number__c + '_' + pax.Flight_Date__c + '_' + pax.First_Name__c + '_' + pax.Last_Name__c + '_' + pax.PNR__c + '_' + pax.FlightId__r.Leg_Number__c;
			pax.AccountId__c = acclist.get(pax.WS_KEY__c).Id;
			travellist.get(pax.WS_KEY__c).AccountId__c = acclist.get(pax.WS_KEY__c).Id;
			pax.WS_KEY__c = null;
			System.debug('Account ID: ' + pax.AccountId__c);
			System.debug('PAX: ' + pax);
			List<Case> caseList = (List<Case>)caseListMap.get(pax.Id);
			if(caseList != null){
				for(Case cases : caseList){
					caseUpdateList.add(new Case(Id = cases.Id, AccountId = pax.AccountId__c));
				}	
			}
			List<Case_Group_Member__c> caseGroupList = (List<Case_Group_Member__c>)caseGroupListMap.get(pax.Id);
			if(caseGroupList != null){
				for(Case_Group_Member__c caseGroup : caseGroupList){
					caseGroupUpdateList.add(new Case_Group_Member__c(Id = caseGroup.Id, AccountId__c = pax.AccountId__c));
				}
			}
		}
		upsert travellist.values() ExtDocument__c;
		update newPaxList;
		update caseUpdateList;
		update caseGroupUpdateList;
	}
}