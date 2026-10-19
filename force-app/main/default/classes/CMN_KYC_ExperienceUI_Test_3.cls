@IsTest
private class CMN_KYC_ExperienceUI_Test_3 {

    @TestSetup
    static void setupData() {
        // Create a Party Profile
        PartyProfile pp = new PartyProfile(
            Name = 'Test Profile',
            WI_PrimaryIdentificationName__c = '123456789',
            WI_IdentificationDocumentIssuingCountry__c = 'UG'
        );
        insert pp;

        // Create a Party Identity Verification
        PartyIdentityVerification piv = new PartyIdentityVerification(
            Name = 'WFR',
            PartyProfileId = pp.Id,
            Result = 'On Hold',
            ThirdPartyVerfdentifier = 'REQ-123'
        );
        insert piv;
    }

    @IsTest
    static void testFetchPIV() {
        PartyProfile pp = [SELECT Id FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        String result = CMN_KYC_ExperienceUI.fetchPIV(pp.Id, 'WFR');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isTrue(result.contains('WFR'), 'JSON should contain the PIV name');
    }

    @IsTest
    static void testFetchProfileDetails() {
        PartyProfile pp = [SELECT Id FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        String result = CMN_KYC_ExperienceUI.fetchProfileDetails(new List<Id>{pp.Id});
        Test.stopTest();
        
        Assert.isNotNull(result);
        Assert.isTrue(result.contains('Test Profile'));
    }

    @IsTest
    static void testUpdatePIV() {
        PartyProfile pp = [SELECT Id FROM PartyProfile LIMIT 1];
        PartyIdentityVerification piv = [SELECT Id, Name FROM PartyIdentityVerification LIMIT 1];
        piv.Result = 'Passed';
        
        String jsonData = JSON.serialize(new List<PartyIdentityVerification>{piv});

        Test.startTest();
        String result = CMN_KYC_ExperienceUI.updatePIV(pp.Id, jsonData);
        Test.stopTest();
        
        Assert.isNotNull(result);
        // Note: In real scenarios, verify if KYC_SRV_PartyIdentityVerification was called
    }

    @IsTest
    static void testGetPicklistValues() {
        Test.startTest();
        // Using PartyProfile as an example, ensure 'Status' or similar picklist exists
        List<CMN_KYC_ExperienceUI.PicklistOption> options = 
            CMN_KYC_ExperienceUI.getPicklistValues('PartyProfile', 'Status'); 
        Test.stopTest();
        
        Assert.isNotNull(options);
    }

    @IsTest
    static void testUpsertPartyProfile() {
        PartyProfile pp = [SELECT Id, Name FROM PartyProfile LIMIT 1];
        pp.Name = 'Updated Name';
        String jsonData = JSON.serialize(new List<PartyProfile>{pp});

        Test.startTest();
        List<PartyProfile> results = CMN_KYC_ExperienceUI.upsertPartyProfile(jsonData);
        Test.stopTest();

        Assert.areEqual('Updated Name', results[0].Name);
    }

    @IsTest
    static void testUploadPIVDocument() {
        PartyIdentityVerification piv = [SELECT Id FROM PartyIdentityVerification LIMIT 1];
        
        CMN_KYC_ExperienceUI.FileDataWP file = new CMN_KYC_ExperienceUI.FileDataWP();
        file.fileName = 'test.pdf';
        file.fileContent = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));
        
        String fileData = JSON.serialize(new List<CMN_KYC_ExperienceUI.FileDataWP>{file});

        Test.startTest();
        Id resultId = CMN_KYC_ExperienceUI.uploadPIVDocument(piv.Id, fileData);
        Test.stopTest();

        Assert.areEqual(piv.Id, resultId);
    }

    @IsTest
    static void testOcrResponseCheck_Success() {
        // Mocking the internal logic for the OCR check
        Map<String, Object> ocrFields = new Map<String, Object>{
            'statuscode' => 200,
            'DateOfExpiry' => '20.12.2030', // Future date
            'PersonalNumber' => '123456789'
        };
        
        List<PartyIdentityVerification> pivRecord = [SELECT Id, PartyProfile.WI_PrimaryIdentificationName__c FROM PartyIdentityVerification];
        
        Test.startTest();
        Boolean hasError = CMN_KYC_ExperienceUI.ocrResponseCheck(ocrFields, false, pivRecord);
        Test.stopTest();

        Assert.isFalse(hasError, 'Should not have error for valid data');
    }

    @IsTest
    static void testOcrResponseCheck_Failure() {
        Map<String, Object> ocrFields = new Map<String, Object>{
            'statuscode' => 200,
            'DateOfExpiry' => '01.01.2020', // Expired date
            'PersonalNumber' => 'WRONG_ID'
        };
        
        List<PartyIdentityVerification> pivRecord = [SELECT Id, PartyProfile.WI_PrimaryIdentificationName__c FROM PartyIdentityVerification];
        
        Test.startTest();
        Boolean hasError = CMN_KYC_ExperienceUI.ocrResponseCheck(ocrFields, false, pivRecord);
        Test.stopTest();

        Assert.isTrue(hasError, 'Should have error for expired date and mismatched ID');
    }
}