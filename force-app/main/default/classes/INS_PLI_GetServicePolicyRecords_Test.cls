/**
 * @description       : Test class for INS_PLI_GetServicePolicyRecords Apex class Service Insurance Policy
 * @author            : Madito Tsilo
 * @UserStory         : SFP-53079
 * @date              : 25-10-2025
 ***************************************************
 * Last Modified By : Shams Arifeen
 * Last Modified Date : 23-10-2026
 * Last Modified Description : Updated all sections
 **/
@isTest
private class INS_PLI_GetServicePolicyRecords_Test {
    /**
     * @description Creates the Account and role data shared by the test methods.
     */
    @TestSetup
    private static void testSetup() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole role = new UserRole(Name = 'Portal Test Role');
            insert role;
            User owner = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
            owner.UserRoleId = role.Id;
            update owner;
            insert new Account(Name = 'Test Account', OwnerId = owner.Id);
        }
    }
    /**
     * @description Verifies that policy, payment, cover, and beneficiary data are returned for an Account.
     */
    @isTest
    static void test_getPoliciesForUser_withAccount() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        INS_PLI_GetServicePolicyRecords.accountIdOverride = acc.Id;
        Id currentUserId = UserInfo.getUserId();
        Product2 prod = new Product2(Name = 'Platinum Life Insurance', ProductCode = 'LIFE001', IsActive = true);
        insert prod;
        Id standardPricebookId = Test.getStandardPricebookId();
        insert new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = standardPricebookId, UnitPrice = 1000, IsActive = true, UseStandardPrice = false);
        Pricebook2 customPricebook = new Pricebook2(Name = 'C&HNW(Kenya)', IsActive = true);
        insert customPricebook;
        insert new PricebookEntry(Pricebook2Id = customPricebook.Id, Product2Id = prod.Id, UnitPrice = 120, IsActive = true, UseStandardPrice = false);
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Pricebook2Id = customPricebook.Id, Country__c = 'KE', OwnerId = currentUserId);
        insert opp;
        Quote quoteRecord = new Quote(Name = 'Test Quote', OpportunityId = opp.Id, OwnerId = currentUserId, Pricebook2Id = standardPricebookId);
        insert quoteRecord;
        InsurancePolicy policy = new InsurancePolicy(Name = 'POL12345', StandardPremiumAmount = 1000, PremiumAmount = 500, Premium_Payer__c = acc.Id, PremiumFrequency = 'Monthly', PaymentMethod__c = 'Debit Order', OwnerId = currentUserId, ProductId = prod.Id, NameInsuredId = acc.Id, SourceQuoteId = quoteRecord.Id);
        insert policy;
        insert new List<InsurancePolicyParticipant>{
            new InsurancePolicyParticipant(FirstName__c = 'John', LastName__c = 'Doe', Role = 'Insured', InsurancePolicyId = policy.Id, RelationshipToInsured = 'Spouse', BeneficiarySharePercentage = 60),
            new InsurancePolicyParticipant(FirstName__c = 'Anna', LastName__c = 'Doe', Role = 'Insured', InsurancePolicyId = policy.Id, RelationshipToInsured = 'Child', BeneficiarySharePercentage = 40)
        };
        Test.startTest();
        INS_PLI_GetServicePolicyRecords.PolicyWrapper result = INS_PLI_GetServicePolicyRecords.getPoliciesForUser();
        Test.stopTest();
        Assert.isNotNull(result);
        Assert.areEqual('Platinum Life Insurance', result.productName);
        Assert.areEqual('POL12345', result.policyNumber);
        Assert.isNull(result.errorMessage);
        Assert.areEqual(2, result.beneficiaries.size());
        Assert.areEqual('John Doe', result.beneficiaries[0].name);
        Assert.areEqual(60, result.beneficiaries[0].allocation);
        Assert.areEqual('Anna Doe', result.beneficiaries[1].name);
        Assert.areEqual(40, result.beneficiaries[1].allocation);
    }
    /**
     * @description Verifies the response when no Account is available for the logged-in user.
     */
    @isTest
    static void test_getPoliciesForUser_noAccount() {
        INS_PLI_GetServicePolicyRecords.accountIdOverride = null;
        Test.startTest();
        INS_PLI_GetServicePolicyRecords.PolicyWrapper result = INS_PLI_GetServicePolicyRecords.getPoliciesForUser();
        Test.stopTest();
        Assert.isNotNull(result);
        Assert.areEqual('No Account found for the logged-in user.', result.errorMessage);
        Assert.isNull(result.productName);
    }
    /**
     * @description Verifies that the beneficiaries list is initialized when the policy has no Quick Quote.
     */
    @isTest
    static void test_NoQuickQuote_BeneficiariesInitialized() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        INS_PLI_GetServicePolicyRecords.accountIdOverride = acc.Id;
        insert new InsurancePolicy(Name = 'POL-001', StandardPremiumAmount = 1000, PremiumAmount = 500, Premium_Payer__c = acc.Id, PaymentMethod__c = 'Debit Order', PremiumFrequency = 'Monthly', OwnerId = UserInfo.getUserId(), NameInsuredId = acc.Id);
        Test.startTest();
        INS_PLI_GetServicePolicyRecords.PolicyWrapper result = INS_PLI_GetServicePolicyRecords.getPoliciesForUser();
        Test.stopTest();
        Assert.isNotNull(result);
        Assert.areEqual(0, result.beneficiaries.size());
    }
}