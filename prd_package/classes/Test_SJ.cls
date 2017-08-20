@isTest
private class Test_SJ {

	@testSetup static void methodName() {
		//Account account1 = MockupData_Test.createAccount('accountName1');
		//account1.Customer_External_Id__c = '1';
		//insert account1;
	}

	@isTest static void test() {
		//String xml = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:q0="http://dao.appraisalservice.cw.tg/"><env:Header><ReqHeader xmlns="http://xml.accenture.com/common/header"><ReqDateTime>2017-01-26T04:18:16Z</ReqDateTime><ReqTxnID>null20170126-111816</ReqTxnID><SvcVer>v1_0</SvcVer><IsLastTxn>true</IsLastTxn><Credentials><MWCredential><ReqID></ReqID><ReqPwd/><UserID/></MWCredential></Credentials><MWTxnID></MWTxnID></ReqHeader><Security xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><UsernameToken><Username>FB_SICSE</Username><Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">tgfbtgfb1</Password><Nonce>LTgwNDc5MTU0NzE1MzQzNzY1Njg=</Nonce><Created>2017-01-26T04:18:16Z</Created></UsernameToken></Security></env:Header><env:Body><q0:CrewEAppraisal><arg0><createBy>15791</createBy><createDate></createDate><formNumber>02</formNumber><staffID>12103</staffID><evaluateStaffID>15791</evaluateStaffID><evaluatedAirlineCode>TG</evaluatedAirlineCode><evaluatedAircraft>777</evaluatedAircraft><evaluatedArrPort>BKK</evaluatedArrPort><evaluateData><subject_num>01</subject_num><item_num>01</item_num><comment>null</comment></evaluateData><evaluateData><subject_num>01</subject_num><item_num>02</item_num><comment>null</comment></evaluateData><dataSize>2</dataSize></arg0></q0:CrewEAppraisal></env:Body></env:Envelope>';

		//String fail = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><fs:FaultDetail xmlns:fs="http://www.forumsystems.com/2004/04/soap-fault-detail"><fs:SystemName>SWSGTHT1</fs:SystemName><fs:User></fs:User><fs:Policy>CrewAppraisalServiceDAOService</fs:Policy><fs:TaskList>AIP_WS-Security_Task_List</fs:TaskList><fs:Task>User Identity &amp; Access Control</fs:Task></fs:FaultDetail></soap:Header><soap:Body><soap:Fault><faultcode xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">wsse:FailedAuthentication</faultcode><faultstring xml:lang="en-US">Replay detected</faultstring></soap:Fault></soap:Body></soap:Envelope>';


		//BE8_XmlUtility.parse(xml);
		//BE8_XmlUtility.parse(fail);
	}
}