@isTest
public class WI_FLOW_LeadConverter_TEST {
    @testSetup
    static void setup() {
        Map<String, RecordTypeInfo> recordTypeIdsByDeveloperName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Map<String, RecordTypeInfo> leadRecordTypeIdsByDeveloperName = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();

        Account personAccount = new Account(
                FirstName = 'test account'
                , LastName = 'person'
                , RecordTypeId = recordTypeIdsByDeveloperName.get('PersonAccount').getRecordTypeId()
                , PersonEmail = 'account@test.com'
                , PersonHomePhone = '133-456-7890'
                , PersonMailingStreet = '133 Main St'
                , PersonMailingCity = 'Anytown'
                , PersonMailingState = 'CA'
                , PersonMailingPostalCode = '13345'
                , PersonMailingCountry = 'USA'
                , WI_IdentityType__c = 'National Identity Document');

        Account secondAccount = new Account(
                FirstName = 'second'
                , LastName = 'account'
                , RecordTypeId = recordTypeIdsByDeveloperName.get('PersonAccount').getRecordTypeId()
                , PersonEmail = 'secondAccount@test.com'
                , PersonHomePhone = '133-456-7890'
                , PersonMailingStreet = '133 Main St'
                , PersonMailingCity = 'Anytown'
                , PersonMailingState = 'CA'
                , PersonMailingPostalCode = '13345'
                , PersonMailingCountry = 'USA'
                , WI_IdentityType__c = 'National Identity Document');

        insert new List<Account>{
                secondAccount, personAccount
        };

        Application__c testApplication = new Application__c(WI_AttestationConfirmation__c = 'Yes',
                AOB_Country__c = 'AF',
                AOB_Current_Address_Country__c = 'AF',
                AOB_FirstName__c = 'person',
                AOB_LastName__c = 'related',
                WI_IdentityType__c = 'National Identity Document');
        Application__c secondRelated = new Application__c(WI_AttestationConfirmation__c = 'Yes',
                AOB_Country__c = 'AF',
                AOB_Current_Address_Country__c = 'AF',
                AOB_FirstName__c = 'business',
                AOB_LastName__c = 'related',
                WI_IdentityType__c = 'National Identity Document');
        insert new List<Application__c>{
                testApplication, secondRelated
        };

        Lead personLead = new Lead(FirstName = 'test account'
                , LastName = 'person'
                , Email = 'adconver.leadas@abcinc.com'
                , FinServ__RelatedAccount__c = personAccount.Id
                , RecordTypeId = leadRecordTypeIdsByDeveloperName.get('WI_WealthInvestment').getRecordTypeId()
                , WI_PendingClientID__c = 'tete3w53245'
                , SA_ID_or_Passport__c = 'fwe343f'
                , LeadSource = 'Website'
                , Client_Type__c = 'New To Bank Client'
                , WI_Application__c = testApplication.Id);

        Lead secondLead = new Lead(FirstName = 'second', LastName = 'account',
                Email = 'adconver.leadas@abcinc.com',
                FinServ__RelatedAccount__c = secondAccount.Id,
                RecordTypeId = leadRecordTypeIdsByDeveloperName.get('WI_WealthInvestment').getRecordTypeId(),
                WI_PendingClientID__c = 'tete3w53245',
                SA_ID_or_Passport__c = 'fwe343f',
                LeadSource = 'Website',
                Client_Type__c = 'New To Bank Client',
                WI_Application__c = secondRelated.Id);
        insert new List<Lead>{
                personLead, secondLead
        };

        testApplication.WI_RelatedLead__c = personLead.Id;
        secondRelated.WI_RelatedLead__c = secondLead.Id;
        update new List<Application__c>{
                testApplication, secondRelated
        };

        Pricebook2 pb1 = WI_DAL_DataFactory.createPricebook(
            new Map<String, Object>{
                'Name' => 'SA Wealth & Investment'
            }
        );
        insert pb1;

        Product2 prod = WI_DAL_DataFactory.createProduct(null);
        insert prod;

        PricebookEntry standardPrice = WI_DAL_DataFactory.createPricebookEntry(
            new Map<String, Object>{
                'Product2Id' => prod.Id
            }
        );
        insert standardPrice;

        PricebookEntry customPrice = WI_DAL_DataFactory.createPricebookEntry(
            new Map<String, Object>{
                'Product2Id' => prod.Id,
                'Pricebook2Id' => pb1.Id
            }
        );
        insert customPrice;
    }

    @IsTest
    static void convertLeadNullInput() {
        Test.startTest();
        List<WI_FLOW_LeadConverter.LeadConversionResult> results = WI_FLOW_LeadConverter.convertLeads(null);
        Test.stopTest();
        Assert.isNull(results);
    }

    @IsTest
    static void convertLeadFailTest() {
        List<WI_FLOW_LeadConverter.LeadConversionInput> inputList = new List<WI_FLOW_LeadConverter.LeadConversionInput> ();
        WI_FLOW_LeadConverter.LeadConversionInput inn = new WI_FLOW_LeadConverter.LeadConversionInput ();
        inn.leadStatus = 'Qualified';
        inn.lead = new Lead();
        inputList.add(inn);

        Test.startTest();
        List<WI_FLOW_LeadConverter.LeadConversionResult> results = WI_FLOW_LeadConverter.convertLeads(inputList);
        Test.stopTest();
        Assert.isNotNull(results);
    }

