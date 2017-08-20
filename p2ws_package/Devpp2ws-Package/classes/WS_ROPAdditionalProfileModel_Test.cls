@IsTest
public class WS_ROPAdditionalProfileModel_Test {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"AdditionalMemberProfileRS\": {'+
        '    \"Success\": {'+
        '      \"MemberID\": \"QH90845\",'+
        '      \"MaritalStatus\": \"S\",'+
        '      \"Children\": \"N\",'+
        '      \"Education\": \"S5\",'+
        '      \"Occupation\": \"J1\",'+
        '      \"Income\": \"M7\",'+
        '      \"TargetAudience\": ['+
        '        { \"Code\": \"A01\" },'+
        '        { \"Code\": \"A03\" },'+
        '        { \"Code\": \"A04\" },'+
        '        { \"Code\": \"A05\" },'+
        '        { \"Code\": \"B02\" },'+
        '        { \"Code\": \"B08\" },'+
        '        { \"Code\": \"C22\" },'+
        '        { \"Code\": \"D01\" },'+
        '        { \"Code\": \"D02\" },'+
        '        { \"Code\": \"D03\" },'+
        '        { \"Code\": \"D04\" },'+
        '        { \"Code\": \"D05\" },'+
        '        { \"Code\": \"D09\" },'+
        '        { \"Code\": \"D14\" },'+
        '        { \"Code\": \"LD07\" },'+
        '        { \"Code\": \"LD08\" },'+
        '        { \"Code\": \"LD09\" },'+
        '        { \"Code\": \"LD10\" },'+
        '        { \"Code\": \"LD11\" },'+
        '        { \"Code\": \"LD12\" },'+
        '        { \"Code\": \"LH01\" },'+
        '        { \"Code\": \"LH13\" },'+
        '        { \"Code\": \"LH14\" },'+
        '        { \"Code\": \"LH15\" },'+
        '        { \"Code\": \"LH16\" },'+
        '        { \"Code\": \"LS01\" },'+
        '        { \"Code\": \"LS19\" },'+
        '        { \"Code\": \"LS20\" },'+
        '        { \"Code\": \"LS21\" },'+
        '        { \"Code\": \"LS22\" },'+
        '        { \"Code\": \"LS23\" },'+
        '        { \"Code\": \"LS24\" },'+
        '        { \"Code\": \"LS25\" }'+
        '      ]'+
        '    }'+
        '  }'+
        '}';
        WS_ROPAdditionalProfileModel obj = WS_ROPAdditionalProfileModel.parse(json);
        System.assert(obj != null);
    }
}