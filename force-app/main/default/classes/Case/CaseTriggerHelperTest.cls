@isTest
public class CaseTriggerHelperTest {
  @isTest
  static void validateCases_EmptyInput_Returns() {
    Case[] cases = new List<Case>();
    CaseTriggerHelper helper = new CaseTriggerHelper(cases);
    helper.validateCases();
  }

  @isTest
  static void validateCases_NoAccount_LogsError() {
    // Arrange
    TriggerHandler.bypass('CaseTriggerHandler');
    Case[] newCases = TestDataFactory.createSObjectList('Case', 2);
    TriggerHandler.clearBypass('CaseTriggerHandler');
    CaseTriggerHelper helper = new CaseTriggerHelper(newCases);

    // Act
    helper.validateCases();
    // Assert
    for (Case newCase : newCases) {
      Database.Error[] errors = newCase.getErrors();
      System.assert(errors.size() == 1);
      System.assertEquals(
        CaseTriggerHelper.ERROR_ACCOUNT_REQUIRED,
        errors[0].message
      );
    }
  }

  @isTest
  static void casesWithSameAccount_UseSingletonForContacts() {
    TriggerHandler.bypass('CaseTriggerHandler');
    Account account = (Account) TestDataFactory.createSObject('Account');
    Case[] cases = TestDataFactory.createSObjectList(
      'Case',
      new Map<String, Object>{ 'AccountId' => account.Id },
      2
    );
    Account account2 = (Account) TestDataFactory.createSObject('Account');
    Case[] cases2 = TestDataFactory.createSObjectList(
      'Case',
      new Map<String, Object>{ 'AccountId' => account2.Id },
      2
    );
    TriggerHandler.clearBypass('CaseTriggerHandler');
    cases.addAll(cases2);
    CaseTriggerHelper helper = new CaseTriggerHelper(cases);

    Test.startTest();
    helper.validateCases();
    Integer numberOfQueries = Limits.getQueries();
    Test.stopTest();

    System.assert(
      numberOfQueries == 1,
      'Only one call to DB should be performed, b/c the result is being cached'
    );
    for (Case newCase : cases) {
      Database.Error[] errors = newCase.getErrors();
      System.assert(errors.size() == 1);
      System.assertEquals(
        CaseTriggerHelper.ERROR_CONTACTS_REQUIRED,
        errors[0].message
      );
    }
  }
}
