trigger CrewListTrigger on Crew_List__c (before insert, after insert) {
	if (TriggerActivator.isTriggerActivated(TriggerActivator.CREW_LIST_TRIGGER)) {
		if (Trigger.isBefore && Trigger.isInsert) {
			if (FlightService.isSystemIntegrationProfile()) {
				List<Crew_List__c> inputCrewList = Trigger.new;
				System.debug('Input Crew List:---' + inputCrewList.size());
				System.debug('Crew List: ' + inputCrewList);
				/* remove all the existing crew on flight in the related flight */
				Set<String> inputFlightId = new Set<String>();
				Map<String, String> inputFlight = new Map<String, String>();
				Map<String, Crew__c> crewMap = new Map<String, Crew__c>();
				Map<String, Flight__c> flightMap = new Map<String, Flight__c>();
				for (Crew_List__c crewlist : inputCrewList) {
					inputFlightId.add(crewlist.Flight_Temp__c);
					String crewId = crewlist.Crew_Temp__c;
					String[] flightInfo = crewlist.Flight_Temp__c != null ? crewlist.Flight_Temp__c.split('_') : crewlist.FlightId__r.Flight_External_ID__c.split('_');
					if (crewMap.get(crewId) == null) {
						Crew__c crew = CrewOnFlightService.createCrew(crewlist);
						if (crewlist.Language__c != null) {
							crew.Language__c = crewlist.Language__c;
						}
						crewMap.put(crewId, crew);
					}
					if (flightMap.get(crewlist.Flight_Temp__c) == null) {
						flightMap.put(crewlist.Flight_Temp__c, CrewOnFlightService.createFlight(flightInfo, crewlist.Flight_Temp__c));
					}
				}
				//List<Crew_List__c> getcrewlist = [SELECT Id FROM Crew_List__c WHERE FlightId__r.Flight_External_ID__c in :inputFlightId AND DAY_ONLY(Last_Modifed_by_Webservice__c) != TODAY];
				List<Crew_List__c> getcrewlist = [SELECT Id FROM Crew_List__c WHERE FlightId__r.Flight_External_ID__c in :inputFlightId AND Id NOT IN :BE8_GlobalConstants.CREW_LIST_ID];
				System.debug('Amount of Flight(inputFlightId):---' + inputFlightId.size());
				System.debug('Amount of Flight(inputFlight):---' + inputFlight.size());
				System.debug('Delete Crewlist:---' + getcrewlist.size());
				delete getcrewlist;

				for (Flight__c fli : flightMap.values()) {
					System.debug('Flight duration: ' + fli.Block_Time__c);
				}
				System.debug('Crew Map Size:---' + crewMap.size());
				System.debug('Flight Map Size:---' + flightMap.size());
				for (Crew__c crew : crewMap.values()) {
					System.debug('Upsert Crew: ' + crew);
				}
				upsert crewMap.values() Personel_Id__c;
				upsert flightMap.values() Flight_External_ID__c;
				System.debug('flightMap: ' + flightMap);
				for (Crew_List__c crewlist : inputCrewList) {
					String[] flightInfo = crewlist.Flight_Temp__c.split('_');
					crewlist.CrewId__c = crewMap.get(crewlist.Crew_Temp__c).Id;
					crewlist.FlightId__c = flightMap.get(crewlist.Flight_Temp__c).Id;
					crewlist.Crew_External_ID__c = crewlist.CrewList_Temp__c;
					//Crewlist.Last_Modifed_by_Webservice__c = Datetime.now();
				}
				System.debug('inputCrewList: ' + inputCrewList);
			}
		}

		if (Trigger.isAfter && Trigger.isInsert) {
			List<Crew_List__c> inputCrewList = Trigger.new;
			for (Crew_List__c crewlist : inputCrewList) {
				BE8_GlobalConstants.CREW_LIST_ID.add(crewlist.Id);
				System.debug('size of crewlist set' + BE8_GlobalConstants.CREW_LIST_ID.size());
				System.debug('crewlist set' + BE8_GlobalConstants.CREW_LIST_ID);
			}
		}
	}
}