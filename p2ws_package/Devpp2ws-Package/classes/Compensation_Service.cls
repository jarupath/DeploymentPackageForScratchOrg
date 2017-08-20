public with sharing class Compensation_Service {
	public Compensation_Service() {
		
	}

	public static Decimal getAmountPerPassenger(Compensation__c compensation, Boolean displayTHB) {
		Decimal amount = 0;
		if(displayTHB) {
			if(compensation.Currency__c != 'THB' && compensation.ROE__c != null) {
				amount = compensation.Amount__c * compensation.ROE__c;
			} else {
				amount = compensation.Amount__c;
			}
		} else {
			amount = compensation.Amount__c;
		}
		return amount;
	}

	public static Boolean validateAccountNumberAndAccountCenter(List<Compensation__c> compensations) {
        String previousAccountNumber;
        String previousAccountCenter;
		for(Compensation__c eachCompensation : compensations) {
            Boolean isError = false;
            if(String.isNotBlank(previousAccountNumber)) {
                if(previousAccountNumber != eachCompensation.Compensation_Account_Number__c) {
                	return false;
                }
            }

            if(String.isNotBlank(previousAccountCenter)) {
                if(previousAccountCenter != eachCompensation.Compensation_Account_Center__c) {
                	return false;
                }
            }

            previousAccountNumber = eachCompensation.Compensation_Account_Number__c;
            previousAccountCenter = eachCompensation.Compensation_Account_Center__c;
        }
        return true;
	}
}