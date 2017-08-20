public with sharing class InFlightLOPAStatusHandler implements LOPAStatusHandler {

	public String getLOPAPositionStatus(String position, String positionType, Passenger__c matchedPassenger, List<Case_Group_Member__c> matchedCaseList, MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos) {
		Boolean isPassengerSeat = positionType == BE8_GlobalConstants.TYPE_SEAT;
		Boolean isPassengerSeatOccupied = isPassengerSeat && (matchedPassenger != null);
		Boolean isROP = isPassengerSeatOccupied && (matchedPassenger.FFP_Carrier__c == BE8_GlobalConstants.DEFAULT_TG_COMPANY);

		Boolean hasCase = matchedCaseList != null;
		Boolean isServiceable = !hasCase || matchedCaseList.size() == 0;

		Boolean isOccupied = isPassengerSeatOccupied;
		Boolean isBlock = false;
		Boolean isMalfunction = false;
		Boolean isGold = false;
		Boolean isPlatinum = false;

		Boolean isBlockedFromLOPA = lopaPos.sOcp != null && BE8_GlobalConstants.SEAT_OCCUPATION_BLOCKED_SEAT.contains(lopaPos.sOcp);

		String status = '';
		if (isPassengerSeat) {
			if (!isServiceable) {
				for (Case_Group_Member__c eachMember : matchedCaseList) {
					if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_BLOCK) {
						isBlock = true;
						break;
					}
					if (eachMember.Impact__c == BE8_GlobalConstants.IMPACT_MALFUNCTION) {
						isMalfunction = true;
						break;
					}
				}
			}
		}

		if (isROP && matchedPassenger.Match_with_ROP__c) {
			isGold = matchedPassenger.FFP_Tier__c != null && matchedPassenger.FFP_Tier__c == BE8_GlobalConstants.FFP_TIER_GOLD;
			isPlatinum = matchedPassenger.FFP_Tier__c != null && matchedPassenger.FFP_Tier__c == BE8_GlobalConstants.FFP_TIER_PLATINUM;
		}


		if (isBlockedFromLOPA && !isOccupied) {
			return BE8_GlobalConstants.LOPA_STATUS_BLOCKED_FROM_LOPA;
		}
		if (isMalfunction && isGold) {
			return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_GOLD;
		}
		if (isMalfunction && isPlatinum) {
			return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_PLATINUM;
		}
		if (isBlock && isGold) {
			return BE8_GlobalConstants.LOPA_STATUS_BLOCK_GOLD;
		}
		if (isBlock && isPlatinum) {
			return BE8_GlobalConstants.LOPA_STATUS_BLOCK_PLATINUM;
		}
		if (isOccupied && isGold) {
			return BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_GOLD;
		}
		if (isOccupied && isPlatinum) {
			return BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_PLATINUM;
		}
		if (isMalfunction && isOccupied) {
			return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_OCCUPIED;
		}
		if (isBlock && isOccupied) {
			return BE8_GlobalConstants.LOPA_STATUS_BLOCK_OCCUPIED;
		}
		if (isMalfunction) {
			return BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION;
		}
		if (isBlock) {
			return BE8_GlobalConstants.LOPA_STATUS_BLOCK;
		}
		if (isOccupied) {
			return BE8_GlobalConstants.LOPA_STATUS_OCCUPIED;
		} else {
			return BE8_GlobalConstants.LOPA_STATUS_AVAILABLE;
		}
	}
}