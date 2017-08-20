public with sharing class TG_Utility {
	public TG_Utility() {

	}

	public static Integer getFlightNumberAsInteger(String flightNumber) {
		return Integer.valueOf(flightNumber.replaceAll('TG', ''));
	}
}