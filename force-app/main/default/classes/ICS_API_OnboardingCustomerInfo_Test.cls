/***********************************************************
* @description SFP-34727 test Class used for ICS_API_OnboardingCustomerInfo
* @author Dayakar
* @date 10/10/2024
******************************************************
* Last Modified By Dayakar
* Last Modified Date 10/10/2024
* Last Modified Description: Initial Version
*/
@IsTest
private class ICS_API_OnboardingCustomerInfo_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create Primary Account
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        Account relatedAccount = new Account(
            FirstName = 'Test',
            LastName = 'Related',
            PersonEmail = 'pskRe@gmail.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        insert relatedAccount;
         Assessment assData = new Assessment(
                Name = 'Test Assessment',
                AssessmentStatus = 'In Progress',
                AccountId = testAccount.Id
            );
        insert assData;
         AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'Which address should the Visa Debit Card be delivered to?',
            QuestionCategory = 'Financial'
        );
        insert question;
        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Which address should the Visa Debit Card be delivered to?',
            Name = 'Which address should the Visa Debit Card be delivered to?',
            IsActive = true
        );
        insert qv;
        AssessmentQuestionResponse responseData = new AssessmentQuestionResponse();
        responseData.Name = 'test name';
        responseData.AssessmentQuestionId = qv.Id;
        responseData.AssessmentId = assData.Id;
        insert responseData;
        
        Opportunity testOpp = ICS_DAL_TestFactory.createOpportunity(testAccount.id);
        ApplicationForm testForm =ICS_DAL_TestFactory.createApplicationForm(testAccount.id,testOpp.id);
        PartyProfile primaryProfile = new PartyProfile(
            Name = 'Primary Profile',
            AccountId = testAccount.Id
        );
        insert primaryProfile;
        PartyProfile relatedProfile = new PartyProfile(
            Name = 'Related Profile',
            AccountId = relatedAccount.Id
        );
        insert relatedProfile;
        // Create Applicants
        Applicant primaryApplicant = new Applicant(
            ApplicationFormId = testForm.Id,
            PartyProfileId = primaryProfile.Id,
            Role = 'Primary Applicant'
        );
        insert primaryApplicant;
        
        Applicant secondaryApplicant = new Applicant(
            ApplicationFormId = testForm.Id,
            PartyProfileId = relatedProfile.Id,
            Role = 'Secondary Applicant'
        );
        insert secondaryApplicant;
        
        // Create Primary Addresses
        createAddressesPrimary(primaryProfile.Id);
        // Create Related Party Addresses
        createRelatedAddresses(relatedProfile.Id);
    }
    
    private static void createAddressesPrimary(Id profileId) {
        PartyProfileAddress currentAddress = new PartyProfileAddress(
            Name = 'Primary Current' ,
            PartyProfileId = profileId,
            AddressType = 'Residential Address',
            Street ='US Street' ,
            City = 'e',
            State = 'WA',
            PostalCode ='50072',
            Country = 'ZA',
            Date_Move_In__c = Date.today(),
            Date_Move_Out__c = null
        );
        
        PartyProfileAddress address1 = new PartyProfileAddress(
            Name = 'Primary Add1' ,
            PartyProfileId = profileId,
            AddressType = 'Residential Address',
            Street = 'AdditionalAddress1' ,
            City =  'Test' ,
            State = 'WA',
            PostalCode = '6025',
            Country = 'AU',
            Date_Move_In__c = Date.today().addYears(-2),
            Date_Move_Out__c = Date.today().addYears(-1)
        );
        
        PartyProfileAddress address2 = new PartyProfileAddress(
            Name = 'Primary Add2' ,
            PartyProfileId = profileId,
            AddressType = 'Residential Address',
            Street =  'AdditionalAddress2' ,
            City = 'Joondalup',
            State = 'WA',
            PostalCode = '6025',
            Country = 'AU',
            Date_Move_In__c = Date.today().addYears(-3),
            Date_Move_Out__c = Date.today().addYears(-2)
        );
        
        insert new List<PartyProfileAddress>{currentAddress, address1, address2};
    }
    private static void createRelatedAddresses(Id profileId) {
        PartyProfileAddress currentAddress = new PartyProfileAddress(
            Name = 'Related Current' ,
            PartyProfileId = profileId,
            AddressType = 'Residential Address',
            Street ='RPrimaryAddress' ,
            City = 'e' ,
            State = 'WA',
            PostalCode ='6025' ,
            Country = 'AU' ,
            Date_Move_In__c = Date.today(),
            Date_Move_Out__c = null
        );
        
        PartyProfileAddress address1 = new PartyProfileAddress(
            Name = 'Related Add1' ,
            PartyProfileId = profileId,
            AddressType = 'Residential Address',
            Street = '1/4 Warburton Ave' ,
            City =  'Joondalup' ,
            State = 'WA',
            PostalCode = '6025',
            Country = 'AU',
            Date_Move_In__c = Date.today().addYears(-2),
            Date_Move_Out__c = Date.today().addYears(-1)
        );
        
        PartyProfileAddress address2 = new PartyProfileAddress(
            Name = 'Related Add22' ,
            PartyProfileId = profileId,
            AddressType = 'Residential Address',
            Street =  '1/4 Warburton Ave' ,
            City = 'Joondalup',
            State = 'WA',
            PostalCode = '6025',
            Country = 'AU',
            Date_Move_In__c = Date.today().addYears(-3),
            Date_Move_Out__c = Date.today().addYears(-2)
        );
        
        insert new List<PartyProfileAddress>{currentAddress, address1, address2};
    }
    
    @IsTest
    static void testGetCustomerDetails() {
        try{
            Account testAccount = [SELECT Id, FirstName,LastName, PersonEmail FROM Account WHERE LastName = 'testet' LIMIT 1];
        RestRequest req = new RestRequest();
        req.params.put('SFAccountID', testAccount.Id);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        ICS_API_OnboardingCustomerInfo.getCustomerDetails();
        Test.stopTest();
        
        // Verify response
        
        String responseBody = RestContext.response.responseBody.toString();
        
        // Parse and verify response
        ICS_DTO_CustomerAPI response = (ICS_DTO_CustomerAPI)JSON.deserialize(responseBody, ICS_DTO_CustomerAPI.class);
       Assert.areEqual(testAccount.Id, response.SFAccountID,'Inserted Account and Response returned Account is Same');
       Assert.areEqual('Joint', response.AccountType,'Account type is Joint');
       Assert.areEqual('All', response.SigngingMandate,'Signing Mandate is for all the applicants');
        }catch(exception e){
             Assert.areEqual(true,e.getmessage() !=null,'Error occured  while processing request'); 
        }
       
    }
    
    @IsTest
    static void testProcessRequest() {
        Account testAccount = [SELECT Id,FirstName,LastName,PersonEmail  FROM Account WHERE LastName = 'Related' LIMIT 1];
        PartyProfile testProfile = [SELECT Id FROM PartyProfile WHERE Name = 'Related Profile' LIMIT 1];
        
        // Create sample request body based on provided JSON
        String requestJson = createSampleRequestJson(testAccount.Id, testProfile.Id);
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestJson);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        try{
        ICS_API_OnboardingCustomerInfo.processRequest();
        }catch(exception e){
          Assert.areEqual(true,e.getmessage() !=null,'Error occured  while processing request');  
        }
        Test.stopTest();
        
    }
    
    private static String createSampleRequestJson(Id accountId, Id profileId) {
        ICS_DTO_CustomerAPI request = new ICS_DTO_CustomerAPI();
        request.SigngingMandate = 'All';
        request.idNumber = '6327532367523';
        request.expiryDate = '2006-12-20';
        request.validTo = '2006-12-20';
        request.validfrom = '2006-12-20';
        request.SFAccountID = accountId;
        request.EmailAddresss = 'update@gmail.com';
        request.CustomerBPID = '856585675';
        request.AccountType = 'Joint';
        
        request.PrimaryAddress = createDTOAddress('US Street', 'e', 'WA', '50072', 'ZA');
        request.AdditionalAddress1 = createDTOAddress('AdditionalAddress1', 'Test', 'WA', '6025', 'AU');
        request.AdditionalAddress2 = createDTOAddress('AdditionalAddress2', 'Joondalup', 'WA', '6025', 'AU');
        
        // Create Related Party
        ICS_DTO_CustomerAPI.RelatedParties relatedParty = new ICS_DTO_CustomerAPI.RelatedParties();
        relatedParty.SFPartyProfileID = profileId;
        relatedParty.SFAccountID = accountId;
        relatedParty.idNumber = '6327532367523';
        relatedParty.expiryDate = '2006-12-20';
        relatedParty.validTo = '2006-12-20';
        relatedParty.validfrom = '2006-12-20';
        relatedParty.EmailAddresss = 'pskRe@gmail.com';
        relatedParty.AutorisedSignatory = 'Yes';
        
        relatedParty.PrimaryAddress = createDTOAddress('RPrimaryAddress', 'Joondalup RR', 'WA', '6025', 'AU');
        relatedParty.AdditionalAddress1 = createDTOAddress('1/4 Warburton Ave', 'Joondalup', 'WA', '6025', 'AU');
        relatedParty.AdditionalAddress2 = createDTOAddress('1/4 Warburton Ave', 'Joondalup', 'WA', '6025', 'AU');
        
        request.RelatedParties = new List<ICS_DTO_CustomerAPI.RelatedParties>{relatedParty};
        
        return JSON.serialize(request);
    }
    
    private static ICS_DTO_CustomerAPI.DTO_Address createDTOAddress(String street, String city, String state, String postalCode, String country) {
        ICS_DTO_CustomerAPI.DTO_Address address = new ICS_DTO_CustomerAPI.DTO_Address();
        address.street = street;
        address.city = city;
        address.state = state;
        address.postalcode = postalCode;
        address.country = country;
        return address;
    }
         
}