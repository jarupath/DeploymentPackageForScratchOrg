public with sharing class DCS_Pax_Model_Service {

	public static Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> getssrDetailMapBySSRCode(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>> returnMap = new Map<String, List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>>();
		List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> ssrlist = DCS_Pax_Model_Handler.paxSSRList(paxmodel);
		if(ssrlist != null){
			for(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr : ssrlist){
				if(returnMap.containsKey(ssr.ssrCode)) returnMap.get(ssr.ssrCode).add(ssr);
				else returnMap.put(ssr.ssrCode, new List<WS_DCS_Pax_Model.cls_specialRequirementsInfo>{ssr});
			}
		}
		if(returnmap != null && !returnmap.isEmpty()) return returnMap;
		return null;
	}

	public static Map<String, String> getCustomerStatusMapByCode(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		Map<String, String> returnmap = new Map<String, String>();
		List<WS_DCS_Pax_Model.cls_statusInfo> paxstatusinfolist = DCS_Pax_Model_Handler.paxCustomerStatusInfoList(paxmodel);
		if(paxstatusinfolist != null){
			for(WS_DCS_Pax_Model.cls_statusInfo statusinfo : paxstatusinfolist){
				returnmap.put(statusinfo.indicator, statusinfo.action);
			}
		}
		if(returnmap != null && !returnmap.isEmpty()) return returnmap;
		return null;
	}

	public static Boolean isINFTOccupyingSeat(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr){
		return (ssr.ssrCode == 'INFT' && ssr.serviceFreeText.contains('OCCUPYING SEAT'));
	}

	public static Boolean isINFTOccupyingSeat(List<WS_DCS_Pax_Model.cls_specialRequirementsInfo> ssrlist){
		if(ssrlist != null && !ssrlist.isEmpty()){
			for(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr : ssrlist){
				if(!isINFTOccupyingSeat(ssr)) return false;
			}
		}
		return true;
	}

	public static String getPaxNameFromModel(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		String firstname = DCS_Pax_Model_Handler.paxFirstname(paxmodel);
		String lastname = DCS_Pax_Model_Handler.paxLastname(paxmodel);
		String title = DCS_Pax_Model_Handler.paxTitle(paxmodel);

		return lastname + ' ' + firstname + ' ' + title;
	}

	public static Boolean isSSRRequest(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr){
		return ssr.serviceType == 'S';
	}

	public static String getSSRStatus(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr){
		return ssr.actionCode == BE8_GlobalConstants.SSR_CONFIRM ? BE8_GlobalConstants.SSR_GURANTEED : BE8_GlobalConstants.SSR_NOT_GURANTEED;
	}

	public static String getInfantDOB(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr){
		String returnstring = null;
		if(ssr != null && ssr.serviceFreeText != null){
			List<String> freetxtsplit = ssr.serviceFreeText.split(' ');
			if(freetxtsplit != null && !freetxtsplit.isEmpty() && freetxtsplit.size() > 1)
				returnstring = BE8_DateUtility.convertBirthDate(freetxtsplit.get(1));
		}
		return returnstring;
	}

	public static String getInfantName(WS_DCS_Pax_Model.cls_specialRequirementsInfo ssr){
		String returnstring = null;
		if(ssr != null && ssr.serviceFreeText != null){
			List<String> freetxtsplit = ssr.serviceFreeText.split(' ');
			if(freetxtsplit != null && !freetxtsplit.isEmpty()){
				returnstring = freetxtsplit.get(0);
				returnstring = returnstring.replaceAll('/', ' ');
			} 
		}
		return returnstring;
	}

	public static Boolean isInfant(WS_DCS_Pax_Model.cls_customerLevel paxmodel){
		Map<String, String> statusmap = getCustomerStatusMapByCode(paxmodel);
		if(statusmap != null && !statusmap.isEmpty() && statusmap.containsKey('IFT') && statusmap.get('IFT') == '1') return true;
		return false;
	}
}