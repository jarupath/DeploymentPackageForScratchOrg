public without sharing class CTI_Management {
    public static final String Unidentified = 'Unidentified';

    public static void getctivalue(list<CTI__c> listgetctivalue, set<ID> setcaseid, Map<String, SObject> flightMap) {
        Map<id, Case> mapcase = getmapcase(setcaseid);
        List<CTI_Route_Area__c> listroutearea = CTI_Route_Area__c.getAll().values();
        List<CTI_Area_with_Sector__c> listsectorwitharea = CTI_Area_with_Sector__c.getall().values();
        Map<String, CTI_Route_Area__c> Maproutearea = getmaproutearea(listroutearea);
        Map<String, CTI_Area_with_Sector__c> Maprsectorarea = getmapsectorarea(listsectorwitharea);
        //String Unidentified = 'Unidentified';
        Boolean areaUnidentified = true;
        Boolean sectorUnidentified = true;

        system.debug('map route area size : ' + Maproutearea.size());
        system.debug('map sector area size : ' + Maprsectorarea.size());

        if (listgetctivalue.size() > 0) {
            for (CTI__c thiscti : listgetctivalue) {
                if (mapcase.Containskey(thiscti.caseid__c)) {

                    Case thiscase = mapcase.get(thiscti.caseid__c);
                    thiscti.detail__c = thiscase.description;
                    thiscti.Special_Meal__c = thiscase.passengerid__r.Special_Meal__c;

                    //M@I:M2 popular nationality group for report Onboard Catering by Nationality
                    if (thiscti.Nationality_txt__c != null && thiscti.Nationality_txt__c != '') {
                        if (thiscti.Nationality_txt__c == 'Thai')
                            thiscti.Nationality_Group__c = 'Thai';
                        else
                            thiscti.Nationality_Group__c = 'Non-Thai';
                    }

                    system.debug('this case : ' + thiscase);
                    system.debug('this cti : ' + JSON.serialize(thiscti));
                    System.debug('JK: Maprsectorarea - ' + JSON.serialize(Maprsectorarea));
                    System.debug('JK: flightMap - ' + JSON.serialize(flightMap));
                    if (Maprsectorarea.size() > 0) {
                        if (thiscti.FlightId__c != null && thiscti.Sector_txt__c != null && flightMap.containsKey(thiscti.FlightId__c)) {
                            String Sector = thiscti.Sector_txt__c;
                            Flight__c thisFlight = (Flight__c) flightMap.get(thiscti.FlightId__c);
                            if ((thisFlight.Flight_Number__c != null || thisFlight.Name == 'TGXXX') && Sector != null) {
                                String ctiAreaWithSectorKey = (thisFlight.Flight_Number__c != null ? thisFlight.Flight_Number__c.right(3) : thisFlight.Name.right(3)) + Sector.remove('-');
                                System.debug('JK: ctiAreaWithSectorKey - ' + ctiAreaWithSectorKey);
                                if (Maprsectorarea.Containskey(ctiAreaWithSectorKey)) {
                                    thiscti.area__c = Maprsectorarea.get(ctiAreaWithSectorKey).Area__c;
                                    //thiscti.Region_txt__c = Maprsectorarea.get(ctiAreaWithSectorKey).Region__c;
                                    areaUnidentified = false;
                                    //break;
                                }
                            }
                        }
                    }

                    if (Maproutearea.size() > 0) {
                        if (thiscti.CTI_Station__c != null) {
                            system.debug('CTI Station : ' + thiscti.CTI_Station__c);
                            system.debug('Map area : ' + Maproutearea);
                            if (Maproutearea.Containskey(thiscti.CTI_Station__c)) {
                                thiscti.STN__c = Maproutearea.get(thiscti.CTI_Station__c).STN__c;
                                sectorUnidentified = false;
                                //break;
                            }
                        }
                    }
                }

                if (areaUnidentified) {
                    thiscti.area__c = Unidentified;
                }
                if (sectorUnidentified) {
                    thiscti.STN__c = Unidentified;
                }
            }
        }
    }

    public static void updateCTIContinent(List<CTI__c> ctilist){
        if(ctilist != null && !ctilist.isEmpty()){
            Set<Id> caseIdSet = getCaseIdSetFromCTIList(ctilist);
            Map<Id, Case> casemap = null;
            if(caseIdSet != null) casemap = getmapcase(caseIdSet);
            if(casemap != null){
                Map<String, String> continentlist = getContinentMapByNationalityFullname();
                for(CTI__c cti : ctilist){
                    if(casemap.containsKey(cti.Caseid__c)){
                        Case eachcase = casemap.get(cti.Caseid__c);
                        if(cti.Nationality_txt__c == eachcase.Passengerid__r.Nationality_Fullname__c){
                            if(continentlist.containsKey(eachcase.Passengerid__r.Nationality_Fullname__c))cti.Continent_txt__c = eachcase.passengerid__r.Continent__c;
                            else cti.Continent_Txt__c = Unidentified;
                        }
                        else{
                            if(continentlist.containsKey(cti.Nationality_txt__c))cti.Continent_txt__c = continentlist.get(cti.Nationality_txt__c);
                            else cti.Continent_Txt__c = Unidentified;
                        }
                    }
                }
            }
        }
    }

    public static Set<Id> getCaseIdSetFromCTIList(List<CTI__c> ctilist){
        Set<Id> returnIdSet = new Set<Id>();
        if(ctilist != null && !ctilist.isEmpty()){
            for(CTI__c cti : ctilist) returnIdSet.add(cti.Caseid__c);
        }
        if(!ctilist.isEmpty()) return returnIdSet;
        return null;
    }

    private static Map<id, Case> getmapcase(set<ID> setcaseid) {
        list<Case> listcase = new list<Case>();
        Map<id, Case> mapcase = new Map<id, Case>();
        listcase = [Select id, flightid__c, flightid__r.Sector__c, flightid__r.Origin__c, flightid__r.Departure_STN__c,
                    flightid__r.Arrival_STN__c, flightid__r.flight_Number__c,
                    description, passengerid__r.Special_Meal__c, passengerid__r.Nationality_Fullname__c, passengerid__r.Continent__c from Case Where id IN: setcaseid];

        if (listcase.size() > 0) {
            for (Case thiscase : listcase) {
                mapcase.put(thiscase.id, thiscase);
            }
        }

        return mapcase;
    }

    private static Map<String, CTI_Route_Area__c> getmaproutearea(List<CTI_Route_Area__c> listroutearea) {
        Map<String, CTI_Route_Area__c> Maproutearea = new Map<String, CTI_Route_Area__c>();
        string result = '';
        for (CTI_Route_Area__c routearea : listroutearea) {
            Maproutearea.put(routearea.name , routearea);
            if (result == '')
                result = routearea.name;
            else
                result += ',' + routearea.name;
        }
        system.debug('result areaaaa : ' + result);
        return Maproutearea;
    }

    private static Map<String, CTI_Area_with_Sector__c> getmapsectorarea(List<CTI_Area_with_Sector__c> listsectorwitharea) {
        Map<String, CTI_Area_with_Sector__c> Maprsectorarea = new Map<String, CTI_Area_with_Sector__c>();
        for (CTI_Area_with_Sector__c sectorarea : listsectorwitharea) {
            Maprsectorarea.put(sectorarea.name , sectorarea);
        }

        return Maprsectorarea;
    }

    public static void setCTISectorFollowFlight(CTI__c thiscti, Map<String, SObject> flightMap) {
        if (thiscti.FlightId__c != null) {
            thiscti.Sector_txt__c = flightMap.get(thiscti.FlightId__c) != null && ((Flight__c)flightMap.get(thiscti.FlightId__c)).Sector__c != '-' ? ((Flight__c)flightMap.get(thiscti.FlightId__c)).Sector__c : thiscti.Sector_txt__c;
        }
    }

    private static Map<String, String> getContinentMapByNationalityFullname(){
        Map<String, String> returnMap = new Map<String, String>();
        List<Nationality_Master__mdt> continentlist = [SELECT Id, Continent__c, Nationality_Full_Name__c FROM Nationality_Master__mdt WHERE Primary__c = true];
        for(Nationality_Master__mdt continent : continentlist){
            returnMap.put(continent.Nationality_Full_Name__c, continent.Continent__c);
        }

        return returnMap;
    }

}