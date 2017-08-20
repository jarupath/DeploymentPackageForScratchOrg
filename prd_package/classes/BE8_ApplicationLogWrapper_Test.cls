@isTest
private class BE8_ApplicationLogWrapper_Test {
	
	@isTest static void test_method_one() {
		BE8_ApplicationLogWrapper log = new BE8_ApplicationLogWrapper();
		log.source = 'TEST';
		log.sourceFunction = 'TEST';
		log.referenceId = 'TEST';
		log.referenceInfo = 'TEST';
		log.logMessage = 'TEST';
		log.payload = 'TEST';
		log.ex = null;
		log.debugLevel = 'TEST';
		log.logCode = 'TEST';
		log.timer = 1231231232;
	}
}