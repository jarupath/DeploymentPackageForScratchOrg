@isTest
private class LOPA_RestResource_Test {
	@isTest
	static void testGetMethod() {
		String result = LOPA_RestResource.show();
 		System.assertEquals('test', result);
	}
}