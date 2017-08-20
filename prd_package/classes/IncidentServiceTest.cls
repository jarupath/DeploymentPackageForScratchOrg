@isTest
private class IncidentServiceTest {

	@isTest static void testCreatePassengerSObjectForChangeSeat() {
		Passenger__c passenger = MockupData_Test.createPassenger(null, 'F');
		insert passenger;
		List<MB_RestRequestInfoModel.incident_changeSeatMem> chSeat = new List<MB_RestRequestInfoModel.incident_changeSeatMem>();
		MB_RestRequestInfoModel.incident_changeSeatMem eachMem = new MB_RestRequestInfoModel.incident_changeSeatMem();
		eachMem.fromSeat = '11A';
		eachMem.toSeat = '12A';
		eachMem.fromClass = 'F';
		eachMem.toClass = 'C';
		chSeat.add(eachMem);
		IncidentService.createPassengerSObjectForChangeSeat(new MB_RestRequestInfoModel.incident_model(), chSeat, passenger.Id);

		List<MB_RestRequestInfoModel.incident_compensation> compenMem = new List<MB_RestRequestInfoModel.incident_compensation>();
		MB_RestRequestInfoModel.incident_compensation eachCompen = new MB_RestRequestInfoModel.incident_compensation();
		eachCompen.fromSeat = '11A';
		eachCompen.toSeat = '12A';
		eachCompen.fromClass = 'F';
		eachCompen.toClass = 'C';
		compenMem.add(eachCompen);
		IncidentService.createPassengerSObjectForChangeSeat(new MB_RestRequestInfoModel.incident_model(), compenMem, passenger.Id);
	}
}