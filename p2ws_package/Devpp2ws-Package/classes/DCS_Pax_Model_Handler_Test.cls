@isTest
private class DCS_Pax_Model_Handler_Test {
	
	@isTest static void test_getRegulatoryInfo() {
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		WS_DCS_Pax_Model.cls_regulatoryInfo reginfo = DCS_Pax_Model_Handler.getRegulatoryInfo(paxmodel);
		System.assertNotEquals(null, reginfo, 'reginfo not equals null');

		reginfo = DCS_Pax_Model_Handler.getRegulatoryInfo(null);
		System.assertEquals(null, reginfo, 'reginfo equals null');
	}
	
	@isTest static void test_getTravelerDocument() {
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		WS_DCS_Pax_Model.cls_travelerDocuments travellerDocuments = DCS_Pax_Model_Handler.getTravelerDocument(paxmodel);
		System.assertNotEquals(null, travellerDocuments, 'travellerDocuments not equals null');

		travellerDocuments = DCS_Pax_Model_Handler.getTravelerDocument(null);
		System.assertEquals(null, travellerDocuments, 'travellerDocuments equals null');
	}

	@isTest static void test_getTravelerDocumentDetails(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		WS_DCS_Pax_Model.cls_travelerDocumentDetails travelerDocumentDetails = DCS_Pax_Model_Handler.getTravelerDocumentDetails(paxmodel);
		System.assertNotEquals(null, travelerDocumentDetails, 'travelerDocumentDetails not equals null');

		travelerDocumentDetails = DCS_Pax_Model_Handler.getTravelerDocumentDetails(null);
		System.assertEquals(null, travelerDocumentDetails, 'travelerDocumentDetails equals null');
	}

	@isTest static void test_paxFirstname(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String fname = DCS_Pax_Model_Handler.paxFirstname(paxmodel);
		System.assertEquals('BYUNGWOOK', fname, 'fname should be BYUNGWOOK');

		fname = DCS_Pax_Model_Handler.paxFirstname(null);
		System.assertEquals(null, fname, 'fname should be null');
	}
	
	@isTest static void test_paxLastname(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String lname = DCS_Pax_Model_Handler.paxLastname(paxmodel);
		System.assertEquals('AHN', lname, 'lname should be AHN');

		lname = DCS_Pax_Model_Handler.paxLastname(null);
		System.assertEquals(null, lname, 'lname should be null');
	}

	@isTest static void test_paxTitle(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String title = DCS_Pax_Model_Handler.paxTitle(paxmodel);
		System.assertEquals('MR', title, 'title should be MR');

		title = DCS_Pax_Model_Handler.paxTitle(null);
		System.assertEquals(null, title, 'title should be null');		
	}

	@isTest static void test_paxGroupname(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String groupname = DCS_Pax_Model_Handler.paxGroupname(paxmodel);
		System.assertEquals(null, groupname, 'groupname should be null');
	}

	@isTest static void test_paxPNR(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String pnr = DCS_Pax_Model_Handler.paxPNR(paxmodel);
		System.assertEquals('UI2BIW', pnr, 'pnr should be UI2BIW');

		pnr = DCS_Pax_Model_Handler.paxPNR(null);
		System.assertEquals(null, pnr, 'pnr should be null');		
	}

	@isTest static void test_paxSegmentStatus(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String segment = DCS_Pax_Model_Handler.paxSegmentStatus(paxmodel);
		System.assertEquals('HK', segment, 'segment should be HK');

		segment = DCS_Pax_Model_Handler.paxSegmentStatus(null);
		System.assertEquals(null, segment, 'segment should be null');		
	}

	@isTest static void test_paxGender(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String gender = DCS_Pax_Model_Handler.paxGender(paxmodel);
		System.assertEquals('M', gender, 'gender should be M');

		gender = DCS_Pax_Model_Handler.paxGender(null);
		System.assertEquals(null, gender, 'gender should be null');		
	}

	@isTest static void test_paxBookingClass(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String bookingclass = DCS_Pax_Model_Handler.paxBookingClass(paxmodel);
		System.assertEquals('K', bookingclass, 'bookingclass should be K');

		bookingclass = DCS_Pax_Model_Handler.paxBookingClass(null);
		System.assertEquals(null, bookingclass, 'bookingclass should be null');
	}

