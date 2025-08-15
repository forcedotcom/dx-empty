/*
 * AI_Strategy class orchestrates AI chat completions by dynamically selecting and invoking
 * an implementation of the IAI_ChatCompletion interface based on configuration stored in PromptSetting__mdt.
 * 
 * - It exposes methods for both Flow (@InvocableMethod) and Lightning Web Component (@AuraEnabled) integrations.
 * - For Flows, it receives input, looks up the appropriate Apex class to handle the AI prompt (dependency injection via class name in metadata),
 *   instantiates it at runtime, and delegates the chat completion logic.
 * - This design allows new AI strategies to be added or swapped without code changes, simply by updating metadata.
 * - Includes error handling for missing or incomplete configurations.
 * - LWC integration is currently a placeholder and not yet implemented.
 */
public with sharing class AI_Strategy {

  public class FlowInput {
    @InvocableVariable(required=true)
    public String mode;
    @InvocableVariable(required=true)
    public String prompt;
    @InvocableVariable
    public String previousResponse;
    @InvocableVariable
    public String messagesString;
    @InvocableVariable
    public Boolean includeHistory;
  }

  public class LWCInput {
    public String mode;
    public String prompt;
    public String previousResponse;
    public String messagesString;
    public Boolean includeHistory;
  }

  public class AIStrategyException extends Exception {}

  @InvocableMethod(label='Invoke GEN AI from Flow' description='Sends prompt to GENAI and gets the response.' category='GENAI')
  public static List<List<String>> invokeAiFromFlow(List<FlowInput> inputs) {
    //Guardrail
    if (inputs == null || inputs.isEmpty() || inputs[0] == null) {
      throw new AIStrategyException('Invalid input data');
    }
    
    FlowInput input = inputs[0];
    //Determine Apex class to instantiate
    PromptSetting__mdt ps = getPromptSettings(input.mode);
    Type classType = Type.forName(ps.ApexClassName__c);
    IAI_ChatCompletion completion = (IAI_ChatCompletion) classType.newInstance();
    Map<String,String> response = completion.getChatCompletion(new Map<String,Object>{
                                                            'settings' => ps,
                                                            'prompt' => input.prompt,
                                                            'previousResponse' => input.previousResponse,
                                                            'messagesString' => input.messagesString,
                                                            'includeHistory' => String.valueOf(input.includeHistory)});
    //create response 
    List<String> outputs = new List<String>();
    List<List<String>> flowOutputs = new List<List<String>>();
    for(String key: response.keySet()) {
      String output =key + '*'+ response.get(key);
      outputs.add(output);
    }
    flowOutputs.add(outputs);
    return flowOutputs;
  }

  @AuraEnabled(cacheable=false)
  public static String invokeAiFromLWC(LWCInput input) {
      return null; // Placeholder for LWC implementation
  }

  @TestVisible
  private static PromptSetting__mdt getPromptSettings(String mode) {
    try {
      PromptSetting__mdt ps = [SELECT Id, DeveloperName, Instructions__c, Named_Credential__c, 
                                      ApexClassName__c,Temprature__c, Top_P__c, Frequency_Penalty__c,
                                      Presence_Penalty__c, Max_Tokens__c 
                                FROM PromptSetting__mdt
                                WHERE DeveloperName = :mode
                                WITH USER_MODE
                                LIMIT 1];
      if (String.isBlank(ps.ApexClassName__c)) {
        throw new AIStrategyException('Incomplete configuration for prompt: ' + mode);
        }
      return ps;
    }
    catch (AIStrategyException ex){
      throw new AIStrategyException(ex.getMessage());
    }
    catch (Exception e) {
      throw new AIStrategyException('No configuration found for prompt: ' + mode);
    }
  }
}