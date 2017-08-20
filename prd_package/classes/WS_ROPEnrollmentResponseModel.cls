public class WS_ROPEnrollmentResponseModel{
    public EnrolROPMemberRS EnrollROPMemberRes;

    public class EnrolROPMemberRS {
        public Success Success;
        public Error Error;
        public AddMainProfileRS AddMainProfileRS;
        public AddMainProfileRS UpdateCustomerSSRRS;
        public AddMainProfileRS UpdateMemberCommunicationPreferenceRS;
        public AddMainProfileRS AddPendingEnrolmentRS;
    }

    public class AddMainProfileRS {
        public Success Success;
        public Error Error;
    }

    public class Success {
        public String Code;
        public String Message;
    }

    public class Error{
        public String Code;
        public String Message;
        public String Type;
    }
}