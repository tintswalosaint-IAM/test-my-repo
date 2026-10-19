/**
 * @description       : Selector Class for Quotes
 * @author            : Michal Orawiec
 * @created           : 14-10-2025
 ****************************************************
 * Last Modified By Shams
 * Last Modified Date 24/07/2026
 * Last Modified Description: Added Coverage for the additional methods to query by OpportunityId
 * User Story : SFP-59435
**/
@isTest
public with sharing class SEL_Quote_Test {
    private static Id getPersonAccountProspectRT() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();
    }

    private static Id getOpportunityRT() {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    }

    private static Account createAccount(CMN_DAL_SObjectUnitOfWork uow) {
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Test',
                LastName = 'Customer',
                ExternalCIFCountry__c = 'ZA',
                PersonBirthdate = Date.newInstance(1990,1,1)
        );
        uow.registerNew(acc);
        return acc;
    }

    private static Opportunity createOpportunity(CMN_DAL_SObjectUnitOfWork uow, Account acc) {
        Pricebook2 pricebook = new Pricebook2(
                Name = 'C&HNW (South Africa)', IsActive = true, CurrencyIsoCode = 'ZAR'
        );
        insert pricebook;
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;
        insert new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product.Id,
                UnitPrice = 100, IsActive = true
        );
        insert new PricebookEntry(
                Pricebook2Id = pricebook.Id, Product2Id = product.Id,
                UnitPrice = 100, IsActive = true
        );

        Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                Pricebook2Id = pricebook.Id,
                Country__c = 'ZA',
                CurrencyIsoCode = 'ZAR',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                // Opportunity_Flow skips records with a Quote_Id__c, so it won't look up the
                // running user's country pricebook ("No Active Pricebook was found" error)
                Quote_Id__c = 'QUOTE-' + Crypto.getRandomInteger()
        );
        uow.registerNew(opp, Opportunity.AccountId, acc);
        return opp;
    }

    private static Quote createQuote(CMN_DAL_SObjectUnitOfWork uow, Opportunity opp) {
        return createQuote(uow, opp, null);
    }

    private static Quote createQuote(CMN_DAL_SObjectUnitOfWork uow, Opportunity opp, String status) {
        Quote q = new Quote(
                Name = 'Test Quote',
                OpportunityId = opp.Id,
                Pricebook2Id = Test.getStandardPricebookId()
        );
        if (status != null) {
            q.Status = status;
        }
        uow.registerNew(q, Quote.OpportunityId, opp);
        return q;
    }

    private static CMN_DAL_SObjectUnitOfWork newUow() {
        return new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType
        });
    }

    @IsTest
    static void testGetSObjectType_returnsQuote() {
        Assert.areEqual(Quote.SObjectType, new SEL_Quote().getSObjectType());
    }

    @IsTest
    static void testGetSObjectFieldList_containsQuoteFields() {
        List<Schema.SObjectField> fields = new SEL_Quote().getSObjectFieldList();
        Map<String, Schema.SObjectField> quoteFields = Quote.SObjectType.getDescribe().fields.getMap();

        Assert.isTrue(fields.size() >= 9, 'Quote selector should expose its configured fields');
        for (Schema.SObjectField field : fields) {
            Assert.isTrue(quoteFields.containsKey(field.getDescribe().getName()));
        }
    }

    @IsTest
    static void testSelectByOpportunityIds_returnsQuotes() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType
        });
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote q = createQuote(uow, opp);
        uow.commitWork();

        List<Quote> results = new SEL_Quote().selectByOpportunityIds(new List<Id>{ opp.Id });
        Assert.areEqual(1, results.size());
        Assert.areEqual(q.Id, results[0].Id);
        Assert.areEqual(opp.Id, results[0].OpportunityId);
    }

    @IsTest
    static void testSelectByOpportunityIds_nullAndEmpty_returnsEmpty() {
        SEL_Quote selector = new SEL_Quote();
        List<Quote> nullResults = selector.selectByOpportunityIds(null);
        List<Quote> emptyResults = selector.selectByOpportunityIds(new List<Id>());

        Assert.areEqual(0, nullResults.size(), 'Null Opportunity Id input should return no Quotes');
        Assert.areEqual(0, emptyResults.size(), 'Empty Opportunity Id input should return no Quotes');
    }

    @IsTest
    static void testSelectByIds_returnsQuote() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType
        });
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote q = createQuote(uow, opp);
        uow.commitWork();

        List<Quote> results = new SEL_Quote().selectByIds(new List<Id>{ q.Id });
        Assert.areEqual(1, results.size(), 'Should return one Quote for provided Id');
        Assert.areEqual(q.Id, results[0].Id, 'Returned Quote Id should match');
        Assert.areEqual(acc.Id, results[0].AccountId, 'Returned Quote should have AccountId populated');
        Assert.areEqual(opp.Id, results[0].OpportunityId, 'Returned Quote should have OpportunityId populated');
    }

    @IsTest
    static void testSelectByIdsOrNames_withIds_returnsQuote() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType
        });
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote q = createQuote(uow, opp);
        uow.commitWork();

        List<Quote> results = new SEL_Quote().selectByIdsOrNames(new List<Id>{ q.Id });
        Assert.areEqual(1, results.size(), 'Should return one Quote when filtering by Id via selectByIdsOrNames');
        Assert.areEqual(q.Id, results[0].Id, 'Returned Quote Id should match for selectByIdsOrNames');
    }

    @IsTest
    static void testSelectByIds_emptyInput_returnsEmpty() {
        List<Quote> results = new SEL_Quote().selectByIds(new List<Id>());
        Assert.areEqual(0, results.size(), 'Empty input should return no records');
    }

    @IsTest
    static void testSelectByAccIds_returnsQuotes() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType
        });
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote q1 = createQuote(uow, opp);
        Quote q2 = createQuote(uow, opp);
        uow.commitWork();

        List<Quote> results = new SEL_Quote().selectByAccIds(new List<Id>{ acc.Id });
        Assert.isTrue(results.size() >= 2, 'Should return at least two Quotes for provided Account Id');
        Set<Id> resultIds = new Map<Id, Quote>(results).keySet();
        Assert.isTrue(resultIds.contains(q1.Id) && resultIds.contains(q2.Id), 'Both Quotes should be returned');
        Assert.isNotNull(results[0].Name, 'Returned Quote should have Name populated');
    }

    @IsTest
    static void testSelectByAccIds_emptyInput_returnsEmpty() {
        List<Quote> results = new SEL_Quote().selectByAccIds(new List<Id>());
        Assert.areEqual(0, results.size(), 'Empty input should return no records');
    }

    @IsTest
    static void testSelectByAccIdsWoSharing_returnsQuotes() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType
        });
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote q = createQuote(uow, opp);
        uow.commitWork();

        List<Quote> results = new SEL_Quote().selectByAccIdsWoSharing(new List<Id>{ acc.Id });
        Assert.isTrue(results.size() >= 1, 'Should return at least one Quote without sharing');
        Assert.isNotNull(results[0].Name, 'Returned Quote should have Name populated');
    }

    @IsTest
    static void testSelectByIdsWoSharing_returnsQuote() {
        CMN_DAL_SObjectUnitOfWork uow = newUow();
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote q = createQuote(uow, opp);
        uow.commitWork();

        Test.startTest();
        List<Quote> results = new SEL_Quote().selectByIdsWoSharing(new List<Id>{ q.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one Quote without sharing');
        Assert.areEqual(q.Id, results[0].Id, 'Returned Quote Id should match');
    }

    @IsTest
    static void testSelectInProgressByAccIds_returnsOnlyInProgress() {
        CMN_DAL_SObjectUnitOfWork uow = newUow();
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote inProgress = createQuote(uow, opp, 'Quote In-Progress');
        createQuote(uow, opp);
        uow.commitWork();

        Test.startTest();
        List<Quote> results = new SEL_Quote().selectInProgressByAccIds(new List<Id>{ acc.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Only the in-progress Quote should be returned');
        Assert.areEqual(inProgress.Id, results[0].Id, 'Returned Quote should be the in-progress one');
    }

    @IsTest
    static void testSelectInProgressByAccIdsWoSharing_returnsOnlyInProgress() {
        CMN_DAL_SObjectUnitOfWork uow = newUow();
        Account acc = createAccount(uow);
        Opportunity opp = createOpportunity(uow, acc);
        Quote inProgress = createQuote(uow, opp, 'Quote In-Progress');
        createQuote(uow, opp);
        uow.commitWork();

        Test.startTest();
        List<Quote> results = new SEL_Quote().selectInProgressByAccIdsWoSharing(new List<Id>{ acc.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Only the in-progress Quote should be returned without sharing');
        Assert.areEqual(inProgress.Id, results[0].Id, 'Returned Quote should be the in-progress one');
    }

    @IsTest
    static void testSelectInProgressByAccIds_emptyInput_returnsEmpty() {
        List<Quote> results = new SEL_Quote().selectInProgressByAccIds(new List<Id>());
        Assert.areEqual(0, results.size(), 'Empty input should return no records');
    }
}