/*
	DCS_Pax_Model_Handler - Used for extract data from dcs model
	
	Model Structure:
	getUniqueCustomerId
		getIdSection

	getSSRDetails
		getSpecialRequirementInfo

	getSecNumber
		getReferenceDetails

	getSeatInfo
		getSeatStatusInfo
			getStatusInfo
		getSeatNumberInfo
			getSeatDetails

	getRegulatoryInfo
		getTravelerDocument
			getTravelerDocumentDetails
				getIssueDetails
		getPaxData
			getPaxDetails
			getOtherPaxDetails
		getDocumentIssuingCountry
			getLoncDesc

	getProductLevel
		getTktInfo
			getTkt
				getDocumentDetails
		getSbrRecordLocator
			getReservation
		getFlightInfo
			getOffPointDetails
			getBoardPointDetails
			getFlightIdentification
			getFlightDate
			getCompanyDetails
		getBookingData

	getPaxDateTime
	getOtherFlightInfo
		getTimeData
		getOtherFlightData
			getOtherFlightOffPointDetails
			getOtherFlightBoardPointDetails
			getOtherFlightIdentification
			getOtherFlightDate
			getOtherFlightCompanyDetails
		getOtherFlightOperatingDetails
			getOtherFlightOperatingFlightIdentification
			getOtherFlightOperatingCompanyDetails
		getOtherFlightTypeIndicator
			getOtherFlightTypeStatusInfo
		getOtherFlightCabinData
			getOtherFlightCabinDetails
		getOtherFlightAcceptanceStatus
			getOtherFlightAcceptanceStatusinfo

	getNationality
		getNationalityDetails

	getLegCabinCode
		getCabinDetails

	getGroupName
		getGroupNameFreeTextQualification

	getFqtvDetails
		getFqtvData
			getFrequentTravellerDetails

	getCustomerStatus
		getCustomerStatusInfo

	getCustomerStaffCategory
		getCustomerStaffIndicators

	getCustomerData
		getCustomerDataPaxDetails
		getCustomerDataOtherPaxDetails

	getBookedCabinCode
		getBookedCabinDetails

*/
public without sharing class DCS_Pax_Model_Handler {
	public static String paxFirstname(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherPaxDetails otherpaxdetails = getCustomerDataOtherPaxDetails(paxmodel);
		if(otherpaxdetails != null) return otherpaxdetails.givenName;
		return null;
	}

	public static String paxLastname(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_paxDetails paxdetails = getCustomerDataPaxDetails(paxmodel);
		if(paxdetails != null) return paxdetails.surname;
		return null;
	}

	public static String paxTitle(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherPaxDetails otherpaxdetails = getCustomerDataOtherPaxDetails(paxmodel);
		if(otherpaxdetails != null) return otherpaxdetails.title;
		return null;
	}

	public static String paxGroupname(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_groupName groupname = getGroupName(paxmodel);
		if(groupname != null) return groupname.freeText;
		return null;
	}

	public static String paxPNR(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_reservation pnr = getReservation(paxmodel);
		if(pnr != null) return pnr.controlNumber;
		return null;
	}

	public static String paxSegmentStatus(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_bookingData bookingdata = getBookingData(paxmodel);
		if(bookingdata != null) return bookingdata.statusCode;
		return null;
	}

	public static String paxGender(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_paxDetails paxdetails = getCustomerDataPaxDetails(paxmodel);
		if(paxdetails != null) return paxdetails.gender;
		return null;
	}

	public static String paxBookingClass(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightIdentification fltidentification = getFlightIdentification(paxmodel);
		if(fltidentification != null) return fltidentification.bookingClass;
		return null;
	}

	public static String paxCheckinCabinCode(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_cabinDetails legcabincode = getCabinDetails(paxmodel);
		if(legcabincode != null) return legcabincode.classDesignator;
		return null;
	}

	public static String paxBookingCabinCode(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_cabinDetails bookedcabincode = getBookedCabinDetails(paxmodel);
		if(bookedcabincode != null) return bookedcabincode.classDesignator;
		return null;
	}

	public static String paxSeat(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_seatDetails seatdetails = getSeatDetails(paxmodel);
		if(seatdetails != null) return seatdetails.seatNumber;
		return null;
	}

	public static String paxSeatStatus(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_statusInfo seatinfo = getStatusInfo(paxmodel);
		if(seatinfo != null) return seatinfo.action;
		return null;
	}

	public static String paxFFPCarrier(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_frequentTravellerDetails fqtv = paxFQTV(paxmodel);
		if(fqtv != null) return fqtv.carrier;
		return null;
	}

	public static String paxFFPTier(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_frequentTravellerDetails fqtv = paxFQTV(paxmodel);
		if(fqtv != null) return fqtv.tierLevel;
		return null;
	}

	public static String paxFFPNumber(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_frequentTravellerDetails fqtv = paxFQTV(paxmodel);
		if(fqtv != null) return fqtv.number_z;
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_frequentTravellerDetails> paxFQTVList(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		return getFrequentTravellerDetails(paxmodel);
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_frequentTravellerDetails paxFQTV(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		List<WS_DCS_Pax_Model.cls_frequentTravellerDetails> fqtvlist = paxFQTVList(paxmodel);
		if(fqtvlist != null) return fqtvlist.get(0);
		return null;
	}

	public static String paxDocType(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_issueDetails docissued = getIssueDetails(paxmodel);
		if(docissued != null) return docissued.documentCode;
		return null;
	}

	public static String paxDocNumber(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_travelerDocumentDetails docdetails = getTravelerDocumentDetails(paxmodel);
		if(docdetails != null) return docdetails.travelerDocumentId;
		return null;
	}

	public static String paxDocIssuingCountry(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_LocnDesc docissuedLocn = getLoncDesc(paxmodel);
		if(docissuedLocn != null) return docissuedLocn.code;
		return null;
	}

	public static String paxNationality(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_nationalityDetails nationalityDetails = getNationalityDetails(paxmodel);
		if(nationalityDetails != null) return nationalityDetails.nationalityCode;
		return null;
	}

	public static String paxDOB(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_paxDateTime paxdob = getPaxDateTime(paxmodel);
		if(paxdob != null) return DCS_Pax_Util_Service.getDateTimeFormat(paxdob.dateTime_z);
		return null;
	}

	public static String paxConnectingFlightNumber(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightIdentification fltinfo = getOtherFlightIdentification(paxmodel);
		WS_DCS_Pax_Model.cls_companyDetails fltcarrier = getOtherFlightCompanyDetails(paxmodel);
		if(fltinfo != null && fltcarrier != null) return  fltcarrier.marketingCompany + fltinfo.flightNumber;
		return null;
	}

	public static String paxConnectingFlightDate(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightDate fltdate = getOtherFlightDate(paxmodel);
		if(fltdate != null) return fltdate.departureDate;
		return null;
	}

	public static String paxConnectingFlightSTD(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		List<WS_DCS_Pax_Model.cls_timeData> otherFltTimeDataList = getTimeData(paxmodel);
		if(otherFltTimeDataList != null && !otherFltTimeDataList.isEmpty()) return DCS_Pax_Util_Service.getFlightSTD(otherFltTimeDataList);
		return null;
	}

	public static String paxConnectingFlightSegment(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_offpointDetails otherfltoffpoint = getOtherFlightOffPointDetails(paxmodel);
		WS_DCS_Pax_Model.cls_boardPointDetails otherfltboardpoint = getOtherFlightBoardPointDetails(paxmodel);
		if(otherfltboardpoint != null && otherfltoffpoint != null) return otherfltboardpoint.trueLocnId + '-' + otherfltoffpoint.trueLocnId;
		return null;
	}

	public static String paxTicketNumber(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_documentDetails ticketinfo = getDocumentDetails(paxmodel);
		if(ticketinfo != null) return ticketinfo.number_z;
		return null;
	}

	public static String paxTicketType(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_documentDetails ticketinfo = getDocumentDetails(paxmodel);
		if(ticketinfo != null) return ticketinfo.type_z;
		return null;
	}

	public static String paxBoardPoint(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_boardPointDetails boardpoint = getBoardPointDetails(paxmodel);
		if(boardpoint != null) return boardpoint.trueLocnId;
		return null;
	}

	public static String paxOffPoint(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_offpointDetails offpoint = getOffPointDetails(paxmodel);
		if(offpoint != null) return offpoint.trueLocnId;
		return null;
	}

	public static String paxFltDate(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightDate fltdate = getFlightDate(paxmodel);
		if(fltdate != null) return fltdate.departureDate;
		return null;
	}

	public static String paxDCSPaxUniqueId(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_idSection idsection = getIdSection(paxmodel);
		if(idsection != null) return idsection.primeId;
		return null;
	}

	public static List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> paxSSRList(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> ssrlist = getSpecialRequirementInfo(paxmodel);
		if(ssrlist != null && !ssrlist.isEmpty()) return ssrlist;
		return null;
	}

	public static List<WS_DCS_Pax_Model.cls_statusInfo> paxCustomerStatusInfoList(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		List<WS_DCS_Pax_Model.cls_statusInfo> paxinfolist = getCustomerStatusInfo(paxmodel);
		if(paxinfolist != null && !paxinfolist.isEmpty()) return paxinfolist;
		return null;
	}

	public static Boolean isDCSModelNull(WS_DCS_Pax_Model dcsmodel){
		return dcsmodel == null;
	}

	public static Boolean isDCSModelFlightGroupNull(WS_DCS_Pax_Model dcsmodel){
		return isDCSModelNull(dcsmodel) || (!isDCSModelNull(dcsmodel) && dcsmodel.flightDetailsGroup == null);
	}

	public static Boolean isDCSModelCustomerLevelNull(WS_DCS_Pax_Model dcsmodel){
		return isDCSModelFlightGroupNull(dcsmodel) || (!isDCSModelFlightGroupNull(dcsmodel) && dcsmodel.flightDetailsGroup.customerLevel == null);
	}

	public static Boolean isDCSModelCustomerLevelEmpty(WS_DCS_Pax_Model dcsmodel){
		return isDCSModelFlightGroupNull(dcsmodel) || (!isDCSModelFlightGroupNull(dcsmodel) && dcsmodel.flightDetailsGroup.customerLevel.isEmpty());
	}

	public static List<WS_DCS_Pax_Model.cls_customerLevel> getCustomerLevelList(WS_DCS_Pax_Model dcsmodel){
		if(!isDCSModelCustomerLevelNull(dcsmodel) && !isDCSModelCustomerLevelEmpty(dcsmodel)) return dcsmodel.flightDetailsGroup.customerLevel;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_uniqueCustomerId getUniqueCustomerId(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.uniqueCustomerId;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_idSection getIdSection(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_uniqueCustomerId uniId = getUniqueCustomerId(paxmodel);
		if(uniId != null) return uniId.idSection;
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_ssrDetails> getSSRDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.ssrDetails;
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> getSpecialRequirementInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		List<WS_DCS_Pax_Model.cls_ssrDetails> ssrlist = getSSRDetails(paxmodel);
		List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> returnlist = new List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>();
		if(ssrlist != null){
			for(WS_DCS_Pax_Model.cls_ssrDetails ssr : ssrlist){
				returnlist.add(ssr.specialRequirementsInfo);
			}
		}
		if(!returnlist.isEmpty()) return returnlist;
		else return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_secNumber getSecNumber(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.secNumber;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_referenceDetails getReferenceDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_secNumber secno = getSecNumber(paxmodel);
		if(secno != null) return secno.referenceDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_seatInfo getSeatInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.seatInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_seatStatusInfo getSeatStatusInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_seatInfo seatinfo = getSeatInfo(paxmodel);
		if(seatinfo != null) return seatinfo.seatStatusInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_statusInfo getStatusInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_seatStatusInfo seatstatusinfo = getSeatStatusInfo(paxmodel);
		if(seatstatusinfo != null) return seatstatusinfo.statusInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_seatNumberInfo getSeatNumberInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_seatInfo seatinfo = getSeatInfo(paxmodel);
		if(seatinfo != null) return seatinfo.seatNumberInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_seatDetails getSeatDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_seatNumberInfo seatnoinfo = getSeatNumberInfo(paxmodel);
		if(seatnoinfo != null) return seatnoinfo.seatDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_regulatoryInfo getRegulatoryInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		//if(paxmodel != null && paxmodel.regulatoryInfo.size() > 1)System.debug('regulatoryInfo: ' + JSON.serialize(paxmodel.regulatoryInfo));
		if(paxmodel != null && paxmodel.regulatoryInfo != null && !paxmodel.regulatoryInfo.isEmpty()) return paxmodel.regulatoryInfo.get(0);
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_travelerDocuments getTravelerDocument(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_regulatoryInfo reginfo = getRegulatoryInfo(paxmodel);
		if(reginfo != null) return reginfo.travelerDocuments;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_travelerDocumentDetails getTravelerDocumentDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_travelerDocuments traveldoc = getTravelerDocument(paxmodel);
		if(traveldoc != null) return traveldoc.travelerDocumentDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_issueDetails getIssueDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_travelerDocuments traveldoc = getTravelerDocument(paxmodel);
		if(traveldoc != null) return traveldoc.issueDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_PaxData getPaxData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_regulatoryInfo reginfo = getRegulatoryInfo(paxmodel);
		if(reginfo != null) return reginfo.PaxData;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_paxDetails getPaxDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_PaxData paxdata = getPaxData(paxmodel);
		if(paxdata != null) return paxdata.paxDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_otherPaxDetails getOtherPaxDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_PaxData paxdata = getPaxData(paxmodel);
		if(paxdata != null) return paxdata.otherPaxDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_documentIssuingCountry getDocumentIssuingCountry(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_regulatoryInfo reginfo = getRegulatoryInfo(paxmodel);
		if(reginfo != null) return reginfo.documentIssuingCountry;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_LocnDesc getLoncDesc(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_documentIssuingCountry docissuingcountry = getDocumentIssuingCountry(paxmodel);
		if(docissuingcountry != null) return docissuingcountry.LocnDesc;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_productLevel getProductLevel(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.productLevel;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_TktInfo getTktInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_productLevel productlvl = getProductLevel(paxmodel);
		if(productlvl != null) return productlvl.TktInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_Tkt getTkt(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_TktInfo tktinfo = getTktInfo(paxmodel);
		if(tktinfo != null) return tktinfo.Tkt;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_documentDetails getDocumentDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_Tkt tkt = getTkt(paxmodel);
		if(tkt != null) return tkt.documentDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_sbrRecordLocator getSbrRecordLocator(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_productLevel productlvl = getProductLevel(paxmodel);
		if(productlvl != null) return productlvl.sbrRecordLocator;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_reservation getReservation(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_sbrRecordLocator sbr = getSbrRecordLocator(paxmodel);
		if(sbr != null) return sbr.reservation;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightInfo getFlightInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_productLevel productlvl = getProductLevel(paxmodel);
		if(productlvl != null) return productlvl.flightInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_offpointDetails getOffPointDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightInfo fltinfo = getFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.offpointDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_boardPointDetails getBoardPointDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightInfo fltinfo = getFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.boardPointDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightIdentification getFlightIdentification(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightInfo fltinfo = getFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.flightIdentification;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightDate getFlightDate(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightInfo fltinfo = getFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.flightDate;
		return null;
	}	

	@testVisible
	private static WS_DCS_Pax_Model.cls_companyDetails getCompanyDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightInfo fltinfo = getFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.companyDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_bookingData getBookingData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_productLevel productlvl = getProductLevel(paxmodel);
		if(productlvl != null) return productlvl.bookingData;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_paxDateTime getPaxDateTime(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.paxDateTime;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_otherFlightInfo getOtherFlightInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null){
			if(paxmodel.otherFlightInfo != null && !paxmodel.otherFlightInfo.isEmpty()) return paxmodel.otherFlightInfo.get(0);
		}
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_timeData> getTimeData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightInfo otherflight = getOtherFlightInfo(paxmodel);
		if(otherflight != null) return otherflight.timeData;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_otherFlightData getOtherFlightData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightInfo otherflight = getOtherFlightInfo(paxmodel);
		if(otherflight != null) return otherflight.otherFlightData;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_offpointDetails getOtherFlightOffPointDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightData fltdata = getOtherFlightData(paxmodel);
		if(fltdata != null) return fltdata.offpointDetails;
		return null;
	}	

	@testVisible
	private static WS_DCS_Pax_Model.cls_boardpointDetails getOtherFlightBoardPointDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightData fltdata = getOtherFlightData(paxmodel);
		if(fltdata != null) return fltdata.boardPointDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightIdentification getOtherFlightIdentification(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightData fltdata = getOtherFlightData(paxmodel);
		if(fltdata != null) return fltdata.flightIdentification;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightDate getOtherFlightDate(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightData fltdata = getOtherFlightData(paxmodel);
		if(fltdata != null) return fltdata.flightDate;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_companyDetails getOtherFlightCompanyDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightData fltdata = getOtherFlightData(paxmodel);
		if(fltdata != null) return fltdata.companyDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_operatingDetails getOtherFlightOperatingDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightInfo fltinfo = getOtherFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.operatingDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightIdentification getOtherFlightOperatingFlightIdentification(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_operatingDetails fltoperating = getOtherFlightOperatingDetails(paxmodel);
		if(fltoperating != null) return fltoperating.flightIdentification;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_companyDetails getOtherFlightOperatingCompanyDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_operatingDetails fltoperating = getOtherFlightOperatingDetails(paxmodel);
		if(fltoperating != null) return fltoperating.companyDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_flightTypeIndicator getOtherFlightTypeIndicator(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightInfo fltinfo = getOtherFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.flightTypeIndicator;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_statusInfo getOtherFlightTypeStatusInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_flightTypeIndicator fltindicator = getOtherFlightTypeIndicator(paxmodel);
		if(fltindicator != null) return fltindicator.statusInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_cabinData getOtherFlightCabinData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightInfo fltinfo = getOtherFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.cabinData;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_cabinDetails getOtherFlightCabinDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_cabinData cabindata = getOtherFlightCabinData(paxmodel);
		if(cabindata != null) return cabindata.cabinDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_acceptanceStatus getOtherFlightAcceptanceStatus(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_otherFlightInfo fltinfo = getOtherFlightInfo(paxmodel);
		if(fltinfo != null) return fltinfo.acceptanceStatus;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_statusInfo getOtherFlightAcceptanceStatusinfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_acceptanceStatus acceptancestatus = getOtherFlightAcceptanceStatus(paxmodel);
		if(acceptancestatus != null) return acceptancestatus.statusInfo;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_nationality getNationality(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.nationality;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_nationalityDetails getNationalityDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_nationality nationality = getNationality(paxmodel);
		if(nationality != null) return nationality.nationalityDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_legCabinCode getLegCabinCode(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.legCabinCode;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_cabinDetails getCabinDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_legCabinCode cabincode = getLegCabinCode(paxmodel);
		if(cabincode != null) return cabincode.cabinDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_groupName getGroupName(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.groupName;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_freeTextQualification getGroupNameFreeTextQualification(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_groupName groupname = getGroupName(paxmodel);
		if(groupname != null) return groupname.freeTextQualification;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_fqtvDetails getFqtvDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null && paxmodel.fqtvDetails != null && !paxmodel.fqtvDetails.isEmpty()) return paxmodel.fqtvDetails.get(0);
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_fqtvData getFqtvData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_fqtvDetails fqtvdetails = getFqtvDetails(paxmodel);
		if(fqtvdetails != null) return fqtvdetails.fqtvData;
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_frequentTravellerDetails> getFrequentTravellerDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_fqtvData fqtvdata = getFqtvData(paxmodel);
		if(fqtvdata != null && !fqtvdata.frequentTravellerDetails.isEmpty()) return fqtvdata.frequentTravellerDetails;
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_customerStatus> getCustomerStatus(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.customerStatus;
		return null;
	}

	@testVisible
	private static List<WS_DCS_Pax_Model.cls_statusInfo> getCustomerStatusInfo(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		List<WS_DCS_Pax_Model.cls_statusInfo> returnList = new List<WS_DCS_Pax_Model.cls_statusInfo>();
		List<WS_DCS_Pax_Model.cls_customerStatus> customerstatus = getCustomerStatus(paxmodel);
		if(customerstatus != null && !customerstatus.isEmpty()){
			for(WS_DCS_Pax_Model.cls_customerStatus cs : customerstatus){
				returnList.add(cs.statusInfo);
			}
		}
		if(!returnList.isEmpty()) return returnList;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_customerStaffCategory getCustomerStaffCategory(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.customerStaffCategory;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_indicators getCustomerStaffIndicators(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_customerStaffCategory staff = getCustomerStaffCategory(paxmodel);
		if(staff != null) return staff.indicators;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_customerData getCustomerData(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.customerData;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_paxDetails getCustomerDataPaxDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_customerData customerdata = getCustomerData(paxmodel);
		if(customerdata != null) return customerdata.paxDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_otherPaxDetails getCustomerDataOtherPaxDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_customerData customerdata = getCustomerData(paxmodel);
		if(customerdata != null) return customerdata.otherPaxDetails;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_bookedCabinCode getBookedCabinCode(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		if(paxmodel != null) return paxmodel.bookedCabinCode;
		return null;
	}

	@testVisible
	private static WS_DCS_Pax_Model.cls_cabinDetails getBookedCabinDetails(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		WS_DCS_Pax_Model.cls_bookedCabinCode bookedcabincode = getBookedCabinCode(paxmodel);
		if(bookedcabincode != null) return bookedcabincode.cabinDetails;
		return null;
	}
}