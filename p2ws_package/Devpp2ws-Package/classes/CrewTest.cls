@isTest
private class CrewTest {

	/* This function is used to test for upsert Crew record from file */
	@isTest static void testUpsertCrew() {
		//Flight__c flight1 = MockupData_Test.createFlight('0998', '01Oct16', 1);
		//insert flight1;
		Crew__c crew = new Crew__c(
			Crew_First_Name__c = 'Earth',
			Crew_Last_Name__c = 'Pho-ngoen',
			Personel_Id__c = '00001',
			Rank__c = 'FC');
		upsert crew Personel_Id__c;
		Crew__c crew2 = new Crew__c(
			Crew_First_Name__c = 'Earth',
			Crew_Last_Name__c = 'Pho-ngoen',
			Personel_Id__c = '00001',
			Rank__c = 'FC');
		upsert crew2 Personel_Id__c;
		List<Crew__c> getcrewList = [select Id from Crew__c where Personel_Id__c='00001'];
		Assert.assertEquals(1, getcrewList.size());
		Crew__c getcrew = [select Id from Crew__c where Personel_Id__c='00001'];
		Assert.assertNotEquals(null, getcrew);


	}

	/* this function is used to test the case that there are crew that have a duty on multiple flight - 
		For the result, dupplication error should not occured */
	@isTest static void testUpsertDupplicateCrewOnFlight(){
		List<Crew_List__c> crewList = new List<Crew_List__c>();
		crewList.add(MockupData_Test.createCrewList('Earth Pho-ngoen', 'TG0001_01Jan16_1', 'CR0001', 'CR0001_TG0001_01Jan16_1'));
		crewList.add(MockupData_Test.createCrewList('Earth Pho-ngoen', 'TG0001_02Jan16_1', 'CR0001', 'CR0001_TG0002_02Jan16_1'));
		insert crewList;
		List<Crew__c> crew = [SELECT Id, Name FROM Crew__c WHERE Personel_Id__c = 'CR0001'];
		Assert.assertEquals(1, crew.size());
	}

	/* this function is used to test for the correction of crew record that is generated from crewlist */
	@isTest static void testCreateCrewFromCrewList(){
		Crew_List__c crewlist = MockupData_Test.createCrewList('Earth Pho-ngoen', 'TG0001_01Jan16_1', 'CR0001', 'CR0001_TG0001_01Jan16_1');
		Crew__c crewMock = new Crew__c(Name = 'Earth Pho-ngoen', Crew_First_Name__c = 'Earth', Crew_Last_Name__c = 'Pho-ngoen', Personel_Id__c = 'CR0001', Rank__c = 'FC');
		Crew__c crewFromMethod = CrewonFlightService.createCrew(crewlist);
		Assert.assertEquals(crewMock, crewFromMethod);
	}

	/* this function is used to test for the correction of flight record that is generated from crewlist's flight external id */
	@isTest static void testCreateFlightFromCrewlistInformation(){
		String flightExgternalId = 'TG0001_01Jan16_1';
		String[] flightinfo = flightExgternalId.split('_');
		Flight__c flightMock = new Flight__c(Name = flightinfo[0].remove('TG'), Flight_Date_UTC__c = flightinfo[1], Leg_Number__c = 1, Flight_External_ID__c = flightExgternalId, Integration_Source__c = '2');
		Flight__c flightFromMethod = CrewonFlightService.createFlight(flightinfo, flightExgternalId);
		Assert.assertEquals(flightMock, flightFromMethod);
	}

	/* this function is used to test for the correctness of crewlist record that returned from the inputed model */
	@isTest static void testCreateCrewListFromDataModel(){
		String returnFromWS = '<ns0:CrewOnFlightQueryRes xmlns="http://xml.thaiairways.com/crew/enquiry/crewonflight/CrewOnFlightQuery/v1_0" xmlns:ns0="http://xml.thaiairways.com/crew/enquiry/crewonflight" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/crew/enquiry/crewonflight/v1_0" xmlns:tns1="http://ws.thaiairways.com/crew/enquiry/crewonflight">    <return>        <actrank>FC</actrank>        <arrStation>HKG</arrStation>        <crewimage/>        <depDateLT/>        <depStation>BKK</depStation>        <dutycode>FLY</dutycode>        <evaLastDate>-</evaLastDate>        <evaNum>-</evaNum>        <firstname>PASAKORN</firstname>        <fltDateUTC>22Nov16</fltDateUTC>        <fltNo>0628</fltNo>        <lastname>KANLONG</lastname>        <nickname/>        <posfly>FC</posfly>        <rank>FC</rank>        <returnfltdate>23Nov16</returnfltdate>        <returnfltno>0657</returnfltno>        <seqNo>1</seqNo>        <staffno>37223</staffno>        <thirdlang/>    </return></ns0:CrewOnFlightQueryRes>';
		WS_CrewonFlightModel inputMethod = (WS_CrewonFlightModel)new XMLSerializer().deSerialize(returnFromWS, WS_CrewonFlightModel.class, new Set<String>{'return'});
		System.debug('Input Method: ' + inputMethod);
		String flightExgternalId = 'TG0628_22Nov16_1';
		List<Crew_List__c> crewlistMock = new List<Crew_List__c>();
		crewlistMock.add(new Crew_List__c(
			Name = 'PASAKORN KANLONG', 
			Acting_Rank__c = 'FC', 
			CrewList_Temp__c = '37223_TG0628_22Nov16_1', 
			Crew_Temp__c = '37223', 
			SEQ_No__c = 1, 
			Duty_Code__c = 'FLY',
			Flight_Temp__c = 'TG0628_22Nov16_1',
			POS_Fly__c = 'FC',
			Rank__c = 'FC', 
			Duty_Assignment__c = null,
			Nickname__c = null,
			Gender__c = null,
			No_of_Eval__c = 0,
			Language__c = null,
			returnfltno__c = 'TG657',
			returnfltdate__c = '2016-11-23'));
		List<Crew_List__c> crewlistFromMethod = CrewonFlightService.getCrewListFromDataModel(inputMethod, flightExgternalId);
		System.debug('DEBUG - testCreateCrewListFromDataModel');
		System.debug('Expect: ' + JSON.serialize(crewlistMock));
		System.debug('actual: ' + JSON.serialize(crewlistFromMethod));
		Assert.assertEquals(crewlistMock, crewlistFromMethod);
	}
}