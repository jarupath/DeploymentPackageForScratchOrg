global class CSE_SOAPUpdateComplaintStatus_WS {
	public static final String CLASS_NAME = 'CSE_SOAPUpdateComplaintStatus_WS';
	@TestVisible
	private static String CLOSE = 'CLOSE';

    global class ComplaintStatusReply{
		webservice String ResponseType;
		webservice String ResponseText;
	}
    
    webservice static ComplaintStatusReply updateStatus(String SEQNO, String Status){
    	boolean isError = false;
		ComplaintStatusReply result = new ComplaintStatusReply();
		result.ResponseType = 'E';
		result.ResponseText = '';
		
		System.debug('SEQNO :' + SEQNO + ' Status :' + Status);

		if(SEQNO == null){
			result.ResponseText += 'SEQNO ';
			isError = true;
		}

		if(Status == null){
			result.ResponseText += 'Status ';
			isError = true;
		}

		if(isError){
			System.debug('Error update complaint status require seqno/staus');
			result.ResponseText += 'required ';
			Applogger.error(CLASS_NAME, 'updateStatus', null, 'Error update complaint status require seqno/staus', null);
			AppLogger.insertLogs();
			return result;
		}


		if(Status != CLOSE){
			System.debug('Error update complaint status status is not CLOSE :' + Status);
			result.ResponseText = 'Error invalid status :require status = CLOSE';
			Applogger.error(CLASS_NAME, 'updateStatus', null, 'Error update complaint status status is not CLOSE :' + Status, null);
			AppLogger.insertLogs();
			return result;
		}

		else{
			try{
		        System.debug('Receive SEQNO :' + SEQNO + ' Status :' + Status);
		        List<Case> cs = [SELECT Id, Status FROM Case WHERE SEQ_No_Display__c = :SEQNO];

		        // Found case related to SEQNO
		        if(cs != null && !cs.isEmpty()){
		        	System.debug('Found case which SEQNO=' + SEQNO + ' size :' + cs.size());
			        for(Case c : cs){
			        	System.debug('Case Id :' + c.Id);
			        	c.Status = 'Closed'; // Change status to Closed
			        	Applogger.debug(CLASS_NAME, 'updateStatus', c.Id, SEQNO + ' is closed', null);
			        }
			        update cs;

			        result.ResponseType = 'S';
					result.ResponseText = SEQNO + ' is closed';
					AppLogger.insertLogs();
					return result;
		    	}
		    	// Not found case
		    	else{
		    		System.debug('Not found case SEQNO :' + SEQNO);
		    		result.ResponseType = 'E';
					result.ResponseText = SEQNO + ' not found';
					Applogger.error(CLASS_NAME, 'updateStatus', null, 'Not found case SEQNO :' + SEQNO, null);

		    	}
	        }catch(Exception e){
	        	System.debug('ERROR while update complaint status :' + e);
	        	result.ResponseType = 'E';
				result.ResponseText = 'Update failed :SEQNO :' + SEQNO;
				Applogger.error(CLASS_NAME, 'updateStatus', null, 'ERROR while update complaint status :' + e.getMessage(), e);
	        }
		}
		System.debug('JK: AppLogger - ' + JSON.serialize(AppLogger.getLogs()));
		AppLogger.insertLogs();
		return result;
	}
}