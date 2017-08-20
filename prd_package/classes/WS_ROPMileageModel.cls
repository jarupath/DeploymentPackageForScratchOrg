public class WS_ROPMileageModel {

    public class CurrentMileageRS {
        public String Success;
        public String PrivilegeCard;
        public String CurrentMileage;
        public String MemberID;
        public String LastActivityDate;
        public List<MilesExpiry> MilesExpiry;
        public String FullName;
        public List<MilesExpiry> ExtendablePoints;
    }

    public CurrentMileageRS CurrentMileageRS;

    public class MilesExpiry {
        public String Quarter;
        public String MilesExpiryDate;
        public String Year;
        public String Amount;
    }
}