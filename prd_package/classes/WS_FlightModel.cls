public class WS_FlightModel {
    //public static void consumeObject(JSONParser parser) {
    //    Integer depth = 0;
    //    do {
    //        JSONToken curr = parser.getCurrentToken();
    //        if (curr == JSONToken.START_OBJECT || 
    //            curr == JSONToken.START_ARRAY) {
    //            depth++;
    //        } else if (curr == JSONToken.END_OBJECT ||
    //            curr == JSONToken.END_ARRAY) {
    //            depth--;
    //        }
    //    } while (depth > 0 && parser.nextToken() != null);
    //}

    public Return_Z return_Z {get;set;} // in json: return

    //public WS_FlightModel(JSONParser parser) {
    //    while (parser.nextToken() != JSONToken.END_OBJECT) {
    //        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
    //            String text = parser.getText();
    //            if (parser.nextToken() != JSONToken.VALUE_NULL) {
    //                if (text == 'return') {
    //                    return_Z = new Return_Z(parser);
    //                } else {
    //                    System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
    //                    consumeObject(parser);
    //                }
    //            }
    //        }
    //    }
    //}
    
    public class Return_Z {
        public String destination {get;set;} 
        public String changeFlightDateLT {get;set;}
        public String changeFlightDateUTC {get;set;}
        public String changeFlightNo {get;set;}
        public String flightCancelFlag {get;set;} 
        public String flightChangeFlag {get;set;} 
        public String flightDateLT {get;set;} 
        public String flightDateUTC {get;set;} 
        public String flightNo {get;set;} 
        public List<Legdetail> legdetail {get;set;} 
        public String nextFlightNo {get;set;} 
        public String nextFlightSTD_LT {get;set;} 
        public String nextFlightSTD_UTC {get;set;} 
        public String origin {get;set;} 

        //public Return_Z(JSONParser parser) {
        //    while (parser.nextToken() != JSONToken.END_OBJECT) {
        //        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
        //            String text = parser.getText();
        //            System.debug('TEXT :' + text);
        //            if (parser.nextToken() != JSONToken.VALUE_NULL) {
        //                if (text == 'destination') {
        //                    destination = parser.getText();
        //                } else if (text == 'flightCancelFlag') {
        //                    flightCancelFlag = parser.getText();
        //                } else if (text == 'flightChangeFlag') {
        //                    flightChangeFlag = parser.getText();
        //                } else if (text == 'flightDateLT') {
        //                    flightDateLT = parser.getText();
        //                } else if (text == 'flightDateUTC') {
        //                    flightDateUTC = parser.getText();
        //                } else if (text == 'flightNo') {
        //                    flightNo = parser.getText();
        //                } else if (text == 'legdetail') {
        //                    legdetail = new List<Legdetail>();
        //                    while (parser.nextToken() != JSONToken.END_ARRAY) {
        //                        legdetail.add(new Legdetail(parser));
        //                    }
        //                } else if (text == 'nextFlightNo') {
        //                    nextFlightNo = parser.getText();
        //                } else if (text == 'nextFlightSTD_LT') {
        //                    nextFlightSTD_LT = parser.getText();
        //                } else if (text == 'nextFlightSTD_UTC') {
        //                    nextFlightSTD_UTC = parser.getText();
        //                } else if (text == 'origin') {
        //                    origin = parser.getText();
        //                } else {
        //                    System.debug(LoggingLevel.WARN, 'Return_Z consuming unrecognized property: '+text);
        //                    consumeObject(parser);
        //                }
        //            }
        //        }
        //    }
        //}
    }
    
    public class Legdetail {
        public String ATA_LT {get;set;} 
        public String ATA_UTC {get;set;} 
        public String ATD_LT {get;set;} 
        public String ATD_UTC {get;set;} 
        public String aircraftRegistration {get;set;} 
        public String aircraftType {get;set;} 
        public String arrivalSTN {get;set;} 
        public String arrivalSTNICAO {get;set;} 
        public String arrivalSTNName {get;set;} 
        public String arrivalTerminal {get;set;}
        public String arrivalDelay {get;set;}
        public String blockTime {get;set;} 
        public String codeshareInfo {get;set;}
        public String departureTerminal {get;set;}
        public String departureDelay {get;set;} 
        public String departureSTN {get;set;} 
        public String departureSTNICAO {get;set;} 
        public String departureSTNName {get;set;} 
        public String ETA_LT {get;set;} 
        public String ETA_UTC {get;set;} 
        public String ETD_LT {get;set;} 
        public String ETD_UTC {get;set;} 
        public String gate {get;set;}
        public String legSeq {get;set;} 
        public String STA_LT {get;set;} 
        public String STA_UTC {get;set;} 
        public String STD_LT {get;set;} 
        public String STD_UTC {get;set;} 
        public String bay {get;set;}

        //public Legdetail(JSONParser parser) {
        //    while (parser.nextToken() != JSONToken.END_OBJECT) {
        //        if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
        //            String text = parser.getText();
        //            if (parser.nextToken() != JSONToken.VALUE_NULL) {
        //                if (text == 'ATA_LT') {
        //                    ATA_LT = parser.getText();
        //                } else if (text == 'ATA_UTC') {
        //                    ATA_UTC = parser.getText();
        //                } else if (text == 'ATD_LT') {
        //                    ATD_LT = parser.getText();
        //                } else if (text == 'ATD_UTC') {
        //                    ATD_UTC = parser.getText();
        //                } else if (text == 'aircraftRegistration') {
        //                    aircraftRegistration = parser.getText();
        //                } else if (text == 'aircraftType') {
        //                    aircraftType = parser.getText();
        //                } else if (text == 'arrivalSTN') {
        //                    arrivalSTN = parser.getText();
        //                } else if (text == 'arrivalSTNICAO') {
        //                    arrivalSTNICAO = parser.getText();
        //                } else if (text == 'arrivalSTNName') {
        //                    arrivalSTNName = parser.getText();
        //                } else if (text == 'blockTime') {
        //                    blockTime = parser.getText();
        //                } else if (text == 'departureDelay') {
        //                    departureDelay = parser.getText();
        //                } else if (text == 'departureSTN') {
        //                    departureSTN = parser.getText();
        //                } else if (text == 'departureSTNICAO') {
        //                    departureSTNICAO = parser.getText();
        //                } else if (text == 'departureSTNName') {
        //                    departureSTNName = parser.getText();
        //                } else if (text == 'ETA_LT') {
        //                    ETA_LT = parser.getText();
        //                } else if (text == 'ETA_UTC') {
        //                    ETA_UTC = parser.getText();
        //                } else if (text == 'ETD_LT') {
        //                    ETD_LT = parser.getText();
        //                } else if (text == 'ETD_UTC') {
        //                    ETD_UTC = parser.getText();
        //                } else if (text == 'legSeq') {
        //                    legSeq = parser.getText();
        //                } else if (text == 'STA_LT') {
        //                    STA_LT = parser.getText();
        //                } else if (text == 'STA_UTC') {
        //                    STA_UTC = parser.getText();
        //                } else if (text == 'STD_LT') {
        //                    STD_LT = parser.getText();
        //                } else if (text == 'STD_UTC') {
        //                    STD_UTC = parser.getText();
        //                } else {
        //                    System.debug(LoggingLevel.WARN, 'Legdetail consuming unrecognized property: '+text);
        //                    consumeObject(parser);
        //                }
        //            }
        //        }
        //    }
        //}
    }
    
    
    //public static WS_FlightModel parse(String json) {
    //    return new WS_FlightModel(System.JSON.createParser(json));
    //}
}