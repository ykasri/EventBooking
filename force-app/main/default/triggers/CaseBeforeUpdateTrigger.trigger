trigger CaseBeforeUpdateTrigger on Case(after update) {
  CaseTriggerHelper helper = new CaseTriggerHelper(Trigger.New);
  helper.registerAttendees();
}
