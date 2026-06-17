@isTest
public with sharing class ConstantsTest {

    @isTest
    static void testUserConstants() {
      Test.startTest();
      UserConstants userConstants = Constants.USER;
      Test.stopTest();
      Assert.areNotEqual(null, userConstants, 'UserConstants instance should not be null');
    }

    @isTest
    static void testPartsQuotesConstants() {
      Test.startTest();
      PartsQuoteConstants partsQuotesConstants = Constants.PARTS_QUOTE;
      Test.stopTest();
      Assert.areNotEqual(null, partsQuotesConstants, 'PartsQuoteConstants instance should not be null');
    }

    @isTest
    static void testCaseConstants() {
      Test.startTest();
      CaseConstants caseConstants = Constants.CASES;
      Test.stopTest();
      Assert.areNotEqual(null, caseConstants, 'CaseConstants instance should not be null');
    }

    @isTest
    static void testWorkOrderConstants() {
      Test.startTest();
      WorkOrderConstants woConstants = Constants.WORK_ORDER;
      Test.stopTest();
      Assert.areNotEqual(null, woConstants, 'WorkOrderConstants instance should not be null');
    }

    @isTest
    static void testWorkOrderLineItemConstants() {
      Test.startTest();
      WorkOrderLineItemConstants woliConstants = Constants.WORK_ORDER_LINE_ITEM;
      Test.stopTest();
      Assert.areNotEqual(null, woliConstants, 'WorkOrderLineItemConstants instance should not be null');
    }

    @isTest
    static void testHttpConstants() {
      Test.startTest();
      HttpConstants httpConstants = Constants.HTTP;
      Test.stopTest();
      Assert.areNotEqual(null, httpConstants, 'HttpConstants instance should not be null');
    }

    @isTest
    static void testEquipmentConstants() {
      Test.startTest();
      EquipmentConstants equipmentConstants = Constants.EQUIPMENT;
      Test.stopTest();
      Assert.areNotEqual(null, equipmentConstants, 'EquipmentConstants instance should not be null');
    }
}