/**
 * The OpenAIChat class provides methods for interacting with the OpenAI Chat API.
 */
public class OpenAIChat {
  /**
   * Represents the output of the chat completion.
   */
  public class ChatOutput {
    @InvocableVariable(required=true)
    public String res;
    @InvocableVariable
    public String messagesString;
  }

  /**
   * Represents the input parameters for the chat completion.
   */
  public class ChatInput {
    @InvocableVariable(required=true)
    public String mode;
    @InvocableVariable(required=true)
    public String prompt;
    @InvocableVariable
    public String previousPrompt;
    @InvocableVariable
    public String previousResponse;
    @InvocableVariable
    public String messagesString;
    @InvocableVariable
    public Boolean includeHistory;
    @InvocableVariable
    public Decimal temperature;
    @InvocableVariable
    public String model;
  }

  public class TaskWrapper {
    public String Subject;
    public String Status;
    public String Priority;
    public String WhatId;
    public String WhoId;
    public String OwnerId;
    public Date ActivityDate;
    public String Description;
  }

  public static List<Task> parseTasks(String jsonString) {
    List<TaskWrapper> tasks = (List<TaskWrapper>) JSON.deserialize(
      jsonString,
      List<TaskWrapper>.class
    );
    List<Task> sObjectTasks = new List<Task>();
    for (TaskWrapper t : tasks) {
      Task newTask = new Task();
      newTask.Subject = t.Subject;
      newTask.Status = t.Status;
      newTask.Priority = t.Priority;
      newTask.WhatId = t.WhatId;
      newTask.WhoId = t.WhoId;
      newTask.OwnerId = t.OwnerId;
      newTask.ActivityDate = t.ActivityDate;
      newTask.Description = t.Description;
      sObjectTasks.add(newTask);
    }
    return sObjectTasks;
  }

  /**
   * Invocable method to get the chat completion.
   * @param inputs The list of ChatInput objects containing the input parameters.
   * @return The list of ChatOutput objects representing the chat completion output.
   */
  @InvocableMethod
  public static List<ChatOutput> getChatCompletion(List<ChatInput> inputs) {
    // get named credential

    String endpoint = 'callout:NC_OpenAI/chat/completions';
    List<Object> messages = new List<Object>();

    PromptSetting__mdt ps = [
      SELECT Id, Instructions__c, ReplyCode__c, SObject__c
      FROM PromptSetting__mdt
      WHERE DeveloperName = :inputs[0].mode
      LIMIT 1
    ];

    if (!String.isBlank(inputs[0].messagesString) && inputs[0].includeHistory) {
      messages = (List<Object>) JSON.deserializeUntyped(
        inputs[0].messagesString
      );
      messages.add(
        new Map<String, Object>{
          'role' => 'assistant',
          'content' => inputs[0].previousResponse
        }
      );
      messages.add(
        new Map<String, Object>{
          'role' => 'user',
          'content' => inputs[0].prompt
        }
      );
    } else {
      messages.add(
        new Map<String, Object>{
          'role' => 'system',
          'content' => ps.Instructions__c
        }
      );
      messages.add(
        new Map<String, Object>{
          'role' => 'user',
          'content' => inputs[0].prompt
        }
      );
    }

    // Prepare the request body
    Map<String, Object> requestBody = new Map<String, Object>{
      'model' => inputs[0].model,
      'temperature' => inputs[0].temperature,
      'messages' => messages
    };

    // Make the HTTP callout

    HttpRequest request = new HttpRequest();
    request.setTimeout(120000);
    request.setEndpoint(endpoint);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setBody(JSON.serialize(requestBody));

    Http http = new Http();
    HttpResponse response = http.send(request);

    //System.debug(response.getBody());
    // Parse the response and return the content attribute
    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    List<Object> choices = (List<Object>) responseBody.get('choices');
    Map<String, Object> message = (Map<String, Object>) ((Map<String, Object>) choices[0])
      .get('message');
    String content = (String) message.get('content');

    if (ps.ReplyCode__c) {
      system.debug(content);
      List<Task> tasks = parseTasks(content);
      system.debug('Tasks: ' + tasks);
      insert tasks;
    }

    List<ChatOutput> chatOutputs = new List<ChatOutput>();
    ChatOutput chatOutput = new ChatOutput();
    chatOutput.res = content;
    chatOutput.messagesString = JSON.serialize(messages);
    chatOutputs.add(chatOutput);

    return chatOutputs;
  }
}
