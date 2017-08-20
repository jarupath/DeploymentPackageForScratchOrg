@RestResource(urlMapping='/sessionid')
global with sharing class SessionId_RestResource  {

    @HttpGet
    global static String get() {
        return UserInfo.getSessionId();
    }
}