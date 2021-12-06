trigger OppTrigger on Opportunity(before insert, before update) {
    OppTriggerHandler.validateFieldAcc(Trigger.new, Trigger.old, Trigger.operationType);
}
