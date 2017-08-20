/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A wrapper class for application log messages

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
28/09/2016  Charnun.T           First Create
------------------------------------------------------------*/
public class BE8_ApplicationLogWrapper {
    public string source {get;set;}
    public string sourceFunction {get;set;}
    public string referenceId {get;set;}
    public string referenceInfo{get;set;}
    public string logMessage {get;set;}
    public string payload {get;set;}
    public Exception ex {get;set;}
    public string debugLevel {get;set;}
    public string logCode {get;set;}
    public long timer {get;set;}
      
}