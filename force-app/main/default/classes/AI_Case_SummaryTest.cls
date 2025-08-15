@isTest
public with sharing class AI_Case_SummaryTest {
 

  private static PromptSetting__mdt getSettings(String psDeveloperName) {
    return [SELECT Id, DeveloperName, Instructions__c, Named_Credential__c, 
                    ApexClassName__c,Temprature__c, Top_P__c, Frequency_Penalty__c,
                    Presence_Penalty__c, Max_Tokens__c  
            FROM PromptSetting__mdt 
            WHERE DeveloperName = :psDeveloperName 
            LIMIT 1];
  }

  @isTest
  static void testValidInputs() {
    PromptSetting__mdt ps = getSettings('Case_Summary_Comprehensive');
    Map<String, Object> inputs = new Map<String, Object>{
      'settings' => ps,
      'prompt' => 'This is a test prompt for Case Summary'
    };

    // Set mock callout class
    String mockJsonResponse = '{"choices":[{"message":{"content":"mockResponse"}}]}';
    MockHttpResponses mockResponse = new MockHttpResponses(200, 'OK', mockJsonResponse);
    mockResponse.setHeaders(new Map<String, String>{'Content-Type' => 'application/json'});
    Test.setMock(HttpCalloutMock.class, mockResponse);

    // Act
    AI_Case_Summary aiCaseSummary = new AI_Case_Summary();
    Map<String, String> result = aiCaseSummary.getChatCompletion(inputs);

    // Assert
    Assert.areEqual('mockResponse', result.get('caseSummary'), 'Invalid response from AI Case Summary comprehensive');
  }

  @isTest
  static void apiCallErrorTest() {
    PromptSetting__mdt ps = getSettings('Case_Summary_Comprehensive');
    Map<String, Object> inputs = new Map<String, Object>{
      'settings' => ps,
      'prompt' => 'This is a test prompt for Case Summary'
    };

    // Set mock callout class
    //this String will cause a deserialization error
    String invalidJsonResponse = '{"choices":[{"message":{"content":"Bad Request"}}}';
    MockHttpResponses mockResponse = new MockHttpResponses(400, 'Bad Request', invalidJsonResponse);
    mockResponse.setHeaders(new Map<String, String>{'Content-Type' => 'application/json'});
    Test.setMock(HttpCalloutMock.class, mockResponse);

    AI_Case_Summary aiCaseSummary = new AI_Case_Summary();
    try {
      Map<String, String> result = aiCaseSummary.getChatCompletion(inputs);
    } catch (AI_Case_Summary.AI_Case_SummaryException e) {
      // Assert that the exception is thrown
      Assert.isTrue(e.getMessage().startsWith('Impossible to get chat completion from the API'), 'Incorrect error thrown');
    }
  }

  @isTest
  static void testInvalidInputs() {
    // Test with null inputs
    AI_Case_Summary aiCaseSummary = new AI_Case_Summary();
    try {
      aiCaseSummary.getChatCompletion(null);
    } catch (AI_Case_Summary.AI_Case_SummaryException e) {
      Assert.areEqual('Invalid input data for chat completion', e.getMessage(), 'Incorrect error thrown for null inputs');
    }
  }
}