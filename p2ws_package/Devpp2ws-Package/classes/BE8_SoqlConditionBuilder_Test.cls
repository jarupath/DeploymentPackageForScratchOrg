@isTest
private class BE8_SoqlConditionBuilder_Test
{
	@isTest
	static void test() {
		BE8_SoqlConditionBuilder condition = new BE8_SoqlConditionBuilder('Account');
		condition.add('Name != null');
		condition.add('TestField', 'Test');
		condition.add('TestIn', new Set<String>{'Test1', 'Test2'});
		Assert.assertEquals(false, condition.isEmpty());
		Assert.assertEquals('(Name != null Account TestField = \'Test\' Account TestIn IN (\'Test1\',\'Test2\'))', condition.getString());
	}
}