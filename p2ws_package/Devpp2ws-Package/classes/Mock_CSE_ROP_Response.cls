public with sharing class Mock_CSE_ROP_Response {
	public Mock_CSE_ROP_Response() {
		
	}

	public static SingleRequestMock getCurrentMileage() {
        String responeStr = '<?xml version="1.0" encoding="UTF-8" ?><CurrentMileageRS>  <Success>Y</Success>  <PrivilegeCard>MEMBER</PrivilegeCard>  <CurrentMileage>25,114</CurrentMileage>  <MemberID>NY67945</MemberID>  <LastActivityDate>2013-07-17</LastActivityDate>  <MilesExpiry>    <Quarter>3</Quarter>    <MilesExpiryDate>2015-09-30</MilesExpiryDate>    <Year>2015</Year>    <Amount>1,772</Amount>  </MilesExpiry>  <MilesExpiry>    <Quarter>4</Quarter>    <MilesExpiryDate>2015-12-31</MilesExpiryDate>    <Year>2015</Year>    <Amount>0</Amount>  </MilesExpiry>  <MilesExpiry>    <Quarter>1</Quarter>    <MilesExpiryDate>2016-03-31</MilesExpiryDate>    <Year>2016</Year>    <Amount>0</Amount>  </MilesExpiry>  <MilesExpiry>    <Quarter>2</Quarter>    <MilesExpiryDate>2016-06-30</MilesExpiryDate>    <Year>2016</Year>    <Amount>0</Amount>  </MilesExpiry>  <FullName>Mr. ANAPAT  SUVARNASUDDHI</FullName>  <ExtendablePoints>    <Quarter>3</Quarter>    <MilesExpiryDate>2015-09-30</MilesExpiryDate>    <Year>2015</Year>    <Amount>1,772</Amount>  </ExtendablePoints></CurrentMileageRS>';

		return new SingleRequestMock(200, 'Complete', responeStr, null);
	}

	public static String getCurrentMileageEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_MILEAGE_ENDPOINT);
	}

	public static SingleRequestMock getROPProfile() {
		String responeStr = '' +
        '<?xml version="1.0" encoding="UTF-8"?>' +
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<SOAP-ENV:Header>' +
                '<ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.accenture.com/rop/enquiry/profile/getmemberprofile/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.accenture.com/rop/enquiry/profile/v1_0" xmlns:tns1="http://ws.accenture.com/rop/enquiry/profile" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                    '<ResDateTime>2016-11-25T14:39:28.552+07:00</ResDateTime>' +
                    '<ReqTxnID>MWTESTER_48853</ReqTxnID>' +
                    '<MWTxnID>SY_TGAIP_1480059568464</MWTxnID>' +
                    '<IsLastTxn>true</IsLastTxn>' +
                    '<ResCode>SUCCESS</ResCode>' +
                '</ResHeader>' +
            '</SOAP-ENV:Header>' +
            '<SOAP-ENV:Body>' +
                '<ns0:GetMemberProfileRes xmlns="http://xml.accenture.com/rop/enquiry/profile/getmemberprofile/v1_0" xmlns:ns0="http://xml.accenture.com/rop/enquiry/profile" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.accenture.com/rop/enquiry/profile/v1_0" xmlns:tns1="http://ws.accenture.com/rop/enquiry/profile">' +
                    '<getMemberProfileReturn><MemberProfileRS><Success>Y</Success><MemberID>NY67945</MemberID><RemainingMiles>11,746</RemainingMiles><Salutation>Mr.</Salutation><FirstName>ALAN</FirstName><MiddleName></MiddleName><LastName>NEAL</LastName><Suffix></Suffix><ChildFlag></ChildFlag><HomePhone><HomePhoneType>H</HomePhoneType><CountryCode>61</CountryCode><AreaCode>8</AreaCode><PhoneNumber>92746777</PhoneNumber><Extension></Extension><SeqNo>1897590</SeqNo></HomePhone><Email>test@beryl8.com</Email><EmlSeqNo></EmlSeqNo><SPCCode></SPCCode><BirthDate>1942-02-06</BirthDate><Address><AdrSeqNo>1021299</AdrSeqNo><Type>HOM</Type><CompanyName1></CompanyName1><CompanyName2></CompanyName2><AddressLine1>2JAMESSTREET</AddressLine1><AddressLine2></AddressLine2><AddressLine3></AddressLine3><CityName>BELLEVUE</CityName><ProvinceCode>WA</ProvinceCode><CountryCode>AU</CountryCode><Postal>6056</Postal></Address><Phone><Type>H</Type><AreaCode>8</AreaCode><PhoneNumber>92746777</PhoneNumber><Extension></Extension><CountryCode>61</CountryCode><SeqNo>1897590</SeqNo></Phone><Phone><Type>F</Type><AreaCode>8</AreaCode><PhoneNumber>92746777</PhoneNumber><Extension></Extension><CountryCode>61</CountryCode><SeqNo>1897590</SeqNo></Phone><Phone><Type>BPH</Type><AreaCode>8</AreaCode><PhoneNumber>92746777</PhoneNumber><Extension></Extension><CountryCode>61</CountryCode><SeqNo>1897590</SeqNo></Phone><Phone><Type>C</Type><AreaCode>8</AreaCode><PhoneNumber>438746726</PhoneNumber><Extension></Extension><CountryCode>61</CountryCode><SeqNo>1897591</SeqNo></Phone><PrivilegeCard>MEMBER</PrivilegeCard><CardExpiryDate>2016-09-28</CardExpiryDate><Language>E</Language><Status>AC</Status><Gender>M</Gender><EnrollSource>MAIL</EnrollSource><EnrollDate>2005-06-21</EnrollDate><Nationality></Nationality><Religion></Religion><PassportNumber></PassportNumber><IdentificationNumber></IdentificationNumber></MemberProfileRS></getMemberProfileReturn>' +
                '</ns0:GetMemberProfileRes>' +
            '</SOAP-ENV:Body>' +
        '</SOAP-ENV:Envelope>';
		return new SingleRequestMock(200, 'Complete', responeStr, null);
	}

	public static String getROPProfileEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_ENDPOINT);
	}

    public static SingleRequestMock getAdditionalProfile() {
        String responeStr = '{'+
        '  \"AdditionalMemberProfileRS\": {'+
        '    \"Success\": {'+
        '      \"MemberID\": \"NY67945\",'+
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
        return new SingleRequestMock(200, 'Complete', responeStr, null);
    }

    public static String getAdditionalProfileEndPoint() {
        return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_ENDPOINT);
    }
}