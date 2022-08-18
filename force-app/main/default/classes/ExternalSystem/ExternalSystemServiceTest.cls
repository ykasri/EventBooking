@isTest
public class ExternalSystemServiceTest {
  @isTest
  static void testRegisterAttendees() {
    /// Arrange
    // Set mock callout class
    Integer returnStatus = 201;
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(returnStatus)
    );
    PostRequestQueueable.isTestRunning = true;
    // Prepare data
    Case newCase = createCaseWithAccountAndContact();

    /// Act
    Test.startTest();
    ExternalSystemService.registerAttendees(newCase.AccountId);
    Test.stopTest();
    Map<String, Object> sentBody = (Map<String, Object>) JSON.deserializeUntyped(
      MockHttpResponseGenerator.receivedBody
    );

    /// ASSERT
    System.assert(
      MockHttpResponseGenerator.hasCorrectHeaders,
      'Check the headers'
    );
    System.assert(
      String.isNotBlank(MockHttpResponseGenerator.receivedBody),
      'Request Body should not be empty'
    );
    System.assert(sentBody != null, 'Should send a valid JSON body');
    System.assert(sentBody.get('name') != null, 'Name is parsed');
  }

  private static Case createCaseWithAccountAndContact() {
    SObject account = TestDataFactory.createSObject('Account');
    Contact contact = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'AccountId' => account.Id,
        'Email' => 'test@example.com'
      }
    );
    Case newCase = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{ 'AccountId' => account.Id }
    );
    return newCase;
  }
  @isTest
  static void registerAttendees_LogsError_WhenStatusNot201() {
    // Arrange
    Integer returnStatus = 500;
    Case newCase = createCaseWithAccountAndContact();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(returnStatus)
    );

    // Act
    Test.startTest();
    ExternalSystemService.registerAttendees(newCase.AccountId);
    Test.stopTest();

    // Assert
    for (Log__c errorLog : [SELECT Id, Message__c FROM Log__c LIMIT 1]) {
      System.assert(errorLog.Message__c != null);
    }
  }

  @isTest
  static void PostRequestQueueable_DoesInvoke_SendEmailQueueableIfSuccess() {
    // Arrange
    Contact contact = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{ 'Email' => 'test@example.tom' }
    );
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(PostRequestQueueable.STATUS_CREATED_OK)
    );

    // Act
    Test.startTest();
    Queueable postRequestJob = new PostRequestQueueable(contact);
    postRequestJob.execute(null);
    Test.stopTest();

    // Assert
    List<AsyncApexJob> jobs = [
      SELECT Id, NumberOfErrors, Status, ApexClassId, ApexClass.Name
      FROM AsyncApexJob
      WHERE JobType = 'Queueable'
    ];
    System.assert(jobs.size() == 1);
    for (AsyncApexJob job : jobs) {
      System.assert(job.NumberOfErrors == 0);
      System.assert(job.Status == 'Completed');
      System.assert(job.ApexClass.Name == SendEmailQueueable.class.getName());
    }
  }
}
