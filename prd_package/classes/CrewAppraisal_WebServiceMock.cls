@isTest
global class CrewAppraisal_WebServiceMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       WS_SUBMITCrewAppraisal_Model respElement =  new WS_SUBMITCrewAppraisal_Model();
       response.put('response_x', respElement); 
   }
}