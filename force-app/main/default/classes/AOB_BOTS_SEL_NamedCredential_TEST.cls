/**
 * @description       : Test Class for AOB_BOTS_SEL_NamedCredential
 * @author            : Narendra Teja
 * @last modified on  : 08-04-2023
 * @last modified by  : Narendra Teja
**/

@IsTest
public with sharing class AOB_BOTS_SEL_NamedCredential_TEST {
   
    /**
    * Test method for BOTS SEL.NamedCredential.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        AOB_BOTS_SEL_NamedCredential app = new AOB_BOTS_SEL_NamedCredential();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * Test method for BOTS SEL.NamedCredential.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        Test.startTest();
        AOB_BOTS_SEL_NamedCredential app = new AOB_BOTS_SEL_NamedCredential();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(NamedCredential.sObjectType,typ);
    }
    
    /**
    * Test method for BOTS SEL.NamedCredential.selectAppsById
    * Check that the created application is returned
    */
    @IsTest(SeeAllData=true)
    private static void selectAppsByIdTest(){
            NamedCredential ld = [Select Id, DeveloperName  from NamedCredential Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_NamedCredential app = new AOB_BOTS_SEL_NamedCredential();
            List<NamedCredential> lst = app.selectNamedCredentialsByName(ld.DeveloperName);
            Test.stopTest();
            Assert.areEqual(ld.id,lst[0].id);
    }

}