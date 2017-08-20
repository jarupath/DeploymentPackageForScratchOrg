@isTest
global class Mock_TG_Pax_WS {
	public static final String MOCK_FIRST_NAME = 'JOHN';
	public static final String MOCK_LAST_NAME = 'WICK';
	public static final String MOCK_RLOC = 'RLOC';
	public static final Boolean MOCK_IS_CHILD = false;
	public static final Boolean MOCK_IS_INFANT = false;
	public static final Boolean MOCK_IS_STAFF_BOOKING = true;
	public static final Boolean MOCK_IS_STAFF_WAIT_LIST = false;
	public static final Boolean MOCK_IS_TICKET = true;
	public static final String MOCK_SEGMENT_STATUS = 'HK';
	public static final String MOCK_CABIN_CODE = 'C';
	public static final String MOCK_BOOKING_CLASS = 'W';
	public static final Boolean MOCK_HAS_SSR = true;
	public static final Boolean MOCK_IS_INBOUND = false;
	public static final Boolean MOCK_IS_OUTBOUND = false;
	public static final Boolean MOCK_IS_ASSIGNED_SEAT = true;
	public static final String MOCK_GROUP_NAME = 'WEESTOUR';
	public static final String MOCK_BOARD_POINT = 'BKK';
	public static final String MOCK_OFF_POINT = 'CDG';
	    
	public static void addMockSSR(TG_PaxSSR_Result.IFLIRR pData, Integer pIndex, String pFirstName, String pLastName, String pRloc, String pCode, String pTxt){
		TG_PaxSSR_Result.SSROutput output = new TG_PaxSSR_Result.SSROutput();
		pData.BodyDetail[0].SSROutput[pIndex] = output;
		output.SSRCode = pCode;
		output.FreeTxt = pTxt;
		output.TravellerFirstName = pFirstName;
		output.TravellerSurname = pLastName;
		output.RecordLocator = pRloc;

		if('FQTV' == pCode){
			output.FQTInfo = new TG_PaxSSR_Result.FQTInfo_element();
			output.FQTInfo.AirlineCode = 'TG';
			output.FQTInfo.Carrier = 'TG';
			output.FQTInfo.MemberNumber = 'ROP111';
			output.FQTInfo.TierLevel = 'BASE';
			output.FQTInfo.NumberOfService = 1;
		}
	}

	global class MockSSR1 implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	      TG_PaxSSR_Result.IFLIRR result = new TG_PaxSSR_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSSR_Result.Segment[1];
	      TG_PaxSSR_Result.Segment bodyDetail = new TG_PaxSSR_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;

		  bodyDetail.SSROutput = new TG_PaxSSR_Result.SSROutput[5];
	      Mock_TG_Pax_WS.addMockSSR(result, 0, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'MAAS', 'VIP');
	      Mock_TG_Pax_WS.addMockSSR(result, 1, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'LANG', 'LANG');
	      Mock_TG_Pax_WS.addMockSSR(result, 2, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'WCHR', 'WCHR');
	      Mock_TG_Pax_WS.addMockSSR(result, 3, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'UMNR', 'UMNR');
	      Mock_TG_Pax_WS.addMockSSR(result, 4, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'DEAF', 'DEAF');

	      response.put('response_x', result);
	    }
	}// End MockSSR1

	global class MockSSR2 implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	      TG_PaxSSR_Result.IFLIRR result = new TG_PaxSSR_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSSR_Result.Segment[1];
	      TG_PaxSSR_Result.Segment bodyDetail = new TG_PaxSSR_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;

		  bodyDetail.SSROutput = new TG_PaxSSR_Result.SSROutput[5];	      
	      Mock_TG_Pax_WS.addMockSSR(result, 0, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'MEDA', 'MEDA');
	      Mock_TG_Pax_WS.addMockSSR(result, 1, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'DEPA', 'DEPA');
	      Mock_TG_Pax_WS.addMockSSR(result, 2, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'DEPU', 'DEPU');
	      Mock_TG_Pax_WS.addMockSSR(result, 3, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'AVIH', 'AVIH');
	      Mock_TG_Pax_WS.addMockSSR(result, 4, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'PETC', 'PETC');
	      
	      response.put('response_x', result);
	    }
	}// End MockSSR2

	global class MockSSR3 implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	      TG_PaxSSR_Result.IFLIRR result = new TG_PaxSSR_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSSR_Result.Segment[1];
	      TG_PaxSSR_Result.Segment bodyDetail = new TG_PaxSSR_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;

		  bodyDetail.SSROutput = new TG_PaxSSR_Result.SSROutput[5];	      
	      Mock_TG_Pax_WS.addMockSSR(result, 0, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'WEAP', 'WEAP');
	      Mock_TG_Pax_WS.addMockSSR(result, 1, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'CBBG', 'CBBG');
	      Mock_TG_Pax_WS.addMockSSR(result, 2, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'EXST', 'EXST');
	      Mock_TG_Pax_WS.addMockSSR(result, 3, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'COUR', 'COUR');
	      Mock_TG_Pax_WS.addMockSSR(result, 4, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'SPML', 'SPML');

	      response.put('response_x', result);
	    }
	}// End MockSSR3

	global class MockSSR4 implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	      TG_PaxSSR_Result.IFLIRR result = new TG_PaxSSR_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSSR_Result.Segment[1];
	      TG_PaxSSR_Result.Segment bodyDetail = new TG_PaxSSR_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;

		  bodyDetail.SSROutput = new TG_PaxSSR_Result.SSROutput[5];
	      Mock_TG_Pax_WS.addMockSSR(result, 0, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'MAAS', 'VVIP');
	      Mock_TG_Pax_WS.addMockSSR(result, 1, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'DOCS', 'P/CHN/E07530195/CHN/27MAR82/F/06MAR24/CHEN/HUIJUAN');
	      Mock_TG_Pax_WS.addMockSSR(result, 2, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'CTCE', 'ROBERT.GOETZ//BAMCASES.COM');
	      Mock_TG_Pax_WS.addMockSSR(result, 3, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'CTCM', '08964943000/DE');
	      Mock_TG_Pax_WS.addMockSSR(result, 4, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'FQTV', '');
	      
	      response.put('response_x', result);
	    }
	}// End MockSSR4

	global class MockSSRINFT implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	      TG_PaxSSR_Result.IFLIRR result = new TG_PaxSSR_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSSR_Result.Segment[1];
	      TG_PaxSSR_Result.Segment bodyDetail = new TG_PaxSSR_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;

		  bodyDetail.SSROutput = new TG_PaxSSR_Result.SSROutput[1];
	      Mock_TG_Pax_WS.addMockSSR(result, 0, MOCK_FIRST_NAME, MOCK_LAST_NAME, MOCK_RLOC, 'INFT', 'PONGSANG/KUNANYA 31JAN16');

	      response.put('response_x', result);
	    }
	}// End MockSSR5

	global class MockSeat implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
			System.debug('SJ : MockTest');
	      TG_PaxSeat_Result.IFLIRR result = new TG_PaxSeat_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSeat_Result.Segment[1];
	      TG_PaxSeat_Result.Segment bodyDetail = new TG_PaxSeat_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;
	      bodyDetail.SeatOutput = new TG_PaxSeat_Result.SeatOutput[1];
	      TG_PaxSeat_Result.SeatOutput seatOutput = new TG_PaxSeat_Result.SeatOutput();
	      bodyDetail.SeatOutput[0] = seatOutput;
	      bodyDetail.SeatOutput[0].TravellerFirstName = MOCK_FIRST_NAME;
	      bodyDetail.SeatOutput[0].TravellerSurname = MOCK_LAST_NAME;
	      bodyDetail.SeatOutput[0].RecordLocator = MOCK_RLOC;
	      bodyDetail.SeatOutput[0].SeatRow = 1;
          bodyDetail.SeatOutput[0].SeatColumn = 'A';
          bodyDetail.SeatOutput[0].CheckInSeat = '014A';
    
			System.debug('SJ : MockTest :' + result);
	      response.put('response_x', result);
	    }
	}// End MockSeat

	global class MockIllegalCheckInSeat implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	      TG_PaxSeat_Result.IFLIRR result = new TG_PaxSeat_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxSeat_Result.Segment[1];
	      TG_PaxSeat_Result.Segment bodyDetail = new TG_PaxSeat_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;
	      bodyDetail.SeatOutput = new TG_PaxSeat_Result.SeatOutput[1];
	      TG_PaxSeat_Result.SeatOutput seatOutput = new TG_PaxSeat_Result.SeatOutput();
	      bodyDetail.SeatOutput[0] = seatOutput;
	      bodyDetail.SeatOutput[0].TravellerFirstName = MOCK_FIRST_NAME;
	      bodyDetail.SeatOutput[0].TravellerSurname = MOCK_LAST_NAME;
	      bodyDetail.SeatOutput[0].RecordLocator = MOCK_RLOC;
	      bodyDetail.SeatOutput[0].SeatRow = 1;
          bodyDetail.SeatOutput[0].SeatColumn = 'A';
          bodyDetail.SeatOutput[0].CheckInSeat = '014A/014A';
    
	      response.put('response_x', result);
	    }
	}// End MockSeat

	global class MockPax implements WebServiceMock {
		global void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

			System.debug('SJ : MockPax');

	      TG_PaxAll_Result.IFLIRR result = new TG_PaxAll_Result.IFLIRR();
	      result.BodyDetail = new TG_PaxAll_Result.Segment[1];
	      TG_PaxAll_Result.Segment bodyDetail = new TG_PaxAll_Result.Segment();
	      result.BodyDetail[0] = bodyDetail;
	      bodyDetail.BoardPoint = MOCK_BOARD_POINT;
	      bodyDetail.OffPoint = MOCK_OFF_POINT;
	      bodyDetail.TotalByCabin = new TG_PaxAll_Result.TotalByCabin[2];
	      TG_PaxAll_Result.TotalByCabin c1 = new TG_PaxAll_Result.TotalByCabin();
		  TG_PaxAll_Result.TotalByCabin c2 = new TG_PaxAll_Result.TotalByCabin();
		  bodyDetail.TotalByCabin[0] = c1;
		  bodyDetail.TotalByCabin[1] = c2;
		  c1.CabinCode = 'C'; c1.Total = 23;
		  c2.CabinCode = 'Y'; c2.Total = 216;

	      bodyDetail.DefaultOutput = new TG_PaxAll_Result.DefaultOutput[1];
	      TG_PaxAll_Result.DefaultOutput o = new TG_PaxAll_Result.DefaultOutput();
	      bodyDetail.DefaultOutput[0] = o;
	      o.Indicator = new TG_PaxAll_Result.Indicator();
	      o.Indicator.SSR = MOCK_HAS_SSR;
	      o.Indicator.Inbound = MOCK_IS_INBOUND;
	      o.Indicator.Outbound = MOCK_IS_OUTBOUND;
	      o.Indicator.AssignedSeat = MOCK_IS_ASSIGNED_SEAT;

	      o.TravellerFirstName = MOCK_FIRST_NAME;
	      o.TravellerSurname = MOCK_LAST_NAME;
	      o.RecordLocator = MOCK_RLOC;
	      o.IsStaffWaitlist = MOCK_IS_STAFF_WAIT_LIST;
	      o.SegmentStatus = MOCK_SEGMENT_STATUS;
	      o.StaffBooking = MOCK_IS_STAFF_BOOKING;
	      o.Child = MOCK_IS_CHILD;
	      o.IsTicket = MOCK_IS_TICKET;
	      o.Infant = MOCK_IS_INFANT;
	      o.BookingClass = MOCK_BOOKING_CLASS;
	      o.CabinCode = MOCK_CABIN_CODE;
	      o.GroupName = MOCK_GROUP_NAME;

	      response.put('response_x', result);
	    }
	}// End MockPax
}