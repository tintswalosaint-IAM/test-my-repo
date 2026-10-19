/**
 * @description       : Test class for INS_PLI_GetServicingRecords Helper class for retrieving servicing records and customer details
 * @author            : Vershley Joyejob
 * @UserStory         : SFP-53079
 * @date              : 15-10-2025
 ***************************************************
 * Last Modified By Shams
 * Last Modified Date 24/07/2026
 * Last Modified Description: Added coverage after adding the new field ProductName
 * User Story : SFP-59435
**/
@isTest
public class INS_PLI_GetServicingRecords_TEST {
    
    @testSetup
    static void setupTestData() {
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User adminUser = new User(
            FirstName = 'Admin',
            LastName = 'User',
            Email = 'adminuser@example.org',
            Username = 'adminuser' + DateTime.now().getTime() + '@example.org',
            Alias = 'admusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = adminProfile.Id,
            UserRoleId = portalRole.Id
        );
        insert adminUser;
    }

    @isTest
    static void testGetServicingRecords() {
        User adminUser = [SELECT Id FROM User WHERE Email = 'adminuser@example.org' LIMIT 1];
        
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Account.sObjectType, Contact.sObjectType, User.sObjectType }
        );
        
        Account acc = new Account(
            Name = 'Test Account',
            Phone = '+27823309876',
            AOB_CommerceSiteId__c = 'SB-COZA',
            AOB_TECH_CCCustomerId__c = '12345',
            ExternalCIFUUID__c = 'RandomUUID-123'
        );
        uow.registerNew(acc, Account.OwnerId, adminUser);

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.org'
        );
        uow.registerNew(con, Contact.AccountId, acc);
        
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' OR Name LIKE '%Community%' LIMIT 1];

        User communityUser = new User(
            FirstName = 'Test',
            LastName = 'CommunityUser',
            Email = 'communityuser@example.org',
            Username = 'communityuser' + DateTime.now().getTime() + '@example.org',
            Alias = 'tcomu',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = communityProfile.Id
        );
        uow.registerNew(communityUser, User.ContactId, con);
        uow.commitWork();
        
        Test.startTest();
        System.runAs(communityUser) {
            INS_PLI_GetServicingRecords.getConnectedCustomerDetails(communityUser.Id);
        }
        Test.stopTest();

        Assert.isTrue(true, 'Method executed successfully without QueryException');
    }

    @isTest
    static void testGetConnectedCustomerDetails_InvalidUserId() {
        Test.startTest();
        try {
            INS_PLI_GetServicingRecords.getConnectedCustomerDetails('');
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Exception message should match expected value');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetConnectedCustomerDetails_UserWithoutContact() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ User.sObjectType }
        );
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'UserNoContact',
            Email = 'nocontact@example.org',
            Username = 'nocontact' + DateTime.now().getTime() + '@example.org',
            Alias = 'tunoc',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = adminProfile.Id
        );
        uow.registerNew(testUser);
        uow.commitWork();

        Test.startTest();
        try {
            INS_PLI_GetServicingRecords.getConnectedCustomerDetails(testUser.Id);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Exception message should match expected value');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetPoliciesForUser_NoPolicies() {
        User adminUser = [SELECT Id FROM User WHERE Email = 'adminuser@example.org' LIMIT 1];
        
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Account.sObjectType, Contact.sObjectType, User.sObjectType }
        );
        
        Account acc = new Account(
            Name = 'Test Account',
            Phone = '+27823309876',
            AOB_CommerceSiteId__c = 'SB-COZA',
            AOB_TECH_CCCustomerId__c = '12345',
            ExternalCIFUUID__c = 'RandomUUID-123'
        );
        uow.registerNew(acc, Account.OwnerId, adminUser);

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.org'
        );
        uow.registerNew(con, Contact.AccountId, acc);
        
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' OR Name LIKE '%Community%' LIMIT 1];

        User communityUser = new User(
            FirstName = 'Test',
            LastName = 'NoPolicyUser',
            Email = 'nopolicyuser@example.org',
            Username = 'nopolicyuser' + DateTime.now().getTime() + '@example.org',
            Alias = 'tnpol',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = communityProfile.Id
        );
        uow.registerNew(communityUser, User.ContactId, con);
        uow.commitWork();
        
        Test.startTest();
        System.runAs(communityUser) {
            List<INS_PLI_GetServicingRecords.PolicyWrapper> result = INS_PLI_GetServicingRecords.getPoliciesForUser();
            Assert.isNotNull(result, 'Result should not be null');           
            Assert.areEqual('No Policies found for your account', result[0].errorMessage, 'Should return error message when no Policies are found');
        }
        Test.stopTest();
    }

    @isTest
    static void testPolicyWrapper() {
        INS_PLI_GetServicingRecords.PolicyWrapper wrapper = new INS_PLI_GetServicingRecords.PolicyWrapper(
            'testId',
            'Test Policy',
            'Test Product',
            'Test Owner',
            50000.00,
            1000.00
        );
        
        Assert.areEqual('testId', wrapper.id, 'ID should match');
        Assert.areEqual('Test Product', wrapper.productName, 'Product name should match');
        Assert.areEqual('Test Policy', wrapper.name, 'Name should match');
        Assert.areEqual('Test Owner', wrapper.owner, 'Owner should match');
        Assert.areEqual('KES 50000.00', wrapper.coverAmount, 'Cover amount should be formatted with KES');
        Assert.areEqual('KES 1000.00 p.m', wrapper.premium, 'Premium should be formatted with KES and p.m');
    }

    @isTest
    static void testPolicyWrapper_NullValues() {
        INS_PLI_GetServicingRecords.PolicyWrapper wrapper = new INS_PLI_GetServicingRecords.PolicyWrapper(
            'testId',
            'Test Policy',
            null,
            'Test Owner',
            null,
            null
        );
        
        Assert.areEqual('testId', wrapper.id, 'ID should match');
        Assert.areEqual(null, wrapper.productName, 'Product name should be null');
        Assert.areEqual('Test Policy', wrapper.name, 'Name should match');
        Assert.areEqual('Test Owner', wrapper.owner, 'Owner should match');
        Assert.areEqual('', wrapper.coverAmount, 'Cover amount should be empty string for null');
        Assert.areEqual('', wrapper.premium, 'Premium should be empty string for null');
    }    
    @isTest
    static void testGetPoliciesForUser_UserWithoutAccount() {
        Account acc;
        UserRole role;
        User adminUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {        
             role = new UserRole(Name = 'Portal Role');
            insert role;
        
        adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        adminUser.UserRoleId = role.Id;
        update adminUser;
        
         acc = new Account(
            Name = 'Test Account for Quotes',
            OwnerId = adminUser.Id
        );
        insert acc; 
      }    
        // Initialize Unit of Work
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Contact.sObjectType, User.sObjectType }
        );       
        
        Contact orphanContact = new Contact(
            FirstName = 'Orphan',
            LastName = 'Contact',
            Email = 'orphancontact@example.org',
			AccountId = acc.Id,
			OwnerId = adminUser.Id            
        );
        uow.registerNew(orphanContact);
        
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' OR Name LIKE '%Community%' LIMIT 1];
        User orphanUser = new User(
            FirstName = 'NoAccount',
            LastName = 'User',
            Email = 'noaccountuser@example.org',
            Username = 'noaccountuser' + DateTime.now().getTime() + '@example.org',
            Alias = 'noacc',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = communityProfile.Id,
            ContactId = orphanContact.Id
        );
        uow.registerNew(orphanUser, User.ContactId, orphanContact);
        uow.commitWork();
        
        Test.startTest();
        List<INS_PLI_GetServicingRecords.PolicyWrapper> result;        
         System.runAs(new User(Id = UserInfo.getUserId())){
            result = INS_PLI_GetServicingRecords.getPoliciesForUser();
        }
        Test.stopTest();

        // Assert
        Assert.areNotEqual(null, result, 'Result list should not be null');
        Assert.areEqual(1, result.size(), 'Should return one result (error wrapper)');
        Assert.areEqual('No Account found for the logged-in user.', result[0].errorMessage,
            'Error message should match expected value');
    }
    
    @isTest
	static void testGetTaxDetailsForLoggedInUser_Success() {
    Account acc;
    UserRole role;
    User adminUser;
    System.runAs(new User(Id = UserInfo.getUserId())) {  
      role = new UserRole(Name = 'Portal Role');
      insert role;
        
      adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
      adminUser.UserRoleId = role.Id;
      update adminUser;        
      acc = new Account(
            Name = 'Test Account for Tax Details',
            OwnerId = adminUser.Id
        );
     insert acc; 
   }  

    Contact con = new Contact(
        FirstName = 'Tax',
        LastName = 'User',
        Email = 'taxuser@example.org',
        AccountId = acc.Id
    );
    insert con;

    Profile communityProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];

    User communityUser = new User(
        FirstName = 'Tax',
        LastName = 'Community',
        Email = 'taxcommunity@example.org',
        Username = 'taxcommunity' + DateTime.now().getTime() + '@example.org',
        Alias = 'taxcu',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        ProfileId = communityProfile.Id,
        ContactId = con.Id
    );
    insert communityUser;

    // Insert Tax Details
    TaxDetails__c tax = new TaxDetails__c(
        Account__c = acc.Id,
        TaxNumber__c = 'TX123456',
        OwnerId = communityUser.Id
    );
    insert tax;

        Test.startTest();
        System.runAs(communityUser) {
            List<TaxDetails__c> result = INS_PLI_GetServicingRecords.getTaxDetailsForLoggedInUser();    
            Assert.areEqual(1, result.size(), 'One tax record should be returned');
            Assert.areEqual(acc.Id, result[0].Account__c);
        }
        Test.stopTest();
	}    
    @isTest
	static void testGetPoliciesForUser_WithPolicies() {
    	Account acc;
        UserRole role;
        User adminUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {        
             role = new UserRole(Name = 'Portal Role');
            insert role;
        
        adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        adminUser.UserRoleId = role.Id;
        update adminUser;
        
         acc = new Account(
            Name = 'Test Account for Tax Details',
            OwnerId = adminUser.Id
        );
        insert acc; 
      }
    Contact con = new Contact(
        FirstName = 'Policy',
        LastName = 'Holder',
        Email = 'policyholder@example.org',
        AccountId = acc.Id
    );
    insert con;
    Profile communityProfile = [
        SELECT Id
        FROM Profile
        WHERE Name LIKE '%Community%'
        LIMIT 1
    ];
    User communityUser = new User(
        FirstName = 'Policy',
        LastName = 'User',
        Email = 'policyuser@example.org',
        Username = 'policyuser' + DateTime.now().getTime() + '@example.org',
        Alias = 'polu',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'ISO-8859-1',
        LanguageLocaleKey = 'en_US',
        ProfileId = communityProfile.Id,
        ContactId = con.Id
    );
    insert communityUser;
    Product2 prod = new Product2(
        Name = 'Test Product',
        ProductCode = 'TEST-PROD',
        IsActive = true
    );
    insert prod;
    // Create Policy
    InsurancePolicy policy = new InsurancePolicy(
        Name = 'Test Policy',
        NameInsuredId = acc.Id,
        TotalSumInsured = 100000,
        PremiumAmount = 1500,
        ProductId = prod.Id,
        OwnerId = communityUser.Id
    );
    insert policy;
        Test.startTest();
        System.runAs(communityUser) {
            List<INS_PLI_GetServicingRecords.PolicyWrapper> result = INS_PLI_GetServicingRecords.getPoliciesForUser();    
            Assert.areEqual(1, result.size());
            Assert.isNull(result[0].errorMessage);
            Assert.areEqual('Test Product', result[0].productName);
            Assert.areEqual('Test Policy', result[0].name);
            Assert.areEqual('KES 100000.00', result[0].coverAmount);
            Assert.areEqual('KES 1500.00 p.m', result[0].premium);        
        Test.stopTest();
       }
	}
}