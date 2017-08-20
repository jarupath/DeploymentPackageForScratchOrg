@isTest
public class MockFlightWSResponseGenerator implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    //public MockFlightWSResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
    //    this.code = code;
    //    this.status = status;
    //    this.body = body;
    //    this.responseHeaders = responseHeaders;
    //}

    public MockFlightWSResponseGenerator() {
        this('628');
    }

    public MockFlightWSResponseGenerator(String flightNo) {
        this.code = 200;
        this.status = 'SUCCESS';
        this.body = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">  <soapenv:Body>    <ns2:getFlightResponse xmlns:ns2="http://bean.fi.tg.com/">      <return>        <changeFlightDateLT/>        <changeFlightDateUTC/>        <changeFlightNo/>        <destination>ICN</destination>        <flightCancelFlag>false</flightCancelFlag>        <flightChangeFlag>false</flightChangeFlag>        <flightDateLT>30Sep16</flightDateLT>        <flightDateUTC>30Sep16</flightDateUTC>        <flightNo>' + flightNo + '</flightNo>        <flightRemark/>        <legdetail>          <ATA_LT>30Sep16 1516</ATA_LT>          <ATA_UTC>30Sep16 0716</ATA_UTC>          <ATD_LT>30Sep16 1110</ATD_LT>          <ATD_UTC>30Sep16 0410</ATD_UTC>          <aircraftRegistration>HSTET  </aircraftRegistration>          <aircraftType>330</aircraftType>          <arrivalDelay/>          <arrivalSTN>HKG</arrivalSTN>          <arrivalSTNICAO>VHHH</arrivalSTNICAO>          <arrivalSTNName>HONG KONG                     </arrivalSTNName>          <arrivalTerminal/>          <belt/>          <blockTime>0306</blockTime>          <departureDelay>AM/0025</departureDelay>          <departureSTN>BKK</departureSTN>          <departureSTNICAO>VTBS</departureSTNICAO>          <departureSTNName>BANGKOK INTERNATIONAL         </departureSTNName>          <departureTerminal/>          <ETA_LT>30Sep16 1458</ETA_LT>          <ETA_UTC>30Sep16 0658</ETA_UTC>          <ETD_LT>30Sep16 1045</ETD_LT>          <ETD_UTC>30Sep16 0345</ETD_UTC>          <gate/>          <legSeq>1</legSeq>          <STA_LT>30Sep16 1430</STA_LT>          <STA_UTC>30Sep16 0630</STA_UTC>          <STD_LT>30Sep16 1045</STD_LT>          <STD_UTC>30Sep16 0345</STD_UTC>        </legdetail>        <legdetail>          <ATA_LT/>          <ATA_UTC/>          <ATD_LT/>          <ATD_UTC/>          <aircraftRegistration>HSTET  </aircraftRegistration>          <aircraftType>330</aircraftType>          <arrivalDelay/>          <arrivalSTN>ICN</arrivalSTN>          <arrivalSTNICAO>RKSI</arrivalSTNICAO>          <arrivalSTNName>INCHEON INTERNATIONAL         </arrivalSTNName>          <arrivalTerminal/>          <belt/>          <blockTime>0340</blockTime>          <departureDelay/>          <departureSTN>HKG</departureSTN>          <departureSTNICAO>VHHH</departureSTNICAO>          <departureSTNName>HONG KONG                     </departureSTNName>          <departureTerminal/>          <ETA_LT/>          <ETA_UTC/>          <ETD_LT/>          <ETD_UTC/>          <gate/>          <legSeq>2</legSeq>          <STA_LT>30Sep16 2010</STA_LT>          <STA_UTC>30Sep16 1110</STA_UTC>          <STD_LT>30Sep16 1530</STD_LT>          <STD_UTC>30Sep16 0730</STD_UTC>        </legdetail>        <nextFlightNo>657</nextFlightNo>        <nextFlightSTD_LT>30Sep16 2120</nextFlightSTD_LT>        <nextFlightSTD_UTC>30Sep16 1220</nextFlightSTD_UTC>        <origin>BKK</origin>      </return>    </ns2:getFlightResponse>  </soapenv:Body></soapenv:Envelope>';
        this.responseHeaders = new Map<String, String> {'Content-Type' => 'application/xml'};
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}