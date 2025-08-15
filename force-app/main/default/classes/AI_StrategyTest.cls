@isTest
public with sharing class AI_StrategyTest {

  private static PromptSetting__mdt getSettings(String psDeveloperName){
    return [SELECT Id, DeveloperName, ApexClassName__c 
            FROM PromptSetting__mdt 
            WHERE DeveloperName = :psDeveloperName 
            LIMIT 1];
  }

  @isTest
  private static void noInputTest(){
    // Call the InvocableMethod with no input
    Test.startTest();
    try {
      AI_Strategy.invokeAiFromFlow(new List<AI_Strategy.FlowInput>());
    } catch (AI_Strategy.AIStrategyException e) {
      Assert.isTrue(e.getMessage().startsWith('Invalid input data'), 'Exception should have been thrown for no input');
    }
    Test.stopTest();
  }

  @IsTest
  static void invalidModeTest() {
    // Create a test FlowInput record
    AI_Strategy.FlowInput input = new AI_Strategy.FlowInput();
    input.mode = 'TestMode';
    input.prompt = 'TestPrompt';
    input.previousResponse = 'TestPreviousResponse';
    input.messagesString = 'TestMessagesString';
    input.includeHistory = true;

    // Call the InvocableMethod
    Test.startTest();
    try{
      AI_Strategy.invokeAiFromFlow(new List<AI_Strategy.FlowInput>{input});
    } catch (AI_Strategy.AIStrategyException e) {
      Assert.isTrue(e.getMessage().startsWith('No configuration found for prompt'), 'Exception should have been thrown for invalid mode');
    }
    Test.stopTest();
  }

  @IsTest
  static void missingConfigurationTest() {
    AI_Strategy.FlowInput input = new AI_Strategy.FlowInput();
    input.mode = 'Sentiment_Analysis';
    input.prompt = 'TestPrompt';

    // Call the InvocableMethod
    Test.startTest();
    try{
      AI_Strategy.invokeAiFromFlow(new List<AI_Strategy.FlowInput>{input});
    } catch (AI_Strategy.AIStrategyException e) {
      Assert.isTrue(e.getMessage().startsWith('Incomplete configuration for prompt:'), 'Exception should have been thrown for incomplete configuration');
    }
    Test.stopTest();
  }

  @IsTest
  static void testGetPromptSettings() {
   
    PromptSetting__mdt ps = getSettings('NonQualityReview');
    Test.startTest();
    PromptSetting__mdt result = AI_Strategy.getPromptSettings('NonQualityReview');
    Test.stopTest();

    // Assert the result
    Assert.areEqual(ps.Id, result.Id, 'Expected the same record to be returned');
  }

  @IsTest
  static void testApiFailure() {
    // Create a test FlowInput record
    AI_Strategy.FlowInput input = new AI_Strategy.FlowInput();
    input.mode = 'NonQualityReview';
    input.prompt = 'There was a problem with the parts received that was damaged';
    // Call the InvocableMethod
    Test.startTest();
    try{
      AI_Strategy.invokeAiFromFlow(new List<AI_Strategy.FlowInput>{input});
    } catch (AI_NQ_Assist.AI_NQ_AssistException e) {
      Assert.isTrue(e.getMessage().startsWith('Impossible to get chat completion from the API'), 'Exception should have been thrown for API failure');
    }
  }

  @IsTest
  static void testInvokeAiFromFlow() {
    // Create a test FlowInput record
    AI_Strategy.FlowInput input = new AI_Strategy.FlowInput();
    input.mode = 'NonQualityReview';
    input.prompt = 'There was a problem with the parts received that was damaged';
    // Set mock callout class
    String mockJsonResponse = '{"choices":[{"message":{"content":"{ \\"rating\\": \\"2.5\\", \\"reasoning\\": \\"Documentation lacks clarity on installation steps.\\", \\"suggestions\\": \\"Include specific details and actionable improvements.\\", \\"language\\": \\"en\\", \\"suggestedExplanation\\": \\"Documentation is missing key installation steps.\\", \\"suggestedResolution\\": \\"Add detailed instructions for all parts.\\" }"}}]}';
    MockHttpResponses mockResponse = new MockHttpResponses(200, 'OK', mockJsonResponse);
    mockResponse.setHeaders(new Map<String, String>{'Content-Type' => 'application/json'});
    Test.setMock(HttpCalloutMock.class, mockResponse);
    // Call the InvocableMethod
    Test.startTest();
    List<List<String>> result = AI_Strategy.invokeAiFromFlow(new List<AI_Strategy.FlowInput>{input});
    Test.stopTest();

    // Assert the result
    Assert.isNotNull(result, 'Result should not be null');
    Assert.isTrue(result.size() > 0, 'Result should contain at least one list');
  }
}