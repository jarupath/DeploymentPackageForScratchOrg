@isTest
private class MileageUpgradeSeatCalculatorTest {

        private static testMethod void testPassengerBKKtoARNClassY() {
                String origin = 'BKK';
                String destination = 'ARN';
                String travelClass = 'Y';
                String ropNumber = 'AB123459';
                Set<String> originSet = new Set<String> {origin};
                Set<String> destinationSet = new Set<String> {destination};

                MileageUpgradeSeatCalculator calculator = new MileageUpgradeSeatCalculator(originSet, destinationSet);

                Flight__c flight = MockupData_Test.getMockUpFlight();
                flight.Origin__c = origin;
                flight.Destination__c = destination;
                flight.Departure_STN__c = origin;
                flight.Arrival_STN__c = destination;
                insert flight;

                Account acc = MockupData_Test.createAccount('TEST');
                insert acc;
                Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, travelClass);
                passenger.AccountId__c = acc.Id;
                insert passenger;
                passenger = [SELECT Id, FlightId__r.Routing__c, Pax_Key_txt__c, Eligible_for_Upgrade_Seat__c, Eligible_for_Upgrade_Seat_Priority__c, Last_Name__c, Board_Point__c, Off_Point__c,  Date_of_Birth_Input__c, Name, Cabin_Code__c, Flight_Origin__c, Flight_Destination__c, FFP__c, FFP_Number__c, FFP_Carrier__c, FlightId__r.Origin__c, FlightId__r.Destination__c, AccountId__r.Last_Name__c, AccountId__r.Date_of_Birth__c, FlightId__r.Departure_STN__c, FlightId__r.Arrival_STN__c FROM Passenger__c WHERE Id = : passenger.Id LIMIT 1];
                System.debug(passenger);
                Membership__c membership = MockupData_Test.createMembership();
                membership.Name = ropNumber;
                membership.EXTMember__c = CSE_SOAPUpdatePax_WS.getMemberExtId(BE8_GlobalConstants.DEFAULT_TG_COMPANY, ropNumber);
                membership.Mileages__c = 90000;
                membership.AccountId__c = acc.Id;
                insert membership;

                calculator.calculateEligibleSeatUpgrade(membership, new List<Passenger__c> {passenger});
                Assert.assert(passenger.Eligible_for_Upgrade_Seat__c != null, 'Eligible_for_Upgrade_Seat__c is not null.');
                Assert.assert(passenger.Eligible_for_Upgrade_Seat__c.contains('A066'), 'Passenger should be available for A058 upgrade.');
        }

        private static testMethod void testPassengerBKKtoHKGtoICNUpgradableFirstLegOnly() {
                String travelClass = 'Y';
                String ropNumber = 'AB123459';
                Set<String> originSet = new Set<String> {'BKK', 'HKG'};
                Set<String> destinationSet = new Set<String> {'ICN'};

                MileageUpgradeSeatCalculator calculator = new MileageUpgradeSeatCalculator(originSet, destinationSet);

                Flight__c flightFirstLeg = MockupData_Test.createFlight('TG628', '2017-03-03', 1);
                flightFirstLeg.Departure_STN__c = 'BKK';
                flightFirstLeg.Arrival_STN__c = 'HKG';
                insert flightFirstLeg;

                Flight__c flightSecondLeg = MockupData_Test.createFlight('TG628', '2017-03-03', 2);
                flightSecondLeg.Departure_STN__c = 'HKG';
                flightSecondLeg.Arrival_STN__c = 'ICN';
                insert flightSecondLeg;

                Account acc = MockupData_Test.createAccount('TEST');
                insert acc;

                Passenger__c passenger1 = MockupData_Test.createPassenger(flightFirstLeg.Id, travelClass);
                passenger1.AccountId__c = acc.Id;
                insert passenger1;

                Passenger__c passenger2 = MockupData_Test.createPassenger(flightSecondLeg.Id, travelClass);
                passenger2.AccountId__c = acc.Id;
                insert passenger2;

                passenger1 = [SELECT Id, FlightId__r.Routing__c, Pax_Key_txt__c, Eligible_for_Upgrade_Seat__c, Eligible_for_Upgrade_Seat_Priority__c, Last_Name__c, Board_Point__c, Off_Point__c,  Date_of_Birth_Input__c, Name, Cabin_Code__c, Flight_Origin__c, Flight_Destination__c, FFP__c, FFP_Number__c, FFP_Carrier__c, FlightId__r.Origin__c, FlightId__r.Destination__c, AccountId__r.Last_Name__c, AccountId__r.Date_of_Birth__c, FlightId__r.Departure_STN__c, FlightId__r.Arrival_STN__c FROM Passenger__c WHERE Id = : passenger1.Id LIMIT 1];
                passenger2 = [SELECT Id, FlightId__r.Routing__c, Pax_Key_txt__c, Eligible_for_Upgrade_Seat__c, Eligible_for_Upgrade_Seat_Priority__c, Last_Name__c, Board_Point__c, Off_Point__c,  Date_of_Birth_Input__c, Name, Cabin_Code__c, Flight_Origin__c, Flight_Destination__c, FFP__c, FFP_Number__c, FFP_Carrier__c, FlightId__r.Origin__c, FlightId__r.Destination__c, AccountId__r.Last_Name__c, AccountId__r.Date_of_Birth__c, FlightId__r.Departure_STN__c, FlightId__r.Arrival_STN__c FROM Passenger__c WHERE Id = : passenger2.Id LIMIT 1];

                Membership__c membership = MockupData_Test.createMembership();
                membership.Name = ropNumber;
                membership.EXTMember__c = CSE_SOAPUpdatePax_WS.getMemberExtId(BE8_GlobalConstants.DEFAULT_TG_COMPANY, ropNumber);
                membership.Mileages__c = 60000;
                membership.AccountId__c = acc.Id;
                insert membership;

                calculator.calculateEligibleSeatUpgrade(membership, new List<Passenger__c> {passenger1, passenger2});
                //Assert.assert(passenger1.Eligible_for_Upgrade_Seat__c != null, 'Eligible_for_Upgrade_Seat__c is not null.');
                System.debug('JK: pax1 - ' + JSON.serialize(passenger1));
                System.debug('JK: pax2 - ' + JSON.serialize(passenger2));
                Assert.assert(passenger1.Eligible_for_Upgrade_Seat__c.contains('A027'), 'Passenger should be available for A027 upgrade.');
                Assert.assert(!passenger1.Eligible_for_Upgrade_Seat__c.contains('A085'), 'Passenger should not be available for A085 upgrade, because this passenger is in the second leg of the flight.');
                Assert.assert(passenger2.Eligible_for_Upgrade_Seat__c.contains('A085'), 'Passenger should be available for A085 upgrade.');
                Assert.assert(!passenger2.Eligible_for_Upgrade_Seat__c.contains('A027'), 'Passenger should not be available for A027 upgrade, because this passenger is in the second leg of the flight.');
        }

}