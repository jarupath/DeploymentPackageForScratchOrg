@IsTest
public class WS_FlightModel_Test {
    
    // This test method should give 100% coverage
    //static testMethod void testParse() {
    //    String json = '{'+
    //    '  \"return\": {'+
    //    '    \"destination\": \"ICN\",'+
    //    '    \"flightCancelFlag\": \"false\",'+
    //    '    \"flightChangeFlag\": \"false\",'+
    //    '    \"flightDateLT\": \"30Sep16\",'+
    //    '    \"flightDateUTC\": \"30Sep16\",'+
    //    '    \"flightNo\": \"628\",'+
    //    '    \"legdetail\": ['+
    //    '      {'+
    //    '        \"ATA_LT\": \"30Sep16 1516\",'+
    //    '        \"ATA_UTC\": \"30Sep16 0716\",'+
    //    '        \"ATD_LT\": \"30Sep16 1110\",'+
    //    '        \"ATD_UTC\": \"30Sep16 0410\",'+
    //    '        \"aircraftRegistration\": \"HSTET  \",'+
    //    '        \"aircraftType\": \"330\",'+
    //    '        \"arrivalSTN\": \"HKG\",'+
    //    '        \"arrivalSTNICAO\": \"VHHH\",'+
    //    '        \"arrivalSTNName\": \"HONG KONG                     \",'+
    //    '        \"blockTime\": \"0306\",'+
    //    '        \"departureDelay\": \"AM/0025\",'+
    //    '        \"departureSTN\": \"BKK\",'+
    //    '        \"departureSTNICAO\": \"VTBS\",'+
    //    '        \"departureSTNName\": \"BANGKOK INTERNATIONAL         \",'+
    //    '        \"ETA_LT\": \"30Sep16 1458\",'+
    //    '        \"ETA_UTC\": \"30Sep16 0658\",'+
    //    '        \"ETD_LT\": \"30Sep16 1045\",'+
    //    '        \"ETD_UTC\": \"30Sep16 0345\",'+
    //    '        \"legSeq\": \"1\",'+
    //    '        \"STA_LT\": \"30Sep16 1430\",'+
    //    '        \"STA_UTC\": \"30Sep16 0630\",'+
    //    '        \"STD_LT\": \"30Sep16 1045\",'+
    //    '        \"STD_UTC\": \"30Sep16 0345\"'+
    //    '      },'+
    //    '      {'+
    //    '        \"aircraftRegistration\": \"HSTET  \",'+
    //    '        \"aircraftType\": \"330\",'+
    //    '        \"arrivalSTN\": \"ICN\",'+
    //    '        \"arrivalSTNICAO\": \"RKSI\",'+
    //    '        \"arrivalSTNName\": \"INCHEON INTERNATIONAL         \",'+
    //    '        \"blockTime\": \"0340\",'+
    //    '        \"departureSTN\": \"HKG\",'+
    //    '        \"departureSTNICAO\": \"VHHH\",'+
    //    '        \"departureSTNName\": \"HONG KONG                     \",'+
    //    '        \"legSeq\": \"2\",'+
    //    '        \"STA_LT\": \"30Sep16 2010\",'+
    //    '        \"STA_UTC\": \"30Sep16 1110\",'+
    //    '        \"STD_LT\": \"30Sep16 1530\",'+
    //    '        \"STD_UTC\": \"30Sep16 0730\"'+
    //    '      }'+
    //    '    ],'+
    //    '    \"nextFlightNo\": \"657\",'+
    //    '    \"nextFlightSTD_LT\": \"30Sep16 2120\",'+
    //    '    \"nextFlightSTD_UTC\": \"30Sep16 1220\",'+
    //    '    \"origin\": \"BKK\"'+
    //    '  }'+
    //    '}';
    //    WS_FlightModel r = WS_FlightModel.parse(json);
    //    System.assert(r != null);

    //    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    //    WS_FlightModel objRoot = new WS_FlightModel(System.JSON.createParser(json));
    //    System.assert(objRoot != null);
    //    System.assert(objRoot.return_Z == null);

    //    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    //    WS_FlightModel.Return_Z objReturn_Z = new WS_FlightModel.Return_Z(System.JSON.createParser(json));
    //    System.assert(objReturn_Z != null);
    //    System.assert(objReturn_Z.destination == null);
    //    System.assert(objReturn_Z.flightCancelFlag == null);
    //    System.assert(objReturn_Z.flightChangeFlag == null);
    //    System.assert(objReturn_Z.flightDateLT == null);
    //    System.assert(objReturn_Z.flightDateUTC == null);
    //    System.assert(objReturn_Z.flightNo == null);
    //    System.assert(objReturn_Z.legdetail == null);
    //    System.assert(objReturn_Z.nextFlightNo == null);
    //    System.assert(objReturn_Z.nextFlightSTD_LT == null);
    //    System.assert(objReturn_Z.nextFlightSTD_UTC == null);
    //    System.assert(objReturn_Z.origin == null);

    //    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    //    WS_FlightModel.Legdetail objLegdetail = new WS_FlightModel.Legdetail(System.JSON.createParser(json));
    //    System.assert(objLegdetail != null);
    //    System.assert(objLegdetail.ATA_LT == null);
    //    System.assert(objLegdetail.ATA_UTC == null);
    //    System.assert(objLegdetail.ATD_LT == null);
    //    System.assert(objLegdetail.ATD_UTC == null);
    //    System.assert(objLegdetail.aircraftRegistration == null);
    //    System.assert(objLegdetail.aircraftType == null);
    //    System.assert(objLegdetail.arrivalSTN == null);
    //    System.assert(objLegdetail.arrivalSTNICAO == null);
    //    System.assert(objLegdetail.arrivalSTNName == null);
    //    System.assert(objLegdetail.blockTime == null);
    //    System.assert(objLegdetail.departureDelay == null);
    //    System.assert(objLegdetail.departureSTN == null);
    //    System.assert(objLegdetail.departureSTNICAO == null);
    //    System.assert(objLegdetail.departureSTNName == null);
    //    System.assert(objLegdetail.ETA_LT == null);
    //    System.assert(objLegdetail.ETA_UTC == null);
    //    System.assert(objLegdetail.ETD_LT == null);
    //    System.assert(objLegdetail.ETD_UTC == null);
    //    System.assert(objLegdetail.legSeq == null);
    //    System.assert(objLegdetail.STA_LT == null);
    //    System.assert(objLegdetail.STA_UTC == null);
    //    System.assert(objLegdetail.STD_LT == null);
    //    System.assert(objLegdetail.STD_UTC == null);
    //}
}