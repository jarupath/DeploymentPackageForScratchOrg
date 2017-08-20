/*
    JK
*/
trigger FlightTrigger on Flight__c (before insert, before update, after update, after insert) {
    if (TriggerActivator.isTriggerActivated(TriggerActivator.FLIGHT_TRIGGER)) {
        Boolean isSystemIntegrationProfile = FlightService.isSystemIntegrationProfile();
        List<Flight__c> flightList = Trigger.new;
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            List<Flight__c> flightListToBeUpdated = new List<Flight__c>();
            for (Flight__c eachFlight : Trigger.new) {
                if (eachFlight.Manual_Run__c) {
                    //PreFlight_Sync preflightSync = new PreFlight_Sync(eachFlight.Flight_Master__c, eachFlight.Flight_Number__c, Date.valueOf(eachFlight.Flight_Date_UTC__c), 'UTC', BE8_GlobalConstants.MANUAL_JOB);
                    //preflightSync.sync();
                    PreFlight_Sync.AsyncPreFlight(eachFlight.Flight_Master__c, eachFlight.Flight_Number__c, Date.valueOf(eachFlight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(eachFlight.Leg_Number__c), FlightService.getSyncFlightJobName(eachFlight, BE8_GlobalConstants.MANUAL_JOB));

                    //Database.executeBatch(new PreFlightBatch(eachFlight.Flight_Master__c, eachFlight.Flight_Number__c, Date.valueOf(eachFlight.Flight_Date_UTC__c), 'UTC'), 1);
                    //flightListToBeUpdated.add(new Flight__c(Id = eachFlight.Id, Manual_Run__c = false));
                    flightListToBeUpdated.add(new Flight__c(Id = eachFlight.Id, Manual_Run__c = false, Flight_Date_LT__c = BE8_DateUtility.convertDateFormatToTraditionalFormat(eachFlight.Flight_Date_LT__c), Integration_Source__c = '3'));
                    System.debug('Update in Manual Run: ' + flightListToBeUpdated.get(flightListToBeUpdated.size() - 1));
                }
            }
            update flightListToBeUpdated;
        }

        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            //List<Flight__c> flightList = Trigger.new;
            BE8_GlobalUtility.updateOverBookValueToCase(flightList);
            Map<String, String> aircraftMapList = new Map<String, String>();
            Map<String, Aircraft__c> insertAircraftMap = new Map<String, Aircraft__c>();
            //List<Aircraft__c> airList = new List<Aircraft__c>();
            Map<String, Aircraft__c> airList = new Map<String, Aircraft__c>();
            String source = '2';
            for (Flight__c flight : flightList) {
                aircraftMapList.put(flight.A_C_Reg__c, flight.A_C_Reg__c);
            }
            System.debug('input map:---' + aircraftMapList);
            Map<String, Aircraft__c> aircraftMap = FlightService.getExistingAircraft(aircraftMapList.values());
            System.debug('Existing in SFDC:----' + aircraftMap);


            for (Flight__c flight : flightList) {
                if (isSystemIntegrationProfile || flight.Manual_Run__c) {
                    System.debug('Check Integration Source: ' + flight.Integration_Source__c);
                    System.debug('Manual Run Value: ' + flight.Manual_Run__c);
                    System.debug('Input flight name: ' + flight.Name);
                    System.debug('Input Flight: ' + flight);
                    
                    System.debug('Flight Name: ' + flight.Name);
                    System.debug('Flight Number' + flight.Flight_Number__c);
                    flight.Flight_Date_UTC__c = BE8_DateUtility.convertTGFlightDateformat(flight.Flight_Date_UTC__c);
                    flight.Flight_Date_LT__c = BE8_DateUtility.convertTGFlightDateformat(flight.Flight_Date_LT__c);
                    flight.STD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.STD_UTC__c);
                    flight.STD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.STD_LT__c);
                    flight.STA_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.STA_UTC__c);
                    flight.STA_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.STA_LT__c);
                    flight.ETD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ETD_UTC__c);
                    flight.ETD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ETD_LT__c);
                    flight.ETA_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ETA_UTC__c);
                    flight.ETA_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ETA_LT__c);
                    flight.ATD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ATD_UTC__c);
                    flight.ATD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ATD_LT__c);
                    flight.ATA_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ATA_UTC__c);
                    flight.ATA_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.ATA_LT__c);
                    //flight.Block_Time__c = BE8_DateUtility.convertTGFlightTimeformat(flight.Flying_Time_Elapsed_Time__c);
                    flight.Block_Time__c = BE8_GlobalUtility.convertDurationToMiniteUnit(flight.Flying_Time_Elapsed_Time__c, null);
                    flight.Next_Flight_STD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.Next_Flight_STD_UTC__c);
                    flight.Next_Flight_STD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(flight.Next_Flight_STD_LT__c);
                    flight.Change_Flight_Date_UTC__c = BE8_DateUtility.convertTGFlightDateformat(flight.Change_Flight_Date_UTC__c);
                    flight.Change_Flight_Date_LT__c = BE8_DateUtility.convertTGFlightDateformat(flight.Change_Flight_Date_LT__c);

                    if (flight.Name != null && !flight.Name.contains('TG')) {
                       FlightService.generateFlightName(flight);
                    } else {
                        flight.Integration_Source__c = null;
                        System.debug('SET INTEGRATION SOURCE TO NULL');
                    }

                    // Assign Flight Master
                    if (flight.Flight_External_ID__c != null && flight.Flight_External_ID__c.length() > 0) {
                        String[] splittedFlightExternalId = flight.Flight_External_ID__c.split('_');
                        if (splittedFlightExternalId.size() == 3) {
                            flight.Flight_Master__c = splittedFlightExternalId[0] + '_' + splittedFlightExternalId[1];
                        }
                    }


                    if (flight.Integration_Source__c == '1') {
                        source = '1';
                        if (flight.A_C_Reg__c != null) {
                            Aircraft__c aircraft = null;
                            System.debug('input reg:-------------------------' + flight.A_C_Reg__c);
                            if (aircraftMap.get(flight.A_C_Reg__c) != null) {
                                aircraft = aircraftMap.get(flight.A_C_Reg__c);
                                insertAircraftMap.put(aircraft.Name, aircraft);
                                System.debug('inserted aircraft 1:-----' + aircraft.Name + '-' + aircraft.Id);
                            } else {
                                aircraft = new Aircraft__c(Name = flight.A_C_Reg__c, Aircraft_Type__c = flight.Aircraft_Type__c, Aircraft_Registration__c = flight.A_C_Reg__c);
                                insertAircraftMap.put(aircraft.Name, aircraft);
                                if (airList.get(aircraft.Name) == null) {
                                    airList.put(aircraft.Name, aircraft);
                                }
                                System.debug('inserted aircraft 2:-----' + aircraft.Name);
                            }
                        }
                    }
                }
            }
            //BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'FlightTrigger', 'FlightTrigger', '', 'Flight__c', source, 'source value', null, System.currentTimeMillis());
            if (source == '1') {
                System.debug('insert list size:----' + insertAircraftMap.size());
                //Database.UpsertResult[] t = Database.upsert(insertAircraftMap.values(), true);
                //insert airList;
                Database.SaveResult[] t = Database.insert(airList.values(), true);
                System.debug('Save Result:----' + t);
                for (Flight__c a : flightList) {
                    if (a.A_C_Reg__c != null && insertAircraftMap != null && !insertAircraftMap.isEmpty()) {
                        System.debug('Look up Aircraft: ' + a.A_C_Reg__c);
                        System.debug('Look up Id: ' + insertAircraftMap.get(a.A_C_Reg__c).Id);
                        a.AircraftId__c = insertAircraftMap.get(a.A_C_Reg__c).Id;
                    }
                    //if(a.Leg_Number__c > 1){
                    //    String firstLegFlightExternalId = a.Flight_External_ID__c.substring(0, a.Flight_External_ID__c.length()-1) + '1';
                    //    //flight.First_Leg__c = ((Flight__c)flightMapWithExternalId.get(firstLegFlightExternalId)).Id;
                    //    a.First_Leg__r = new Flight__c(Flight_External_ID__c = firstLegFlightExternalId);
                    //    System.debug('First Leg External ID: ' + firstLegFlightExternalId);
                    //    System.debug('flight First Leg: ' + a.First_Leg__r);
                    //}
                }
            }

            FlightService.calculateFlightRegion(flightList);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            List<Flight__c> updateFlightList = new List<Flight__c>();
            for (Flight__c flight : flightList) {
                if (flight.Leg_Number__c != 1 && flight.Leg_Number__c != null) {
                    String firstLegFlightExternalId = flight.Flight_External_ID__c != null ? flight.Flight_External_ID__c.substring(0, flight.Flight_External_ID__c.length() - 1) + '1' : null;
                    Flight__c updateFlight = new Flight__c();
                    updateFlight.Id = flight.Id;
                    updateFlight.First_Leg__r = new Flight__c(Flight_External_ID__c = firstLegFlightExternalId);
                    updateFlightList.add(updateFlight);
                    System.debug('After Trigger: ' + flight.First_Leg__c);
                }
            }
            Database.SaveResult[] result = Database.update(updateFlightList, false);
            //update updateFlightList;

            for (Database.SaveResult re : result) {
                if (re.getErrors() != null) {
                    System.debug('ERROR: ' + re);
                }
            }
        }

        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            //String abortFlight = '';
            //Map<String, SObject> flightMapWithExternalId = BE8_GlobalUtility.getMapFromList('Flight_External_ID__c', flightList);
            //Set<String> flightSet = new Set<String>();
            //for(Flight__c flight : flightList){
            //    //in case that there are flight delay and the flight is changed, call web service call out to query new flight
            //    if (flight.Change_Flight_Number__c != null) {
            //        String fNumber = null;
            //        System.debug('Input Change Flight Number: ' + flight.Change_Flight_Number__c);
            //        if(!flight.Change_Flight_Number__c.contains('TG')){
            //            fNumber = flight.Change_Flight_Number__c;
            //        }
            //        else{
            //            fNumber = flight.Change_Flight_Number__c.substring(2, flight.Change_Flight_Number__c.length());
            //            System.debug('Modified Change Flight Number: ' + fNumber);
            //        }
            //        System.debug('Change Flight Number: ' + fNumber);
            //        CSE_SOAPFLIGHT_WS flightCallout = new CSE_SOAPFLIGHT_WS();
            //        Database.executeBatch(new PreFlightBatch(fNumber, Date.valueOf(flight.Change_Flight_Date_UTC__c), 'UTC'), 1);
            //        flightSet.add(flight.Id);
            //    }
            //}
            ////delete job queue
            //delete [SELECT Id FROM Job_Queue__c WHERE Reference_Id__c IN :flightSet AND Scheduled__c = false];
            // Schedule Flight Batch
            System.debug('After insert information: ' + Trigger.new);
            Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Id', Trigger.new);
            if (!Test.isRunningTest()) {
                FlightService.schedulePreFlightBatch(flightIdSet);
            }
            JobQueueService.enqueueJob();
        }
    }
}