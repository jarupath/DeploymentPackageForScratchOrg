@isTest
public class CSE_SOAPNewPaxList_WS_Test {

	@testSetup static void DataPreparation() {
		MockupData_Test.initialApplicationLogCustomSetting();

		List<TG_WS_SETTING__c> tgwssetting = new List<TG_WS_SETTING__c>();
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_ENDPOINT', TG_WS_VALUE__c = 'http://202.122.131.25/pdt/dcs/listing/pax'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_USERNAME', TG_WS_VALUE__c = 'FB_SICSE'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_PASSWORD', TG_WS_VALUE__c = 'tgfbtgfb1'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_REQ_TXN_ID', TG_WS_VALUE__c = 'SFDC_SICSE'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_REQ_USER_ID', TG_WS_VALUE__c = ''));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_REQ_ID', TG_WS_VALUE__c = 'FB_SICSE_DCS'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_REQ_PWD', TG_WS_VALUE__c = ''));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_SVC_VER', TG_WS_VALUE__c = 'v1_0'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_MW_TXN_ID', TG_WS_VALUE__c = ''));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'NEW_PAX_LIST_TIMEOUT', TG_WS_VALUE__c = '120000'));
		insert tgwssetting;
	}

	@isTest static void testGetPaxSuccess() {
		setupWSCallout('s');
		List<Map<String, String>> filterListMap = new List<Map<String, String>>();
		List<String> groupIndicator = new List<String>();
		groupIndicator.add('OFD');
		String carrier = 'TG';
		String fltNo = '103';
		String departureDate = '2016-03-04';
		String boardPoint = 'CNX';

		Test.startTest();
		String response = getPaxCallout(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);
		Test.stopTest();

		System.debug('DEBUG - testGetPaxSuccess');
		System.debug(response);
	}

	@isTest static void testGetPaxFailure() {
		setupWSCallout('e');
		List<Map<String, String>> filterListMap = new List<Map<String, String>>();
		List<String> groupIndicator = new List<String>();
		groupIndicator.add('OFD');
		String carrier = 'TG';
		String fltNo = '103';
		String departureDate = '2016-03-04';
		String boardPoint = 'CNX';

		Test.startTest();
		String response = getPaxCallout(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);
		Test.stopTest();

		System.debug('DEBUG - testGetPaxFailure');
		System.debug(response);
	}

	@isTest static void testGetPaxModelSuccess() {
		setupWSCallout('s');
		List<Map<String, String>> filterListMap = new List<Map<String, String>>();
		List<String> groupIndicator = new List<String>();
		groupIndicator.add('OFD');
		String carrier = 'TG';
		String fltNo = '103';
		String departureDate = '2016-03-04';
		String boardPoint = 'CNX';

		Test.startTest();
		WS_New_Pax_List_Model responseModel = getPaxModelCallout(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);
		Test.stopTest();

		System.debug('DEBUG - testGetPaxModelSuccess');
		System.debug(responseModel);
	}

	@isTest static void testGetPaxModelFailure() {
		setupWSCallout('e');
		List<Map<String, String>> filterListMap = new List<Map<String, String>>();
		List<String> groupIndicator = new List<String>();
		groupIndicator.add('OFD');
		String carrier = 'TG';
		String fltNo = '103';
		String departureDate = '2016-03-04';
		String boardPoint = 'CNX';

		Test.startTest();
		WS_New_Pax_List_Model responseModel = getPaxModelCallout(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);
		Test.stopTest();

		System.assertEquals(null, responseModel, 'response model should be null due to the return response is error and callout will be error. P.S.: error log will be added to application log in flight service part');

		System.debug('DEBUG - testGetPaxModelFailure');
		System.debug(responseModel);
	}

	public static void setupWSCallout(String calloutType) {
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		if (calloutType == 's') {
			endpoint2TestResp.put(Mock_CSE_NewPaxList_Response.getNewPaxListEndPoint(), Mock_CSE_NewPaxList_Response.getNewPaxListResponseSuccess());
		} else if (calloutType == 'e') {
			endpoint2TestResp.put(Mock_CSE_NewPaxList_Response.getNewPaxListEndPoint(), Mock_CSE_NewPaxList_Response.getNewPaxListResponseFailure());
		}

		HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

	private static String getPaxCallout(List<Map<String, String>> filterListMap, List<String> groupIndicator, String carrier, String fltNo, String departureDate, String boardPoint) {
		CSE_SOAPNewPaxList_WS ws = new CSE_SOAPNewPaxList_WS();
		String response = ws.getPax(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);
		return response;
	}

	private static WS_New_Pax_List_Model getPaxModelCallout(List<Map<String, String>> filterListMap, List<String> groupIndicator, String carrier, String fltNo, String departureDate, String boardPoint) {
		CSE_SOAPNewPaxList_WS ws = new CSE_SOAPNewPaxList_WS();
		WS_New_Pax_List_Model responseModel = ws.getPaxModel(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);
		return responseModel;
	}
}