public class CSE_SOAPUpdateLopa_WS {
    private static final String CLASS_NAME = 'CSE_SOAPUpdateLopa_WS';
    public CSE_SOAPUpdateLopa_WS() {}

    private static TG_WS_Header.ReqHeader getHeader() {
        TG_WS_Header.ReqHeader h = new TG_WS_Header.ReqHeader();

        h.ReqDateTime = DateTime.now();
        h.ReqTxnID = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_REQ_TXN_ID));
        //h.ReqTxnID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_REQ_TXN_ID);
        h.SvcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_SVC_VER);
        h.IsLastTxn = true;
        h.MWTxnID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_MW_TXN_ID);
        h.Credentials = new TG_WS_Header.Credentials_element();
        h.Credentials.MWCredential = new TG_WS_Header.MWCredential_element();
        //h.Credentials.MWCredential.ReqID = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_REQ_ID));
        h.Credentials.MWCredential.ReqID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_REQ_ID);
        h.Credentials.MWCredential.ReqPwd = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_REQ_PWD);
        h.Credentials.MWCredential.UserID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_REQ_USER_ID);

        // Support service callout 48 hr before flight departure.
        h.Credentials.ProviderCredentials = new TG_WS_Header.ProviderCredentials_element();
        h.Credentials.ProviderCredentials.ProviderCredential = new TG_WS_Header.ProviderCredential_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate = new TG_WS_Header.Security_Authenticate_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.userIdentifier = new TG_WS_Header.userIdentifier_element[1];
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.userIdentifier[0] = new TG_WS_Header.userIdentifier_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.userIdentifier[0].originIdentification = new TG_WS_Header.originIdentification_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.userIdentifier[0].originIdentification.sourceOffice = 'BKKTG055B';
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.userIdentifier[0].originatorTypeCode = 'U';
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.userIdentifier[0].originator = 'WSTGAPS';

        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.dutyCode = new TG_WS_Header.dutyCode_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.dutyCode.dutyCodeDetails = new TG_WS_Header.dutyCodeDetails_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.dutyCode.dutyCodeDetails.referenceQualifier = 'DUT';
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.dutyCode.dutyCodeDetails.referenceIdentifier = 'RC';

        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.systemDetails = new TG_WS_Header.systemDetails_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.systemDetails.organizationDetails = new TG_WS_Header.organizationDetails_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.systemDetails.organizationDetails.organizationId = 'TG';

        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.passwordInfo = new TG_WS_Header.passwordInfo_element[1];
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.passwordInfo[0] = new TG_WS_Header.passwordInfo_element();
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.passwordInfo[0].dataLength = '8';
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.passwordInfo[0].dataType = 'E';
        h.Credentials.ProviderCredentials.ProviderCredential.Security_Authenticate.passwordInfo[0].binaryData = 'QU1BREVVUzE=';

        return h;
    }

    private static TG_Security_element getSecurity() {
        return new TG_Security_element(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_USERNAME)
                                       , BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_PASSWORD));
    }

    private static Integer getTimeout() {
        try {
            return Integer.valueOf(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_TIMEOUT));
        } catch (Exception e) {
            return BE8_GlobalConstants.WS_DEFAULT_TIMEOUT;
        }
    }

    private static Map<String, String> getInputHttpHeaders() {
        return new Map<String, String>();
    }

    private static Map<String, String> getOutputHttpHeaders() {
        return new Map<String, String>();
    }

    private static String getEndPoint() {
        return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_LOPA_ENDPOINT);
    }

    public static TG_LOPA_WS.Air_HTTP concreteWebservice() {
        TG_LOPA_WS.Air_HTTP ws = new TG_LOPA_WS.Air_HTTP();
        ws.endpoint_x = getEndPoint();
        // ws.Security = getSecurity(); // The logic has been removed, should always called every time
        ws.timeout_x = getTimeout();
        ws.GetSeatMapReqHeader = getHeader();

        return ws;
    }

    private static TG_LOPA_Req.TravelProductInfoTypeIREQ buildDefaultLopaRequest(Date flightDate, Integer flightNumber, String bookingClass, String boardPoint, String offPoint) {
        TG_LOPA_Req.TravelProductInfoTypeIREQ t = new TG_LOPA_Req.TravelProductInfoTypeIREQ();

        t.flightDate = new TG_LOPA_Req.ProductDateTimeTypeIREQ();
        t.boardPointDetails = new TG_LOPA_Req.LocationTypeIREQ();
        t.offpointDetails = new TG_LOPA_Req.LocationTypeIREQ();
        t.companyDetails = new TG_LOPA_Req.CompanyIdentificationTypeIREQ();
        t.flightIdentification = new TG_LOPA_Req.ProductIdentificationDetailsTypeIREQ();

        t.flightDate.departureDate = flightDate;
        t.boardPointDetails.trueLocationId = boardPoint; // Optional (Data :BKK)
        t.offpointDetails.trueLocationId = offPoint; // Optional (Data :FRA)
        t.companyDetails.marketingCompany = BE8_GlobalConstants.DEFAULT_TG_COMPANY;
        t.flightIdentification.flightNumber = flightNumber.format();
        t.flightIdentification.bookingClass = bookingClass;

        return t;
    }

    private static Aircraft__c getAircraft(Id pAircraftId) {
        List<Aircraft__c> aircrafts = [Select Id, Name, Aircraft_Registration__c, Aircraft_Configuration__c, Is_LOPA_Ready__c
                                       From Aircraft__c Where Id = :pAircraftId Limit 1];

        if (aircrafts != null && !aircrafts.isEmpty()) {
            return aircrafts[0];
        }

        return null;
    }

    private static TG_LOPA_Req.GetSeatMapRes getLOPA(TG_LOPA_WS.Air_HTTP ws, String pFlightNumber, Date pFlightDate, String pBoardPoint, String pOffPoint, String pClass, Map<String, String> pMAircraftConfiguration) {
        if (pFlightNumber != null && pFlightNumber.indexOf(BE8_GlobalConstants.DEFAULT_TG_COMPANY) != -1) {
            pFlightNumber = pFlightNumber.replace(BE8_GlobalConstants.DEFAULT_TG_COMPANY, '');
        }

        ws.Security = getSecurity(); // Always generate nonce
        Datetime startTime = Datetime.now();
        TG_LOPA_Req.GetSeatMapRes seatMapRes = null;
        try {
            System.debug('Get LOPA with pFlightDate:' + pFlightDate + ' pFlightNumber:' + pFlightNumber + ' pClass:' + pClass + ' pBoardPoint:' + pBoardPoint + ' pOffPoint:' + pOffPoint);
            seatMapRes = ws.GetSeatMap(
                             buildDefaultLopaRequest(pFlightDate, BE8_GlobalUtility.toNumber(pFlightNumber), pClass, pBoardPoint, pOffPoint),
                             null,
                             null,
                             null,
                             null,
                             null,
                             null,
                             null,
                             null);

            if (seatMapRes != null && seatMapRes.seatMapInfo.size() > 0) {
                // Get aircraft configuration F12 C60 Y435
                if (pMAircraftConfiguration.isEmpty() && seatMapRes.seatmapInfo[0].equipInfo != null) {
                    if (seatMapRes.seatmapInfo[0].equipInfo.cabinClassDetails != null &&
                            !seatMapRes.seatmapInfo[0].equipInfo.cabinClassDetails.isEmpty()) {
                        String aircraftConfig = '';
                        for (TG_LOPA_Req.ConfigurationDetailsTypeIRES cabin : seatMapRes.seatmapInfo[0].equipInfo.cabinClassDetails) {
                            aircraftConfig += cabin.classDesignator + cabin.numberOfSeats + ' ';
                        }
                        aircraftConfig = aircraftConfig.trim();
                        pMAircraftConfiguration.put(BE8_GlobalConstants.DEFAULT_TG_COMPANY, aircraftConfig);
                    }
                }
                return seatMapRes;
            }
        } catch (Exception e) {
            String errorCode = '';
            String errorDesc = '';
            if (seatMapRes != null && seatMapRes.errorInfo != null && seatMapRes.errorInfo.errorDetails != null) {
                errorCode = seatMapRes.errorInfo.errorDetails.code;
                errorDesc = seatMapRes.errorInfo.errorDetails.desc_x;
            }

            String message = 'get LOPA from flight :' + pFlightNumber +
                             '-' + pFlightDate  +
                             '-' + pClass +
                             '-' + pBoardPoint +
                             '-' + pOffPoint +
                             '- error code :' + errorCode +
                             '- error desc :' + errorDesc +
                             '- error message :' + e.getMessage() +
                             '- error :' + e;
            String lopaExternalId = pFlightDate + '_' + BE8_GlobalUtility.toNumber(pFlightNumber) + '_' + pClass + '_' + pBoardPoint + '_' + pOffPoint;
            AppLogger.error(CLASS_NAME, 'getLOPA', lopaExternalId, message, e);
        }
        return null;
    }

    public static Attachment concreteAttachment(Id pAircraftId, String pClass, String pData) {
        Attachment att = new Attachment();
        att.Name = pClass + '_' + 'LOPA.txt';
        att.ParentId = pAircraftId;
        att.Body = Blob.valueOf(pData);
        return att;
    }

    // Old version update attachment in Aircraft__c
    //public static Map<String, Object> updateLopaInformation(TG_LOPA_WS.Air_HTTP pService, String pFlightNumber, Date pFlightDate, String pBoardPoint, String pOffPoint, Id pAircraftId) {
    //    Map<String, Object> resultMap = new Map<String, Object>();

    //    // If LOPA is ready / No aircraft related, don't call web service return immediately
    //    Aircraft__c air = getAircraft(pAircraftId);
    //    if (air == null || air.Is_LOPA_Ready__c == true) {
    //        return resultMap;
    //    }

    //    String strConfiguration = null;
    //    Map<String, String> mAircraftConfiguration = new Map<String, String>();
    //    TG_LOPA_Req.GetSeatMapRes yModel = null;
    //    TG_LOPA_Req.GetSeatMapRes fModel = null;
    //    TG_LOPA_Req.GetSeatMapRes cModel = null;
    //    TG_LOPA_Req.GetSeatMapRes uModel = null;
    //    String y = null;
    //    String c = null;
    //    String f = null;
    //    String u = null;
    //    Datetime startTime = Datetime.now();

    //    if (pService == null) {
    //        pService = concreteWebservice();
    //    }

    //    // Get LOPA for yModel
    //    yModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_Y, mAircraftConfiguration);

    //    if (!mAircraftConfiguration.isEmpty()) {
    //        strConfiguration = mAircraftConfiguration.get(BE8_GlobalConstants.DEFAULT_TG_COMPANY);

    //        if (strConfiguration != null) {
    //            // Found C configuration
    //            if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_C) != -1) {
    //                cModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_C, mAircraftConfiguration);
    //            }

    //            // Found F configuration
    //            if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_F) != -1) {
    //                fModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_F, mAircraftConfiguration);
    //            }

    //            // Found U configuration
    //            if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_U) != -1) {
    //                uModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_U, mAircraftConfiguration);
    //            }
    //        }
    //    }

    //    Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap = new Map<String, TG_LOPA_Req.GetSeatMapRes>();
    //    if (yModel != null) {
    //        lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_Y, yModel);
    //        System.debug('yModel :' + yModel);
    //    }
    //    if (cModel != null) {
    //        lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_C, cModel);
    //        System.debug('yModel :' + cModel);
    //    }
    //    if (fModel != null) {
    //        lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_F, fModel);
    //        System.debug('yModel :' + fModel);
    //    }
    //    if (uModel != null) {
    //        lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_U, uModel);
    //        System.debug('yModel :' + uModel);
    //    }

    //    String masterLOPAJSON = LOPAService.getMasterLOPAJSONString(lopaRawModelMap);
    //    if (yModel != null) {
    //        y = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_Y));
    //    }

    //    if (cModel != null) {
    //        c = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_C));
    //    }

    //    if (fModel != null) {
    //        f = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_F));
    //    }

    //    if (uModel != null) {
    //        u = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_U));
    //    }

    //    try {
    //        List<Attachment> attachments = new List<Attachment>();
    //        air.Aircraft_Configuration__c = strConfiguration;
    //        if (air.Aircraft_Configuration__c != null) {
    //            air.Aircraft_Configuration__c = air.Aircraft_Configuration__c.replaceAll(':', '');
    //        }
    //        if (f != null) {
    //            attachments.add(concreteAttachment(air.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_F, f));
    //            //System.debug('F length :' + f.length());
    //        }
    //        if (c != null) {
    //            attachments.add(concreteAttachment(air.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_C, c));
    //            //System.debug('C length :' + c.length());
    //        }
    //        if (y != null) {
    //            attachments.add(concreteAttachment(air.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_Y, y));
    //            air.Is_LOPA_Ready__c = true;
    //            //System.debug('Y length :' + y.length());
    //        }
    //        if (u != null) {
    //            attachments.add(concreteAttachment(air.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_U, u));
    //            //System.debug('U length :' + u.length());
    //        }
    //        if (masterLOPAJSON != null) {
    //            attachments.add(concreteAttachment(air.Id, 'Master', masterLOPAJSON));
    //        }

    //        resultMap.put('aircraft', air);
    //        resultMap.put('attachmentList', attachments);
    //    } catch (Exception e) {
    //        System.debug('Update LOPA from flight :' + pFlightNumber +
    //                     '-' + pFlightDate  +
    //                     '-' + pBoardPoint +
    //                     '-' + pOffPoint +
    //                     '-' + pAircraftId +
    //                     ' failed :' + e.getMessage());
    //    }
    //    return resultMap;
    //}

    public static Attachment concreteFlightAttachment(Id pFlightId, String pClass, String pData, String flightExternalId) {
        Attachment att = new Attachment();
        att.Name = pClass + '_' + 'LOPA.txt';
        att.ParentId = pFlightId;
        att.Body = Blob.valueOf(pData);
        att.Description = flightExternalId;
        return att;
    }

    // New version update attachment in Flight__c
    public static Map<String, Object> updateLopaInformation(TG_LOPA_WS.Air_HTTP pService, String pFlightNumber, Date pFlightDate, Flight__c pFlight, String pBoardPoint, String pOffPoint, Id pAircraftId) {
        System.debug('Update LOPA from flight :' + pFlightNumber +
                     '-' + pFlightDate  +
                     '-' + pBoardPoint +
                     '-' + pOffPoint +
                     '-' + pAircraftId);
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            if (pFlight == null) {
                return resultMap;
            }

            String strConfiguration = null;
            Map<String, String> mAircraftConfiguration = new Map<String, String>();
            TG_LOPA_Req.GetSeatMapRes yModel = null;
            TG_LOPA_Req.GetSeatMapRes fModel = null;
            TG_LOPA_Req.GetSeatMapRes cModel = null;
            TG_LOPA_Req.GetSeatMapRes uModel = null;
            String y = null;
            String c = null;
            String f = null;
            String u = null;
            Datetime startTime = Datetime.now();

            if (pService == null) {
                pService = concreteWebservice();
            }

            // Get LOPA for yModel, and update aircraft configuration to mAircraftConfiguration
            yModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_Y, mAircraftConfiguration);

            if (!mAircraftConfiguration.isEmpty()) {
                strConfiguration = mAircraftConfiguration.get(BE8_GlobalConstants.DEFAULT_TG_COMPANY);

                if (strConfiguration != null) {
                    // Found C configuration, get LOPA C class
                    if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_C) != -1) {
                        cModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_C, mAircraftConfiguration);
                    }

                    // Found F configuration, get LOPA F class
                    if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_F) != -1) {
                        fModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_F, mAircraftConfiguration);
                    }

                    // Found U configuration, get LOPA U class
                    if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_U) != -1) {
                        uModel = getLOPA(pService, pFlightNumber, pFlightDate, pBoardPoint, pOffPoint, BE8_GlobalConstants.AIRCRAFT_CLASS_U, mAircraftConfiguration);
                    }
                }
            }

            Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap = new Map<String, TG_LOPA_Req.GetSeatMapRes>();
            //if (yModel != null) {
            //    lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_Y, yModel);
            //    System.debug('yModel :' + yModel);
            //}
            //if (cModel != null) {
            //    lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_C, cModel);
            //    System.debug('cModel :' + cModel);
            //}
            //if (fModel != null) {
            //    lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_F, fModel);
            //    System.debug('fModel :' + fModel);
            //}
            //if (uModel != null) {
            //    lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_U, uModel);
            //    System.debug('uModel :' + uModel);
            //}
            lopaRawModelMap = retrieveLopaMap(pFlight);
            //String masterLOPAJSON = LOPAService.getMasterLOPAJSONString(lopaRawModelMap);
            //if (yModel != null) {
            //    y = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_Y));
            //}

            //if (cModel != null) {
            //    c = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_C));
            //}

            //if (fModel != null) {
            //    f = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_F));
            //}

            //if (uModel != null) {
            //    u = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_U));
            //}


            List<Attachment> attachments = new List<Attachment>();
            List<Flight__c> flights = [Select Id, Name, AircraftId__c From Flight__c Where Flight_Master__c = :pFlight.Flight_Master__c];
            //AppLogger.debug('UpdateLOPA', 'sync', '', 'flights ' + flights, null);
            Set<Id> flightIds = BE8_GlobalUtility.getIdSet('Id', flights);

            Set<Id> aircraftIdSet = BE8_GlobalUtility.getIdSet('AircraftId__c', flights);
            //Map<String, SObject> aircraftAttachmentMap = BE8_GlobalUtility.getSObjectMap('ParentId', [SELECT Id, ParentId FROM Attachment WHERE ParentId In :aircraftIdSet And Name Like '%LOPA.txt']);

            if (flights != null && !flights.isEmpty()) {
                //System.debug('Assinging LOPA to flight size :' + flights.size());
                //for (Flight__c flight : flights) {
                //    System.debug('Assigning LOPA to flight :' + flight.Name + ' - ' + flight.Id);
                //    flightIds.add(flight.Id);

                //    System.debug('Debug :Aircraft configuration :' + strConfiguration);
                //    flight.Aircraft_Configuration__c = strConfiguration;

                //    if (f != null) {
                //        attachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_F, f));
                //    }
                //    if (c != null) {
                //        attachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_C, c));
                //    }
                //    if (y != null) {
                //        attachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_Y, y));
                //    }
                //    if (u != null) {
                //        attachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_U, u));
                //    }

                //    AppLogger.debug('UpdateLOPA', 'sync', '', 'masterLOPAJSON ' + masterLOPAJSON, null);
                //    AppLogger.debug('UpdateLOPA', 'sync', '', 'aircraftAttachmentMap ' + aircraftAttachmentMap, null);
                //    if (masterLOPAJSON != null) {
                //        attachments.add(concreteFlightAttachment(flight.Id, 'Master', masterLOPAJSON));
                //        if (!aircraftAttachmentMap.containsKey(flight.AircraftId__c)) {
                //            AppLogger.debug('UpdateLOPA', 'sync', '', 'LOPA for aircraft ', null);
                //            attachments.add(concreteFlightAttachment(flight.AircraftId__c, 'Master', masterLOPAJSON));
                //        }
                //    }
                //}// End for(Flight__c)

                attachments = createLopaAttachment(pFlight, lopaRawModelMap);
                Set<Id> parentIdForLOPA = aircraftIdSet;
                parentIdForLOPA.addAll(flightIds);
                List<Attachment> existingAttachment = [Select Id From Attachment Where ParentId In :parentIdForLOPA And Name Like '%LOPA.txt'];
                resultMap.put('flight-aircraft', flights);
                resultMap.put('attachmentList', attachments);
                resultMap.put('existingAttachment', existingAttachment);

            }// End if(flights != null
            else {
                System.debug('Flight is NULL or empty.');
                resultMap.put('flight-aircraft', null);
                resultMap.put('attachmentList', null);
                resultMap.put('existingAttachment', null);
            }// End else of if(flights != null
        } catch (Exception e) {
            String message = 'Update LOPA from flight (Update to Flight__c):' + pFlightNumber +
                             '-' + pFlight +
                             '-' + pFlightDate  +
                             '-' + pBoardPoint +
                             '-' + pOffPoint +
                             '-' + pAircraftId +
                             '-' + pFlight.Flight_Master__c +
                             ' failed :' + e.getMessage();
            AppLogger.error(CLASS_NAME, 'updateLopaInformation', pFlight.Flight_External_Id__c, message, e);
        }
        return resultMap;
    }

    // Data preparation for developer console
    /*
    List<Aircraft__c> airs = [Select Id From Aircraft__c Where Aircraft_Registration__c = 'HS-THJ'];
    Flight__c f = new Flight__c();
    f.Flight_Number__c = '0920';
    f.Flight_Date_LT__c = '2016-12-27';
    f.Origin__c = 'BKK';
    f.Destination__c = 'FRA';
    f.Departure_STN__c = 'BKK';
    f.Arrival_STN__c = 'FRA';
    f.Aircraft_Type__c = 380;
    f.AircraftId__c = airs[0].Id;
    CSE_SOAPUpdateLopa_WS.updateLopaInformation(f);

    List<Aircraft__c> airs = [Select Id From Aircraft__c Where Aircraft_Registration__c = 'HS-TBA'];
    Flight__c f = new Flight__c();
    f.Flight_Number__c = '0465';
    f.Origin__c = 'BKK';
    f.Destination__c = 'MEL';
    f.Flight_Date_LT__c = '2016-11-01';
    f.Departure_STN__c = 'BKK';
    f.Arrival_STN__c = 'MEL';
    f.AircraftId__c = airs[0].Id;
    CSE_SOAPUpdateLopa_WS.updateLopaInformation(f);
    */

    public static Map<String, TG_LOPA_Req.GetSeatMapRes> retrieveLopaMap(Flight__c flight) {
        TG_LOPA_WS.Air_HTTP pService = concreteWebservice();
        String flightNumber = flight.Flight_Number__c;
        Date flightDate = BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, flight.Flight_Date_LT__c);
        String flightOrigin = flight.Origin__c;
        String flightDest = flight.Destination__c;
        String aircraftId = flight.AircraftId__c;

        Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap = new Map<String, TG_LOPA_Req.GetSeatMapRes>();

        TG_LOPA_Req.GetSeatMapRes yModel, fModel, cModel, uModel = null;
        try {
            Map<String, String> mAircraftConfiguration = new Map<String, String>();
            String strConfiguration = null;

            yModel = getLOPA(pService, flightNumber, flightDate, flightOrigin, flightDest, BE8_GlobalConstants.AIRCRAFT_CLASS_Y, mAircraftConfiguration);

            if (!mAircraftConfiguration.isEmpty()) {
                strConfiguration = mAircraftConfiguration.get(BE8_GlobalConstants.DEFAULT_TG_COMPANY);

                if (strConfiguration != null) {
                    if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_C) != -1) {
                        cModel = getLOPA(pService, flightNumber, flightDate, flightOrigin, flightDest, BE8_GlobalConstants.AIRCRAFT_CLASS_C, mAircraftConfiguration);
                    }

                    if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_F) != -1) {
                        fModel = getLOPA(pService, flightNumber, flightDate, flightOrigin, flightDest, BE8_GlobalConstants.AIRCRAFT_CLASS_F, mAircraftConfiguration);
                    }

                    if (strConfiguration.indexOf(BE8_GlobalConstants.AIRCRAFT_CLASS_U) != -1) {
                        uModel = getLOPA(pService, flightNumber, flightDate, flightOrigin, flightDest, BE8_GlobalConstants.AIRCRAFT_CLASS_U, mAircraftConfiguration);
                    }
                }
                flight.Aircraft_Configuration__c = strConfiguration;
            }

            if (yModel != null) {
                lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_Y, yModel);
            }
            if (cModel != null) {
                lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_C, cModel);
            }
            if (fModel != null) {
                lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_F, fModel);
            }
            if (uModel != null) {
                lopaRawModelMap.put(BE8_GlobalConstants.AIRCRAFT_CLASS_U, uModel);
            }
        } catch (Exception e) {
            String message = flightNumber +
                             '-' + flightDate  +
                             '-' + flightOrigin +
                             '-' + flightDest +
                             '-' + aircraftId +
                             '-' + flight.Flight_Master__c +
                             ' failed :' + e.getMessage();
            AppLogger.error(CLASS_NAME, 'retrieveLopaMap', flight.Flight_External_ID__c, message, e);
        }
        return lopaRawModelMap;
    }

    public static List<Attachment> createLopaAttachment(Flight__c flight, Map<String, TG_LOPA_Req.GetSeatMapRes> lopaRawModelMap) {
        System.debug('createLopaAttachment');
        if (lopaRawModelMap == null) {
            return new List<Attachment>();
        }
        System.debug('createLopaAttachment :' + flight.Id + ' ' + lopaRawModelMap.keySet());

        List<Flight__c> flights = [Select Id, Name, AircraftId__c From Flight__c Where Flight_Master__c = :flight.Flight_Master__c];
        Set<Id> aircraftIdSet = BE8_GlobalUtility.getIdSet('AircraftId__c', flights);
        //Map<String, SObject> aircraftAttachmentMap = BE8_GlobalUtility.getSObjectMap('ParentId', [SELECT Id, ParentId FROM Attachment WHERE ParentId In :aircraftIdSet And Name Like '%LOPA.txt']);
        List<Attachment> newAttachments = new List<Attachment>();
        String masterLOPAJSON = LOPAService.getMasterLOPAJSONString(lopaRawModelMap, flight);
        String y, c, f, u = null;
        if (lopaRawModelMap.containsKey(BE8_GlobalConstants.AIRCRAFT_CLASS_Y)) {
            y = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_Y));
        }

        if (lopaRawModelMap.containsKey(BE8_GlobalConstants.AIRCRAFT_CLASS_C)) {
            c = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_C));
        }

        if (lopaRawModelMap.containsKey(BE8_GlobalConstants.AIRCRAFT_CLASS_F)) {
            f = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_F));
        }

        if (lopaRawModelMap.containsKey(BE8_GlobalConstants.AIRCRAFT_CLASS_U)) {
            u = System.JSON.serialize(lopaRawModelMap.get(BE8_GlobalConstants.AIRCRAFT_CLASS_U));
        }

        if (f != null) {
            newAttachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_F, f, flight.Flight_External_ID__c));
        }
        if (c != null) {
            newAttachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_C, c, flight.Flight_External_ID__c));
        }
        if (y != null) {
            newAttachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_Y, y, flight.Flight_External_ID__c));
        }
        if (u != null) {
            newAttachments.add(concreteFlightAttachment(flight.Id, BE8_GlobalConstants.AIRCRAFT_CLASS_U, u, flight.Flight_External_ID__c));
        }
        if (masterLOPAJSON != null) {
            newAttachments.add(concreteFlightAttachment(flight.Id, 'Master', masterLOPAJSON, flight.Flight_External_ID__c));
            //if(!aircraftAttachmentMap.containsKey(flight.AircraftId__c)){
            newAttachments.add(concreteFlightAttachment(flight.AircraftId__c, 'Master', masterLOPAJSON, flight.Flight_External_ID__c));
            //}
        }

        return newAttachments;
    }

    public static Map<String, Object> updateLopaInformation(Flight__c pFlight) {
        System.debug('Update LOPA from Flight :' + pFlight.Flight_Number__c + '-' +
                     pFlight.Flight_Date_LT__c + '-' +
                     pFlight.Origin__c + '-' +
                     pFlight.Destination__c + '-' +
                     pFlight.AircraftId__c);

        return updateLopaInformation(concreteWebservice(),
                                     pFlight.Flight_Number__c,
                                     BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, pFlight.Flight_Date_LT__c),
                                     pFlight,
                                     pFlight.Origin__c,
                                     pFlight.Destination__c,
                                     pFlight.AircraftId__c);
    }

    public static Flight__c getAircraftConfig(Flight__c pFlight) {
        Map<String, String> mAircraftConfiguration = new Map<String, String>();
        System.debug('Get aircraft configuration from Flight :' + pFlight.Flight_Number__c + '-' +
                     pFlight.Flight_Date_LT__c + '-' +
                     pFlight.Origin__c + '-' +
                     pFlight.Destination__c + '-' +
                     pFlight.AircraftId__c);

        getLOPA(concreteWebservice(),
                pFlight.Flight_Number__c,
                BE8_DateUtility.toDate(BE8_DateUtility.FORMAT_YYYYMMDD, pFlight.Flight_Date_LT__c),
                pFlight.Origin__c,
                pFlight.Destination__c,
                BE8_GlobalConstants.AIRCRAFT_CLASS_Y, mAircraftConfiguration);

        String strConfig = mAircraftConfiguration.get(BE8_GlobalConstants.DEFAULT_TG_COMPANY);
        System.debug('Get aircraft configuration from Flight :' + pFlight.Flight_Number__c + '-' +
                     pFlight.Flight_Date_LT__c + '-' +
                     pFlight.Origin__c + '-' +
                     pFlight.Destination__c + '-' +
                     pFlight.AircraftId__c + '-' +
                     strConfig);
        if (strConfig != null) {
            strConfig = strConfig.replaceAll(':', '');
            pFlight.Aircraft_Configuration__c = strConfig;
        }

        return pFlight;
    }
}