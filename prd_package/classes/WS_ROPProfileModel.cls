public class WS_ROPProfileModel {
    public class Address {
        public String AdrSeqNo {get;set;} 
        public String Type {get;set;} // in json: Type
        public String CompanyName1 {get;set;} // Append
        public String CompanyName2 {get;set;} // Append 
        public String AddressLine1 {get;set;} 
        public String AddressLine2 {get;set;} 
        public String AddressLine3 {get;set;} // Append
        public String CityName {get;set;} 
        public String ProvinceCode {get;set;} // Append
        public String CountryCode {get;set;} 
        public String Postal {get;set;} 
    }
    
    public MemberProfileRS MemberProfileRS {get;set;} 
    
    public class HomePhone {
        public String HomePhoneType {get;set;} 
        public String CountryCode {get;set;}
        public String AreaCode {get;set;}
        public String PhoneNumber {get;set;} 
        public String Extension {get;set;} 
        public String SeqNo {get;set;} 
    }
    
    public class Phone {
        public String Type {get;set;} // in json: Type
        public String AreaCode {get;set;} // Append
        public String PhoneNumber {get;set;} 
        public String Extension {get;set;} // Append
        public String CountryCode {get;set;} 
        public String SeqNo {get;set;} 
    }
    
    public class MemberProfileRS {
        public String Success {get;set;} 
        public String MemberID {get;set;} 
        public String RemainingMiles {get;set;} 
        public String Salutation {get;set;} 
        public String FirstName {get;set;} 
        public String LastName {get;set;} 
        public HomePhone HomePhone {get;set;} 
        public String Email {get;set;} 
        public String EmlSeqNo {get;set;} 
        public String BirthDate {get;set;} 
        public Address Address {get;set;} 
        public List<Phone> Phone {get;set;} 
        public String PrivilegeCard {get;set;} 
        public String CardExpiryDate {get;set;} 
        public String Language {get;set;} 
        public String Status {get;set;} 
        public String Gender {get;set;} 
        public String EnrollSource {get;set;} 
        public String EnrollDate {get;set;} 
        public String Nationality {get;set;} 
    }
}