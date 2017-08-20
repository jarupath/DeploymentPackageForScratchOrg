global with sharing class FlightScheduleService {

    static String aircraftQueriedFields = 'Id, Name, Number_Of_NoActions__c, Number_Of_Blocks__c, Number_Of_Completes__c, Number_Of_Malfunctions__c, Number_Of_Serviceables__c, Aircraft_Main_Type__c';
    static String flightQueriedFields = 'Id, Booking_Passengers__c, LastModifiedDate, Name, Aircraft_Configuration__c, Leg_Number__c, Flight_Number__c, Departed__c, Departure_STN__c, Arrival_STN__c, STD__c, STA__c, STD_UTC__c, STD_LT__c, ETD_LT__c, STA_LT__c, ETA_LT__c, STD_UTC_DateTime__c, STA_UTC_DateTime__c, STD_LT_DateTime__c, STA_LT_DateTime__c, AircraftId__r.Name, AircraftId__r.Aircraft_Main_Type__c, BAY_ARR_DEP__c, ETA_LT_DateTime__c , ETA_UTC_DateTime__c, ETD_LT_DateTime__c, ETD_UTC_DateTime__c ';

    global class FlightScheduleRecord implements Comparable {
        public Aircraft__c aircraft;
        public Flight__c arrivalFlight;
        public Boolean isFocusArrivalFlight;
        public Flight__c departureFlight;
        public Boolean isFocusDepartureFlight;
        public String acReg;
        public String acType;
        public String arrFlightFrom;
        public String depFlightTo;
        public String sta;
        public String eta;
        public String std;
        public String etd;
        public DateTime timeToBeSorted;
        public String timeToBeSortedString;
        private DateTime currentTime;
        public Boolean isAircraftLanded;
        public Boolean isAircraftDeparted;
        public Boolean isArrivingFlightDeparted;
        public Boolean isArrivingFlightLanded;
        public Boolean isDepartureFlightDeparted;
        public Boolean isDepartureFlightLanded;
        public String status;
        public String bayArr;
        public String bayDep;
        public String bayArrDep;
        public Decimal serviceableCount;
        public Decimal blockCount;
        public Decimal malfunctionCount;
        public Decimal completedCount;
        public Decimal noActionCount;

        public FlightScheduleRecord(Aircraft__c aircraft, DateTime currentTime) {
            this.aircraft = aircraft;
            acReg = aircraft.Name;
            acType = aircraft.Aircraft_Main_Type__c;
            this.currentTime = currentTime;
            serviceableCount = aircraft.Number_Of_Serviceables__c;
            blockCount = aircraft.Number_Of_Blocks__c;
            malfunctionCount = aircraft.Number_Of_Malfunctions__c;
            completedCount = aircraft.Number_Of_Completes__c;
            noActionCount = aircraft.Number_Of_NoActions__c;
        }

        public void setArrivalFlight(Flight__c f) {
            arrivalFlight = f;
            arrFlightFrom = formatFlightName(f.Flight_Number__c, f.Departure_STN__c);
            sta = formatDateTime(f.STA_LT_DateTime__c, true);
            eta = formatDateTime(f.ETA_LT_DateTime__c, false);

            DateTime departureTime = f.ETD_UTC_DateTime__c != null ? f.ETD_UTC_DateTime__c : f.STD_UTC_DateTime__c;
            DateTime arrivalTime = f.ETA_UTC_DateTime__c != null ? f.ETA_UTC_DateTime__c : f.STA_UTC_DateTime__c;

            isArrivingFlightDeparted = departureTime <= currentTime;
            isArrivingFlightLanded = arrivalTime <= currentTime;
            acType = f.AircraftId__r.Aircraft_Main_Type__c;

            isAircraftLanded = arrivalTime <= currentTime;
            if (timeToBeSorted == null || !isAircraftLanded) {
                timeToBeSorted = arrivalTime;
                timeToBeSortedString = String.valueOf(timeToBeSorted);
            }

            if(currentTime >= arrivalTime.addHours(-2) && !isAircraftLanded){
                isFocusArrivalFlight = true;
            } else {
                isFocusArrivalFlight = false;
            }

            bayArr = f.BAY_ARR_DEP__c;
            setBayArrDep();
        }

        public void setDepartureFlight(Flight__c f) {
            departureFlight = f;
            depFlightTo = formatFlightName(f.Flight_Number__c, f.Arrival_STN__c);
            std = formatDateTime(f.STD_LT_DateTime__c, true);
            etd = formatDateTime(f.ETD_LT_DateTime__c, false);

            DateTime departureTime = f.ETD_UTC_DateTime__c != null ? f.ETD_UTC_DateTime__c : f.STD_UTC_DateTime__c;
            DateTime arrivalTime = f.ETA_UTC_DateTime__c != null ? f.ETA_UTC_DateTime__c : f.STA_UTC_DateTime__c;

            isDepartureFlightDeparted = departureTime <= currentTime;
            isDepartureFlightLanded = arrivalTime <= currentTime;
            acType = f.AircraftId__r.Aircraft_Main_Type__c;

            isAircraftDeparted = departureTime <= currentTime;
            if (timeToBeSorted == null || (!isAircraftDeparted && isAircraftLanded) || (isDepartureFlightDeparted)) {
                timeToBeSorted = departureTime;
                timeToBeSortedString = String.valueOf(timeToBeSorted);
            }

            //System.debug(depFlightTo + ' currentTime <= f.STD_UTC_DateTime__c.addHours(2): ' + String.valueOf(currentTime <= f.STD_UTC_DateTime__c.addHours(2)) + ' !isDepartureFlightDeparted: ' + String.valueOf(!isDepartureFlightDeparted) + ' (arrivalFlight == null || isArrivingFlightLanded): ' + String.valueOf((arrivalFlight == null || isArrivingFlightLanded)));
            if (currentTime >= departureTime.addHours(-2) && !isDepartureFlightDeparted && (arrivalFlight == null || isArrivingFlightLanded)) {
                isFocusDepartureFlight = true;
            }

            bayDep = f.BAY_ARR_DEP__c;
            setBayArrDep();
        }

        private void setBayArrDep() {
            if (bayArr != null && bayDep != null) {
                bayArrDep = bayArr + '/' + bayDep;
            }
        }

        global Integer compareTo(Object anotherObject) {
            FlightScheduleRecord another = (FlightScheduleRecord) anotherObject;
            if (this.timeToBeSorted > another.timeToBeSorted) {
                return 1;
            } else if (this.timeToBeSorted < another.timeToBeSorted) {
                return -1;
            } else {
                return 0;
            }
        }
    }

    public static List<FlightScheduleRecord> getSchedule(Integer startTimeOffset, Integer endTimeOffset, DateTime currentTime, String currentStation) {
        if (currentTime == null) {
            throw new CustomException('Current time cannot be null.');
            return null;
        }

        DateTime startTime = currentTime.addHours(- startTimeOffset);
        DateTime endTime = currentTime.addHours(endTimeOffset);


        List<Aircraft__c> aircraftList = Database.query('SELECT ' + aircraftQueriedFields + ' ,(SELECT ' + flightQueriedFields + ' FROM Flights__r WHERE ((Departure_STN__c = :currentStation AND STD_UTC_DateTime__c >= :startTime AND STD_UTC_DateTime__c <= :endTime) OR (Arrival_STN__c = :currentStation AND STA_UTC_DateTime__c >= :startTime AND STA_UTC_DateTime__c <= :endTime)) ORDER BY STD_UTC_DateTime__c ASC) FROM Aircraft__c ORDER BY Name');
        System.debug(JSON.serialize(aircraftList));
        //List<Flight__c> departureFlightList = Database.query('SELECT ' + flightQueriedFields + ' FROM Flight__c WHERE Departure_STN__c = :currentStation AND STD_UTC_DateTime__c >= :startTime AND STD_UTC_DateTime__c <= :endTime ORDER BY STD_UTC_DateTime__c ASC');
        //List<Flight__c> arrivalFlightList = Database.query('SELECT ' + flightQueriedFields + ' FROM Flight__c WHERE Arrival_STN__c = :currentStation AND STA_UTC_DateTime__c >= :startTime AND STA_UTC_DateTime__c <= :endTime ORDER BY STA_UTC_DateTime__c ASC');

        //Map<Id, FlightScheduleRecord> aircraftScheduleReportMap = new Map<Id, FlightScheduleRecord>();
        List<FlightScheduleRecord> aircraftScheduleReportList = new List<FlightScheduleRecord>();
        Set<Id> aircraftWithoutDepartureFlightIdSet = new Set<Id>();
        Set<Id> aircraftWithoutArrivalFlightIdSet = new Set<Id>();

        for (Aircraft__c aircraft : aircraftList) {
            if (aircraft.Flights__r != null) {
                //System.debug(aircraft.Name);
                //System.debug(aircraft.Flights__r);
                for (Integer i = 0, numberOfFlight = aircraft.Flights__r.size(); i < numberOfFlight; i++) {
                    Flight__c flight = aircraft.Flights__r[i];
                    FlightScheduleRecord reportItem = new FlightScheduleRecord(aircraft, currentTime);
                    Boolean isFoundFlightThatMatchesCriteria = false;
                    Boolean isDepartingFromCurrentStation = flight.Departure_STN__c == currentStation;
                    Boolean isArrivingToCurrentStation = flight.Arrival_STN__c == currentStation;
                    Boolean isFlightLanded = flight.STA_UTC_DateTime__c <= currentTime;
                    Boolean hasAtLeastOneFlight = false;

                    if (isDepartingFromCurrentStation && !isFlightLanded) {
                        reportItem.setDepartureFlight(flight);
                        aircraftWithoutArrivalFlightIdSet.add(aircraft.Id);
                        hasAtLeastOneFlight = true;
                    } else if (isArrivingToCurrentStation) {
                        reportItem.setArrivalFlight(flight);
                        if ((i + 1) < numberOfFlight) {
                            Flight__c nextFlight = aircraft.Flights__r[i + 1];
                            if (flight.Arrival_STN__c == nextFlight.Departure_STN__c) {
                                reportItem.setDepartureFlight(nextFlight);
                                i++; // Move to the next one
                            } else {
                                aircraftWithoutDepartureFlightIdSet.add(aircraft.Id);
                            }
                        } else {
                            aircraftWithoutDepartureFlightIdSet.add(aircraft.Id);
                        }
                        hasAtLeastOneFlight = true;
                    }

                    if (hasAtLeastOneFlight) {
                        //aircraftScheduleReportMap.put(aircraft.Id, reportItem);
                        aircraftScheduleReportList.add(reportItem);
                    }
                }
                //for (Flight__c flight : aircraft.Flights__r) {
                //    FlightScheduleRecord reportItem = new FlightScheduleRecord(aircraft, currentTime);
                //    Boolean isFoundFlightThatMatchesCriteria = false;
                //    Boolean isDepartingFromCurrentStation = flight.Departure_STN__c == currentStation;
                //    Boolean isArrivingToCurrentStation = flight.Arrival_STN__c == currentStation;
                //    Boolean isFlightLanded = flight.STA_UTC_DateTime__c <= currentTime;

                //    if (isDepartingFromCurrentStation && !isFlightLanded) {
                //        reportItem.setDepartureFlight(flight);
                //        aircraftWithoutArrivalFlightIdSet.add(aircraft.Id);
                //        isFoundFlightThatMatchesCriteria = true;
                //    } else if (isArrivingToCurrentStation) {
                //        reportItem.setArrivalFlight(flight);
                //        aircraftWithoutDepartureFlightIdSet.add(aircraft.Id);
                //        isFoundFlightThatMatchesCriteria = true;
                //    }

                //    if (isFoundFlightThatMatchesCriteria) {
                //        aircraftScheduleReportMap.put(aircraft.Id, reportItem);
                //        break;
                //    }
                //}
            }
        }

        System.debug('aircraftWithoutDepartureFlightIdSet: ' + aircraftWithoutDepartureFlightIdSet.size());
        System.debug('aircraftWithoutArrivalFlightIdSet: ' + aircraftWithoutArrivalFlightIdSet.size());

        List<Aircraft__c> aircraftWithDepartureFlightList = Database.query('SELECT ' + aircraftQueriedFields + ' ,(SELECT ' + flightQueriedFields + ' FROM Flights__r WHERE (Departure_STN__c =: currentStation OR Arrival_STN__c =: currentStation) AND (STA_UTC_DateTime__c >= :startTime)  ORDER BY STD_UTC_DateTime__c ASC LIMIT 10) FROM Aircraft__c WHERE Id IN :aircraftWithoutDepartureFlightIdSet');
        List<Aircraft__c> aircraftWithArrivalFlightList = Database.query('SELECT ' + aircraftQueriedFields + ' ,(SELECT ' + flightQueriedFields + ' FROM Flights__r WHERE (Departure_STN__c =: currentStation OR Arrival_STN__c =: currentStation) AND (STD_UTC_DateTime__c <= :endTime)  ORDER BY STD_UTC_DateTime__c DESC LIMIT 10) FROM Aircraft__c WHERE Id IN :aircraftWithoutArrivalFlightIdSet');
        Map<String, SObject> aircraftWithDepartureFlightMap = BE8_GlobalUtility.getSObjectMap('Id', aircraftWithDepartureFlightList);
        Map<String, SObject> aircraftWithArrivalFlightMap = BE8_GlobalUtility.getSObjectMap('Id', aircraftWithArrivalFlightList);
        for (FlightScheduleRecord eachRecord : aircraftScheduleReportList) {
            //System.debug('eachRecord: ' + eachRecord);
            if(aircraftWithDepartureFlightMap.containsKey(eachRecord.aircraft.Id)){
                Aircraft__c aircraft = (Aircraft__c) aircraftWithDepartureFlightMap.get(eachRecord.aircraft.Id);
                Boolean thereIsFlight = aircraft != null && aircraft.Flights__r != null && aircraft.Flights__r.size() > 0;
                Boolean recordDoestNotHaveDepartureFlight = eachRecord.departureFlight == null;
                if(recordDoestNotHaveDepartureFlight){
                    //System.debug(eachRecord.arrivalFlight);
                    //System.debug(JSON.serialize(aircraft.Flights__r));
                    for (Integer i = 0, numberOfFlightUnderAircraft = aircraft.Flights__r.size(); i < numberOfFlightUnderAircraft; i++) {
                        Flight__c eachFlightUnderAircraft = aircraft.Flights__r[i];
                        if (eachRecord.arrivalFlight.Name == eachFlightUnderAircraft.Name) {
                            if ((i + 1) < numberOfFlightUnderAircraft) {
                                Flight__c nextFlight = aircraft.Flights__r[i + 1];
                                Boolean isConnectedByArrivalAndDepartureStation = eachRecord.arrivalFlight.Arrival_STN__c == nextFlight.Departure_STN__c;
                                if(isConnectedByArrivalAndDepartureStation){
                                    eachRecord.setDepartureFlight(nextFlight);
                                }
                            }
                        }
                    }
                }
            }
        }
        for (FlightScheduleRecord eachRecord : aircraftScheduleReportList) {
            //System.debug('eachRecord: ' + eachRecord);
            if(aircraftWithArrivalFlightMap.containsKey(eachRecord.aircraft.Id)){
                Aircraft__c aircraft = (Aircraft__c) aircraftWithArrivalFlightMap.get(eachRecord.aircraft.Id);
                Boolean thereIsFlight = aircraft != null && aircraft.Flights__r != null && aircraft.Flights__r.size() > 0;
                Boolean recordDoestNotHaveArrivalFlight = eachRecord.arrivalFlight == null;
                if(recordDoestNotHaveArrivalFlight){
                    //System.debug('recordDoestNotHaveArrivalFlight: ' + eachRecord.aircraft.Name + ' ' + eachRecord.depFlightTo);
                    //System.debug(JSON.serialize(aircraft.Flights__r));
                    for (Integer i = 0, numberOfFlightUnderAircraft = aircraft.Flights__r.size(); i < numberOfFlightUnderAircraft; i++) {
                        Flight__c eachFlightUnderAircraft = aircraft.Flights__r[i];
                        if (eachRecord.departureFlight.Name == eachFlightUnderAircraft.Name) {
                            if ((i + 1) < numberOfFlightUnderAircraft) {
                                Flight__c nextFlight = aircraft.Flights__r[i + 1];
                                Boolean isConnectedByArrivalAndDepartureStation = eachRecord.departureFlight.Departure_STN__c == nextFlight.Arrival_STN__c;
                                if(isConnectedByArrivalAndDepartureStation){
                                    eachRecord.setArrivalFlight(nextFlight);
                                }
                            }
                        }
                    }
                }
            }
        }
        //for (Aircraft__c eachAircraft : aircraftWithoutDepartureFlightList) {
        //    Boolean thereIsFlight = eachAircraft.Flights__r != null && eachAircraft.Flights__r.size() > 0;
        //    if (aircraftScheduleReportMap.containsKey(eachAircraft.Id) && thereIsFlight) {
        //        FlightScheduleRecord reportItem = aircraftScheduleReportMap.get(eachAircraft.Id);
        //        Flight__c arrivalFlight = reportItem.arrivalFlight;
        //        for (Flight__c departureFlight : eachAircraft.Flights__r) {
        //            if (arrivalFlight.STA_UTC_DateTime__c != null && departureFlight.STD_UTC_DateTime__c != null) {
        //                Boolean departureFlightIsAfterArrivalFlight = arrivalFlight.STA_UTC_DateTime__c < departureFlight.STD_UTC_DateTime__c;
        //                if (departureFlightIsAfterArrivalFlight) {
        //                    reportItem.setDepartureFlight(departureFlight);
        //                    break;
        //                }
        //            }
        //        }
        //    }
        //}

        //List<Aircraft__c> aircraftWithoutArrivalFlightList = Database.query('SELECT ' + aircraftQueriedFields + ' ,(SELECT ' + flightQueriedFields + ' FROM Flights__r WHERE Arrival_STN__c =: currentStation AND STA_UTC_DateTime__c <= :currentTime  ORDER BY STA_UTC_DateTime__c DESC LIMIT 1) FROM Aircraft__c WHERE Id IN :aircraftWithoutArrivalFlightIdSet');
        //for (Aircraft__c eachAircraft : aircraftWithoutArrivalFlightList) {
        //    Boolean thereIsFlight = eachAircraft.Flights__r != null && eachAircraft.Flights__r.size() > 0;
        //    if (aircraftScheduleReportMap.containsKey(eachAircraft.Id) && thereIsFlight) {
        //        FlightScheduleRecord reportItem = aircraftScheduleReportMap.get(eachAircraft.Id);
        //        reportItem.setArrivalFlight(eachAircraft.Flights__r.get(0));
        //    }
        //}

        List<FlightScheduleRecord> resultList = aircraftScheduleReportList;
        resultList.sort();
        return resultList;
    }

    private static String formatDateTime(DateTime dt, Boolean includeDate) {
        if (dt != null) {
            String output = forceTwoDigits(dt.hourGmt()) + ':' + forceTwoDigits(dt.minuteGmt());
            if (includeDate) {
                output += ' ' + forceTwoDigits(dt.dayGmt()) + '/' + forceTwoDigits(dt.monthGmt());
            }
            return output;
        } else {
            return null;
        }
    }

    private static String forceTwoDigits(Integer input) {
        String output = '000000' + input;
        return output.right(2);
    }

    private static String formatFlightName(String flightNumber, String station) {
        if (flightNumber != null && station != null) {
            String flightNumberWithoutTG = flightNumber.replace('TG', '');
            Integer flightNumberOnly = Integer.valueOf(flightNumberWithoutTG);
            return 'TG' + flightNumberOnly + ' ' + station;
        }
        return '';
    }
}