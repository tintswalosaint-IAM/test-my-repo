/**
* @description       : Test for CMN_TRH_Lead
* @author            : Derek Hughes
* @group             : Lead
* @last modified on  : 31-05-2024
* @last modified by  : Derek Hughes
**/
@isTest
private with sharing class CMN_TRH_Lead_Test {
    
    private static final String PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final String PROSPECT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();
    private static final String GENERAL_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    private static final String UGANDA_GENERAL_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Uganda_General_Lead').getRecordTypeId();
    
    /**
* @description Create basic test data for all test methods
* @author Derek Hughes | 04-04-2024 
**/
    @TestSetup
    public static void testSetUp() {
        
        final Account testClient = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            LastName='Client',
            FirstName='John',
            PersonEmail  ='client@email.com',
            ExternalIdentifier__c = 'ZA010111111',
            ExternalCIFCountry__c = 'ZA',
            ExternalSystemId__c ='01',
            ExternalCIFId__c = '0111111'
        );
        
        insert testClient;
        
        // Create a working Lead for an existing client - synched to org
        final Lead testLeadForClient = new Lead(
            RecordTypeId = GENERAL_LEAD_RT_ID,
            Status = 'Working',
            FirstName = 'Client',
            LastName = 'Lead',
            Loan_Income_Amount__c = 500000,
            External_Client_Identifier__c = testClient.ExternalIdentifier__c
        );
        
        insert testLeadForClient;
        
        testLeadForClient.OwnerId = UserInfo.getUserId();
        
        update testLeadForClient;
        
        final Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            Campaign_Code__c = 'ABC123'
        );
        
        insert testCampaign;
        
        // Create a new Lead for Uganda
        final Lead testLeadForUganda = new Lead(
            RecordTypeId = UGANDA_GENERAL_LEAD_RT_ID,
            Status = 'New',
            FirstName = 'Uganda',
            LastName = 'Lead'
        );
        
        insert testLeadForUganda;
        
    }
    
    @isTest
    static void relateToAccountTest() {
        
        final Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'Client'];
        final Account testClient = [SELECT Id FROM Account WHERE Lastname = 'Client'];
        
        Test.startTest();
        
        testLead.OwnerId = UserInfo.getUserId();
        
        update testLead;
        
        Test.stopTest();
        
        final Lead updatedLead = [
            SELECT Id, Firstname, Lastname, Status, isConverted, FinServ__RelatedAccount__c, External_Client_Identifier__c 
            FROM Lead 
            WHERE Id = :testLead.Id
        ];
        
        Assert.areEqual(updatedLead.FinServ__RelatedAccount__c, testClient.Id, 'RElated Account mismatched Id');
        
    }
    
    
    @isTest
    static void relateToCampaignTest() {
        
        final Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'Client'];
        
        Test.startTest();
        
        testLead.Campaign_Code__c = 'ABC123';
        
        update testLead;
        
        Test.stopTest();
        
        final CampaignMember campaignMember = [
            SELECT Id, LeadId, CampaignId  
            FROM CampaignMember 
        ];
        
        Assert.areEqual(campaignMember.LeadId, testLead.Id, 'Campaign member not linked to correct lead');
        
    }
    
    @isTest
    static void milestoneTest() {
        
        final Lead testLeadUganda = [SELECT Id FROM Lead WHERE FirstName = 'Uganda'];
        
        Test.startTest();
        
        testLeadUganda.status='Working';
        
        update testLeadUganda;
        
        Test.stopTest();
        
        final Lead updatedLeadUganda = [
            SELECT Id, Firstname, Lastname, Status, isConverted, Current_Milestone_Start_Date__c
            FROM Lead 
            WHERE Id = :testLeadUganda.Id
        ];
        
        Assert.isNotNull(updatedLeadUganda.Current_Milestone_Start_Date__c, 'Milestone start date/time not set by trigger');
        
    }
    
    // Method to check that delete is not negatively affected by the trigger changes
    @isTest
    static void testDelete() {
        
        final Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'Client'];        
        Test.startTest();
        delete testLead;      
        final List<Lead> testLeads = [SELECT Id FROM Lead WHERE FirstName = 'Client'];        
        Test.stopTest();        
        Assert.areEqual(0, testLeads.size(), 'Lead was not deleted');
    }
    
    
    
    
    
}