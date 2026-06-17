@isTest
public with sharing class AI_ContactJobTitleTest {

  @TestSetup
  static void makeData(){
    Contact cont = (Contact) new SObjectBuilder(Contact.SObjectType)
                            .put(Contact.Title, 'Tester')
                            .create().getRecord();
  }
  
  static Contact createContactWithJobTitle(){
      return (Contact) new SObjectBuilder(Contact.SObjectType)
                          .put(Contact.Title, 'Purchasing')
                          .create().getRecord();
  }
  
  @isTest
  static void insertContactWithJobTitleTest(){
    //this test method does not contain assertion because the Mock response should contain the Contact Id
    //but the Id is not known beforehand so we cannot assert the Marketing title is updated asynchronously
    //The mock response contains teh Contact Id of a nexisting contact in the database
    //the test method updateContactJobTitleTest will contain the assertion
    Contact con = [select Id from Contact limit 1];
    String conId = con.Id;
    String aiResponse = '{"choices":[{"message":{"content":"{\\"' + conId + '\\":\\"Purchasing Manager\\"}"}}]}';
    MockHttpResponses mockResponse = new MockHttpResponses(200, 'OK', aiResponse);
    Test.startTest();
    ContactTriggerHandler.forceExecuteTest = true;
    Contact objContact = createContactWithJobTitle();
    Test.stopTest();
  }

  
  @isTest
  static void updateContactJobTitleTest(){
    Contact objContact = [select Id, Title from Contact limit 1];
    String conId = objContact.Id;
    String aiResponse = '{"choices":[{"message":{"content":"{\\"' + conId + '\\":\\"Purchasing Manager\\"}"}}]}';
    MockHttpResponses mockResponse = new MockHttpResponses(200, 'OK', aiResponse);
    objContact.Title = 'Purchase';
    Test.setMock(HttpCalloutMock.class, mockResponse);
    Test.startTest();
      ContactTriggerHandler.forceExecuteTest = true;
      update objContact;
      ContactTriggerHandler.forceExecuteTest = false;
    Test.stopTest();
    Contact updatedContact = [Select id,Marketing_Job_Title__c from contact where Id = :objContact.Id];
    Assert.areEqual('Purchasing Manager', updatedContact.Marketing_Job_Title__c, 'Contact job title did not updated');
  }
}