public without sharing class DCS_Pax_Record_Service {
	private static String accountQuery = 'SELECT Id, Customer_External_Id__c, Customer_External_Id_Trim__c FROM Account';
	private static String membershipQuery = 'SELECT Id, EXTMember__c, AccountId__r FROM Membership__c WHERE EXTMember__c IN :';
	@testVisible static Map<String, Account> sfdcAccountMap;
	@testVisible static Map<String, Membership__c> sfdcMembershipMap;

	/**
										Manage Account
	*/

	public static Map<String, Account> getSFDCAccountMap(Set<String> keySet){
		if(sfdcAccountMap == null || !isContainsAllKey(sfdcAccountMap, keySet)){
			querySFDCAccountMap(keySet);
		}
		return sfdcAccountMap;
	}

	public static Map<String, Account> getSFDCAccountMap(){
		return sfdcAccountMap;
	}

	public static void querySFDCAccountMap(Set<String> keySet){
		if(sfdcAccountMap == null) sfdcAccountMap = new Map<String, Account>();
		Set<String> fields = BE8_GlobalUtility.getAllCreateableFields('Account');
		BE8_SoqlBuilder soqlBuilder = new BE8_SoqlBuilder('Account');
		soqlBuilder.addField(fields);
		soqlBuilder.addCondition('Customer_External_Id_Trim__c IN :keySet');
		for(Account acc : Database.query(soqlBuilder.getQueryStr())){
			sfdcAccountMap.put(acc.Customer_External_Id_Trim__c, acc);
		}
	}

	public static Boolean isContainsAllKey(Map<String, Account> sfdcAccountMap, Set<String> keySet){
		for(String key : keySet){
			if(!sfdcAccountMap.containsKey(key)) return false;
		}
		return true;
	}

	public static Map<String, Account> concreteAccount(Map<String, Passenger__c> paxmap, Map<String, Passenger__c> dcspaxmap){
		Map<String, Account> accToBeInsertMap = new Map<String, Account>();
		Map<String, Passenger__c> tempPaxMap = new Map<String, Passenger__c>();
		if(dcspaxmap != null && !dcspaxmap.isEmpty()){
			for(String key : dcspaxmap.keySet()){
				if(paxmap != null && !paxmap.isEmpty() && paxmap.containsKey(key) && paxmap.get(key).AccountId__c != null){
					dcspaxmap.get(key).AccountId__c = paxmap.get(key).AccountId__c;
					accToBeInsertMap.put(key, createAccountFromPax(dcspaxmap.get(key), true));
				}
				else if(isReadyForCreateAccount(dcspaxmap.get(key))) tempPaxMap.put(key, dcspaxmap.get(key));
			}

			if(tempPaxMap != null && !tempPaxMap.isEmpty()){
				querySFDCAccountMap(getCustomerExternalIdTrimFromAccount(tempPaxMap.values()));
				for(String key : tempPaxMap.keySet()){
					accToBeInsertMap.put(key, createAccountFromPax(tempPaxMap.get(key)));
				}	
			}
		}
		if(accToBeInsertMap != null && !accToBeInsertMap.isEmpty()) return accToBeInsertMap;
		return null;
	}

	@testVisible
	private static Boolean isReadyForCreateAccount(Passenger__c pax){
		return pax.First_Name__c != null && pax.Last_Name__c != null && pax.Date_of_Birth__c != null && pax.Travel_Document_Number__c != null;
	}

   	@testVisible
	private static Account createAccountFromPax(Passenger__c pax){
		return createAccountFromPax(pax, false);
	}

   	@testVisible
	private static Account createAccountFromPax(Passenger__c pax, Boolean isUpdateCustomerExternalId){
		Account acc = new Account();
		acc.Name = pax.Name;
		if(isUpdateCustomerExternalId) acc.Customer_External_Id__c = DCS_Pax_Util_Service.getCustomerProfileExtId(pax);
		acc.First_Name__c = pax.First_Name__c;
		acc.Salutation__c = pax.Salutation__c;
		acc.Last_Name__c = pax.Last_Name__c;
		acc.Gender__c = BE8_GlobalConstants.MAP_ACCOUNT_GENDER.get(pax.Gender__c);
		acc.Email_1__c = pax.Email_1__c;
		acc.Mobile__c = pax.Mobile__c;
		acc.Travel_Document__c = pax.Travel_Document_Number__c;
		acc.Nationality__c = pax.Nationality__c;
		Date dob = Date.valueOf(DCS_Pax_Util_Service.getDateTimeFormat(pax.Date_of_Birth__c));
		acc.Date_of_Birth__c = dob;

		pax.AccountId__r = new Account(Customer_External_Id__c = DCS_Pax_Util_Service.getCustomerProfileExtId(pax));
		return acc;
	}

	@testVisible
	private static Set<String> getCustomerExternalIdTrimFromAccount(List<Passenger__c> paxs){
		Set<String> returnSet = null;
		if(paxs != null){
			for(Passenger__c pax : paxs){
				if(returnSet == null) returnSet = new Set<String>();
				String key = pax.First_Name__c + pax.Salutation__c + '_' + pax.Last_Name__c + '_' + BE8_DateUtility.convertDateFormatToTraditionalFormat(pax.Date_of_Birth__c.split('T').get(0)) + '_' + pax.Travel_Document_Number__c;
				key = key.replaceAll(' ', '');
				key = key.toLowerCase();
				returnSet.add(key);
			}
		}
		return returnSet;
	}

	/**
										Manage Membership
	*/

	public static Map<String, Membership__c> concreteMembership(Map<String, Passenger__c> paxmap){
		Map<String, Membership__c> returnmap = new Map<String, Membership__c>();
		if(paxmap != null && !paxmap.isEmpty()){
			for(String key : paxmap.keySet()){
				Membership__c mem = createMembershipFromPax(paxmap.get(key));
				if(mem != null) returnmap.put(key, mem);
			}
		}
		if(!returnmap.isEmpty()) return returnmap;
		return null;
	}

    public static Map<String, Passenger__c> getPaxMapToCreateMembership(Set<String> keylist, Map<String, Passenger__c> paxmap){
    	Map<String, Passenger__c> returnmap = new Map<String, Passenger__c>();
    	if(keylist != null && !keylist.isEmpty() && paxmap != null && !paxmap.isEmpty()){
    		for(String key : keylist){
    			if(paxmap.containsKey(key)) returnmap.put(key, paxmap.get(key));
    		}
    	}
    	if(returnmap != null && !returnmap.isEmpty()) return returnmap;
    	return null;
    }

    @testVisible
    private static Membership__c createMembershipFromPax(Passenger__c pax){
    	if(pax != null && pax.FFP_Number__c != null){
    		Membership__c membership = new Membership__c();
    		membership.Name = pax.FFP_Number__c;
	        membership.Airline__c = pax.FFP_Carrier__c;
	        membership.Tier__c = pax.FFP_Tier__c;
	        membership.EXTMember__c = DCS_Pax_Util_Service.getMemberExtId(pax);
	        membership.Status__c = BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE;
	        if(pax.AccountId__r.Customer_External_Id__c != null) membership.AccountId__r = new Account(Customer_External_Id__c = pax.AccountId__r.Customer_External_Id__c);
	        return membership;
    	}
    	return null;
    }

    /**
										Manage Travel Document
    */

	public static List<Travel_Document__c> concreteTravelDoc(List<Passenger__c> paxlist){
		List<Travel_Document__c> returnlist = new List<Travel_Document__c>();
		if(paxlist != null && !paxlist.isEmpty()){
			for(Passenger__c pax : paxlist){
				returnlist.add(createTravelDocumentFromPax(pax));	
			}
		}
		if(returnlist != null && !returnlist.isEmpty()) return returnlist;
		return null;
	}

    public static List<Passenger__c> getPaxListToCreateTravelDoc(Set<String> keylist, Map<String, Passenger__c> paxmap){
    	List<Passenger__c> returnlist = new List<Passenger__c>();
    	if(keylist != null && !keylist.isEmpty() && paxmap != null && !paxmap.isEmpty()){
    		for(String key : keylist){
    			if(paxmap.containsKey(key)) returnlist.add(paxmap.get(key));
    		}
    	}
    	if(returnlist != null && !returnlist.isEmpty()) return returnlist;
    	return null;
    }

    @testVisible
	private static Travel_Document__c createTravelDocumentFromPax(Passenger__c pax){
		Travel_Document__c traveldoc = new Travel_Document__c();
		traveldoc.Nationality__c = pax.Nationality__c;
		traveldoc.Travel_Document_Number__c = pax.Travel_Document_Number__c;
		traveldoc.ExtDocument__c = pax.Travel_Document_Number__c;
		traveldoc.AccountId__r = new Account(Customer_External_Id__c = pax.AccountId__r.Customer_External_Id__c);
		return traveldoc;
	}

	/**
										Manage Passenger
	*/

	public static Flight__c getFlight(WS_DCS_Pax_Model.cls_flightDetailsGroup dcsmodel){
		Flight__c returnFlight = new Flight__c();
		List<WS_DCS_Pax_Model.cls_timeData> timeDataList = dcsmodel.timeData;
		WS_DCS_Pax_Model.cls_legDetails legDetails = dcsmodel.legDetails;
		List<WS_DCS_Pax_Model.cls_totalByCabin> totalByCabin = dcsmodel.totalByCabin;

		return null;
	}

	public static void getPaxBasicInfo(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		updatePaxInfoCheckbox(pax, paxmodel);
		updatePaxPersonalInfo(pax, paxmodel);
		updatePaxSeatInfo(pax, paxmodel);
		updatePaxFlightInfo(pax, paxmodel);
	}

	public static void updatePaxInfoCheckbox(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null){
			Map<String, String> customerStatusMap = DCS_Pax_Model_Service.getCustomerStatusMapByCode(paxmodel);
			Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrmap = DCS_Pax_Model_Service.getssrDetailMapBySSRCode(paxmodel);

			pax.Child__c = customerStatusMap != null && !customerStatusMap.isEmpty() && customerStatusMap.containsKey('CHD') && customerStatusMap.get('CHD') == '1' ? true : false;
			pax.Infant__c = ssrmap != null && !ssrmap.isEmpty() && !DCS_Pax_Model_Service.isINFTOccupyingSeat(ssrmap.get('INFT'));
			pax.Staff_Booking__c = paxmodel.customerStaffCategory != null && paxmodel.customerStaffCategory.indicators != null && paxmodel.customerStaffCategory.indicators.indicator == 'BKB' ? true : false;
			pax.Staff_Waitlist__c = paxmodel.customerStaffCategory != null && paxmodel.customerStaffCategory.indicators != null && paxmodel.customerStaffCategory.indicators.indicator == 'SBY' ? true : false;
			pax.Ticket__c = paxmodel.productLevel != null && paxmodel.productLevel.TktInfo != null ? true : false;
		}
		pax.IgnoreProcessBuilder__c = true;
		pax.Source_Data__c = BE8_GlobalConstants.SOURCE_DATA_WEB_SERVICE;
	}

	public static void updatePaxPersonalInfo(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String pname = DCS_Pax_Model_Service.getPaxNameFromModel(paxmodel);
		String fname = DCS_Pax_Model_Handler.paxFirstname(paxmodel);
		String lname = DCS_Pax_Model_Handler.paxLastname(paxmodel);
		String title = DCS_Pax_Model_Handler.paxTitle(paxmodel);
		String gender = DCS_Pax_Model_Handler.paxGender(paxmodel);
		String groupname = DCS_Pax_Model_Handler.paxGroupname(paxmodel);
		String pnr = DCS_Pax_Model_Handler.paxPNR(paxmodel);
		String segment = DCS_Pax_Model_Handler.paxSegmentStatus(paxmodel);
		String dob = DCS_Pax_Model_Handler.paxDOB(paxmodel);

		
		if(fname != null) pax.First_Name__c = fname;
		if(lname != null) pax.Last_Name__c = lname;
		if(pname != null) pax.Name = pname;
		if(title != null) pax.Salutation__c = title;
		if(gender != null) pax.Gender__c = gender;
		if(groupname != null) pax.Group_Name__c = groupname;
		if(pnr != null) pax.PNR__c = pnr;
		if(segment != null) pax.Segment_Status__c = segment;
		if(dob != null) pax.Date_of_Birth__c = dob;
	}

	public static void updatePaxSeatInfo(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String paxseat = DCS_Pax_Model_Handler.paxSeat(paxmodel);
		String paxseatstatus = DCS_Pax_Model_Handler.paxSeatStatus(paxmodel);
		String bookingclass = DCS_Pax_Model_Handler.paxBookingClass(paxmodel);
		String cabincode = DCS_Pax_Model_Handler.paxCheckinCabinCode(paxmodel);

		if(paxseatstatus != null && paxseatstatus == 'NGA') pax.Booking_Seat__c = paxseat;
		if(paxseatstatus == 'GUA') pax.Checkin_Seat__c = paxseat;
		if(bookingclass != null) pax.Booking_Class__c = bookingclass;
		if(cabincode != null) pax.Cabin_Code__c = cabincode;
	}

	public static void updatePaxFlightInfo(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String boardpoint = DCS_Pax_Model_Handler.paxBoardPoint(paxmodel);
		String offpoint = DCS_Pax_Model_Handler.paxOffPoint(paxmodel);
		if(boardpoint != null && offpoint != null){
			pax.Board_Point__c = boardpoint;
			pax.Off_Point__c = offpoint;
			pax.Sector__c = boardpoint + '-' + offpoint;
		}
	}

	public static void updatePaxWSKey(Passenger__c pax, Map<String, Passenger__c> odspaxmap, Flight__c flight){
		String key = null;
		if(flight != null && odspaxmap != null && !odspaxmap.isEmpty()) key = DCS_Pax_Util_Service.keyGenerateByDCSPaxInfo(flight.Flight_Number__c, flight.Flight_Date_LT__c, pax.Salutation__c, pax.First_Name__c, pax.Last_Name__c, pax.PNR__c, String.valueOf(flight.Leg_Number__c));
		if(key != null && odspaxmap.containsKey(key)) pax.WS_Key__c = odspaxmap.get(key).WS_Key__c;
		else pax.WS_Key__c = DCS_Pax_Util_Service.generateWSKey(pax, flight);
	}

	public static void getPaxConnectingFlight(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String fltno = DCS_Pax_Model_Handler.paxConnectingFlightNumber(paxmodel);
		String fltdate = DCS_Pax_Model_Handler.paxConnectingFlightDate(paxmodel);
		String fltstd = DCS_Pax_Model_Handler.paxConnectingFlightSTD(paxmodel);
		String fltsegment = DCS_Pax_Model_Handler.paxConnectingFlightSegment(paxmodel);
		if(fltno != null) pax.Connecting_Flight__c = fltno;
		if(fltdate != null) pax.Connecting_Date__c = fltDate;
		if(fltsegment != null) pax.Connecting_Segment__c = fltsegment;
		if(fltstd != null) pax.Connecting_STD__c = fltstd;
	}

	public static void getPaxTicketInfo(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String tktno = DCS_Pax_Model_Handler.paxTicketNumber(paxmodel);
		String tkttype = DCS_Pax_Model_Handler.paxTicketType(paxmodel);
		if(tktno != null) pax.Ticket_Number__c = tktno;
		if(tkttype != null) pax.Ticket_Type__c = tkttype;
	}

	public static void getPaxSSR(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrmap = DCS_Pax_Model_Service.getssrDetailMapBySSRCode(paxModel);
		SSRPaxTravelDoc(pax, paxmodel);
		SSRPaxFQTV(pax, paxmodel);
		SSRPaxEmail(pax, ssrmap);
		SSRPaxPhone(pax, ssrmap);
		SSRPaxSpecialMeal(pax, ssrmap);
		SSRPaxVipVVip(pax, ssrmap);
		SSRPaxInfant(pax, ssrmap);
		SSROthers(pax, ssrmap);
	}

	public static void SSRPaxTravelDoc(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String doctype = DCS_Pax_Model_Handler.paxDocType(paxmodel);
		String docno = DCS_Pax_Model_Handler.paxDocNumber(paxmodel);
		String issuingcountry = DCS_Pax_Model_Handler.paxDocIssuingCountry(paxmodel);
		String nationality = DCS_Pax_Model_Handler.paxNationality(paxmodel);
		if(doctype != null) pax.Document_Type__c = doctype;
		if(docno != null) pax.Travel_Document_Number__c = docno;
		if(issuingcountry != null) pax.Doc_Issuing_Country__c = issuingcountry;
		if(nationality != null) pax.Nationality__c = nationality;
	}

	public static void SSRPaxFQTV(Passenger__c pax, WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String ffpnumber = DCS_Pax_Model_Handler.paxFFPNumber(paxmodel);
		String ffptier = DCS_Pax_Model_Handler.paxFFPTier(paxmodel);
		String ffpcarrier = DCS_Pax_Model_Handler.paxFFPCarrier(paxmodel);
		if(ffpnumber != null) pax.FFP_Number__c = ffpnumber;
		if(ffpcarrier != null) pax.FFP_Carrier__c = ffpcarrier;
		if(ffptier != null) pax.FFP_Tier__c = ffptier;
	}

	public static void SSRPaxEmail(Passenger__c pax, Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrMap){
		if(ssrMap != null && ssrMap.containsKey(BE8_GlobalConstants.SSR_CODE_CTCE)){
			if(ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCE) != null && !ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCE).isEmpty()){
				pax.Email_1__c = ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCE).get(0).serviceFreeText;
				if(ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCE).size() > 1) 
					pax.Email_2__c = ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCE).get(1).serviceFreeText;
			}
			ssrMap.remove(BE8_GlobalConstants.SSR_CODE_CTCE);
		}
	}

	public static void SSRPaxPhone(Passenger__c pax, Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrMap){
		if(ssrMap != null && ssrMap.containsKey(BE8_GlobalConstants.SSR_CODE_CTCM)){
			if(ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCM) != null && !ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCM).isEmpty()){
				pax.Mobile__c = ssrMap.get(BE8_GlobalConstants.SSR_CODE_CTCM).get(0).serviceFreeText;
			}
			ssrMap.remove(BE8_GlobalConstants.SSR_CODE_CTCM);
		}
	}

	public static void SSRPaxSpecialMeal(Passenger__c pax, Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrMap){
		if(ssrMap != null && ssrMap.containsKey(BE8_GlobalConstants.SSR_CODE_SPML)){
			String spml = '';
			Integer loopcount = 1;
			for(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr : ssrMap.get(BE8_GlobalConstants.SSR_CODE_SPML)){
				spml += BE8_GlobalConstants.SSR_CODE_SPML + '-' + ssr.serviceFreeText;
				if(ssr.actionCode == BE8_GlobalConstants.SSR_CONFIRM)
					spml += BE8_GlobalConstants.SSR_GURANTEED;
				else if(ssr.actionCode == BE8_GlobalConstants.SSR_NOT_CONFIRM)
				spml += BE8_GlobalConstants.SSR_NOT_GURANTEED;
				if(loopcount < ssrMap.get(BE8_GlobalConstants.SSR_CODE_SPML).size()) spml += '\n';
			}
			pax.Special_Meal__c = spml;
			ssrMap.remove(BE8_GlobalConstants.SSR_CODE_SPML);
		}
	}

	public static void SSRPaxVipVVip(Passenger__c pax, Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrMap){
		if(ssrMap != null && ssrMap.containsKey(BE8_GlobalConstants.SSR_CODE_MAAS)){
			if(ssrMap.get(BE8_GlobalConstants.SSR_CODE_MAAS) != null && !ssrMap.get(BE8_GlobalConstants.SSR_CODE_MAAS).isEmpty()){
				String ssrtxt = ssrMap.get(BE8_GlobalConstants.SSR_CODE_MAAS).get(0).serviceFreeText;
				if(ssrtxt.contains(BE8_GlobalConstants.SSR_MAAS_VIP) || ssrtxt.contains(BE8_GlobalConstants.SSR_MAAS_VVIP)) 
					pax.VIP_VVIP_Flag__c = true;
			}
			ssrMap.remove(BE8_GlobalConstants.SSR_CODE_MAAS);
		}
	}

	public static void SSRPaxInfant(Passenger__c pax, Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrMap){
		Boolean flag = false;
		if(ssrMap != null && ssrMap.containsKey(BE8_GlobalConstants.SSR_CODE_INFT)){
			for(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr : ssrMap.get(BE8_GlobalConstants.SSR_CODE_INFT)){
				if(!DCS_Pax_Model_Service.isINFTOccupyingSeat(ssr)){
					pax.Infant__c = true;
					String infantname = DCS_Pax_Model_Service.getInfantName(ssr);
					String infantDOB = DCS_Pax_Model_Service.getInfantDOB(ssr);
					if(infantname != null) pax.Infant_Name__c = infantname;
					if(infantDOB != null) pax.Infant_Date_of_Birth__c = infantDOB;
					break;
				}
			}
			ssrMap.remove(BE8_GlobalConstants.SSR_CODE_INFT);
		}
	}

	public static void SSROthers(Passenger__c pax, Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> ssrMap){
		List<String> ssrliststring = new List<String>();
		if(ssrMap != null && !ssrMap.isEmpty()){
			for(String ssrcode : ssrMap.keySet()){
				/*evaluate whether ssr code is request or info*/
				WS_DCS_Pax_Model.cls_specialRequirementsInfo ssrinfo = ssrMap.get(ssrcode).get(0);
				if(DCS_Pax_Model_Service.isSSRRequest(ssrinfo)) ssrcode += DCS_Pax_Model_Service.getSSRStatus(ssrinfo);
				ssrliststring.add(ssrcode);
				
			}
			pax.SSR_Service__c = String.join(ssrliststring, '\n');
		}
	}
}