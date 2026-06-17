@isTest
global with sharing class MockHttpResponses implements HttpCalloutMock {
  private Integer statusCode;
  private String statusMessage;
  private String responseBodyString;
  private Map<String,String> headers = new Map<String,String>();

  global MockHttpResponses(Integer statusCode, String statusMessage, String responseBodyString) {
    this.statusCode = statusCode;
    this.statusMessage = statusMessage;
    this.responseBodyString = responseBodyString;
  }

  global void setHeaders(Map<String, String> headers) {
    this.headers = headers;
  }

  global HTTPResponse respond(HTTPRequest req) {
    // Create a fake response
    HttpResponse res = new HttpResponse();
    res.setStatusCode(statusCode);
    res.setStatus(statusMessage);
    res.setBody(responseBodyString);
    if (!headers.isEmpty()) {
      for (String key : headers.keySet()) {
        res.setHeader(key, headers.get(key));
      }
    }
    return res;
  }
}