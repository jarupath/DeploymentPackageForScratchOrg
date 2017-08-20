@RestResource(urlMapping = '/alllopa/*')
global class MB_RESTAllAircraftLOPA {

	global class lopaInfo_model {
		public String aircraftId;
		public String acReg;
		public String maxRow;
		public String acType;
		public String cabinVer;
		public lopaInfo_lopaPos[] lopaPos;
	}

	global class lopaInfo_lopaPos {
		//public String id;
		public String lopaId;
		public String type;
		public String row;
		public String rowL;
		public String col;
		public String colL;
		public String maxCol;
		public String pos;
		public String tclass;
		public String floor;
		public String zone;
		//public Boolean flag;
		//public String sts;
		//public String sOcp;
		public Integer width;
		public Integer height;
		//public List<String> sCh;
		//private List<Integer> aisleSeatList;
	}

	@HttpPost
	global static List<lopaInfo_model> getAllLOPA(Integer offset) {
		Integer limitCount = 10;
		offset = (offset - 1) * limitCount;
		//List<Aircraft__c> allAircraftList = [SELECT Id, Cabin_Ver__c, Aircraft_Registration__c, Aircraft_Type__c, (SELECT Id FROM Flights__r WHERE Departed__c = true ORDER BY STD_UTC_DateTime__c DESC LIMIT 1) FROM Aircraft__c ORDER BY Aircraft_Registration__c ASC LIMIT :limitCount OFFSET :offset];

		//Map<Id, Aircraft__c> aircraftMap = new Map<Id, Aircraft__c>();
		//for (Aircraft__c aircraft : allAircraftList) {
		//	Boolean thisAircraftHasFlight = aircraft.Flights__r != null && aircraft.Flights__r.size() > 0;
		//	if (thisAircraftHasFlight) {
		//		aircraftMap.put(aircraft.Flights__r.get(0).Id, aircraft);
		//	}
		//}
		Map<Id, Aircraft__c> aircraftMap = new Map<Id, Aircraft__c>([SELECT Id, Cabin_Ver__c, Aircraft_Registration__c, Aircraft_Main_Type__c FROM Aircraft__c ORDER BY Aircraft_Registration__c ASC LIMIT :limitCount OFFSET :offset]);

		List<lopaInfo_model> resultList = new List<lopaInfo_model>();
		for (Attachment lopaFile : [SELECT Id, Body, ParentId FROM Attachment WHERE Name = 'Master_LOPA.txt' AND ParentId IN :aircraftMap.keySet()]) {
			Aircraft__c aircraft = aircraftMap.get(lopaFile.ParentId);
			resultList.add(convertIntoAircraftAppModel((MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(lopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class), aircraft));
			//convertIntoAircraftAppModel((MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(lopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class), acReg);
		}
		return resultList;
		return null;
	}

	public static lopaInfo_model convertIntoAircraftAppModel(MB_RestResponseInfoModel.lopaInfo_model oldModel, Aircraft__c aircraft) {
		lopaInfo_model newModel = new lopaInfo_model();
		newModel.aircraftId = aircraft.Id;
		newModel.acReg = aircraft.Aircraft_Registration__c;
		newModel.acType = aircraft.Aircraft_Main_Type__c;
		newModel.cabinVer = aircraft.Cabin_Ver__c;
		if (oldModel != null) {
			newModel.maxRow = oldModel.maxRow;

			newModel.lopaPos = new List<lopaInfo_lopaPos>();
			if (oldModel.lopaPos != null) {
				for (MB_RestResponseInfoModel.lopaInfo_lopaPos oldPosModel : oldModel.lopaPos) {
					lopaInfo_lopaPos newPosModel = new lopaInfo_lopaPos();
					//newPosModel.id = oldPosModel.id;
					newPosModel.lopaId = oldPosModel.lopaId;
					newPosModel.type = oldPosModel.type;
					newPosModel.row = oldPosModel.row;
					newPosModel.rowL = oldPosModel.rowL;
					newPosModel.col = oldPosModel.col;
					newPosModel.colL = oldPosModel.colL;
					newPosModel.maxCol = oldPosModel.maxCol;
					newPosModel.pos = oldPosModel.pos;
					newPosModel.floor = oldPosModel.floor;
					newPosModel.zone = oldPosModel.zone;
					//newPosModel.sts = oldPosModel.sts;
					//newPosModel.sOcp = oldPosModel.sOcp;
					newPosModel.width = oldPosModel.width;
					newPosModel.height = oldPosModel.height;
					newPosModel.tclass = oldPosModel.tclass;
					newModel.lopaPos.add(newPosModel);
				}
			}
		}
		return newModel;
	}
}