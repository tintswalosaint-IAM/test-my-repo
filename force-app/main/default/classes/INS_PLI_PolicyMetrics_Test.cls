@IsTest
public with sharing class INS_PLI_PolicyMetrics_Test {

    // Constants to avoid duplicate literals
    private static final String STATUS_SOLD = 'Draft';
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final String TEST_CANCELLATION_REASON = 'Test Cancellation Reason';
    private static final String CANCELLATION_REASON_TYPE_REWRITTEN = 'Rewritten';
    private static final String COUNTRY_KE = 'KE';
    private static final String PRICEBOOK_KENYA = 'C&HNW(Kenya)';
    private static final String RT_GENERAL = 'General';
    private static final String PRODUCT_NAME_PLATINUM = 'Platinum Life Insurance';
    private static final String PRODUCT_CODE_LIFE = 'LIFE001';

    // Utility to get Opportunity RT
    private static Id getOpportunityRT() {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(RT_GENERAL).getRecordTypeId();
    }

    @TestSetup
    static void setupTestData() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, Opportunity.SObjectType, InsurancePolicy.SObjectType, Producer.SObjectType
        });

        Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;

        Id stdPricebookId = Test.getStandardPricebookId();


        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;

        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true
        );
        insert customPricebook;

       Account acc = new Account(
                FirstName = 'Test',
                LastName = 'Customer',
                PersonBirthdate = Date.newInstance(1990, 1, 1),
                PersonEmail = 'test.customer.' + System.currentTimeMillis() + '@example.com',
                OwnerId = UserInfo.getUserId()
        );
        uow.registerNew(acc);

        String oppName = acc.FirstName + ' ' + acc.LastName + ' Platinum Life Insurance '
                + Date.today().format();
        Opportunity opp = new Opportunity(
                Name = oppName,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1),
                Country__c = COUNTRY_KE,
                Pricebook2Id = customPricebook.Id,
                CurrencyIsoCode = 'KES',
                RecordTypeId = getOpportunityRT()
        );
        uow.registerNew(opp, Opportunity.AccountId, acc);

        Producer producer = new Producer(
                Name = 'Test Producer',
                InternalUserId = UserInfo.getUserId(),
                AccountId = acc.id
        );
        uow.registerNew(producer);
        uow.commitWork();
    }

    private static InsurancePolicy createInsurancePolicy(CMN_DAL_SObjectUnitOfWork uow, Account nameInsured, Id producerId, String status, Decimal premiumAmount) {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        InsurancePolicy policy = new InsurancePolicy(
                Name = 'Test Policy ' + System.currentTimeMillis(),
            	PolicyName = 'Platinum Life test',
                NameInsuredId = nameInsured.Id,
                OwnerId = UserInfo.getUserId(),
                ProducerId = producerId,
                Status = status,
                PremiumAmount = premiumAmount,
                SourceOpportunityId = opp.Id
        );

        if (status == STATUS_CANCELLED) {
            policy.CancellationReason = TEST_CANCELLATION_REASON;
            policy.CancellationReasonType = CANCELLATION_REASON_TYPE_REWRITTEN;
            policy.CancellationDate = Date.today();
        }

        uow.registerNew(policy, InsurancePolicy.NameInsuredId, nameInsured);
        return policy;
    }

    @IsTest
    static void testGetPolicyMetricsData_onlySoldPolicies() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType
        });
        Account acc = [SELECT Id FROM Account];
        Producer testProducer  = [SELECT Id FROM Producer];
        Id userId = UserInfo.getUserId();

        createInsurancePolicy(uow, acc, testProducer .Id, STATUS_SOLD, 1000);
        createInsurancePolicy(uow, acc, testProducer .Id, STATUS_SOLD, 2000);

        uow.commitWork();

        Test.startTest();
        INS_PLI_PolicyMetrics.PolicyMetricsData result = INS_PLI_PolicyMetrics.getPolicyMetricsData(userId);
        Test.stopTest();

        Assert.areEqual(3000, result.premiumOfPolicies, 'Total premium should be sum of sold policies');
        Assert.areEqual(2, result.policiesSold, 'Should return 2 sold policies');
        Assert.areEqual(0, result.policiesCanceled, 'Should return 0 cancelled policies');
    }

    @IsTest
    static void testGetPolicyMetricsData_onlyCancelledPolicies() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType
        });
        Account acc = [SELECT Id FROM Account];
        Producer testProducer = [SELECT Id FROM Producer];
        Id userId = UserInfo.getUserId();

        createInsurancePolicy(uow, acc, testProducer.Id, STATUS_CANCELLED, 500);
        createInsurancePolicy(uow, acc, testProducer.Id, STATUS_CANCELLED, 750);

        uow.commitWork();

        Test.startTest();
        INS_PLI_PolicyMetrics.PolicyMetricsData result = INS_PLI_PolicyMetrics.getPolicyMetricsData(userId);
        Test.stopTest();

        Assert.areEqual(1250, result.premiumOfPolicies, 'Total premium should be sum of cancelled policies');
        Assert.areEqual(0, result.policiesSold, 'Should return 0 sold policies');
        Assert.areEqual(2, result.policiesCanceled, 'Should return 2 cancelled policies');
    }

    @IsTest
    static void testGetPolicyMetricsData_noPolicies() {
        Id userId = UserInfo.getUserId();

        Test.startTest();
        INS_PLI_PolicyMetrics.PolicyMetricsData result = INS_PLI_PolicyMetrics.getPolicyMetricsData(userId);
        Test.stopTest();

        Assert.areEqual(0, result.premiumOfPolicies, 'Total premium should be 0 when no policies exist');
        Assert.areEqual(0, result.policiesSold, 'Should return 0 sold policies');
        Assert.areEqual(0, result.policiesCanceled, 'Should return 0 cancelled policies');
    }

    @IsTest
    static void testGetPolicyMetricsData_policiesWithNullPremium() {
        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>{
                Account.SObjectType, InsurancePolicy.SObjectType
        });
        Account acc = [SELECT Id FROM Account];
        Producer testProducer = [SELECT Id FROM Producer];
        Id userId = UserInfo.getUserId();

        createInsurancePolicy(uow, acc, testProducer.Id, STATUS_SOLD, null);
        createInsurancePolicy(uow, acc, testProducer.Id, STATUS_SOLD, 1000);

        uow.commitWork();

        Test.startTest();
        INS_PLI_PolicyMetrics.PolicyMetricsData result = INS_PLI_PolicyMetrics.getPolicyMetricsData(userId);
        Test.stopTest();

        Assert.areEqual(1000, result.premiumOfPolicies, 'Total premium should only include policies with premium amount');
        Assert.areEqual(2, result.policiesSold, 'Should return 2 sold policies');
    }
}