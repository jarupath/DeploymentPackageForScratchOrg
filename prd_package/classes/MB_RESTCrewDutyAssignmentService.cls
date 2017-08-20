@RestResource(urlMapping='/crewdutyassignment/*')
global class MB_RESTCrewDutyAssignmentService {
    @HttpPost
    global static String updateCrewDutyAssignment(List<MB_RestRequestInfoModel.crewDutyAssignment_model> crewDutyAssignmentList){
        return 'OK';
    }
}