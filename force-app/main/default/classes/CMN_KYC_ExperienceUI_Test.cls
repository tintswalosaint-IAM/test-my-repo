/***************************************************************************************
@Name of the Class :CMN_KYC_ExperienceUI_Test
@Description :SFP-40755 Test Class for CMN_KYC_ExperienceUI.    
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By Jaco de Lange
* Last Modified Date Feb 03 2026
* Last Modified Description: Consolidated duplicate string literals into constants.
****************************************************************************************
* Last Modified By Jaco de Lange
* Last Modified Date March 05 2026
* Last Modified Description: SFP-55685 - Tech debt fixes
****************************************************************************************/
@IsTest
private class CMN_KYC_ExperienceUI_Test {

    private static final String HEADER_CONTENT_TYPE = 'Content-Type';
    private static final String HEADER_APPLICATION_JSON = 'application/json';
    private static final String WFR_PIV_NAME = 'WFR';
    private static final String ACCEPTED = 'Accepted';
    private static final String OCR_FAILED = 'OCR Failed';
    private static final String TEST_FILE_NAME = 'TestDocument.pdf';
    private static final String TEST_FILE_CONTENT = 'VGVzdCBGaWxlIENvbnRlbnQ=';
    private static final String ASSERT_RESULT = 'Result should not be null';
    private static final String ASSERT_EXCEPTION_THROWN = 'Expected AuraHandledException was not thrown';

