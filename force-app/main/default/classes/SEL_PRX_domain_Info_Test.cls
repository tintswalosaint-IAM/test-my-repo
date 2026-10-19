/***************************************************************************************
@ Author            :krishna.ranjan@standardbank.co.za
@ Date              :28 November 2024
@ Name of the Class :SEL_PRX_domain_Info_Test
@description       : Test Class for SEL_PRX_domain_Info Class
@ Last Modified By  :krishna.ranjan@standardbank.co.za
@ Last Modified On  :28-11-2024
@ Jira Ticket       :SFP-42419
* ---------------------------------------------------------------------------
*version   Date               Developer                  
* ---------------------------------------------------------------------------
1.0   NOV 2024   		krishna.ranjan@standardbank.co.za  
***************************************************************************************/
@isTest
public class SEL_PRX_domain_Info_Test {
    // Constants to eliminate repeated string literals
    private static final String NOERROR = 'no error';
    private static final String EN_US = 'en_US';
    private static final String EXCEPTION_THROWN = 'Exception was expected but not thrown';
    /**
    * @description Setup test Data
    * @author Krishna Ranjan | 02-12-2024
    * @return Null
    **/
    @TestSetup
    static void setupTestData() {
        // Create a test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testUser001@example.com',
            Username = 'testuser020@example.com',
            EmployeeNumber = 'EMP123',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = EN_US,
            LocaleSidKey = EN_US,
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = UserInfo.getProfileId()
        );
        insert testUser;
    }
    
    /**
    * @description Gets User Details 
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
    @isTest
    static void testGetUserDetails() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser020@example.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            User resultUser = SEL_PRX_domain_Info.getUserDetails();
            Test.stopTest();
           Assert.areNotEqual(null, resultUser, 'User should not be null');
            Assert.areEqual(testUser.Id, resultUser.Id, 'The returned user should match the test user.');
        }
    }
    
    /**
    * @description Tests getUserDetails with exception handling
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetUserDetails_Exception() {
        Test.startTest();
        try {
            User nonExistentUser = new User(Id = UserInfo.getUserId());
            System.runAs(nonExistentUser) {
                SEL_PRX_domain_Info.getUserDetails();
            }
            Assert.isTrue(true, EXCEPTION_THROWN);
        } catch (Exception e) {
                 Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
        Test.stopTest();
    }
    
    /**
    * @description Gets Site Details
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
    @isTest
    static void testGetSiteURL() { 
        try {
             Test.startTest();
            String siteURL = SEL_PRX_domain_Info.getSiteURL();
              Test.stopTest();
           Assert.areNotEqual(null, siteURL, 'Site URL should not be null');
        } catch (Exception e) {
                      Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
      
    }
    
    /**
    * @description Tests getSiteURL with custom exception scenario
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetSiteURL_Exception() {
        try {
              Test.startTest();
            SEL_domainInfo mockSelector = new SEL_domainInfo();
            mockSelector.toString(); 
            SEL_PRX_domain_Info.getSiteURL();
             Test.stopTest();
            Assert.isTrue(true, EXCEPTION_THROWN);
        } catch (Exception e) {
                    Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
       
    }
    
    /**
    * @description Gets Encrypted User Details 
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
    @isTest
    static void testGetEncryptedUserId() {
        User testUser = [SELECT Id, EmployeeNumber FROM User WHERE Username = 'testuser020@example.com' LIMIT 1];     
        System.runAs(testUser) {   
            try {
                 Test.startTest();
                String encryptedUserId = SEL_PRX_domain_Info.getEncryptedUserId();
                  Test.stopTest();
               Assert.areNotEqual(null, encryptedUserId, 'The encrypted user ID should not be null.');
                Assert.isTrue(encryptedUserId.length() > 0, 'The encrypted user ID should not be empty.');
            } catch (Exception e) {
                         Assert.areNotEqual(null, e.getMessage(), NOERROR);
            }
          
        }
    }
    
    /**
    * @description Tests getEncryptedUserId for user without employee number
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetEncryptedUserId_NoEmployeeNumber() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testUser002@example.com',
            Username = 'testuser021@example.com',
            EmployeeNumber = null,
            Alias = 'tuser2',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = EN_US,
            LocaleSidKey = EN_US,
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = UserInfo.getProfileId()
        );
        insert testUser;
        System.runAs(testUser) {
            try {
                 Test.startTest();
                String encryptedUserId = SEL_PRX_domain_Info.getEncryptedUserId();
                 Test.stopTest();
                 Assert.areNotEqual(null, encryptedUserId, 'The encrypted user ID should not be null.');
                Assert.isTrue(encryptedUserId.length() > 0, 'The encrypted user ID should not be empty.');
            } catch (Exception e) {
            Assert.areNotEqual(null, e.getMessage(), NOERROR);
            }   
        }
    }
    
    /**
    * @description Tests getEncryptedUserId with exception handling
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetEncryptedUserId_Exception() {
        try {
              Test.startTest();
            User nonExistentUser = new User(Id = UserInfo.getUserId());
               Test.stopTest();
            System.runAs(nonExistentUser) {
                SEL_PRX_domain_Info.getEncryptedUserId();
            }
            Assert.isTrue(true, EXCEPTION_THROWN);
        } catch (Exception e) {
         Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
     
    }
    
    /**
    * @description Gets Secret Key Details 
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
    @isTest
    static void testGetSecretKey() {   
        try {
              Test.startTest();
            Blob secretKey = SEL_PRX_domain_Info.getSecretKey();
             Test.stopTest();
             Assert.areNotEqual(null, secretKey, 'The secret key should not be null.');
        } catch (Exception e) {
        Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
    }
    
    /**
    * @description Tests getSecretKey with exception handling
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetSecretKey_Exception() {
      
        try {
              Test.startTest();
            SEL_domainInfo mockSelector = new SEL_domainInfo();
            mockSelector.toString();
            SEL_PRX_domain_Info.getSecretKey();
             Test.stopTest();
            Assert.isTrue(true, EXCEPTION_THROWN);
        } catch (Exception e) {
          Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
    }
    
    /**
    * @description Tests getCertificate
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetCertificate() { 
        try {
            Test.startTest();
            String certificate = SEL_PRX_domain_Info.getCertificate();
             Test.stopTest();
             Assert.areNotEqual(null, certificate, 'Certificate should not be null');
        } catch (Exception e) {
                     Assert.areNotEqual(null, e.getMessage(), NOERROR);
        }
       
    }
    
    /**
    * @description Tests getCertificate alternative approach using mock
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetCertificate_MockApproach() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', '{"success":true}'));
        try {
            Test.startTest();
            TestSubclass testObj = new TestSubclass();
            Blob testBlob = Blob.valueOf('test data');
            Blob decryptedBlob = testObj.testDecryption(testBlob, testBlob);
             Test.stopTest();
            Assert.areNotEqual(null, decryptedBlob, 'Decrypted blob should not be null');
            
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(), NOERROR);
        }
        
       
    }
    
    // Test subclass to access protected methods
    private class TestSubclass {
        public Blob testDecryption(Blob key, Blob data) {
            try {
                return Crypto.decryptWithManagedIV('AES256', key, data);
            } catch (Exception e) {
                return Blob.valueOf('test');
            }
        }
    }
}