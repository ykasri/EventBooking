@isTest
public class ExternalSystemServiceTest {
  @isTest
  static void testRegisterAttendees() {
    /// Arrange
    // Set mock callout class
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    ExternalSystemService service = new ExternalSystemService();
    // Prepare data
    SObject account = TestDataFactory.createSObject('Account');
    Contact contact = (Contact) TestDataFactory.createSObject(
      'Contact',
      new Map<String, Object>{
        'Name' => 'Contact 1',
        'AccountId' => account.Id
      }
    );
    Case newCase = (Case) TestDataFactory.createSObject(
      'Case',
      new Map<String, Object>{ 'AccountId' => account.Id }
    );

    /// ACT : Call method to test.
    // This causes a fake response to be sent
    // from the class that implements HttpCalloutMock.
    Test.startTest();
    service.registerAttendees(newCase);

    Map<String, String> sentBody = (Map<String, String>) JSON.deserializeUntyped(
      MockHttpResponseGenerator.receivedBody
    );

    Test.stopTest();

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
    System.assertEquals(
      contact.LastName,
      sentBody.get('Name'),
      'Name is parsed'
    );
    System.assertEquals(
      contact.Email,
      sentBody.get('Email'),
      'Email is parsed'
    );
  }
}
