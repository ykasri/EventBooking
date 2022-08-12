trigger CaseBeforeInsertTrigger on Case(before insert) {
  CaseTriggerHelper helper = new CaseTriggerHelper(Trigger.New);
  helper.validateCases();
}
