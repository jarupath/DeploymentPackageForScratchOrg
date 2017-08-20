public with sharing class FlightSummary {
	public class FlightSummaryView {
		public String route {get; set;}
		public String currentStation {get; set;}
		public String sta {get; set;}
		public String eta {get; set;}
		public String ata {get; set;}
		public String std {get; set;}
		public String etd {get; set;}
		public String atd {get; set;}
		public Boolean isReached {get; set;}
		public Boolean isLanded {get; set;}
		public String flightDate {get; set;}
		public String flyingTime {get; set;}
		public String waitingTime {get; set;}
		public Id legId {get; set;}
	}

	public List<FlightSummaryView> viewList {get; set;}
	public String totalElapsedTime {get; set;}

	public FlightSummary (ApexPages.StandardController stdController) {
		Id flightId = Apexpages.currentpage().getparameters().get('id');
		String flightMaster = [SELECT Id, Flight_Master__c FROM Flight__c WHERE Id = :flightId LIMIT 1].Flight_Master__c;
		List<Flight__c> flightList = [SELECT Id, Flight_Date_LT__c, ETA_LT_DateTime__c, ATA_LT_DateTime__c, ATA_UTC_DateTime__c, ATD_UTC_DateTime__c, STD_UTC_DateTime__c, ATD_LT_DateTime__c, ETD_LT_DateTime__c, Routing__c, Departure_STN__c, Arrival_STN__c, STA_LT_DateTime__c, STD_LT_DateTime__c, STA_UTC_DateTime__c, ETA_UTC_DateTime__c, ETD_UTC_DateTime__c FROM Flight__c WHERE Flight_Master__c = :flightMaster AND Name != :BE8_GlobalConstants.DUMMY_FLIGHT_NAME ORDER By Leg_Number__c];
		Long totalTime = 0;
		viewList = new List<FlightSummaryView>();
		if (flightList != null && flightList.size() > 0 && flightList[0].Routing__c != null) {
			String[] routes = flightList[0].Routing__c.split('-');
			for (Integer i = 0; i < flightList.size(); i++) {
				Boolean isFirstLeg = i == 0;
				Boolean isLastLeg = i == flightList.size() - 1;
				Flight__c previousLeg = !isFirstLeg ? flightList[i - 1] : null;
				Boolean isThisLegDivertedFlight = !isFirstLeg && previousLeg.Departure_STN__c == previousLeg.Arrival_STN__c;

				//Boolean isLegInMiddle = !isFirstLeg && !isLastLeg;

				FlightSummaryView view = new FlightSummaryView();
				Flight__c leg = flightList[i];
				view.legId = leg.Id;
				view.currentStation = leg.Departure_STN__c;
				view.std = BE8_DateUtility.convertDateTimeToTimeString(leg.STD_LT_DateTime__c) + getOvernightIndicatorString(Date.valueOf(leg.Flight_Date_LT__c), leg.STD_LT_DateTime__c);
				view.etd = BE8_DateUtility.convertDateTimeToTimeString(leg.ETD_LT_DateTime__c) + getOvernightIndicatorString(Date.valueOf(leg.Flight_Date_LT__c), leg.ETD_LT_DateTime__c);
				view.atd = BE8_DateUtility.convertDateTimeToTimeString(leg.ATD_LT_DateTime__c) + getOvernightIndicatorString(Date.valueOf(leg.Flight_Date_LT__c), leg.ATD_LT_DateTime__c);
				view.flightDate = BE8_DateUtility.convertDateFormatToTraditionalFormat(leg.Flight_Date_LT__c);
				DateTime departureTime = getDepartureTime(leg);
				DateTime arrivalTime = getArrivalTime(leg);
				DateTime previousDepartureTime = previousLeg != null ? getDepartureTime(previousLeg) : null;
				DateTime previousArrivalTime = previousLeg != null ? getArrivalTime(previousLeg) : null;

				if (leg.ATA_UTC_DateTime__c != null) {
					Long flyingTimeInMinutes = getElapsedTimeInMinute(leg.ATD_UTC_DateTime__c, leg.ATA_UTC_DateTime__c);
					view.flyingTime = getElapsedTimeInHourMinuteString(flyingTimeInMinutes);
					totalTime += flyingTimeInMinutes;
				} else {
					Long flyingTimeInMinutes = getElapsedTimeInMinute(leg.STD_UTC_DateTime__c, leg.STA_UTC_DateTime__c);
					view.flyingTime = getElapsedTimeInHourMinuteString(flyingTimeInMinutes);
					totalTime += flyingTimeInMinutes;
				}


				if (isFirstLeg) {
					view.isReached = DateTime.now() > departureTime;
				} else {
					view.isReached = DateTime.now() > departureTime || DateTime.now() > previousArrivalTime;
					viewList[i - 1].isLanded = view.isReached;
				}

				if (!isFirstLeg) {
					view.sta = BE8_DateUtility.convertDateTimeToTimeString(previousLeg.STA_LT_DateTime__c) + getOvernightIndicatorString(Date.valueOf(previousLeg.Flight_Date_LT__c), previousLeg.STA_LT_DateTime__c);
					view.eta = BE8_DateUtility.convertDateTimeToTimeString(previousLeg.ETA_LT_DateTime__c) + getOvernightIndicatorString(Date.valueOf(previousLeg.Flight_Date_LT__c), previousLeg.ETA_LT_DateTime__c);
					view.ata = BE8_DateUtility.convertDateTimeToTimeString(previousLeg.ATA_LT_DateTime__c) + getOvernightIndicatorString(Date.valueOf(previousLeg.Flight_Date_LT__c), previousLeg.ATA_LT_DateTime__c);

					Long groundTime = 0;
					if (previousLeg.ATA_UTC_DateTime__c != null && leg.ATD_UTC_DateTime__c != null) {
						groundTime = getElapsedTimeInMinute(previousLeg.ATA_UTC_DateTime__c, leg.ATD_UTC_DateTime__c);
						view.waitingTime = getElapsedTimeInHourMinuteString(groundTime);
					} else {
						groundTime = getElapsedTimeInMinute(previousLeg.STA_UTC_DateTime__c, leg.STD_UTC_DateTime__c);
						view.waitingTime = getElapsedTimeInHourMinuteString(groundTime);
					}
					totalTime += groundTime;
				}

				if (isThisLegDivertedFlight) {
					view.std = '';
					view.etd = '';
					view.sta = '';
					view.eta = '';
				}

				viewList.add(view);


				if (isLastLeg) {
					FlightSummaryView lastView = new FlightSummaryView();
					Date sta = leg.STA_LT_DateTime__c.dateGMT();
					String staDate = String.valueOf(leg.STA_LT_DateTime__c.dateGMT());

					lastView.currentStation = leg.Arrival_STN__c;
					lastView.sta = BE8_DateUtility.convertDateTimeToTimeString(leg.STA_LT_DateTime__c) + getOvernightIndicatorString(sta, leg.STA_LT_DateTime__c);
					lastView.eta = BE8_DateUtility.convertDateTimeToTimeString(leg.ETA_LT_DateTime__c) + getOvernightIndicatorString(sta, leg.ETA_LT_DateTime__c);
					lastView.ata = BE8_DateUtility.convertDateTimeToTimeString(leg.ATA_LT_DateTime__c) + getOvernightIndicatorString(sta, leg.ATA_LT_DateTime__c);
					lastView.flightDate = BE8_DateUtility.convertDateFormatToTraditionalFormat(staDate);
					lastView.isReached = DateTime.now() > arrivalTime;
					view.isLanded = lastView.isReached;
					viewList.add(lastView);
				}
			}
			totalElapsedTime = getElapsedTimeInHourMinuteString(totalTime);
		}
	}

	private DateTime getDepartureTime(Flight__c leg) {
		DateTime departureTime = leg.STD_UTC_DateTime__c;
		if (leg.ATD_UTC_DateTime__c != null) {
			departureTime = leg.ATD_UTC_DateTime__c;
		} else if (leg.ETD_UTC_DateTime__c != null) {
			departureTime = leg.ETD_UTC_DateTime__c;
		}
		return departureTime;
	}

	private DateTime getArrivalTime(Flight__c leg) {
		DateTime arrivalTime = leg.STA_UTC_DateTime__c;
		if (leg.ATA_UTC_DateTime__c != null) {
			arrivalTime = leg.ATA_UTC_DateTime__c;
		} else if (leg.ETA_UTC_DateTime__c != null) {
			arrivalTime = leg.ETA_UTC_DateTime__c;
		}
		return arrivalTime;
	}


	private String getOvernightIndicatorString(Date flightDate, DateTime dt) {
		if (flightDate != null && dt != null && flightDate.daysBetween(dt.dateGmt()) > 0) {
			return '(+1)';
		} else {
			return '';
		}
	}

	public Long getElapsedTimeInMinute(DateTime dt1, DateTime dt2) {
		Long dt1Long = dt1.getTime();
		Long dt2Long = dt2.getTime();
		Long milliseconds = dt2Long - dt1Long;
		Long seconds = milliseconds / 1000;
		Long minutes = seconds / 60;
		//Long hours = minutes / 60;
		//Long days = hours / 24;
		return minutes;
	}

	private String getElapsedTimeInHourMinuteString(Long minutes) {
		Integer hour = Integer.valueOf(minutes / 60);
		Integer minute = Integer.valueOf(minutes - (hour * 60));
		return hour + 'h ' + minute + 'm';
	}
}