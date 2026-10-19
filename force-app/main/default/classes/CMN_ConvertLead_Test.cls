/**
 * @description       : Test class for CMN_ConvertLead
 * @author            : Derek Hughes
 * @group             : Lead Management
 * @last modified on  : 12-05-2024
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class CMN_ConvertLead_Test {


    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_ConvertLead_Test.class.getName());

    private static final String PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final String PROSPECT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();
    private static final String AE_CROSS_SELL_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('ZA_A_E_Cross_Sell').getRecordTypeId();

    /**
    * @description Create basic test data for all test methods
    * @author Derek Hughes | 04-04-2024 
    **/
    @TestSetup
    public static void testSetUp() {

        LOGGER.debug('===== SETUP testSetUp START : Queries='+Limits.getQueries());

        List<Account> testAccounts = new List<Account>();

        Account testClient = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            LastName='Client',
            FirstName='John',
            PersonEmail  ='client@email.com',
            ExternalIdentifier__c = 'ZA010111111',
            ExternalCIFCountry__c = 'ZA',
            ExternalSystemId__c ='01',
            ExternalCIFId__c = '0111111'
        );

        testAccounts.add(testClient);

        Account testProspect = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            LastName='Prospect',
            FirstName='Mary',
            PersonEmail  ='prospect@email.com'
        );

        testAccounts.add(testProspect);

        insert testAccounts;

        LOGGER.debug('===== SETUP testSetUp Accounts: Queries='+Limits.getQueries());


        List<Lead> testLeads = new  List<Lead>();

        // Create a working Lead for a propect
        Lead testLeadForProspect = new Lead(
            RecordTypeId = AE_CROSS_SELL_LEAD_RT_ID,
            Status = 'Working',
            FirstName = 'Prospect',
            LastName = 'Lead',
            Loan_Income_Amount__c = 500000
        );
        testLeads.add(testLeadForProspect);

        // Create a working Lead for an existing client - synched to org
        Lead testLeadForClient = new Lead(
            RecordTypeId = AE_CROSS_SELL_LEAD_RT_ID,
            Status = 'Working',
            FirstName = 'Client',
            LastName = 'Lead',
            Loan_Income_Amount__c = 500000,
            External_Client_Identifier__c = testClient.ExternalIdentifier__c
        );
        testLeads.add(testLeadForClient);

        // Create a working Lead for a new client - not yet synced to the org
        Lead testLeadForNewClient = new Lead(
            RecordTypeId = AE_CROSS_SELL_LEAD_RT_ID,
            Status = 'Working',
            FirstName = 'New',
            LastName = 'Lead',
            Loan_Income_Amount__c = 500000,
            External_Client_Identifier__c = 'ZA010222222'
        );
        testLeads.add(testLeadForNewClient);

        insert testLeads;

        testLeadForProspect.OwnerId = UserInfo.getUserId();
        testLeadForClient.OwnerId = UserInfo.getUserId();
        testLeadForNewClient.OwnerId = UserInfo.getUserId();

        update testLeads;

        LOGGER.debug('===== SETUP testSetUp Leads: Queries='+Limits.getQueries());
    }

    @isTest
    static void testConvertProspect() {

        Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'Prospect'];

        Test.startTest();
        LOGGER.debug('===== START TEST testConvertProspect : Queries='+Limits.getQueries());

            List<CMN_ConvertLead.LeadConversionRequest> requests = new List<CMN_ConvertLead.LeadConversionRequest>();
            CMN_ConvertLead.LeadConversionRequest request = new CMN_ConvertLead.LeadConversionRequest();
            request.leadId = testLead.Id;
            requests.add(request);
            
            List<CMN_ConvertLead.LeadConversionResult> results = CMN_ConvertLead.convertLead(requests);

            LOGGER.debug('===== STOP TEST testConvertProspect : Queries='+Limits.getQueries());
        Test.stopTest();

        Account newAccount = [SELECT Id, Name, Firstname, Lastname FROM Account WHERE Id = :results[0].accountId];
        Opportunity newOpp = [SELECT Id, Name, StageName FROM Opportunity WHERE AccountId = :results[0].accountId];
        Lead convertedLead = [SELECT Id, Name, Firstname, Lastname, Status, isConverted FROM Lead WHERE Id = :testLead.Id];

        Assert.isTrue(convertedLead.IsConverted, 'Lead is not converted');
        Assert.areEqual(convertedLead.Firstname, newAccount.FirstName, 'New account does not have the correct first name');
        Assert.areEqual(convertedLead.Name, newOpp.Name, 'Opportunity does not have the correct name');
    }

    @isTest
    static void testConvertExistingClient() {

        Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'Client'];

        Test.startTest();

            List<CMN_ConvertLead.LeadConversionRequest> requests = new List<CMN_ConvertLead.LeadConversionRequest>();
            CMN_ConvertLead.LeadConversionRequest request = new CMN_ConvertLead.LeadConversionRequest();
            request.leadId = testLead.Id;
            requests.add(request);
            
            List<CMN_ConvertLead.LeadConversionResult> results = CMN_ConvertLead.convertLead(requests);

        Test.stopTest();

        Account newAccount = [SELECT Id, Name, Firstname, Lastname FROM Account WHERE Id = :results[0].accountId];
        Lead convertedLead = [SELECT Id, Firstname, Lastname, Status, isConverted, FinServ__RelatedAccount__c, External_Client_Identifier__c FROM Lead WHERE Id = :testLead.Id];

        Assert.isTrue(convertedLead.IsConverted, 'Lead is not converted');
        Assert.areEqual(convertedLead.FinServ__RelatedAccount__c, newAccount.Id, 'Converted Account mismatched Id');

    }

    @isTest
    static void testConvertNewClient() {

        Lead testLead = [SELECT Id FROM Lead WHERE FirstName = 'New'];

        Test.startTest();

            List<CMN_ConvertLead.LeadConversionRequest> requests = new List<CMN_ConvertLead.LeadConversionRequest>();
            CMN_ConvertLead.LeadConversionRequest request = new CMN_ConvertLead.LeadConversionRequest();
            request.leadId = testLead.Id;
            requests.add(request);
            
            List<CMN_ConvertLead.LeadConversionResult> results = CMN_ConvertLead.convertLead(requests);

        Test.stopTest();

        Account newAccount = [SELECT Id, Name, Firstname, Lastname, ExternalIdentifier__c FROM Account WHERE Id = :results[0].accountId];
        Lead convertedLead = [SELECT Id, Firstname, Lastname, Status, isConverted, External_Client_Identifier__c FROM Lead WHERE Id = :testLead.Id];

        Assert.isTrue(convertedLead.IsConverted, 'Lead is not converted');
        Assert.areEqual(convertedLead.External_Client_Identifier__c, newAccount.ExternalIdentifier__c, 'Converted Account mismatched External Identifier');

    }

}