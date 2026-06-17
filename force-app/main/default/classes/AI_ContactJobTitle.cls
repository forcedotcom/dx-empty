/*current implementation is not meant to be invoked from Flow but from apex trigger
 * @summary
 * This class extends the AI_MsOpenAiCompletion abstract class and implements the IAI_ChatCompletion interface.
 * It is designed to determine and assign the Marketing Job Title for Contact records by leveraging the OpenAI API.
 * The class validates AI-generated job titles against the allowed picklist values and ensures only valid titles
 * are returned for each Contact.
 */
public with sharing class AI_ContactJobTitle extends AI_MsOpenAiCompletion implements IAI_ChatCompletion {
  
  private Boolean errorLogged = false;
  public List<String> allowedContactJobTitles;
  
  public List<String> getAllowedContactJobTitles() {
    if (allowedContactJobTitles == null) {
      allowedContactJobTitles = new List<String>();
      Schema.DescribeFieldResult fieldDescribe = Contact.Marketing_Job_Title__c.getDescribe();
      List<Schema.PicklistEntry> pickEntryList = fieldDescribe.getPicklistValues();
      for (Schema.PicklistEntry pickEntry : pickEntryList) {
        allowedContactJobTitles.add(pickEntry.getValue());
      }
    }
    return allowedContactJobTitles;
  }


  public Map<String,String> getChatCompletion(Map<String,Object> inputs){
    //Guardrails
    if (inputs == null || inputs.isEmpty() || !inputs.containsKey('settings') || !inputs.containsKey('prompt')) {
      Logger.error('AI Contact Job Title error: Invalid input data for AI chat completion');
      Logger.debug('Inputs: ' + inputs);
      Logger.saveLog();
      Logger.flushBuffer();
    }
    //Set context variables
    super.init(inputs);
    HttpRequest request = super.buildHttpRequest();
    Http http = new Http();
    HttpResponse response;
    try {
      response = http.send(request);
      // Parse the response and return the content attribute
      String jsonResponse = super.parseResponse(response);
      //expected output is list of {"SF Contact Id": "jobTitle"}
      //verify that the Id is a valid Contact Id and the job title returned by AI is a valid picklist value as well
      Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
      List<String> validContactJobTitles = getAllowedContactJobTitles();
      Set<String> contIdSet = parsedResponse.keySet();
      for(String key:contIdSet){
        Id contId = (Id) key;
        String jobTitle = (String) parsedResponse.get(key);
        if(contId.getSobjectType() == Contact.SObjectType && validContactJobTitles.contains(jobTitle)){
          returnMap.put(key, jobTitle);
        } else {
          Logger.error('AI Contact Job Title error: Invalid Contact Id or Invalid Job Title');
          Logger.debug('Id: ' + key);
          Logger.debug('Job Title: ' + parsedResponse.get(key));
          errorLogged = true;
        }
      }
      if(errorLogged){
        Logger.saveLog();
        Logger.flushBuffer();
      }
      // Create log
      logAiEvent(response);
    } catch (Exception e) {
      Logger.error('AI Contact job title GEN AI Api error',e);
      Logger.saveLog();
      Logger.flushBuffer();
    }
    return returnMap;
  }
}