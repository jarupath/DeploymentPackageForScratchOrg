@RestResource(urlMapping = '/masterdata/maintenance/*')
global class MB_RESTMasterDataMaintenanceAppService {

	global class MasterData {
		public List<Station> station;
		public List<Equipment> equipment;
		public List<String> condi;
	}

	global class Station {
		public String code;
		public String name;
		public String address;
	}

	global class Equipment {
		public String id;
		public String type;
		public String eqType;
		public String zone;
		public String location;
		public String name;
		public String ataCh;
		public String cCA;
		public String cPro;
		public String descr;
		public String qty;
		public String total;
		public String cabinVer;
		public String airDec;
		public Part[] part;
	}

	global class Part {
		public String id;
		public String name;
	}

	@HttpGet
	global static MasterData getMasterData() {
		MasterData result = new MasterData();
		result.station = new List<Station>();
		List<Aircraft_Station__mdt> stationList = [SELECT Id, Code__c, Full_Name__c, Address__c FROM Aircraft_Station__mdt];
		for (Aircraft_Station__mdt each : stationList) {
			Station eachStation = new Station();
			eachStation.code = each.Code__c;
			eachStation.name = each.Full_Name__c;
			eachStation.address = each.Address__c;
			result.station.add(eachStation);
		}

		List<Master_Map__c> generalEquipmentList = [SELECT Id, Check_by_CA_s_station__c, Checked_Procedure__c, Description__c, Quantity_to_be_checked__c, Total__c, Depend_On_Value__c, Cabin_Ver__c, Depend_On_Object_Name__c, Name, Aircraft_Description__c, Equipment_Type__c, Location__c, Field_Name__c, (SELECT Id, Name, Field_Name__c FROM Depend_On_Object__r) FROM Master_Map__c WHERE Field_Name__c = :BE8_GlobalConstants.SERVICE_EQUIPMENT AND Aircraft_Description__c = null];
		List<Master_Map__c> equipmentByAircraft = [SELECT Id, Check_by_CA_s_station__c, Checked_Procedure__c, Description__c, Quantity_to_be_checked__c, Total__c, Name, Depend_On_Object_Name__c , Cabin_Ver__c, Aircraft_Description__c, Depend_On_Value__c, Equipment_Type__c, Location__c, Field_Name__c FROM Master_Map__c WHERE Aircraft_Description__c != null];
		
		List<Master_Map__c> allEquipmentList = new List<Master_Map__c>();
		allEquipmentList.addAll(generalEquipmentList);
		allEquipmentList.addAll(equipmentByAircraft);

		List<Equipment> equipmentList = new List<Equipment>();
		for (Master_Map__c eachEquipment : allEquipmentList) {
				Equipment eModel = new Equipment();
				eModel.id = eachEquipment.Id;
				eModel.type = eachEquipment.Field_Name__c;
				eModel.eqType = eachEquipment.Equipment_Type__c;
				eModel.zone = eachEquipment.Check_by_CA_s_station__c;
				eModel.location = eachEquipment.Location__c;
				eModel.name = eachEquipment.Name;
				eModel.ataCh = eachEquipment.Depend_On_Object_Name__c;
				eModel.cCA = eachEquipment.Check_by_CA_s_station__c;
				eModel.cPro = eachEquipment.Checked_Procedure__c;
				eModel.descr = eachEquipment.Description__c;
				eModel.qty = '' + eachEquipment.Quantity_to_be_checked__c;
				eModel.total = '' + eachEquipment.Total__c;
				eModel.cabinVer = eachEquipment.Cabin_Ver__c;
				eModel.airDec = eachEquipment.Aircraft_Description__c;
				eModel.part = new List<Part>();
				if (eachEquipment.Depend_On_Object__r != null) {
					for (Master_Map__c eachPart : eachEquipment.Depend_On_Object__r) {
						Part pModel = new Part();
						pModel.id = eachPart.Id;
						pModel.name = eachPart.Name;
						eModel.part.add(pModel);
					}
				}
				equipmentList.add(eModel);
		}
		result.equipment = equipmentList;
        
        result.condi = new List<String>();
        for (Schema.PicklistEntry each : Case.Condition_Multi__c.getDescribe().getPicklistValues()) {
			result.condi.add(each.getValue());
		}
		return result;
	}
}