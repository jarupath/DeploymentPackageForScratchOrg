public with sharing class EmergencyEmailController {
	private Case thisCase;

	public EmergencyEmailController(Case thisCase) {
		this.thisCase = thisCase;
	}

	private static String covertNullToEmptyString(String input) {
		if (input == null) {
			return '';
		} else {
			return input;
		}
	}

	public String getBody() {
		String body = '';
		String stdDate = thisCase.Flightid__r.STD_LT_DateTime__c != null ? BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(thisCase.Flightid__r.STD_LT_DateTime__c.dateGMT())) : '';
		String stdTime = thisCase.Flightid__r.STD_LT_DateTime__c != null ? BE8_DateUtility.convertDateTimeToTimeString(thisCase.Flightid__r.STD_LT_DateTime__c) : '';
		String staDate = thisCase.Flightid__r.STA_LT_DateTime__c != null ? BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(thisCase.Flightid__r.STA_LT_DateTime__c.dateGMT())) : '';
		String staTime = thisCase.Flightid__r.STA_LT_DateTime__c != null ? BE8_DateUtility.convertDateTimeToTimeString(thisCase.Flightid__r.STA_LT_DateTime__c) : '';

		String etdDate = thisCase.Flightid__r.ETD_LT_DateTime__c != null ? BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(thisCase.Flightid__r.ETD_LT_DateTime__c.dateGMT())) : '';
		String etdTime = thisCase.Flightid__r.ETD_LT_DateTime__c != null ? BE8_DateUtility.convertDateTimeToTimeString(thisCase.Flightid__r.ETD_LT_DateTime__c) : '';
		String etaDate = thisCase.Flightid__r.ETA_LT_DateTime__c != null ? BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(thisCase.Flightid__r.ETA_LT_DateTime__c.dateGMT())) : '';
		String etaTime = thisCase.Flightid__r.ETA_LT_DateTime__c != null ? BE8_DateUtility.convertDateTimeToTimeString(thisCase.Flightid__r.ETA_LT_DateTime__c) : '';
		String flightInformation = getFlightInformation(thisCase.Flightid__r.Name, thisCase.Flightid__r.Aircraftid__r.Name, stdDate, stdTime, etdDate, etdTime, staDate, staTime, etaDate, etaTime, thisCase.Flightid__r.Aircraft_Description__c, thisCase.Flightid__r.Origin__c, thisCase.Flightid__r.Destination__c);
		String reporterName = getReporterName(thisCase);

		if (thisCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_PASSENGER_DECEASE || thisCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY) {
			body = getHeader() +
			       flightInformation +
			       getPassengerInformation(thisCase.Passengerid__r.Name, thisCase.Passengerid__r.Checkin_Seat__c, thisCase.Passengerid__r.FFP_Number__c, thisCase.Passengerid__r.FFP_Tier__c, thisCase.Passengerid__r.Gender__c, thisCase.Passengerid__r.Nationality_Fullname__c) +
			       getPersonInvolved(thisCase, thisCase.Case_Group_Members__r) +
			       getDescription(thisCase.Emergency_Type__c, thisCase.Description, reporterName) +
			       getFooter();
		} else if (thisCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_CREW_DECEASE || thisCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_SEVERE_CREW_INJURY) {
			body = getHeader() +
			       flightInformation +
			       getCrewInformation(thisCase.CrewId__r.Name, thisCase.CrewId__r.Rank__c, thisCase.CrewId__r.Personel_Id__c) +
			       getPersonInvolved(thisCase, thisCase.Case_Group_Members__r) +
			       getDescription(thisCase.Emergency_Type__c, thisCase.Description, reporterName) +
			       getFooter();
		} else if (thisCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_SLIDER_DEPLOYMENT) {
			body = getHeader() +
			       flightInformation +
			       getPersonInvolved(thisCase, thisCase.Case_Group_Members__r) +
			       getDescription(thisCase.Emergency_Type__c, thisCase.Description, reporterName) +
			       getFooter();
		} else if (thisCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_SEVERE_TURBULENCE) {
			body = getHeader() +
			       flightInformation +
			       getDescription(thisCase.Emergency_Type__c, thisCase.Description, reporterName) +
			       getFooter();
		}
		return body;

	}

	private String getReporterName(Case thisCase){
		if(thisCase.Reported_By_Crew__c != null){
			return thisCase.Reported_By_Crew__r.Name;
		} else {
			return thisCase.Created_By_Crew__r.Name;
		}
	}

	private String getThaiLogoId() {
		List<Document> documentList = [SELECT Id FROM Document WHERE Name = :BE8_GlobalConstants.DOCUMENT_THAI_LOGO_EN];
		if (documentList != null && documentList.size() > 0) {
			return documentList.get(0).Id;
		} else {
			return '';
		}
	}

	private String getHeader() {
		return '<html> '
		       + ' '
		       + '<body> '
		       + '    <center> '
		       + '        <table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450"> '
		       + '            <tbody> '
		       + '                <tr valign="top"> '
		       + '                    <td style=" background-color:#FFFFFF; bEditID:r1st1; bLabel:header; vertical-align:top; height:100; text-align:left;"> '
		       + '                        <img border="0" beditid="r1sp1" blabel="headerImage" id="r1sp1" src="https://c.cs6.content.force.com/servlet/servlet.ImageServer?id=' + getThaiLogoId() + '&oid=' + UserInfo.getOrganizationId() + '" /> '
		       + '                    </td> '
		       + '                </tr> '
		       + '                <tr valign="top"> '
		       + '                    <td style=" background-color:#663366; bEditID:r2st1; bLabel:accent1; height:5;"></td> '
		       + '                </tr> '
		       + '                <tr valign="top"> '
		       + '                    <td styleinsert="1" height="300" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;"> '
		       + '                        <table border="0" cellpadding="5" width="550" cellspacing="5" height="400"> '
		       + '                            <tbody> ';
	}

	private String getFooter() {
		return '                                    </td> '
		       + '                                </tr> '
		       + '                            </tbody> '
		       + '                        </table> '
		       + '                    </td> '
		       + '                </tr> '
		       + '                <tr valign="top"> '
		       + '                    <td style=" background-color:#663366; bEditID:r4st1; bLabel:accent2; height:5;"></td> '
		       + '                </tr> '
		       + '                <tr valign="top"> '
		       + '                    <td style=" background-color:#FFFFFF; bEditID:r5st1; bLabel:footer; vertical-align:top; height:100; text-align:left;"> '
		       + '                    </td> '
		       + '                </tr> '
		       + '                <tr valign="top"> '
		       + '                    <td style=" background-color:#AAAAFF; bEditID:r6st1; bLabel:accent3; height:0;"></td> '
		       + '                </tr> '
		       + '            </tbody> '
		       + '        </table> '
		       + '    </center> '
		       + '</body> '
		       + ' '
		       + '</html> '
		       + ' ';
	}

	public String getFlightInformation(String flightNumber, String aircraftRegistration, String stdDate, String stdTime, String etdDate, String etdTime, String staDate, String staTime, String etaDate, String etaTime, String aircraftNumber, String origin, String destination) {
		return '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font style="font-size: 12pt;"><b>Flight Information</b></font> '
		       + '                                            <div style="font-size: 12pt;"> '
		       + '                                                <font color="#663366"><b>--------------------------------------------------</b></font> '
		       + '                                            </div> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>FLT No.: <b><i>' + covertNullToEmptyString(flightNumber) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>A/C Reg: <b><i>' + covertNullToEmptyString(aircraftRegistration) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>STD: <b><i>' + covertNullToEmptyString(stdDate) + ' ' + covertNullToEmptyString(stdTime) + '</i></b> ETD: <b><i>' + covertNullToEmptyString(etdDate) + ' ' + covertNullToEmptyString(etdTime) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>STA: <b><i>' + covertNullToEmptyString(staDate) + ' ' + covertNullToEmptyString(staTime) + '</i></b> ETA: <b><i>' + covertNullToEmptyString(etaDate) + ' ' + covertNullToEmptyString(etaTime) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>A/C: <b><i>' + covertNullToEmptyString(aircraftNumber) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>Origin: <b><i>' + covertNullToEmptyString(origin) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font>Destination: <b><i>' + covertNullToEmptyString(destination) + '</i></b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font><b><i><br/></i></b></font> '
		       + '                                        </div> ';
	}

	public String getDescription(String emergencyType, String description, String reporterName) {
		return '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <b>Description</b> '
		       + '                                        </div> '
		       + '                                        <div> '
		       + '                                            <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                                <font color="#663366"> '
		       + '                                                    <b>--------------------------------------------------</b> '
		       + '                                                </font> '
		       + '                                            </div> '
		       + '                                            <div> '
		       + '                                                <font style="font-family: arial; font-size: 12pt;"> '
		       + '                                                    Emergency Type:&nbsp; '
		       + '                                                </font> '
		       + '                                                <font face="arial"> '
		       + '                                                    <b><i>' + covertNullToEmptyString(emergencyType) + '</i></b> '
		       + '                                                </font> '
		       + '                                            </div> '
		       + '                                            <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                                <font face="arial"> '
		       + '                                                    <div style="color: rgb(0, 0, 0);"> '
		       + '                                                        ' + covertNullToEmptyString(description) + ' '
		       + '                                                    </div> '
		       + '                                                    <div style="color: rgb(0, 0, 0);"> '
		       + '                                                        <br/> '
		       + '                                                    </div> '
		       + '                                                    <div style="color: rgb(0, 0, 0);"> '
		       + '                                                        <div style="font-size: 12pt;"><b>Report By</b></div> '
		       + '                                                        <div> '
		       + '                                                            <div style="font-size: 12pt;"> '
		       + '                                                                <font color="#663366"> '
		       + '                                                                    <b>--------------------------------------------------</b> '
		       + '                                                                </font> '
		       + '                                                            </div> '
		       + '                                                        </div> '
		       + '                                                    </div> '
		       + '                                                    <div style="font-size: 12pt;"> '
		       + '                                                        <font>AP / IM: <b><i>' + covertNullToEmptyString(reporterName) + '</i></b></font> '
		       + '                                                    </div> '
		       + '                                                    <br/> '
		       + '                                                </font> '
		       + '                                            </div> '
		       + '                                        </div> ';
	}

	private String getPassengerInformation(String passengerName, String seat, String ropNumber, String ropTier, String gender, String nationality) {
		return '<font color="#663366" style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"><b>Passenger Information</b></font> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font color="#663366"><b>--------------------------------------------------</b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font face="arial"> '
		       + '                                                <div> '
		       + '                                                    Name: <b><i>' + covertNullToEmptyString(passengerName) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    Seat: <b><i>' + covertNullToEmptyString(seat) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    ROP No.: <b><i>' + covertNullToEmptyString(ropNumber) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    ROP Tier: <b><i>' + covertNullToEmptyString(ropTier) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    Gender: <b><i>' + covertNullToEmptyString(gender) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    Nationality: <b><i>' + covertNullToEmptyString(nationality) + '</i></b> '
		       + '                                                </div> '
		       + '                                            </font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font color="#663366"><b><br/></b></font> '
		       + '                                        </div> ';
	}

	private String getCrewInformation(String crewName, String rank, String personelId) {
		return '<font color="#663366" style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"><b>Crew Information</b></font> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font color="#663366"><b>--------------------------------------------------</b></font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font face="arial"> '
		       + '                                                <div> '
		       + '                                                    Name: <b><i>' + covertNullToEmptyString(crewName) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    Rank: <b><i>' + covertNullToEmptyString(rank) + '</i></b> '
		       + '                                                </div> '
		       + '                                                <div> '
		       + '                                                    Personel Id: <b><i>' + covertNullToEmptyString(personelId) + '</i></b> '
		       + '                                                </div> '
		       + '                                            </font> '
		       + '                                        </div> '
		       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '                                            <font color="#663366"><b><br/></b></font> '
		       + '                                        </div> '
		       + '                                        <br/> ';
	}

	private String getPassengerInvolved(String passengerName, String checkInSeat, String role, String detail) {
		return '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + 'Name : <b><i>' + covertNullToEmptyString(passengerName) + '</i></b> '
		       + '</div> '
		       + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + 'Seat : <i><b>' + covertNullToEmptyString(checkInSeat) + '</b></i> '
		       + '</div> '
		       + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + 'Role : <i><b>' + covertNullToEmptyString(role) + '</b></i> '
		       + '</div> '
		       + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + 'Detail : <i><b>' + covertNullToEmptyString(detail) + '</b></i> '
		       + '</div> '
		       + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + '<br/> '
		       + '</div> ';
	}

	private String getCrewPersonInvolved(String crewName, String rank, String personelId, String role, String detail) {
		return  '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Name : <b><i>' + covertNullToEmptyString(crewName) + '</i></b> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Rank : <i><b>' + covertNullToEmptyString(rank) + '</b></i> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Personel Id : <i><b>' + covertNullToEmptyString(personelId) + '</b></i> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Role : <i><b>' + covertNullToEmptyString(role) + '</b></i> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + 'Detail : <i><b>' + covertNullToEmptyString(detail) + '</b></i> '
		       + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + '<br/> '
		        + '</div> ';
	}

	private String getStaffPersonInvolved(String staffName, String personalNumber, String role, String detail) {
		return  '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Name : <b><i>' + covertNullToEmptyString(staffName) + '</i></b> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Personal Number : <i><b>' + covertNullToEmptyString(personalNumber) + '</b></i> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + 'Role : <i><b>' + covertNullToEmptyString(role) + '</b></i> '
		        + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		       + 'Detail : <i><b>' + covertNullToEmptyString(detail) + '</b></i> '
		       + '</div> '
		        + '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
		        + '<br/> '
		        + '</div> ';
	}

	private String getPersonInvolved(Case currentCase, List<Case_Group_Member__c> caseGroupMemberList) {
		String allPersonInvolved = '';
		for (Case_Group_Member__c eachMember : caseGroupMemberList) {
			Boolean isPassengerEmergencyCase = currentCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_PASSENGER_DECEASE || currentCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY;
			Boolean isCrewEmergencyCase = currentCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_CREW_DECEASE || currentCase.Emergency_Type__c == BE8_GlobalConstants.EMERGENCY_TYPE_SEVERE_CREW_INJURY;
			if (!(isPassengerEmergencyCase && eachMember.PassengerId__c == currentCase.PassengerId__c) && eachMember.Passengerid__c != null) {
				allPersonInvolved += getPassengerInvolved(eachMember.Passengerid__r.Name, eachMember.Passengerid__r.Checkin_Seat__c, eachMember.Role__c, eachMember.Detail__c);
			} else if (!(isCrewEmergencyCase && eachMember.CrewId__c == currentCase.CrewId__c) && eachMember.CrewId__c != null) {
				allPersonInvolved += getCrewPersonInvolved(eachMember.CrewId__r.Name, eachMember.CrewId__r.Rank__c, eachMember.CrewId__r.Personel_Id__c, eachMember.Role__c, eachMember.Detail__c);
			} else if (eachMember.Staff_Name__c != null || eachMember.Staff_Personal_Number__c != null) {
				allPersonInvolved += getStaffPersonInvolved(eachMember.Staff_Name__c, eachMember.Staff_Personal_Number__c, eachMember.Role__c, eachMember.Detail__c);
			}
		}
		if (allPersonInvolved.length() > 0) {
			return '<div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
			       + '                                            <b>Person Involved</b> '
			       + '                                        </div> '
			       + '                                        <div style="font-family: arial; font-size: 12pt; color: rgb(0, 0, 0);"> '
			       + '                                            <div> '
			       + '                                                <font color="#663366"> '
			       + '                                                    <b>--------------------------------------------------</b> '
			       + '                                                </font> '
			       + '                                            </div> '
			       + allPersonInvolved
			       + '                                        </div> '
			       + '                                        <br/> ';
		} else {
			return '';
		}
	}
}