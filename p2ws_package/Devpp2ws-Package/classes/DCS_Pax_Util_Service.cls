public without sharing class DCS_Pax_Util_Service {

    //private static String querystring = 'SELECT Id, WS_KEY__c FROM Passenger__c WHERE FlightId__c IN (SELECT Id FROM Flight__c WHERE Flight_External_Id__c = ';
	//private static String querystring = 'SELECT Id, Child__c, Infant__c, Staff_Booking__c, Staff_Waitlist__c, Ticket__c, IgnoreProcessBuilder__c, Source_Data__c, First_Name__c, Last_Name__c, Name, Salutation__c, Gender__c, PNR__c, Segment_Status__c, Date_of_Birth__c, Checkin_Seat__c, Booking_Class__c, Cabin_Code__c, Board_Point__c, Off_Point__c, Sector__c, Ticket_Number__c, Ticket_Type__c, Document_Type__c, Travel_Document_Number__c, Doc_Issuing_Country__c, Nationality__c, FFP_Number__c,FFP_Carrier__c, FFP_Tier__c, SSR_Service__c, WS_KEY__c, AccountId__c FROM Passenger__c WHERE FlightId__c IN (SELECT Id FROM Flight__c WHERE Flight_External_Id__c = ';
	//private static String queryMembership = 'SELECT Id, EXTMember__c FROM Membership__c WHERE EXTMember__c IN :';
	//private static String queryAccount = 'SELECT Id, First_Name__c, Last_Name__c, ROP_Number__c FROM Account WHERE Id IN :';

	/**
										Key Management Util
	*/

	public static Map<String, Passenger__c> getPaxMapByGenerateKey(List<Passenger__c> paxlist){
		Map<String, Passenger__c> returnMap = null;
        if(paxlist != null && !paxlist.isEmpty()){
            for(Passenger__c pax : paxlist){
                if(returnmap == null) returnmap = new Map<String, Passenger__c>();
                if(pax.WS_KEY__c != null && pax.WS_KEY__c != '') returnMap.put(keyGenerateByWSKEY(pax.WS_KEY__c), pax);
            }
        }

		return returnMap;
	}

	//public static Map<String, WS_DCS_Pax_Model.cls_customerLevel> getDCSPaxMapByGenerateKey(WS_DCS_Pax_Model dcsmodel, Flight__c flight){
	//	List<WS_DCS_Pax_Model.cls_customerLevel> dcspaxlist = dcsmodel.flightDetailsGroup.customerLevel;
	//	WS_DCS_Pax_Model.cls_legDetails legDetail = dcsmodel.flightDetailsGroup.legDetails;
	//	String fltNo = legDetail.flightDetails.flightNumber;
	//	String fltDate = legDetail.departureDate;
	//	Map<String, WS_DCS_Pax_Model.cls_customerLevel> returnMap = new Map<String, WS_DCS_Pax_Model.cls_customerLevel>();
	//	if(fltno != null && fltDate != null){
	//		for(WS_DCS_Pax_Model.cls_customerLevel dcspax : dcspaxlist){
	//			String fname = DCS_Pax_Model_Handler.paxFirstname(dcspax);
	//			String title = DCS_Pax_Model_Handler.paxTitle(dcspax);
	//			String lname = DCS_Pax_Model_Handler.paxLastname(dcspax);
	//			String pnr = DCS_Pax_Model_Handler.paxPNR(dcspax);
	//			String legNo = String.valueOf(flight.Leg_Number__c);

	//			if(fname != null && lname != null && pnr != null) returnMap.put(keyGenerateByDCSPaxInfo(fltNo, fltDate, title, fname, lname, pnr, legNo), dcspax);
	//		}	
	//	}
		
	//	return returnMap;
	//}

	public static String getDCSPaxGenerateKey(WS_DCS_Pax_Model.cls_customerLevel dcspax, Flight__c flight){
		String fname = null;
        String title = null;
        String lname = null;
        String pnr = null;
        String legno = null;
        String fltno = null;
        String fltDate = null;
        if(dcspax != null && flight != null){
            fname = DCS_Pax_Model_Handler.paxFirstname(dcspax);
            title = DCS_Pax_Model_Handler.paxTitle(dcspax);
            lname = DCS_Pax_Model_Handler.paxLastname(dcspax);
            pnr = DCS_Pax_Model_Handler.paxPNR(dcspax);
            legNo = String.valueOf(flight.Leg_Number__c);
            fltno = getFlightNo(flight.Flight_Number__c);
            fltDate = getSTDLT(flight.STD_LT__c);    
        }
		if(fname != null && lname != null && pnr != null) return keyGenerateByDCSPaxInfo(fltNo, fltDate, title, fname, lname, pnr, legNo);
		return null;
	}

	public static String generateWSKey(Passenger__c pax, Flight__c flight){
        String fname = null;
        String title = null;
        String lname = null;
        String pnr = null;
        String fltno = null;
        String fltdate = null;
        String legno = null;
        String wskey = null;

        if(pax != null && flight != null){
            fname = pax.First_Name__c;
            title = pax.Salutation__c;
            lname = pax.Last_Name__c;
            pnr = pax.PNR__c;
            fltno = flight.Flight_Number__c;
            fltdate = flight.Flight_Date_LT__c;
            legno = String.valueOf(flight.Leg_Number__c);
            if(fltno != null) fltno = fltno.replace('TG', '');
            if(fltdate != null) fltdate = fltdate.trim();
        }

		List<String> keycomponentlist = new List<String>();
		if(fltno != null) keycomponentlist.add(fltno);
		if(fltdate != null) keycomponentlist.add(fltdate);
		if(title != null) fname += ' ' + title;
		if(fname != null) keycomponentlist.add(fname);
		if(lname != null) keycomponentlist.add(lname);
		if(pnr != null) keycomponentlist.add(pnr);
		if(legno != null) keycomponentlist.add(legno);

		if(!keycomponentlist.isEmpty()){
            wskey = String.join(keycomponentlist, '_');
            wskey = wskey.toUpperCase();
        }
		return wskey;
	}

	@testVisible
	private static String keyGenerateByWSKEY(String wskey){
        String key = null;
        if(wskey != null){
    		wskey = wskey.toLowerCase();
    		wskey = wskey.replaceAll(' ', '');
    		List<String> wscomponent = wskey.split('_');
            try{
                String fltNo = String.valueOf(Integer.valueOf(wscomponent.get(0)));
                String fltDate = wscomponent.get(1);
                String fname = wscomponent.get(2).replaceAll(' ', '');
                String lname = wscomponent.get(3);
                String pnr = wscomponent.get(4);
                String legNo = wscomponent.get(5);
                key = fltNo + '_' + fltDate + '_' + fname + '_' + lname + '_' + pnr + '_' + legNo;
            }
            catch(Exception e){
                //log
            }
        }
    		
		return key;
	}

	public static String keyGenerateByDCSPaxInfo(String fltNo, String fltDate, String title, String fname, String lname, String pnr, String legNo){
		if(title != null && title != '') fname += title;
        try{
            fltno = String.valueOf(Integer.valueOf(fltno));    
        }
        catch(Exception e){
            //log
        }
        
		String key = fltNo + '_' + fltDate + '_' + fname + '_' + lname + '_' + pnr + '_' + legNo;
		key = key.toLowerCase();
		key = key.replaceAll(' ', '');
		return key;
	}

	public static String getFlightSTD(List<WS_DCS_Pax_Model.cls_timeData> timeList){
		String returnStr = null;
        if(timeList != null){
            for(WS_DCS_Pax_Model.cls_timeData t : timeList){
                if(t.businessSemantic == 'STD'){
                    returnStr = t.dateTime_z;
                    break;
                }
            }
        }

		return getDateTimeFormat(returnStr);
	}

	/**
											Flight Util
	*/

	public static String getDateTimeFormat(String dtime){
        if(dtime != null) dtime += '.000Z';
		return dtime;
	}

    public static String getFlightCarrier(String flightno){
    	if(flightno != null && flightno.length() > 5) return flightno.substring(0, flightno.length() - 4);
    	else if(flightno != null && flightno.length() == 5) return flightno.substring(0, flightno.length() - 3);
    	return 'TG';
    }

    public static String getFlightNo(String flightno){
        String returnno = null;
    	if(flightno != null){
    	    returnno = flightno.remove('TG');
    		try{
    			returnno = String.valueOf(Integer.valueOf(returnno));
    		}catch(Exception e){
                //log
            }
    	}
    	return returnno;
    }

    public static String getSTDLT(String flightSTDLT){
        String returnSTDLTDate = null;
    	if(flightSTDLT != null) returnSTDLTDate = flightSTDLT.split(' ').get(0);
    	return returnSTDLTDate;
    }

    /**
											Account Util
    */

	public static String getCustomerProfileExtId(Passenger__c pPassenger) {
        String externalId = null;
        if(pPassenger != null && pPassenger.First_Name__c != null && pPassenger.Last_Name__c != null && pPassenger.Salutation__c != null && pPassenger.Travel_Document_Number__c != null && pPassenger.Date_of_Birth__c != null){
            Map<String, Account> sfdcAccountMap = DCS_Pax_Record_Service.getSFDCAccountMap();
            externalId = pPassenger.First_Name__c + ' ' + pPassenger.Salutation__c + '_' + pPassenger.Last_Name__c + '_' + BE8_DateUtility.convertDateFormatToTraditionalFormat(pPassenger.Date_of_Birth__c.split('T').get(0)) + '_' + pPassenger.Travel_Document_Number__c;
            externalId = externalId.toUpperCase();
            String key = externalId.replace(' ', '');
            key = key.toLowerCase();
            if(sfdcAccountMap != null && sfdcAccountMap.containsKey(key)){
                externalId = sfdcAccountMap.get(key).Customer_External_Id__c;
            }
        }

        return externalId;
    }

    public static Set<Id> getAccountIdSet(List<Membership__c> memberships){
    	Set<Id> returnset = new Set<Id>();
    	for(Membership__c mem : memberships){
    		returnset.add(mem.AccountId__c);
    	}
    	if(returnset != null && !returnset.isEmpty()) return returnset;
    	return null;
    }

    public static Map<String, Account> getAccountMap(List<Account> accounts){
    	Map<String, Account> returnmap = new Map<String, Account>();
    	for(Account acc : accounts){
    		if(acc.ROP_Number__c != null) returnmap.put(acc.ROP_Number__c, acc);
    	}
    	if(returnmap != null && !returnmap.isEmpty()) return returnmap;
    	return null;
    }

    public static Map<String, Account> getAccountMapFromSFDC(List<Membership__c> memberships){
        Set<String> fields = BE8_GlobalUtility.getAllCreateableFields('Account');
    	Set<Id> accountIdSet = getAccountIdSet(memberships);
        BE8_SoqlBuilder soqlBuilder = new BE8_SoqlBuilder('Account');
        soqlBuilder.addField(fields);
        soqlBuilder.addCondition('Id IN :accountIdSet');
    	List<Account> accountsSFDC = Database.query(soqlBuilder.getQueryStr());
    	return getAccountMap(accountsSFDC);
    }

    /**
											Membership Util
    */

    public static String getMemberExtId(Passenger__c pax){
    	if(pax!= null && pax.FFP_Carrier__c != null && pax.FFP_Number__c != null) return pax.FFP_Carrier__c + '_' + pax.FFP_Number__c;
    	return null;
    }

	public static Set<String> getMembershipExtIdSet(List<Membership__c> memberships){
    	Set<String> returnlist = new Set<String>();
    	for(Membership__c mem : memberships){
    		returnlist.add(mem.EXTMember__c);
    	}
    	if(returnlist != null && !returnlist.isEmpty()) return returnlist;
    	return null;
    }

    public static Map<String, Membership__c> getMembershipMap(List<Membership__c> memberships){
    	Map<String, Membership__c> returnmap = new Map<String, Membership__c>();
    	for(Membership__c mem : memberships){
    		returnmap.put(mem.EXTMember__c, mem);
    	}
    	if(returnmap != null && !returnmap.isEmpty()) return returnmap;
    	return null;
    }

    public static Map<String, Membership__c> getMembershipMapFromSFDC(List<Membership__c> memberships){
        Set<String> fields = BE8_GlobalUtility.getAllCreateableFields('Membership__c');
    	Set<String> membershipExternalIdSet = getMembershipExtIdSet(memberships);
        BE8_SoqlBuilder soqlBuilder = new BE8_SoqlBuilder('Membership__c');
        soqlBuilder.addField(fields);
        soqlBuilder.addCondition('EXTMember__c IN :membershipExternalIdSet');
    	List<Membership__c> membershipsSFDC = Database.query(soqlBuilder.getQueryStr());
    	return getMembershipMap(membershipsSFDC);
    }

    /**
											Pax Util
    */

    public static Map<String, Passenger__c> getCurrentPaxMap(Flight__c flight){
        Set<String> fields = BE8_GlobalUtility.getAllCreateableFields('Passenger__c');
        BE8_SoqlBuilder soqlBuilder = new BE8_SoqlBuilder('Passenger__c');
        soqlBuilder.addField(fields);
        soqlBuilder.addCondition('FlightId__c IN (SELECT Id FROM Flight__c WHERE Flight_External_Id__c = \'' + flight.Flight_External_ID__c + '\')');
    	List<Passenger__c> paxlist = Database.query(soqlBuilder.getQueryStr());
    	if(paxlist != null && !paxlist.isEmpty()) return DCS_Pax_Util_Service.getPaxMapByGenerateKey(paxlist);
    	return null;
    }

    //public static void updatePaxWSKeyByCurrentPax(Map<String, Passenger__c> odspaxmap, Map<String, Passenger__c> dcspaxmap){
    //	if(odspaxmap != null && !odspaxmap.isEmpty()){
    //		for(String key : odspaxmap.keySet()){
    //			if(dcspaxmap.containsKey(key)) dcspaxmap.get(key).WS_KEY__c = odspaxmap.get(key).WS_KEY__c;
    //		}
    //	}
    //}

    public static Boolean comparePaxWithROPInfo(Passenger__c pax, Account memAccount){
    	String paxFirstName = null;
    	String paxLastname = null;
    	String accFirstName = null;
    	String accLastName = null;
    	if(pax != null){
    		paxFirstName = pax.First_Name__c.replaceAll('\\W+', '');
    		paxLastname = pax.Last_Name__c.replaceAll('\\W+', '');
    	}
    	if(memAccount != null){
    		accFirstName = memAccount.First_Name__c.replaceAll('\\W+', '');
    		accLastName = memAccount.Last_Name__c.replaceAll('\\W+', '');	
    	}
    	if(paxFirstName != null && paxLastname != null && accFirstName != null && accLastName != null) return paxFirstname == accFirstName && paxLastname == accLastName;
    	return null;
    	
    }

    public static List<Passenger__c> getPaxListToDelete(Map<String, Passenger__c> dcsPaxMap, Map<String, Passenger__c> sfdcPaxMap){
    	List<Passenger__c> returnList = new List<Passenger__c>();
        if(sfdcPaxMap != null && !sfdcPaxMap.isEmpty()){
            for(String key : sfdcPaxMap.keySet()){
                if(!dcsPaxMap.containsKey(key)) returnList.add(sfdcPaxMap.get(key));
            }            
        }

    	if(returnList != null && !returnList.isEmpty()) return returnList;
    	return null;
    }

    public static void updateDCSPaxIdFromPaxSFDC(Map<String, Passenger__c> dcsPaxMap, Map<String, Passenger__c> sfdcPaxMap){
    	if(sfdcPaxMap != null && !sfdcPaxMap.isEmpty()){
            for(String key : dcsPaxMap.keySet()){
                if(sfdcPaxMap.containsKey(key)) dcsPaxMap.get(key).Id = sfdcPaxMap.get(key).Id;
            }
        }
    }

    /**
											DB handling
    */

    public static List<Database.UpsertResult> getError(List<Database.UpsertResult> upsertResultList){
    	List<Database.UpsertResult> returnList = new List<Database.UpsertResult>();
    	for(Database.UpsertResult result : upsertResultList){
    		if(!result.isSuccess()) returnList.add(result);
    	}
    	if(returnList != null && !returnList.isEmpty()) return returnList;
    	return null;
    }

    public static List<Database.DeleteResult> getError(List<Database.DeleteResult> saveResultList){
    	List<Database.DeleteResult> returnList = new List<Database.DeleteResult>();
    	for(Database.DeleteResult result : saveResultList){
    		if(!result.isSuccess()) returnList.add(result);
    	}
    	if(returnList != null && !returnList.isEmpty()) return returnList;
    	return null;
    }

	public static Map<String, object> updateToDB(Map<String, object> infoMap){
        Map<String, object> returnMap = new Map<String, object>();
        Map<String, Account> accountMap = (Map<String, Account>) infoMap.get('ACCOUNT');
        List<Passenger__c> deletePaxList = (List<Passenger__c>) infoMap.get('DELETE-PAX');
        Map<String, Passenger__c> paxMap = (Map<String, Passenger__c>) infoMap.get('PAX');
        List<Travel_Document__c> traveldocList = (List<Travel_Document__c>) infoMap.get('TRAVELDOC');
        Map<String, Membership__c> membershipMap = (Map<String, Membership__c>) infoMap.get('MEMBERSHIP');

        dedupAccountMap(accountMap);
        dedupMembershipMap(membershipMap);

		if(accountMap != null && !accountMap.isEmpty()){
            Database.UpsertResult[] accountUpsertResult = Database.upsert(accountMap.values(), Account.Fields.Customer_External_Id__c, false);
            returnMap.put('ACC-RESULT', accountUpsertResult);
        } 
		if(deletePaxList != null && !deletePaxList.isEmpty()){
            Database.DeleteResult[] deletedResult = Database.delete(deletePaxList, false);
            returnMap.put('DEL-RESULT', deletedResult);
        } 
		if(paxMap != null && !paxMap.isEmpty()){
            Database.UpsertResult[] paxUpsertResult = Database.upsert(paxMap.values(), Passenger__c.Fields.Id, false);
            returnMap.put('PAX-RESULT', paxUpsertResult);
        } 
		if(traveldocList != null && !traveldocList.isEmpty()){
            Database.UpsertResult[] traveldocUpsertResult = Database.upsert(traveldocList, Travel_Document__c.Fields.ExtDocument__c, false);
            returnMap.put('TRA-RESULT', traveldocUpsertResult);
		}
        if(membershipMap != null && !membershipMap.isEmpty()){
            Database.UpsertResult[] membershipUpsertResult = Database.upsert(membershipMap.values(), Membership__c.Fields.EXTMember__c, false);
            returnMap.put('MEM-RESULT', membershipUpsertResult);
        }
        
        if(returnMap != null && !returnMap.isEmpty()) return returnMap;
        return null;
	}

    public static void dedupAccountMap(Map<String, Account> accountMap){
        if(accountMap != null && !accountMap.isEmpty()){
            Set<String> externalIdSet = new Set<String>();
            Set<String> keySet = new Set<String>();
            for(String key : accountMap.keySet()){
                String externalId = accountMap.get(key).Customer_External_Id__c;
                if(externalIdSet.contains(externalId)) keySet.add(key);
                else externalIdSet.add(externalId);
            }
            accountMap.keySet().removeAll(keySet);
        }
    }

    public static void dedupMembershipMap(Map<String, Membership__c> membershipMap){
        if(membershipMap != null && !membershipMap.isEmpty()){
            Set<String> externalIdSet = new Set<String>();
            Set<String> keySet = new Set<String>();
            for(String key : membershipMap.keySet()){
                String externalId = membershipMap.get(key).EXTMember__c;
                if(externalIdSet.contains(externalId)) keySet.add(key);
                else externalIdSet.add(externalId);
            }
            membershipMap.keySet().removeAll(keySet);
        }
    }

    /**
                                        Callout Service
    */
    public static List<Map<String, String>> getFilterListMap(String isPSTCallout){
        List<Map<String, String>> filterListMap = new List<Map<String, String>>();
        if(isPSTCallout == 'base'){
            return filterListMap;
        }

        else if(isPSTCallout == 'pst'){
            Map<String, String> filter1 = new Map<String, String>();
            filter1.put('GRP', null);
            filterListMap.add(filter1);

            Map<String, String> filter2 = new Map<String, String>();
            filter2.put('PST', null);
            filter2.put('NAT', null);
            filterListMap.add(filter2);
            return filterListMap;
        }
        return null;
    }

    public static List<String> getGroupIndicator(){
        List<String> groupIndicator = new List<String>();
        groupIndicator.add('OFD');
        groupIndicator.add('SSR');
        groupIndicator.add('FQT');
        return groupIndicator;
    }
}