public class PostRequestQueueable implements Queueable, Database.AllowsCallouts {
  public static final String WEBSERVICE_URL = 'https://th-apex-http-callout.herokuapp.com/animals';
  public static final Integer STATUS_CREATED_OK = 201;

  @testVisible
  private static Boolean isTestRunning = false;

  private Contact contact;

  public PostRequestQueueable(Contact contact) {
    this.contact = contact;
  }

  public void execute(QueueableContext context) {
    String jsonBody = buildJsonBody();
    HttpResponse response = postRequest(jsonBody);
    if (response.getStatusCode() == STATUS_CREATED_OK) {
      notifyByEmail();
    } else {
      logResponse(response);
    }
  }

  private String buildJsonBody() {
    JSONGenerator jsonGenerator = JSON.createGenerator(true);
    jsonGenerator.writeStartObject();
    if (String.isNotBlank(contact.Name)) {
      jsonGenerator.writeStringField('name', contact.Name);
    }
    if (String.isNotBlank(contact.Email)) {
      jsonGenerator.writeStringField('email', contact.Email);
    }
    jsonGenerator.writeEndObject();
    return jsonGenerator.getAsString();
  }

  private static HttpResponse postRequest(String jsonBody) {
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

  @testVisible
  private void notifyByEmail() {
    if (!isTestRunning) {
      SendEmailQueueable sendEmailJob = new SendEmailQueueable(contact);
      System.enqueueJob(sendEmailJob);
    }
  }

  private static void logResponse(HttpResponse response) {
    Log.error(
      'The status code returned was not expected: ' +
      response.getStatusCode() +
      ' ' +
      response.getStatus()
    );
  }
}
