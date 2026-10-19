/**
 * @description       : Test class for INS_PLI_GetServicePolicyRecords Apex class Service Insurance Policy
 * @author            : Madito Tsilo
 * @UserStory         : SFP-53079
 * @date              : 25-10-2025
 **/
@isTest
private class INS_PLI_GetServicePolicyRecords_Test {
    @TestSetup
    private static void testSetup() {
        createBaseTestUser(true);
    }
   
  // Reusable setup method to create base data
    private static User createBaseTestUser(Boolean withAccount) {
        Contact con; 
        System.runAs(new User(Id = UserInfo.getUserId())) {
        UserRole role = new UserRole(Name = 'Portal Role');
        insert role;

        // Fetch a system admin as the owner
        User owner = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        owner.UserRoleId = role.Id;
        update owner;

        // Optionally create an Account
        Account acc;
        if (withAccount) {
            acc = new Account(Name = 'Test Account', OwnerId = owner.Id);
            insert acc;
        }

        // Create a Contact linked to Account (or not)
            con = new Contact(
            FirstName = 'Client',
            LastName = 'Test',
            Email = 'client@test.com',
            Phone = '+254232323232',
            AccountId = withAccount ? acc.Id : null
        );
        insert con;
      }
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE 'Customer Community%' LIMIT 1];

        User testUser = new User(
            FirstName = 'Portal',
            LastName = 'User9643',
            Email = 'portal.user@example.com',
            Username = 'portal.user.' + System.currentTimeMillis() + '@test.com',
            Alias = 'puser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            ContactId = con.Id
        );
        insert testUser;

        assignPermSets(testUser);

        return testUser;
      }    

    private static void assignPermSets(User u) {
        List<String> permSetApiName = new List<String>{
            'FSCInsurance',
            'Platinum_Life_Insurance_Policy_Access_Clients'
        };
        List<PermissionSet> permSets = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :permSetApiName
        ];
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        for (PermissionSet ps : permSets) {
            psa.add(
                new PermissionSetAssignment(
                    PermissionSetId = ps.Id,
                    AssigneeId = u.Id
                )
            );
        }
        insert psa;
    }

    // Positive test — AccountId is present
    @isTest
    static void test_getPoliciesForUser_withAccount() {
        User testUser = [SELECT Id, ContactId FROM User WHERE LastName = 'User9643'];
		
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
        // Create a Custom Pricebook and Entry
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
        // Get related Account and Contact
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Id = :testUser.ContactId LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = con.AccountId,
            StageName = 'Prospecting',     
            CloseDate = Date.today().addDays(30), // Required
            Pricebook2Id = customPricebook.Id, 
            Country__c = 'KE',
            OwnerId = testUser.Id 
        );
		insert opp;
        
		// Create a Quote (or whatever object SourceQuoteId references)
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            OwnerId = testUser.Id,
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
            OwnerId = testUser.Id,
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
		
        Test.setMock(HttpCalloutMock.class, new INS_GetQuickQuote_Mock());
        System.runAs(testUser) {
            Test.startTest();
            INS_PLI_GetServicePolicyRecords.PolicyWrapper result =
                INS_PLI_GetServicePolicyRecords.getPoliciesForUser();
            Test.stopTest();

            Assert.areNotEqual(null, result, 'Wrapper should not be null');
            Assert.areEqual('Platinum Life Insurance', result.productName);
            Assert.areEqual('POL12345', result.policyNumber);
            Assert.areEqual(null, result.errorMessage, 'Error message should be null for valid user');
            
            //  Beneficiary assertions
            Assert.isTrue(result.beneficiaries.size() == 2, 'Should have returned 2 beneficiaries');
    
            INS_PLI_GetServicePolicyRecords.BeneficiaryWrapper b1 = result.beneficiaries[0];
            Assert.areEqual('John Doe', b1.name);
            Assert.areEqual(60, b1.allocation);
    
            INS_PLI_GetServicePolicyRecords.BeneficiaryWrapper b2 = result.beneficiaries[1];
            Assert.areEqual('Anna Doe', b2.name);
            Assert.areEqual(40, b2.allocation);
        }
    }

    // Negative test — AccountId is null
    @isTest
    static void test_getPoliciesForUser_noAccount() {
        User testUser = [SELECT Id, ContactId FROM User WHERE LastName = 'User9643'];
        Product2 prod = new Product2(
            Name = 'Platinum Life Insurance',
            ProductCode = 'LIFE001',
            IsActive = true
        );
        insert prod;

        // Get related Account and Contact
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Id = :testUser.ContactId LIMIT 1];

        InsurancePolicy pol = new InsurancePolicy(
            Name = 'POL12345',
            StandardPremiumAmount = 1000,
            PremiumAmount = 500,
            Premium_Payer__c = con.AccountId,
            PremiumFrequency = 'Monthly',
            PaymentMethod__c = 'Debit Order',
            OwnerId = testUser.Id,
            ProductId = prod.Id,
            NameInsuredId = con.AccountId
        );
        insert pol;        
        System.runAs(new User(Id = UserInfo.getUserId())) {        
            Test.startTest();
            INS_PLI_GetServicePolicyRecords.PolicyWrapper result =
                INS_PLI_GetServicePolicyRecords.getPoliciesForUser();
            Test.stopTest();

            Assert.areNotEqual(null, result, 'Wrapper should still be returned');
            Assert.areEqual('No Account found for the logged-in user.', result.errorMessage,
                'Expected error message when AccountId is null');
            Assert.areEqual(null, result.productName, 'No product should be set');        
       }  
    } 		
	@isTest
    static void test_NoQuickQuote_BeneficiariesInitialized() {
        User usr = [SELECT Id, ContactId FROM User WHERE LastName = 'User9643'];
         // Get related Account and Contact
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Id = :usr.ContactId LIMIT 1];        
            InsurancePolicy pol = new InsurancePolicy(
                Name = 'POL-001',
                StandardPremiumAmount = 1000,
            	PremiumAmount = 500,                
                SourceQuoteId = null, // forces blank quoteId
                Premium_Payer__c = con.AccountId,
                PaymentMethod__c = 'Debit Order',
                PremiumFrequency = 'Monthly',
                OwnerId = usr.Id,
                NameInsuredId = con.AccountId
            );
            insert pol;
        	System.runAs(usr) {
			Test.setMock(HttpCalloutMock.class, new INS_GetQuickQuote_Mock());
            Test.startTest();
            INS_PLI_GetServicePolicyRecords.PolicyWrapper result =
                INS_PLI_GetServicePolicyRecords.getPoliciesForUser();
            Test.stopTest(); 
            Assert.isNotNull(result, 'Wrapper should not be null');            
            Assert.areEqual(0, result.beneficiaries.size(), 'Beneficiaries list should be empty when Quick Quote is null');
          }       
     }    
}