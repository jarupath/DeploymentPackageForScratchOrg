global with sharing class PassengerListController {
	global class PassengerView {
		public String id;
		public String firstName;
		public String lastName;
		public String name;
		public String pnr;
		public String sector;
		public String ffpNumber;
		public String ffpTier;
		public Boolean isVIP;
		public Boolean isCIP;
		public Boolean noShow;
		public String seatNumber;
		public String travelClass;
		public Boolean isBirthdayToday;
		public String ssr;
		public String specialMeal;
		public String passengerStatus;
		public Boolean hasInfant;
	}

	public Id flightId {get; set;}

	public PassengerListController(ApexPages.StandardController controller) {
		flightId = controller.getRecord().Id;
	}

	@RemoteAction
	global static List<PassengerView> getPassengerList(Id flightId) {
		List<PassengerView> resultList = new List<PassengerView>();
		if (flightId != null) {
			for (Passenger__c eachPassenger : [SELECT Id, No_Show__c, Name, Date_of_Birth_Display__c, First_Name__c, Last_Name__c, Sector__c, PNR__c, FFP__c, FFP_Carrier__c, FFP_Number__c, FFP_Tier__c, VIP_VVIP_Flag__c, Checkin_Seat__c, Cabin_Code_F__c, SSR__c, SSR_Service__c, Special_Meal__c, Infant__c FROM Passenger__c WHERE FlightId__c = :flightId]) {
				PassengerView view = new PassengerView();
				view.id = eachPassenger.Id;
				view.firstName = eachPassenger.First_Name__c;
				view.lastName = eachPassenger.Last_Name__c;
				view.name = eachPassenger.Name;
				view.pnr = eachPassenger.PNR__c;
				view.sector = eachPassenger.Sector__c;
				view.ffpNumber = eachPassenger.FFP__c;
				view.ffpTier = eachPassenger.FFP_Tier__c;
				view.seatNumber = eachPassenger.Checkin_Seat__c;
				view.travelClass = eachPassenger.Cabin_Code_F__c;
				view.isBirthdayToday = isBirthdayToday(eachPassenger.Date_of_Birth_Display__c);
				view.noShow = eachPassenger.No_Show__c;
				view.hasInfant = eachPassenger.Infant__c;

				view.isVIP = eachPassenger.VIP_VVIP_Flag__c;
				view.passengerStatus = view.isVIP ? 'VIP' : '';
				if (eachPassenger.SSR_Service__c != null && eachPassenger.SSR_Service__c.contains(BE8_GlobalConstants.SSR_CODE_MAAS) && eachPassenger.SSR_Service__c.contains(BE8_GlobalConstants.SSR_CODE_CIP)) {
					view.isCIP = true;
					view.passengerStatus += 'CIP';
				}

				view.ssr = '';
				if (view.hasInfant) {
					view.ssr += ' INFT';
				}
				if (eachPassenger.SSR_Service__c != null) {
					view.ssr += ' ' + eachPassenger.SSR_Service__c;
				}
				if(view.ssr.length() > 0){
					view.ssr = 'SSR:' + view.ssr;
				}

				if (eachPassenger.Special_Meal__c != null) {
					if (view.ssr != null) {
						view.ssr += ' | MEAL: ' + eachPassenger.Special_Meal__c;
					} else {
						view.ssr = 'MEAL:' + eachPassenger.Special_Meal__c;
					}
					view.specialMeal = eachPassenger.Special_Meal__c;
				}

				resultList.add(view);
			}
		}
		return resultList;
	}

	private static Boolean isBirthdayToday(Date birthday) {
		if (birthday != null) {
			Decimal birthdayDay = birthday.day();
			Decimal birthdayMonth = birthday.month();

			Date today = Date.today();
			Decimal todayDay = today.day();
			Decimal todayMonth = today.month();
			return birthdayDay == todayDay && birthdayMonth == todayMonth;
		} else {
			return false;
		}
	}
}