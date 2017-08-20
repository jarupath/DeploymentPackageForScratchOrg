//@isTest(seeAllData=true)
@isTest
public class CSE_SOAPUpdatePax_WS_Test {

        private static  String flightNumber = '777';
        private static  String flightDate = '2016-12-01';
        private static  String firstName = 'JOHN';
        private static  String lastName = 'WICK';
        private static String boardPoint = 'BKK';
        private static String offPoint = 'CDG';
        private static String rloc = 'RLOC';

        private static String preparePassengerWSKey() {
                return CSE_SOAPUpdatePax_WS.getPassengerWSKey(flightNumber, flightDate, firstName, lastName, rloc);
        }

        private static Map<String, Passenger__c> preparePassengerMap() {
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();

                Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                //p.Booking_Seat__c = '1A';
                //p.Checkin_Seat__c = '14A';

                String key = preparePassengerWSKey();
                p.WS_KEY__c = key;
                mPax.put(key, p);

                return mPax;
        }

        @testSetup static void setup() {
                MockupData_Test.initializeWebServiceCustomSetting();
        }

        @isTest
        static void testGetPax() {
                Map<String, String> mTotalCabin = new Map<String, String>();
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                String key = CSE_SOAPUpdatePax_WS.getPassengerWSKey(flightNumber, flightDate, firstName, lastName, rloc);

                Flight__c flight = new Flight__c();
                flight.Flight_Number__c = flightNumber;
                flight.Flight_Date_UTC__c = flightDate;
                flight.Flight_External_ID__c = 'TG0777_01Dec16_1';
                insert flight;
                Id flightId = flight.Id;

                Test.startTest();
                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockPax());
                mPax = CSE_SOAPUpdatePax_WS.getPax(flight, flightNumber, flightDate, flightDate, boardPoint, offPoint, mTotalCabin, false);

                Passenger__c p = mPax.get(key);
                Assert.assertEquals(true, p.SSR__c);
                Assert.assertEquals(false, p.Inbound__c);
                Assert.assertEquals(false, p.Outbound__c);
                Assert.assertEquals(true, p.Assigned_Seat__c);
                Assert.assertEquals('WICK JOHN', p.Name);
                Assert.assertEquals('BKK', p.Board_Point__c);
                Assert.assertEquals('CDG', p.Off_Point__c);
                Assert.assertEquals('W', p.Booking_Class__c);
                Assert.assertEquals('C', p.Cabin_Code__c);
                Assert.assertEquals('JOHN', p.First_Name__c);
                Assert.assertEquals('WICK', p.Last_Name__c);
                Assert.assertEquals('2016-12-01', p.Flight_Date__c);
                Assert.assertEquals('WEESTOUR', p.Group_Name__c);
                Assert.assertEquals(false, p.Child__c);
                Assert.assertEquals(false, p.Infant__c);
                Assert.assertEquals(true, p.Staff_Booking__c);
                Assert.assertEquals(false, p.Staff_Waitlist__c);
                Assert.assertEquals(true, p.Ticket__c);
                Assert.assertEquals('WEESTOUR', p.Group_Name__c);
                Assert.assertEquals('RLOC', p.PNR__c);
                Assert.assertEquals('HK', p.Segment_Status__c);
                Assert.assertEquals(key, p.WS_KEY__c);
                Assert.assertEquals('', p.SSR_Service__c);
                Assert.assertEquals('BKK-CDG', p.Sector__c);
                Assert.assertEquals('TG777_01DEC16', p.Flight_Master__c);
                Assert.assertEquals('C23 Y216', mTotalCabin.get('BKK-CDG'));

