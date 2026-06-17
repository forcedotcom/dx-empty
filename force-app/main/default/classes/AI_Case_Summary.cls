/*This class is designed for the specific use case of case summarization.
 * It extends the base functionality provided by the parent class, allowing for
 * customized behavior tailored to summarizing Salesforce Case records.
 * Additionally, it implements an interface to ensure that all required methods
 * for case summarization are present and correctly structured.
 */
public with sharing class AI_Case_Summary extends AI_MsOpenAiCompletion implements IAI_ChatCompletion {
  
  public class AI_Case_SummaryException extends Exception {}

  public Map<String,String> getChatCompletion(Map<String,Object> inputs){
    //Guardrails
    if (inputs == null || inputs.isEmpty() || !inputs.containsKey('settings') || !inputs.containsKey('prompt')) {
      throw new AI_Case_SummaryException('Invalid input data for chat completion');
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
      returnMap.put('caseSummary',jsonResponse);
      // Create log
      logAiEvent(response);
      return returnMap;

    } catch (Exception e) {
      Logger.error('AI Case Summarry GEN AI Api error',e);
      Logger.saveLog();
      Logger.flushBuffer();
      throw new AI_Case_SummaryException('Impossible to get chat completion from the API: '+e.getMessage());
    }
  }
}