trigger PassengerTrigger on Passenger__c (before insert, before update) {
	if (TriggerActivator.isTriggerActivated(TriggerActivator.PASSENGER_TRIGGER)) {
		if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
			PassengerService.populateFullNationalityName(Trigger.new);
			PassengerService.populatePaxKeyTXT(Trigger.new);
			PassengerService.changePassengersSeat(Trigger.oldMap, Trigger.new);
			PassengerService.formatPassengerNameFromList(Trigger.new);
			PassengerService.convertSubTierToActualTier(Trigger.new);
		}
	}
}