                delete flight;
                Flight__c deletedFlight = [SELECT Id, IsDeleted FROM Flight__c WHERE Id = :flightId ALL ROWS];
                Assert.assertEquals(true, deletedFlight.IsDeleted);
                Test.stopTest();
        }

        @isTest
        static void testGetSeat() {
                Map<String, Passenger__c> mPax = preparePassengerMap();
                String key = preparePassengerWSKey();

                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockSeat());
                Test.startTest();
                CSE_SOAPUpdatePax_WS.getSeat(mPax, flightNumber, flightDate, boardPoint, offPoint);
                Test.stopTest();
                Passenger__c p = mPax.get(key);
                Assert.assertEquals('1A', p.Booking_Seat__c);
                Assert.assertEquals('14A', p.Checkin_Seat__c);
        }

        @isTest
        static void testGetIllegalCheckInSeat() {
                Map<String, Passenger__c> mPax = preparePassengerMap();
                String key = preparePassengerWSKey();

                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockIllegalCheckInSeat());
                Test.startTest();
                CSE_SOAPUpdatePax_WS.getSeat(mPax, flightNumber, flightDate, boardPoint, offPoint);
                Test.stopTest();
                Passenger__c p = mPax.get(key);
                Assert.assertEquals('1A', p.Booking_Seat__c);
                Assert.assertEquals('014A/014A', p.Checkin_Seat__c);
        }

        @isTest
        static void testGetSSR() {
                List<String> ssrs1 = new List<String>();
                ssrs1.add('MAAS');
                ssrs1.add('LANG');
                ssrs1.add('WCHR');
                ssrs1.add('UMNR');
                ssrs1.add('DEAF');

                List<String> ssrs2 = new List<String>();
                ssrs2.add('MEDA');
                ssrs2.add('DEPA');
                ssrs2.add('DEPU');
                ssrs2.add('AVIH');
                ssrs2.add('PETC');

                List<String> ssrs3 = new List<String>();
                ssrs3.add('WEAP');
                ssrs3.add('CBBG');
                ssrs3.add('EXST');
                ssrs3.add('COUR');
                ssrs3.add('SPML');

                List<String> ssrs4 = new List<String>();
                ssrs4.add('MAAS');
                ssrs4.add('DOCS');
                ssrs4.add('CTCE');
                ssrs4.add('CTCM');
                ssrs4.add('SPML');

                List<String> ssrsINFT = new List<String>();
                ssrs3.add('INFT');

                Map<String, Passenger__c> mPax = preparePassengerMap();
                String key = preparePassengerWSKey();

                Test.startTest();
                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockSSR1());
                CSE_SOAPUpdatePax_WS.getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint, ssrs1, null);

                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockSSR2());
                CSE_SOAPUpdatePax_WS.getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint, ssrs2, null);

                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockSSR3());
                CSE_SOAPUpdatePax_WS.getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint, ssrs3, null);

                List<String> rops = new List<String>();
                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockSSR4());
                CSE_SOAPUpdatePax_WS.getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint, ssrs4, rops);

                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockSSRINFT());
                CSE_SOAPUpdatePax_WS.getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint, ssrsINFT, null);
                Test.stopTest();

                Passenger__c p = mPax.get(key);

                Assert.assertEquals(key, p.WS_KEY__c);
                Assert.assertEquals('JOHN', p.First_Name__c);
                Assert.assertEquals('WICK', p.Last_Name__c);
                Assert.assertEquals('MAAS - VIP\nLANG\nWCHR\nUMNR\nDEAF\nMEDA\nDEPA\nDEPU\nAVIH\nPETC\nWEAP\nCBBG\nEXST\nCOUR\nMAAS - VVIP\n', p.SSR_Service__c);
                Assert.assertEquals('SPML - SPML\n', p.Special_Meal__c);
                Assert.assertEquals(true, p.VIP_VVIP_Flag__c);
                Assert.assertEquals('08964943000/DE', p.Mobile__c);
                Assert.assertEquals('ROBERT.GOETZ//BAMCASES.COM', p.Email_1__c);
                Assert.assertEquals('P', p.Document_Type__c);
                Assert.assertEquals('CHN', p.Doc_Issuing_Country__c);
                Assert.assertEquals('E07530195', p.Travel_Document_Number__c);
                Assert.assertEquals('CHN', p.Nationality__c);
                Assert.assertEquals('27MAR82', p.Date_of_Birth__c);
                Assert.assertEquals('F', p.Gender__c);
                Assert.assertEquals('06MAR24', p.Travel_Document_Expiry_Date__c);
                Assert.assertEquals('ROP111', p.FFP_Number__c);
                Assert.assertEquals('TG', p.FFP_Carrier__c);
                Assert.assertEquals('ROP111', rops[0]);
                Assert.assertEquals('BASE', p.FFP_Tier__c);
                Assert.assertEquals('PONGSANG KUNANYA', p.Infant_Name__c);
                Assert.assertEquals('2016-01-31', p.Infant_Date_of_Birth__c);
                Assert.assert(p.Infant__c);
        }

        @isTest
        static void testGetPassengerWSKey() {
                String actual = CSE_SOAPUpdatePax_WS.getPassengerWSKey('777', '2016-10-10', 'AAA', 'BBB', 'ZA1245');
                Assert.assertEquals('777_2016-10-10_AAA_BBB_ZA1245', actual);
        }

        @isTest
        static void testFindFlight() {
                Test.startTest();
                Flight__c f1 = new Flight__c();
                f1.Name = 'TG999 Leg 1 / 20OCT16';
                f1.Flight_Number__c = 'TG999';
                f1.Flight_Date_UTC__c = '20OCT16';
                f1.Flight_Master__c = 'TG999_20OCT16';
                f1.Departure_STN__c = 'BKK';
                f1.Arrival_STN__c = 'HKG';
                f1.Leg_Number__c = 1;
                f1.Flight_External_ID__c = 'TG0999_20Oct16_1';
                insert f1;

                Flight__c f2 = new Flight__c();
                f2.Name = 'TG999 Leg 2 / 20OCT16';
                f2.Flight_Number__c = 'TG999';
                f2.Flight_Date_UTC__c = '20OCT16';
                f2.Flight_Master__c = 'TG999_20OCT16';
                f2.Departure_STN__c = 'HKG';
                f2.Arrival_STN__c = 'ICN';
                f2.Leg_Number__c = 2;
                f2.Flight_External_ID__c = 'TG0999_20Oct16_2';
                insert f2;
                System.debug('JK: query flight - ' + JSON.serialize([SELECT Id, Name, Flight_Master__c FROM Flight__c]));

                List<Flight__c> flights = CSE_SOAPUpdatePax_WS.findFlight(null, '0999', '2016-10-20');
                System.debug('JK: flights - ' + JSON.serialize(flights));
                Assert.assertEquals('TG999 Leg 1 / 20OCT16', flights[0].Name);
                Assert.assertEquals(Decimal.valueOf('1'), flights[0].Leg_Number__c);
                Assert.assertEquals('TG999', flights[0].Flight_Number__c);
                Assert.assertEquals('2016-10-20', flights[0].Flight_Date_UTC__c);
                Assert.assertEquals('BKK', flights[0].Departure_STN__c);
                Assert.assertEquals('HKG', flights[0].Arrival_STN__c);

                Assert.assertEquals('TG999 Leg 2 / 20OCT16', flights[1].Name);
                Assert.assertEquals(Decimal.valueOf('2'), flights[1].Leg_Number__c);
                Assert.assertEquals('TG999', flights[1].Flight_Number__c);
                Assert.assertEquals('2016-10-20', flights[1].Flight_Date_UTC__c);
                Assert.assertEquals('HKG', flights[1].Departure_STN__c);
                Assert.assertEquals('ICN', flights[1].Arrival_STN__c);

                Test.stopTest();
        }

        @isTest
        static void testConcreteAccount_PaxHaveFLBP_AccountCreatedCorrectly() {
                Passenger__c p = new Passenger__c();
                p.First_Name__c = 'AAA';
                p.Last_Name__c = 'BBB';
                p.Date_of_Birth__c = '13JUL78';
                p.Travel_Document_Number__c = 'NA756412';
                p.Gender__c = 'M';
                p.Email_1__c = 'AAA@mail.com';
                p.Travel_Document_Expiry_Date__c = '13JUL20';
                Test.startTest();
                Account a = CSE_SOAPUpdatePax_WS.concreteAccount(p);
                Test.stopTest();

                Assert.assertEquals('BBB AAA', a.Name);
                Assert.assertEquals('AAA_BBB_13JUL78_NA756412', a.Customer_External_Id__c);
                Assert.assertEquals('AAA', a.First_Name__c);
                Assert.assertEquals('BBB', a.Last_Name__c);
                Assert.assertEquals('Male', a.Gender__c);
                Assert.assertEquals('AAA@mail.com', a.Email_1__c);
                Assert.assertEquals(BE8_DateUtility.toDate('YYYY-MM-DD', '1978-07-13'), a.Date_of_Birth__c);
                Assert.assertEquals('NA756412', a.Travel_Document__c);
                Assert.assertEquals(BE8_DateUtility.toDate('YYYY-MM-DD', '2020-07-13'), a.Travel_Document_Expiry_Date__c);
        }

        @isTest
        static void testConcreteAccount_PaxAgeIs99_AccountCreatedCorrectly() {
                DateTime currentDateTime = DateTime.now();

                String strCurrentYearPlus1 = '' + (currentDateTime.year() + 1); // If current year is 2017, plus 1 is 2018
                String strCurrentYearPlus1_2Digits = strCurrentYearPlus1.substring(strCurrentYearPlus1.length() - 2, strCurrentYearPlus1.length()); // If current year + 1 is 2018, 2 digits is 18
                String strBirthYear = '' + (currentDateTime.year() + 1 - 100); // If current year is 2017, birth year is 1918

                Passenger__c p = new Passenger__c();
                p.First_Name__c = 'AAA';
                p.Last_Name__c = 'BBB';
                p.Date_of_Birth__c = '13JUL' + strCurrentYearPlus1_2Digits; // If current year is 2017, Date_of_Birth__c = 13JUL18
                p.Travel_Document_Number__c = 'NA756412';
                p.Gender__c = 'M';
                p.Email_1__c = 'AAA@mail.com';
                p.Travel_Document_Expiry_Date__c = '13JUL20';

                Test.startTest();
                Account a = CSE_SOAPUpdatePax_WS.concreteAccount(p);
                Test.stopTest();

                Assert.assertEquals('BBB AAA', a.Name);
                Assert.assertEquals('AAA_BBB_13JUL' + strCurrentYearPlus1_2Digits + '_NA756412', a.Customer_External_Id__c);
                Assert.assertEquals('AAA', a.First_Name__c);
                Assert.assertEquals('BBB', a.Last_Name__c);
                Assert.assertEquals('Male', a.Gender__c);
                Assert.assertEquals('AAA@mail.com', a.Email_1__c);
                Assert.assertEquals(BE8_DateUtility.toDate('YYYY-MM-DD', strBirthYear + '-07-13'), a.Date_of_Birth__c); // if current year is 2017, strBirthYear = 1918-01-13
                Assert.assertEquals('NA756412', a.Travel_Document__c);
                Assert.assertEquals(BE8_DateUtility.toDate('YYYY-MM-DD', '2020-07-13'), a.Travel_Document_Expiry_Date__c);
        }

        @isTest
        static void testClonePassenger() {
                Map<String, String> mTotalCabin = new Map<String, String>();
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                String key = CSE_SOAPUpdatePax_WS.getPassengerWSKey(flightNumber, flightDate, firstName, lastName, rloc);

                Flight__c flight = new Flight__c();
                flight.Flight_Number__c = flightNumber;
                flight.Flight_Date_UTC__c = flightDate;
                flight.Flight_External_ID__c = 'TG0777_11Dec16_1';
                insert flight;
                Id flightId = flight.Id;

                Test.startTest();
                Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockPax());
                mPax = CSE_SOAPUpdatePax_WS.getPax(flight, flightNumber, flightDate, flightDate, boardPoint, offPoint, mTotalCabin, false);
                Passenger__c pax = mPax.get(key);
                Passenger__c p = CSE_SOaPUpdatePax_WS.clonePassenger(pax);
                Test.stopTest();

                Assert.assertEquals(true, p.SSR__c);
                Assert.assertEquals(false, p.Inbound__c);
                Assert.assertEquals(false, p.Outbound__c);
                Assert.assertEquals(true, p.Assigned_Seat__c);
                Assert.assertEquals('WICK JOHN', p.Name);
                Assert.assertEquals('BKK', p.Board_Point__c);
                Assert.assertEquals('CDG', p.Off_Point__c);
                Assert.assertEquals('W', p.Booking_Class__c);
                Assert.assertEquals('C', p.Cabin_Code__c);
                Assert.assertEquals('JOHN', p.First_Name__c);
                Assert.assertEquals('WICK', p.Last_Name__c);
                Assert.assertEquals('2016-12-01', p.Flight_Date__c);
                Assert.assertEquals('WEESTOUR', p.Group_Name__c);
                Assert.assertEquals(false, p.Child__c);
                Assert.assertEquals(false, p.Infant__c);
                Assert.assertEquals(true, p.Staff_Booking__c);
                Assert.assertEquals(false, p.Staff_Waitlist__c);
                Assert.assertEquals(true, p.Ticket__c);
                Assert.assertEquals('WEESTOUR', p.Group_Name__c);
                Assert.assertEquals('RLOC', p.PNR__c);
                Assert.assertEquals('HK', p.Segment_Status__c);
                Assert.assertEquals(key, p.WS_KEY__c);
                Assert.assertEquals('', p.SSR_Service__c);
                Assert.assertEquals('BKK-CDG', p.Sector__c);
                Assert.assertEquals('TG777_01DEC16', p.Flight_Master__c);
        }

        @isTest
        static void testAssignAccountToClonedPassenger_ClonePaxIsNotEmpty_AccountHasBeenAssignedCorrectly() {
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                List<Passenger__c> lClonedPax = new List<Passenger__c>();

                Account a = new Account();
                a.Name = 'TEST';
                insert a;

                Passenger__c pOrigin = new Passenger__c();
                pOrigin.AccountId__c = a.Id;
                mPax.put('0634_2016-11-19_VORATHIDA_TANGITVET_2ATLKU', pOrigin);

                Passenger__c pCloned = new Passenger__c();
                pCloned.WS_KEY__c = '0634_2016-11-19_VORATHIDA_TANGITVET_2ATLKU_2';
                lClonedPax.add(pCloned);

                Test.startTest();
                CSE_SOaPUpdatePax_WS.assignAccountToClonedPassenger(mPax, lClonedPax);
                Test.stopTest();

                Assert.assertEquals(a.Id, lClonedPax.get(0).AccountId__c);
        }

        @isTest
        static void testGetMapPaxAccountFromMember_MemberHasRelationToAccount_ReturnValidAccountId() {
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();


                // Create account
                Account acc = new Account();
                acc.Name = 'AAA BBB';
                acc.First_Name__c = 'AAA';
                acc.Last_Name__c = 'BBB';
                insert acc;
                Id accountId = acc.Id;

                // Relate member to account
                Membership__c m = new Membership__c();
                m.Name = '1234';
                m.EXTMember__c = 'TG_1234';
                m.AccountId__c = acc.Id;
                m.Airline__c = 'TG';
                m.Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, '2099-12-01');
                insert m;

                List<Membership__c> memberships = [Select Name, AccountId__R.Name, Airline__c From Membership__c Where EXTMember__c = 'TG_1234'];
                Assert.assertEquals(1, memberships.size());
                for (Membership__c member : memberships) {
                        Assert.assertEquals('1234', member.Name);
                        Assert.assertEquals('AAA BBB', member.AccountId__R.Name);
                        Assert.assertEquals('TG', member.Airline__c);
                }


                Passenger__c p = new Passenger__c();
                p.FFP_Carrier__c = 'TG';
                p.FFP_Number__c = '1234';
                p.WS_KEY__c = '0628_2016-12-01_JOHN_WICK_NA756412_1';
                mPax.put(p.WS_KEY__c, p);

                Test.startTest();
                Map<String, Account> accounts = CSE_SOAPUpdatePax_WS.getMapPaxAccountFromMember(mPax);
                Test.stopTest();
                Account a = accounts.get('0628_2016-12-01_JOHN_WICK_NA756412_1');

                Assert.assertEquals(accountId, a.Id);

        }

        @isTest
        static void testUpdateAccountFromMember_PaxMapAndAccountMapIsNotEmpty_AccountHasBeenUpdated() {
                Map<String, Account> mPaxAcc = new Map<String, Account>();
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();

                Passenger__c p = new Passenger__c();
                p.WS_KEY__c = '0628_2016-12-01_JOHN_WICK_NA756412_1';
                p.Date_of_Birth__c = '2000-01-01';
                p.Travel_Document_Number__c = 'AB12345';
                p.Travel_Document_Expiry_Date__c = '2099-01-01';
                mPax.put('0628_2016-12-01_JOHN_WICK_NA756412_1', p);

                Account a = new Account();
                a.Name = 'TEST';
                mPaxAcc.put('0628_2016-12-01_JOHN_WICK_NA756412_1', a);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.updateAccountFromMember(mPaxAcc, mPax);
                Test.stopTest();

                Account expectedAcc = mPaxAcc.get('0628_2016-12-01_JOHN_WICK_NA756412_1');

                Assert.assertEquals(expectedAcc.Date_of_Birth__c, BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, '2000-01-01'));
                Assert.assertEquals(expectedAcc.Travel_Document__c, 'AB12345');
                Assert.assertEquals(expectedAcc.Travel_Document_Expiry_Date__c, BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, '2099-01-01'));
        }

        @isTest
        static void testUpdateAccountFromMember_PaxMapIsEmpty_AccountNotUpdated() {
                Map<String, Account> mPaxAcc = new Map<String, Account>();
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();

                Account a = new Account();
                a.Name = 'TEST';
                mPaxAcc.put('0628_2016-12-01_JOHN_WICK_NA756412_1', a);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.updateAccountFromMember(mPaxAcc, mPax);
                Test.stopTest();

                Account actualAcc = mPaxAcc.get('0628_2016-12-01_JOHN_WICK_NA756412_1');

                Assert.assertEquals(null, actualAcc.Date_of_Birth__c);
                Assert.assertEquals(null, actualAcc.Travel_Document__c);
                Assert.assertEquals(null, actualAcc.Travel_Document_Expiry_Date__c);

        }

        @isTest
        static void testGetMapPaxAccountFromFLBP_PassengersIsNotEmpty_AccountHasBeenCreated() {
                List<Passenger__c> passengers = new List<Passenger__c>();

                Passenger__c p = new Passenger__c();
                p.First_Name__c = 'JOHN';
                p.Last_Name__c = 'WICK';
                p.Gender__c = 'M';
                p.Email_1__c = 'johnwick@mail.com';
                p.Mobile__c = '6688997766';
                p.Date_of_Birth__c = '2000-01-01';
                p.Travel_Document_Number__c = 'NA12345';
                p.Travel_Document_Expiry_Date__c = '2099-01-01';
                p.Nationality__c = 'TH';
                p.WS_KEY__c = '0628_2016-12-01_JOHN_WICK_NA756412_1';
                passengers.add(p);

                Test.startTest();
                Map<String, Account> mActual = CSE_SOAPUpdatePax_WS.getMapPaxAccountFromFLBP(passengers);
                Test.stopTest();

                Account actualAcc = mActual.get('0628_2016-12-01_JOHN_WICK_NA756412_1');
                Assert.assertEquals('JOHN', actualAcc.First_Name__c);
                Assert.assertEquals('WICK', actualAcc.Last_Name__c);
                Assert.assertEquals('Male', actualAcc.Gender__c);
                Assert.assertEquals('johnwick@mail.com', actualAcc.Email_1__c);
                Assert.assertEquals('6688997766', actualAcc.Mobile__c);
                Assert.assertEquals(BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, '2000-01-01'), actualAcc.Date_of_Birth__c);
                Assert.assertEquals('NA12345', actualAcc.Travel_Document__c);
                Assert.assertEquals(BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, '2099-01-01'), actualAcc.Travel_Document_Expiry_Date__c);
                Assert.assertEquals('TH', actualAcc.Nationality__c);
                Assert.assertEquals('JOHN_WICK_2000-01-01_NA12345', actualAcc.Customer_External_Id__c);
        }

        @isTest
        static void testGetMapPaxAccountFromFLBP_PassengersIsEmpty_ReturnEmptyAccount() {
                List<Passenger__c> passengers = new List<Passenger__c>();

                Test.startTest();
                Map<String, Account> mActual = CSE_SOAPUpdatePax_WS.getMapPaxAccountFromFLBP(passengers);
                Test.stopTest();
                Assert.assertEquals(0, mActual.size());
        }

        @isTest
        static void testFilterMapPaxAccountFromFLBP_MapPaxAccountAndFilterIsNotEmpty_AccountWhichPassFilterExist() {
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                Set<String> filters = new Set<String>();

                filters.add('JOHN_WICK_2000-01-01_NA12345');

                Account a = new Account();
                a.Name = 'JOHN WICK';
                mPaxAccFLBP.put('JOHN_WICK_2000-01-01_NA12345', a);

                a = new Account();
                a.Name = 'SOMETHING ELSE';
                mPaxAccFLBP.put('SOMETHING_ELSE_2000-01-01_NA12346', a);

                Assert.assertEquals(2, mPaxAccFLBP.size());

                Test.startTest();
                CSE_SOAPUpdatePax_WS.filterMapPaxAccountFromFLBP(mPaxAccFLBP, filters);
                Test.stopTest();
                Assert.assertEquals(1, mPaxAccFLBP.size());

                Account acc = mPaxAccFLBP.get('SOMETHING_ELSE_2000-01-01_NA12346');
                Assert.assertEquals('SOMETHING ELSE', acc.Name);
        }

        @isTest
        static void testFilterMapPaxAccountFromFLBP_FilterIsEmpty_AllAccountsExist() {
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                Set<String> filters = new Set<String>();

                Account a = new Account();
                a.Name = 'JOHN WICK';
                mPaxAccFLBP.put('JOHN_WICK_2000-01-01_NA12345', a);

                a = new Account();
                a.Name = 'SOMETHING ELSE';
                mPaxAccFLBP.put('SOMETHING_ELSE_2000-01-01_NA12346', a);

                Assert.assertEquals(2, mPaxAccFLBP.size());

                Test.startTest();
                CSE_SOAPUpdatePax_WS.filterMapPaxAccountFromFLBP(mPaxAccFLBP, filters);
                Test.stopTest();
                Assert.assertEquals(2, mPaxAccFLBP.size());

                Account acc = mPaxAccFLBP.get('SOMETHING_ELSE_2000-01-01_NA12346');
                Assert.assertEquals('SOMETHING ELSE', acc.Name);

                acc = mPaxAccFLBP.get('JOHN_WICK_2000-01-01_NA12345');
                Assert.assertEquals('JOHN WICK', acc.Name);
        }

        @isTest
        static void testGetMapPaxTravelDoc_PassengersIsNotEmpty_ReturnTravelDocumentMapCorrectly() {
                Passenger__c p = new Passenger__c();
                p.Nationality__c = 'TH';
                p.Travel_Document_Number__c = 'TH12345';
                p.Travel_Document_Expiry_Date__c = '2099-01-01';
                p.WS_KEY__c = 'JOHN_WICK_2000-01-01_NA12345';
                List<Passenger__c> passengers = new List<Passenger__c>();
                passengers.add(p);

                Test.startTest();
                Map<String, Travel_Document__c> mPaxTravelDoc = CSE_SOAPUpdatePax_WS.getMapPaxTravelDoc(passengers);
                Test.stopTest();
                Assert.assertEquals(1, mPaxTravelDoc.size());

                Travel_Document__c t = mPaxTravelDoc.get('JOHN_WICK_2000-01-01_NA12345');
                Assert.assertEquals('TH', t.Nationality__c);
                Assert.assertEquals('TH12345', t.Travel_Document_Number__c);
                Assert.assertEquals('TH12345', t.ExtDocument__c);
                Assert.assertEquals(BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, '2099-01-01'), t.Travel_Document_Expiry_Date__c);
        }

        @isTest
        static void testGetFlightMasterKey_ValidFlightNumberAndFlightDate_ReturnFlightMasterCorrectly() {
                Test.startTest();
                String actual = CSE_SOAPUpdatePax_WS.getFlightMasterKey(null, '0600', '2016-11-11');
                Test.stopTest();
                Assert.assertEquals('TG0600_11NOV16', actual);
        }

        @isTest
        static void testGetClonePassenger_Flight1Leg_PaxReferToFlightCorrectlyAndPaxWSKeyIncludeLegNumber1() {
                List<Passenger__c> passengers = new List<Passenger__c>();
                Flight__c f = new Flight__c();
                f.Name = 'TG666 / 11NOV16';
                f.Leg_Number__c = 1;
                f.Flight_Date_UTC__c = '11NOV16';
                f.Departure_STN__c = 'BKK';
                f.Arrival_STN__c = 'HKG';
                f.Flight_Number__c = 'TG0666';
                f.Flight_Master__c = 'TG0666_11NOV16';
                f.Flight_External_ID__c = 'TG0666_11Nov16_1';
                insert f;

                Id expectedFlightId = f.Id;

                Passenger__c p = new Passenger__c();
                p.Board_Point__c = 'BKK';
                p.Off_Point__c = 'HKG';
                p.First_Name__c = 'JOHN';
                p.Last_Name__c = 'WICK';
                p.WS_KEY__c = '0666_2016-11-11_JOHN_WICK_NA756412';
                p.Flight_Master__c = 'TG0666_11NOV16';
                passengers.add(p);

                Test.startTest();
                List<Passenger__c> clonePassengers = CSE_SOAPUpdatePax_WS.getClonePassenger(null, passengers, '0666', '2016-11-11');
                Test.stopTest();

                Assert.assertEquals(0, clonePassengers.size());
                Assert.assertEquals('0666_2016-11-11_JOHN_WICK_NA756412_1', p.WS_KEY__c);
                Assert.assertEquals(expectedFlightId, p.FlightId__c);
        }

        @isTest
        static void testGetClonePassenger_Flight2Leg_PaxReferToFlightCorrectlyAndPaxWSKeyIncludeValidLegNumberAndClonePaxHaveBeenGeneratedWithValidValue() {
                List<Passenger__c> passengers = new List<Passenger__c>();


                Flight__c f = new Flight__c();
                f.Name = 'TG666 / 11NOV16';
                f.Leg_Number__c = 1;
                f.Flight_Date_UTC__c = '11NOV16';
                f.Departure_STN__c = 'BKK';
                f.Arrival_STN__c = 'HKG';
                f.Flight_Number__c = 'TG0666';
                f.Flight_Master__c = 'TG0666_11NOV16';
                f.Flight_External_ID__c = 'TG0666_11Nov16_1';
                insert f;
                Id expectedFlightIdLeg1 = f.Id;

                f = new Flight__c();
                f.Name = 'TG666 / 11NOV16';
                f.Leg_Number__c = 2;
                f.Flight_Date_UTC__c = '11NOV16';
                f.Departure_STN__c = 'HKG';
                f.Arrival_STN__c = 'ICN';
                f.Flight_Number__c = 'TG0666';
                f.Flight_Master__c = 'TG0666_11NOV16';
                f.Flight_External_ID__c = 'TG0666_11Nov16_2';
                insert f;
                Id expectedFlightIdLeg2 = f.Id;

                Passenger__c p = new Passenger__c();
                p.Board_Point__c = 'BKK';
                p.Off_Point__c = 'HKG';
                p.First_Name__c = 'JOHN';
                p.Last_Name__c = 'WICK';
                p.WS_KEY__c = '0666_2016-11-11_JOHN_WICK_NA756412';
                p.Flight_Master__c = 'TG0666_11NOV16';
                passengers.add(p);

                p = new Passenger__c();
                p.Board_Point__c = 'HKG';
                p.Off_Point__c = 'ICN';
                p.First_Name__c = 'ANNA';
                p.Last_Name__c = 'WICK';
                p.WS_KEY__c = '0666_2016-11-11_ANNA_WICK_NA756413';
                p.Flight_Master__c = 'TG0666_11NOV16';
                passengers.add(p);

                p = new Passenger__c();
                p.Board_Point__c = 'BKK';
                p.Off_Point__c = 'ICN';
                p.First_Name__c = 'THRUMB';
                p.Last_Name__c = 'FUCK';
                p.WS_KEY__c = '0666_2016-11-11_THRUMB_FUCK_NA756414';
                p.Flight_Master__c = 'TG0666_11NOV16';
                passengers.add(p);

                Test.startTest();
                List<Passenger__c> clonePassengers = CSE_SOAPUpdatePax_WS.getClonePassenger(null, passengers, '0666', '2016-11-11');
                Test.stopTest();

                Assert.assertEquals(1, clonePassengers.size());
                Assert.assertEquals('0666_2016-11-11_JOHN_WICK_NA756412_1', passengers.get(0).WS_KEY__c);
                Assert.assertEquals('0666_2016-11-11_ANNA_WICK_NA756413_2', passengers.get(1).WS_KEY__c);
                Assert.assertEquals('0666_2016-11-11_THRUMB_FUCK_NA756414_1', passengers.get(2).WS_KEY__c);
                Assert.assertEquals(expectedFlightIdLeg1, passengers.get(0).FlightId__c);
                Assert.assertEquals(expectedFlightIdLeg2, passengers.get(1).FlightId__c);
                Assert.assertEquals(expectedFlightIdLeg1, passengers.get(2).FlightId__c);

                Assert.assertEquals('0666_2016-11-11_THRUMB_FUCK_NA756414_2', clonePassengers.get(0).WS_KEY__c);
                Assert.assertEquals(expectedFlightIdLeg2, clonePassengers.get(0).FlightId__c);
        }

        @isTest
        static void testAssignAccountToPassenger_PaxRelatedToAccountFromMembership_AccountIdOfPaxAndCustomerExtIdOfAccountHaveBeenUpdated() {
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                insert a;
                mPaxAccMember.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                mPaxAccFLBP.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                Id expectedAccId = a.Id;

                Passenger__c p = new Passenger__c();
                p.Board_Point__c = 'BKK';
                p.Off_Point__c = 'HKG';
                p.First_Name__c = 'JOHN';
                p.Last_Name__c = 'WICK';
                p.Date_of_Birth__c = '2000-12-12';
                p.Travel_Document_Number__c = 'NA756412';
                p.WS_KEY__c = '0666_2016-11-11_JOHN_WICK_NA756412';
                p.Flight_Master__c = 'TG0666_11NOV16';
                mPax.put(p.WS_KEY__c, p);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountToPassenger(mPax, mPaxAccMember, mPaxAccFLBP);
                Test.stopTest();

                Assert.assertEquals(expectedAccId, mPax.get('0666_2016-11-11_JOHN_WICK_NA756412').AccountId__c);
                Assert.assertEquals('JOHN_WICK_2000-12-12_NA756412', mPaxAccMember.get('0666_2016-11-11_JOHN_WICK_NA756412').Customer_External_Id__c);
        }

        @isTest
        static void testAssignAccountToPassenger_PaxRelatedToAccountFromFLBP_AccountIdOfPaxHasBeenUpdated() {
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                String pnrNumber = 'NA756412';
                String paxWSKey = flightNumber + '_' + flightDate + '_' + firstName + '_' + lastName + '_' + pnrNumber;

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                a.Customer_External_Id__c = 'JOHN_WICK_1985-11-11_12345678';
                insert a;
                //mPaxAccMember.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                mPaxAccFLBP.put(paxWSKey, a);
                Id expectedAccId = a.Id;

                Passenger__c p = new Passenger__c();
                p.Board_Point__c = 'BKK';
                p.Off_Point__c = 'HKG';
                p.First_Name__c = 'JOHN';
                p.Last_Name__c = 'WICK';
                p.Date_of_Birth__c = '1985-11-11';
                p.Travel_Document_Number__c = '12345678';
                p.PNR__c = pnrNumber;
                p.WS_KEY__c = CSE_SOaPUpdatePax_WS.getPassengerWSKey(flightNumber, flightDate, firstName, lastName, pnrNumber);
                p.Flight_Master__c = 'TG0666_11NOV16';
                mPax.put(p.WS_KEY__c, p);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountToPassenger(mPax, mPaxAccMember, mPaxAccFLBP);
                Test.stopTest();

                Assert.assertEquals(expectedAccId, mPax.get(paxWSKey).AccountId__c);
        }

        /*
                Scenario: A passenger made two reservation. This passenger will be given two sets of PNR Number.
                This will result in two Passenger records looking up to the same Account.
                Positive/Negative Case: Positive
                Expected Results:
                - Passenger with the same First Name, Last Name and Travel Document but different PNR will be related to the same Account
        */
        @isTest
        static void testAssignAccountToPassenger_PaxRelatedToAccountFromFLBP_OnePassengerTwoPNRNumber() {
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                //String paxWSKey = flightNumber + '_' + flightDate + '_' + firstName + '_' + lastName + '_' + pnrNumber;

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                a.Customer_External_Id__c = 'JOHN_WICK_1985-11-11_12345678';
                insert a;

                Id expectedAccId = a.Id;

                Passenger__c p = new Passenger__c();
                p.Board_Point__c = 'BKK';
                p.Off_Point__c = 'HKG';
                p.First_Name__c = 'JOHN';
                p.Last_Name__c = 'WICK';
                p.Date_of_Birth__c = '1985-11-11';
                p.Travel_Document_Number__c = '12345678';
                p.PNR__c = 'NA756412';
                p.WS_KEY__c = CSE_SOaPUpdatePax_WS.getPassengerWSKey(flightNumber, flightDate, p.First_Name__c, p.Last_Name__c, p.PNR__c);
                p.Flight_Master__c = 'TG0666_11NOV16';
                mPaxAccFLBP.put(p.WS_KEY__c, a);
                mPax.put(p.WS_KEY__c, p);

                Passenger__c p2 = new Passenger__c();
                p2.Board_Point__c = 'BKK';
                p2.Off_Point__c = 'HKG';
                p2.First_Name__c = 'JOHN';
                p2.Last_Name__c = 'WICK';
                p2.Date_of_Birth__c = '1985-11-11';
                p2.Travel_Document_Number__c = '12345678';
                p2.PNR__c = 'NA7523989';
                p2.WS_KEY__c = CSE_SOaPUpdatePax_WS.getPassengerWSKey(flightNumber, flightDate, p2.First_Name__c, p2.Last_Name__c, p2.PNR__c);
                p2.Flight_Master__c = 'TG0666_11NOV16';
                mPaxAccFLBP.put(p2.WS_KEY__c, a);
                mPax.put(p2.WS_KEY__c, p2);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountToPassenger(mPax, mPaxAccMember, mPaxAccFLBP);
                Test.stopTest();

                Assert.assertEquals(expectedAccId, p.AccountId__c);
                Assert.assertEquals(expectedAccId, p2.AccountId__c);
        }

        @isTest
        static void testAssignAccountToTravelDoc_TravelDocRelatedToAccountFromMembership_AccountIdOfTravelDocHasBeenUpdated() {
                Map<String, Travel_Document__c> mPaxDoc = new Map<String, Travel_Document__c>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                insert a;
                mPaxAccMember.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                mPaxAccFLBP.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                Id expectedAccId = a.Id;

                Travel_Document__c t = new Travel_Document__c();
                t.Nationality__c = 'TH';
                t.Travel_Document_Number__c = 'NA756412';
                t.ExtDocument__c = 'NA756412';
                mPaxDoc.put('0666_2016-11-11_JOHN_WICK_NA756412', t);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountToTravelDoc(mPaxDoc, mPaxAccMember, mPaxAccFLBP);
                Test.stopTest();

                Assert.assertEquals(expectedAccId, mPaxDoc.get('0666_2016-11-11_JOHN_WICK_NA756412').AccountId__c);
        }

        @isTest
        static void testAssignAccountToTravelDoc_TravelDocRelatedToAccountFromFLBP_AccountIdOfTravelDocHasBeenUpdated() {
                Map<String, Travel_Document__c> mPaxDoc = new Map<String, Travel_Document__c>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                insert a;
                mPaxAccMember.put('0777_2016-11-11_JOHN_WICK_NA756412', a);
                mPaxAccFLBP.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                Id expectedAccId = a.Id;

                Travel_Document__c t = new Travel_Document__c();
                t.Nationality__c = 'TH';
                t.Travel_Document_Number__c = 'NA756412';
                t.ExtDocument__c = 'NA756412';
                mPaxDoc.put('0666_2016-11-11_JOHN_WICK_NA756412', t);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountToTravelDoc(mPaxDoc, mPaxAccMember, mPaxAccFLBP);
                Test.stopTest();

                Assert.assertEquals(expectedAccId, mPaxDoc.get('0666_2016-11-11_JOHN_WICK_NA756412').AccountId__c);
        }

        @isTest
        static void testAssignAccountFLBPToMembership_MembershipRelatedToAccountFLBP_AccountIdOfMembershipHasBeenUpdated() {
                Map<String, Membership__c> mPaxMem = new Map<String, Membership__c>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                insert a;
                mPaxAccFLBP.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                Id expectedAccId = a.Id;

                Membership__c m = new Membership__c();
                m.Airline__c = 'TG';
                m.Name = 'AZ123456';
                m.Tier__c = 'PLATINUM';
                m.EXTMember__c = 'TG_AZ123456';
                mPaxMem.put('0666_2016-11-11_JOHN_WICK_NA756412', m);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountFLBPToMembership(mPaxMem, mPaxAccFLBP, mPaxAccMember);
                Test.stopTest();

                Assert.assertEquals(expectedAccId, mPaxMem.get('0666_2016-11-11_JOHN_WICK_NA756412').AccountId__c);
        }

        @isTest
        static void testAssignAccountFLBPToMembership_MembershipNotRelatedToAccountFLBP_ThisMembershipHasBeenRemovedFromMap() {
                Map<String, Membership__c> mPaxMem = new Map<String, Membership__c>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();

                Account a = new Account();
                a.Name = 'JOHN WICK';
                a.First_Name__c = 'JOHN';
                a.Last_Name__c = 'WICK';
                insert a;
                mPaxAccFLBP.put('0666_2016-11-11_JOHN_WICK_NA756412', a);
                Id expectedAccId = a.Id;

                Membership__c m = new Membership__c();
                m.Airline__c = 'TG';
                m.Name = 'AZ123456';
                m.Tier__c = 'PLATINUM';
                m.EXTMember__c = 'TG_AZ123456';
                mPaxMem.put('0777_2016-11-11_JOHN_WICK_NA756412', m);

                Test.startTest();
                CSE_SOAPUpdatePax_WS.assignAccountFLBPToMembership(mPaxMem, mPaxAccFLBP, mPaxAccMember);
                Test.stopTest();

                Assert.assertEquals(0, mPaxMem.size());
        }

        @isTest
        static void testConcreteFlightBookingPax_FlightWith2Leg_SaveBookingPassengerToFlightCorrectly() {
                List<Flight__c> flights = null;
                Map<String, String> mTotalCabin = new Map<String, String>();


                Flight__c f = new Flight__c();
                f.Name = 'TG666 / 11NOV16';
                f.Leg_Number__c = 1;
                f.Flight_Date_UTC__c = '11NOV16';
                f.Departure_STN__c = 'BKK';
                f.Arrival_STN__c = 'HKG';
                f.Flight_Number__c = 'TG0666';
                f.Flight_Master__c = 'TG0666_11NOV16';
                f.Flight_External_ID__c = 'TG0666_11Nov16_1';
                insert f;
                Id expectedFlightIdLeg1 = f.Id;

                f = new Flight__c();
                f.Name = 'TG666 / 11NOV16';
                f.Leg_Number__c = 2;
                f.Flight_Date_UTC__c = '11NOV16';
                f.Departure_STN__c = 'HKG';
                f.Arrival_STN__c = 'ICN';
                f.Flight_Number__c = 'TG0666';
                f.Flight_Master__c = 'TG0666_11NOV16';
                f.Flight_External_ID__c = 'TG0666_11Nov16_2';
                insert f;
                Id expectedFlightIdLeg2 = f.Id;

                mTotalCabin.put('BKK-HKG', 'F10 C20 Y30');
                mTotalCabin.put('HKG-ICN', 'F5 C10 Y15');
                mTotalCabin.put('BKK-ICN', 'F1 C2 Y3');

                Test.startTest();
                flights = CSE_SOAPUpdatePax_WS.concreteFlightBookingPax(null, '0666', '2016-11-11', mTotalCabin);
                Test.stopTest();

                for (Flight__c flight : flights) {
                        if (flight.Leg_Number__c == 1) {
                                Assert.assertEquals('F11 C22 Y33', flight.Booking_Passengers__c);
                        } else if (flight.Leg_Number__c == 2) {
                                Assert.assertEquals('F6 C12 Y18', flight.Booking_Passengers__c);
                        }
                }
        }

        @isTest
        static void testUpdatePassengerInformation() {
                Flight__c flight = MockupData_Test.createFlight('TG0777', '01Dec16', 1);
                flight.Aircraft_Configuration__c = 'C20 Y300';
                flight.Booking_Passengers__c = 'C5 Y5';
                flight.Departure_STN__c = 'HKG';
                flight.Flight_External_ID__c = 'TG0777_01Dec16_1';
                insert flight;

                List<Passenger__c> passengersForInsert = new List<Passenger__c>();

                Passenger__c bookingPassenger = MockupData_Test.createPassenger(flight.Id, 'C');
                bookingPassenger.Sector__c = 'BKK-HKG';
                bookingPassenger.Booking_Class__c = 'A03';
                passengersForInsert.add(bookingPassenger);

                insert passengersForInsert;

                Test.startTest();
                Map<String, Object> objMap = CSE_SOAPUpdatePax_WS.updatePassengerInformation(flight);
                Test.stopTest();

                Map<String, Account> actualMemberMap = (Map<String, Account>)objMap.get('PAX-ACC-Member');
                System.debug('SJ : actualMemberMap : ' + actualMemberMap);
                //Assert.assertEquals('TEST', );
                Map<String, Account> actualFLBPMap = (Map<String, Account>)objMap.get('PAX-ACC_FLBP');
                System.debug('SJ : actualFLBPMap : ' + actualFLBPMap);

                Map<String, Travel_Document__c> actualTravelDocMap = (Map<String, Travel_Document__c>)objMap.get('PAX-DOC');
                System.debug('SJ : actualTravelDocMap : ' + actualTravelDocMap);

                Map<String, Membership__c> actualMembershipMap = (Map<String, Membership__c>)objMap.get('PAX-MEM');
                System.debug('SJ : actualMembershipMap : ' + actualMembershipMap);

                Map<String, Passenger__c> actualPassengerMap = (Map<String, Passenger__c>)objMap.get('PAX');
                System.debug('SJ : actualPassenger : ' + actualPassengerMap);

                List<Passenger__c> actualClonePassengers = (List<Passenger__c>)objMap.get('PAX-CLONE');
                System.debug('SJ : actualPassengers : ' + actualClonePassengers);

                List<String> ropList = (List<String>)objMap.get('PAX-ROP');
                System.debug('SJ : ropList : ' + ropList);

                Assert.assertEquals(null, objMap.get('PAX-CABIN'));
        }

        @isTest static void testConcreteMembershipPaxNotNull(){
                Flight__c f1 = new Flight__c();
                f1.Name = 'TG628 / 25MAR25';
                insert f1;

                Passenger__c pax = MockupData_Test.createPassengerList(f1.Id, 1).get(0);
                pax.FFP_Tier__c = 'PLAT';
                pax.FFP_Number__c = 'RF12345';
                pax.FFP_Carrier__c = 'TG';

                Membership__c mem = CSE_SOaPUpdatePax_WS.concreteMembership(pax);
                System.debug('JK: mem - ' + JSON.serialize(mem));
                System.assertEquals('RF12345', mem.Name, 'Membership name should be RF12345');
                System.assertEquals('TG', mem.Airline__c, 'Membership airline should be TG');
                System.assertEquals('PLAT', mem.Tier__c, 'Membership tier should be PLAT');
                System.assertEquals('TG_RF12345', mem.EXTMember__c, 'Membership external id should be TG_RF12345');
                System.assertEquals('Active', mem.Status__c, 'Membership status should be Active');
        }
        @isTest static void testUpdatePassengerToDatabase(){
                Map<String, object> mInfo = new Map<String, object>();
                List<Flight__c> lFlights = new List<Flight__c>();
                Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
                Map<String, Account> mPaxAccMember = new Map<String, Account>();
                Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
                Map<String, Travel_Document__c> mPaxDoc = new Map<String, Travel_Document__c>();
                Map<String, Membership__c> mPaxMem = new Map<String, Membership__c>();
                List<Passenger__c> clonePaxs = new List<Passenger__c>();
                mInfo.put('PAX-ACC-Member', mPaxAccMember);
                mInfo.put('PAX-ACC_FLBP', mPaxAccFLBP);
                mInfo.put('PAX-DOC', mPaxDoc);
                mInfo.put('PAX-MEM', mPaxMem);
                mInfo.put('PAX-CLONE', clonePaxs);
                mInfo.put('PAX', mPax);
                mInfo.put('PAX-CABIN', lFlights);
                CSE_SOaPUpdatePax_WS.updatePassengerToDatabase(mInfo);
        }
}