public class CaseTriggerHandler extends TriggerHandler {
  private CaseTriggerHelper helper;
  public CaseTriggerHandler() {
    this.setMaxLoopCount(3);
    helper = (new CaseTriggerHelper((List<Case>) Trigger.new));
  }
  protected override void beforeInsert() {
    helper.validateCases();
  }
  protected override void afterUpdate() {
    helper.registerAttendees();
  }
}
