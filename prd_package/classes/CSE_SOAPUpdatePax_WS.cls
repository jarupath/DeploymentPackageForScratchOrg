public with sharing class CSE_SOAPUpdatePax_WS {
    private static final String CLASS_NAME = 'CSE_SOAPUpdatePax_WS';
    private static TG_WS_Header.ReqHeader getHeader() {
        TG_WS_Header.ReqHeader h = new TG_WS_Header.ReqHeader();

        h.ReqDateTime = DateTime.now();
        h.ReqTxnID = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_REQ_TXN_ID));
        h.SvcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_SVC_VER);
        h.MWTxnID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_MW_TXN_ID);

        h.Credentials = new TG_WS_Header.Credentials_element();
        h.Credentials.MWCredential = new TG_WS_Header.MWCredential_element();
        h.Credentials.MWCredential.ReqID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_REQ_ID);
        h.Credentials.MWCredential.ReqPwd = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_REQ_PWD);
        h.Credentials.MWCredential.UserID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_REQ_USER_ID);

        return h;
    }

    private static TG_Security_element getSecurity() {
        return new TG_Security_element(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_USERNAME),
                                       BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_PASSWORD));
    }

    private static Integer getTimeout() {
        try {
            return Integer.valueOf(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_TIMEOUT));
        } catch (Exception e) {
            return BE8_GlobalConstants.WS_DEFAULT_TIMEOUT;
        }
    }

    //private static Map<String, String> getInputHttpHeaders() {
    //    return new Map<String, String>();
    //}

    //private static Map<String, String> getOutputHttpHeaders() {
    //    return new Map<String, String>();
    //}

    public static String getEndPoint() {
        return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_PAX_ENDPOINT);
    }

    public static String getPassengerWSKey(String flightNumber, String flightDate, String firstName, String lastName, String pnrNumber) {
        String passengerFirstNameWithoutInfantName = firstName;
        Boolean isPassengerFirstNameContainsInfantName = passengerFirstNameWithoutInfantName.contains('/');
        if(isPassengerFirstNameContainsInfantName){
            passengerFirstNameWithoutInfantName = passengerFirstNameWithoutInfantName.split('/')[0];
        }
        return flightNumber + '_'
               + flightDate + '_'
               + passengerFirstNameWithoutInfantName + '_'
               + lastName + '_'
               + pnrNumber;
    }

    // findFlight order by leg number ASC
    public static List<Flight__c> findFlight(Flight__c pFlight, String pFlightNumber, String pFlightDate) {
        String flightMasterKey = getFlightMasterKey(pFlight, pFlightNumber, pFlightDate);
        //System.debug('JK: flightMasterKey - ' + flightMasterKey);
        //System.debug('Flight master key data :' + flightMasterKey);
        //System.debug('QUERY POINT');
        return [Select Id, Name, Leg_Number__c, Flight_Number__c, Flight_Date_UTC__c, Departure_STN__c, Arrival_STN__c
                From Flight__c Where Flight_Master__c = :flightMasterKey Order By Leg_Number__c ASC];
    }

    // ===== ===== ===== External ID ===== ===== =====
    public static String getFlightMasterKey(Flight__c pFlight, String pFlightNumber, String pFlightDate) {
        try {
            if (pFlight != null && pFlight.Flight_Master__c != null) {
                return pFlight.Flight_Master__c;
            } else {
                return BE8_GlobalConstants.DEFAULT_TG_COMPANY + pFlightNumber + '_' + BE8_DateUtility.convertToTGFlightDateformat(pFlightDate, '-');
            }
        } catch (Exception e) {
            return null;
        }
    }

    private static String getCustomerProfileExtId(Passenger__c pPassenger) {
        return pPassenger.First_Name__c + '_' + pPassenger.Last_Name__c + '_' + pPassenger.Date_of_Birth__c + '_' + pPassenger.Travel_Document_Number__c;
    }

    public static String getMemberExtId(String pAirline, String pNumber) {
        return pAirline + '_' + pNumber;
    }

    private static String getMemberExtId(Passenger__c pPassenger) {
        return getMemberExtId(pPassenger.FFP_Carrier__c, pPassenger.FFP_Number__c);
    }

    private static String str(String pData) {
        if (pData == null) {
            return '';
        }
        return pData.trim();
    }

    public static Account concreteAccount(Passenger__c pPassenger) {
        if (pPassenger.First_Name__c != null && pPassenger.Last_Name__c != null
                && pPassenger.Date_of_Birth__c != null && pPassenger.Travel_Document_Number__c != null
                && pPassenger.Date_of_Birth__c.trim().length() > 0 && pPassenger.Travel_Document_Number__c.trim().length() > 0) {
            Account a = new Account();

            a.Name = pPassenger.Last_Name__c + ' ' + pPassenger.First_Name__c;
            a.Customer_External_Id__c = getCustomerProfileExtId(pPassenger);
            a.First_Name__c = pPassenger.First_Name__c;
            a.Last_Name__c = pPassenger.Last_Name__c;
            a.Gender__c = BE8_GlobalConstants.MAP_ACCOUNT_GENDER.get(pPassenger.Gender__c);
            a.Email_1__c = pPassenger.Email_1__c;
            a.Mobile__c = pPassenger.Mobile__c;
            // a.Date_of_Birth__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, pPassenger.Date_of_Birth__c);
            try {
                if (pPassenger.Date_of_Birth__c != null) {
                    a.Date_of_Birth__c = BE8_DateUtility.getBirthDate(pPassenger.Date_of_Birth__c);
                }
            } catch (Exception e) {
                System.debug('ERROR while in concreteAccount set date of birth :' + pPassenger.Date_of_Birth__c + ' :' + e);
            }
            a.Travel_Document__c = pPassenger.Travel_Document_Number__c;
            a.Travel_Document_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, pPassenger.Travel_Document_Expiry_Date__c);
            a.Nationality__c = pPassenger.Nationality__c; //#1

            return a;
        }

        return null;
    }

    public static Membership__c concreteMembership(Passenger__c pPassenger) {
        if (pPassenger.FFP_Carrier__c == null || pPassenger.FFP_Number__c == null) {
            return null;
        }

        Membership__c m = new Membership__c();

        m.Name = pPassenger.FFP_Number__c;
        m.Airline__c = pPassenger.FFP_Carrier__c;
        m.Tier__c = pPassenger.FFP_Tier__c;
        m.EXTMember__c = getMemberExtId(pPassenger);
        m.Status__c = BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE;
        return m;
    }

    public static Travel_Document__c concreteTravelDocument(Passenger__c pPassenger) {
        if (pPassenger.Travel_Document_Number__c == null || pPassenger.Travel_Document_Number__c.trim().length() == 0) {
            return null;
        }

        // Passport / Travel document
        Travel_Document__c t = new Travel_Document__c();

        //t.AccountId__c
        t.Nationality__c = pPassenger.nationality__c; // #2
        t.Travel_Document_Number__c = pPassenger.Travel_Document_Number__c;
        t.ExtDocument__c = pPassenger.Travel_Document_Number__c;
        t.Travel_Document_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY,
                                           pPassenger.Travel_Document_Expiry_Date__c);

        return t;
    }

    public static void concreteFlightMap(List<Flight__c> pFlights, Map<Integer, Flight__c> mLegFlight, Map<String, Integer> mBp, Map<String, Integer> mOp) {
        if (pFlights != null) {
            for (Flight__c f : pFlights) {
                mLegFlight.put(Integer.valueOf(f.Leg_Number__c), f);
                mBp.put(f.Departure_STN__c, Integer.valueOf(f.Leg_Number__c));
                mOp.put(f.Arrival_STN__c, Integer.valueOf(f.Leg_Number__c));
            }
        }
    }

    public static Passenger__c clonePassenger(Passenger__c pPassenger) {
        Passenger__c p = new Passenger__c();

        p.AccountId__c = pPassenger.AccountId__c;

        p.SSR__c = pPassenger.SSR__c;
        p.Inbound__c = pPassenger.Inbound__c;
        p.Outbound__c = pPassenger.Outbound__c;
        p.Assigned_Seat__c = pPassenger.Assigned_Seat__c;

        p.Name = pPassenger.Name;
        p.Board_Point__c = pPassenger.Board_Point__c;
        p.Booking_Class__c = pPassenger.Booking_Class__c;
        p.Cabin_Code__c = pPassenger.Cabin_Code__c;
        p.First_Name__c = pPassenger.First_Name__c;
        p.Flight_Date__c = pPassenger.Flight_Date__c;

        p.Group_Name__c = pPassenger.Group_Name__c;
        p.Child__c = pPassenger.Child__c;
        p.Infant__c = pPassenger.Infant__c;
        p.Staff_Booking__c = pPassenger.Staff_Booking__c;
        p.Staff_Waitlist__c = pPassenger.Staff_Waitlist__c;
        p.Ticket__c = pPassenger.Ticket__c;
        //p.language__c
        p.Last_Name__c = pPassenger.Last_Name__c;
        p.Off_Point__c = pPassenger.Off_Point__c;
        p.PNR__c = pPassenger.PNR__c;
        //p.religion__c
        //p.remainingMiles__c
        p.Segment_Status__c = pPassenger.Segment_Status__c;

        p.WS_KEY__c = pPassenger.WS_KEY__c;

        p.SSR_Service__c = pPassenger.SSR_Service__c;
        p.Sector__c = pPassenger.Sector__c;
        p.Flight_Master__c = pPassenger.Flight_Master__c;

        p.Booking_Seat__c = pPassenger.Booking_Seat__c;
        p.Checkin_Seat__c = pPassenger.Checkin_Seat__c;

        p.Document_Type__c = pPassenger.Document_Type__c;
        p.Doc_Issuing_Country__c = pPassenger.Doc_Issuing_Country__c;
        p.Travel_Document_Number__c = pPassenger.Travel_Document_Number__c;
        p.Nationality__c = pPassenger.Nationality__c; // #3
        p.Date_of_Birth__c = pPassenger.Date_of_Birth__c;
        p.Gender__c = pPassenger.Gender__c;
        p.Travel_Document_Expiry_Date__c = pPassenger.Travel_Document_Expiry_Date__c;

        p.FFP_Carrier__c = pPassenger.FFP_Carrier__c;
        p.FFP_Number__c = pPassenger.FFP_Number__c;
        p.FFP_Tier__c = pPassenger.FFP_Tier__c;

        p.Mobile__c = pPassenger.Mobile__c;
        p.Email_1__c = pPassenger.Email_1__c;

        p.Special_Meal__c = pPassenger.Special_Meal__c;
        p.VIP_VVIP_Flag__c = pPassenger.VIP_VVIP_Flag__c;
        p.SSR_Service__c = pPassenger.SSR_Service__c;

        p.IgnoreProcessBuilder__c = pPassenger.IgnoreProcessBuilder__c;
        p.Source_Data__c = pPassenger.Source_Data__c;
        p.Date_of_Birth_Input__c = pPassenger.Date_of_Birth_Input__c;

        p.Infant_Name__c = null;
        p.Infant_Date_of_Birth__c = null;
        p.Infant_Name__c = pPassenger.Infant_Name__c;
        p.Infant_Date_of_Birth__c = pPassenger.Infant_Date_of_Birth__c;

        return p;
    }

    public static Map<String, Passenger__c> getPax(Flight__c pFlight, String flightNumber, String flightDate, String flightDateUTC, String boardPoint, String offPoint, Map<String, String> pMTotalCabin, Boolean isRetrialWithPreviousFlight) {
        Map<String, Passenger__c> paxMap = new Map<String, Passenger__c>();
        TG_PaxAll_WS.INVSBRPNRList_HTTP ws = new TG_PaxAll_WS.INVSBRPNRList_HTTP();
        ws.endpoint_x = getEndPoint();
        ws.Security = getSecurity();
        ws.timeout_x = getTimeout();
        ws.GetPaxNameListAllReqHeader = getHeader();
        TG_PaxAll_Result.IFLIRR data = null;

        //System.debug('start GetPaxNameListAll');
        try {
            data = ws.GetPaxNameListAll(BE8_GlobalConstants.DEFAULT_TG_COMPANY,
                                        flightNumber,
                                        BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, flightDate),
                                        boardPoint, // String BoardPoint
                                        offPoint, // String OffPoint
                                        null, // String BookingClass
                                        false, // Boolean InboundIndic
                                        false); // Boolean OutboundIndic
        } catch (Exception e) {
            String message = 'ERROR while call service pax all :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e + '\n'
                             + 'The web service will call out again with the prvious flight number if this flight has been changed before.';
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'getPax', BE8_GlobalConstants.LEVEL_DEBUG, message, pFlight.Flight_External_ID__c, PreFlightBatch.applicationLogCache);
            AppLogger.error(CLASS_NAME, 'getPax', pFlight.Flight_External_ID__c, message, e);
            Boolean alreadyRetriedWithPreviousFlight_NoNeedToRetryAnymore = isRetrialWithPreviousFlight;
            if (pFlight.Previous_Flight_Number__c != null && !alreadyRetriedWithPreviousFlight_NoNeedToRetryAnymore) {
                System.debug('Retrial with previous flight number');
                PreFlightBatch.retrialFlightListCache.add(pFlight);
            }
        }
        //System.debug('stop GetPaxNameListAll');

        if (data != null && data.BodyDetail != null) {
            for (TG_PaxAll_Result.Segment bodyDetail : data.bodyDetail) {
                if (bodyDetail.DefaultOutput != null) {
                    for (TG_PaxAll_Result.DefaultOutput defaultOutput : bodyDetail.DefaultOutput) {
                        Passenger__c p = new Passenger__c();
                        if (defaultOutput.Indicator != null) {
                            p.SSR__c = defaultOutput.Indicator.SSR;
                            p.Inbound__c = defaultOutput.Indicator.Inbound;
                            p.Outbound__c = defaultOutput.Indicator.Outbound;
                            p.Assigned_Seat__c = defaultOutput.Indicator.AssignedSeat;
                        }

                        p.Name = defaultOutput.TravellerSurname + ' ' + defaultOutput.TravellerFirstName;
                        p.Board_Point__c = bodyDetail.BoardPoint;
                        p.Booking_Class__c = defaultOutput.BookingClass;
                        p.Cabin_Code__c = defaultOutput.CabinCode;
                        p.First_Name__c = defaultOutput.TravellerFirstName;
                        //System.debug('TravellerFirstName: ' + defaultOutput.TravellerFirstName + ' TravellerSurname: ' + defaultOutput.TravellerSurname);
                        p.Flight_Date__c = flightDate;

                        p.Group_Name__c = defaultOutput.GroupName;
                        p.Child__c = defaultOutput.Child;
                        p.Infant__c = false;
                        //p.Infant__c = defaultOutput.Infant;
                        p.Staff_Booking__c = defaultOutput.StaffBooking;
                        p.Staff_Waitlist__c = defaultOutput.IsStaffWaitlist;
                        p.Ticket__c = defaultOutput.IsTicket;
                        //p.language__c
                        p.Last_Name__c = defaultOutput.TravellerSurname;
                        p.Off_Point__c = bodyDetail.OffPoint;
                        p.PNR__c = defaultOutput.RecordLocator;
                        //p.religion__c
                        //p.remainingMiles__c
                        p.Segment_Status__c = defaultOutput.SegmentStatus;

                        String wsKey = getPassengerWSKey(flightNumber,
                                                         flightDate,
                                                         defaultOutput.TravellerFirstName,
                                                         defaultOutput.TravellerSurname,
                                                         defaultOutput.RecordLocator);
                        //System.debug('wsKey: ' + wsKey);
                        p.WS_KEY__c = wsKey;

                        p.SSR_Service__c = '';
                        p.Special_Meal__c = '';
                        p.Sector__c = bodyDetail.BoardPoint + '-' + bodyDetail.offPoint;

                        p.Flight_Master__c = getFlightMasterKey(pFlight, flightNumber, flightDateUTC);

                        p.IgnoreProcessBuilder__c = true;
                        p.Source_Data__c = BE8_GlobalConstants.SOURCE_DATA_WEB_SERVICE;

                        // Clear Value before retrieving seat
                        p.Checkin_Seat__c = null;
                        p.Booking_Seat__c = null;

                        paxMap.put(wsKey, p);
                    }
                } else {
                    System.debug('Passenger size is NULL');
                }

                if (bodyDetail.TotalByCabin != null) {
                    for (TG_PaxAll_Result.TotalByCabin totalByCabin : bodyDetail.TotalByCabin) {
                        //System.debug('boardPoint :' + bodyDetail.BoardPoint + '-' +
                                     //'offPoint :' + bodyDetail.OffPoint + '-' +
                                     //totalByCabin.CabinCode + ' - ' + totalByCabin.Total);

                        String strKeyTotal =  bodyDetail.BoardPoint + '-' + bodyDetail.OffPoint;
                        String strTotal = pMTotalCabin.get(strKeyTotal);
                        if (strTotal == null) {
                            strTotal = totalByCabin.CabinCode + totalByCabin.Total;
                            pMTotalCabin.put(strKeyTotal, strTotal);
                        } else {
                            pMTotalCabin.put(strKeyTotal, strTotal + ' ' + totalByCabin.CabinCode + totalByCabin.Total);
                        }
                    }
                }
            }// End for(bodyDetail)
        }

        return paxMap;
    }

    private static TG_PaxAll_Result.IFLIRR getPaxFromPreviousFlight(Flight__c pFlight, String flightNumber, String flightDate, String boardPoint, String offPoint) {
        TG_PaxAll_Result.IFLIRR data = null;
        TG_PaxAll_WS.INVSBRPNRList_HTTP ws = new TG_PaxAll_WS.INVSBRPNRList_HTTP();
        ws.endpoint_x = getEndPoint();
        ws.Security = getSecurity();
        ws.timeout_x = getTimeout();
        try {
            data = ws.GetPaxNameListAll(BE8_GlobalConstants.DEFAULT_TG_COMPANY,
                                        flightNumber,
                                        BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, flightDate),
                                        boardPoint, // String BoardPoint
                                        offPoint, // String OffPoint
                                        null, // String BookingClass
                                        false, // Boolean InboundIndic
                                        false); // Boolean OutboundIndic
        } catch (Exception e) {
            String message = 'ERROR while call service pax all :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e + '\n'
                             + 'The web service will call out again with the prvious flight number if this flight has been changed before.';
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'getPax', BE8_GlobalConstants.LEVEL_DEBUG, message, pFlight.Flight_External_Id__c , PreFlightBatch.applicationLogCache);
            AppLogger.error(CLASS_NAME, 'getPaxFromPreviousFlight', pFlight.Flight_External_Id__c, message, e);
            return null;
        }
        return data;
    }

    public static String formatSeat(String pSeatData) {
        // If checkin seat data is in legal format (035D), remove the first 0 out of checkin seat value.
        // If checkin seat data is illegal format (035D/035D), do nothing.
        if (pSeatData != null && pSeatData.trim().length() < 6) {
            String strSeatData = pSeatData.trim();
            String strSeatColumn = strSeatData.substring(strSeatData.length() - 1, strSeatData.length());
            String strSeatRow = strSeatData.substring(0, strSeatData.length() - 1);
            try {
                return '' + Integer.valueOf(strSeatRow) + strSeatColumn;
            } catch (Exception e) {
                System.debug('ERROR while convert checkin seat row number to Integer :' + e);
            }
        }
        return pSeatData;
    }

    public static void getSeat(Map<String, Passenger__c> paxMap, String flightNumber, String flightDate, String boardPoint, String offPoint) {
        TG_PaxSeat_WS.INVSBRPNRList_HTTP ws = new TG_PaxSeat_WS.INVSBRPNRList_HTTP();
        ws.endpoint_x = getEndPoint();
        ws.Security = getSecurity();
        ws.timeout_x = getTimeout();
        ws.GetPaxNameListSeatReqHeader = getHeader();

        TG_PaxSeat_Result.IFLIRR data = null;

        try {
            data = ws.GetPaxNameListSeat(BE8_GlobalConstants.DEFAULT_TG_COMPANY,
                                         flightNumber,
                                         BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, flightDate), // Date DepartureDate
                                         boardPoint, // String BoardPoint
                                         offPoint, // String OffPoint
                                         null);
        } catch (Exception e) {
            String message = 'ERROR while call service pax seat :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'getSeat', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.error(CLASS_NAME, 'getSeat', flightNumber + flightDate, message, e);
        }

        if (data != null && data.BodyDetail != null) {
            for (TG_PaxSeat_Result.Segment bodyDetail : data.BodyDetail) {
                if (bodyDetail.SeatOutput != null) {
                    for (TG_PaxSeat_Result.SeatOutput seatOutput : bodyDetail.SeatOutput) {
                        Passenger__c p = paxMap.get(getPassengerWSKey(flightNumber, flightDate, seatOutput.TravellerFirstName, seatOutput.TravellerSurname, seatOutput.RecordLocator));
                        if (p != null) {
                            if (seatOutput.SeatRow != null && seatOutput.SeatColumn != null) {
                                p.Booking_Seat__c = '' + seatOutput.SeatRow + seatOutput.SeatColumn;
                            }

                            p.Checkin_Seat__c = seatOutput.CheckInSeat;
                            p.Checkin_Seat__c = formatSeat(p.Checkin_Seat__c);
                        }
                    }
                }
            }
        }
    }

    public static TG_PaxSSR_Req.SSRIndic buildSSRRequest(String[] ssrCodes) {
        TG_PaxSSR_Req.SSRIndic ssrIndics = new TG_PaxSSR_Req.SSRIndic();

        if (ssrCodes != null && ssrCodes.size() > 0) {
            Integer index = 0;
            ssrIndics.SSRCode = new String[ssrCodes.size()];
            for (String ssrCode : ssrCodes) {
                ssrIndics.SSRCode[index++] = ssrCode;
                // Limit 5 SSR codes only
                if (BE8_GlobalConstants.MAX_SSR_CODE == index) {
                    break;
                }
            }
        }

        return ssrIndics;
    }

    public static void getSSR(Map<String, Passenger__c> paxMap, String flightNumber, String flightDate, String boardPoint, String offPoint, String[] ssrCodes, List<String> rops) {
        TG_PaxSSR_WS.INVSBRPNRList_HTTP ws = new TG_PaxSSR_WS.INVSBRPNRList_HTTP();
        ws.endpoint_x = getEndPoint();
        ws.Security = getSecurity();
        ws.timeout_x = getTimeout();
        ws.GetPaxNameListSSRReqHeader = getHeader();

        TG_PaxSSR_Result.IFLIRR data = null;

        try {
            data = ws.GetPaxNameListSSR(BE8_GlobalConstants.DEFAULT_TG_COMPANY,
                                        flightNumber,
                                        BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, flightDate), // Date DepartureDate
                                        boardPoint, // String BoardPoint
                                        offPoint, // String OffPoint
                                        null, // String BookingClass
                                        buildSSRRequest(ssrCodes));
            //System.debug(System.JSON.serialize(data));
        } catch (Exception e) {
            String message = 'ERROR while call service pax ssr ' + ssrCodes + ' ' + buildSSRRequest(ssrCodes) + ' :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'getSSR', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'getSSR', flightNumber + flightDate, message, e);
        }

        if (data != null && data.BodyDetail != null) {
            for (TG_PaxSSR_Result.Segment bodyDetail : data.BodyDetail) {
                if (bodyDetail.SSROutput != null) {
                    for (TG_PaxSSR_Result.SSROutput ssrOutput : bodyDetail.SSROutput) {
                        Passenger__c p = paxMap.get(getPassengerWSKey(flightNumber, flightDate, ssrOutput.TravellerFirstName, ssrOutput.TravellerSurname, ssrOutput.RecordLocator));
                        if (p != null) {
                            if (ssrOutput.FQTInfo != null) {
                                ssrCodeHandler(p, ssrOutput.SSRCode, ssrOutput.FreeTxt, ssrOutput.ActionCode, ssrOutput.FQTInfo.Carrier, ssrOutput.FQTInfo.MemberNumber, ssrOutput.FQTInfo.TierLevel, rops);
                            } else {
                                ssrCodeHandler(p, ssrOutput.SSRCode, ssrOutput.FreeTxt, ssrOutput.ActionCode, null, null, null, null);
                            }
                            //System.debug('SSR output FirstName, Surname, PNR, email, mobile, nationality :' + ssrOutput.TravellerFirstName + ' - ' + ssrOutput.TravellerSurname + ' - ' + ssrOutput.RecordLocator + ' - ' + p.Email_1__c + ' - ' + p.Mobile__c + ' - ' + p.Nationality__c);
                            //System.debug('SSR output FirstName, Surname, PNR, email, mobile, nationality :' + ssrOutput.TravellerFirstName + ' - ' + ssrOutput.TravellerSurname + ' - ' + ssrOutput.RecordLocator + ' - ' + p.Email_1__c + ' - ' + p.Mobile__c); // #4
                        }
                    }
                }
            }
        }
    }

    private static Passenger__c handleDOCS_SSR(Passenger__c pax, String travellerDoc, String infantDoc) {
        if (travellerDoc != null) {
            String[] docs = travellerDoc.split('\\/');
            if (docs != null && docs.size() > 7) {
                pax.Document_Type__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_TRAVEL_DOC_TYPE];
                pax.Doc_Issuing_Country__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_DOC_ISSUING_COUNTRY];
                pax.Travel_Document_Number__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_DOC_NUMBER];
                pax.Nationality__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_NATIONALITY]; //#5
                pax.Date_of_Birth__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_DATE_OF_BIRTH];
                if (pax.Date_of_Birth__c != null) {
                    try {
                        pax.Date_of_Birth_Input__c = BE8_DateUtility.getBirthDate(pax.Date_of_Birth__c);
                    } catch (Exception e) {
                        System.debug('ERROR in ssrCodeHandler while converting birthdate :' + pax.Date_of_Birth__c);
                    }
                }
                pax.Gender__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_GENDER];
                pax.Travel_Document_Expiry_Date__c = docs[BE8_GlobalConstants.SSR_DOCS_IDX_DOC_EXPIRY_DATE];
            }
        }
        if (infantDoc != null) {
            String[] docs = infantDoc.split('\\/');
            if (docs != null && docs.size() > 7) {
                //System.debug('infantDoc DOCS: ' + docs);
                assignInfantDateOfBirth(pax, docs[BE8_GlobalConstants.SSR_DOCS_IDX_DATE_OF_BIRTH]);
                //pax.Infant__c = true;
            }
        }
        return pax;
    }

    private static void ssrCodeHandler(Passenger__c pax, String ssrCode, String freeText, String actionCode, String fqtCarrier, String fqtMemberNumber, String fqtTierLevel, List<String> rops) {
        if (BE8_GlobalConstants.SSR_CODE_DOCS.equals(ssrCode)) {
            handleDOCS_SSR(pax, freeText, null);
        } else if (BE8_GlobalConstants.SSR_CODE_FQTV.equals(ssrCode)) {
            pax.FFP_Carrier__c = fqtCarrier;
            pax.FFP_Number__c = fqtMemberNumber;
            if (BE8_GlobalConstants.SSR_TG_CARRIER.equals(fqtCarrier)) {
                rops.add(fqtMemberNumber);
            }
            pax.FFP_Tier__c = fqtTierLevel;
        } else if (BE8_GlobalConstants.SSR_CODE_CTCM.equals(ssrCode)) {
            pax.Mobile__c = freeText;
        } else if (BE8_GlobalConstants.SSR_CODE_CTCE.equals(ssrCode)) {
            pax.Email_1__c = freeText;
        } else if (BE8_GlobalConstants.SSR_CODE_SPML.equals(ssrCode)) {
            pax.Special_Meal__c = BE8_GlobalConstants.SSR_CODE_SPML + ' - ' + freeText;
            if (BE8_GlobalConstants.SSR_CONFIRM.equals(actionCode)) {
                pax.Special_Meal__c += BE8_GlobalConstants.SSR_GURANTEED;
            } else if (BE8_GlobalConstants.SSR_NOT_CONFIRM.equals(actionCode)) {
                pax.Special_Meal__c += BE8_GlobalConstants.SSR_NOT_GURANTEED;
            }
            pax.Special_Meal__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_MAAS.equals(ssrCode)) {
            if (freeText != null) {
                if (freeText.indexOf(BE8_GlobalConstants.SSR_MAAS_VIP) != -1 ||
                        freeText.indexOf(BE8_GlobalConstants.SSR_MAAS_VVIP) != -1) {
                    pax.VIP_VVIP_Flag__c = true;
                }
            }
            pax.SSR_Service__c += BE8_GlobalConstants.SSR_CODE_MAAS + ' - ' + str(freeText);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_INFT.equals(ssrCode)) {
            pax.Infant__c = true;
            if (freeText != null) {
                //System.debug('Debug SSR INFT :' + freeText);
                String[] strText = freeText.split(' ');

                // If infant is involved with birth date
                if (strText != null && strText.size() > 1) {
                    pax.Infant_Name__c = strText[0];
                    if (pax.Infant_Name__c != null) {
                        pax.Infant_Name__c = pax.Infant_Name__c.replaceAll('/', ' ');
                    }

                    assignInfantDateOfBirth(pax, strText[1]);
                }
                // Fix DEFECT :Infant doesn't displayed if birth date not included in web service
                // If infant is NOT involved with birth date
                else if (strText != null && strText.size() == 1) {
                    pax.Infant_Name__c = freeText;
                    if (pax.Infant_Name__c != null) {
                        pax.Infant_Name__c = pax.Infant_Name__c.replaceAll('/', ' ');
                    }
                }
            }
        } else if (BE8_GlobalConstants.SSR_CODE_LANG.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_UMNR.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_DEAF.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_MEDA.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_DEPA.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_DEPU.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_AVIH.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_PETC.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_WEAP.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_CBBG.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_EXST.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_COUR.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else if (BE8_GlobalConstants.SSR_CODE_BLND.equals(ssrCode)) {
            pax.SSR_Service__c += str(ssrCode);
            pax.SSR_Service__c += '\n';
        } else {
            if (ssrCode != null) {
                if (ssrCode.contains('ML')) {
                    if (BE8_GlobalConstants.SSR_CONFIRM.equals(actionCode)) {
                        ssrCode += BE8_GlobalConstants.SSR_GURANTEED;
                    } else if (BE8_GlobalConstants.SSR_NOT_CONFIRM.equals(actionCode)) {
                        ssrCode += BE8_GlobalConstants.SSR_NOT_GURANTEED;
                    }

                    pax.Special_Meal__c += str(ssrCode);
                    pax.Special_Meal__c += '\n';
                } else if (ssrCode.contains('WC')) {
                    if (BE8_GlobalConstants.SSR_CONFIRM.equals(actionCode)) {
                        ssrCode += BE8_GlobalConstants.SSR_GURANTEED;
                    } else if (BE8_GlobalConstants.SSR_NOT_CONFIRM.equals(actionCode)) {
                        ssrCode += BE8_GlobalConstants.SSR_NOT_GURANTEED;
                    }

                    pax.SSR_Service__c += str(ssrCode);
                    pax.SSR_Service__c += '\n';
                }
            }
        }
    }

    public static Map<String, Passenger__c> preparePassenger(Flight__c pFlight, String flightNumber, String flightDate, String flightDateUTC, String boardPoint, String offPoint, List<String> pRops, Map<String, String> pMTotalCabin) {
        return preparePassenger(pFlight, flightNumber, flightDate, flightDateUTC, boardPoint, offPoint, pRops, pMTotalCabin, false);
    }

    public static Map<String, Passenger__c> preparePassenger(Flight__c pFlight, String flightNumber, String flightDate, String flightDateUTC, String boardPoint, String offPoint, List<String> pRops, Map<String, String> pMTotalCabin, Boolean isRetrialWithPreviousFlight) {
        // Get passenger information
        Map<String, Passenger__c> mPax = getPax(pFlight, flightNumber, flightDate, flightDateUTC, boardPoint, offPoint, pMTotalCabin, isRetrialWithPreviousFlight);

        // Update seat information
        getSeat(mPax, flightNumber, flightDate, boardPoint, offPoint);

        try {
            // Update passport, birthdate, mobile, email, membership, infant
            // SSR DOCS, INFT, FQTV, CTCM, CTCE
            getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint,
                   new String[] {BE8_GlobalConstants.SSR_CODE_BLND, BE8_GlobalConstants.SSR_CODE_INFT,
                                 BE8_GlobalConstants.SSR_CODE_FQTV, BE8_GlobalConstants.SSR_CODE_CTCM,
                                 BE8_GlobalConstants.SSR_CODE_CTCE
                                }, pRops);
        } catch (Exception e) {
            String message = 'ERROR while call service get ssr :DOCS, INFT, FQTV, CTCM, CTCE :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'preparePassenger', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'preparePassenger.getSSR1', flightNumber + flightDate, message, e);
        }

        try {
            // SSR MAAS, LANG, WCXX, UMNR, DEAF
            getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint,
                   new String[] {BE8_GlobalConstants.SSR_CODE_MAAS, BE8_GlobalConstants.SSR_CODE_LANG,
                                 BE8_GlobalConstants.SSR_CODE_WCXX, BE8_GlobalConstants.SSR_CODE_UMNR,
                                 BE8_GlobalConstants.SSR_CODE_DEAF
                                }, null);
        } catch (Exception e) {
            String message = 'ERROR while call service get ssr :MAAS, LANG, WCHR, UMNR, DEAF :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'preparePassenger', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'preparePassenger.getSSR2', flightNumber + flightDate, message, e);
        }

        try {
            // SSR MEDA, DEPA, DEPU, AVIH, PETC
            getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint,
                   new String[] {BE8_GlobalConstants.SSR_CODE_MEDA, BE8_GlobalConstants.SSR_CODE_DEPA,
                                 BE8_GlobalConstants.SSR_CODE_DEPU, BE8_GlobalConstants.SSR_CODE_AVIH,
                                 BE8_GlobalConstants.SSR_CODE_PETC
                                }, null);
        } catch (Exception e) {
            String message = 'ERROR while call service get ssr :MEDA, DEPA, DEPU, AVIH, PETC :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'preparePassenger', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'preparePassenger.getSSR3', flightNumber + flightDate, message, e);
        }

        try {
            // SSR WEAP, CBBG, EXST, COUR, XXML
            getSSR(mPax, flightNumber, flightDate, boardPoint, offPoint,
                   new String[] {BE8_GlobalConstants.SSR_CODE_WEAP, BE8_GlobalConstants.SSR_CODE_CBBG,
                                 BE8_GlobalConstants.SSR_CODE_EXST, BE8_GlobalConstants.SSR_CODE_COUR,
                                 BE8_GlobalConstants.SSR_CODE_XXML
                                }, null);
        } catch (Exception e) {
            String message = 'ERROR while call service get ssr :WEAP, CBBG, EXST, COUR, XXML :' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'preparePassenger', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'preparePassenger.getSSR4', flightNumber + flightDate, message, e);
        }

        try {
            // DOCS
            getDOCS(mPax, flightNumber, flightDate, boardPoint, offPoint);
        } catch (Exception e) {
            String message = 'ERROR while call DOCS Shenzhen:' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e.getMessage() + e.getStackTraceString();
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'preparePassenger', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'preparePassenger.getDOCS', flightNumber + flightDate, message, e);
        }

        //try{
        //    List<Map<String, String>> filterListMap = new List<Map<String, String>>();
        //    List<String> groupIndicator = new List<String>();
        //    groupIndicator.add('OFD')
        //    CSE_SOAPNewPaxList_WS ws = new CSE_SOAPNewPaxList_WS();
        //    String fltNo = String.valueOf(Integer.valueOf(pflight.Flight_Number__c.remove('TG')));
        //    WS_New_Pax_List_Model newPaxListModel = ws.getPaxModel(filterListMap, groupIndicator, 'TG', fltNo, pflight.Flight_Date_UTC__c, pflight.Departure_STN__c);
        //    New_Pax_List_Management.updatePaxConnectingFltInfo(mPax.values(), pflight, newPaxListModel);
        //    System.debug('JK: execute New Pax List');
        //    System.debug(mPax);
        //    //New_Pax_List_Management.updatePaxConnectingFltInfo(mPax.values(), pFlight);
        //}
        //catch(Exception e){
        //    String message = 'ERROR while call New Pax List:' +
        //                     flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
        //                     ' :' + e;
        //    BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'preparePassenger', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
        //}

        //System.debug('Passenger size :' + mPax.size());
        return mPax;
    }

    public static Map<String, Account> getMapPaxAccountFromMember(Map<String, Passenger__c> pMPax) {
        Map<String, Account> mPaxAccount = new Map<String, Account>();
        Map<String, String> mMemberPax = new Map<String, String>();
        Set<String> sMemberExt = new Set<String>();
        List<Passenger__c> pPassengers = null;

        if (pMPax == null || pMPax.isEmpty()) {
            return mPaxAccount;
        }

        pPassengers = pMPax.values();

        // Preparing membership condition
        for (Passenger__c p : pPassengers) {
            //System.debug('Debug pax membership :' + p.WS_KEY__c + ' - ' + p.FFP_Carrier__c + ' - ' + p.FFP_Number__c);

            if (p.FFP_Carrier__c != null && p.FFP_Number__c != null
                    && p.FFP_Carrier__c.trim().length() > 0 && p.FFP_Number__c.trim().length() > 0) {
                String strMembershipKey = getMemberExtId(p.FFP_Carrier__c, p.FFP_Number__c);
                mMemberPax.put(strMembershipKey, p.WS_KEY__c); // Mapping between EXTMember__c and WS_KEY__c
                sMemberExt.add(strMembershipKey); // For searching
            }
        }

        //System.debug('QUERY POINT');

        // Find account by membership external id and airline is TG
        for (Membership__c member : [Select Id, EXTMember__c, AccountId__c, AccountId__R.Name, AccountId__R.First_Name__c, AccountId__R.Last_Name__c From Membership__c Where Airline__c = 'TG' And EXTMember__c In :sMemberExt]) {
            if (member.AccountId__c != null) {
                //System.debug('Debug get account from member : Found member/account/paxWSKey :' +
                //             member.EXTMember__c + '/' + member.AccountId__R.Name + ' ===== ' +
                //             member.AccountId__R.First_Name__c + '/' + member.AccountId__R.Last_Name__c + '=====' +
                //             mMemberPax.get(member.EXTMember__c));

                Account a = new Account();
                a.Id = member.AccountId__c;

                mPaxAccount.put(mMemberPax.get(member.EXTMember__c), a);
            }
        }

        return mPaxAccount;
    }

    public static void updateAccountFromMember(Map<String, Account> pMPaxAcc, Map<String, Passenger__c> pMPax) {
        if (pMPaxAcc == null || pMPaxAcc.isEmpty() || pMPax == null || pMPax.isEmpty()) {
            return;
        }

        Set<String> sPaxWSKey = pMPaxAcc.keySet();
        for (String key : sPaxWSKey) {
            Passenger__c p = pMPax.get(key);
            if (p != null) {
                Account a = pMPaxAcc.get(key);
                if (a.Date_of_Birth__c == null) {
                    //a.Date_of_Birth__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, p.Date_of_Birth__c);
                    if (p.Date_of_Birth__c != null) {
                        try {
                            a.Date_of_Birth__c = BE8_DateUtility.getBirthDate(p.Date_of_Birth__c);
                        } catch (Exception e) {
                            System.debug('ERROR in updateAccountFromMember while convert birth date :' + p.Date_of_Birth__c + ' :' + e);
                        }
                    }
                }
                if (p.Travel_Document_Number__c != null) {
                    a.Travel_Document__c = p.Travel_Document_Number__c;
                }
                if (p.Travel_Document_Expiry_Date__c != null) {
                    a.Travel_Document_Expiry_Date__c = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_DDMMMYY, p.Travel_Document_Expiry_Date__c);
                }
            }
        }
    }

    public static Map<String, Account> getMapPaxAccountFromFLBP(List<Passenger__c> pPassengers) {
        Map<String, Account> mPaxAccount = new Map<String, Account>();
        if (pPassengers == null) {
            return mPaxAccount;
        }

        for (Passenger__c p : pPassengers) {
            //System.debug('Before concrete account FLBP :' + p.First_Name__c + ' - ' + p.Last_Name__c + ' - ' + p.Date_of_Birth__c + ' - ' + p.Travel_Document_Number__c);

            Account acc = concreteAccount(p);
            if (acc != null) {
                mPaxAccount.put(p.WS_KEY__c, acc);
            }
        }

        return mPaxAccount;
    }

    public static void filterMapPaxAccountFromFLBP(Map<String, Account> pMPaxAccFLBP, Set<String> pFilters) {
        if (pFilters == null || pMPaxAccFLBP == null) {
            return;
        }

        // If account has ROP relate, use ROP account instead of FLBP
        for (String key : pFilters) {
            pMPaxAccFLBP.remove(key);
        }
    }

    public static Map<String, Travel_Document__c> getMapPaxTravelDoc(List<Passenger__c> pPassengers) {
        Map<String, Travel_Document__c> mPaxTravelDoc = new Map<String, Travel_Document__c>();

        if (pPassengers == null) {
            return mPaxTravelDoc;
        }

        for (Passenger__c p : pPassengers) {
            Travel_Document__c t = concreteTravelDocument(p);
            if (t != null) {
                mPaxTravelDoc.put(p.WS_KEY__c, t);
            }
        }

        return mPaxTravelDoc;
    }

    public static Map<String, Membership__c> getMapPaxMember(List<Passenger__c> pPassengers) {
        Map<String, Membership__c> mPaxMem = new Map<String, Membership__c>();

        if (pPassengers == null) {
            return mPaxmem;
        }

        for (Passenger__c p : pPassengers) {
            Membership__c m = concreteMembership(p);
            if (m != null) {
                mPaxMem.put(p.WS_KEY__c, m);
            }
        }

        return mPaxMem;
    }

    public static List<Passenger__c> getClonePassenger(Flight__c pFlight , List<Passenger__c> pPassengers, String pFlightNumber, String pFlightDate) {
        List<Passenger__c> clonePaxs = new List<Passenger__c>();

        if (pPassengers == null || pPassengers.isEmpty()) {
            return clonePaxs;
        }

        // Map leg number i.e. :leg number(1), Flight__c(1)
        Map<Integer, Flight__c> mLegFlight = new Map<Integer, Flight__c>();
        // I.E. :Leg 1 = BKK(1)-HKG(1), Leg 2 = HKG(2)-ICN(2), Leg 3 = ICN(3)-CDG(3)
        // Map boardPoint with leg :i.e. :'BKK', 1
        Map<String, Integer> mBp = new Map<String, Integer>();
        // Map offPoint with leg :i.e. :'CDG', 3, ''
        Map<String, Integer> mOp = new Map<String, Integer>();

        Integer startLeg = -1;
        Integer endLeg = -1;
        Integer index = 0;

        List<Flight__c> flights = findFlight(pFlight, pFlightNumber, pFlightDate);
        //System.debug('Flights size :' + flights.size());
        concreteFlightMap(flights, mLegFlight, mBp, mOp);
        for (Passenger__c p : pPassengers) {

            startLeg = mBp.get(p.Board_Point__c);
            endLeg = mOp.get(p.Off_Point__c);

            if (startLeg != null && endLeg != null && startLeg > 0 && endLeg > 0) {
                //System.debug('start-end leg :' + startLeg + ' ' + endLeg);
                // start leg = end leg (this route can be mapped to flight leg), no clone
                if (startLeg == endLeg) {
                    p.WS_KEY__c += ('_' + startLeg);
                    //p.FlightId__c = mLegFlight.get(startLeg).Id; // Assign flight to passenger
                    if (mLegFlight.get(startLeg).Id != null) {
                        p.FlightId__c = mLegFlight.get(startLeg).Id;
                    } else {
                        p.FlightId__r = new Flight__c (Flight_External_Id__c = mLegFlight.get(startLeg).Flight_External_Id__c); // Assign flight to passenger
                    }
                }
                // start leg <> end leg, clone passenger and assign flight
                else if (endLeg > startLeg) {
                    String[] checkInSeats = null;
                    Integer indexSeat = -1;
                    if (p.Checkin_Seat__c != null && p.Checkin_Seat__c.contains('/')) {
                        checkInSeats = p.Checkin_Seat__c.split('/');
                        //System.debug('CheckInSeat :' + checkInSeats);
                        if (checkInSeats != null) {
                            indexSeat = checkInSeats.size() - 1;
                        }
                    }

                    for (index = startLeg; index < endLeg; index++) {
                        Passenger__c clonePax = clonePassenger(p);

                        clonePax.WS_KEY__c += ('_' + (index + 1));
                        if (mLegFlight.get((index + 1)).Id != null) {
                            clonePax.FlightId__c = mLegFlight.get((index + 1)).Id;
                        } else {
                            clonePax.FlightId__r = new Flight__c (Flight_External_Id__c = mLegFlight.get(startLeg).Flight_External_Id__c);
                        }

                        if (indexSeat > -1) {
                            try {
                                clonePax.Checkin_Seat__c = checkInSeats[indexSeat--];
                                clonePax.Checkin_Seat__c = formatSeat(clonePax.Checkin_Seat__c);
                            } catch (Exception e) {
                                System.debug('ERROR while assign checkin seat to cloned passenger :' + e);
                            }
                        }
                        clonePaxs.add(clonePax);
                    }
                    p.WS_KEY__c += ('_' + startLeg);
                    if (mLegFlight.get(startLeg).Id != null) {
                        p.FlightId__c = mLegFlight.get(startLeg).Id; // Assign flight to original passenger
                    } else {
                        p.FlightId__r = new Flight__c (Flight_External_Id__c = mLegFlight.get(startLeg).Flight_External_Id__c);

                    }
                    if (checkInSeats != null && checkInSeats.size() > 0) {
                        p.Checkin_Seat__c = formatSeat(checkInSeats[0]);
                    }
                }

                //System.debug('FlightID :' + p.FlightId__c);
            }
            startLeg = -1;
            endLeg = -1;
            index = 0;
            //System.debug('Debug pax origin :' + p.First_Name__c + ' / ' + p.Last_Name__c + ' / ' + p.WS_KEY__c);
        }// End for

        //for (Passenger__c p : clonePaxs) {
        //    System.debug('Debug pax cloned :' + p.First_Name__c + ' / ' + p.Last_Name__c + ' / ' + p.WS_KEY__c);
        //}

        return clonePaxs;
    }

    public static void assignAccountToPassenger(Map<String, Passenger__c> pMPax, Map<String, Account> pMPaxAccMember, Map<String, Account> pMPaxAccFLBP) {
        if (pMPax == null || pMPaxAccMember == null || pMPaxAccFLBP == null) {
            return;
        }

        // Transform pMPaxAccFLBP from using PaxWSKey as key to using Customer_External_Id__c as key
        Map<String, Account> accountMapByCustomerExternalId = new Map<String, Account>();
        for (Account each : pMPaxAccFLBP.values()) {
            accountMapByCustomerExternalId.put(each.Customer_External_Id__c, each);
        }
        /////////////////////////////////////////////////////////////////////////////////

        Set<String> sPaxWSKey = pMpax.keySet();
        for (String key : sPaxWSKey) {
            Passenger__c passenger = pMPax.get(key);
            Account a = pMPaxAccMember.get(key);
            if (a != null) {
                a.Customer_External_Id__c = getCustomerProfileExtId(passenger); // Update customer external id to Account
                passenger.AccountId__c = a.Id;
                continue;
            }

            String customerExternalId = getCustomerProfileExtId(passenger);
            //a = pMPaxAccFLBP.get(key);
            a = accountMapByCustomerExternalId.get(customerExternalId);
            if (a != null) {
                passenger.AccountId__c = a.Id;
            }
        }
    }

    public static void assignAccountToClonedPassenger(Map<String, Passenger__c> pMPax, List<Passenger__c> pLClonePax) {
        if (pMPax == null || pMPax.isEmpty() || pLClonePax == null || pLClonePax.isEmpty()) {
            System.debug('Either pMPax is empty or pLClonePax is empty');
            return;
        }

        // I.E. cloned passenger WS_Key__c :0634_2016-11-19_VORATHIDA_TANGITVET_2ATLKU_2
        for (Passenger__c p : pLClonePax) {
            if (p.WS_KEY__c != null) {
                Integer index = p.WS_KEY__c.lastIndexOf('_');
                if (index > -1) {
                    String k = p.WS_KEY__c.substring(0, index);
                    //System.debug('Assign account to cloned pax : KEY :' + k);
                    if (k != null && pMPax.get(k) != null) {
                        p.AccountId__c = pMPax.get(k).AccountId__c;
                    }
                }// End if(index > -1)
            }// End if(p.WS_KEY__c
        }// End for(Passenger__c p
    }

    public static void assignAccountToTravelDoc(Map<String, Travel_Document__c> pMPaxDoc, Map<String, Account> pMPaxAccMember, Map<String, Account> pMPaxAccFLBP) {
        if (pMPaxDoc == null || pMPaxAccMember == null || pMPaxAccFLBP == null) {
            return;
        }

        Set<String> sPaxWSKey = pMPaxDoc.keySet();
        for (String key : sPaxWSKey) {
            // Assign account from membership to travel document first
            Account a = pMPaxAccMember.get(key);
            if (a != null) {
                pMPaxDoc.get(key).AccountId__c = a.Id;
                continue;
            }

            // If not found account from membership, assign account from FLBP instead
            a = pMPaxAccFLBP.get(key);
            if (a != null) {
                pMPaxDoc.get(key).AccountId__c = a.Id;
            } else {
                pMPaxDoc.remove(key);
            }
        }
    }

    public static void assignAccountFLBPToMembership(Map<String, Membership__c> pMPaxMem, Map<String, Account> pMPaxAccFLBP, Map<String, Account> mPaxAccMember) {
        if (pMPaxMem == null || pMPaxAccFLBP == null) {
            return;
        }

        for (String key : pMPaxMem.keySet()) {
            Account a = pMPaxAccFLBP.get(key);
            if (a == null) {
                a = mPaxAccMember.get(key);
            }
            // If found FLBP account which related to membership, assign Id to membership and upsert this membership to database later
            if (a != null) {
                pMPaxMem.get(key).AccountId__c = a.Id;
            }

            // Not found FLBP account for this membership, remove this membership from Map (Not upsert this membership to database)
            else {
                Membership__c m = pMPaxMem.get(key);
                //if (m != null) {
                //    System.debug('Debug Remove memebership :' + key + ' - ' +
                //                 m.Name + ' - ' +
                //                 m.Airline__c + ' - ' +
                //                 m.Tier__c);
                //}
                pMPaxMem.remove(key);
            }
        }
    }

    public static Map<String, Integer> prepareConfig(String pConfig) {
        Map<String, Integer> mConfig = new Map<String, Integer>();
        if (pConfig != null) {
            String[] configs = pConfig.split(' ');
            if (configs != null && configs.size() > 0) {
                String strConfig = null;
                String strTotal = null;
                for (String c : configs) {
                    if (c != null && c.length() > 1) {
                        c = c.trim();
                        strConfig = c.substring(0, 1);
                        strTotal = c.replace(strConfig, '');
                        try {
                            mConfig.put(strConfig, Integer.valueOf(strTotal));
                        } catch (Exception e) {
                            mConfig.put(strConfig, 0);
                        }

                    }
                }
            }
        }
        return mConfig;
    }

    public static String combineConfig(String pExist, String pNew) {
        String result = '';
        Map<String, Integer> mConfigExist = new Map<String, Integer>();
        Map<String, Integer> mConfigNew = new Map<String, Integer>();

        mConfigExist = prepareConfig(pExist);
        mConfigNew = prepareConfig(pNew);

        for (String key : mConfigNew.keySet()) {
            Integer newValue = mConfigNew.get(key);
            Integer existValue = mConfigExist.get(key);
            if (existValue != null) {
                if (newValue != null) {
                    mConfigExist.put(key, existValue + newValue);
                }
            } else {
                mConfigExist.put(key, newValue);
            }
        }

        for (String key : mConfigExist.keySet()) {
            result += key + mConfigExist.get(key) + ' ';
        }

        return result.trim();
    }

    public static void combineFlightBookingPax(Map<String, String> mSectorCabin, String pNewTotalCabin) {
        if (mSectorCabin != null) {
            for (String key : mSectorCabin.keySet()) {
                String existValue = mSectorCabin.get(key);
                String newValue = combineConfig(existValue, pNewTotalCabin);
                mSectorCabin.put(key, newValue);
            }
        }
    }

    public static List<Flight__c> concreteFlightBookingPax(Flight__c pFlight, String pFlightNumber, String pFlightDate, Map<String, String> pMTotalCabin) {
        List<Flight__c> flights = findFlight(pFlight, pFlightNumber, pFlightDate);
        Map<String, Flight__c> mSectorFlight = new Map<String, Flight__c>();
        Map<String, String> mSectorCabin = new Map<String, String>();

        if (flights != null && pMTotalCabin != null && !pMTotalCabin.isEmpty()) {
            String strSector = '';
            // Prepare map
            for (Flight__c f : flights) {
                strSector = f.Departure_STN__c + '-' + f.Arrival_STN__c;
                mSectorFlight.put(strSector, f);
                //System.debug('Flight Sector :' + strSector);
                String strBookingConfg = pMTotalCabin.get(strSector);
                if (strBookingConfg != null) {
                    mSectorCabin.put(strSector, pMTotalCabin.get(strSector));
                }
            }

            // Support for flight with 2 legs
            for (String key : pMTotalCabin.keySet()) {
                if (mSectorCabin.get(key) == null) {
                    combineFlightBookingPax(mSectorCabin, pMTotalCabin.get(key));
                }
            }

            // Update flight - booking passenger
            for (String key : mSectorFlight.keySet()) {
                Flight__c f = mSectorFlight.get(key);
                if (f != null) {
                    f.Booking_Passengers__c = mSectorCabin.get(key);
                }
            }

            if (mSectorFlight != null && !mSectorFlight.isEmpty()) {
                return mSectorFlight.values();
            }
        }

        return null;
    }

    public static Map<String, Object> updatePax(Flight__c pFlight, String flightNumber, String flightDate, String boardPoint, String offPoint, String flightDateUTC) {
        //Map<String, Object> mInfo = new Map<String, Object>();
        ////System.debug('Flight :' + flightNumber + ' - ' + flightDate + ' - UTC :' + flightDateUTC);
        //List<String> rops = new List<String>();
        //Map<String, String> mTotalCabin = new Map<String, String>();
        //Map<String, Passenger__c> mPax = preparePassenger(pFlight, flightNumber, flightDate, flightDateUTC, boardPoint, offPoint, rops, mTotalCabin);

        //Map<String, Account> mPaxAccMember = getMapPaxAccountFromMember(mPax); // Existing account only
        //Map<String, Account> mPaxAccFLBP = getMapPaxAccountFromFLBP(mPax.values()); // New / existing account
        //filterMapPaxAccountFromFLBP(mPaxAccFLBP, mPaxAccMember.keySet()); // Filter mPaxAccFLBP account, this account should not created if there is ROP account

        //Map<String, Travel_Document__c> mPaxDoc = getMapPaxTravelDoc(mPax.values());
        //Map<String, Membership__c> mPaxMem = getMapPaxMember(mPax.values());

        //// Prevent duplicated ROP numbers
        //if (rops != null) {
        //    Map<String, String> mRops = new Map<String, String>();
        //    for (String r : rops) {
        //        //System.debug('Debug ROP number :' + r);
        //        mRops.put(r, r);
        //    }
        //    rops = mRops.values();
        //}

        //// Update Membership account
        //updateAccountFromMember(mPaxAccMember, mPax); // Update travel document, travel document expire date to Account

        //mInfo.put('PAX-ACC-Member', mPaxAccMember);
        //mInfo.put('PAX-ACC_FLBP', mPaxAccFLBP);
        //mInfo.put('PAX-DOC', mPaxDoc);
        //mInfo.put('PAX-MEM', mPaxMem);
        //mInfo.put('PAX', mPax);
        //mInfo.put('PAX-CLONE', getClonePassenger(pFlight, mPax.values(), flightNumber, flightDateUTC));
        //mInfo.put('PAX-CABIN', concreteFlightBookingPax(pFlight, flightNumber, flightDateUTC, mTotalCabin));

        //mInfo.put('PAX-ROP', rops);

        return updatePax(pFlight, flightNumber, flightDate, boardPoint, offPoint, flightDateUTC, false);
    }

    public static Map<String, Object> updatePax(Flight__c pFlight, String flightNumber, String flightDate, String boardPoint, String offPoint, String flightDateUTC, Boolean isRetrialWithPreviousFlight) {
        Map<String, Object> mInfo = new Map<String, Object>();
        //System.debug('Flight :' + flightNumber + ' - ' + flightDate + ' - UTC :' + flightDateUTC);
        List<String> rops = new List<String>();
        Map<String, String> mTotalCabin = new Map<String, String>();
        Map<String, Passenger__c> mPax = preparePassenger(pFlight, flightNumber, flightDate, flightDateUTC, boardPoint, offPoint, rops, mTotalCabin, isRetrialWithPreviousFlight);

        Map<String, Account> mPaxAccMember = getMapPaxAccountFromMember(mPax); // Existing account only
        Map<String, Account> mPaxAccFLBP = getMapPaxAccountFromFLBP(mPax.values()); // New / existing account
        filterMapPaxAccountFromFLBP(mPaxAccFLBP, mPaxAccMember.keySet()); // Filter mPaxAccFLBP account, this account should not created if there is ROP account

        Map<String, Travel_Document__c> mPaxDoc = getMapPaxTravelDoc(mPax.values());
        Map<String, Membership__c> mPaxMem = getMapPaxMember(mPax.values());

        // Prevent duplicated ROP numbers
        if (rops != null) {
            Map<String, String> mRops = new Map<String, String>();
            for (String r : rops) {
                //System.debug('Debug ROP number :' + r);
                mRops.put(r, r);
            }
            rops = mRops.values();
        }

        // Update Membership account
        updateAccountFromMember(mPaxAccMember, mPax); // Update travel document, travel document expire date to Account

        mInfo.put('PAX-ACC-Member', mPaxAccMember);
        mInfo.put('PAX-ACC_FLBP', mPaxAccFLBP);
        mInfo.put('PAX-DOC', mPaxDoc);
        mInfo.put('PAX-MEM', mPaxMem);
        mInfo.put('PAX', mPax);
        mInfo.put('PAX-CLONE', getClonePassenger(pFlight, mPax.values(), flightNumber, flightDateUTC));
        mInfo.put('PAX-CABIN', concreteFlightBookingPax(pFlight, flightNumber, flightDateUTC, mTotalCabin));

        mInfo.put('PAX-ROP', rops);

        return mInfo;
    }

    private static Map<String, Object> updatePassengerInformation(Flight__c pFlight, String flightNumber, String flightDate, String boardPoint, String offPoint, String flightDateUTC) {
        if (flightNumber != null && flightNumber.indexOf(BE8_GlobalConstants.DEFAULT_TG_COMPANY) != -1) {
            flightNumber = flightNumber.replace(BE8_GlobalConstants.DEFAULT_TG_COMPANY, '');
        }
        return updatePax(pFlight, flightNumber, flightDate, boardPoint, offPoint, flightDateUTC);
    }

    private static Map<String, Object> updatePassengerInformation(Flight__c pFlight, String flightNumber, String flightDate, String boardPoint, String offPoint, String flightDateUTC, Boolean isRetrialWithPreviousFlight) {
        if (flightNumber != null && flightNumber.indexOf(BE8_GlobalConstants.DEFAULT_TG_COMPANY) != -1) {
            flightNumber = flightNumber.replace(BE8_GlobalConstants.DEFAULT_TG_COMPANY, '');
        }
        return updatePax(pFlight, flightNumber, flightDate, boardPoint, offPoint, flightDateUTC, isRetrialWithPreviousFlight);
    }

    public static Map<String, Object> updatePassengerInformation(Flight__c pFlight) {
        String strFlightDateUTC = pFlight.Flight_Date_UTC__c;
        String strFlightDateLT = pFlight.Flight_Date_LT__c;

        //System.debug('Debug updatePassengerInformation flightNumber/flightDateUTC/fightDateLT :' +
        //             pFlight.Flight_Number__c + '/' + strFlightDateUTC + '/' + strFlightDateLT);

        if (strFlightDateUTC != null && strFlightDateLT != null) {
            strFlightDateUTC = strFlightDateUTC.trim();
            strFlightDateLT = strFlightDateLT.trim();

            // If flightDateUTC = flightDateLT, query passenger using flight date UTC
            if (strFlightDateUTC.equals(strFlightDateLT)) {
                return updatePassengerInformation(pFlight, pFlight.Flight_Number__c,
                                                  strFlightDateUTC,
                                                  null,
                                                  null,
                                                  strFlightDateUTC);
            }

            // else query passenger using flight date LT (This case for flight TG910 after 12PM)
            else {
                return updatePassengerInformation(pFlight, pFlight.Flight_Number__c,
                                                  strFlightDateLT,
                                                  null,
                                                  null,
                                                  strFlightDateUTC);
            }
        }

        //System.debug('Debug updatePassengerInformation NOT update passenger due to either flight date UTC ore flight date LT are NULL or both are NULL use flight_date_utc__c.');
        return updatePassengerInformation(pFlight, pFlight.Flight_Number__c,
                                          pFlight.Flight_Date_UTC__c,
                                          null,
                                          null,
                                          pFlight.Flight_Date_UTC__c);
    }

    public static Map<String, Object> updatePassengerInformation(Flight__c pFlight, Boolean isRetrialWithPreviousFlight) {
        String strFlightDateUTC = pFlight.Flight_Date_UTC__c;
        String strFlightDateLT = pFlight.Flight_Date_LT__c;

        //System.debug('Debug updatePassengerInformation flightNumber/flightDateUTC/fightDateLT :' +
        //             pFlight.Flight_Number__c + '/' + strFlightDateUTC + '/' + strFlightDateLT);

        if (strFlightDateUTC != null && strFlightDateLT != null) {
            strFlightDateUTC = strFlightDateUTC.trim();
            strFlightDateLT = strFlightDateLT.trim();

            if (!isRetrialWithPreviousFlight) {
                return updatePassengerInformation(pFlight, pFlight.Flight_Number__c,
                                                  strFlightDateLT,
                                                  null,
                                                  null,
                                                  strFlightDateUTC);
            } else {
                if (pFlight.Previous_Flight_Number__c == null) {
                    AppLogger.debug(CLASS_NAME, 'updatePassengerInformation', pFlight.Flight_External_Id__c, 'Previous_Flight_Number__c does not have value.', null);
                    //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'updatePassengerInformation', BE8_GlobalConstants.LEVEL_DEBUG, 'Previous_Flight_Number__c does not have value.', pFlight.Flight_External_Id__c, PreFlightBatch.applicationLogCache);
                } else if (pFlight.Previous_Flight_Date_LT__c == null) {
                    AppLogger.debug(CLASS_NAME, 'updatePassengerInformation', pFlight.Flight_External_Id__c, 'Previous_Flight_Date_LT__c does not have value.', null);
                    //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'updatePassengerInformation', BE8_GlobalConstants.LEVEL_DEBUG, 'Previous_Flight_Date_LT__c does not have value.', pFlight.Flight_External_Id__c, PreFlightBatch.applicationLogCache);
                }
                return updatePassengerInformation(pFlight, pFlight.Previous_Flight_Number__c,
                                                  pFlight.Previous_Flight_Date_LT__c,
                                                  null,
                                                  null,
                                                  strFlightDateUTC, isRetrialWithPreviousFlight);
            }
        }

        //System.debug('Debug updatePassengerInformation NOT update passenger due to either flight date UTC ore flight date LT are NULL or both are NULL use flight_date_utc__c.');
        return updatePassengerInformation(pFlight, pFlight.Flight_Number__c,
                                          pFlight.Flight_Date_UTC__c,
                                          null,
                                          null,
                                          pFlight.Flight_Date_UTC__c);
    }

    public static void updatePassengerToDatabase(Map<String, Object> mInfo) {
        List<String> rops = new List<String>();
        Map<String, String> mTotalCabin = new Map<String, String>();
        List<Flight__c> lFlights = new List<Flight__c>();
        Map<String, Passenger__c> mPax = new Map<String, Passenger__c>();
        Map<String, Account> mPaxAccMember = new Map<String, Account>();
        Map<String, Account> mPaxAccFLBP = new Map<String, Account>();
        Map<String, Travel_Document__c> mPaxDoc = new Map<String, Travel_Document__c>();
        Map<String, Membership__c> mPaxMem = new Map<String, Membership__c>();
        List<Passenger__c> clonePaxs = new List<Passenger__c>();


        // ----- Prepare data -----
        mPaxAccMember = (Map<String, Account>)mInfo.get('PAX-ACC-Member');
        mPaxAccFLBP = (Map<String, Account>)mInfo.get('PAX-ACC_FLBP');
        mPaxDoc = (Map<String, Travel_Document__c>)mInfo.get('PAX-DOC');
        mPaxMem = (Map<String, Membership__c>)mInfo.get('PAX-MEM');
        clonePaxs = (List<Passenger__c>)mInfo.get('PAX-CLONE');
        mPax = (Map<String, Passenger__c>)mInfo.get('PAX');
        lFlights = (List<Flight__c>)mInfo.get('PAX-CABIN');

        // ----- Database execution -----
        // Update member account
        if (mPaxAccMember != null) {
            try {
                Map<String, Account> accountDedupMap = new Map<String, Account>();
                for (Account each : mPaxAccMember.values()) {
                    accountDedupMap.put(each.Id, each);
                }
                update accountDedupMap.values();
            } catch (Exception e) {
                System.debug('ERROR while update mPaxAccMember :' + e);
            }
        }

        // Upsert FLBP account
        if (mPaxAccFLBP != null) {
            Map<String, Account> accFLBPDedupMap = new Map<String, Account>();
            for (Account each : mPaxAccFLBP.values()) {
                accFLBPDedupMap.put(each.Customer_External_Id__c, each);
            }
            upsert accFLBPDedupMap.values() Account.Customer_External_Id__c;
        }

        assignAccountToTravelDoc(mPaxDoc, mPaxAccMember, mPaxAccFLBP);
        //System.debug('mPaxAccFLBP: ' + JSON.serialize(mPaxAccFLBP));
        //System.debug('mPaxMem: ' + JSON.serialize(mPaxMem));
        assignAccountFLBPToMembership(mPaxMem, mPaxAccFLBP, mPaxAccMember);
        //System.debug('mPaxMem: ' + JSON.serialize(mPaxMem));

        if (mPaxDoc != null) {
            try {
                Map<String, Travel_Document__c> travelDocumentDedupMap = new Map<String, Travel_Document__c>();
                for (Travel_Document__c each : mPaxDoc.values()) {
                    travelDocumentDedupMap.put(each.ExtDocument__c, each);
                }
                upsert travelDocumentDedupMap.values() Travel_Document__c.ExtDocument__c;
            } catch (Exception e) {
                System.debug('ERROR while update mPaxDoc :' + e);
            }
        }


        if (mPaxMem != null) {
            try {
                for (String k : mPaxMem.keySet()) {
                    Membership__c m = mPaxMem.get(k);
                }
                upsert mPaxMem.values() Membership__c.EXTMember__c;
            } catch (Exception e) {
                System.debug('ERROR while update mPaxMem :' + e);
            }
        }

        // assign account to passenger
        assignAccountToPassenger(mPax, mPaxAccMember, mPaxAccFLBP);

        // assign account to cloned passenger
        assignAccountToClonedPassenger(mPax, clonePaxs);

        // Delete pax in database which not exist in pax from service
        if (mPax != null && !mPax.isEmpty()) {
            List<String> lPaxKeys = new List<String>();
            String strFlightMaster = '';
            for (Passenger__c p : mPax.values()) {
                lPaxKeys.add(p.WS_KEY__c);
                strFlightMaster = p.Flight_Master__c;
            }

            for (Passenger__c p : clonePaxs) {
                lPaxKeys.add(p.WS_KEY__c);
            }

            if (lPaxKeys != null && !lPaxKeys.isEmpty()) {
                Map<String, Passenger__c> mRemovePax = new Map<String, Passenger__c>();
                try {
                    for (Passenger__c p : [Select Id, Name, WS_KEY__c, (SELECT Id FROM Cases__r) From Passenger__c Where WS_KEY__c Not In :lPaxKeys And Flight_Master__c = :strFlightMaster And Source_Data__c = :BE8_GlobalConstants.SOURCE_DATA_WEB_SERVICE]) {
                        mRemovePax.put(p.WS_KEY__c, p);
                    }

                } catch (Exception e) {
                    System.debug('ERROR while remove pax which has related case :');
                }

                if (!mRemovePax.isEmpty()) {
                    try {
                        Map<String, Passenger__c> passengerDedupMap = new Map<String, Passenger__c>();
                        for (Passenger__c each : mRemovePax.values()) {
                            passengerDedupMap.put(each.WS_KEY__c, each);
                        }
                        delete passengerDedupMap.values();
                    } catch (Exception e) {
                        System.debug('ERROR while delete pax which not exist in service :' + e);
                    }
                }
            }
        }

        // Upsert passenger
        if (mPax != null) {
            try {
                Map<String, Passenger__c> passengerDedupMap = new Map<String, Passenger__c>();
                for (Passenger__c each : mPax.values()) {
                    passengerDedupMap.put(each.WS_KEY__c, each);
                }
                upsert passengerDedupMap.values() Passenger__c.WS_KEY__c;
            } catch (Exception e) {
                System.debug('ERROR while update mPax :' + e);
            }

            // Prepare passenger id conditon which its account is not NULL
            // to inquiry Case_Group_Member__c
            List<Id> paxIds = new List<Id>();
            // Mapping key: paxId, value: accountId
            Map<Id, Id> mPaxIdAccId = new Map<Id, Id>();
            try {
                for (Passenger__c p : mPax.values()) {
                    if (p.AccountId__c != null) {
                        paxIds.add(p.Id);
                        mPaxIdAccId.put(p.Id, p.AccountId__c);
                    }
                }
            } catch (Exception e) {
                System.debug('ERROR while get pax ID and account ID from pax :' + e);
            }

            // Assign account to case group memeber
            List<Case_Group_Member__c> lCaseGroupMemberToBeUpdatedAccount = new List<Case_Group_Member__c>();
            try {
                if (!paxIds.isEmpty()) {
                    for (Case_Group_Member__c c : [Select Id, Passengerid__c, AccountId__c From Case_Group_Member__c Where Passengerid__c In :paxIds AND AccountId__c = null]) {
                        if (c.Passengerid__c != null) {
                            c.AccountId__c = mPaxIdAccId.get(c.Passengerid__c);
                            lCaseGroupMemberToBeUpdatedAccount.add(c);
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('ERROR while query case group member by passenger id :' + e);
            }

            try {
                if (!lCaseGroupMemberToBeUpdatedAccount.isEmpty()) {
                    update lCaseGroupMemberToBeUpdatedAccount;
                }
            } catch (Exception e) {
                System.debug('ERROR while update account to caes group member :' + e);
            }
        }

        // Upsert clone passenger
        if (clonePaxs != null) {
            try {
                Map<String, Passenger__c> passengerDedupMap = new Map<String, Passenger__c>();
                for (Passenger__c each : clonePaxs) {
                    passengerDedupMap.put(each.WS_KEY__c, each);
                }
                upsert passengerDedupMap.values() Passenger__c.WS_KEY__c;
            } catch (Exception e) {
                System.debug('ERROR while update clonePaxs :' + e);
            }
        }

        // Update flight - passenger configuration
        if (lFlights != null) {
            try {
                Map<Id, Flight__c> flightDedupMap = new Map<Id, Flight__c>(lFlights);
                update flightDedupMap.values();
            } catch (Exception e) {
                System.debug('ERROR while update flight :' + e);
            }
        }
    }

    private static void getDOCS(Map<String, Passenger__c> paxMap, String flightNumber, String flightDate, String boardPoint, String offPoint) {
        TG_PaxSSR_WS.PAXLIST_WS ws = new TG_PaxSSR_WS.PAXLIST_WS();
        ws.endpoint_x =  BE8_GlobalUtility.getSetting('DOCS_ENDPOINT');
        ws.Security = getSecurity();
        ws.timeout_x = getTimeout();
        ws.GetPaxNameListSSRReqHeader = getHeader();

        TG_PaxSSR_Result.GetPaxDocRes data = null;

        try {
            data = ws.GetPaxDoc(BE8_GlobalConstants.DEFAULT_TG_COMPANY,
                                flightNumber,
                                BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, flightDate), // Date DepartureDate
                                boardPoint, // String BoardPoint
                                offPoint // String OffPoint)
                               );
            System.debug('################NEW DOCS: ' + System.JSON.serialize(data));
        } catch (Exception e) {
            String message = 'ERROR while call service DOCS Shenzhen: ' +
                             flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint +
                             ' :' + e;
            //BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'getDOCS', BE8_GlobalConstants.LEVEL_DEBUG, message, flightNumber + ' - ' + flightDate + ' - ' + boardPoint + ' - ' + offPoint, PreFlightBatch.applicationLogCache);
            AppLogger.warn(CLASS_NAME, 'getDOCS', flightNumber + flightDate, message, e);
        }

        if (data != null && data.BodyDetail != null) {
            for (TG_PaxSSR_Result.SSROutput ssrOutput : data.BodyDetail) {
                //System.debug('##########ssrOutput: ' + System.JSON.serialize(ssrOutput));
                //System.debug('paxKey: ' + getPassengerWSKey(flightNumber, flightDate, ssrOutput.TravellerFirstName, ssrOutput.TravellerSurname, ssrOutput.RecordLocator));
                //System.debug('paxMap: ' + System.JSON.serialize(paxMap));
                Passenger__c p = paxMap.get(getPassengerWSKey(flightNumber, flightDate, ssrOutput.TravellerFirstName, ssrOutput.TravellerSurname, ssrOutput.RecordLocator));
                if(p == null){
                    // Retrieve again by adding Infant Firstname next to passenger first name
                    p = paxMap.get(getPassengerWSKey(flightNumber, flightDate, ssrOutput.TravellerFirstName + '/' + ssrOutput.InfantFirstName, ssrOutput.TravellerSurname, ssrOutput.RecordLocator));
                }
                //System.debug(p);
                if (p != null) {
                    handleDOCS_SSR(p, ssrOutput.TravellerDoc, ssrOutput.InfantDoc);

                    if (ssrOutput.InfantFirstName != null && ssrOutput.InfantSurname != null) {
                        p.Infant_Name__c = ssrOutput.InfantSurname + ' ' + ssrOutput.InfantFirstName;
                    }
                }
                //System.debug(p);
            }
        }
    }

    public static Passenger__c assignInfantDateOfBirth(Passenger__c pax, String birthday) {
        pax.Infant_Date_of_Birth__c = birthday;
        if (pax.Infant_Date_of_Birth__c != null) {
            try {
                pax.Infant_Date_of_Birth__c = BE8_DateUtility.convertBirthDate(birthday);
            } catch (Exception e) {
                System.debug('ERROR in ssrCodeHandler while convert birth date of infant :' + pax.Infant_Date_of_Birth__c + ' :' + e);
            }
        }
        return pax;
    }
}