@isTest
private class Performance_Debugger_Test {
	@isTest
	static void test() {
		Performance_Debugger debugger = new Performance_Debugger();
		debugger.start();
		debugger.stop();
		System.assert(debugger.getMessage().contains('timeTaken'));
		System.assert(debugger.getMessage().contains('cpuTimeTaken'));
	}
}