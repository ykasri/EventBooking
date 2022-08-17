public class ExternalSystemService {
  public static final String WEBSERVICE_URL = 'https://th-apex-http-callout.herokuapp.com/animals';

  @future(callout=true)
  public static void registerAttendees(ID accountID) {
    for (Account account : [SELECT Id FROM Account WHERE id = :accountID]) {
      for (Contact contact : [
        SELECT Id, Name, Email, AccountId
        FROM Contact
        WHERE AccountId = :accountID
      ]) {
        String jsonBody = buildJsonBody(contact);
        HttpResponse response = sendHttpRequest(jsonBody);
        if (response.getStatusCode() == 201) {
          notifyAttendeeByEmail(contact); // Everything went as expected.
        } else {
          logResponse(response);
        }
      }
    }
  }

  private static String buildJsonBody(Contact contact) {
    JSONGenerator jsonGenerator = JSON.createGenerator(true);
    jsonGenerator.writeStartObject();
    jsonGenerator.writeStringField('name', contact.Name);
    if (String.isNotBlank(contact.Email)) {
      jsonGenerator.writeStringField('email', contact.Email);
    }
    jsonGenerator.writeEndObject();
    return jsonGenerator.getAsString();
  }

  private static HttpResponse sendHttpRequest(String jsonBody) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(WEBSERVICE_URL);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    // Set the body as a JSON object
    request.setBody(jsonBody);
    HttpResponse response = http.send(request);
    return response;
  }

  private static void postRequestThenNotifyByEmail() {
  }

  public static void notifyAttendeeByEmail(Contact contact) {
    SendEmailQueueable updateJob = new SendEmailQueueable(contact);
    ID jobID = System.enqueueJob(updateJob);
  }

  public static void logResponse(HttpResponse response) {
    Log.error(
      'The status code returned was not expected: ' +
      response.getStatusCode() +
      ' ' +
      response.getStatus()
    );
  }
}
