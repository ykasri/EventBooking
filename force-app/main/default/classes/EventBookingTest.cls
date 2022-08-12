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
    System.assert(result.getErrors().size() > 0);
    System.assertEquals(
      CaseTriggerHelper.ERROR_ACCOUNT_REQUIRED,
      result.getErrors()[0].getMessage()
    );
  }

  @isTest
  public static void refuseCaseCreationWhenNoContactIsAttachedToAnAccount() {
    // Given
    Account account = new Account(Name = 'Salesforce');
    insert account;

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
    Account account = insertAccountWithContacts('Salesforce', 3);
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

  private static Account insertAccountWithContacts(
    String accountName,
    Integer contactsCount
  ) {
    Account account = new Account(Name = accountName);
    insert account;

    Contact[] contacts = new List<Contact>();
    for (Integer i = 1; i <= contactsCount; i++) {
      contacts.add(
        new Contact(LastName = 'Contact ' + i, AccountId = account.ID)
      );
    }
    insert contacts;

    return account;
  }

  @isTest
  public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanThreeForPhoneCases() {
    // Given
    Account account = insertAccountWithContacts('Salesforce', 4);
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
    Account account = insertAccountWithContacts('Salesforce', 1);
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
    Account account = insertAccountWithContacts('Salesforce', 3);
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
}
