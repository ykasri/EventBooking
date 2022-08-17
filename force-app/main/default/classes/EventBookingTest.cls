@isTest
public class EventBookingTest {
  @isTest
  public static void refuseCaseCreationWhenAnAccountIsNotAttachedToACase() {
    // Given
    Case phoneCase = new Case(
      Origin = 'Phone',
      Subject = 'Event Booking',
      Description = 'Book Spots'
    );

    // When
    Test.startTest();
    Database.SaveResult result = Database.insert(phoneCase, false);
    Test.stopTest();

    // Then
    System.assert(!result.isSuccess());
    System.assert(!result.getErrors().isEmpty());
    System.assertEquals(
      CaseTriggerHelper.ERROR_ACCOUNT_REQUIRED,
      result.getErrors()[0].getMessage()
    );
  }

  @isTest
  public static void refuseCaseCreationWhenNoContactIsAttachedToAnAccount() {
    // Given
    SObject account = TestDataFactory.createSObject('Account');
    Case phoneCase = new Case(
      Origin = 'Phone',
      Subject = 'Event Booking',
      Description = 'Book Spots',
      AccountId = account.ID
    );

    // When
    Test.startTest();
    Database.SaveResult result = Database.insert(phoneCase, false);
    Test.stopTest();

    // Then
    System.assert(!result.isSuccess());
    System.assert(!result.getErrors().isEmpty());
    System.assertEquals(
      CaseTriggerHelper.ERROR_CONTACTS_REQUIRED,
      result.getErrors()[0].getMessage()
    );
  }

  @isTest
  public static void bookEventFromPhone() {
    // Given
    Account account = insertAccountWithContacts(3);
    Case phoneCase = new Case(
      Origin = 'Phone',
      Subject = 'Event Booking',
      Description = 'Book Spots for Company A1 & their 3 employees',
      AccountId = account.ID
    );

    // When
    Test.startTest();
    Database.SaveResult result = Database.insert(phoneCase, false);
    Test.stopTest();

    // Then
    System.assert(result.isSuccess());
  }

  private static Account insertAccountWithContacts(Integer contactsCount) {
    Account account = (Account) TestDataFactory.createSObject('Account');
    TestDataFactory.createSObjectList(
      'Contact',
      new Map<String, Object>{ 'AccountId' => account.Id },
      contactsCount
    );
    return account;
  }

  @isTest
  public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanThreeForPhoneCases() {
    // Given
    Account account = insertAccountWithContacts(4);
    Case phoneCase = new Case(
      Origin = 'Phone',
      Subject = 'Event Booking',
      Description = 'Book Spots for Company A1 & their 4 employees',
      AccountId = account.ID
    );

    // When
    Test.startTest();
    Database.SaveResult result = Database.insert(phoneCase, false);
    Test.stopTest();

    // Then
    System.assert(!result.isSuccess());
    System.assert(!result.getErrors().isEmpty());
    System.assertEquals(
      CaseTriggerHelper.ERROR_PHONE_MAX_ATTENDEES,
      result.getErrors()[0].getMessage()
    );
  }

  @isTest
  public static void bookEventFromTheWeb() {
    // Given
    Account account = insertAccountWithContacts(1);
    Case webCase = new Case(
      Origin = 'Web',
      Subject = 'Event Booking',
      Description = 'Book One Spot for Company A1',
      AccountId = account.ID
    );

    // When
    Test.startTest();
    Database.SaveResult result = Database.insert(webCase, false);
    Test.stopTest();

    // Then
    System.assert(result.isSuccess());
  }

  @isTest
  public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanOneForWebCases() {
    // Given
    Account account = insertAccountWithContacts(3);
    Case webCase = new Case(
      Origin = 'Web',
      Subject = 'Event Booking',
      Description = 'Book Spots for Company A1 & their 3 employees',
      AccountId = account.ID
    );

    // When
    Test.startTest();
    Database.SaveResult result = Database.insert(webCase, false);
    Test.stopTest();

    // Then
    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
    System.assertEquals(
      CaseTriggerHelper.ERROR_WEB_MAX_ATTENDEES,
      result.getErrors()[0].getMessage()
    );
  }

  @isTest
  public static void notifyContactAfterCaseClosed() {
    // Arrange
    Account account = insertAccountWithContacts(3);
    Case newCase = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{ 'AccountId' => account.Id }
    );
    MockCaseTriggerHelper helper = new MockCaseTriggerHelper();
    TriggerHandler handler = new CaseTriggerHandler(helper);
    handler.setTriggerContext('after update', true);

    // Act
    Test.startTest();
    handler.run();
    Test.stopTest();

    // Assert
    // Task createdTask = [SELECT ID, WhatId, Subject FROM Task];
    // System.assert(createdTask.Subject.contains('Send Email To'));
    // System.assert(createdTask.WhatId == account.Id);
    System.assert(helper.isRegisterAttendeesCalled);
  }
}

/**
=== Apex Code Coverage by Class
CLASSES                PERCENT  UNCOVERED LINES  
─────────────────────  ───────  ─────────────────
CaseTriggerHelper      76%      13,14,30,53,55...
Log                    100%                      
ExternalSystemService  98%      55               
TriggerHandler         100%                      
CaseTriggerHandler     100%                      
CaseTrigger            100%   
 */

