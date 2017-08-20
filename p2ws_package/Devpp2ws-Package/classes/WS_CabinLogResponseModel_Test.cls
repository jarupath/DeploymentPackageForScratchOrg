@IsTest
public class WS_CabinLogResponseModel_Test {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"Customercomplaintreply\": {'+
        '    \"Responsetype\": \"S\",'+
        '    \"Responsetext\": \"Order UA007C011016 saved with notification UA007C011016\"'+
        '  }'+
        '}';
        WS_CabinLogResponseModel obj = WS_CabinLogResponseModel.parse(json);
        System.assert(obj != null);
    }
}