	@isTest static void test_paxCheckinCabinCode(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String legcabincode = DCS_Pax_Model_Handler.paxCheckinCabinCode(paxmodel);
		System.assertEquals('Y', legcabincode, 'bookingclass should be Y');

		legcabincode = DCS_Pax_Model_Handler.paxCheckinCabinCode(null);
		System.assertEquals(null, legcabincode, 'bookingclass should be null');		
	}

	@isTest static void test_paxBookingCabinCode(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String bookedcabincode = DCS_Pax_Model_Handler.paxBookingCabinCode(paxmodel);
		System.assertEquals('Y', bookedcabincode, 'bookingclass should be Y');

		bookedcabincode = DCS_Pax_Model_Handler.paxBookingCabinCode(null);
		System.assertEquals(null, bookedcabincode, 'bookingclass should be null');		
	}

	@isTest static void test_paxSeat(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String paxseat = DCS_Pax_Model_Handler.paxSeat(paxmodel);
		System.assertEquals('053K', paxseat, 'paxseat should be 053K');

		paxseat = DCS_Pax_Model_Handler.paxSeat(null);
		System.assertEquals(null, paxseat, 'paxseat should be null');		
	}

	@isTest static void test_paxSeatStatus(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String paxseatstatus = DCS_Pax_Model_Handler.paxSeatStatus(paxmodel);
		System.assertEquals('GUA', paxseatstatus, 'paxseat should be GUA');

		paxseatstatus = DCS_Pax_Model_Handler.paxSeatStatus(null);
		System.assertEquals(null, paxseatstatus, 'paxseat should be null');
	}

	@isTest static void test_paxFFPCarrier(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String ffpCarrier = DCS_Pax_Model_Handler.paxFFPCarrier(paxmodel);
		System.assertEquals('TG', ffpCarrier, 'FFP carrier should be TG');

		ffpCarrier = DCS_Pax_Model_Handler.paxFFPCarrier(null);
		System.assertEquals(null, ffpCarrier, 'FFP carrier should be null');
	}

	@isTest static void test_paxFFPTier(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String ffpTier = DCS_Pax_Model_Handler.paxFFPTier(paxmodel);
		System.assertEquals('BASE', ffpTier, 'FFP tier should be equal to BASE');

		ffpTier = DCS_Pax_Model_Handler.paxFFPTier(null);
		System.assertEquals(null, ffpTier, 'FFP tier should be equal to null');
	}

	@isTest static void test_paxFFPNumber(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String ffpNumber = DCS_Pax_Model_Handler.paxFFPNumber(paxmodel);
		System.assertEquals('GM44817', ffpNumber, 'FFP number should be GM44817');

		ffpNumber = DCS_Pax_Model_Handler.paxFFPNumber(null);
		System.assertEquals(null, ffpNumber, 'FFP number should be null');
	}

	@isTest static void test_paxDocType(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String doctype = DCS_Pax_Model_Handler.paxDocType(paxmodel);
		System.assertEquals('P', doctype, 'doctype should be P');

		doctype = DCS_Pax_Model_Handler.paxDocType(null);
		System.assertEquals(null, doctype, 'doctype should be null');
	}

	@isTest static void test_paxDocNumber(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String docno = DCS_Pax_Model_Handler.paxDocNumber(paxmodel);
		System.assertEquals('M10037216', docno, 'docno should be M10037216');

		docno = DCS_Pax_Model_Handler.paxDocNumber(null);
		System.assertEquals(null, docno, 'docno should be null');
	}

	@isTest static void test_paxDocIssuingCountry(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String issuingcountry = DCS_Pax_Model_Handler.paxDocIssuingCountry(paxmodel);
		System.assertEquals('KOR', issuingcountry, 'docno should be KOR');

		issuingcountry = DCS_Pax_Model_Handler.paxDocIssuingCountry(null);
		System.assertEquals(null, issuingcountry, 'docno should be null');
	}

