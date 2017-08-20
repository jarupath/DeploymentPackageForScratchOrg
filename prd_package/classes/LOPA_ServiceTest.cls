@isTest
private class LOPA_ServiceTest {
	@testSetup static void DataPreparation(){
		List<Flight__c> flightList = new List<Flight__c>();
		Flight__c flight1 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    Departure_STN__c  = 'BKK',
		    STD_UTC__c = '20Dec25 0330',
		    STD_LT__c  = '20Dec25 1030',
		    STA_UTC__c = '20Dec25 0620',
		    STA_LT__c = '20Dec25 1420',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_1');
		flightList.add(flight1);
		insert flightList;
	}

	@isTest static void testIsTheSameEntity() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos position = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		position.type = 'GR';
		position.flag = true;
		position.col = '3';
        position.pos = 'GR';
		position.row = '0';

		MB_RestResponseInfoModel.lopaInfo_lopaPos nextPosition = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		nextPosition.type = 'GR';
		nextPosition.flag = true;
		nextPosition.col = '4';
        nextPosition.pos = 'GR';
		nextPosition.row = '0';

		Assert.assert(LOPAService.isTheSameEntity(position, nextPosition, LOPAService.HORIZONTAL_SEARCH));

		position.type = 'GR';
		position.flag = true;
        position.col = '4';
        position.pos = 'GR';
        position.row = '0';
        
        nextPosition.type = 'GR';
        nextPosition.flag = true;
        nextPosition.col = '5';
        nextPosition.pos = 'GR';
		nextPosition.row = '0';

