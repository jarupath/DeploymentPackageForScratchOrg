@RestResource(urlMapping = '/userprefs/*')
global class MB_RESTMaintenanceUserPrefs {
    @HttpGet
    global static MB_RESTResponseInfoModel.userPrefs getUserPreferences() {
        User thisUser = [SELECT Id, Station__c, A_C_REG__c, A_C_Type__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        MB_RESTResponseInfoModel.userPrefs userPrefs = new MB_RESTResponseInfoModel.userPrefs();
        userPrefs.station = thisUser.Station__c;
        userPrefs.acReg = thisUser.A_C_REG__c;
        userPrefs.acType = thisUser.A_C_Type__c;
        userPrefs.status = '1';
        return userPrefs;
    }
    
    @HttpPost
    global static MB_RESTResponseInfoModel.userPrefs updateUserPreferences(MB_RESTRequestInfoModel.userPrefs userPrefs) {
        MB_RESTResponseInfoModel.userPrefs response = new MB_RESTResponseInfoModel.userPrefs();
        User thisUser = new User(Id = UserInfo.getUserId());
        response.station = thisUser.Station__c = userPrefs.station;
        response.acReg = thisUser.A_C_REG__c = userPrefs.acReg;
        response.acType = thisUser.A_C_Type__c = userPrefs.acType;
        try {
            update thisUser;   
        } catch(Exception e){
            String message = e.getMessage() + '\n' + e.getStackTraceString();
            AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'MB_RESTMaintenanceUserPrefs', 'updateUserPreferences', UserInfo.getUserId(), 'User', message, System.JSON.serialize(userPrefs), null, System.currentTimeMillis());
            AppLogger.insertLogs();
            response.status = '0';
            return response;
        }
        response.status = '1';
        return response;
    }
}