    @isTest
    static void convertLeads_Test() {
        List<Lead> testLeads = [SELECT Id, FinServ__RelatedAccount__c, WI_Application__c, WI_AllowContact__c, Website, Email, Phone, Country, Name FROM Lead];
        List<WI_FLOW_LeadConverter.LeadConversionInput> inputList = new List<WI_FLOW_LeadConverter.LeadConversionInput> ();
        List<String> rtList = new List<String> {'WI_WealthInvestment','WI_Banking','WI_Deposits','WI_WealthManagement','WI_SpecializedLending','WI_TrustFiduciary'};

        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id != :Test.getStandardPricebookId() LIMIT 1];
        for (Lead singleLead : testLeads) {
            WI_FLOW_LeadConverter.LeadConversionInput input = new WI_FLOW_LeadConverter.LeadConversionInput();
            input.lead = singleLead;
            input.opportunityRtName = 'WI_WealthInvestment;WI_Banking;WI_Deposits;WI_WealthManagement;WI_SpecializedLending;WI_TrustFiduciary';
            input.leadStatus = 'Qualified';
            input.opportunityTeamRole = 'Wealth Administrator';
            input.productsData = new List<String>{
                'WI_WealthInvestment;' + pbe.Product2Id + ';' + UserInfo.getUserId(),
                'WI_Banking;' + pbe.Product2Id + ';' + UserInfo.getUserId()
            };

            inputList.add(input);
        }

        Test.startTest();
        List<WI_FLOW_LeadConverter.LeadConversionResult> results = WI_FLOW_LeadConverter.convertLeads(inputList);
        Test.stopTest();

        // Verify that the service returns a result
        Assert.isNotNull(results);
        for (WI_FLOW_LeadConverter.LeadConversionResult result : results) {
            Assert.areEqual('', result.errorMessage.replaceAll('null', ''));
            Assert.isTrue(result.success);
        }
        Map<Id, Account> accounts = new Map<Id, Account> ([
                SELECT Id,
                        WI_InternationalRM__c,
                        WI_DomesticRM__c,
                        WI_WealthManager__c,
                        WI_WealthAdministrator__c
                FROM Account
        ]);
        Map<Id, Application__c> applications = new Map<Id, Application__c>([
                SELECT Id,
                        WI_RelatedLead__c,
                        AOB_FirstName__c,
                        AOB_LastName__c,
                        WI_IdentityType__c,
                        WI_WealthAdministrator__c,
                        WI_AccountManager__c,
                        WI_IdentificationNumber__c,
                        AOB_Title__c,
                        WI_CompanyRegistrationNumber__c,
                        Correspondence_Address_Line_1__c,
                        WI_WealthManager__c,
                        WI_RelationshipManager__c,
                        Correspondence_Country__c,
                        Correspondence_Postcode__c,
                        Correspondence_Province__c
                FROM Application__c
        ]);

        Map<Id,Opportunity> opportunitiesMap =  new Map<Id, Opportunity>([SELECT Id, AccountId, Name, RecordType.DeveloperName, StageName FROM Opportunity]);
        Assert.areEqual(12, opportunitiesMap.size());
        Map<Id, Opportunity> opportunityByAccountId = new Map<Id, Opportunity>();
        for (Opportunity singleOpp : opportunitiesMap.values()) {
            Assert.isTrue(rtList.contains(singleOpp.RecordType.DeveloperName));
            Assert.areEqual('Setup', singleOpp.StageName);
            opportunityByAccountId.put(singleOpp.AccountId, singleOpp);
        }

        testLeads = [SELECT Id, Status, FinServ__RelatedAccount__c, WI_Application__c, WI_AllowContact__c, Website, Email, Phone, Country FROM Lead];
        for (Lead singleLead : testLeads) {
            Assert.areEqual('Qualified', singleLead.Status);
            Account relatedAccount = accounts.get(singleLead.FinServ__RelatedAccount__c);
            Assert.isNotNull(relatedAccount);
            Application__c relatedApplication = applications.get(singleLead.WI_Application__c);
            Assert.isNotNull(relatedApplication);
            Opportunity relatedOpportunity = opportunityByAccountId.get(singleLead.FinServ__RelatedAccount__c);
            Assert.isNotNull(relatedOpportunity);

            Assert.areEqual(relatedAccount.WI_InternationalRM__c, relatedApplication.WI_RelationshipManager__c);
            Assert.areEqual(relatedAccount.WI_DomesticRM__c, relatedApplication.WI_RelationshipManager__c);
            Assert.areEqual(relatedAccount.WI_WealthManager__c, relatedApplication.WI_WealthManager__c);
            Assert.areEqual(relatedAccount.WI_WealthAdministrator__c, relatedApplication.WI_WealthAdministrator__c);
        }
    }
}