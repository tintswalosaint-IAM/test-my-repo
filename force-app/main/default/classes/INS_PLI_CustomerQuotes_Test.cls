/**
 * @description       : Test class for INS_PLI_CustomerQuotes Apex class (Customer Quotes retrieval)
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52960
 * @date              : 31-10-2025
 **/
@isTest
private class INS_PLI_CustomerQuotes_Test {
    
    private static PermissionSet createQuotePermissionSet() {
        PermissionSet ps = new PermissionSet(
            Name = 'Quote_And_Opportunity_Access',
        	Label = 'Quote and Opportunity Access'
        );
        insert ps;
		// Grant Opportunity read access first (dependency)
        ObjectPermissions oppPerm = new ObjectPermissions(
            ParentId = ps.Id,
            SObjectType = 'Opportunity',
            PermissionsRead = true,
            PermissionsViewAllRecords = false,
            PermissionsCreate = false,
            PermissionsEdit = true,
            PermissionsDelete = false,
            PermissionsModifyAllRecords = false
        );
        insert oppPerm;
        
        ObjectPermissions quotePerm  = new ObjectPermissions(
            ParentId = ps.Id,
            SObjectType = 'Quote',
            PermissionsRead = true,
            PermissionsCreate = false,
            PermissionsEdit = true,
            PermissionsDelete = false,
            PermissionsViewAllRecords = false,
            PermissionsModifyAllRecords = false
        );
        insert quotePerm;
        
        // Grant Field Level Security for the field 
        List<String> fields = new List<String>{
            'Quote.INS_PolicyDocumentLatestStatus__c',
            'Quote.INS_MonthlyPremium__c',
            'Quote.UnderwriterQuoteReferenceNumber__c'
        };
        List<FieldPermissions> fps = new List<FieldPermissions>();
        for (String fld : fields) {
            fps.add(
                new FieldPermissions(
                    ParentId = ps.Id,
                    SObjectType = 'Quote',
                    Field = fld,
                    PermissionsRead = true,
                    PermissionsEdit = true
                )
            );
        }
        insert fps;
        return ps;
    }

    private static void assignPermissionSetTo(User u, PermissionSet ps) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
    }
    
    //  Utility: Creates a portal user with related contact and account
    private static User createPortalUser(Boolean linkAccount) {
        UserRole role; 
        Account acc;
        // Create Role (some orgs require this for community users)
       System.runAs(new User(Id = UserInfo.getUserId())) {
            role = new UserRole(Name = 'Portal Role');
            insert role;      
           
            // Step 2: Get a base System Administrator user and assign role
            User owner = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
            owner.UserRoleId = role.Id;
            update owner; 
                       
            if (linkAccount) {                          
                acc = new Account(
                    Name = 'Test Account for Quotes',
                    OwnerId = owner.Id
                );
                insert acc;
            }
       }
        // Create Contact (linked to Account only if requested)
        Contact con = new Contact(
            FirstName = 'Quote',
            LastName = 'Client',
            Email = 'quote.client@test.com',
            Phone = '+27123456789',
            AccountId = linkAccount ? acc.Id : null
        );
        insert con;

        // Retrieve Customer Community profile
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE 'Customer Community%' LIMIT 1];

        // Create portal user
        User testUser = new User(
            FirstName = 'Portal',
            LastName = 'QuoteUser',
            Email = 'portal.quoteuser.' + System.currentTimeMillis() + '@example.com',
            Username = 'portal.quoteuser.' + System.currentTimeMillis() + '@test.com',
            Alias = 'pquser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,            
            ContactId = con.Id
        );
        insert testUser;
       
       return testUser;
     }
         
    // Scenario 1: Valid user with account + quotes
    @isTest
    static void test_validQuotesReturned() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
        User testUser = createPortalUser(true);
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for Quotes' LIMIT 1];		
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
        // Create Opportunity + Quote
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            OwnerId = testUser.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Pricebook2Id = customPricebook.Id
        );
        insert opp;

        Quote qt = new Quote(
            Name = 'Quote A',            
            OwnerId = testUser.Id,			            
            OpportunityId = opp.Id,
            ExpirationDate = Date.today().addDays(30),
            INS_MonthlyPremium__c = 1200.50,
            UnderwriterQuoteReferenceNumber__c = 'UQRNum1'
        );        
        insert qt;
		PermissionSet ps = createQuotePermissionSet();
		assignPermissionSetTo(testUser, ps);
        System.runAs(testUser) {             
            Test.startTest();            
            List<INS_PLI_CustomerQuotes.QuoteWrapper> results;                 
            results = INS_PLI_CustomerQuotes.getCustomerQuotes();                
            Test.stopTest();            
            Assert.areNotEqual(null, results, 'Results should not be null');           
            Assert.isTrue(results.size() > 0, 'Should return at least one quote');            
            Assert.areEqual('Quote A', results[0].name, 'Quote name should match');           
            Assert.areEqual('1200.50', results[0].estimatedPayment, 'Estimated payment should match');
            
        }
    }
  }
    // Scenario 2: User has no account (should return error message)
    @isTest
    static void test_missingAccount() {        
        System.runAs(new User(Id = UserInfo.getUserId())) {                 
            Test.startTest();
            List<INS_PLI_CustomerQuotes.QuoteWrapper> results = INS_PLI_CustomerQuotes.getCustomerQuotes();
            Test.stopTest();
            Assert.areEqual(1, results.size(), 'Should return one wrapper');
            Assert.areEqual('No Account found for the logged-in user.', results[0].errorMessage);    	
     }
  }
    // Scenario 3: User has account but no quotes (should return “no quotes found” message)
    @isTest
    static void test_noQuotesFound() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User testUser = createPortalUser(true);
    		PermissionSet ps = createQuotePermissionSet();
			assignPermissionSetTo(testUser, ps);
            System.runAs(testUser) {
                Test.startTest();
                List<INS_PLI_CustomerQuotes.QuoteWrapper> results;
                System.runAs(new User(Id = UserInfo.getUserId())) {                
               	results = INS_PLI_CustomerQuotes.getCustomerQuotes();
                }    
                Test.stopTest();    
                Assert.areEqual(1, results.size(), 'Should return one wrapper');
                Assert.areEqual('No quotes found for your account.', results[0].errorMessage);
           }
        }
    }          
}