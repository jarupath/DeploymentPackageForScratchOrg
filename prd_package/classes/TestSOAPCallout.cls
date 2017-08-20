public class TestSOAPCallout {
    public static Integer myValue = 0;  //Class Member variable
    public static String myString = ''; //Class Member variable
    
    /*
    public static void wsCallGetPaxNameListAll(){
        wsAccentureComInvOdsenquiryInvsbrpn.INVSBRPNRList_HTTP wsInv = new wsAccentureComInvOdsenquiryInvsbrpn.INVSBRPNRList_HTTP();
        //wsInv.inputHttpHeaders_x = new Map<String, String>{'Authorization'=>'Basic 555'};
        
        wsInv.inputHttpHeaders_x = new Map<String, String>();
        wsInv.outputHttpHeaders_x = new Map<String, String>();
        
        wsInv.inputHttpHeaders_x.put('Username','FB_SICSE');
        wsInv.inputHttpHeaders_x.put('Password Type','tgfbtgfb1');
        wsInv.inputHttpHeaders_x.put('Nonce EncodingType','XoMnrWTUxCTyXKsBO31orNiZ7F8');
        wsInv.inputHttpHeaders_x.put('Created','2016-09-22T07:38:18.612Z');
        wsInv.inputHttpHeaders_x.put('SvcVer','v1_0');        
        wsInv.inputHttpHeaders_x.put('ReqTxnID','SALESFORCE');
        wsInv.inputHttpHeaders_x.put('SvcVer','v1_0');
        wsInv.inputHttpHeaders_x.put('MWTxnID','ExxQy0FqLCuRbxxxx');

        wsInv.outputHttpHeaders_x.put('Username','FB_SICSE');
        wsInv.outputHttpHeaders_x.put('Password Type','tgfbtgfb1');
        wsInv.outputHttpHeaders_x.put('Nonce EncodingType','XoMnrWTUxCTyXKsBO31orNiZ7F8');
        wsInv.outputHttpHeaders_x.put('Created','2016-09-22T07:38:18.612Z');
        wsInv.outputHttpHeaders_x.put('SvcVer','v1_0');        
        wsInv.outputHttpHeaders_x.put('ReqTxnID','SALESFORCE');
        wsInv.outputHttpHeaders_x.put('SvcVer','v1_0');
        wsInv.outputHttpHeaders_x.put('MWTxnID','ExxQy0FqLCuRbxxxx');


        //wsInv.inputHttpHeaders_x.put('', '');
        wsInv.GetPaxNameListAllReqHeader = new xmlAccentureComCommonHeader.ReqHeader();
        wsInv.GetPaxNameListAllReqHeader.ReqDateTime = DateTime.newInstance(2016, 09, 12, 08, 08, 30);
        wsInv.GetPaxNameListAllReqHeader.ReqTxnID = 'SALESFORCEs';
        wsInv.GetPaxNameListAllReqHeader.SvcVer = 'v1_0';
        wsInv.GetPaxNameListAllReqHeader.MWTxnID = 'ExxQy0FqLCuRbxxxx';
        wsinv.GetPaxNameListAllReqHeader.Credentials = new xmlAccentureComCommonHeader.Credentials_element();
        wsinv.GetPaxNameListAllReqHeader.Credentials.MWCredential = new xmlAccentureComCommonHeader.MWCredential_element();
        wsinv.GetPaxNameListAllReqHeader.Credentials.MWCredential.ReqID = 'MWTESTER'; 
        wsinv.GetPaxNameListAllReqHeader.Credentials.MWCredential.ReqPwd = ''; 
        wsinv.GetPaxNameListAllReqHeader.Credentials.MWCredential.UserID = 'MWTESTER';

        xmlAccentureComInvOutputPaxnamelist.IFLIRR data = wsInv.GetPaxNameListAll('TG',
            '378',
            Date.newInstance(2016, 08, 12), // Date DepartureDate
            null, // String BoardPoint
            null, // String OffPoint
            null, // String BookingClass
            false, // Boolean InboundIndic
            false); // Boolean OutboundIndic

            System.debug( 'Call service GetPaxNameListAll successfully');
        

    }*/
}