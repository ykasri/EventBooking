public class CaseTriggerHandler extends TriggerHandler {
  private ICaseTriggerHelper helper;
  public CaseTriggerHandler() {
    this(new CaseTriggerHelper((List<Case>) Trigger.new));
  }

  public CaseTriggerHandler(ICaseTriggerHelper helper) {
    this.setMaxLoopCount(3);
    this.helper = helper;
  }

  protected override void beforeInsert() {
    helper.validateCases();
  }
  protected override void afterUpdate() {
    helper.registerAttendees();
  }
}
