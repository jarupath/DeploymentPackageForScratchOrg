public class Assert {
	public static Boolean needAssert;

	static {
		Config_Parameter__mdt needAssertParameter = [SELECT DeveloperName, Value__c FROM Config_Parameter__mdt WHERE DeveloperName = 'Assert'];
		needAssert = Boolean.valueOf(needAssertParameter.Value__c);
	}

	public static void assertEquals(Object expect, Object actual) {
		if(needAssert) {
			System.assertEquals(expect, actual);
		}
	}

	public static void assertEquals(Object expect, Object actual, String text) {
		if(needAssert) {
			System.assertEquals(expect, actual, text);
		}
	}

	public static void assertNotEquals(Object expect, Object actual) {
		if(needAssert) {
			System.assertNotEquals(expect, actual);
		}
	}

	public static void assertNotEquals(Object expect, Object actual, String text) {
		if(needAssert) {
			System.assertNotEquals(expect, actual, text);
		}
	}

	public static void assert(Boolean assertEquation) {
		if(needAssert) {
			System.assert(assertEquation);
		}
	}

	public static void assert(Boolean assertEquation, String text) {
		if(needAssert) {
			System.assert(assertEquation, text);
		}
	}
}