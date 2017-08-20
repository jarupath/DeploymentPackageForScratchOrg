@RestResource(urlMapping = '/masterdata/inflight/*')
global class MB_RESTMasterDataInFlightService {

	global class PickList {
		public String label;
		public String value;

		public PickList(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}

	global class UpgradeSeatCriteria {
		public String code;
		public String fromClass;
		public String toClass;
		public String amount;
		public String mile;
		public String fltId;
	}

	global class CompensationCriteria {
		public String problem;
		public String type;
		public String subType;
		public String[] classList;
		public Decimal amount;
		public String curr;
		public String region;
	}

	global class CrewAppraisalFormCriteria {
		public String evaluator;
		public String evaluated;
		public String[] formNums;
	}

	global class MasterData {
		public List<PickList> nation;
		public String condi;
		public String accept;
		public String sbUpgradeCondi;
		public String cUpgradeCondi;
		public List<Map<String, String>> crewAppraisal;
		public List<CrewAppraisalFormCriteria> crewAppraisalFormCriteria;
		public List<UpgradeSeatCriteria> upgrade;
		public List<CompensationCriteria> compen;
		public List<CurrencyUnit> currenc;
		public List<String> paymentType;
		public List<TextData> ropMileCondi;
		public List<TextData> mpdCondi;
		public List<TextData> upgradeSeatCondi;
	}

	global class CurrencyUnit {
		public String currencyName;
		public String subCurrency;
	}

	global class TextData {
		public String name;
		public String content;
	}

	@HttpGet
	global static MasterData getMasterData() {
		Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(UserInfo.getUserId());
		List<Flight__c> flightList = [SELECT Id, Origin__c, Destination__c, Flight_Region__c, Departure_STN__c, Arrival_STN__c FROM Flight__c WHERE Id IN : flightIdSet];

		MasterData result = new MasterData();
		List<Nationality_Master__mdt> nationalityMasterList = [SELECT Id, MasterLabel, Nationality_Full_Name__c, Continent__c FROM Nationality_Master__mdt WHERE (NOT MasterLabel LIKE '___')];
		result.nation = new List<PickList>();
		for (Nationality_Master__mdt each : nationalityMasterList) {
			result.nation.add(new PickList(each.Nationality_Full_Name__c, each.MasterLabel));
		}

		Document ropConditions = [SELECT Id, Body FROM Document WHERE Name = 'ROP Conditions' LIMIT 1];
		result.condi = ropConditions.Body.toString();
		Document ropAccept = [SELECT Id, Body FROM Document WHERE Name = 'ROP Accept' LIMIT 1];
		result.accept = ropAccept.Body.toString();
		Document standByUpgradeCertificateCondition = [SELECT Id, Body FROM Document WHERE Name = 'StandByUpgradeCertificateCondition' LIMIT 1];
		result.sbUpgradeCondi = standByUpgradeCertificateCondition.Body.toString();
		Document confirmedUpgradeCertificateCondition = [SELECT Id, Body FROM Document WHERE Name = 'ConfirmedUpgradeCertificateCondition' LIMIT 1];
		result.cUpgradeCondi = confirmedUpgradeCertificateCondition.Body.toString();

		List<Map<String, String>> crewAppraisalDatas = new List<Map<String, String>>();
		List<MD_Appraisal_Item__c> mdItems = [SELECT Id, MD_Appraisal_Item_External_ID__c, Form_Number__c, Form_Description__c, MD_Appraisal_Subject__r.Name, MD_Appraisal_Subject__r.Description__c, MD_Appraisal_Subject__r.Type__c, Version__c, Name, Condition__c, Description__c, Type__c , Default_Value__c FROM MD_Appraisal_Item__c ORDER BY MD_Appraisal_Item_External_ID__c ASC];

		for (MD_Appraisal_Item__c eachMDItem : mdItems) {
			Map<String, String> dataEachItem = new Map<String, String>();
			dataEachItem.put('id', eachMDItem.MD_Appraisal_Item_External_ID__c);
			dataEachItem.put('sfdcId', eachMDItem.Id);
			dataEachItem.put('version', eachMDItem.Version__c);
			dataEachItem.put('formNum', eachMDItem.Form_Number__c);
			dataEachItem.put('formDesc', eachMDItem.Form_Description__c);
			dataEachItem.put('subjType', String.isBlank(eachMDItem.MD_Appraisal_Subject__r.Type__c) ? '' : eachMDItem.MD_Appraisal_Subject__r.Type__c);
			dataEachItem.put('subjNum', eachMDItem.MD_Appraisal_Subject__r.Name);
			dataEachItem.put('subjDesc', eachMDItem.MD_Appraisal_Subject__r.Description__c);
			dataEachItem.put('itemNum', eachMDItem.Name);
			dataEachItem.put('condi', eachMDItem.Condition__c);
			dataEachItem.put('itemDesc', eachMDItem.Description__c);
			dataEachItem.put('type', eachMDItem.Type__c);
			dataEachItem.put('defaultValue', eachMDItem.Default_Value__c);
			crewAppraisalDatas.add(dataEachItem);
		}

		List<CrewAppraisalFormCriteria> crewAppraisalFormCriterias = new List<CrewAppraisalFormCriteria>();
		List<Crew_Appraisal_Form_Criteria__mdt> criterias = [SELECT Id, Evaluator_Rank__c, Evaluated_Rank__c, Form_Numbers__c FROM Crew_Appraisal_Form_Criteria__mdt];
		for (Crew_Appraisal_Form_Criteria__mdt criteria : criterias) {
			CrewAppraisalFormCriteria eachCriteriaData = new CrewAppraisalFormCriteria();
			eachCriteriaData.evaluator = criteria.Evaluator_Rank__c;
			eachCriteriaData.evaluated = criteria.Evaluated_Rank__c;
			eachCriteriaData.formNums = criteria.Form_Numbers__c.split(',');
			crewAppraisalFormCriterias.add(eachCriteriaData);
		}

		result.crewAppraisalFormCriteria = crewAppraisalFormCriterias;
		result.crewAppraisal = crewAppraisalDatas;
		result.upgrade = getUpgradeSeatCriteriaMasterData(flightList);
		result.compen = getCompensationCriteria();
		result.currenc = getCurrencyMasterData();

		result.paymentType = new List<String>();
		for (Schema.PicklistEntry each : Case.Payment_Type__c.getDescribe().getPicklistValues()) {
			result.paymentType.add(each.getValue());
		}

		result.ropMileCondi = getTextDataListFromDocumentsInFolder('ROP_Mileages_Conditions');
		result.mpdCondi = getTextDataListFromDocumentsInFolder('MPD_Conditions');
		result.upgradeSeatCondi = getTextDataListFromDocumentsInFolder('Upgrade_Seat_Conditions');

		return result;
	}

	private static List<UpgradeSeatCriteria> getUpgradeSeatCriteriaMasterData(List<Flight__c> flightList) {
		Set<String> originAndDestinationSet = new Set<String>();
		for (Flight__c flight : flightList) {
			originAndDestinationSet.add(flight.Departure_STN__c);
			originAndDestinationSet.add(flight.Arrival_STN__c);
		}
		List<In_flight_Upgrade_Seat_Master__mdt> allMasterDataList = [SELECT DeveloperName, Origin__c, Destination__c, Upgrade_From_Class__c, Upgrade_To_Class__c, Amount__c, ROP_Award_Code__r.Mileages__c FROM In_flight_Upgrade_Seat_Master__mdt WHERE (Origin__c IN :originAndDestinationSet AND Destination__c IN :originAndDestinationSet)];
		//System.debug('allMasterDataList: ' + allMasterDataList);
		Map<String, List<SObject>> masterDataMapByOriginAndDestination = BE8_GlobalUtility.getSObjectListMap(new Set<String> {'Origin__c', 'Destination__c'}, allMasterDataList);
		//System.debug('masterDataMapByOriginAndDestination: ' + masterDataMapByOriginAndDestination);
		List<UpgradeSeatCriteria> upgradeList = new List<UpgradeSeatCriteria>();
		for (Flight__c flight : flightList) {
			String key = flight.Departure_STN__c + flight.Arrival_STN__c;
			if(!masterDataMapByOriginAndDestination.containsKey(key)){
				key = flight.Arrival_STN__c + flight.Departure_STN__c;
			}
			if (masterDataMapByOriginAndDestination.containsKey(key)) {
				List<In_flight_Upgrade_Seat_Master__mdt> masterDataList = (List<In_flight_Upgrade_Seat_Master__mdt>) masterDataMapByOriginAndDestination.get(key);
				for (In_flight_Upgrade_Seat_Master__mdt masterData : masterDataList) {
					UpgradeSeatCriteria upgrade = new UpgradeSeatCriteria();
					upgrade.code = masterData.DeveloperName;
					upgrade.fromClass = masterData.Upgrade_From_Class__c;
					upgrade.toClass = masterData.Upgrade_To_Class__c;
					upgrade.amount = '' + masterData.Amount__c;
					upgrade.mile = '' + masterData.ROP_Award_Code__r.Mileages__c;
					String originAndDestinationKey = masterData.Origin__c + masterData.Destination__c;
					upgrade.fltId = flight.Id;
					upgradeList.add(upgrade);
				}
			}
		}
		return upgradeList;
	}

	private static List<CompensationCriteria> getCompensationCriteria() {
		List<CompensationCriteria> compensationCriteriaList = new List<CompensationCriteria>();
		List<In_flight_Compensation_Master__mdt> allMasterDataList = [SELECT Id, Amount__c, Class__c, Currency__c, Flight_Region__c, Problem__c, Sub_Type__c, Type__c FROM In_flight_Compensation_Master__mdt];
		for (In_flight_Compensation_Master__mdt masterData : allMasterDataList) {
			CompensationCriteria compensationCriteria = new CompensationCriteria();
			compensationCriteria.problem = masterData.Problem__c;
			compensationCriteria.type = masterData.Type__c;
			compensationCriteria.subType = masterData.Sub_Type__c;
			compensationCriteria.classList = masterData.Class__c.split(',');
			compensationCriteria.amount = masterData.Amount__c;
			compensationCriteria.curr = masterData.Currency__c;
			compensationCriteria.region = masterData.Flight_Region__c;
			compensationCriteriaList.add(compensationCriteria);
		}
		return compensationCriteriaList;
	}

	private static List<CurrencyUnit> getCurrencyMasterData() {
		List<Currency_Unit__mdt> currencyMasterDataList = [SELECT Id, DeveloperName, Currency__c, Sub_Currency__c FROM Currency_Unit__mdt];
		List<CurrencyUnit> currencyModelList = new List<CurrencyUnit>();
		for (Currency_Unit__mdt eachCurrency : currencyMasterDataList) {
			CurrencyUnit currencyModel = new CurrencyUnit();
			currencyModel.currencyName = eachCurrency.DeveloperName;
			currencyModel.subCurrency = eachCurrency.Sub_Currency__c;
			currencyModelList.add(currencyModel);
		}
		return currencyModelList;
	}

	private static List<String> getROPMileagesConditionList() {
		List<String> result = new List<String>();
		for (Document eachDoc : [SELECT Id, Name, Body FROM Document WHERE Folder.Name = 'ROP Mileages Conditions']) {
			result.add(eachDoc.Body.toString());
		}
		return result;
	}

	private static List<String> getMPDConditionList() {
		List<String> result = new List<String>();
		for (Document eachDoc : [SELECT Id, Name, Body FROM Document WHERE Folder.Name = 'MPD Conditions']) {
			result.add(eachDoc.Body.toString());
		}
		return result;
	}

	private static List<TextData> getTextDataListFromDocumentsInFolder(String folderDeveloperName) {
		List<TextData> result = new List<TextData>();
		for (Document eachDoc : [SELECT Id, Name, Body FROM Document WHERE Folder.DeveloperName = :folderDeveloperName]) {
			TextData eachTextData = new TextData();
			eachTextData.name = eachDoc.Name;
			eachTextData.content = eachDoc.Body.toString();
			result.add(eachTextData);
		}
		return result;
	}
}