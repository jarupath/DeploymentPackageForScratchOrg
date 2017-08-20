trigger TempPassengerTrigger on TempPassenger__c (after insert) {
	if (TriggerActivator.isTriggerActivated(TriggerActivator.TEMPPASSENGER_TRIGGER)) {
		//delete record
		if (Trigger.isAfter && Trigger.isInsert) {
			List<TempPassenger__c> tempPassengerList = Trigger.new;
			System.debug('TempPassenger:----' + tempPassengerList.size());
			Map<String, TempPassenger__c> tempMap = new Map<String, TempPassenger__c>();

			Map<String, Account> existingAccount = new Map<String, Account>();
			Map<String, Membership__c> existingMembership = new Map<String, Membership__c>();
			Map<String, Account> newAccount = new Map<String, Account>();
			Map<String, Membership__c> newMembership = new Map<String, Membership__c>();

			List<String> membershipList = new List<String>();

			//create membership list and tempassenger map from input
			for (TempPassenger__c temp : tempPassengerList) {
				membershipList.add('TG_' + temp.ROP_Number__c);
				tempMap.put(temp.ROP_Number__c, temp);
			}

			Map<String, Membership__c> existingInSFDC = BE8_GlobalUtility.getExistingAccountMember(membershipList);

			for (TempPassenger__c temp : tempPassengerList) {
				String accountID = null;
				String memId = null;
				if (existingInSFDC.get('TG_' + temp.ROP_Number__c) != null) {
					accountID = existingInSFDC.get('TG_' + temp.ROP_Number__c).AccountId__c;
					memId = existingInSFDC.get('TG_' + temp.ROP_Number__c).Id;
					System.debug('AccountID:----' + accountID);
					System.debug('input ROP number:----' + 'TG_' + temp.ROP_Number__c);
				}

				Account acc = new Account();
				Membership__c mem = new Membership__c();
				acc.Name = temp.Name;
				acc.First_Name__c = temp.ROP_First_Name__c;
				acc.Last_Name__c = temp.ROP_Last_Name__c;
				if (temp.ROP_Tier__c == null) {
					acc.ROP_Tier__c = 'Basic';
					mem.Tier__c = 'Basic';
				} else {
					acc.ROP_Tier__c = temp.ROP_Tier__c;
					mem.Tier__c = temp.ROP_Tier__c;
				}
				acc.Salutation__c = temp.ROP_Title__c;
				if (temp.ROP_Date_of_Birth__c != '0001-01-01') {
					acc.Date_of_Birth__c = Date.valueOf(temp.ROP_Date_of_Birth__c);
				}
				acc.ROP_Number__c = temp.ROP_Number__c;
				acc.Mailling_Address__c = temp.ROP_Mailing_Address__c;

				acc.ROP_Home_Phone__c = temp.ROP_Home_Phone__c;
				acc.ROP_Home_Phone_2__c = temp.ROP_Home_Phone_2__c;
				acc.ROP_Business_Phone__c = temp.ROP_Business_Phone__c;
				acc.ROP_Business_Phone_2__c = temp.ROP_Business_Phone_2__c;
				acc.ROP_Mobile__c = temp.ROP_Mobile_Phone__c;
				acc.ROP_Mobile_2__c = temp.ROP_Mobile_Phone_2__c;
				acc.ROP_Fax__c = temp.ROP_Fax_Phone__c;

				acc.ROP_Home_Country_Code__c = temp.ROP_Home_Phone_Country_Code__c;
				acc.ROP_Home_Country_Code_2__c = temp.ROP_Home_Phone_2_Country_Code__c;
				acc.ROP_Business_Country_Code__c = temp.ROP_Business_Phone_Country_Code__c;
				acc.ROP_Business_Country_Code_2__c = temp.ROP_Business_Phone_2_Country_Code__c;
				acc.ROP_Mobile_Country_Code__c = temp.ROP_Mobile_Phone_Country_Code__c;
				acc.ROP_Mobile_Country_Code_2__c = temp.ROP_Mobile_Phone_2_Country_Code__c;
				acc.ROP_Fax_Country_Code__c = temp.ROP_Fax_Phone_Country_Code__c;

				acc.ROP_Home_Area_Code__c = temp.ROP_Home_Phone_Area_Code__c;
				acc.ROP_Home_Area_Code_2__c = temp.ROP_Home_Phone_2_Area_Code__c;
				acc.ROP_Business_Area_Code__c = temp.ROP_Business_Phone_Area_Code__c;
				acc.ROP_Business_Area_Code_2__c = temp.ROP_Business_Phone_2_Area_Code__c;
				acc.ROP_Mobile_Area_Code__c = temp.ROP_Mobile_Phone_Area_Code__c;
				acc.ROP_Mobile_Area_Code_2__c = temp.ROP_Mobile_Phone_2_Area_Code__c;
				acc.ROP_Fax_Area_Code__c = temp.ROP_Fax_Phone_Area_Code__c;

				acc.ROP_Home_Extension__c = temp.ROP_Home_Phone_Extension__c;
				acc.ROP_Home_Extension_2__c = temp.ROP_Home_Phone_2_Extension__c;
				acc.ROP_Business_Extension__c = temp.ROP_Business_Phone_Extension__c;
				acc.ROP_Business_Extension_2__c = temp.ROP_Business_Phone_2_Extension__c;
				acc.ROP_Mobile_Extension__c = temp.ROP_Mobile_Phone_Extension__c;
				acc.ROP_Mobile_Extension_2__c = temp.ROP_Mobile_Phone_2_Extension__c;
				acc.ROP_Fax_Extension__c = temp.ROP_Fax_Phone_Extension__c;
				//acc.ROP_Home_Phone_Country_Code__c = temp.ROP_Home_Phone_Country_Code__c;
				//acc.ROP_Business_Phone_Country_Code__c = temp.ROP_Business_Phone_Country_Code__c;
				//acc.ROP_Mobile_Country_Code__c = temp.ROP_Mobile_Phone_Country_Code__c;
				//acc.ROP_Fax_Country_Code__c = temp.ROP_Fax_Phone_Country_Code__c;
				acc.ROP_Email_1__c = temp.ROP_Email__c;
				acc.ROP_Seat_Preference__c = temp.ROP_Seat_Preference__c;
				acc.ROP_Favorite_Food__c = temp.ROP_Food_Preference__c;
				if (temp.ROP_Gender__c == 'M') {
					acc.Gender__c = 'Male';
				} else if (temp.ROP_Gender__c == 'F') {
					acc.Gender__c = 'Female';
				}


				mem.Name = temp.ROP_Number__c;
				mem.Airline__c = 'TG';
				mem.EXTMember__c = mem.Airline__c + '_' + mem.Name;
				mem.Favorite_Food__c = temp.ROP_Food_Preference__c;
				mem.Language__c = temp.ROP_Language__c;
				mem.Seat_Preference__c = temp.ROP_Seat_Preference__c;
				if (temp.ROP_Status__c == 'AC') {
					mem.Status__c = 'Active';
				} else if (temp.ROP_Status__c == 'IN') {
					mem.Status__c = 'Inactive';
				} else if (temp.ROP_Status__c == 'DE') {
					mem.Status__c = 'Dead';
				} else if (temp.ROP_Status__c == null) {
					mem.Status__c = 'Closed';
				}

				if (accountID != null) {
					acc.Id = accountID;
					mem.AccountId__c = acc.Id;
					mem.Id = memId;
					existingAccount.put(temp.ROP_Number__c, acc);
					existingMembership.put(temp.ROP_Number__c, mem);
				} else {
					newAccount.put(temp.ROP_Number__c, acc);
					newMembership.put(temp.ROP_Number__c, mem);
				}
			}
			System.debug('Amount of existingAccount:----' + existingAccount.size());
			System.debug('Amount of existingMembership:----' + existingMembership.size());
			System.debug('Amount of newAccount:----' + newAccount.size());
			System.debug('Amount of newMembership:----' + newMembership.size());

			//Database.SaveResult[] existingAccResult = Database.update(existingAccount.values(), true);
			update existingAccount.values();
			//Database.SaveResult[] existingMemResult = Database.update(existingMembership.values(), true);
			update existingMembership.values();
			//Database.SaveResult[] newAccResult = Database.insert(newAccount.values(), true);
			insert newAccount.values();
			//loop to add account id to account lookup field in membership
			for (Account a : newAccount.values()) {
				newMembership.get(a.ROP_Number__c).AccountId__c = a.Id;
			}
			//Database.SaveResult[] newMemResult = Database.insert(newMembership.values(), true);
			insert newMembership.values();

			delete[SELECT Id from TempPassenger__c LIMIT 8000];
			//delete tempPassengerList;
		}
	}
}