@isTest
private class PVController_Test {

    @testSetup static void setUp() {
        MockupData_Test.initializeSystemConfigurationCustomSetting();
    }

    @isTest
    static void testCreatePVView() {
        ApexPages.currentPage().getParameters().put('displayTHB', 'true');
        Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
        insert flight;

        Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
        newCase.Flightid__c = flight.Id;
        insert newCase;

        Case_Group_Member__c cgm = MockupData_Test.createCaseGroupMember(newCase.Id);
        insert cgm;

        List<Compensation__c> compensationsForInsert = new List<Compensation__c>();

        Compensation__c cashCompensation = MockupData_Test.createCompensation(newCase.Id);
        cashCompensation.Compensation_Tools__c = 'Cash';
        cashCompensation.Amount__c = 100;
        cashCompensation.ROE__c = 20;
        cashCompensation.Status__c = 'Approved';
        compensationsForInsert.add(cashCompensation);

        Compensation__c emdCompensation = MockupData_Test.createCompensation(newCase.Id);
        emdCompensation.Compensation_Tools__c = 'EMD';
        emdCompensation.Currency__c = 'USD';
        emdCompensation.Amount__c = 50;
        emdCompensation.ROE__c = 10;
        emdCompensation.Status__c = 'Approved';
        compensationsForInsert.add(emdCompensation);

        Compensation__c otherCompensation = MockupData_Test.createCompensation(newCase.Id);
        otherCompensation.Amount__c = 50;
        otherCompensation.Status__c = 'Approved';
        compensationsForInsert.add(otherCompensation);
        insert compensationsForInsert;

        ApexPages.currentPage().getParameters().put('id', newCase.Id);
        ApexPages.currentPage().getParameters().put('comment', 'comment');
        ApexPages.currentPage().getParameters().put('compensationIds', compensationsForInsert.get(0).Id);
        ApexPages.currentPage().getParameters().put('isCash', 'false');
        ApexPages.currentPage().getParameters().put('isCheque', 'false');

        ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
        System.debug('stdcontroller: ' + stdCaseController);
        PVController ctrl = new PVController(stdCaseController);
        System.debug('ctrl: ' + JSON.serialize(ctrl));
        Assert.assertEquals(100, ctrl.view.amountInFigures);
        Assert.assertEquals('00', ctrl.view.amountInFiguresDec);
    }
}