public with sharing class PassengerSectorPage {

	public static final String ACCEPTED = 'Accepted';
	public static final String BOOKING = 'Booking';
	public static final String ALL = 'ALL';

	public List<String> sectorList {get; set;}
	public Map<String, SectorView> sectorViewMap {get; set;}
	public Map<String, Integer> aircraftConfigMap {get; set;}
	public Map<String, ClassView> totalClassMap {get; set;}
	public List<String> classList {get; set;}
	public List<String> totalClassList {get; set;}
	public static List<String> masterClassList = new List<String> {'F', 'C', 'U', 'Y'}; //first, business, premium economy, economy
	public Integer columnWidth {get; set;}
	public Flight__c flight {get; set;}

	public class ClassView {
		public String classCode {get; set;}
		public Integer totalBooking {get; set;}
		public Integer totalAccepted {get; set;}
		public Integer totalPassenger {get; set;}
		public Integer capacity {get; set;}
		public Decimal bookingPercentage {get; set;}
		public Decimal acceptedPercentage {get; set;}

		public ClassView(String classCode, Integer totalBooking, Integer totalAccepted, Integer capacity) {
			this.classCode = classCode;
			this.totalBooking = totalBooking;
			this.totalAccepted = totalAccepted;
			totalPassenger = totalAccepted + totalBooking;
			this.capacity = capacity;
			bookingPercentage = totalPassenger > 0 ? totalBooking / totalPassenger * 100 : 0;
			acceptedPercentage = totalPassenger > 0 ? totalAccepted / totalPassenger * 100 : 0;
			if (bookingPercentage == acceptedPercentage) {
				bookingPercentage = 50;
				acceptedPercentage = 50;
			} else if (acceptedPercentage == 0) {
				bookingPercentage = 70;
				acceptedPercentage = 30;
			} else if (bookingPercentage + acceptedPercentage < 100) {
				Decimal addUp = 100 - (bookingPercentage + acceptedPercentage);
				bookingPercentage += addUp;
				acceptedPercentage += addUp;
			} else if (bookingPercentage + acceptedPercentage > 100) {
				Decimal substract = (bookingPercentage + acceptedPercentage) - 100 ;
				bookingPercentage -= substract;
				acceptedPercentage -= substract;
			}
		}
	}

	public class SectorView {
		public Map<String, ClassView> classMap {get; set;}


		public SectorView(Map<String, Map<String, List<Passenger__c>>> inputMap, List<String> classList, Map<String, Integer> aircraftConfigMap) {
			classMap = new Map<String, ClassView>();

			Map<String, List<Passenger__c>> acceptedMap = inputMap.get(PassengerSectorPage.ACCEPTED);
			Map<String, List<Passenger__c>> bookingMap = inputMap.get(PassengerSectorPage.BOOKING);

			for (String key : classList) {
				List<Passenger__c> bookingPassengerList = bookingMap.get(key);
				List<Passenger__c> acceptedPassengerList = acceptedMap.get(key);
				Integer totalBooking = 0;
				Integer totalAccepted = 0;
				Integer capacity = aircraftConfigMap.get(key);

				if (bookingPassengerList != null) {
					totalBooking = bookingPassengerList.size();
				}

				if (acceptedPassengerList != null) {
					totalAccepted = acceptedPassengerList.size();
				}
				classMap.put(key, new ClassView(key, totalBooking, totalAccepted, capacity));
			}
		}
	}

	public PassengerSectorPage (ApexPages.StandardController stdController) {
		Id flightId = Apexpages.currentpage().getparameters().get('id');
		flight = [SELECT Id, Routing__c, Origin__c, Destination__c, Departure_STN__c, Arrival_STN__c, Aircraft_Configuration__c, Flight_Master__c FROM Flight__c WHERE Id = :flightId AND Name != :BE8_GlobalConstants.DUMMY_FLIGHT_NAME LIMIT 1];
		String flightMaster = flight.Flight_Master__c;
		String aircraftConfig = flight.Aircraft_Configuration__c;
		aircraftConfigMap = new Map<String, Integer>();

		if (aircraftConfig != null) {
			String[] aircraftConfigList = aircraftConfig.split(' ');
			for (String config : aircraftConfigList) {
				String code = config.left(1);
				Integer capacity = Integer.valueOf(config.substring(1));
				aircraftConfigMap.put(code, capacity);
			}
			classList = new List<String>(aircraftConfigMap.keySet());
			totalClassList = new List<String>(aircraftConfigMap.keySet());
			totalClassList.add(ALL);

			//List<Flight__c> flightList = [SELECT Id, Departure_STN__c, Arrival_STN__c FROM Flight__c WHERE Flight_Master__c = :flightMaster ORDER By Leg_Number__c];
			System.debug('flightMaster: ' + flightMaster);
			List<Passenger__c> passengerList = [SELECT Id, PNR__c, Name, Cabin_Code__c, Sector__c, Booking_Seat__c, Checkin_Seat__c FROM Passenger__c WHERE FlightId__r.Flight_Master__c = :flightMaster];
			System.debug('passengerList: ' + passengerList);
			if (passengerList != null && passengerList.size() > 0) {
				Map<String, Passenger__c> passengerMap = new Map<String, Passenger__c>();
				for (Passenger__c eachPax : passengerList) {
					passengerMap.put(eachPax.PNR__c + eachPax.Name, eachPax);
				}
				passengerList = passengerMap.values();

				Map<String, Map<String, Map<String, List<Passenger__c>>>> sectorMap = new Map<String, Map<String, Map<String, List<Passenger__c>>>>();
				for (Passenger__c eachPassenger : passengerList) {
					if (eachPassenger.Cabin_Code__c != null) {
						String sector = eachPassenger.Sector__c;
						if (sectorMap.get(sector) == null) {
							Map<String, Map<String, List<Passenger__c>>> acceptedOrBookingMap = new Map<String, Map<String, List<Passenger__c>>>();
							acceptedOrBookingMap.put(ACCEPTED, new Map<String, List<Passenger__c>>());
							acceptedOrBookingMap.put(BOOKING, new Map<String, List<Passenger__c>>());
							sectorMap.put(sector, acceptedOrBookingMap);
						}

						Map<String, Map<String, List<Passenger__c>>> acceptedOrBookingMap = sectorMap.get(sector);

						Boolean isAccepted = eachPassenger.Checkin_Seat__c != null;
						//String key = isAccepted ? ACCEPTED : BOOKING;
						Map<String, List<Passenger__c>> classMap = acceptedOrBookingMap.get(BOOKING);
						String cabinCode = eachPassenger.Cabin_Code__c;
						if (classMap.get(cabinCode) == null) {
							classMap.put(cabinCode, new List<Passenger__c>());
						}
						classMap.get(cabinCode).add(eachPassenger);

						if (eachPassenger.Checkin_Seat__c != null) {
							classMap = acceptedOrBookingMap.get(ACCEPTED);
							cabinCode = eachPassenger.Cabin_Code__c;
							if (classMap.get(cabinCode) == null) {
								classMap.put(cabinCode, new List<Passenger__c>());
							}

							classMap.get(cabinCode).add(eachPassenger);
						}
					}
				}

				totalClassMap = new Map<String, ClassView>();
				sectorViewMap = new Map<String, SectorView>();
				sectorList = new List<String>(sectorMap.keySet());
				Integer overallTotalBooking = 0;
				Integer overallTotalAccepted = 0;
				for (String sector : sectorList) {
					SectorView view = new SectorView(sectorMap.get(sector), classList, aircraftConfigMap);
					sectorViewMap.put(sector, view);

					Boolean isSectorFromOrigin = sector.contains(flight.Origin__c + '-');
					if (isSectorFromOrigin) {
						for (String classCode : masterClassList) {
							Integer totalBooking = 0;
							Integer totalAccepted = 0;

							if (totalClassMap.containsKey(classCode)) {
								totalBooking = totalClassMap.get(classCode).totalBooking;
								totalAccepted = totalClassMap.get(classCode).totalAccepted;
							}
							System.debug(classCode);
							System.debug(sector + ' totalBooking:' + totalBooking + ' totalAccepted: ' + totalAccepted);

							if (view.classMap.containsKey(classCode)) {
								totalBooking += view.classMap.get(classCode).totalBooking;
								totalAccepted += view.classMap.get(classCode).totalAccepted;
								overallTotalBooking += view.classMap.get(classCode).totalBooking;
								overallTotalAccepted += view.classMap.get(classCode).totalAccepted;
							}
							System.debug('view: ' + view);
							System.debug(sector + ' totalBooking:' + totalBooking + ' totalAccepted: ' + totalAccepted);
							totalClassMap.put(classCode, new ClassView(classCode, totalBooking, totalAccepted, aircraftConfigMap.get(classCode)));

							System.debug(sector + ' overallTotalBooking:' + overallTotalBooking + ' overallTotalAccepted: ' + overallTotalAccepted);
						}
					}
				}

				Integer totalCapacity = 0;
				for (String key : aircraftConfigMap.keySet()) {
					totalCapacity += aircraftConfigMap.get(key);
				}
				totalClassMap.put(ALL, new ClassView(ALL, overallTotalBooking, overallTotalAccepted, totalCapacity));

				sectorList = sortSectorList(sectorList, flight.Departure_STN__c, flight.Arrival_STN__c, flight.Routing__c);
				columnWidth = sectorList.size() > 0 ? 12 / sectorList.size() : 0;
			}
		}
	}

	private List<String> sortSectorList(List<String> sectorList, String departureStation, String arrivalStation, String routing) {
		Map<String, String> priorityMap = new Map<String, String>();
		if (routing != null) {
			List<String> splittedSectorList = routing.split('-');
			if (splittedSectorList.size() >= 2) {
				String firstSector = splittedSectorList[0];
				String secondSector = splittedSectorList[1];

				for (String sector : sectorList) {
					if (sector.indexOf(firstSector + '-' + secondSector) != -1) {
						priorityMap.put(sector, sector);
					}
				}

				for (String sector : sectorList) {
					if (sector.indexOf(firstSector) != -1) {
						priorityMap.put(sector, sector);
					}
				}

				for (String sector : sectorList) {
					priorityMap.put(sector, sector);
				}
			}
		}

		return new List<String>(priorityMap.values());
	}
}