	@isTest static void test_paxNationality(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String nationality = DCS_Pax_Model_Handler.paxNationality(paxmodel);
		System.assertEquals('KOR', nationality, 'nationality should be KOR');

		nationality = DCS_Pax_Model_Handler.paxNationality(null);
		System.assertEquals(null, nationality, 'nationality should be null');
	}

	@isTest static void test_paxDOB(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String dob = DCS_Pax_Model_Handler.paxDOB(paxmodel);
		System.assertEquals('1988-09-14T00:00:00.000Z', dob, 'dob should be 1988-09-14T00:00:00.000Z');

		dob = DCS_Pax_Model_Handler.paxDOB(null);
		System.assertEquals(null, dob, 'dob should be null');
	}

	@isTest static void test_paxConnectingFlightNumber(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String fltno = DCS_Pax_Model_Handler.paxConnectingFlightNumber(paxmodel);
		System.assertEquals('TG607', fltno, 'fltno should be TG607');

		fltno = DCS_Pax_Model_Handler.paxConnectingFlightNumber(null);
		System.assertEquals(null, fltno, 'fltno should be null');
	}

	@isTest static void test_paxConnectingFlightDate(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String fltdate = DCS_Pax_Model_Handler.paxConnectingFlightDate(paxmodel);
		System.assertEquals('2017-07-05', fltdate, 'fltdate should be 2017-07-05');

		fltdate = DCS_Pax_Model_Handler.paxConnectingFlightDate(null);
		System.assertEquals(null, fltdate, 'fltdate should be null');
	}

	@isTest static void test_paxConnectingFlightSTD(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String fltstd = DCS_Pax_Model_Handler.paxConnectingFlightSTD(paxmodel);
		System.assertEquals('2017-07-05T20:45:00.000Z', fltstd, 'fltstd should be 2017-07-05T20:45:00');

		fltstd = DCS_Pax_Model_Handler.paxConnectingFlightSTD(null);
		System.assertEquals(null, fltstd, 'fltstd should be null');
	}

	@isTest static void test_paxConnectingFlightSegment(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String fltsegment = DCS_Pax_Model_Handler.paxConnectingFlightSegment(paxmodel);
		System.assertEquals('HKG-BKK', fltsegment, 'fltsegment should be HKG-BKK');

		fltsegment = DCS_Pax_Model_Handler.paxConnectingFlightSegment(null);
		System.assertEquals(null, fltsegment, 'fltsegment should be null');
	}

	@isTest static void test_paxTicketNumber(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String tktno = DCS_Pax_Model_Handler.paxTicketNumber(paxmodel);
		System.assertEquals(null, tktno, 'tktno should be null');
	}

	@isTest static void test_paxTicketType(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String tkttype = DCS_Pax_Model_Handler.paxTicketType(paxmodel);
		System.assertEquals(null, tkttype, 'tkttype should be null');
	}

	@isTest static void test_paxBoardPoint(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String boardpoint = DCS_Pax_Model_Handler.paxBoardPoint(paxmodel);
		System.assertEquals('BKK', boardpoint, 'boardpoint should be BKK');

		boardpoint = DCS_Pax_Model_Handler.paxBoardPoint(null);
		System.assertEquals(null, boardpoint, 'boardpoint should be null');
	}

	@isTest static void test_paxOffPoint(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String offpoint = DCS_Pax_Model_Handler.paxOffPoint(paxmodel);
		System.assertEquals('ICN', offpoint, 'offpoint should be ICN');

		offpoint = DCS_Pax_Model_Handler.paxOffPoint(null);
		System.assertEquals(null, offpoint, 'offpoint should be null');
	}

	@isTest static void test_paxFltDate(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String fltdate = DCS_Pax_Model_Handler.paxFltDate(paxmodel);
		System.assertEquals('2017-06-03', fltdate, 'fltdate should be 2017-06-03');

		fltdate = DCS_Pax_Model_Handler.paxFltDate(null);
		System.assertEquals(null, fltdate, 'fltdate should be null');
	}

