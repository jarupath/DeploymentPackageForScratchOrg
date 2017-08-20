@isTest
private class MB_RESTMaintenanceUserPrefsTest{
    
    @isTest static void testUpdateUserPreferences() {
        String station = 'BKK';
        String acReg = 'HS-TKA';
        String acType = '333';
        MB_RESTRequestInfoModel.userPrefs userPrefs = MockupData_Test.createUserPrefsRequest(station, acReg, acType);
        
        MB_RESTResponseInfoModel.userPrefs result = MB_RESTMaintenanceUserPrefs.updateUserPreferences(userPrefs);
        Assert.assertEquals('1', result.status);
        User thisUser = [SELECT Id, Station__c, A_C_REG__c, A_C_Type__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        Assert.assertEquals(station, thisUser.Station__c);
        Assert.assertEquals(acReg, thisUser.A_C_REG__c);
        Assert.assertEquals(acType, thisUser.A_C_Type__c);
    }
    
    @isTest static void testGetUserPreferences(){
        String station = 'BKK';
        String acReg = 'HS-TKA';
        String acType = '333';
        
        User thisUser = new User(Id = UserInfo.getUserId());
        thisUser.Station__c = station;
        thisUser.A_C_REG__c = acReg;
        thisUser.A_C_Type__c = acType;
        update thisUser;
        
        MB_RESTResponseInfoModel.userPrefs userPrefs = MB_RESTMaintenanceUserPrefs.getUserPreferences();
        Assert.assertEquals(station, userPrefs.station);
        Assert.assertEquals(acReg, userPrefs.acReg);
        Assert.assertEquals(acType, userPrefs.acType);
    }
}