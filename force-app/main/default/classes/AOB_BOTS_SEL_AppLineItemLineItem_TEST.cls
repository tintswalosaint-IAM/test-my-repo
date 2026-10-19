/**
 * @description       : Test Class for AOB_BOTS_SEL_ApplicationLineItemLineItem
 * @author            : Narendra Teja
 * @last modified on  : 08-04-2023
 * @last modified by  : Narendra Teja
**/

@IsTest
public with sharing class AOB_BOTS_SEL_AppLineItemLineItem_TEST {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        insert app;
        Application_Participant__c appParticipant = new Application_Participant__c(AOB_FullName__c = 'test test',Application__c = app.id, AOB_TECH_OTPATTEMS__c = 3,CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = true,AOB_KeyContactPerson__c = true,CNGCU_Email__c = 'test@email.com');
        insert appParticipant;
        Application_Line_Item__c appLineItem = new Application_Line_Item__c(Application__c = app.Id, AOB_Main__c = true, Details__c = 'Test details');
        insert appLineItem;
    
    }
   
    /**
    * Test method for AOB_BOTS_SEL_ApplicationLineItem.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        AOB_BOTS_SEL_ApplicationLineItem app = new AOB_BOTS_SEL_ApplicationLineItem();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * Test method for AOB_BOTS_SEL_ApplicationLineItem.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        Test.startTest();
        AOB_BOTS_SEL_ApplicationLineItem app = new AOB_BOTS_SEL_ApplicationLineItem();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Application_Line_Item__c.sObjectType,typ);
    }
    
    
    /**
    * Test method for BOTS AOB_BOTS_SEL_ApplicationLineItem.selectApplicationById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationLineItemByIdTest(){
        Application_Line_Item__c newApplication = [Select Id from Application_Line_Item__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationLineItem app = new AOB_BOTS_SEL_ApplicationLineItem();
        List<Application_Line_Item__c> lst = app.selectApplicationLineItemById(newApplication.Id);
        Test.stopTest();
        Assert.areEqual(newApplication.id,lst[0].id);
    }
    /**
    * Test method for BOTS AOB_BOTS_SEL_ApplicationLineItem.selectApplicationById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationLineItemByApplicationIdTest(){
        Application_Line_Item__c newApplication = [Select Id from Application_Line_Item__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationLineItem app = new AOB_BOTS_SEL_ApplicationLineItem();
        List<Application_Line_Item__c> lst = app.selectApplicationLineItemByIds(New List<Id>{newApplication.Id});
        Test.stopTest();
        Assert.areEqual(newApplication.id,lst[0].id);
    }
    /**
    * Test method for BOTS AOB_BOTS_SEL_ApplicationLineItem.selectApplicationById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationLineItemByFilterTest(){
        Application_Line_Item__c newApplication = [Select Id,Application__c from Application_Line_Item__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationLineItem app = new AOB_BOTS_SEL_ApplicationLineItem();
        List<Application_Line_Item__c> lst = app.selectApplicationLineItemByApplicationId(newApplication.Application__c);
        Test.stopTest();
        Assert.areEqual(newApplication.id,lst[0].id);
    }
    /**
    * Test method for BOTS AOB_BOTS_SEL_ApplicationLineItem.selectApplicationById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationByIdTest(){
        Application_Line_Item__c newApplication = [Select Id,Application__c from Application_Line_Item__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationLineItem app = new AOB_BOTS_SEL_ApplicationLineItem();
        List<Application_Line_Item__c> lst = app.selectApplicationLineItemByFilter(newApplication.Application__c, true);
        Test.stopTest();
        Assert.areEqual(newApplication.id,lst[0].id);
    }

  
}