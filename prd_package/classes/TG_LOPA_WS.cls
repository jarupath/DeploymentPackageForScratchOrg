public class TG_LOPA_WS {
    public class Air_HTTP {
        public String endpoint_x = 'http://202.122.131.25/res/booking/air';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public TG_Security_element Security;
        private String Security_hns = 'Security=http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
        public TG_WS_Header.ReqHeader GetSeatMapReqHeader;
        public TG_WS_Header.ResHeader GetSeatMapResHeader;
        private String GetSeatMapReqHeader_hns = 'ReqHeader=http://xml.accenture.com/common/header';
        private String GetSeatMapResHeader_hns = 'ResHeader=http://xml.accenture.com/common/header';
        private String[] ns_map_type_info = new String[]{'http://ws.accenture.com/res/booking/air/Air_HTTP', 'TG_LOPA_WS', 'http://xml.accenture.com/common/fault', 'TG_WS_Fault', 'http://xml.accenture.com/res/booking/air/getseatmap/v2_0', 'TG_LOPA_Req', 'http://xml.accenture.com/common/header', 'TG_WS_Header', 'http://xml.accenture.com/res/booking/air', 'TG_LOPA_Result'};
        public TG_LOPA_Req.GetSeatMapRes GetSeatMap(TG_LOPA_Req.TravelProductInfoTypeIREQ travelProductIdent,TG_LOPA_Req.SeatRequestParametersTypeIREQ seatRequestParameters,TG_LOPA_Req.RelatedProductInfoTypeIREQ productInfo,TG_LOPA_Req.FrequentTravellerInfoTypeIREQ frequentTravelerInfo,TG_LOPA_Req.ReservationControlInfoTypeIREQ resControlInfo,TG_LOPA_Req.EquipInfoTypeIREQ equipInfo,TG_LOPA_Req.AdditionalBusinessSourceInfoTypeIREQ additionalInfo,TG_LOPA_Req.ConversionRateTypeIREQ conversionRate,TG_LOPA_Req.traveler_element[] traveler) {
            TG_LOPA_Req.GetSeatMapReq request_x = new TG_LOPA_Req.GetSeatMapReq();
            request_x.travelProductIdent = travelProductIdent;
            request_x.seatRequestParameters = seatRequestParameters;
            request_x.productInfo = productInfo;
            request_x.frequentTravelerInfo = frequentTravelerInfo;
            request_x.resControlInfo = resControlInfo;
            request_x.equipInfo = equipInfo;
            request_x.additionalInfo = additionalInfo;
            request_x.conversionRate = conversionRate;
            request_x.traveler = traveler;
            TG_LOPA_Req.GetSeatMapRes response_x;
            Map<String, TG_LOPA_Req.GetSeatMapRes> response_map_x = new Map<String, TG_LOPA_Req.GetSeatMapRes>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'GetSeatMap',
              'http://xml.accenture.com/res/booking/air',
              'GetSeatMapReq',
              'http://xml.accenture.com/res/booking/air',
              'GetSeatMapRes',
              'TG_LOPA_Req.GetSeatMapRes'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}