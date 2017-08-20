@RestResource(urlMapping='/ropapplication/*')
global class MB_RESTROPApplicationService {
    @HttpPost
    global static String createROPApplication(List<MB_RestRequestInfoModel.ropApplication_model> ropApplicationList){
        return 'OK';
    }
}