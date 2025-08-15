/**
 * AI_NQ_Assist is a concrete Apex class that extends AI_MsOpenAiCompletion and implements the IAI_ChatCompletion interface.
 * This class provides a specialized implementation for handling Non Quality AI Assistance scenarios.
 * Ths class is covered by the AI_StrategyTest class.
 * Inheritance:
 * - Inherits methods and properties from AI_MsOpenAiCompletion, enabling integration with external AI chat completion APIs.
 * 
 * Interface Implementation:
 * - Implements the getChatCompletion method as required by IAI_ChatCompletion, ensuring a consistent contract for chat completion functionality.
 * 
 * Responsibilities:
 * - Validates input parameters for chat completion requests.
 * - Prepares and sends HTTP requests to the AI service.
 * - Processes and deserializes API responses.
 * - Handles error logging and exception management.
 * 
 * Usage:
 * - Call getChatCompletion(Map<String, Object> inputs) with 'settings' and 'prompt' keys to obtain AI-generated responses.
 * - Throws AI_NQ_AssistException for invalid inputs or API failures.
 */
public with sharing class AI_NQ_Assist extends AI_MsOpenAiCompletion implements IAI_ChatCompletion {

  public class AI_NQ_AssistException extends Exception {}

  public Map<String,String> getChatCompletion(Map<String,Object> inputs){
    //Guardrails
    if (inputs == null || inputs.isEmpty() || !inputs.containsKey('settings') || !inputs.containsKey('prompt')) {
      throw new AI_NQ_AssistException('Invalid input data for chat completion');
    }
    //Set context variables
    super.init(inputs);
    //build request
    HttpRequest request = super.buildHttpRequest();
    Http http = new Http();
    HttpResponse response;
    try {
      response = http.send(request);
      //Process and Deserialize the JSON response
      String jsonResponse = super.parseResponse(response);
      // Convert parsed response to Map<String, Object>
      Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
      for(String key:parsedResponse.keySet()){
        returnMap.put(key,String.valueOf(parsedResponse.get(key)));
      }
      // Create log
      logAiEvent(response);
      return returnMap;

    } catch (Exception e) {
      Logger.error('AI NQ Assits GEN AI Api error',e);
      Logger.saveLog();
      Logger.flushBuffer();
      throw new AI_NQ_AssistException('Impossible to get chat completion from the API: '+e.getMessage());
    }
  }
}