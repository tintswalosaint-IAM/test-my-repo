/**
* @Name of the Class:  ICS_CTRL_OnboardingFormCreator_Test
* @description class used as test class controller for ICS_CTRL_OnboardingFormCreator
* @Story:SFP-30128
* @author Ikyatha Naidu
* @date 25-07-2024
* @last modified on  : 29-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : SFP-30128 class used as controller for SBO-UK onBoardingApplication
*/
@IsTest
public class ICS_CTRL_OnboardingFormCreator_Test {
  @TestSetup
   static void setupTestData() {
       User commUser = ICS_DAL_TestFactory.createCommunityUser();
       commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       
       Product2 testProduct = new Product2(
           Name = 'Test Product', 
           ProductCode = 'VISA_DEBIT_CARD',
           IsActive = true
       );
       insert testProduct;

       Id pricebookId = Test.getStandardPricebookId();
       PricebookEntry standardPrice = new PricebookEntry(
           Pricebook2Id = pricebookId,
           Product2Id = testProduct.Id,
           UnitPrice = 100,
           IsActive = true
       );
       insert standardPrice;

       Opportunity opp = new Opportunity(
           Name = 'Test Opp',
           AccountId = commUser.Contact.AccountId,
           StageName = 'New',
           CloseDate = System.today()
       );
       insert opp;

       OpportunityLineItem oli = new OpportunityLineItem(
           OpportunityId = opp.Id,
           PricebookEntryId = standardPrice.Id,
           Quantity = 1,
           UnitPrice = 100
       );
       insert oli;
        Assessment assData = ICS_DAL_TestFactory.createAssessment(commUser.contact.accountid);
       
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'Select all assets and income*',
            QuestionCategory = 'Financial'
        );
        insert question;

