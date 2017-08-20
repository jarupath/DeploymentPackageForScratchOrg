public class WS_ROPEnrollmentRequestModel {

	public class Address {
		public String AddressType;
		public String BusinessTitle;
		public String CompanyName1;
		public String CompanyName2;
		public String AddressLine1;
		public String AddressLine2;
		public String AddressLine3;
		public String City;
		public String State;
		public String CountryCode;
		public String PostalCode;
	}

	public EnrolROPMemberRQ EnrolROPMemberRQ;

	public class EnrolROPMemberRQ {
		public String MemberID;
		public String Salutation;
		public String FirstName;
		public String Middle;
		public String LastName;
		public String Suffix;
		public Address Address;
		public String PhoneType1;
		public String CountryCode1;
		public String AreaCode1;
		public String Number1;
		public String Extension1;
		public String PhoneType2;
		public String AreaCode2;
		public String Number2;
		public String Extension2;
		public String CountryCode2;
		public String PhoneType3;
		public String AreaCode3;
		public String Number3;
		public String Extension3;
		public String CountryCode3;
		public String PhoneType4;
		public String AreaCode4;
		public String Number4;
		public String Extension4;
		public String CountryCode4;
		public String EmailAddress;
		public String BirthDate;
		public String Gender;
		public String EnrollSource;
		public String Language;
		public String EnrollDate;
		public String SponsorID;
		public String SSRSeat;
		public String SSRMeal;
		public String EnewsIndicator;
		public String ThaiOfferIndicator;
		public String PartnerOfferIndicator;
		public String Nationality;
		public String PinNumber;

		public EnrolROPMemberRQ() {
			Address = new WS_ROPEnrollmentRequestModel.Address();
			Address.AddressType = 'H';
			Address.AddressLine1 = 'xxx';
			Address.City = 'Bangkok';
			Address.CountryCode = 'TH';
			Address.PostalCode = '99999';
			EnrollSource = 'IFLIGHT';
			Language = 'EN';
			EnrollDate = String.valueOf(Date.today());
			PinNumber = ROPEnrollmentService.generatePINNumber();
			EnewsIndicator = 'Y';
			ThaiOfferIndicator = 'D';
			PartnerOfferIndicator = 'D';
		}

		public String toJsonString() {
			JSONGenerator gen = JSON.createGenerator(true);

			gen.writeStartObject();
			writeStringField(gen, 'MemberID', this.MemberID);
			writeStringField(gen, 'Salutation', this.Salutation);
			writeStringField(gen, 'FirstName', this.FirstName);
			writeStringField(gen, 'Middle', this.Middle);
			writeStringField(gen, 'LastName', this.LastName);
			writeStringField(gen, 'Suffix', this.Suffix);
			//public Address Address;
			gen.writeFieldName('Address');
			if (this.Address != null) {
				gen.writeStartObject();
				writeStringField(gen, 'AddressType', this.Address.AddressType);
				writeStringField(gen, 'BusinessTitle', this.Address.BusinessTitle);
				writeStringField(gen, 'CompanyName1', this.Address.CompanyName1);
				writeStringField(gen, 'CompanyName2', this.Address.CompanyName2);
				writeStringField(gen, 'AddressLine1', this.Address.AddressLine1);
				writeStringField(gen, 'AddressLine2', this.Address.AddressLine2);
				writeStringField(gen, 'AddressLine3', this.Address.AddressLine3);
				writeStringField(gen, 'City', this.Address.City);
				writeStringField(gen, 'State', this.Address.State);
				writeStringField(gen, 'CountryCode', this.Address.CountryCode);
				writeStringField(gen, 'PostalCode', this.Address.PostalCode);
				gen.writeEndObject();
			}

			writeStringField(gen, 'PhoneType1', this.PhoneType1);
			writeStringField(gen, 'CountryCode1', this.CountryCode1);
			writeStringField(gen, 'AreaCode1', this.AreaCode1);
			writeStringField(gen, 'Number1', this.Number1);
			writeStringField(gen, 'Extension2', this.Extension1);
			writeStringField(gen, 'PhoneType2', this.PhoneType1);
			writeStringField(gen, 'AreaCode2', this.AreaCode2);
			writeStringField(gen, 'Number2', this.Number2);
			writeStringField(gen, 'Extension2', this.Extension2);
			writeStringField(gen, 'CountryCode2', this.CountryCode2);
			writeStringField(gen, 'PhoneType3', this.PhoneType3);
			writeStringField(gen, 'AreaCode3', this.AreaCode3);
			writeStringField(gen, 'Number3', this.Number3);
			writeStringField(gen, 'Extension3', this.Extension3);
			writeStringField(gen, 'CountryCode3', this.CountryCode3);
			writeStringField(gen, 'PhoneType4', this.PhoneType4);
			writeStringField(gen, 'AreaCode4', this.AreaCode4);
			writeStringField(gen, 'Number4', this.Number4);
			writeStringField(gen, 'Extension4', this.Extension4);
			writeStringField(gen, 'CountryCode4', this.CountryCode4);
			writeStringField(gen, 'EmailAddress', this.EmailAddress);
			writeStringField(gen, 'BirthDate', this.BirthDate);
			writeStringField(gen, 'Gender', this.Gender);
			writeStringField(gen, 'EnrollSource', this.EnrollSource);
			writeStringField(gen, 'Language', this.Language);
			writeStringField(gen, 'EnrollDate', this.EnrollDate);
			writeStringField(gen, 'SponsorID', this.SponsorID);
			writeStringField(gen, 'SSRSeat', this.SSRSeat);
			writeStringField(gen, 'SSRMeal', this.SSRMeal);
			writeStringField(gen, 'EnewsIndicator', this.EnewsIndicator);
			writeStringField(gen, 'ThaiOfferIndicator', this.ThaiOfferIndicator);
			writeStringField(gen, 'PartnerOfferIndicator', this.PartnerOfferIndicator);
			writeStringField(gen, 'Nationality', this.Nationality);
			writeStringField(gen, 'PinNumber', this.PinNumber);
			gen.writeEndObject();
			return gen.getAsString();
		}

		private void writeStringField(JSONGenerator gen, String fieldName, String value) {
			if (value != null) {
				gen.writeStringField(fieldName, value);
			}
		}
	}
}