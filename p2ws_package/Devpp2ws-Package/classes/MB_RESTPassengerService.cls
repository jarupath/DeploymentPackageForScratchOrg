@RestResource(urlMapping = '/passenger/*')
global class MB_RESTPassengerService {
    @HttpGet
    global static List<MB_RestResponseInfoModel.passengerInfo_model> retrievePassengerInfo() {
        List<MB_RestResponseInfoModel.passengerInfo_model> result = new List<MB_RestResponseInfoModel.passengerInfo_model>();
        //String flightExternalId = RestContext.request.params.get('id');
        //System.debug(RestContext.request);
        //System.debug('flightExternalId ' + flightExternalId);

        Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(UserInfo.getUserId());
        List<Passenger__c> passengerList = [SELECT Id, Change_Seat__c, Date_of_Birth_Input__c , Change_Cabin_Class__c, PaxKey__c, Connecting_Date__c, Connecting_Flight__c, Connecting_Segment__c, Connecting_STD__c, Eligible_for_Upgrade_Seat__c, Eligible_for_Upgrade_Seat_Priority__c, Staff_Booking__c, Board_Point__c, Off_Point__c, Checkin_Seat__c, AccountId__r.Mailling_Address__c, AccountId__r.ROP_Home_Phone__c, AccountId__r.ROP_Business_Phone__c, Infant__c, Infant_Name__c , Nationality_Fullname__c, Infant_Date_of_Birth__c, Infant_Age__c, Cabin_Code__c, Name, AccountId__r.Favorite_Drink__c, AccountId__r.Favorite_Food__c, FlightId__c, FlightId__r.Leg_Number__c, PNR__c, Booking_Seat__c, First_Name__c, Last_Name__c, Gender__c, AccountId__r.Date_of_Birth__c, Phone__c, Email_1__c, Email_2__c, Booking_Class__c, SSR__c, Special_Meal__c, SSR_Service__c, Nationality__c, Mobile__c, AccountId__c, AccountId__r.Phone, AccountId__r.ROP_Mobile__c, AccountId__r.ROP_Email_1__c, AccountId__r.ROP_Email_2__c, ROP_KEY__c, AccountId__r.ROP_Favorite_Food__c, AccountId__r.ROP_Favorite_Drink__c, AccountId__r.Like__c, AccountId__r.Dislike__c, AccountId__r.Information__c, AccountId__r.by_Ground_Customer_Service__c, AccountId__r.by_Sale_and_Marketing__c, FlightId__r.Flight_External_ID__c, FFP_Number__c, FFP_Tier__c, FFP_Carrier__c FROM Passenger__c WHERE FlightId__c IN : flightIdSet];

        Set<Id> accountIdSet = BE8_GlobalUtility.getIdSet('AccountId__c', passengerList);
        System.debug('passengerList ' + passengerList);
        System.debug('accountIdSet ' + accountIdSet);

        Map<String, SObject> membershipMapByAccountId = BE8_GlobalUtility.getSObjectMap('AccountId__c', [SELECT Id, Name, AccountId__r.First_Name__c, AccountId__r.Last_Name__c, AccountId__r.Date_of_Birth__c, AccountId__c, Tier__c, Mileages__c, Mileages_Current_Quater__c, Airline__c, AccountId__r.Mailling_Address__c, AccountId__r.ROP_Home_Phone__c, AccountId__r.ROP_Business_Phone__c, AccountId__r.ROP_Mobile__c, AccountId__r.ROP_Email_1__c, AccountId__r.ROP_Email_2__c, Mileages_Q_1__c FROM Membership__c WHERE AccountId__c IN : accountIdSet AND Status__c = :BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE]);

        for (Passenger__c passenger : passengerList) {
            MB_RestResponseInfoModel.passengerInfo_model passengerModel = new MB_RestResponseInfoModel.passengerInfo_model();
            passengerModel.id = passenger.Id;
            passengerModel.fltId = passenger.FlightId__c;
            passengerModel.legNo = String.valueOf(passenger.FlightId__r.Leg_Number__c);
            passengerModel.pnrNo = passenger.PNR__c;
            passengerModel.bSeat = passenger.Checkin_Seat__c;
            passengerModel.firstN = passenger.First_Name__c;
            passengerModel.lastN = passenger.Last_Name__c;
            passengerModel.image = null;
            passengerModel.gender = passenger.Gender__c;
            passengerModel.birth = String.valueOf(passenger.AccountId__r.Date_of_Birth__c);
            passengerModel.nat = passenger.Nationality_Fullname__c;
            passengerModel.phone = passenger.AccountId__r.Phone;
            passengerModel.mobile = passenger.Mobile__c;
            passengerModel.email1 = passenger.Email_1__c;
            passengerModel.email2 = passenger.Email_2__c;
            passengerModel.bClass = passenger.Booking_Class__c;
            passengerModel.cabin = passenger.Cabin_Code__c;
            passengerModel.hasInfant = BE8_GlobalConstants.BOOLEAN_TO_INTEGER.get(passenger.Infant__c);
            passengerModel.isStaff = passenger.Staff_Booking__c == true ? 1 : 0;
            passengerModel.accId = passenger.AccountId__c;
            passengerModel.paxKey = passenger.PaxKey__c;
            passengerModel.changeSeat = passenger.Change_Seat__c;
            passengerModel.changeClass = passenger.Change_Cabin_Class__c;

            passengerModel.connectingfltdate = passenger.Connecting_Date__c;
            passengerModel.connectingfltno = passenger.Connecting_Flight__c;
            passengerModel.connectingfltsegment = passenger.Connecting_Segment__c;
            passengerModel.connectingfltstd = passenger.Connecting_STD__c;

            Set<String> upgradeSeatCodeSet = new Set<String>();
            passengerModel.isExpired = 0;
            if (passenger.Eligible_for_Upgrade_Seat__c != null && passenger.Eligible_for_Upgrade_Seat__c.length() > 0) {
                upgradeSeatCodeSet.addAll(passenger.Eligible_for_Upgrade_Seat__c.split(','));
            }
            if (passenger.Eligible_for_Upgrade_Seat_Priority__c != null && passenger.Eligible_for_Upgrade_Seat_Priority__c.length() > 0) {
                upgradeSeatCodeSet.addAll(passenger.Eligible_for_Upgrade_Seat_Priority__c.split(','));
                passengerModel.isExpired = 1;
            }
            passengerModel.upgrade = new List<String>(upgradeSeatCodeSet);

            //if(passengerModel.infName != null){
            //    passengerModel.hasInfant = 1; //true
            //}
            passengerModel.infName = passenger.Infant_Name__c;
            passengerModel.boardPoint = passenger.Board_Point__c;
            passengerModel.offPoint = passenger.Off_Point__c;

            if (passenger.Infant_Date_of_Birth__c != null) {
                passengerModel.infAge = passenger.Infant_Age__c;
            }

            if (passenger.SSR__c) {
                passengerModel.ssr_spm = getSSRModel(passenger.Special_Meal__c);
                passengerModel.ssr_sv = getSSRModel(passenger.SSR_Service__c);
            }

            passengerModel.memberships = new List<MB_RESTResponseInfoModel.passengerInfo_membership>();
            //if (membershipListByAccountMap.containsKey(passenger.AccountId__c)) {
            //List<Membership__c> membershipList = (List<Membership__c>) membershipListByAccountMap.get(passenger.AccountId__c);
            //for (Membership__c membership : membershipList) {
            //    Boolean isROPMembership = membership.Airline__c == 'TG';
            //    MB_RESTResponseInfoModel.passengerInfo_membership membershipModel = new MB_RESTResponseInfoModel.passengerInfo_membership();
            //    membershipModel.id = membership.Name;
            //    membershipModel.tier = membership.Tier__c;
            //    membershipModel.mi = String.valueOf(membership.Mileages__c);
            //    membershipModel.expMi = String.valueOf(membership.Mileages_Q_1__c);
            //    membershipModel.airline = membership.Airline__c;
            //    if (isROPMembership) {
            //        membershipModel.addr = membership.AccountId__r.Mailling_Address__c;
            //        membershipModel.hPhone = membership.AccountId__r.ROP_Home_Phone__c;
            //        membershipModel.bPhone = membership.AccountId__r.ROP_Business_Phone__c;
            //        membershipModel.email1 = membership.AccountId__r.ROP_Email_1__c;
            //        membershipModel.email2 = membership.AccountId__r.ROP_Email_2__c;
            //    }
            //    passengerModel.memberships.add(membershipModel);
            //}
            Membership__c membership = (Membership__c) membershipMapByAccountId.get(passenger.AccountId__c);
            if (passenger.FFP_Carrier__c == BE8_GlobalConstants.DEFAULT_TG_COMPANY && membership != null && membership.AccountId__r.Last_Name__c == passenger.Last_Name__c && membership.AccountId__r.Date_of_Birth__c == passenger.Date_of_Birth_Input__c) {
                MB_RESTResponseInfoModel.passengerInfo_membership membershipModel = new MB_RESTResponseInfoModel.passengerInfo_membership();
                membershipModel.id = passenger.FFP_Number__c;
                membershipModel.tier = passenger.FFP_Tier__c;
                membershipModel.airline = passenger.FFP_Carrier__c;
                membershipModel.addr = passenger.AccountId__r.Mailling_Address__c;
                membershipModel.hPhone = passenger.AccountId__r.ROP_Home_Phone__c;
                membershipModel.bPhone = passenger.AccountId__r.ROP_Business_Phone__c;
                membershipModel.email1 = passenger.AccountId__r.ROP_Email_1__c;
                membershipModel.email2 = passenger.AccountId__r.ROP_Email_2__c;
                membershipModel.drink = passenger.AccountId__r.ROP_Favorite_Drink__c;
                membershipModel.food = passenger.AccountId__r.ROP_Favorite_Food__c;
                if (membership != null) {
                    membershipModel.mi = String.valueOf(membership.Mileages__c);
                    membershipModel.expMi = String.valueOf(membership.Mileages_Q_1__c);
                    membershipModel.airline = membership.Airline__c;
                }
                passengerModel.memberships.add(membershipModel);
            }
            passengerModel.psy = new MB_RESTResponseInfoModel.passengerInfo_paxPsy();
            if (passenger.AccountId__c != null) {
                passengerModel.psy.ifLike = passenger.AccountId__r.Like__c;
                passengerModel.psy.ifDislike = passenger.AccountId__r.Dislike__c;
                passengerModel.psy.ifOther = passenger.AccountId__r.Information__c;
                passengerModel.psy.ground = passenger.AccountId__r.by_Ground_Customer_Service__c;
                passengerModel.psy.sale = passenger.AccountId__r.by_Sale_and_Marketing__c;
            }
            result.add(passengerModel);
        }
        return result;
    }

    @HttpPost
    global static List<MB_RestRequestInfoModel.passengerPsychology_model> updatePassengerPsychology(List<MB_RestRequestInfoModel.passengerPsychology_model> paxPsy) {
        AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTPassengerService', 'updatePassengerPsychology', '', 'ROP_Number_Inventory__c', 'The Passenger Psychology that are sent from mobile.', System.JSON.serialize(paxPsy), null, System.currentTimeMillis());
        List<Account> accountList = new List<Account>();
        for (MB_RestRequestInfoModel.passengerPsychology_model each : paxPsy) {
            if (each.accId != null) {
                Account acc = new Account();
                acc.Id = each.accId;
                if (each.pLike != null) {
                    acc.Like__c = each.pLike;
                }
                if (each.dislike != null) {
                    acc.Dislike__c = each.dislike;
                }
                if (each.byOther != null) {
                    acc.Information__c = each.byOther;
                }
                if (each.byGnd != null) {
                    acc.By_Ground_Customer_Service__c = each.byGnd;
                }
                if (each.bySale != null) {
                    acc.By_Sale_and_Marketing__c = each.bySale;
                }
                accountList.add(acc);
            }
        }
        try {
            update accountList;
        } catch (Exception e) {
            Set<Id> accountIdSet = BE8_GlobalUtility.getIdSet('Id', accountList);
            String message = e.getMessage() + '\n' + e.getStackTraceString();
            AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTPassengerService', 'updatePassengerPsychology', '' + accountIdSet, 'Account', message, System.JSON.serialize(paxPsy), null, System.currentTimeMillis());
            AppLogger.insertLogs();
            throw e;

        }
        AppLogger.insertLogs();
        return paxPsy;
    }

    private static List<MB_RestResponseInfoModel.passengerInfo_ssr> getSSRModel(String ssrString) {
        if (ssrString != null) {
            List<MB_RestResponseInfoModel.passengerInfo_ssr> ssrModelList = new List<MB_RestResponseInfoModel.passengerInfo_ssr>();
            List<String> ssrList = ssrString.split('\n');
            for (String ssr : ssrList) {
                MB_RestResponseInfoModel.passengerInfo_ssr ssrModel = new MB_RestResponseInfoModel.passengerInfo_ssr();
                Integer indexOfStatus = ssr.indexOf('(');
                Integer indexOfRemark = ssr.indexOf('-');
                Boolean hasStatus = indexOfStatus != -1;
                Boolean hasRemark = indexOfRemark != -1;

                ssrModel.type = extractTypeFromSSR(ssr);
                if (hasRemark) {
                    ssrModel.remark = extractRemarkFromSSR(ssr);
                }
                if (hasStatus) {
                    ssrModel.status = extractStatusFromSSR(ssr);
                }
                ssrModelList.add(ssrModel);
            }
            return ssrModelList;
        }
        return null;
    }

    private static String extractTypeFromSSR(String ssr) {
        Integer indexOfDash = ssr.indexOf('-');
        Integer indexOfStartOfStatus = ssr.indexOf('(');

        Boolean hasRemark = indexOfDash != -1;
        Boolean hasOnlyStatus = indexOfDash == -1 && indexOfStartOfStatus != -1;

        if (hasRemark) {
            return ssr.substring(0, indexOfDash);
        } else if (hasOnlyStatus) {
            return ssr.substring(0, indexOfStartOfStatus);
        } else return ssr;
    }

    private static String extractRemarkFromSSR(String ssr) {
        Integer indexOfDash = ssr.indexOf('-');
        Integer indexOfStartOfStatus = ssr.indexOf('(');

        Boolean hasBothRemarkAndStatus = indexOfDash != -1 && indexOfStartOfStatus != -1 && indexOfDash < indexOfStartOfStatus;
        Boolean hasOnlyRemark = indexOfDash != -1 && indexOfStartOfStatus == -1;

        if (hasBothRemarkAndStatus) {
            return ssr.substring(indexOfDash + 1, indexOfStartOfStatus);
        } else if (hasOnlyRemark) {
            return ssr.substring(indexOfDash + 1);
        } else return null;
    }

    private static String extractStatusFromSSR(String ssr) {
        Integer indexOfStartOfStatus = ssr.indexOf('(');
        Integer indexOfEndOfStatus = ssr.indexOf(')');
        Boolean hasStatus = indexOfStartOfStatus != -1;

        if (hasStatus) {
            Integer stringLength = ssr.length();
            return ssr.substring(indexOfStartOfStatus + 1, indexOfEndOfStatus);
        } else return null;
    }

    public static String getPaxKey(Passenger__c p){
        return p.PaxKey__c;
    }
}