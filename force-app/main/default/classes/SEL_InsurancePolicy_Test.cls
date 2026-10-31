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

    private static InsurancePolicy createPolicyForOpportunity(String opportunityName) {
        Account account = new Account(
            RecordTypeId = getPersonAccountProspectRT(),
            FirstName = 'Policy',
            LastName = 'Customer',
            PersonBirthdate = Date.newInstance(1990, 1, 1)
        );
        insert account;

        Producer producer = new Producer(
            Name = 'Policy Producer',
            InternalUserId = UserInfo.getUserId(),
            AccountId = account.Id
        );
        insert producer;

        Opportunity opportunity = new Opportunity(
            Name = opportunityName,
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Country__c = 'KE'
        );
        insert opportunity;

        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Opportunity Policy',
            PolicyName = 'Platinum Life Policy',
            NameInsuredId = account.Id,
            ProducerId = producer.Id,
            SourceOpportunityId = opportunity.Id,
            Status = 'Active',
            PremiumAmount = 500
        );
        insert policy;
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
    static void testSelectByProducerId_returnsPolicy() {
        InsurancePolicy policy = createPolicyForOpportunity('Producer Policy Opportunity');

        List<InsurancePolicy> results = new SEL_InsurancePolicy().selectByProducerId(UserInfo.getUserId());
        Assert.areEqual(1, results.size(), 'Should return the policy for the producer.');
        Assert.areEqual(policy.Id, results[0].Id, 'Should return the policy for the producer.');
    }

    @IsTest
    static void testSelectPolicyMethodsWithBlankInputs() {
        SEL_InsurancePolicy selector = new SEL_InsurancePolicy();

        Assert.isTrue(selector.selectByProducerId(null).isEmpty(), 'A null producer ID should return no policies.');
        Assert.isTrue(selector.selectPlatinumLifePlociesByProducerId(' ').isEmpty(), 'A blank producer ID should return no policies.');
        Assert.isTrue(selector.selectPoliciesByNameInsuredAndProduct(null, '%Platinum Life%').isEmpty(), 'A null insured ID should return no policies.');
    }

    @IsTest
    static void testSelectPoliciesByProducerAndProduct() {
        InsurancePolicy policy = createPolicyForOpportunity('Platinum Life Coverage');
        SEL_InsurancePolicy selector = new SEL_InsurancePolicy();

        List<InsurancePolicy> platinumLifePolicies = selector.selectPlatinumLifePlociesByProducerId(UserInfo.getUserId());
        List<InsurancePolicy> policiesByProduct = selector.selectPoliciesByNameInsuredAndProduct(
            policy.NameInsuredId,
            '%Platinum Life%'
        );

        Assert.areEqual(1, platinumLifePolicies.size(), 'Should return the Platinum Life policy for the producer.');
        Assert.areEqual(policy.Id, platinumLifePolicies[0].Id, 'Should return the expected Platinum Life policy.');
        Assert.areEqual(1, policiesByProduct.size(), 'Should return the policy for the insured person and product.');
        Assert.areEqual(policy.Id, policiesByProduct[0].Id, 'Should return the expected policy.');
    }
}