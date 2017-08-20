public class WS_ROPAdditionalProfileModel {

    public class GetAdditionalMemberProfileRes {
        public Success Success;
    }

    public GetAdditionalMemberProfileRes GetAdditionalMemberProfileRes;

    public class TargetAudience {
        public String Code;
    }

    public class Success {
        public String MemberID;
        public String MaritalStatus;
        public String Children;
        public String Education;
        public String Occupation;
        public String Income;
        public List<TargetAudience> TargetAudience;
    }

    public static WS_ROPAdditionalProfileModel parse(String json) {
        return (WS_ROPAdditionalProfileModel) System.JSON.deserialize(json, WS_ROPAdditionalProfileModel.class);
    }
}