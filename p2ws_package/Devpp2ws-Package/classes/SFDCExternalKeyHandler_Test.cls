@isTest
public class SFDCExternalKeyHandler_Test {
	@isTest
	static void testConstructure() {
		SFDCExternalKeyHandler classObj = new SFDCExternalKeyHandler();
	}
	@isTest
	static void test_reservedExternalKey() {
		String objectType = 'Account';
		Set<String> setGroupKey = new Set<String> {'ACC01', 'ACC02'};
		Integer sizess = 10;

		List<SFDC_External_Key__c> listExternalObj = [Select Id, Name From SFDC_External_Key__c ];

		System.assertEquals(listExternalObj.size(), 0);

		Map<String, Integer> mapReserved = SFDCExternalKeyHandler.reservedExternalKey(objectType, setGroupKey, sizess);

		List<SFDC_External_Key__c> listAfterReserve = [Select Id, Name From SFDC_External_Key__c ];
		System.assertEquals(listAfterReserve.size(), 2);
		System.assertEquals(mapReserved.get('ACC01'), 1 );
		System.assertEquals(mapReserved.get('ACC02'), 1 );
	}
	@isTest
	static void test_existingCase() {
		mockUpSFDCKeyObj();
		//for(Integer i=0; i<15000; i++){}
		String objectType = 'Account';
		Set<String> setGroupKey = new Set<String> {'ACC01', 'ACC02'};
		Integer sizess = 10;

		List<SFDC_External_Key__c> listExternalObj = [Select Id, Name From SFDC_External_Key__c ];

		System.assertEquals(listExternalObj.size(),1 );

		Map<String, Integer> mapReserved = SFDCExternalKeyHandler.reservedExternalKey(objectType, setGroupKey, sizess);

		List<SFDC_External_Key__c> listAfterReserve = [Select Id, Name From SFDC_External_Key__c ];
		System.debug('DEBUG - test_existingCase');
		System.debug(mapReserved);
		System.debug(listAfterReserve);
		System.assertEquals(listAfterReserve.size(), 2);
		System.assertEquals(mapReserved.get('ACC01'), 10 );
		System.assertEquals(mapReserved.get('ACC02'), 1 );
	}

	@isTest
	static void test_leadingZeroFormat() {
		Integer givenNumber = 10;
		Integer length = 3;
		String afterLeading  = SFDCExternalKeyHandler.leadingZeroFormat(givenNumber, length);
		System.assertEquals('010', afterLeading);
	}
	@isTest
	static void test_getMonthYearKey() {
		Date thisDate = System.Today();
		SFDCExternalKeyHandler.getMonthYearKey(thisDate);
	}

	public static void mockUpSFDCKeyObj() {
		SFDC_External_Key__c thisObj = new SFDC_External_Key__c(
		    Object_Type__c = 'Account',
		    Group_Key__c = 'ACC01',
		    Last_Key__c = 10
		);
		insert thisObj;
	}
}