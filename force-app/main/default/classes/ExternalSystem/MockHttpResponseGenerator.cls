@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
  public static Boolean hasCorrectHeaders;
  public static String receivedBody;
  static {
    hasCorrectHeaders = false;
    receivedBody = null;
  }

  private Integer returnStatus;
  public MockHttpResponseGenerator(Integer returnStatus) {
    this.returnStatus = returnStatus;
  }

  /* @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_http_testing_httpcalloutmock.htm */
  public HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    hasCorrectHeaders =
      request.getMethod() == 'POST' &&
      request.getEndpoint() == ExternalSystemService.WEBSERVICE_URL &&
      request.getHeader('Content-Type').startsWith('application/json');

    receivedBody = request.getBody();
    if (hasCorrectHeaders) {
      response.setStatusCode(returnStatus);
    }
    return response;
  }
}