		Assert.assert(LOPAService.isTheSameEntity(position, nextPosition, LOPAService.HORIZONTAL_SEARCH));
	}

	@isTest static void testConsolidateSeatTwoRowGalleyBehindSeat() {
		List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row1 = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
		MB_RestResponseInfoModel.lopaInfo_lopaPos column1 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column1.flag = true;
		column1.type = 'GR';
		column1.row = '0';
		column1.col = 'L';
        column1.pos = 'G1';
		column1.maxCol = '8';
		column1.width = 1;
		row1.add(column1);

		MB_RestResponseInfoModel.lopaInfo_lopaPos column2 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column2.flag = true;
		column2.type = 'GR';
		column2.row = '0';
		column2.col = 'L';
        column2.pos = 'G2';
		column2.maxCol = '7';
		column2.width = 1;
		row1.add(column2);

		MB_RestResponseInfoModel.lopaInfo_lopaPos column3 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column3.flag = true;
		column3.type = 'GR';
		column3.row = '0';
		column3.col = 'LC';
        column3.pos = 'G3';
		column3.maxCol = '8';
		column3.width = 1;
		row1.add(column3);

		//List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row2 = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
		//column1 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		//column1.flag = true;
		//column1.type = 'GR';
		//column1.row = '1';
		//column1.col = 'LC';
		//row2.add(column1);

		//column2 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		//column2.flag = true;
		//column2.type = 'GR';
		//column2.row = '1';
		//column2.col = 'C';
		//row2.add(column2);

		//column3 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		//column3.flag = true;
		//column3.type = 'GR';
		//column3.row = '1';
		//column3.col = 'RC';
		//row2.add(column3);

		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();
		seatMatrix.add(row1);
		//seatMatrix.add(row2);

		System.debug('JK: seatMatrix - ' + seatMatrix);
		System.debug('JK: consolidateSeat - ' + LOPAService.consolidateSeat(seatMatrix));
		System.debug('JK: removeFalseFlagLOPAPos - ' + LOPAService.removeFalseFlagLOPAPos(LOPAService.consolidateSeat(seatMatrix)));
		List<MB_RestResponseInfoModel.lopaInfo_lopaPos> result = LOPAService.removeFalseFlagLOPAPos(LOPAService.consolidateSeat(seatMatrix));
		System.debug('result: ' + result);
		Assert.assertEquals(1, result.size());
		MB_RestResponseInfoModel.lopaInfo_lopaPos resultPos = result[0];
		//Assert.assert(resultPos != null);
		//Assert.assertEquals(3, resultPos.width);
		//Assert.assertEquals(1, resultPos.height);
		//Assert.assertEquals('3', resultPos.col);
	}

	@isTest static void testConsolidateSeatTwoRowGalleyBetweenSeat() {
		List<Integer> aisleSeatList = new List<Integer> {4, 6};
		List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row1 = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
		MB_RestResponseInfoModel.lopaInfo_lopaPos column1 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column1.flag = true;
		column1.type = 'GN';
		column1.row = '0';
		column1.col = '4';
		column1.pos = 'G1';
		column1.maxCol = '7';
		column1.width = 1;
		column1.setAisleSeatList(aisleSeatList);
		row1.add(column1);

		MB_RestResponseInfoModel.lopaInfo_lopaPos column2 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column2.flag = true;
		column2.type = 'GN';
		column2.row = '0';
		column2.col = '5';
        column2.pos = 'G2';
		column2.maxCol = '7';
		column2.width = 1;
		column2.setAisleSeatList(aisleSeatList);
		row1.add(column2);

		MB_RestResponseInfoModel.lopaInfo_lopaPos column3 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column3.flag = true;
		column3.type = 'GN';
		column3.row = '0';
		column3.col = '6';
        column3.pos = 'G3';
		column3.maxCol = '7';
		column3.width = 1;
		column3.setAisleSeatList(aisleSeatList);
		row1.add(column3);

		List<MB_RestResponseInfoModel.lopaInfo_lopaPos> row2 = new List<MB_RestResponseInfoModel.lopaInfo_lopaPos>();
		column1 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column1.flag = true;
		column1.type = 'GR';
		column1.row = '1';
		column1.col = '4';
        column1.pos = 'G1';
		column1.maxCol = '7';
		column1.width = 1;
		row2.add(column1);

		column2 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column2.flag = true;
		column2.type = 'GR';
		column2.row = '1';
		column2.col = '5';
        column2.pos = 'G2';
		column2.maxCol = '7';
		column2.width = 1;
		row2.add(column2);

		column3 = new MB_RestResponseInfoModel.lopaInfo_lopaPos();
		column3.flag = true;
		column3.type = 'GR';
		column3.row = '1';
		column3.col = '6';
       	column3.pos = 'G3';
		column3.maxCol = '7';
		column3.width = 1;
		row2.add(column3);

		List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>> seatMatrix = new List<List<MB_RestResponseInfoModel.lopaInfo_lopaPos>>();
		seatMatrix.add(row1);
		seatMatrix.add(row2);

		LOPAService.consolidateSeat(seatMatrix);
	}

	@isTest static void testGetMasterLOPAJSONStringHS_TUB(){
		MB_RestResponseInfoModel.lopaInfo_model lopaResponseModel = MockupData_Test.getMockUpLOPA_HSTUB();

		Assert.assertEquals(507, countLopaPosWithType(lopaResponseModel.lopaPos, new Set<String> {BE8_GlobalConstants.TYPE_SEAT}));
		Assert.assertEquals(18, countLopaPosWithType(lopaResponseModel.lopaPos, new Set<String> {BE8_GlobalConstants.TYPE_LAVATORY, 'LAF', 'LAR'}));
		// Remark: There is no lavatory in front of Row 31 which is contradict to the SeatGuru https://www.seatguru.com/airlines/Thai_Airways/Thai_Airways_Airbus_A380_new.php

	}

	private static Integer countLopaPosWithType(List<MB_RestResponseInfoModel.lopaInfo_lopaPos> seatList, Set<String> typeSet) {
		Integer count = 0;
		for (MB_RestResponseInfoModel.lopaInfo_lopaPos pos : seatList) {
			if (typeSet.contains(pos.type)) {
				count++;
			}
		}
		return count;
	}
}