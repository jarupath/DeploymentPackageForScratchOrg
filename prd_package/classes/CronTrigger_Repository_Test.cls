@isTest
private class CronTrigger_Repository_Test {

	@isTest
	static void testGetCronTriggerByName() {
		String nowCRON = BE8_DateUtility.getExactCRONFromDateTime(DateTime.now().addMinutes(1));
		Test.startTest();
		System.schedule('test', nowCRON, new PreFlightBatchScheduler('', '', null, '', 1));

		List<CronTrigger> jobs = CronTrigger_Repository.getInstance().getByName(new Set<String> {'test'});
		Assert.assertEquals(1, jobs.size());
		Test.stopTest();
	}
}