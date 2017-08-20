@RestResource(urlMapping='/lopas')
global with sharing class LOPA_RestResource {

    @HttpGet
    global static String show() {
        return 'test';
    }
}