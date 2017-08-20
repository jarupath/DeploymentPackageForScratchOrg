public with sharing class WS_SUBMITCrewAppraisal_Model extends BE8_BaseSoap {
    public Envelope Envelope;

    public Boolean hasError() {
        if (Envelope.Body.Fault != null) {
            return true;
        }
        return false;
    }

    public String getErrorMessage() {
        if (Envelope.Body.Fault != null) {
            return Envelope.Body.Fault.faultCode + ' ' + Envelope.Body.Fault.faultString;
        }
        return '';
    }


    public class Envelope extends BE8_BaseSoap.Envelope {
        public Header Header;
        public Body Body;
    }

    public class Body extends BE8_BaseSoap.Body {
        public InsertCrewAppraisalRes InsertCrewAppraisalRes {get; set;}
    }

    public class InsertCrewAppraisalRes {
        public List<return_z> return_z {get; set;}
    }

    public class return_z {
        public String description {get; set;}
        public String evaluateStaffID {get; set;}
        public String evaluatedAirlineCode {get; set;}
        public String evaluatedArrPort {get; set;}
        public String flagFormComplete {get; set;}
        public String formNumber {get; set;}
        public String staffID {get; set;}
    }
}