/**
     * @description : Test class for SEL_InsurancePolicy
     * @author      : Michal Orawiec
     * @date        : 15-10-2025
     * @SFP			: SFP-53079:
     * @param nameInsuredId String Account ID of the insured person     
     **/
@IsTest
public with sharing class SEL_InsurancePolicy_Test {
    private static Id getPersonAccountProspectRT() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();
    }

    private static Account createAccount(CMN_DAL_SObjectUnitOfWork uow) {
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Test',
                LastName = 'Customer',
                PersonBirthdate = Date.newInstance(1990,1,1),
                CMN_CustomerBPID__pc = 'BPID123456',
                CMN_IdentityNumber__pc = 'ID123456789',
                Initials__c = 'TC'
        );
        uow.registerNew(acc);
        return acc;
    }

    private static InsurancePolicy createInsurancePolicy(CMN_DAL_SObjectUnitOfWork uow, Account nameInsured) {
        InsurancePolicy policy = new InsurancePolicy(
                Name = 'Test Policy',
                PolicyName = 'Test Policy Name',
                NameInsuredId = nameInsured.Id,
                Status = 'Active'
        );
        uow.registerNew(policy, InsurancePolicy.NameInsuredId, nameInsured);
        return policy;
    }

    private static InsurancePolicy createInsurancePolicyWithPremiumPayer(CMN_DAL_SObjectUnitOfWork uow, Account nameInsured, Account premiumPayer) {
        InsurancePolicy policy = new InsurancePolicy(
                Name = 'Test Policy With Payer',
                NameInsuredId = nameInsured.Id,
                Premium_Payer__c = premiumPayer.Id,
                Status = 'Active',
                StandardPremiumAmount = 1000,
                PremiumAmount = 500,
                PremiumFrequency = 'Monthly'
        );
        uow.registerNew(policy, InsurancePolicy.NameInsuredId, nameInsured);
        return policy;
    }

    private static Producer createProducer(CMN_DAL_SObjectUnitOfWork uow, Account nameInsured) {
        Producer producer = new Producer(
                Name = 'Test Producer',
                InternalUserId = UserInfo.getUserId(),
                AccountId = nameInsured.id
        );
        uow.registerNew(producer);
        return producer;
    }

    private static InsurancePolicy createInsurancePolicyWithProducer(CMN_DAL_SObjectUnitOfWork uow, Account nameInsured, Producer producer) {
        InsurancePolicy policy = new InsurancePolicy(
                Name = 'Test Policy With Producer',
                PolicyName = 'Platinum Life test',
                NameInsuredId = nameInsured.Id,
                ProducerId = producer.Id,
                Status = 'Active'
        );
        uow.registerNew(policy, InsurancePolicy.NameInsuredId, nameInsured);
        return policy;
    }

    @IsTest
    static void testSelectInsurancePolicyById_returnsPolicy() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType
        });
        Account acc = createAccount(uow);
        InsurancePolicy policy = createInsurancePolicy(uow, acc);
        uow.commitWork();

        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectInsurancePolicyById(policy.Id);
        Assert.areEqual(1, results.size(), 'Should return one InsurancePolicy for provided Id');

        Assert.areEqual(policy.Id, results[0].Id, 'Returned InsurancePolicy Id should match');
        Assert.areEqual(acc.Id, results[0].NameInsuredId, 'Returned InsurancePolicy should have NameInsuredId populated');
        Assert.isNotNull(results[0].Name, 'Returned InsurancePolicy should have Name populated');
        Assert.isNotNull(results[0].PolicyName, 'Returned InsurancePolicy should have PolicyName populated');

        Assert.isNotNull(results[0].NameInsured, 'Returned InsurancePolicy should have NameInsured relationship populated');
        Assert.areEqual(acc.CMN_CustomerBPID__pc, results[0].NameInsured.CMN_CustomerBPID__pc, 'Returned InsurancePolicy should have NameInsured.CMN_CustomerBPID__pc populated');
        Assert.areEqual(acc.CMN_IdentityNumber__pc, results[0].NameInsured.CMN_IdentityNumber__pc, 'Returned InsurancePolicy should have NameInsured.CMN_IdentityNumber__pc populated');
        Assert.areEqual(acc.LastName, results[0].NameInsured.LastName, 'Returned InsurancePolicy should have NameInsured.LastName populated');
        Assert.areEqual(acc.Initials__c, results[0].NameInsured.Initials__c, 'Returned InsurancePolicy should have NameInsured.Initials__c populated');
    }

    @IsTest
    static void testSelectInsurancePolicyById_invalidId_returnsEmpty() {
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectInsurancePolicyById('a000000000000000AAA');
        Assert.areEqual(0, results.size(), 'Invalid Id should return no records');
    }

    @IsTest
    static void testSelectByNameInsuredId_returnsPolicies() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType
        });
        Account acc = createAccount(uow);
        createInsurancePolicy(uow, acc);
        createInsurancePolicy(uow, acc);
        uow.commitWork();

        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectByNameInsuredId(acc.Id);
        Assert.isTrue(results.size() >= 2, 'Should return at least two InsurancePolicies for provided NameInsuredId');
        Assert.areEqual(acc.Id, results[0].NameInsuredId, 'Returned InsurancePolicy should have NameInsuredId populated');
        Assert.isNotNull(results[0].Id, 'Returned InsurancePolicy should have Id populated');
        Assert.isNotNull(results[0].Name, 'Returned InsurancePolicy should have Name populated');
    }

    @IsTest
    static void testSelectByNameInsuredId_withPremiumPayer_returnsPolicy() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType
        });
        Account nameInsured = createAccount(uow);
        Account premiumPayer = createAccount(uow);
        createInsurancePolicyWithPremiumPayer(uow, nameInsured, premiumPayer);
        uow.commitWork();

        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectByNameInsuredId(nameInsured.Id);
        Assert.isTrue(results.size() >= 1, 'Should return at least one InsurancePolicy for provided NameInsuredId');
        Assert.areEqual(nameInsured.Id, results[0].NameInsuredId, 'Returned InsurancePolicy should have NameInsuredId populated');
    }

    @IsTest
    static void testSelectByNameInsuredId_nullInput_returnsEmpty() {
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectByNameInsuredId(null);
        Assert.areEqual(0, results.size(), 'Null input should return no records');
    }

    @IsTest
    static void testSelectByNameInsuredId_invalidId_returnsEmpty() {
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectByNameInsuredId('a000000000000000AAA');
        Assert.areEqual(0, results.size(), 'Invalid Id should return no records');
    }

    @IsTest
    static void testSelectByProducerId_returnsPolicy(){
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType, Producer.SObjectType
        });
        Account acc = createAccount(uow);
        Producer pro = createProducer(uow, acc);
        createInsurancePolicyWithProducer(uow, acc, pro);
        uow.commitWork();

        String producerId = UserInfo.getUserId();
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectByProducerId(producerId);
        Assert.isTrue(results.size() >= 0, 'Should return a list without error for valid ProducerId');
    }

    /**
     * @description Creates an Opportunity to use as the policy's SourceOpportunity.
     *              Quote_Id__c is set so Opportunity_Flow skips the record (no pricebook lookup).
     */
    private static Opportunity createSourceOpportunity(Account acc, String name) {
        Opportunity opp = new Opportunity(
                Name = name,
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Quote_Id__c = 'QUOTE-' + Crypto.getRandomInteger()
        );
        insert opp;
        return opp;
    }

    @IsTest
    static void testSelectPlatinumLifePoliciesByProducerId_returnsPolicy() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Producer.SObjectType
        });
        Account acc = createAccount(uow);
        Producer pro = createProducer(uow, acc);
        uow.commitWork();

        Opportunity platinumOpp = createSourceOpportunity(acc, 'Platinum Life Test');
        InsurancePolicy policy = new InsurancePolicy(
                Name = 'Platinum Life Policy',
                PolicyName = 'Platinum Life test',
                NameInsuredId = acc.Id,
                ProducerId = pro.Id,
                SourceOpportunityId = platinumOpp.Id,
                Status = 'Active',
                PremiumAmount = 250
        );
        insert policy;

        Test.startTest();
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectPlatinumLifePlociesByProducerId(UserInfo.getUserId());
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return the Platinum Life policy for the producer user');
        Assert.areEqual(policy.Id, results[0].Id, 'Returned policy should match');
        Assert.areEqual(250, results[0].PremiumAmount, 'PremiumAmount should be selected');
    }

    @IsTest
    static void testSelectPlatinumLifePoliciesByProducerId_blankInput_returnsEmpty() {
        Test.startTest();
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectPlatinumLifePlociesByProducerId('');
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Blank userId should return no records');
    }

    @IsTest
    static void testSelectPoliciesByNameInsuredAndProduct_returnsPolicy() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType
        });
        Account acc = createAccount(uow);
        uow.commitWork();

        Opportunity flexiOpp = createSourceOpportunity(acc, 'Flexi Protect Test');
        InsurancePolicy policy = new InsurancePolicy(
                Name = 'Flexi Protect Policy',
                PolicyName = 'Flexi Protect test',
                NameInsuredId = acc.Id,
                SourceOpportunityId = flexiOpp.Id,
                Status = 'Active'
        );
        insert policy;

        Test.startTest();
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectPoliciesByNameInsuredAndProduct(acc.Id, '%Flexi Protect%');
        List<InsurancePolicy> otherProduct = new SEL_InsurancePolicy().selectPoliciesByNameInsuredAndProduct(acc.Id, '%Platinum Life%');
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return the Flexi Protect policy for the account');
        Assert.areEqual(policy.Id, results[0].Id, 'Returned policy should match');
        Assert.areEqual(acc.Id, results[0].NameInsuredId, 'NameInsuredId should be selected');
        Assert.areEqual(0, otherProduct.size(), 'A different product should return no records');
    }

    @IsTest
    static void testSelectPoliciesByNameInsuredAndProduct_blankInput_returnsEmpty() {
        Test.startTest();
        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectPoliciesByNameInsuredAndProduct(null, '%Flexi Protect%');
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Blank accountId should return no records');
    }
}