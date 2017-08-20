@isTest
private class LOPALabelRepositoryTest {

	@isTest static void test_method_one() {
		LOPALabelRepository lopaLabelRepo = new LOPALabelRepository('3302');
		Assert.assertEquals('G2', lopaLabelRepo.getActualLabelFromTempLabel('1_0_G_3_R'));
		Assert.assertEquals(null, lopaLabelRepo.getActualLabelFromTempLabel('1_0_G_4_R'));
	}
}