/* Parent class for all Microsoft OpenAI Apex classes
 * implementing the different AI use cases.
 * This abstract class contains all common methods and properties 
 * shared by concrete implementations, such as request building, 
 * response parsing, and logging, to address various AI use cases.
 */
public with sharing abstract class AI_MsOpenAiCompletion {

  protected final Integer HTTP_TIMEOUT = 120000;
  protected final String KEY_CHOICES = 'choices';
  protected final String KEY_ROLE = 'role';
  protected final String KEY_CONTENT = 'content';
  protected final String KEY_FREQ_PEN = 'frequency_penalty';
  protected final String KEY_MAX_TOK = 'max_tokens';
  protected final String KEY_MESSAGE = 'message';
  protected final String KEY_MESSAGES = 'messages';
  protected final String KEY_PRES_PEN = 'presence_penalty';
  protected final String KEY_TEMPERATURE = 'temperature';
  protected final String KEY_TOP_P = 'top_p';
  protected final String ROLE_SYSTEM = 'system';
  protected final String ROLE_USER = 'user';
  protected String prompt;
  protected Map<String,String> returnMap = new Map<String,String>();
  protected PromptSetting__mdt ps;
  String requestBodyJson;

  public virtual void init(Map<String, Object> inputs) {
    this.ps = (PromptSetting__mdt) inputs.get('settings');
    this.prompt = (String) inputs.get('prompt');
  }

  public virtual HttpRequest buildHttpRequest(){
    //prepare Request Body data
    List<Object> messages = new List<Object>();
    messages.add(new Map<String, Object>{ KEY_ROLE => ROLE_SYSTEM,
                                          KEY_CONTENT => ps.Instructions__c});
    messages.add(new Map<String, Object>{ KEY_ROLE => ROLE_USER,
                                          KEY_CONTENT => prompt});
    Map<String, Object> requestBodyMap = new Map<String, Object>{KEY_MESSAGES => messages,
                                                                 KEY_TEMPERATURE => ps.Temprature__c,
                                                                 KEY_TOP_P => ps.Top_P__c,
                                                                 KEY_FREQ_PEN => ps.Frequency_Penalty__c,
                                                                 KEY_PRES_PEN => ps.Presence_Penalty__c,
                                                                 KEY_MAX_TOK => Integer.valueOf(ps.Max_Tokens__c) };
    requestBodyJson = JSON.serialize(requestBodyMap);
    //Build Request
    HttpRequest request = new HttpRequest();
    request.setTimeout(HTTP_TIMEOUT);
    request.setEndpoint(ps.Named_Credential__c);
    request.setMethod(Constants.HTTP.HTTP_METHOD_POST);
    request.setHeader(Constants.HTTP.HEADER_CONTENT_TYPE, Constants.HTTP.CONTENT_TYPE_JSON);
    request.setBody(requestBodyJson);

    return request;
  }

  public virtual String parseResponse(HttpResponse response) {
    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    List<Object> choices = (List<Object>) responseBody.get(KEY_CHOICES);
    Map<String, Object> message = (Map<String, Object>) ((Map<String, Object>) choices[0]).get(KEY_MESSAGE);
    return (String) message.get(KEY_CONTENT);
  }

  public virtual void logAiEvent(HttpResponse response) {
    // Create log
    Logger.info('AI Use Case: ' + ps.DeveloperName);
    Logger.info('Api endpoint: ' + ps.Named_Credential__c);
    Logger.info('Request body: ' + requestBodyJson);
    Logger.info('Response status: ' + response.getStatus());
    Logger.info('Response body: ' + response.getBody());
    Logger.info('Prompt: ' + ps.Instructions__c);
    Logger.saveLog();
    Logger.flushBuffer();
  }
}