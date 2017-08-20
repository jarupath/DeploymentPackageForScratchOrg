@RestResource(urlMapping = '/flightschedule/*')
global without sharing class MB_RESTFlightScheduleService {
	@HttpPost
	global static List<MB_RestResponseInfoModel.flightSchedule_model> queryFlightSchedule(String baseStation) {
		List<FlightScheduleService.FlightScheduleRecord> scheduleList = FlightScheduleService.getSchedule(12, 12, System.now(), baseStation);
		return convertFlightScheduleToMobileModelList(scheduleList);
	}

	private static List<MB_RestResponseInfoModel.flightSchedule_model> convertFlightScheduleToMobileModelList(List<FlightScheduleService.FlightScheduleRecord> scheduleList) {
		List<MB_RestResponseInfoModel.flightSchedule_model> mobileModelList = new List<MB_RestResponseInfoModel.flightSchedule_model>();
		for (FlightScheduleService.FlightScheduleRecord eachItem : scheduleList) {
			MB_RestResponseInfoModel.flightSchedule_model mobileModel = new MB_RestResponseInfoModel.flightSchedule_model();
			mobileModel = assignScheduleId(eachItem, mobileModel);
			mobileModel.acReg = eachItem.acReg;
			mobileModel.serviceableCount = eachItem.aircraft.Number_Of_Serviceables__c;
			mobileModel.blockCount = eachItem.aircraft.Number_Of_Blocks__c;
			mobileModel.malfunctionCount = eachItem.aircraft.Number_Of_Malfunctions__c;
			mobileModel.completedCount = eachItem.aircraft.Number_Of_Completes__c;
			mobileModel.noActionCount = eachItem.aircraft.Number_Of_NoActions__c;
			mobileModel.arrFltFrom = eachItem.arrFlightFrom;
			if (eachItem.arrivalFlight != null) {
				mobileModel.arrFltName = eachItem.arrivalFlight.Name;
				mobileModel.arrBookingPax = eachItem.arrivalFlight.Booking_Passengers__c;
				mobileModel.staLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.arrivalFlight.STA_LT_DateTime__c);
				mobileModel.staUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.arrivalFlight.STA_UTC_DateTime__c);
				mobileModel.etaLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.arrivalFlight.ETA_LT_DateTime__c);
				mobileModel.etaUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.arrivalFlight.ETA_UTC_DateTime__c);
				mobileModel.arrFltConfig = eachItem.arrivalFlight.Aircraft_Configuration__c;
				mobileModel.arrFltLastM = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.arrivalFlight.LastModifiedDate);
			}
			mobileModel.acType = eachItem.acType;
			mobileModel.bayArrDep = eachItem.bayArrDep;
			mobileModel.depFltTo = eachItem.depFlightTo;
			if (eachItem.departureFlight != null) {
				mobileModel.depFltName = eachItem.departureFlight.Name;
				mobileModel.depBookingPax = eachItem.departureFlight.Booking_Passengers__c;
				mobileModel.stdLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.departureFlight.STD_LT_DateTime__c);
				mobileModel.stdUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.departureFlight.STD_UTC_DateTime__c);
				mobileModel.etdLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.departureFlight.ETD_LT_DateTime__c);
				mobileModel.etdUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.departureFlight.ETD_UTC_DateTime__c);
				mobileModel.depFltConfig = eachItem.departureFlight.Aircraft_Configuration__c;
				mobileModel.depFltLastM = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachItem.departureFlight.LastModifiedDate);
			}
			mobileModelList.add(mobileModel);
		}
		return mobileModelList;
	}

	private static MB_RestResponseInfoModel.flightSchedule_model assignScheduleId(FlightScheduleService.FlightScheduleRecord eachItem, MB_RestResponseInfoModel.flightSchedule_model mobileModel) {
		String aircraftId;
		String arrFlightId;
		String depFlightId;
		if (eachItem.aircraft != null) {
			aircraftId = eachItem.aircraft.Id;
		}
		if (eachItem.arrivalFlight != null) {
			arrFlightId = eachItem.arrivalFlight.Id;
		}
		if (eachItem.departureFlight != null) {
			depFlightId = eachItem.departureFlight.Id;
		}

		mobileModel.Id = aircraftId + '_' + arrFlightId + '_' + depFlightId;
		mobileModel.arrFltId = arrFlightId;
		mobileModel.depFltId = depFlightId;
		return mobileModel;
	}
}