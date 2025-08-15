/**
 * AI_Case_Routing is a Salesforce Apex class that extends AI_MsOpenAiCompletion and implements the IAI_ChatCompletion interface.
 * It is designed to determine the most probable country of origin for a case by leveraging AI chat completion services,
 * using the language and content of the case description as input. The class handles API communication, error management,
 * and logging, providing a concrete implementation for routing cases based on AI-driven language analysis.
 */
public with sharing class AI_Case_Routing extends AI_MsOpenAiCompletion implements  IAI_ChatCompletion{
  
  public class AI_Case_RoutingException extends Exception {}

  public Map<String,String> getChatCompletion(Map<String,Object> inputs){
    //Guardrails
    if (inputs == null || inputs.isEmpty() || !inputs.containsKey('settings') || !inputs.containsKey('prompt')) {
      throw new AI_Case_RoutingException('Invalid input data for chat completion');
    }
    // Set context variables
    super.init(inputs);
    // Build request
    HttpRequest request = super.buildHttpRequest();
    Http http = new Http();
    HttpResponse response;
    try {
      response = http.send(request);
       // Parse the response and return the content attribute
      String jsonResponse = super.parseResponse(response);
      returnMap.put('probableCountry',jsonResponse);
      // Create log
      logAiEvent(response);
      return returnMap;

    } catch (Exception e) {
      Logger.error('AI Case routing GEN AI Api error',e);
      Logger.saveLog();
      Logger.flushBuffer();
      throw new AI_Case_RoutingException('Impossible to get chat completion from the API: '+e.getMessage());
    }
  }
}