	@isTest static void test_paxDCSPaxUniqueId(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		String uniqueCustomerId = DCS_Pax_Model_Handler.paxDCSPaxUniqueId(paxmodel);
		System.assertEquals('200219770005BDB0', uniqueCustomerId, 'uniqueCustomerId should be 200219770005BDB0');	

		uniqueCustomerId = DCS_Pax_Model_Handler.paxDCSPaxUniqueId(null);
		System.assertEquals(null, uniqueCustomerId, 'uniqueCustomerId should be null');	
	}

	@isTest static void test_paxSSRList(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> ssrlist = DCS_Pax_Model_Handler.paxSSRList(paxmodel);
		System.assertEquals(null, ssrlist, 'ssrlist should be null');	
	}

	@isTest static void test_paxCustomerStatusInfoList(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		List<WS_DCS_Pax_Model.cls_statusInfo> statuslist = DCS_Pax_Model_Handler.paxCustomerStatusInfoList(paxmodel);
		System.assertNotEquals(null, statuslist, 'statuslist should not be null');

		statuslist = DCS_Pax_Model_Handler.paxCustomerStatusInfoList(null);
		System.assertEquals(null, statuslist, 'statuslist should be null');
	}

	@isTest static void test_isDCSModelNull(){
		CSE_SOAPDCSPax_WS ws = new CSE_SOAPDCSPax_WS();
		String response = Mockup_DCS_Pax.getPSTDCSPaxResponse();
		WS_DCS_Pax_Model dcsModel = ws.getPaxModel(response);
		Boolean isnull = DCS_Pax_Model_Handler.isDCSModelNull(dcsModel);
		System.assertEquals(false, isnull, 'The check null returned value should be false');
	}

	@isTest static void test_isDCSModelFlightGroupNull(){
		CSE_SOAPDCSPax_WS ws = new CSE_SOAPDCSPax_WS();
		String response = Mockup_DCS_Pax.getPSTDCSPaxResponse();
		WS_DCS_Pax_Model dcsModel = ws.getPaxModel(response);
		Boolean isnull = DCS_Pax_Model_Handler.isDCSModelFlightGroupNull(dcsModel);
		System.assertEquals(false, isnull, 'The check null returned value should be false');
	}

	@isTest static void test_isDCSModelCustomerLevelNull(){
		CSE_SOAPDCSPax_WS ws = new CSE_SOAPDCSPax_WS();
		String response = Mockup_DCS_Pax.getPSTDCSPaxResponse();
		WS_DCS_Pax_Model dcsModel = ws.getPaxModel(response);
		Boolean isnull = DCS_Pax_Model_Handler.isDCSModelCustomerLevelNull(dcsModel);
		System.assertEquals(false, isnull, 'The check null returned value should be false');
	}

	@isTest static void test_isDCSModelCustomerLevelEmpty(){
		CSE_SOAPDCSPax_WS ws = new CSE_SOAPDCSPax_WS();
		String response = Mockup_DCS_Pax.getPSTDCSPaxResponse();
		WS_DCS_Pax_Model dcsModel = ws.getPaxModel(response);
		Boolean isnull = DCS_Pax_Model_Handler.isDCSModelCustomerLevelEmpty(dcsModel);
		System.assertEquals(false, isnull, 'The check null returned value should be false');
	}

	@isTest static void test_getCustomerLevelList(){
		CSE_SOAPDCSPax_WS ws = new CSE_SOAPDCSPax_WS();
		String response = Mockup_DCS_Pax.getPSTDCSPaxResponse();
		WS_DCS_Pax_Model dcsModel = ws.getPaxModel(response);
		List<WS_DCS_Pax_Model.cls_customerLevel> dcsPaxList = DCS_Pax_Model_Handler.getCustomerLevelList(dcsModel);

		System.assertNotEquals(null, dcsPaxList, 'returned dcs pax list should not be null');
		System.assertEquals(false, dcsPaxList.isEmpty(), 'returned dcs pax should not be empty');
		System.assertEquals(5, dcsPaxList.size(), 'return dcs pax list size should be equal to 5');

		dcsPaxList = DCS_Pax_Model_Handler.getCustomerLevelList(null);
		System.assertEquals(null, dcsPaxList, 'returned dcs pax list should be null');
	}
}