/**
* @description       : Selector Test Class for Opportunity Entity
*  story             : SFP-36390
* author             : Ikyatha Naidu
* @date              : 2023-11-08 
* @last modified on  : 7-11-2024
* @ Modification Description : SFP-36390, used new field signing arrangement SBO UK
*/
@IsTest
private class SEL_Opportunity_Test {
    
    @TestSetup
    static void setupTestData() {
        Account accrec = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createOpportunity(accrec.Id);
        WI_DAL_DataFactory.createAccountLeadOpportunity(new Map<String, Object>(),new Map<String, Object>(),new Map<String, Object>());
    }
     /**
     * @description Tests the `getSObjectType` method to ensure it returns the correct SObjectType for Opportunity.
     */
    @IsTest
    static void testGetSObjectType() { 
        SEL_Opportunity oppSelector = new SEL_Opportunity();
        Test.startTest();
        Schema.SObjectType sObjectType = oppSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Opportunity.SObjectType, sObjectType, 'The returned SObjectType does not match Opportunity.SObjectType');
    }
      /**
     * @description Tests the `getSObjectFieldList` method to verify that it returns a non-empty list of SObjectFields.
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Opportunity oppSelector = new SEL_Opportunity();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = oppSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'The field list should not be empty');
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in Opportunity field map');
        }
    }
      /**
     * @description Tests the `selectByAccountId` method to ensure it correctly retrieves Opportunities for a given Account ID.
     */
    @IsTest
    static void testSelectByAccountId() {
        Account accrec = [SELECT Id FROM Account LIMIT 1];
            
        SEL_Opportunity selOpp = new SEL_Opportunity();
        Test.startTest();
        List<Opportunity> oppData = selOpp.selectByAccountId(accrec.Id);
        Test.stopTest();
        Assert.areEqual(1, oppData.size(), 'Expected 1 Opportunity for Account ID: ' + accrec.Id + ' but got ' + oppData.size());
    }
     /**
     * @description Tests the `selectById` method to ensure it correctly retrieves an Opportunity for a given Opportunity ID.
     */
    @IsTest
    static void testSelectById() {
        Opportunity opprec = [SELECT Id FROM Opportunity LIMIT 1];
        SEL_Opportunity selOpp = new SEL_Opportunity(); 
         Test.startTest();
        Opportunity opp = selOpp.selectById(opprec.Id);
       Test.stopTest();
        Assert.areEqual(true, opp != null, 'Expected a non-null Opportunity for Opportunity ID: ' + opprec.Id);
        
    }
   /**
     * @description Tests the `selectByAccountIds` method to ensure it correctly retrieves Opportunities for a set of Account IDs
     */
    @IsTest
    static void testSelectByAccountIds() {
        Account accrec = [SELECT Id FROM Account LIMIT 1];
        SEL_Opportunity selOpp = new SEL_Opportunity();        
        Test.startTest();
        List<Opportunity> oppData = selOpp.selectByAccountIds(new Set<Id>{accrec.Id});
        Test.stopTest();        
        Assert.areEqual(true, oppData.size() > 0, 'Expected at least 1 Opportunity for Account IDs but got ' + oppData.size());
    }
     /**
     * @description Tests the `selectOpportunityByAccountId` method to ensure it correctly retrieves Opportunities for a set of AccountID
     */
     @IsTest
    static void selectOpportunityByAccountIdTestMethod() {
        Account accrec = [SELECT Id FROM Account LIMIT 1];
        SEL_Opportunity selOpp = new SEL_Opportunity();        
        Test.startTest();
        Opportunity oppData = selOpp.selectOpportunityByAccountId(accrec.Id);
        Test.stopTest();        
        Assert.areEqual(true, oppData !=null, 'Expected a non-null Opportunity for Opportunity ID: ' + oppData.id);
    }
    
     /**
     * @description Tests the `selectByIds` method to ensure it correctly retrieves an Opportunity for a given Opportunity ID.
     */
    @IsTest
    static void selectByIdsTestMethod() {
        Opportunity opprec = [SELECT Id FROM Opportunity LIMIT 1];
        SEL_Opportunity selOpp = new SEL_Opportunity();  
         Test.startTest();
        List<Opportunity> oppData = selOpp.selectByIds(new Set<Id>{opprec.Id});
       Test.stopTest();
         Assert.areEqual(true, oppData.size() > 0, 'Expected at least 1 Opportunity for Account IDs but got ' + oppData.size());
        
    }
    
    /**
* @author Dhriven Hamlall | 7-11-2024
* @description Unit test for the getOpportunityIdByLeadId method in SEL_Opportunity. Verifies that the method 
*              retrieves the correct Opportunity Id based on a given Lead Id and returns null when the Lead Id 
*              is null.
* @test Creates a test Lead and Opportunity, retrieves the Opportunity Id using the getOpportunityIdByLeadId 
*       method, and asserts the results.
*/    
    
    @isTest
    static void testGetOpportunityIdByLeadId() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Lead__c = :testLead.Id LIMIT 1];
        
        SEL_Opportunity opportunitySelector = new SEL_Opportunity();
        
        Id retrievedOpportunityId = opportunitySelector.getOpportunityIdByLeadId(testLead.Id);
        Assert.areNotEqual(null, retrievedOpportunityId, 'Expected to retrieve an Opportunity Id.');
        Assert.areEqual(testOpportunity.Id, retrievedOpportunityId, 'Retrieved Opportunity Id should match the inserted Opportunity.');
        
        Id nullOpportunityId = opportunitySelector.getOpportunityIdByLeadId(null);
        Assert.areEqual(null, nullOpportunityId, 'Expected to retrieve null when leadId is null.');
    }
    
    /**
* @author Dhriven Hamlall | 7-11-2024
* @description Unit test for the getOpenOpportunityByLeadId method in SEL_Opportunity. Verifies that the method 
*              retrieves the correct open Opportunity based on a given Lead Id, ignoring closed opportunities, 
*              and returns null when the Lead Id is null.
* @test Retrieves a test Lead and an open Opportunity associated with the Lead. Calls the getOpenOpportunityByLeadId 
*       method, asserts that the returned Opportunity matches the expected open Opportunity, and verifies 
*       that null is returned when the Lead Id is null.
*/  
    @isTest
    static void testGetOpenOpportunityByLeadId() {
        Account account = [Select Id From Account Limit 1];
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Lead__c = :testLead.Id AND StageName NOT IN ('Closed Won', 'Closed Lost') LIMIT 1];
        
        testOpportunity.Name ='Car and Home Insurance';
        testOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('General').getRecordTypeId();
        testOpportunity.AccountId = account.Id;
        update testOpportunity;
         
        SEL_Opportunity opportunitySelector = new SEL_Opportunity();
        
        Opportunity retrievedOpportunity = opportunitySelector.getOpenOpportunityByLeadId(testLead.Id,'General','%Car and Home Insurance%');
        Assert.areNotEqual(null, retrievedOpportunity, 'Expected to retrieve an open Opportunity.');
        Assert.areEqual(testOpportunity.Id, retrievedOpportunity.Id, 'Retrieved Opportunity should match the expected open Opportunity.');
        
        Opportunity retrievedOpportunityByAccount = opportunitySelector.getOpenOpportunityByAccountId(account.Id,'General','%Car and Home Insurance%'); 
        Assert.isNotNull(retrievedOpportunityByAccount.Id);
        
        Opportunity nullOpportunity = opportunitySelector.getOpenOpportunityByLeadId(null,'General','%Car and Home Insurance%');
        Assert.areEqual(null, nullOpportunity, 'Expected to retrieve null when leadId is null.');
    }
}