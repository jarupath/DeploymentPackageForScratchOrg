public with sharing class WS_ROPManageAward_Model extends BE8_BaseSoap {
	public Envelope Envelope;

	public Boolean hasError() {
		if (Envelope.Body.Fault != null) {
			return true;
		} else if (Envelope.Body.IssueAwardRes.issueAwardReturn.IssueAwardRS.Error != null) {
			return true;
		}
		return false;
	}

	public String getErrorMessage() {
		if (Envelope.Body.Fault != null) {
			return Envelope.Body.Fault.faultCode + ' ' + Envelope.Body.Fault.faultString;
		} else if (Envelope.Body.IssueAwardRes.issueAwardReturn.IssueAwardRS.Error != null) {
			return Envelope.Body.IssueAwardRes.issueAwardReturn.IssueAwardRS.Error.Message;
		}
		return '';
	}

	public class Envelope extends BE8_BaseSoap.Envelope {
		public Header Header;
		public Body Body;
	}

	public class Body extends BE8_BaseSoap.Body {
		public IssueAwardRes IssueAwardRes {get; set;}
	}

	public class IssueAwardRes {
		public issueAwardReturn issueAwardReturn {get; set;}
	}

	//public issueAwardReturn issueAwardReturn {get; set;}

	public class issueAwardReturn {
		public IssueAwardRS IssueAwardRS {get; set;}
	}

	public class IssueAwardRS {
		public Error Error {get; set;}
		public String CertificateName {get; set;}
		public String CertificateNumber {get; set;}
		public String ExpiryDate {get; set;}
		public String EffectiveDate {get; set;}
		public String AwardPackage {get; set;}
		public String RemainingMiles {get; set;}
		public String Name {get; set;}
		public String SPCCode {get; set;}
		public String MemberID {get; set;}
		public String Success {get; set;}
	}

	public class Error {
		public String Code {get; set;}
		public String Message {get; set;}
		public String Type {get; set;}
	}
}