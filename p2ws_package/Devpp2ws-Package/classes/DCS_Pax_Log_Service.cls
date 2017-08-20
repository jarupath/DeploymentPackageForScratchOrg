public without sharing class DCS_Pax_Log_Service {
	private static String jobName;

    public static void setJobName(String jobName){
        DCS_Pax_Log_Service.jobName = jobName;
    }

    public static String getJobName(){return jobName;}

    public static void logUpsert(object info, object result, String objName){
        List<SObject> infos = null;
        try{infos = (List<SObject>) info;}
        catch(Exception e){infos = ((Map<String, SObject>) info).values();}
        List<Database.UpsertResult> results = (List<Database.UpsertResult>) result;
        logUpsertError(results, infos, objName);
        logUpsertInfo(results, infos, objName);
    }

    public static void logDelete(object info, object result, String objName){
        List<SObject> infos = null;
        try{infos = (List<SObject>) info;}
        catch(Exception e){infos = ((Map<String, SObject>) info).values();}
        List<Database.DeleteResult> results = (List<Database.DeleteResult>) result;
        logDeleteError(results, infos, objName);
        logDeleteInfo(results, infos, objName);
    }

	public static void logUpsertError(List<Database.UpsertResult> upsertResult, List<SObject> upsertedSObjects, String objName){
    	List<Database.UpsertResult> errors = DCS_Pax_Util_Service.getError(upsertResult);
        if(errors != null && !errors.isEmpty()){
            Applogger.addLogModel(
                'Error', 
                'DCS_Pax_Util_Service', 
                'updateToDB', 
                jobName, 
                'Fail to upsert '+ objName + ' from DCS', 
                'Error: ' + errors.size() + '/' + upsertResult.size() + ' records', 
                null, 
                null, 
                null,
                getAttachMapOfSOQLEvent(upsertResult, upsertedSObjects, objName, 'upsert', errors)
            );            
        }

    }

    public static void logUpsertInfo(List<Database.UpsertResult> upsertResult, List<SObject> upsertedSObjects, String objName){
        Applogger.addLogModel(
            'Info', 
            'DCS_Pax_Util_Service', 
            'updateToDB', 
            jobName, 
            'upsert ' + objName + ' from DCS', 
            'upsert: ' + upsertResult.size() + ' records', 
            null,
            null, 
            null,
            null
        );
    }

    public static void logDeleteError(List<Database.DeleteResult> deleteResult, List<SObject> deletedSObjects, String objName){
        List<Database.DeleteResult> errors = DCS_Pax_Util_Service.getError(deleteResult);
        if(errors != null && !errors.isEmpty()){
            Applogger.addLogModel(
                'Error', 
                'DCS_Pax_Util_Service', 
                'updateToDB', 
                jobName, 
                'Fail to delete ' + objName + ' from DCS', 
                'Error: ' + deleteResult.size() + ' records', 
                null,
                null, 
                null,
                getAttachMapOfSOQLEvent(deleteResult, deletedSObjects, objName, 'delete', errors)
            );            
        }
    }

    public static void logDeleteInfo(List<Database.DeleteResult> deleteResult, List<SObject> deletedSObjects, String objName){
    	Applogger.addLogModel(
            'Info', 
            'DCS_Pax_Util_Service', 
            'updateToDB', 
            jobName, 
            'delete ' + objName + ' from DCS', 
            'Delete: ' + deleteResult.size() + ' records', 
            null, 
            null, 
            null,
            null
        );
    }

    public static void logCalloutError(String request, Exception e){
        if(e != null){
            AppLogger.addLogModel(
                'Error', //logLevel, 
                'DCS_Pax_Management', //sourceClass, 
                'getDCSPaxModel', //sourceFunction, 
                jobName, //referenceId, 
                'DCS Callout Error', //referenceInfo, 
                e.getStackTraceString(), //logMessage, 
                null, //payLoad, 
                e, //ex, 
                null, //timeTaken, 
                getAttachMapOfWSCallout(request, null) //attachMap
            );
        }
    }

    public static void logCalloutError(String request, String response){
        AppLogger.addLogModel(
            'Error', //logLevel, 
            'DCS_Pax_Management', //sourceClass, 
            'getDCSPaxModel', //sourceFunction, 
            jobName, //referenceId, 
            'DCS Callout Error', //referenceInfo, 
            'Error while callout', //logMessage, 
            null, //payLoad, 
            null, //ex, 
            null, //timeTaken, 
            getAttachMapOfWSCallout(request, response) //attachMap
        );
    }

    public static void logCalloutInfo(){
        AppLogger.addLogModel(
            'Debug', //logLevel, 
            'DCS_Pax_Management', //sourceClass, 
            'getDCSPaxModel', //sourceFunction, 
            jobName, //referenceId, 
            'DCS Callout', //referenceInfo, 
            'DCS Callout', //logMessage, 
            null, //payLoad, 
            null, //ex, 
            null, //timeTaken, 
            null //attachMap
        );
    }

    private static Map<String, String> getAttachMapOfSOQLEvent(List<object> upsertedResults, List<SObject> objList, String objName, String eventName){
    	return getAttachMapOfSOQLEvent(upsertedResults, objList, objName, eventName, null);
    }

    private static Map<String, String> getAttachMapOfSOQLEvent(List<object> upsertedResults, List<SObject> objList, String objName, String eventName, List<object> errors){
        Map<String, String> returnMap = new Map<String, String>();
        if(objList != null && !objList.isEmpty()) returnMap.put(eventName + ' ' + objName + ' list', JSON.serialize(objList));
        if(upsertedResults != null && !upsertedResults.isEmpty()) returnMap.put(eventName + ' ' + objName + ' result', JSON.serialize(upsertedResults));
        if(errors != null && !errors.isEmpty()) returnMap.put(eventName + ' ' + objName + ' error', JSON.serialize(errors));
        
        if(returnMap != null && !returnMap.isEmpty()) return returnMap;
        return null;
    }

    private static Map<String, String> getAttachMapOfWSCallout(String request, String response){
        Map<String, String> returnMap = new Map<String, String>();
        if(request != null) returnMap.put('request', request);
        if(response != null) returnMap.put('response', response);

        if(returnMap != null && !returnMap.isEmpty()) return returnMap;
        return null;
    }
}