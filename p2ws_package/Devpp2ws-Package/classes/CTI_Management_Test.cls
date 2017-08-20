@isTest
private class CTI_Management_Test {

    @testSetup
    static void MockData(){
        System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
        insert sysconfig;
        List<Flight__c> flightList = new List<Flight__c>();
        List<CTI_Route_Area__c> ctiRouteAreaList = new List<CTI_Route_Area__c>();
        List<CTI_Area_with_Sector__c> ctiAreaWithSectorList = new List<CTI_Area_with_Sector__c>();
        Flight__c flight1 = new Flight__c(
            Name = '0628',
            Flight_Number__c = 'TG0628',
            Flight_Date_UTC__c = '20Dec25',
            Flight_Date_LT__c = '20Dec25',
            STD_UTC__c = '20Dec25 0330',
            STD_LT__c  = '20Dec25 1030',
            STA_UTC__c = '20Dec25 0620',
            STA_LT__c = '20Dec25 1420',
            Block_Time__c = '170',
            Integration_Source__c = '1',
            Leg_Number__c = 1,
            Flight_External_ID__c = 'TG0628_20Dec25_1',
            Destination__c = 'ICN',
            Departure_STN__c = 'BKK',
            Arrival_STN__c = 'HKG',
            Aircraft_Type__c = '33H');
        flightList.add(flight1);
        System.debug('Test Method - Flight: ' + flight1);

        Flight__c flight2 = new Flight__c(
            Name = '0628',
            Flight_Number__c = 'TG0628',
            Flight_Date_UTC__c = '20Dec25',
            Flight_Date_LT__c = '20Dec25',
            STD_UTC__c = '20Dec25 0730',
            STD_LT__c  = '20Dec25 1450',
            STA_UTC__c = '20Dec25 1020',
            STA_LT__c = '20Dec25 1820',
            Block_Time__c = '170',
            Integration_Source__c = '1',
            Leg_Number__c = 1,
            Flight_External_ID__c = 'TG0628_20Dec25_2',
            Destination__c = 'ICN',
            Departure_STN__c = 'HKG',
            Arrival_STN__c = 'ICN',
            Aircraft_Type__c = '33H');
        flightList.add(flight2);

        Flight__c flight3 = new Flight__c(
            Name = 'TGXXX');
        flightList.add(flight3);

        CTI_Route_Area__c ctiRouteArea = new CTI_Route_Area__c(
            name='HKG', 
            STN__c='Abroad');
        ctiRouteAreaList.add(ctiRouteArea);

        CTI_Route_Area__c ctiRouteArea2 = new CTI_Route_Area__c(
            name='ICN', 
            STN__c='Abroad');
        ctiRouteAreaList.add(ctiRouteArea2);

        CTI_Area_with_Sector__c ctiAreaWithSector = new CTI_Area_with_Sector__c(
            Name = '628BKKHKG',
            Area__c = 'Northern', 
            Flight_Number__c = '628', 
            Region__c = 'Regional', 
            Sector__c = 'BKKHKG');
        ctiAreaWithSectorList.add(ctiAreaWithSector);

        CTI_Area_with_Sector__c ctiAreaWithSector2 = new CTI_Area_with_Sector__c(
            Name = '628HKGICN',
            Area__c = 'Northern', 
            Flight_Number__c = '628', 
            Region__c = 'Regional', 
            Sector__c = 'HKGICN');
        ctiAreaWithSectorList.add(ctiAreaWithSector2);

        CTI_Area_with_Sector__c ctiAreaWithSector3 = new CTI_Area_with_Sector__c(
            Name = 'XXXBKKHKG',
            Area__c = 'Northern', 
            Flight_Number__c = 'XXX', 
            Region__c = 'Regional', 
            Sector__c = 'BKKHKG');
        ctiAreaWithSectorList.add(ctiAreaWithSector3);

        insert flightList;
        insert ctiRouteAreaList;
        insert ctiAreaWithSectorList;

    }
    
    @isTest static void testInsertNewCTI() {
        Flight__c getFlight = [SELECT Id, Name FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_1' LIMIT 1];
        Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
        newCase.Flightid__c = getFlight.Id;
        insert newCase;
        System.debug('Test Method - Case: ' + newCase);

        Test.startTest();

        CTI__c cti = new CTI__c(caseid__c=newCase.Id, CTI_Station__c='HKG', Sector_txt__c = 'BKK-HKG', FlightId__c = getFlight.Id);
        insert cti;
        System.debug('Test Method - Inserted CTI: ' + cti);
        Test.stopTest();

        CTI__c insertCti = [SELECT area__c, STN__c FROM CTI__c WHERE id =:cti.Id LIMIT 1];
        Assert.assertEquals('Northern', insertCti.area__c, 'Before Test Start - test area');
        Assert.assertEquals('Abroad', insertCti.STN__c, 'Before Test Start - test stn');
    }

    @isTest static void testUpdateCTI() {
        Flight__c getFlight1 = [SELECT Id, Name FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_1' LIMIT 1];
        Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
        newCase.Flightid__c = getFlight1.Id;
        insert newCase;

        CTI__c cti = new CTI__c(caseid__c=newCase.Id, CTI_Station__c = 'ICN', Sector_txt__c = 'HKG-ICN', FlightId__c = getFlight1.Id);
        insert cti;

        CTI__c insertCti = [SELECT area__c, STN__c FROM CTI__c WHERE id =:cti.Id limit 1];
        Assert.assertEquals('Northern', insertCti.area__c, 'Before Test Start 2 - test area');
        Assert.assertEquals('Abroad', insertCti.STN__c , 'Before Test Start 2 - test stn');

        Flight__c getFlight2 = [SELECT Id, Name FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_2' LIMIT 1];

        Test.startTest();
        cti.flightid__c = getFlight2.Id;
        update cti;
        Test.stopTest();

        Assert.assertEquals('Northern', insertCti.area__c, 'After Test Start 2 - test area');
        Assert.assertEquals('Abroad', insertCti.STN__c , 'After Test Start 2 - test stn');
    }

    @isTest static void testTGXXXArea(){
        Flight__c getFlight1 = [SELECT Id, Name FROM Flight__c WHERE Name = 'TGXXX' LIMIT 1];
        Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
        newCase.Flightid__c = getFlight1.Id;
        insert newCase;

        Test.startTest();
        CTI__c cti = new CTI__c(caseid__c=newCase.Id, CTI_Station__c = 'BKK', Sector_txt__c = 'BKK-HKG', FlightId__c = getFlight1.Id);
        insert cti;
        Test.stopTest();

        CTI__c newcti = [SELECT Area__c FROM CTI__c WHERE Id = :cti.Id];
        System.debug('JK: testTGXXXArea - ' + JSON.serialize(newcti));

        System.assertEquals('Northern', newcti.Area__c, 'cti area should be Northern according to cti sector');
    }
    
}