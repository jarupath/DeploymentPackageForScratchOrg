public with sharing class Performance_Debugger {
	Long startTime, stopTime;
	Integer startCPUTime, stopCPUTime;

	public Performance_Debugger() {

	}

	public void start() {
		startTime = System.currentTimeMillis();
		startCPUTime = Limits.getCpuTime();
		stop();
	}

	public void stop() {
		stopTime = System.currentTimeMillis();
		stopCPUTime = Limits.getCpuTime();
	}

	public Integer getCpuTimeTaken() {
		return stopCPUTime - startCPUTime;
	}

	public Long getTimeTaken() {
		return stopTime - startTime;
	}

	public String getMessage() {
		return 'timeTaken=[' + getTimeTaken() + ']~cpuTimeTaken=[' + getCpuTimeTaken() + ']';
	}
}