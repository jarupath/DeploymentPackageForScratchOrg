@RestResource(urlMapping='/edocument/*')
global class MB_RESTeDocumentService {
  @HttpGet
  global static List<MB_RESTRequestInfoModel.allDoc> doGet(){
    Id userId = UserInfo.getUserId();
    Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(userId);
    List<Flight__c> flightList = [SELECT Id, Name, Destination__c, Routing__c, Flight_Number__c, Aircraft_Type__c, Departure_STN__c FROM Flight__c WHERE Id IN :flightIdSet];
    List<MB_RESTRequestInfoModel.allDoc> returnList = new List<MB_RESTRequestInfoModel.allDoc>();
    System.debug('Flight List Size: ' + flightList.size());
    System.debug('Flight List: ' + flightList);
    for(Flight__c flight : flightList){
      MB_RESTRequestInfoModel.allDoc alldoc = getAllDocFromFlight(flight);
      System.debug('All Doc: ' + alldoc);
      returnList.add(getAllDocFromFlight(flight));
    }
    System.debug('Return List: ' + returnList);
    return returnList;
  }

  global static MB_RESTRequestInfoModel.allDoc getAllDocFromFlight(Flight__c inputflight){
    MB_RESTRequestInfoModel.allDoc alldoc = new MB_RESTRequestInfoModel.allDoc();
    List<Master_Map__c> linkList = [SELECT Id, Name, Location__c, Field_Name__c FROM Master_Map__c WHERE Field_Name__c = 'E-Document'];
    Map<String, Master_Map__c> linkMap = new Map<String, Master_Map__c>();
    List<MB_RESTRequestInfoModel.dynamicLink> dynamiclink = new List<MB_RESTRequestInfoModel.dynamicLink>();
    for(Master_Map__c link : linkList){
        linkMap.put(link.Location__c, link);
    }
    allDoc.flightId = inputflight.Id;
    allDoc.manual = linkMap.get('Manual').Name;
    alldoc.functionInfo = linkMap.get('Function Info').Name;
    alldoc.safety = linkMap.get('Safety').Name;
    alldoc.service = linkMap.get('Service').Name;
    alldoc.dynamicLinkList.add(getNonMultiLinkWithoutFlightInfo(linkMap.get('Validity of Passport')));
    alldoc.dynamicLinkList.add(getNonMultiLinkWithoutFlightInfo(linkMap.get('Alcoholic on board')));
    alldoc.dynamicLinkList.add(getNonMultiLinkWithoutFlightInfo(linkMap.get('IDF')));
    alldoc.dynamicLinkList.add(getCrewProcetureLink(linkMap.get('Crew Procedure'), inputflight));
    alldoc.dynamicLinkList.add(getAACLink(linkMap.get('AAC'), inputflight));
    alldoc.dynamicLinkList.add(getWorkingRoutineLink(linkMap.get('Working Routine'), inputflight));
    alldoc.dynamicLinkList.add(getStandardLoadLink(linkMap.get('Standard Load'), inputflight));
    alldoc.dynamicLinkList.add(getCrewMealLink(linkMap.get('Crew Meal'), inputflight));
    alldoc.dynamicLinkList.add(getCACLink(linkMap.get('CAC'), inputflight));
    alldoc.dynamicLinkList.add(getCECLink(linkMap.get('CEC'), inputflight));
    alldoc.dynamicLinkList.add(getMLPLink(linkMap.get('MLP'), inputflight));
    alldoc.dynamicLinkList.add(getRouteSpecialitiesLink(linkMap.get('Route Specialities'), inputflight));
    alldoc.dynamicLinkList.add(getLLPLink(linkMap.get('LLP'), inputflight));
    System.debug('Return AllDoc: ' + alldoc);
    return alldoc;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getNonMultiLinkWithoutFlightInfo(Master_Map__c mastermap){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = false;
    dylink.startWith = null;
    dylink.link = mastermap.Name;
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getCrewProcetureLink(Master_Map__c mastermap, Flight__c inputflight){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = false;
    dylink.startWith = null;
    dylink.link = mastermap.Name + inputflight.Destination__c + '.pdf';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getWorkingRoutineLink(Master_Map__c mastermap, Flight__c inputflight){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = null;
    dylink.link = mastermap.Name + 'WR-' + inputflight.Destination__c + '/';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getRouteSpecialitiesLink(Master_Map__c mastermap, Flight__c inputflight){
    String flightNumberWithoutTG = inputflight.Flight_Number__c.remove('TG');
    String threeDigitFlightNumber = String.valueOf(Integer.valueOf(flightNumberWithoutTG));
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = false;
    dylink.startWith = null;
    dylink.link = mastermap.Name + 'RS' + threeDigitFlightNumber.substring(0, 1) + 'xx/TG' + threeDigitFlightNumber + '.pdf';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getMLPLink(Master_Map__c mastermap, Flight__c inputflight){
    String flightNumberWithoutTG = inputflight.Flight_Number__c.remove('TG');
    String threeDigitFlightNumber = String.valueOf(Integer.valueOf(flightNumberWithoutTG));
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = null;
    dylink.link = mastermap.Name + 'MLP-' + threeDigitFlightNumber.substring(0, 1) + 'xx/MLP-' + threeDigitFlightNumber + '/';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getLLPLink(Master_Map__c mastermap, Flight__c inputflight){
    String flightNumberWithoutTG = inputflight.Flight_Number__c.remove('TG');
    String threeDigitFlightNumber = String.valueOf(Integer.valueOf(flightNumberWithoutTG));
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = 'LLP ' + threeDigitFlightNumber;
    dylink.link = mastermap.Name;
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getStandardLoadLink(Master_Map__c mastermap, Flight__c inputflight){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = 'STANDARD LOAD - ' + inputflight.Destination__c;
    dylink.link = mastermap.Name;
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getCrewMealLink(Master_Map__c mastermap, Flight__c inputflight){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = null;
    dylink.link = mastermap.Name + inputflight.Departure_STN__c + '/';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getCECLink(Master_Map__c mastermap, Flight__c inputflight){
    String flightNumberWithoutTG = inputflight.Flight_Number__c.remove('TG');
    String threeDigitFlightNumber = String.valueOf(Integer.valueOf(flightNumberWithoutTG));
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = threeDigitFlightNumber;
    dylink.link = mastermap.Name + 'CEC-' + threeDigitFlightNumber.substring(0, 1) + '/';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getAACLink(Master_Map__c mastermap, Flight__c inputflight){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = false;
    dylink.startWith = null;
    dylink.link = mastermap.Name + inputflight.Aircraft_Type__c + '.pdf';
    return dylink;
  }

  global static MB_RESTRequestInfoModel.dynamicLink getCACLink(Master_Map__c mastermap, Flight__c inputflight){
    MB_RESTRequestInfoModel.dynamicLink dylink = new MB_RESTRequestInfoModel.dynamicLink();
    dylink.name = mastermap.Location__c;
    dylink.multiFlag = true;
    dylink.startWith = inputflight.Aircraft_Type__c;
    dylink.link = mastermap.Name;
    return dylink;
  }
}