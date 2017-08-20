public with sharing class MembershipService {
	public static Map<String, String> subTierToHardTierMap;
	
	public static List<Membership__c> convertSubTierToActualTier(List<Membership__c> membershipList){
		for(Membership__c eachMem : membershipList){
			if(eachMem.Airline__c == BE8_GlobalConstants.DEFAULT_TG_COMPANY){
				eachMem.Tier_WS__c = eachMem.Tier__c;
				eachMem.Tier__c = getHardTierFromSubTierString(eachMem.Tier__c);
			}
		}
		return membershipList;
	}

	public static void initializeSubTierToHardTierMap(){
		if(subTierToHardTierMap == null){
			List<ROP_Tier__mdt> ropTierList = [SELECT DeveloperName, Sub_Tier__c, Hard_Tier__c FROM ROP_Tier__mdt];
			subTierToHardTierMap = new Map<String, String>();
			for(ROP_Tier__mdt eachRopTier : ropTierList){
				subTierToHardTierMap.put(eachRopTier.Sub_Tier__c, eachRopTier.Hard_Tier__c);
			}
		}
	}

	public static String getHardTierFromSubTierString(String subTier){
		initializeSubTierToHardTierMap();
		String hardTier = subTierToHardTierMap.get(subTier);
		return hardTier != null ? hardTier : subTier;
	}
}