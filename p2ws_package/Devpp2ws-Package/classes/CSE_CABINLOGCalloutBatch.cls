global class CSE_CABINLOGCalloutBatch implements Database.Batchable<CSE_SOAPCABINLOG_WS.CabinLogModel>, Database.AllowsCallouts{
	private CSE_SOAPCABINLOG_WS.CabinLogModel mCabinLogModel;

	public CSE_CABINLOGCalloutBatch(CSE_SOAPCABINLOG_WS.CabinLogModel pCabinLogModel) {
		this.mCabinLogModel = pCabinLogModel;
	}

	global Iterable<CSE_SOAPCABINLOG_WS.CabinLogModel> start(Database.BatchableContext BC) {
		List<CSE_SOAPCABINLOG_WS.CabinLogModel> ms = new List<CSE_SOAPCABINLOG_WS.CabinLogModel>();
		System.debug('Add cabin log to the list');
		ms.add(mCabinLogModel);
		return ms;
	}

   	global void execute(Database.BatchableContext BC, List<CSE_SOAPCABINLOG_WS.CabinLogModel> scope) {
   		for(CSE_SOAPCABINLOG_WS.CabinLogModel c : scope){
   			System.debug('Inserting cabin log to TG :flightNo :' + c.flightNo);
   			// Insert cabin log to TG
   			CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = new CSE_SOAPCABINLOG_WS().insertCabinLog(c);
   		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
}