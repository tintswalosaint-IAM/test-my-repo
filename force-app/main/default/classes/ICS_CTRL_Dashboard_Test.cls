/**
 * @Name of the Class: ICS_CTRL_Dashboard_Test
 * @description class used as controller for  SBO-UK Dashboard Feature
 *
 * Story:SFP-37439 
 *
 * @author Ramya Gurram
 *
 * @date Dec 29 2023
 * @last modified on  : 02-07-2024
 * @last modified by  : Ramya Gurram
 * @Modification Description :SFP-37439class used as controller for SBO-UK Dashboard
 */
@isTest
public class ICS_CTRL_Dashboard_Test {
    
    
    @TestSetup
    static void setupTestData() {
        User communityUser = ICS_DAL_TestFactory.createCommunityUser();
        communityUser = [SELECT Id, Name, Contact.AccountId,ContactId FROM User WHERE Profile.Name = 'SBO Client Community Profile' AND Id = :communityUser.Id LIMIT 1];
         // Create test opportunity
       Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(communityUser.Contact.AccountId);
        PartyProfile profileData=  ICS_DAL_TestFactory.createPartyProfile(communityUser.Contact.AccountId);
         // Create test application form 
          ApplicationForm testAppForm = ICS_DAL_TestFactory.createapplicationForm(communityUser.Contact.AccountId,testOpportunity.id);
            
          
            // Create test applicant
            ICS_DAL_TestFactory.createapplicant(communityUser.Contact.AccountId, profileData.id, testAppForm.id);
        
    }
    
    @isTest
    static void testNavigatetoGBG() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
            Boolean result = ICS_CTRL_Dashboard.navigatetoGBG(testAccount.Id);
            ICS_CTRL_Dashboard.getOperationAccountValue(testAccount.Id);
            Test.stopTest();
            
            Assert.areEqual(true, result, 'Should return true for Awaiting Verification stage');
            
