public with sharing class MaintenanceLOPAStatusHandler implements LOPAStatusHandler {
	
	public String getLOPAPositionStatus(String position, String positionType, Passenger__c matchedPassenger, List<Case_Group_Member__c> matchedCaseList, MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos) {
		Boolean isPassengerSeat = positionType == BE8_GlobalConstants.TYPE_SEAT;
		Boolean isPassengerSeatOccupied = isPassengerSeat && (matchedPassenger != null);
		Boolean isROP = isPassengerSeatOccupied && (matchedPassenger.FFP_Carrier__c == BE8_GlobalConstants.DEFAULT_TG_COMPANY);

		Boolean hasCase = matchedCaseList != null;
		Boolean needRepair = !(!hasCase || matchedCaseList.size() == 0);

		Boolean isOccupied = isPassengerSeatOccupied;
		Boolean isBlock = false;
		Boolean isMalfunction = false;
		Boolean isGold = false;
		Boolean isPlatinum = false;
		Boolean isNoAction = false;
		Boolean isServiceable = false;

		Boolean isBlockedFromLOPA = lopaPos.sOcp != null && BE8_GlobalConstants.SEAT_OCCUPATION_BLOCKED_SEAT.contains(lopaPos.sOcp);

		String status = '';
		if (isPassengerSeat) {
			if (needRepair) {
				for (Case_Group_Member__c eachMember : matchedCaseList) {
					if (eachMember.Impact__c == null) {
						isNoAction = true;
						break;
					}
					if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_BLOCK) {
						isBlock = true;
						break;
					}
					if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_MALFUNCTION) {
						isMalfunction = true;
						break;
					}
					if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_SERVICABLE) {
						isServiceable = true;
						break;
					}
				}
			}
		}

		if (isROP) {
			isGold = matchedPassenger.FFP_Tier__c != null && matchedPassenger.FFP_Tier__c == BE8_GlobalConstants.FFP_TIER_GOLD;
			isPlatinum = matchedPassenger.FFP_Tier__c != null && matchedPassenger.FFP_Tier__c == BE8_GlobalConstants.FFP_TIER_PLATINUM;
		}


		if (isNoAction) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_NO_ACTION;
		}
		if (isBlockedFromLOPA && !isOccupied) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCKED_FROM_LOPA;
		}
		if (isMalfunction && isOccupied) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION_OCCUPIED;
		}
		if (isBlock && isOccupied) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK_OCCUPIED;
		}
		if (isMalfunction) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION;
		}
		if (isBlock) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK;
		}
		if (isServiceable) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_SERVICEABLE;
		}
		if (isOccupied) {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_OCCUPIED;
		} else {
			return BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_AVAILABLE;
		}
	}
}