    @TestSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager' LIMIT 1];
        String uniqueName = 'testuguser' + DateTime.now().getTime() + '@example.com';
        User ugUser = new User(
            Alias = 'uguser',
            Email = 'testuguser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_UG',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Kampala',
            User_Country__c = 'UG',
            UserName = uniqueName
        );
        System.runAs(ugUser) { 
            Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ICS_Applicant').getRecordTypeId();
            Id recTypeId = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().getRecordTypeInfosByDeveloperName().get('Know_Your_Customer').getRecordTypeId();
        	Account account = new Account ( 
                FirstName = 'TestACC',
                LastName = 'testet',
                AOB_CommerceSiteId__c = 'SB-COZA',
                AOB_TECH_CCCustomerId__c = 'XXX', 
                FinServ__Gender__pc = 'Male',
                Phone = '+27823309876',
                ExternalCIFUUID__c = 'RandonBPGUID',
                RecordTypeId = personAccountRecordTypeId
            );
        	insert account;
            
            PartyProfile pprofile = new PartyProfile( 
                FirstName = 'TEST',
                LastName = 'SURNAME',
                Name = 'WFR',  
                PrimaryEmail = 'TEST_SURNAME@test.com',
                PrimaryIdentifierType = '10', // National Identity Document
                PrimaryIdentifier = '218731831', 
                WI_IdentificationDocumentIssuingCountry__c = 'UG',
                WI_PrimaryIdentificationName__c = 'Phone',
                DateOfBirth = Date.valueOf('2001-09-17'),
                EmploymentType = 'Unemployed',
                WI_CountryOfCitizenship__c = 'UG',
                WI_PassportIssuingCountry__c = 'UG',
                RecordTypeId = recTypeId
            );    
            insert pprofile; 
            
            PartyIdentityVerification verification = new PartyIdentityVerification(
                Name = 'WFR',
                PartyProfileId = pprofile.Id,
                ThirdPartyVerfdentifier = '5804832',
                Result = 'On Hold',
                ResultOverrideReason = 'OCR Failed'
            );
        	insert verification;
                        
            ContentVersion cv = new ContentVersion(
                Title = 'Test File', 
                VersionData = Blob.valueOf('Test Data'), 
                PathOnClient = 'Test_File.txt'
            );
            insert cv;
        }
    }

    /**
     * @description Combined tests for fetchPIV: Valid, Invalid ID, and No results.
     */
    @IsTest
    static void fetchPIV_Scenarios() {
        PartyProfile profile = [SELECT Id FROM PartyProfile LIMIT 1];
        
        Test.startTest();
            String result = CMN_KYC_ExperienceUI.fetchPIV(profile.Id, WFR_PIV_NAME);
            String emptyResult = CMN_KYC_ExperienceUI.fetchPIV(profile.Id, 'NonExistent');
            Boolean exceptionCaught = false;
            try {
                CMN_KYC_ExperienceUI.fetchPIV('InvalidId', WFR_PIV_NAME);
            } catch (AuraHandledException ex) {
                exceptionCaught = true;
            }
        Test.stopTest();
        
        Assert.isNotNull(result, ASSERT_RESULT);
        List<PartyIdentityVerification> pivList = (List<PartyIdentityVerification>)JSON.deserialize(result, List<PartyIdentityVerification>.class);
        Assert.areEqual(1, pivList.size(), 'Should return one PIV record');
        
        List<PartyIdentityVerification> emptyList = (List<PartyIdentityVerification>)JSON.deserialize(emptyResult, List<PartyIdentityVerification>.class);
        Assert.areEqual(0, emptyList.size(), 'Should return empty list for non-existent name');
        Assert.isTrue(exceptionCaught, ASSERT_EXCEPTION_THROWN);
    }

    /**
     * @description Combined tests for fetchProfileDetails and Picklist values logic.
     */
    @IsTest
    static void metadataAndProfileFetch_Scenarios() {
        PartyProfile profile = [SELECT Id FROM PartyProfile LIMIT 1];
        
        Test.startTest();
            String profileResult = CMN_KYC_ExperienceUI.fetchProfileDetails(new List<Id>{profile.Id});
            String emptyProfileResult = CMN_KYC_ExperienceUI.fetchProfileDetails(new List<Id>());
            List<CMN_KYC_ExperienceUI.PicklistOption> picklistOptions = CMN_KYC_ExperienceUI.getPicklistValues('PartyIdentityVerification', 'Result');
            List<CMN_KYC_ExperienceUI.PicklistOption> invalidFieldOptions = CMN_KYC_ExperienceUI.getPicklistValues('PartyIdentityVerification', 'Name');
        Test.stopTest();
        
        Assert.isTrue(profileResult.contains(profile.Id), 'Profile ID should be in result');
        Assert.areEqual('[]', emptyProfileResult, 'Empty list should return empty JSON array');
        Assert.isFalse(picklistOptions.isEmpty(), 'Picklist should return values');
        Assert.isTrue(invalidFieldOptions.isEmpty(), 'Non-picklist field should return empty list');
    }

    /**
     * @description Combined Update and Upsert operations for PIV and PartyProfile.
     */
    @IsTest
    static void updateAndUpsert_Scenarios() {
        PartyProfile profile = [SELECT Id FROM PartyProfile LIMIT 1];
        PartyIdentityVerification piv = [SELECT Id FROM PartyIdentityVerification WHERE Name = :WFR_PIV_NAME LIMIT 1];
        piv.Result = ACCEPTED;
        
        Test.startTest();
            String updateResult = CMN_KYC_ExperienceUI.updatePIV(profile.Id, JSON.serialize(new List<PartyIdentityVerification>{piv}));
            profile.FirstName = 'Updated';
            String upsertData = JSON.serialize(new List<PartyProfile>{profile});
            List<PartyProfile> upsertResult = CMN_KYC_ExperienceUI.upsertPartyProfile(upsertData);
        Test.stopTest();
        
        Assert.isNotNull(updateResult, ASSERT_RESULT);
        Assert.areEqual(ACCEPTED, [SELECT Result FROM PartyIdentityVerification WHERE Id = :piv.Id].Result, 'Result should have Accepted');
        Assert.areEqual('Updated', upsertResult[0].FirstName, 'Party profile first name is Updated');
    }

    /**
     * @description Validates OCR logic and error handling in response checks.
     */
    @IsTest
    static void ocrValidation_Scenarios() {
        PartyIdentityVerification piv = [SELECT Id, PartyProfile.WI_PrimaryIdentificationName__c FROM PartyIdentityVerification WHERE Name = :WFR_PIV_NAME LIMIT 1];
        List<PartyIdentityVerification> pivList = new List<PartyIdentityVerification>{piv};

        Test.startTest();
            Boolean err1 = CMN_KYC_ExperienceUI.ocrResponseCheck(new Map<String, Object>{'statuscode' => 200, 'PersonalNumber' => 'DIFF'}, false, pivList);
            Boolean err2 = CMN_KYC_ExperienceUI.ocrResponseCheck(new Map<String, Object>{'statuscode' => 200, 'PersonalNumber' => ''}, false, pivList);
            Boolean err3 = CMN_KYC_ExperienceUI.ocrResponseCheck(new Map<String, Object>{'statuscode' => 500}, false, pivList);
        Test.stopTest();
        
        Assert.isTrue(err1, 'Should error on mismatch');
        Assert.isTrue(err2, 'Should error on blank');
        Assert.isTrue(err3, 'Should error on non-200 status');
    }

    /**
     * @description Combined OCR functional checks and Country logic.
     */
    @IsTest
    static void ugOcrCheck_FunctionalScenarios() {
        PartyProfile profile = [SELECT Id FROM PartyProfile LIMIT 1];
           
        profile.WI_IdentificationDocumentIssuingCountry__c = 'ZA';
        update profile;
        Boolean nonUgResult = CMN_KYC_ExperienceUI.ugOcrCheck(profile.Id);
        
        profile.WI_IdentificationDocumentIssuingCountry__c = 'UG';
        update profile;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CMN_KYC_ExperienceUI_OCRFailureMock());
            CMN_KYC_ExperienceUI.ugOcrCheck(profile.Id);
        Test.stopTest();    
        
        Assert.isFalse(nonUgResult, 'Should bypass for non-UG');
        PartyIdentityVerification updatedPIV = [SELECT ResultOverrideReason FROM PartyIdentityVerification WHERE Name = :WFR_PIV_NAME LIMIT 1];
        Assert.areEqual(OCR_FAILED, updatedPIV.ResultOverrideReason, 'Party identification verification failed');
    }

    @IsTest
    static void uploadPIVDocument_ValidFile() {
        PartyIdentityVerification piv = [SELECT Id FROM PartyIdentityVerification LIMIT 1];
        CMN_KYC_ExperienceUI.FileDataWP fileData = new CMN_KYC_ExperienceUI.FileDataWP();
        fileData.fileName = TEST_FILE_NAME;
        fileData.fileContent = TEST_FILE_CONTENT;
        
        Test.startTest();
        	Id result = CMN_KYC_ExperienceUI.uploadPIVDocument(piv.Id, JSON.serialize(new List<CMN_KYC_ExperienceUI.FileDataWP>{fileData}));
        Test.stopTest();
        
        Assert.areEqual(piv.Id, result, 'Party identity verification id should match');
        Assert.areEqual(1, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :piv.Id], 'Content document link found');
    }

    @IsTest
    static void wrapperClasses_Coverage() {
        CMN_KYC_ExperienceUI.PicklistOption option = new CMN_KYC_ExperienceUI.PicklistOption();
        option.label = 'L'; 
        option.value = 'V';
        CMN_KYC_ExperienceUI.FileDataWP file = new CMN_KYC_ExperienceUI.FileDataWP();
        file.fileName = 'N'; 
        file.fileContent = 'C';
        
        Assert.areEqual('L', option.label, 'Label match found');
        Assert.areEqual('N', file.fileName, 'File name match found');
    }

    // ============================================
    // HTTP CALLOUT MOCK CLASSES
    // ============================================
    
    private class CMN_KYC_ExperienceUI_OCRFailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(HEADER_CONTENT_TYPE, HEADER_APPLICATION_JSON);
            res.setStatusCode(200);
            res.setBody('{"IdentityDocumentMetadatas":[{"FrontVIZFields":{"DateOfExpiry":"","PersonalNumber":""}}]}');
            return res;
        }
    }
}