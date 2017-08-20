@RestResource(urlMapping='/crewappraisalanswer/*')
global class MB_RESTCrewAppraisalAnswerService {
    @HttpPost
    global static String createUpdateCrewAppraisalAnswer(List<MB_RestRequestInfoModel.crewAppraisalAnswer_model> crewAppraisalAnswerList){
        return 'OK';
    }
}