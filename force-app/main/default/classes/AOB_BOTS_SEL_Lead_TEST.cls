/**
 * @description       : Test Class for AOB_BOTS_SEL_Lead
 * @author            : Narendra Teja
 * @last modified on  : 08-04-2023
 * @last modified by  : Narendra Teja
**/

@IsTest
public with sharing class AOB_BOTS_SEL_Lead_TEST {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        Lead leadRec = new Lead(Company = 'Prox', LastName = 'Prox');
        insert leadRec;
    }
   
    /**
    * Test method for BOTS SEL.Lead.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        AOB_BOTS_SEL_Lead app = new AOB_BOTS_SEL_Lead();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * Test method for BOTS SEL.Lead.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        Test.startTest();
        AOB_BOTS_SEL_Lead app = new AOB_BOTS_SEL_Lead();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Lead.sObjectType,typ);
    }
    
    /**
    * Test method for BOTS SEL.Lead.selectAppsById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectAppsByIdTest(){
            Lead ld = [Select Id  from Lead Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Lead app = new AOB_BOTS_SEL_Lead();
            List<Lead> lst = app.selectLeadById(ld.id);
            Test.stopTest();
            Assert.areEqual(ld.id,lst[0].id);
    }

}