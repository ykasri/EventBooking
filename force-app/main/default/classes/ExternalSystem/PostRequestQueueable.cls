public with sharing class PostRequestQueueable {
  private final Integer STATUS_CREATED_OK = 201;
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
    jsonGenerator.writeStringField('name', contact.Name);
    if (String.isNotBlank(contact.Email)) {
      jsonGenerator.writeStringField('email', contact.Email);
    }
    jsonGenerator.writeEndObject();
    return jsonGenerator.getAsString();
  }

  private static Boolean postRequest(String jsonBody) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(WEBSERVICE_URL);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    // Set the body as a JSON object
    request.setBody(jsonBody);
    HttpResponse response = http.send(request);
    return response.getStatusCode() == STATUS_CREATED_OK;
  }

  private void notifyByEmail() {
    SendEmailQueueable updateJob = new SendEmailQueueable(contact);
    System.enqueueJob(updateJob);
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
