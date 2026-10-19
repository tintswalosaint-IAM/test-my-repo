/**
* @description Used to create Data, mostly for unit tests
*
* @author Alexandr Goryachko
*
* @date 2023/02/07
*/
@isTest
public class WI_DAL_DataFactory {
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Account`
*/
    public static Account createAccount(Map<String, Object> fields) {
        Account record = new Account(
            FirstName = 'John',
            LastName = 'Snow',
            RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount').getRecordTypeId()
        );
        return (Account) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Opportunity`
*/
    public static Opportunity createOpportunity(Map<String, Object> fields) {
        Opportunity record = new Opportunity(
            Name = 'Test',
            StageName = 'Proposal',
            CloseDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            RecordTypeId = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('WI_WealthInvestment').getRecordTypeId()
        );
        return (Opportunity) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Product2`
*/
    public static Product2 createProduct(Map<String, Object> fields) {
        Product2 record = new Product2(
            Name = 'Credit',
            Family = 'Banking Product',
            RecordTypeId = SObjectType.Product2.getRecordTypeInfosByDeveloperName()
            .get('WI_WealthInvestment').getRecordTypeId()
        );
        return (Product2) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Pricebook2`
*/
    public static Pricebook2 createPricebook(Map<String, Object> fields) {
        Pricebook2 record = new Pricebook2(
            Name = 'Custom Pricebook',
            IsActive = true
        );
        return (Pricebook2) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `PricebookEntry`
*/
    public static PricebookEntry createPricebookEntry(Map<String, Object> fields) {
        PricebookEntry record = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100,
            IsActive = true
        );
        return (PricebookEntry) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `OpportunityLineItem`
*/
    public static OpportunityLineItem createOpportunityLineItem(Map<String, Object> fields) {
        OpportunityLineItem record = new OpportunityLineItem(
            Quantity = 1
        );
        return (OpportunityLineItem) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Application__c`
*/
    public static Application__c createApplication(Map<String, Object> fields) {
        Application__c record = new Application__c(
            WI_ProcessType__c = 'Wealth Only',
            Status__c = 'Active',
            WI_IdentityType__c = 'National Identity Document',
            RecordTypeId = SObjectType.Application__c.getRecordTypeInfosByDeveloperName()
            .get('WI_ClientEngagementReport').getRecordTypeId()
        );
        return (Application__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `SVC_ServiceType__c`
*/
    public static SVC_ServiceType__c createServiceType(Map<String, Object> fields) {
        SVC_ServiceType__c record = new SVC_ServiceType__c(
            Name = 'Account Opening - Personal',
            SVC_Category__c = 'Account Opening',
            SVC_SubCategory__c = 'Personal',
            SVC_ServiceType__c = 'SVC_ServiceRequest',
            SVC_Active__c = true
        );
        return (SVC_ServiceType__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Entitlement`
*/
    public static Entitlement createEntitlement(Map<String, Object> fields) {
        Entitlement record = new Entitlement(
            Name = 'Test Entitlement',
            Type = 'Phone Support',
            StartDate = Date.today()
        );
        return (Entitlement) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `CMN_Team__c`
*/
    public static CMN_Team__c createTeam(Map<String, Object> fields) {
        CMN_Team__c record = new CMN_Team__c(
            CMN_Active__c = true,
            Name = 'Test Team',
            CMN_Country__c = 'ZA',
            SVC_AnalyseCaseSentiment__c = false,
            SVC_EnableCaseMilestones__c = true,
            SVC_CreateNewCaseAfterHours__c = 24,
            CMN_Email__c = 'noreply.mailer@standardbank.co.za',
            SVC_SendCaseCreationEmails__c = false,
            SVC_CaseCreationEmailTemplate__c = null,
            SVC_SendResolvedNotification__c = false,
            SVC_CaseResolvedEmailTemplate__c = null,
            SVC_SendClosedNotification__c = false,
            SVC_CaseClosureEmailTemplate__c = null,
            SVC_SendSurvey__c = false,
            SVC_SurveyIndicator__c = 'Closed',
            SVC_ChangeRecordTypeonCaseClosure__c = true,
            SVC_CaseClosureRecordType__c = 'SVC_CloseRecordType'
        );
        return (CMN_Team__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `SVC_ServiceTeam__c`
*/
    public static SVC_ServiceTeam__c createServiceTeam(Map<String, Object> fields) {
        SVC_ServiceTeam__c record = new SVC_ServiceTeam__c(
            SVC_Priority__c = 'High',
            SVC_Active__c = true
        );
        return (SVC_ServiceTeam__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `ActionPlanTemplate`
*/
    public static ActionPlanTemplate createActionPlanTemplate(Map<String, Object> fields) {
        ActionPlanTemplate record = new ActionPlanTemplate(
            Name = 'Test Action Plan',
            ActionPlanType = 'Industries',
            TargetEntityType = 'Case'
        );
        return (ActionPlanTemplate) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Case`
*/
    public static Case createCase(Map<String, Object> fields) {
        Case record = new Case(
            Subject = 'Test Case',
            Description = 'Test Description',
            Priority = 'High',
            Origin = 'Phone',
            Status = 'New'
        );
        return (Case) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `ActionPlanTemplateItem`
*/
    public static ActionPlanTemplateItem createActionPlanTemplateItem(Map<String, Object> fields) {
        ActionPlanTemplateItem record = new ActionPlanTemplateItem(
            Name = 'Test Action Task 1',
            ItemEntityType = 'Task',
            UniqueName = 'Test1_1_448a9990_6501_11ed_8a0a_213b76b4dbca'
        );
        return (ActionPlanTemplateItem) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `ActionPlanTemplateItemValue`
*/
    public static ActionPlanTemplateItemValue createActionPlanTemplateItemValue(Map<String, Object> fields) {
        ActionPlanTemplateItemValue record = new ActionPlanTemplateItemValue();
        return (ActionPlanTemplateItemValue) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `ActionPlan`
*/
    public static ActionPlan createActionPlan(Map<String, Object> fields) {
        ActionPlan record = new ActionPlan(
            Name = 'Template Plan',
            StartDate = Date.today(),
            IsUsingHolidayHours = true,
            ActionPlanState = 'In Progress',
            ActionPlanType = 'Industries'
        );
        return (ActionPlan) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `WI_Settings__c`
*/
    public static WI_Settings__c createSettings(Map<String, Object> fields) {
        WI_Settings__c record = new WI_Settings__c(
            WI_CRAChecksNotificationEmail__c = 'test@test.com',
            WI_WorldChecksNotificationEmail__c = 'test@test.com'
        );
        return (WI_Settings__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `ServiceTeamActionPlanTemplate__c`
*/
    public static ServiceTeamActionPlanTemplate__c createServiceTeamActionPlanTemplate(Map<String, Object> fields) {
        ServiceTeamActionPlanTemplate__c record = new ServiceTeamActionPlanTemplate__c(
            Active__c = true
        );
        return (ServiceTeamActionPlanTemplate__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `FieldSetItem__c`
*/
    public static FieldSetItem__c createFieldSetItem(Map<String, Object> fields) {
        FieldSetItem__c record = new FieldSetItem__c(
            Required__c = false,
            ObjectApiName__c = 'Case',
            FieldApiName__c = 'SVC_RequiredSkill__c',
            Order__c = 1
        );
        return (FieldSetItem__c) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Producer`
*/
    public static Producer createProducer(Map<String, Object> fields) {
        Producer record = new Producer(
            Name = 'Test Producer',
            Type = 'Partner Agent'
        );
        return (Producer) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Quote`
*/
    public static Quote createQuote(Map<String, Object> fields) {
        Quote record = new Quote(
            Name = 'Test Quote',
            Status = 'Draft'
        );
        return (Quote) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `QuoteLineItem`
*/
    public static QuoteLineItem createQuoteLineItem(Map<String, Object> fields) {
        QuoteLineItem record = new QuoteLineItem(
            Quantity = 1,
            UnitPrice = 100
        );
        return (QuoteLineItem) populateFields(record, fields);
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @return  `Lead`
*/
    public static Lead createLead(Map<String, Object> fields) {
        Lead record = new Lead(
            Email = 'john@smith.com',
            FirstName = 'John',
            LastName = 'Smith',
            MobilePhone = '1233453453',
            Status = 'New'
        );
        return (Lead) populateFields(record, fields);
    }
    
    /**
* @description Update record fields with new values
* @param obj 
* @param fields record fields
* @return  `SObject`
*/
    private static SObject populateFields(SObject obj, Map<String, Object> fields) {
        if (fields != null) {
            for (String key : fields.keySet()) {
                obj.put(key, fields.get(key));
            }
        }
        return obj;
    }
    
    /**
* @description This method is use to get the user with profile, The profile that should be linked to the new user
* @param profileName
* @return  User with profile set from parameter
*/
    public static User createUser(String profileName) {
        return new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id,
            LastName = 'LastName',
            FirstName = 'FirstName',
            Email = 'aob@sb.com',
            Username = 'aob@sb.com' + System.currentTimeMillis(),
            CommunityNickname = 'aob' + System.currentTimeMillis(),
            CompanyName = 'aob',
            Title = 'Volunteer',
            Alias = 'aob',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            IsActive = true
        );
    }
    
    /**
* @description Fills new test record
* @param fields record fields
* @param accountId optional AccountId for linking PartyProfile
* @param leadId optional LeadId for linking PartyProfile
* @return  `PartyProfile`
*/
    public static PartyProfile createPartyProfile(Map<String, Object> fields, Id accountId, Id leadId) {
        PartyProfile record = new PartyProfile(
            RecordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName()
            .get('Insurance_Individual').getRecordTypeId(),
            FirstName = 'John',
            LastName = 'Snow',
            Name = 'John Snow'
        );
        
        // Set either AccountId or LeadId if provided
        if (accountId != null) {
            record.AccountId = accountId;
        }
        if (leadId != null) {
            record.LeadId = leadId;
        }
        
        return (PartyProfile) populateFields(record, fields);
    }
    
    /**
* @description Creates an Account, a Lead, and an associated Opportunity.
* @param accountFields A map of fields to populate on the Account record.
* @param leadFields A map of fields to populate on the Lead record.
* @param opportunityFields A map of fields to populate on the Opportunity record.
* @return A map containing the created Account, Lead, and Opportunity records.
*/
    public static Map<String, SObject> createAccountLeadOpportunity(
        Map<String, Object> accountFields,
        Map<String, Object> leadFields,
        Map<String, Object> opportunityFields
    ) {
        // Create and insert Account
        Account account = new Account(
            Name = 'Test Account'
        );
        account = (Account) populateFields(account, accountFields);
        insert account;
        
        // Create and insert Lead
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company'
        );
        lead = (Lead) populateFields(lead, leadFields);
        insert lead;
        
        // Create and insert Opportunity associated with the Account and Lead
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            Lead__c = lead.Id,
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        opportunity = (Opportunity) populateFields(opportunity, opportunityFields);
        insert opportunity;
        
        // Return the created records in a map
        return new Map<String, SObject>{
            'Account' => account,
                'Lead' => lead,
                'Opportunity' => opportunity
                };
                    }
    
    
    /**
* @description Creates a test Account and a related Lead
* @return Lead The Lead associated with the created Account
*/
    public static Lead createTestAccountAndLead() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Lead testLead = new Lead(
            LastName = 'Test Lead X', 
            Company = 'Test Company',
            FinServ__RelatedAccount__c = testAccount.Id,
            Email = 'test@example.com',
            MobilePhone = '1234567890',
            ID_Number__c = '1234567890123'
        );
        insert testLead;
        
        return testLead;
    }
    
}