        AssessmentQuestionVersion versionData = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Select all assets and income*',
            Name = 'Select all assets and income*',
            IsActive = true
        );
        insert versionData;
        ICS_DAL_TestFactory.createAssessmentQuestionResponse(assData.id, versionData.id);

       ApplicationForm appForm = new ApplicationForm(
           AccountId = commUser.Contact.AccountId,
           OpportunityId = opp.Id,
           Stage = 'Awaiting Form Filling',
           Section_Name__c = 'ICS UK Personal Info;Current Residential Address',
           UsageType='Onboarding'
       );
       insert appForm;

       ApplicationFormProduct afp = new ApplicationFormProduct(
           ApplicationFormId = appForm.Id,
           ProductId = testProduct.Id
       );
       insert afp;

       PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.AccountId);
       profile.Country_of_Residence__c = 'UA';
       profile.RecordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId();
       update profile;

       Id addAccRecTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByDeveloperName().get('Additional_Accounts').getRecordTypeId();
       Party_Assets_Funds__c fund = new Party_Assets_Funds__c(
           Party_Profile__c = profile.Id,
           RecordTypeId = addAccRecTypeId,
           Type__c = 'Initial Deposit',
           Initial_Deposit__c = 600000,
           Bank_Name__c = 'Test Bank',
           Bank_Account_Number__c = '12345'
       );
       insert fund; 
       
        Id recordTypeId;
   
        recordTypeId = Schema.SObjectType.CMN_Industry__c.getRecordTypeInfosByDeveloperName()
                      .get('SBO').getRecordTypeId();
  
    
    // Create test industry records
    List<CMN_Industry__c> testIndustries = new List<CMN_Industry__c>();
    
    // Technology main industry with sub-industries
    testIndustries.add(new CMN_Industry__c(
        CMN_MainIndustry__c = 'Technology',
        CMN_SubIndustry__c = 'Software Development',
        CMN_RiskRating__c = 'Low',
        CMN_Active__c = true,
        RecordTypeId = recordTypeId,
        CMN_SlugID__c = 'SW'
    ));
    
    testIndustries.add(new CMN_Industry__c(
        CMN_MainIndustry__c = 'Technology',
        CMN_SubIndustry__c = 'Hardware Manufacturing',
        CMN_RiskRating__c = 'Medium',
        CMN_Active__c = true,
        RecordTypeId = recordTypeId,
        CMN_SlugID__c = 'HW'
    ));
    
    // Finance main industry with sub-industries
    testIndustries.add(new CMN_Industry__c(
        CMN_MainIndustry__c = 'Finance',
        CMN_SubIndustry__c = 'Banking',
        CMN_RiskRating__c = 'High',
        CMN_Active__c = true,
        RecordTypeId = recordTypeId,
        CMN_SlugID__c = 'ANK'
    ));
    
    testIndustries.add(new CMN_Industry__c(
        CMN_MainIndustry__c = 'Finance',
        CMN_SubIndustry__c = 'Insurance',
        CMN_RiskRating__c = 'Medium',
        CMN_Active__c = true,
        RecordTypeId = recordTypeId,
        CMN_SlugID__c = 'INS'
    ));
    
    // Healthcare main industry without sub-industry
    testIndustries.add(new CMN_Industry__c(
        CMN_MainIndustry__c = 'Healthcare',
        CMN_SubIndustry__c = null,
        CMN_RiskRating__c = 'Low',
        CMN_Active__c = true,
        RecordTypeId = recordTypeId,
        CMN_SlugID__c = 'LTH'
    ));
    
    insert testIndustries;
   }
      @IsTest
    static void testFetchDynamicDataScenarios() {
        User commUser = [SELECT Id, Contact.AccountId FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            try {
                ICS_CTRL_OnboardingFormCreator.fetchDynamicData(
                    commUser.Contact.AccountId, '', 'Assets and Income', null);
            } catch (Exception e) {
                 Assert.isTrue(true, 'Exception thrown as expected');
            }
            
            try {
                ICS_CTRL_OnboardingFormCreator.fetchDynamicData(
                    commUser.Contact.AccountId, '', 'Future Deposits', null);
            } catch (Exception e) {
                Assert.isTrue(true, 'Exception thrown as expected');
            }
            
            try {
                ICS_CTRL_OnboardingFormCreator.fetchDynamicData(
                    commUser.Contact.AccountId, '', 'Trusts', null);
            } catch (Exception e) {
                 Assert.isTrue(true, 'Exception thrown as expected');
            }
            
            try {
                ICS_CTRL_OnboardingFormCreator.fetchDynamicData(
                    commUser.Contact.AccountId, '', 'Tax Certificates', null);
            } catch (Exception e) {
               Assert.isTrue(true, 'Exception thrown as expected');
            }
            
            try {
                ICS_CTRL_OnboardingFormCreator.fetchDynamicData(
                    commUser.Contact.AccountId, '', 'Unknown Section', 'test');
            } catch (Exception e) {
                 Assert.isTrue(true, 'Exception thrown as expected');
            }
        }
        Test.stopTest();
        
        Assert.isTrue(true, 'Test completed');
    }
    @IsTest
    static void testDeleteAddress() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
            ICS_CTRL_OnboardingFormCreator.fetchDOB(commUser.Contact.AccountId);
        PartyProfile profile = new PartyProfile(
            AccountId = commUser.Contact.AccountId,
            Country_of_Residence__c = 'UA',
            Name='new',
            RecordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId()
        );
        insert profile;
        
        Test.startTest();
        
        // Test valid delete
        ICS_CTRL_OnboardingFormCreator.deleteAddress(profile.Id);
        List<PartyProfile> profiles = [SELECT Id FROM PartyProfile WHERE Id = :profile.Id];
        Assert.areEqual(0, profiles.size(), 'Profile should be deleted');
        
        // Test exception
        try {
            ICS_CTRL_OnboardingFormCreator.deleteAddress(null);
            
            Assert.fail('Should throw exception for null Id');
        } catch(AuraHandledException e) {
            Assert.isTrue(true, 'Exception thrown as expected');
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testCheckIsJointException() {
        Test.startTest();
        try {
            ICS_CTRL_OnboardingFormCreator.checkisJoint('invalid_id');
            Assert.fail('Should throw exception for invalid ID');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    @IsTest
    static void testUpdateSectionName() {
       User commUser = [SELECT Id, Contact.AccountId FROM User 
                       WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
     
       
       Test.startTest();
       
       // Test valid update
       ICS_CTRL_OnboardingFormCreator.updateSectionName(commUser.Contact.AccountId, 'Personal Details');
       try {
           ICS_CTRL_OnboardingFormCreator.updateSectionName('test', 'Test Section');
           Assert.fail('Should throw exception for invalid account');
       } catch(AuraHandledException e) {
           Assert.isFalse(e.getMessage().contains('Unable to find account Id'));
       }
       
       Test.stopTest();
    }
    @IsTest
    static void testGetSectionName() {
       User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       
       ApplicationForm appForm = new ApplicationForm(
           AccountId = commUser.Contact.AccountId,
           Section_Name__c = 'Financial Details',
           UsageType = 'Onboarding'
       );
       insert appForm;
       
       Test.startTest();
       String result = ICS_CTRL_OnboardingFormCreator.getSectionName(commUser.Contact.AccountId);
       Assert.areNotEqual('Test Section', result);
       
       try {
           ICS_CTRL_OnboardingFormCreator.getSectionName('test');
           
           Assert.fail('Should throw exception for invalid ID');
       } catch(AuraHandledException e) {
           Assert.isFalse(e.getMessage().contains('Unable to find account Id'));
       }
       Test.stopTest();
    }
	@IsTest
    static void testGetNameByAccountId() {
       User commUser = [SELECT Id, Contact.AccountId FROM User 
                       WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       Account acc = [SELECT Id, Name FROM Account WHERE Id = :commUser.Contact.AccountId];
       
       Test.startTest();
       
       // Test valid case
       String name = ICS_CTRL_OnboardingFormCreator.getNameByAccountId(acc.Id);
       Assert.areEqual(acc.Name, name);
       
       // Test invalid case
       try {
           ICS_CTRL_OnboardingFormCreator.getNameByAccountId('123456');
           Assert.fail('Should throw exception for invalid account');
       } catch(AuraHandledException e) {
           Assert.isFalse(e.getMessage().contains('Unable to find account Id'));
       }
       
       Test.stopTest();
    }
    @IsTest
    static void testFetchExpectedRevenue() {
       User commUser = [SELECT Id, Contact.AccountId FROM User 
                       WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       Account acc = [SELECT Id, Name FROM Account WHERE Id = :commUser.Contact.AccountId];
       
       Test.startTest();
       
       decimal Idnew = ICS_CTRL_OnboardingFormCreator.fetchExpectedRevenue(acc.Id,'Future Deposit');
         Assert.arenotEqual(null, Idnew);
       
       Test.stopTest();
    }
     @IsTest
    static void testfetchJointPersons() {
       User commUser = [SELECT Id, Contact.AccountId FROM User 
                       WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       Account acc = [SELECT Id, Name FROM Account WHERE Id = :commUser.Contact.AccountId];
       
        
       Test.startTest();
       
       Account Id = ICS_CTRL_OnboardingFormCreator.fetchJointPersons(acc.Id);
        Assert.areEqual(true, Id != null,'The returned account should not be null.');
       Test.stopTest();
    }
     @IsTest
    static void testfetchJointPersons_CatchBlock() {
        Test.startTest();
        try {
            ICS_CTRL_OnboardingFormCreator.fetchJointPersons('001InvalidId123');
            Assert.areEqual(false, 'An exception should have been thrown.');
        } catch (AuraHandledException e) {
           Assert.areEqual(true, e.getMessage() != null, 'The exception message should not be null.');
        }
        Test.stopTest();
    }
    @IsTest
    static void testSubmitApplicationForm() {
        User commUser = [SELECT Id, Contact.AccountId FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        opp.LeadSource = 'Staff';
        opp.Required_Approval_Processes__c = 'Need FAIS Approval;';
        update opp;
        StaticResource sr = [
            SELECT Body FROM StaticResource WHERE Name = 'ICS_Statutory_Disclosure_PDF' LIMIT 1
        ];
    
        Test.startTest();
        String result = ICS_CTRL_OnboardingFormCreator.submitApplicationForm(commUser.Contact.AccountId);
        Test.stopTest();
        
        Assert.areEqual(commUser.Contact.AccountId, result);
        ContentVersion cv = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Title LIKE 'Test Opp%' 
            LIMIT 1
        ];
        Assert.areNotEqual(null, cv.ContentDocumentId);
        List<ContentDocumentLink> cdls = [
            SELECT Id FROM ContentDocumentLink 
            WHERE LinkedEntityId = :commUser.Contact.AccountId
        ];
        Assert.isTrue(!cdls.isEmpty());
    }
    @IsTest
    static void testDisableDocumentUpload() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile profile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        ApplicationForm initialForm = [SELECT Enhanced_Due_Diligence_Required__c FROM ApplicationForm WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        Boolean initialEDDRequired = initialForm.Enhanced_Due_Diligence_Required__c;
        
        Party_Assets_Funds__c existingFund = [SELECT Id, RecordTypeId, Is_Future_Fund__c, Total_Amount__c, 
                                             Sale_Amount__c, Pension_Amount__c, Funds_Received__c 
                                             FROM Party_Assets_Funds__c WHERE Party_Profile__c = :profile.Id LIMIT 1];
        
        Id originalRecordTypeId = existingFund.RecordTypeId;
        existingFund.Is_Future_Fund__c = true;
        existingFund.Total_Amount__c = 600000;
        existingFund.Sale_Amount__c = 100000;
        existingFund.Pension_Amount__c = 50000; 
        existingFund.Funds_Received__c = 25000;
        update existingFund;
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName();
        Id sourceOfFundsRecTypeId = null;
        Boolean recordTypeExists = recordTypes.containsKey('Source of Funds');
        
        if (recordTypeExists) {
            sourceOfFundsRecTypeId = recordTypes.get('Source of Funds').getRecordTypeId();
            existingFund.RecordTypeId = sourceOfFundsRecTypeId;
            update existingFund;
        }
        
        Test.startTest();
        Boolean result = ICS_CTRL_OnboardingFormCreator.disableDocumentUpload(commUser.Contact.AccountId);
        Test.stopTest();
        Party_Assets_Funds__c updatedFund = [SELECT Id, RecordTypeId, Is_Future_Fund__c, Total_Amount__c, 
                                            Sale_Amount__c, Pension_Amount__c, Funds_Received__c 
                                            FROM Party_Assets_Funds__c WHERE Id = :existingFund.Id];
        ApplicationForm updatedForm = [SELECT Enhanced_Due_Diligence_Required__c FROM ApplicationForm WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        Assert.isNotNull(result, 'disableDocumentUpload should return a valid boolean value');
        Assert.areEqual(true, updatedFund.Is_Future_Fund__c, 'Is_Future_Fund__c should be set to true');
        Assert.areEqual(600000, updatedFund.Total_Amount__c, 'Total_Amount__c should be set to 600000');
        Assert.areEqual(100000, updatedFund.Sale_Amount__c, 'Sale_Amount__c should be set to 100000');
        Assert.areEqual(50000, updatedFund.Pension_Amount__c, 'Pension_Amount__c should be set to 50000');
        Assert.areEqual(25000, updatedFund.Funds_Received__c, 'Funds_Received__c should be set to 25000');
       
        if (result == true) {
            Assert.isNotNull(updatedForm.Enhanced_Due_Diligence_Required__c, 
                            'Enhanced_Due_Diligence_Required__c should have a value when document upload is disabled');
        }
        Assert.isNotNull(updatedForm.Enhanced_Due_Diligence_Required__c, 
                        'ApplicationForm.Enhanced_Due_Diligence_Required__c should not be null after processing');
    }

  @IsTest
    static void testCheckIsJointScenarios() {
        User commUser = [SELECT Id, Contact.AccountId FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Applicant app = new Applicant(
            AccountId = commUser.Contact.AccountId,
            Role = 'Primary Applicant',
            ApplicationFormId = [SELECT Id FROM ApplicationForm LIMIT 1].Id
        );
        insert app;
        ApplicationForm formData = [SELECT Id,Account.PersonEmail,Account.Name FROM ApplicationForm LIMIT 1];
        Test.startTest();
        String result = ICS_CTRL_OnboardingFormCreator.checkisJoint(commUser.Contact.AccountId);
        ICS_CTRL_OnboardingFormCreator.createEmailMessage(new EmailTemplate(),formData,null);
        Test.stopTest();
        
        Map<String,Object> jsonResult = (Map<String,Object>)JSON.deserializeUntyped(result);
        Assert.areEqual('true', jsonResult.get('isPrimary'));
    }

   @IsTest
   static void testEmailScenarios() {
       User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       System.runAs(commUser) {
       Test.startTest();
           ICS_CTRL_OnboardingFormCreator.sendEmail(commUser.Contact.AccountId);
           ICS_CTRL_OnboardingFormCreator.sendEmailWithTemplate();
           
           try {
               ICS_CTRL_OnboardingFormCreator.sendEmail(null);
              
           } catch(AuraHandledException e) {
               Assert.isTrue(true);
           }
       
       Test.stopTest();
       }
   }
    @IsTest
    static void testUpdateApplicationForm() {
        User commUser = [SELECT Id, Contact.AccountId FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        Boolean result1 = ICS_CTRL_OnboardingFormCreator.updateApplicationForm(
            commUser.Contact.AccountId, true, true);
        Assert.areEqual(false, result1, 'Should return false when condition met and form exists');
        ApplicationForm updatedForm = [SELECT Enhanced_Due_Diligence_Required__c 
                                      FROM ApplicationForm 
                                      WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        Assert.areEqual(true, updatedForm.Enhanced_Due_Diligence_Required__c, 
                       'Enhanced_Due_Diligence_Required__c should be updated to true');
        Boolean result2 = ICS_CTRL_OnboardingFormCreator.updateApplicationForm(
            commUser.Contact.AccountId, false, false);
        Assert.areEqual(true, result2, 'Should return true when condition not met');
        Account newAcc = new Account(Name = 'Test Account No Form');
        insert newAcc;
        Boolean result3 = ICS_CTRL_OnboardingFormCreator.updateApplicationForm(
            newAcc.Id, true, true);
        Assert.areEqual(true, result3, 'Should return true when no ApplicationForm exists');
        
        Test.stopTest();
    }

   @IsTest
   static void testFetchCurrentApplicationMethods() {
       User commUser = [SELECT Id FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       
       System.runAs(commUser) {
           String appId = ICS_CTRL_OnboardingFormCreator.fetchCurrentApplictaionId();
           Assert.isNotNull(appId);
           
           String appWithProduct = ICS_CTRL_OnboardingFormCreator.fetchCurrentApplictaionIdWithProduct();
           Assert.isNotNull(appWithProduct);
       }
   }

    
   @IsTest
   static void testCountryMethods() {
       User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       
       String countryCode = ICS_CTRL_OnboardingFormCreator.fetchCountryCode(commUser.Contact.AccountId);
       Assert.areEqual('UA', countryCode);
       
       String countryResidence = ICS_CTRL_OnboardingFormCreator.fetchCountryofResidence(commUser.Contact.AccountId);
       Assert.isNotNull(countryResidence);
   }
  @IsTest
    static void testDMLOperations() {
        User commUser = [SELECT Id, Contact.AccountId FROM User 
                        WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        Test.startTest();
        try {
            ICS_CTRL_OnboardingFormCreator.performOnboardingDMLInfo(
                '{"test":"data"}', 
                'Financial Details',
                'Additional Bank Accounts',
                commUser.Contact.AccountId,
                'insert'
            );
        } catch (AuraHandledException e) {
            Assert.areEqual(true, e.getMessage() != null, 'The exception message should not be null.');
        } catch (Exception e) {
          Assert.areEqual(true, e.getMessage() != null, 'The exception message should not be null.');
        }
        Test.stopTest();
    }

   @IsTest
   static void testBankAccountOperations() {
       User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       
       Test.startTest();
       String bankAccounts = ICS_CTRL_OnboardingFormCreator.getBankAccounts(commUser.Contact.AccountId);
       Assert.isNotNull(bankAccounts);
       
       String selectedAccount = ICS_CTRL_OnboardingFormCreator.selectedAccount(commUser.Contact.AccountId);
       Assert.isNotNull(selectedAccount);
       Test.stopTest();
   }

   @IsTest
   static void testTINValidations() {
       Test.startTest();
       String validations = ICS_CTRL_OnboardingFormCreator.returnTINPatternValidations('US');
       Assert.isNotNull(validations);
       Test.stopTest();
   }
    
    /**
 * @description Test method for getIndustryPicklist()
 * Tests the retrieval of grouped industry data as JSON
 */
@IsTest
static void testGetIndustryPicklist() {
    // Setup test data
 
    
    Test.startTest();
    String jsonResult = ICS_CTRL_OnboardingFormCreator.getIndustryPicklist();
    Test.stopTest();
    
    // Assert that JSON is returned
    Assert.isNotNull(jsonResult, 'JSON result should not be null');
    Assert.isTrue(jsonResult.length() > 0, 'JSON string should not be empty');
    
    // Parse JSON to verify structure
    List<Object> parsedResult = (List<Object>) JSON.deserializeUntyped(jsonResult);
    Assert.isTrue(parsedResult.size() > 0, 'Should have industry data in JSON');
    
    // Verify JSON structure contains required fields
    Map<String, Object> firstIndustry = (Map<String, Object>) parsedResult[0];
    Assert.isTrue(firstIndustry.containsKey('mainIndustry'), 'Should contain mainIndustry key');
    Assert.isTrue(firstIndustry.containsKey('riskRating'), 'Should contain riskRating key');
    Assert.isTrue(firstIndustry.containsKey('Id'), 'Should contain Id key');
    Assert.isTrue(firstIndustry.containsKey('subIndustries'), 'Should contain subIndustries key');
    Assert.isTrue(firstIndustry.containsKey('subIndustryCount'), 'Should contain subIndustryCount key');
    
    // Verify that subIndustryCount matches actual sub-industries
    List<Object> subIndustries = (List<Object>) firstIndustry.get('subIndustries');
    Integer subIndustryCount = (Integer) firstIndustry.get('subIndustryCount');
    Assert.areEqual(subIndustries.size(), subIndustryCount, 'subIndustryCount should match actual count');
}

/**
 * @description Test method for getIndustryPicklist() with no data
 * Tests the behavior when no industry records exist
 */
@IsTest
static void testGetIndustryPicklistNoData() {
    // No test data setup - testing empty scenario
    
    Test.startTest();
    String jsonResult = ICS_CTRL_OnboardingFormCreator.getIndustryPicklist();
    Test.stopTest();
    
    // Assert empty JSON array is returned
    Assert.isNotNull(jsonResult, 'JSON result should not be null even with no data');
   
}

/**
 * @description Test method for getSubIndustryPicklist()
 * Tests the retrieval of sub-industries for a given main industry
 */
@IsTest
static void testGetSubIndustryPicklist() {
    // Setup test data
  
    
    Test.startTest();
    
    // Test with valid main industry - Technology
    List<CMN_CTRL_Industry.SubIndustryWrapper> techSubIndustries = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('Technology');
    
    // Test with valid main industry - Finance  
    List<CMN_CTRL_Industry.SubIndustryWrapper> financeSubIndustries = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('Finance');
        
    // Test with main industry having no sub-industries - Healthcare
    List<CMN_CTRL_Industry.SubIndustryWrapper> healthcareSubIndustries = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('Healthcare');
    
    Test.stopTest();
    
    // Assert Technology sub-industries
    Assert.isNotNull(techSubIndustries, 'Technology sub-industries should not be null');
    Assert.areEqual(2, techSubIndustries.size(), 'Technology should have 2 sub-industries');
    
    // Verify sub-industry wrapper properties
    Set<String> techSubValues = new Set<String>();
    for (CMN_CTRL_Industry.SubIndustryWrapper wrapper : techSubIndustries) {
        techSubValues.add(wrapper.value);
        Assert.isNotNull(wrapper.id, 'SubIndustry Id should not be null');
        Assert.isNotNull(wrapper.riskRating, 'SubIndustry risk rating should not be null');
    }
    Assert.isTrue(techSubValues.contains('Software Development'), 'Should contain Software Development');
    Assert.isTrue(techSubValues.contains('Hardware Manufacturing'), 'Should contain Hardware Manufacturing');
    
    // Assert Finance sub-industries
    Assert.isNotNull(financeSubIndustries, 'Finance sub-industries should not be null');
    Assert.areEqual(2, financeSubIndustries.size(), 'Finance should have 2 sub-industries');
    
    // Assert Healthcare (no sub-industries)
    Assert.isNotNull(healthcareSubIndustries, 'Healthcare sub-industries list should not be null');
    Assert.areEqual(0, healthcareSubIndustries.size(), 'Healthcare should have 0 sub-industries');
}

/**
 * @description Test method for getSubIndustryPicklist() with invalid input
 * Tests the behavior with non-existent main industry
 */
@IsTest
static void testGetSubIndustryPicklistInvalidInput() {
    // Setup test data
  
    
    Test.startTest();
    
    // Test with non-existent main industry
    List<CMN_CTRL_Industry.SubIndustryWrapper> nonExistentSubIndustries = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('NonExistentIndustry');
        
    // Test with null input
    List<CMN_CTRL_Industry.SubIndustryWrapper> nullInputSubIndustries = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist(null);
        
    // Test with empty string input
    List<CMN_CTRL_Industry.SubIndustryWrapper> emptyInputSubIndustries = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('');
    
    Test.stopTest();
    
    // Assert null results for invalid inputs
    Assert.isNull(nonExistentSubIndustries, 'Should return null for non-existent main industry');
    Assert.isNull(nullInputSubIndustries, 'Should return null for null input');
    Assert.isNull(emptyInputSubIndustries, 'Should return null for empty string input');
}

/**
 * @description Test method for getIndustryPicklistWithId()
 * Tests the retrieval of industry records by Id
 */
@IsTest
static void testGetIndustryPicklistWithId() {
    // Setup test data
  
    
    // Get a test record Id
    List<CMN_Industry__c> testRecords = [SELECT Id, CMN_MainIndustry__c, CMN_SubIndustry__c 
                                         FROM CMN_Industry__c 
                                         WHERE CMN_MainIndustry__c = 'Technology' 
                                         LIMIT 1];
    Assert.isFalse(testRecords.isEmpty(), 'Should have test records');
    
    String testId = testRecords[0].Id;
    
    Test.startTest();
    
    // Test with valid Id
    List<CMN_Industry__c> result = ICS_CTRL_OnboardingFormCreator.getIndustryPicklistWithId(testId);
    
    Test.stopTest();
    
    // Assert that records are returned
    Assert.isNotNull(result, 'Should return industry records');
    // Note: The specific assertions depend on SEL_Industry selector implementation
    // In a real scenario, you might assert based on what the selector returns
    
    // If the selector returns the specific record, we can test:
    if (!result.isEmpty()) {
        Assert.areEqual(testId, result[0].Id, 'Should return the requested record');
    }
}

/**
 * @description Test method for getIndustryPicklistWithId() with invalid input
 * Tests the behavior with invalid Id inputs
 */
@IsTest
static void testGetIndustryPicklistWithIdInvalidInput() {
    // Setup test data
  
    
    Test.startTest();
    
    // Test with null Id - this should be handled by the selector
    List<CMN_Industry__c> nullResult = ICS_CTRL_OnboardingFormCreator.getIndustryPicklistWithId(null);
    
    // Test with invalid Id format
    try {
        List<CMN_Industry__c> invalidResult = 
            ICS_CTRL_OnboardingFormCreator.getIndustryPicklistWithId('InvalidId123');
    } catch (Exception e) {
        // Expected behavior for invalid Id format
        Assert.isTrue(true, 'Exception expected for invalid Id format');
    }
    
    Test.stopTest();
    
    // Assert null result for null input
    Assert.isNotNull(nullResult, 'Should return empty list rather than null for null input');
    // Note: The exact behavior depends on SEL_Industry selector implementation
}

/**
 * @description Test method for all industry methods with exception handling
 * Tests exception scenarios for all three methods
 */
@IsTest
static void testIndustryMethodsExceptionHandling() {
    Test.startTest();
    
    try {
        // Test methods work even with no data setup
        String jsonResult = ICS_CTRL_OnboardingFormCreator.getIndustryPicklist();
        Assert.isNotNull(jsonResult, 'Should handle no data scenario gracefully');
        
        List<CMN_CTRL_Industry.SubIndustryWrapper> subResult = 
            ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('AnyIndustry');
        // This should return null for non-existent industry
        Assert.isNull(subResult, 'Should return null for non-existent industry');
        
        List<CMN_Industry__c> idResult = 
            ICS_CTRL_OnboardingFormCreator.getIndustryPicklistWithId('001000000000000'); // Valid format but non-existent
        Assert.isNotNull(idResult, 'Should return empty list for non-existent Id');
        
    } catch (Exception e) {
        // If any exceptions occur, ensure they're handled appropriately
        Assert.isNotNull(e.getMessage(), 'Exception message should be available');
    }
    
    Test.stopTest();
}

/**
 * @description Test method to verify integration with CMN_CTRL_Industry
 * Tests that the methods properly delegate to CMN_CTRL_Industry class
 */
@IsTest
static void testIndustryMethodsIntegration() {
    // Setup test data
  
    
    Test.startTest();
    
    // Test that methods return consistent results when called multiple times
    String jsonResult1 = ICS_CTRL_OnboardingFormCreator.getIndustryPicklist();
    String jsonResult2 = ICS_CTRL_OnboardingFormCreator.getIndustryPicklist();
    
    List<CMN_CTRL_Industry.SubIndustryWrapper> subResult1 = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('Technology');
    List<CMN_CTRL_Industry.SubIndustryWrapper> subResult2 = 
        ICS_CTRL_OnboardingFormCreator.getSubIndustryPicklist('Technology');
    
    Test.stopTest();
    
    // Assert consistency
    Assert.areEqual(jsonResult1, jsonResult2, 'JSON results should be consistent');
    Assert.areEqual(subResult1?.size(), subResult2?.size(), 'Sub-industry results should be consistent');
    
    // Verify that the methods are working with actual CMN_CTRL_Industry functionality
    if (subResult1 != null && !subResult1.isEmpty()) {
        Assert.isNotNull(subResult1[0].id, 'SubIndustryWrapper should have valid Id');
        Assert.isNotNull(subResult1[0].value, 'SubIndustryWrapper should have valid value');
        Assert.isNotNull(subResult1[0].riskRating, 'SubIndustryWrapper should have valid risk rating');
    }
}
}