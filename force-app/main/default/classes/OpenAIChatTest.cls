@isTest
private class OpenAIChatTest {
  @isTest
  static void testGetChatCompletion() {
    // Create a mock response for the callout
    String mockResponse = '{"choices":[{"message":{"content":"testResponse"}}]}';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(mockResponse)
    );

    // Test input variables
    OpenAIChat.ChatInput input = new OpenAIChat.ChatInput();
    input.mode = 'Salesforce_Developer';
    input.prompt = 'testPrompt';
    input.includeHistory = false;
    input.temperature = 0.8;

    // Call the method under test
    List<OpenAIChat.ChatOutput> outputs = OpenAIChat.getChatCompletion(
      new List<OpenAIChat.ChatInput>{ input }
    );

    // Assert the results
    System.assertEquals(1, outputs.size());
    OpenAIChat.ChatOutput output = outputs[0];
    System.assertNotEquals(null, output.res);
    System.assertNotEquals(null, output.messagesString);
  }

  // Inner class that implements the HttpCalloutMock interface
  private class MockHttpResponseGenerator implements HttpCalloutMock {
    private String mockResponse;

    public MockHttpResponseGenerator(String mockResponse) {
      this.mockResponse = mockResponse;
    }

    public HTTPResponse respond(HTTPRequest request) {
      // Create a mock HTTP response
      HTTPResponse response = new HTTPResponse();
      response.setStatusCode(200);
      response.setBody(mockResponse);
      return response;
    }
  }
}
