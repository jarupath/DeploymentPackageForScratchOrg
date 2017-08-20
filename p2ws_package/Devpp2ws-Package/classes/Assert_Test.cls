@isTest
private class Assert_Test
{
	@isTest
	static void testAssertEquals() {
		Assert.assertEquals('Object', 'Object');
		Assert.assertEquals('Object', 'Object', 'Message');
	}

	@isTest
	static void testAssertNotEquals() {
		Assert.assertNotEquals('Object', 'NotEquals');
		Assert.assertNotEquals('Object', 'NotEquals', 'Message');
	}

	@isTest
	static void testAssert() {
		Assert.assert(true);
		Assert.assert(true, 'Message');
	}
}