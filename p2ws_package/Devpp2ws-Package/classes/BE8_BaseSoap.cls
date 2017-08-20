public abstract class BE8_BaseSoap {
	public abstract class Envelope {
		public Header Header;
		public Body Body;
	}

	public abstract class Header {
		public FaultDetail FaultDetail;
	}

	public abstract class Body {
		public Fault Fault;
	}

	public class Fault {
		public String faultCode;
		public String faultString;
	}

	public class FaultDetail {
		public String Policy;
		public String SystemName;
		public String Task;
		public String TaskList;
		public String User;
	}

}