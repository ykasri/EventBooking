@isTest
public class CaseTriggerHelperTest {
  @isTest
  static void validateCases_EmptyInput_Returns() {
    Case[] cases = new List<Case>();
    CaseTriggerHelper helper = new CaseTriggerHelper(cases);
    helper.validateCases();
  }
}
