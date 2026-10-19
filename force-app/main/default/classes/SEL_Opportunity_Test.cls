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
        createRelationshipManagementPricebooks();
        Account accrec = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createOpportunity(accrec.Id);
        WI_DAL_DataFactory.createAccountLeadOpportunity(new Map<String, Object>(),new Map<String, Object>(),new Map<String, Object>());
    }

    /**
     * @description Opportunity_Flow looks up an active Pricebook2 by the name configured in
     *              Relationship_Management_Settings__mdt for the running user's country and throws
     *              "No Active Pricebook was found" if none exists. Pricebooks are not visible in tests,
     *              so create an active one for every configured name.
     */
    private static void createRelationshipManagementPricebooks() {
        Set<String> pricebookNames = new Set<String>();
        for (Relationship_Management_Settings__mdt setting : [
            SELECT Name_of_Pricebook_to_be_Added__c
            FROM Relationship_Management_Settings__mdt
            WHERE Add_Pricebook_to_New_Opportunities__c = 'Yes'
                AND Name_of_Pricebook_to_be_Added__c != null
        ]) {
            pricebookNames.add(setting.Name_of_Pricebook_to_be_Added__c);
        }

        List<Pricebook2> pricebooks = new List<Pricebook2>();
        for (String pricebookName : pricebookNames) {
            pricebooks.add(new Pricebook2(Name = pricebookName, IsActive = true));
        }
        insert pricebooks;

        update new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
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
        System.assertNotEquals(null, retrievedOpportunityId, 'Expected to retrieve an Opportunity Id.');
        System.assertEquals(testOpportunity.Id, retrievedOpportunityId, 'Retrieved Opportunity Id should match the inserted Opportunity.');
        
        Id nullOpportunityId = opportunitySelector.getOpportunityIdByLeadId(null);
        System.assertEquals(null, nullOpportunityId, 'Expected to retrieve null when leadId is null.');
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
        System.assertNotEquals(null, retrievedOpportunity, 'Expected to retrieve an open Opportunity.');
        System.assertEquals(testOpportunity.Id, retrievedOpportunity.Id, 'Retrieved Opportunity should match the expected open Opportunity.');
        
        Opportunity retrievedOpportunityByAccount = opportunitySelector.getOpenOpportunityByAccountId(account.Id,'General','%Car and Home Insurance%'); 
        Assert.isNotNull(retrievedOpportunityByAccount.Id);
        
        Opportunity nullOpportunity = opportunitySelector.getOpenOpportunityByLeadId(null,'General','%Car and Home Insurance%');
        System.assertEquals(null, nullOpportunity, 'Expected to retrieve null when leadId is null.');
    }

    /**
     * @description Tests `selectByIds` returns null when no ids are passed
     */
    @IsTest
    static void selectByIdsNullTestMethod() {
        Test.startTest();
        List<Opportunity> oppData = new SEL_Opportunity().selectByIds(null);
        Test.stopTest();
        Assert.isNull(oppData, 'Expected null when ids is null');
    }

    /**
     * @description Tests `selectCloseDateByIds` returns CloseDate and StageName, and null for null ids
     */
    @IsTest
    static void selectCloseDateByIdsTestMethod() {
        Opportunity opprec = [SELECT Id, CloseDate, StageName FROM Opportunity LIMIT 1];
        SEL_Opportunity selOpp = new SEL_Opportunity();
        Test.startTest();
        List<Opportunity> oppData = selOpp.selectCloseDateByIds(new Set<Id>{opprec.Id});
        List<Opportunity> nullData = selOpp.selectCloseDateByIds(null);
        Test.stopTest();
        Assert.areEqual(1, oppData.size(), 'Expected 1 Opportunity');
        Assert.areEqual(opprec.CloseDate, oppData[0].CloseDate, 'CloseDate should match');
        Assert.areEqual(opprec.StageName, oppData[0].StageName, 'StageName should match');
        Assert.isNull(nullData, 'Expected null when ids is null');
    }

    /**
     * @description Tests `selectCloseDateByIdsWoSharing` returns the Opportunity without sharing
     */
    @IsTest
    static void selectCloseDateByIdsWoSharingTestMethod() {
        Opportunity opprec = [SELECT Id, CloseDate FROM Opportunity LIMIT 1];
        Test.startTest();
        List<Opportunity> oppData = new SEL_Opportunity().selectCloseDateByIdsWoSharing(new Set<Id>{opprec.Id});
        Test.stopTest();
        Assert.areEqual(1, oppData.size(), 'Expected 1 Opportunity');
        Assert.areEqual(opprec.CloseDate, oppData[0].CloseDate, 'CloseDate should match');
    }

    /**
     * @description Tests `selectByIdsWoSharing` returns the Opportunity without sharing
     */
    @IsTest
    static void selectByIdsWoSharingTestMethod() {
        Opportunity opprec = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        List<Opportunity> oppData = new SEL_Opportunity().selectByIdsWoSharing(new Set<Id>{opprec.Id});
        Test.stopTest();
        Assert.areEqual(1, oppData.size(), 'Expected 1 Opportunity');
        Assert.areEqual(opprec.Id, oppData[0].Id, 'Opportunity Id should match');
    }

    /**
     * @description Tests `selectBySalesEvent` returns no Opportunities for an unknown sales event
     */
    @IsTest
    static void selectBySalesEventTestMethod() {
        Test.startTest();
        List<Opportunity> oppData = new SEL_Opportunity().selectBySalesEvent(new List<String>{'UNKNOWN-SALES-EVENT'});
        Test.stopTest();
        Assert.areEqual(0, oppData.size(), 'Expected no Opportunities for an unknown sales event');
    }
}