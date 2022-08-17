@isTest
public class MockCaseTriggerHelper implements ICaseTriggerHelper {
  public Boolean isRegisterAttendeesCalled = false;
  public Boolean isValidateCasesCalled = false;
  public void validateCases() {
    isValidateCasesCalled = true;
  }
  public void registerAttendees() {
    isRegisterAttendeesCalled = true;
  }
}