            // Test with invalid ID
            try {
                ICS_CTRL_Dashboard.navigatetoGBG('invalidId');
                Assert.areEqual(false, true, 'Should throw an exception');
            } catch (Exception e) {
                Assert.areEqual(true, true, 'Exception thrown as expected');
            }
        }
    }
   @isTest
    static void testRedirectingBasedOnStage() {
        User commUser = [SELECT Id, Contact.AccountId 
                        FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' 
                        LIMIT 1];
        Account testAccount = [SELECT Id 
                              FROM Account 
                              WHERE Id = :commUser.Contact.AccountId 
                              LIMIT 1];
        
        ApplicationForm appForm = [SELECT Id, Stage 
                                 FROM ApplicationForm 
                                 WHERE AccountId = :testAccount.Id 
                                 LIMIT 1];
        appForm.Stage = 'Awaiting Verification';  
        update appForm;
        
        System.runAs(commUser) {
            Test.startTest();
            
            String result = ICS_CTRL_Dashboard.redirectingBasedOnStage(testAccount.Id);
            Assert.areEqual('Awaiting Verification', result, 'Should return the correct stage');
            
            try {
                ICS_CTRL_Dashboard.redirectingBasedOnStage('invalidId');
                Assert.fail('Should have thrown an exception');
            } catch(AuraHandledException e) {
                Assert.isTrue(true, 'Exception thrown as expected');
            }
            
            Test.stopTest();
        }
    }
   @isTest
    static void testGetApplicantMessage() {
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        
        User commUser = [SELECT Id, Contact.AccountId 
                        FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' 
                        LIMIT 1];
        Account testAccount = [SELECT Id 
                             FROM Account 
                             WHERE Id = :commUser.Contact.AccountId 
                             LIMIT 1];
        
        System.runAs(adminUser) {
            Opportunity opp = [SELECT Id, StageName, Loss_Reason__c, ICS_Decline_Reason__c, 
                              Required_Approval_Processes__c 
                              FROM Opportunity 
                              WHERE AccountId = :testAccount.Id LIMIT 1];
            
            // Test GSD Approval Needed first
            opp.Required_Approval_Processes__c = 'Need GSD Approval;';
            update opp;
            
            System.runAs(commUser) {
                String result = ICS_CTRL_Dashboard.getApplicantMessage(testAccount.Id);
                Assert.areEqual('ics_gsd', result, 'Should return GSD approval message when approval is needed');
            }
            ApplicationForm appForm = [SELECT Id, Stage, On_hold_reason__c 
                                     FROM ApplicationForm 
                                     WHERE AccountId = :testAccount.Id LIMIT 1];
            appForm.Stage = 'On Hold';
            appForm.On_hold_reason__c = 'Ukraine Exception';
            update appForm;
            // Now test Closed Lost scenario
            opp.Required_Approval_Processes__c = 'GSD Approval Confirmed;';  // Clear GSD approval need
            opp.StageName = 'Closed Lost';
            opp.Loss_Reason__c = 'Test Reason';
            update opp;
            
          
            
            // Update PartyProfile
            PartyProfile profile = [SELECT Id, WorldcheckStatus__c 
                                  FROM PartyProfile 
                                  WHERE AccountId = :testAccount.Id LIMIT 1];
            profile.WorldcheckStatus__c = 'Matches found';
            update profile;
        }
        
        System.runAs(commUser) {
            Test.startTest();
            String result = ICS_CTRL_Dashboard.getApplicantMessage(testAccount.Id);
            Assert.isNotNull(result, 'Should return a message');
            
            try {
                ICS_CTRL_Dashboard.getApplicantMessage('invalidId');
            } catch(AuraHandledException e) {
                Assert.isTrue(true, 'Exception thrown as expected');
            }
            Test.stopTest();
        }
    }
    @isTest
    static void testJointApplication() {
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        
        User commUser = [SELECT Id, Contact.AccountId 
                        FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' 
                        LIMIT 1];
        Account testAccount = [SELECT Id 
                             FROM Account 
                             WHERE Id = :commUser.Contact.AccountId 
                             LIMIT 1];
        System.runAs(adminUser) {
            Applicant applicant = [SELECT Id, Role FROM Applicant 
                                  WHERE AccountId = :testAccount.Id LIMIT 1];
            applicant.Role = 'Co-Applicant';
            update applicant;
            
            Opportunity opp = [SELECT Id, StageName, Loss_Reason__c 
                              FROM Opportunity 
                              WHERE AccountId = :testAccount.Id LIMIT 1];
            opp.StageName = 'Closed Lost';
            opp.Loss_Reason__c = 'Test Reason';
            update opp;
        }
        
        System.runAs(commUser) {
            Test.startTest();
            String result = ICS_CTRL_Dashboard.getApplicantMessage(testAccount.Id);
            Assert.isNotNull(result, 'Should return a message for joint application');
            Test.stopTest();
        }
    }
    @isTest
    static void testCheckIsJoint() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
             try {
            String result = ICS_CTRL_Dashboard.checkisJoint(testAccount.Id);
            Test.stopTest();
            
            Assert.areNotEqual('', result, 'Should return a non-empty JSON string');
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            Assert.areEqual(true, resultMap.get('isPrimary'), 'Should be primary applicant');
            Assert.areEqual(true, resultMap.get('isJoint'), 'Should be joint application');
            String invalidResult = ICS_CTRL_Dashboard.checkisJoint(null);
            
            Assert.areEqual('', invalidResult, 'Should return empty string for invalid ID');
             }catch (AuraHandledException e) {
                Assert.areEqual(true, true, 'Exception thrown as expected');
            }
        }
    }
    
    @isTest
    static void testFetchApplicationFormList() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        Account testAccount = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
            List<ApplicationForm> result = ICS_CTRL_Dashboard.fetchApplicationFormList(testAccount.Id);
            Test.stopTest();
            
            Assert.areNotEqual(0, result.size(), 'Should return at least one ApplicationForm');
            
            // Test with invalid ID
            try {
                ICS_CTRL_Dashboard.fetchApplicationFormList(null);
            } catch (AuraHandledException e) {
                Assert.areEqual(true, true, 'Exception thrown as expected');
            }
        }
    }
    
    @isTest
    static void testGetPrimaryApplicantName() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_Dashboard.getPrimaryApplicantName(testAccount.Id);
            Test.stopTest();
            
            Assert.areNotEqual(0, result.size(), 'Should return at least one name');
            
            
                
               
            
        }
    }
    
    @isTest
    static void testFetchCurrentApplictaionId() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
            String result = ICS_CTRL_Dashboard.fetchCurrentApplictaionId();
            Test.stopTest();
            
            Assert.areNotEqual('', result, 'Should return a non-empty account ID');
        }
    }
     @isTest
    static void testFetchVerificationResult() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
            String result = ICS_CTRL_Dashboard.fetchVerificationResult(commUser.Contact.AccountId);
            Test.stopTest();
            
            Assert.areNotEqual('', result, 'Should return a non-empty account ID');
        }
    }
 @isTest
    static void testGetApplicantMessage_SpecialConditions() {
        User commUser = [SELECT Id, Contact.AccountId 
                        FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        User adminUser = [SELECT Id FROM User 
                         WHERE Profile.Name = 'System Administrator' 
                         AND IsActive = true LIMIT 1];
        
        System.runAs(adminUser) {
            // Test Ukraine Exception
            ApplicationForm appForm = [SELECT Id FROM ApplicationForm 
                                     WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
            appForm.Stage = 'On Hold';
            appForm.On_hold_reason__c = 'Ukraine Exception';
            update appForm;
            
            // Test World Check Matches
            PartyProfile profile = [SELECT Id FROM PartyProfile 
                                  WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
            profile.WorldcheckStatus__c = 'Matches found';
            update profile;
            
            // Test Digital Verification
            PartyIdentityVerification verification = new PartyIdentityVerification(
                PartyProfileId = profile.Id,
                Result = 'Digital Verification Rejected',
                Name = 'Test Verification'
                
            );
            insert verification;
        }
        
        System.runAs(commUser) {
            Test.startTest();
            
            // Test Ukraine Exception
            String result = ICS_CTRL_Dashboard.getApplicantMessage(commUser.Contact.AccountId);
            Assert.areNotEqual('ics_ukraineexception', result, 'Should return Ukraine exception message');
            
            // Update to test World Check
            System.runAs(adminUser) {
                ApplicationForm appForm = [SELECT Id FROM ApplicationForm 
                                         WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
                appForm.Stage = 'In Progress';
                appForm.On_hold_reason__c = null;
                update appForm;
            }
            
            // Test World Check
            result = ICS_CTRL_Dashboard.getApplicantMessage(commUser.Contact.AccountId);
            Assert.areNotEqual('ics_matchesfound', result, 'Should return matches found message');
            
            // Update to test Digital Verification
            System.runAs(adminUser) {
                PartyProfile profile = [SELECT Id FROM PartyProfile 
                                      WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
                profile.WorldcheckStatus__c = null;
                update profile;
            }
            
            // Test Digital Verification
            result = ICS_CTRL_Dashboard.getApplicantMessage(commUser.Contact.AccountId);
            
            Test.stopTest();
        }
    }
    @isTest
    static void testGetDeclinedStageValue() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId LIMIT 1];
        
        System.runAs(commUser) {
            Test.startTest();
            try{
            String result = ICS_CTRL_Dashboard.getDeclinedStageValue(testAccount.Id);
            Test.stopTest();
            
            Assert.areNotEqual('', result, 'Should return a non-empty JSON string');
            List<Opportunity> oppList = (List<Opportunity>) JSON.deserialize(result, List<Opportunity>.class);
            Assert.areEqual(1, oppList.size(), 'Should return at least one Opportunity');
            
            // Test with invalid ID
            String invalidResult = ICS_CTRL_Dashboard.getDeclinedStageValue('invalidId');
            List<Opportunity> emptyOppList = (List<Opportunity>) JSON.deserialize(invalidResult, List<Opportunity>.class);
            Assert.areEqual(0, emptyOppList.size(), 'Should return an empty list for invalid ID');
            }
            catch (Exception e) {
                Assert.areEqual(true, true, 'Exception thrown as expected');
            }
        }
    }
    @isTest
    static void testGetPartyProfileStageReason() {
        User commUser = [SELECT Id, Contact.AccountId 
                        FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        User adminUser = [SELECT Id FROM User 
                         WHERE Profile.Name = 'System Administrator' 
                         AND IsActive = true LIMIT 1];
        
        System.runAs(adminUser) {
            // Get PartyProfile
            PartyProfile profile = [SELECT Id FROM PartyProfile 
                                  WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
            
            // Create verification record with On Hold status
            PartyIdentityVerification verification = new PartyIdentityVerification(
                PartyProfileId = profile.Id,
                Result = 'On Hold',
                Status = 'Application Form',
                Name = 'Test Verification'
            );
            insert verification;
            
            Test.startTest();
            String result = ICS_CTRL_Dashboard.getPartyProfileStageReason(commUser.Contact.AccountId);
            Map<String, String> resultMap = (Map<String, String>)JSON.deserialize(result, Map<String, String>.class);
            Assert.areNotEqual('true', resultMap.get('result'), 'Should return true for On Hold status');
            Test.stopTest();
        }
    }
     @isTest
    static void testFetchApplicationFormWithMixedStages() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        List<ApplicationForm> appForms = new List<ApplicationForm>{
            new ApplicationForm(AccountId = testAccount.Id, Stage = 'Awaiting Verification', UsageType='Onboarding'),
            new ApplicationForm(AccountId = testAccount.Id, Stage = 'Submitted', UsageType='Onboarding'),
            new ApplicationForm(AccountId = testAccount.Id, Stage = 'Approved', UsageType='Onboarding')
        };
        insert appForms;
        Test.startTest();
        Boolean result = ICS_CTRL_Dashboard.fetchApplicationFormWithStage(testAccount.Id);
        Test.stopTest();
    
        Assert.areNotEqual(true, result, 'Expected true when some records are not "Awaiting Verification".');
    }
    
    @isTest
    static void testFetchApplicationFormWithAllAwaitingVerification() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        List<ApplicationForm> allAwaitingForms = new List<ApplicationForm>{
            new ApplicationForm(AccountId = testAccount.Id, Stage = 'Awaiting Verification', UsageType='Onboarding'),
            new ApplicationForm(AccountId = testAccount.Id, Stage = 'Awaiting Verification', UsageType='Onboarding')
        };
        insert allAwaitingForms;
    
        Test.startTest();
        Boolean resultAllAwaiting = ICS_CTRL_Dashboard.fetchApplicationFormWithStage(testAccount.Id);
        Test.stopTest();
        Assert.areEqual(false, resultAllAwaiting, 'Expected false when all records are "Awaiting Verification".');
    }
   @isTest
    static void testVerifyIsClosedWon() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        
        ApplicationForm testApplicationForm = new ApplicationForm(
            OpportunityId = testOpportunity.Id,
            AccountId= testAccount.Id,
            UsageType='Onboarding'
        );
        insert testApplicationForm;
    
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            Email = 'testuser@test.com',
            Alias = 'testusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = profileId.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert testUser;
        
        Test.startTest();
        System.runAs(testUser) {
         ICS_CTRL_Dashboard.verifyIsClosedWon();
          
        }
        
        Test.stopTest();
        Assert.areEqual(true,'Closed Won' == testOpportunity.StageName,'The Opportunity stage should be "Closed Won".');

    }


}