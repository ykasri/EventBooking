public class ExternalSystemService {
  public static final String WEBSERVICE_URL = 'https://th-apex-http-callout.herokuapp.com/animals';

  public void registerAttendees(Case currentCase) {
    for (Account account : [
      SELECT Id
      FROM Account
      WHERE id = :currentCase.AccountId
    ]) {
      for (Contact contact : [
        SELECT Id, Name, Email, AccountId
        FROM Contact
        WHERE AccountId = :account.Id
      ]) {
        HttpResponse response = sendHttpRequest(contact);
        if (response.getStatusCode() == 201) {
          notifyAttendeeByEmail(contact); // Everything went as expected.
        } else {
          logResponse(response);
        }
      }
    }
  }

  private HttpResponse sendHttpRequest(Contact contact) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(WEBSERVICE_URL);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    // Set the body as a JSON object
    JSONGenerator jsonGenerator = JSON.createGenerator(true);
    jsonGenerator.writeStartObject();
    jsonGenerator.writeStringField('name', contact.Name);
    if (String.isNotBlank(contact.Email)) {
      jsonGenerator.writeStringField('email', contact.Email);
    }
    jsonGenerator.writeEndObject();
    request.setBody(jsonGenerator.getAsString());
    HttpResponse response = http.send(request);
    return response;
  }

  public void notifyAttendeeByEmail(Contact contact) {
    Task task = new Task();
    task.Subject = 'Send Email To' + contact.Name;
    task.Status = 'Open';
    task.Priority = 'Normal';
    task.WhatId = contact.AccountId;
    Database.SaveResult result = Database.insert(task);
    if (result.isSuccess()) {
      // Operation was successful, so get the ID of the record that was processed
      System.debug('Successfully inserted Task. Task ID: ' + task.Id);
    } else {
      // Operation failed, so get all errors
      for (Database.Error err : result.getErrors()) {
        System.debug('The following error has occurred.');
        System.debug(err.getStatusCode() + ': ' + err.getMessage());
        System.debug(
          'Task fields that affected this error: ' + err.getFields()
        );
      }
    }
  }

  public void logResponse(HttpResponse response) {
    System.debug(
      'The status code returned was not expected: ' +
      response.getStatusCode() +
      ' ' +
      response.getStatus()
    );
  }
}
