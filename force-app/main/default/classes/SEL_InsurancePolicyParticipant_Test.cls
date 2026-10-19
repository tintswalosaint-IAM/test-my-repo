/**
 * @description Test class for InsurancePolicyParticipant selector
 * @author Alexandr Goryachko
 * @date 30-03-2026
 * @userStory SFP-53079
 */
@IsTest
public class SEL_InsurancePolicyParticipant_Test {
    @TestSetup
    private static void testSetup() {
        Product2 prod = new Product2(
            Name = 'Platinum Life Insurance',
            ProductCode = 'LIFE001',
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
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'C&HNW(Kenya)',
            IsActive = true
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry; 
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(
            FirstName = 'Client',
            LastName = 'Test',
            Email = 'client@test.com',
            Phone = '+254232323232',
            AccountId = acc.Id
        );
        insert con;
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = con.AccountId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = customPricebook.Id, 
            Country__c = 'KE',
            OwnerId = UserInfo.getUserId()
        );
        insert opp;
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            OwnerId = UserInfo.getUserId(),
            Pricebook2Id = stdPricebookId
        );
        insert qt;
        InsurancePolicy pol = new InsurancePolicy(
            Name = 'POL12345',
            StandardPremiumAmount = 1000,
            PremiumAmount = 500,
            Premium_Payer__c = con.AccountId,
            PremiumFrequency = 'Monthly',
            PaymentMethod__c = 'Debit Order',
            OwnerId = UserInfo.getUserId(),
            ProductId = prod.Id,
            NameInsuredId = con.AccountId,
            SourceQuoteId = qt.Id
        );
        insert pol;
        insert new List<InsurancePolicyParticipant>{
            new InsurancePolicyParticipant(
                FirstName__c = 'John',
                LastName__c = 'Doe',
                Role = 'Insured',
                InsurancePolicyId = pol.Id,
                RelationshipToInsured = 'Spouse',
                BeneficiarySharePercentage = 60
            ),
            new InsurancePolicyParticipant(
                FirstName__c = 'Anna',
                LastName__c = 'Doe',
                Role = 'Insured',
                InsurancePolicyId = pol.Id,
                RelationshipToInsured = 'Child',
                BeneficiarySharePercentage = 40
            )
        };
    }

    @IsTest
    private static void selectByInsurancePolicyIdsTest() {
        InsurancePolicy pol = [SELECT Id FROM InsurancePolicy LIMIT 1];
        Test.startTest();
        List<InsurancePolicyParticipant> participants = new SEL_InsurancePolicyParticipant().selectByInsurancePolicyIds(new List<Id>{pol.Id});
        Test.stopTest();

        Assert.isTrue(participants.size() == 2, 'Should have returned 2 beneficiaries');
    }
}