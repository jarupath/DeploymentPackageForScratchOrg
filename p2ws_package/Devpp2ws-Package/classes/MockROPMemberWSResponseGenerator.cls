@isTest
public class MockROPMemberWSResponseGenerator implements HttpCalloutMock {

	protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    
	public MockROPMemberWSResponseGenerator() {
		this.code = 200;
        this.status = 'SUCCESS';
        this.body = '' +
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
                    '<getMemberProfileReturn><![CDATA[<MemberProfileRS><Success>Y</Success><MemberID>QW36598</MemberID><RemainingMiles>11,746</RemainingMiles><Salutation>Mr.</Salutation><FirstName>ALAN</FirstName><MiddleName></MiddleName><LastName>NEAL</LastName><Suffix></Suffix><ChildFlag></ChildFlag><HomePhone><HomePhoneType>H</HomePhoneType><CountryCode>61</CountryCode><AreaCode>8</AreaCode><PhoneNumber>92746777</PhoneNumber><Extension></Extension><SeqNo>1897590</SeqNo></HomePhone><Email></Email><EmlSeqNo></EmlSeqNo><SPCCode></SPCCode><BirthDate>1942-02-06</BirthDate><Address><AdrSeqNo>1021299</AdrSeqNo><Type>HOM</Type><CompanyName1></CompanyName1><CompanyName2></CompanyName2><AddressLine1>2 JAMES STREET</AddressLine1><AddressLine2></AddressLine2><AddressLine3></AddressLine3><CityName>BELLEVUE</CityName><ProvinceCode>WA</ProvinceCode><CountryCode>AU</CountryCode><Postal>6056</Postal></Address><Phone><Type>H</Type><AreaCode>8</AreaCode><PhoneNumber>92746777</PhoneNumber><Extension></Extension><CountryCode>61</CountryCode><SeqNo>1897590</SeqNo></Phone><Phone><Type>C</Type><AreaCode>8</AreaCode><PhoneNumber>438746726</PhoneNumber><Extension></Extension><CountryCode>61</CountryCode><SeqNo>1897591</SeqNo></Phone><PrivilegeCard>MEMBER</PrivilegeCard><CardExpiryDate>2016-09-28</CardExpiryDate><Language>E</Language><Status>AC</Status><Gender>M</Gender><EnrollSource>MAIL</EnrollSource><EnrollDate>2005-06-21</EnrollDate><Nationality></Nationality><Religion></Religion><PassportNumber></PassportNumber><IdentificationNumber></IdentificationNumber></MemberProfileRS>]]></getMemberProfileReturn>' +
                '</ns0:GetMemberProfileRes>' +
            '</SOAP-ENV:Body>' +
        '</SOAP-ENV:Envelope>';
        this.responseHeaders = new Map<String, String> {'Content-Type' => 'application/xml'};
	}

	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}