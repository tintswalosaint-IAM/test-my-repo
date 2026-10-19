/**
* @description  Class used as test class for ICS_API_UpdateTINRequestData_Test
* Story: SFP-37310
* @author Ramya Gurram
* @date 15/10/2024
* @last modified on  :16/10/2024
* @last modified by  :  Ramya Gurram
* @Modification Description : updated to latest Version
 ****************************************************************************************
 * @Last Modified By 		: Ramya Gurram
 * @Last Modified On 		: 19-06-2025
 * @Modification description :SFP-50469
*/
@IsTest
private class ICS_API_UpdateTINRequestData_Test {
     /**
     * @description Sets up test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(testAccount.Id);
        testPartyProfile.Country_of_Residence__c = 'ZA';
        update testPartyProfile;

        TaxDetails__c testTaxDetails = ICS_DAL_TestFactory.createTaxDetails(testAccount.Id);
        testTaxDetails.Country__c = 'ZA';
        testTaxDetails.TIN_IN_Number__c = '123456789';
        update testTaxDetails;
        Assessment testAssessment = ICS_DAL_TestFactory.createAssessment(testAccount.Id);

        AssessmentQuestion testQuestion = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'MainTaxResidency',
            Name = 'Is your Country of Residence your main tax residency?',
            QuestionCategory = 'Financial'
        );
        insert testQuestion;

        AssessmentQuestionVersion testQuestionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = testQuestion.Id,
            QuestionText = 'Is your Country of Residence your main tax residency?',
            Name = 'Is your Country of Residence your main tax residency?',
            IsActive = true
        );
        insert testQuestionVersion;

        AssessmentQuestionResponse testResponse = new AssessmentQuestionResponse(
            AssessmentId = testAssessment.id,
            AssessmentQuestionId = testQuestionVersion.Id,
            Name = 'Tax Certificates',
            ResponseText = 'TRUE'
        );
        insert testResponse;
    }
     /**
     * @description: The method used to call the UpdateTin RequestBody
     */
    @IsTest
    static void testPrepareTINJson_Success() {
        Account testAccount = [SELECT Id, ExternalCIFId__c, PersonContactId FROM Account LIMIT 1];
        ICS_API_UpdateTINRequestData requestData = new ICS_API_UpdateTINRequestData();

        Test.startTest();
        String jsonResult = requestData.prepareTINJson(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(true, String.isNotBlank(jsonResult), 'JSON result should not be null or empty');
        Map<String, Object> deserializedResult = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        Assert.areEqual(testAccount.ExternalCIFId__c, deserializedResult.get('bpId'), 'bpId should match');
        Assert.areEqual(testAccount.PersonContactId, deserializedResult.get('contactId'), 'contactId should match');

        List<Object> taxInfo = (List<Object>)deserializedResult.get('taxInfo');
        Assert.areEqual(false, taxInfo == null, 'taxInfo should not be null');
        Assert.areEqual(1, taxInfo.size(), 'There should be one tax info entry');

        Map<String, Object> taxInfoEntry = (Map<String, Object>)taxInfo[0];
        Assert.areEqual('Y', taxInfoEntry.get('mainTaxResidency'), 'mainTaxResidency should be Y');
        Assert.areEqual('ZA', taxInfoEntry.get('country'), 'country should be South Africa');
        Assert.areEqual('123456789', taxInfoEntry.get('tinNumber'), 'tinNumber should match');
        Assert.areEqual(false, taxInfoEntry.get('taxExemptReason') == null, 'taxExemptReason should not be null');
    }
    /**
     * @description: The method used to call the UpdateTin RequestBody for No Account
     */
    @IsTest
    static void testPrepareTINJson_NoAccount() {
        ICS_API_UpdateTINRequestData requestData = new ICS_API_UpdateTINRequestData();
        Test.startTest();
        String jsonResult = requestData.prepareTINJson(null);
        Test.stopTest();
        Assert.areEqual(null, jsonResult, 'JSON result should be null for invalid account ID');
    }

    /**
     * @description: The method used to call the UpdateTin RequestBody
     */
    @IsTest
    static void testPrepareTINJson_NoTaxDetails() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        delete [SELECT Id FROM TaxDetails__c WHERE Account__c = :testAccount.Id];

        ICS_API_UpdateTINRequestData requestData = new ICS_API_UpdateTINRequestData();
        Test.startTest();
        String jsonResult = requestData.prepareTINJson(testAccount.Id);
        Test.stopTest();
        Assert.areEqual(true, jsonResult != null, 'JSON result should not be null even without tax details');
        Map<String, Object> deserializedResult = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        List<Object> taxInfo = (List<Object>)deserializedResult.get('taxInfo');
        Assert.areEqual(0, taxInfo.size(), 'There should be no tax info entries');
    }

    /**
     * @description: The method used to call the UpdateTin for No Main TaxResidency
     */
    @IsTest
    static void testPrepareTINJson_NoMainTaxResidency() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        AssessmentQuestionResponse response = [SELECT Id, ResponseText FROM AssessmentQuestionResponse WHERE Assessment.AccountId = :testAccount.Id AND Name = 'Tax Certificates' LIMIT 1];
        response.ResponseText = 'FALSE';
        update response;

        ICS_API_UpdateTINRequestData requestData = new ICS_API_UpdateTINRequestData();

        // Act
        Test.startTest();
        String jsonResult = requestData.prepareTINJson(testAccount.Id);
        Test.stopTest();

        // Assert
        Assert.areEqual(true, jsonResult != null, 'JSON result should not be null');
        Map<String, Object> deserializedResult = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        List<Object> taxInfo = (List<Object>)deserializedResult.get('taxInfo');
        Assert.isFalse(taxInfo.isEmpty(), 'Tax info should not be empty');
        Map<String, Object> taxInfoEntry = (Map<String, Object>)taxInfo[0];

        Assert.areEqual('', taxInfoEntry.get('mainTaxResidency'), 'mainTaxResidency should be empty string');
    }

    /**
     * @description: The method used to call the UpdateTin for No Assessment Response
     */
    @IsTest
    static void testPrepareTINJson_NoAssessmentResponse() {
        // Arrange
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        delete [SELECT Id FROM AssessmentQuestionResponse WHERE Assessment.AccountId = :testAccount.Id];

        ICS_API_UpdateTINRequestData requestData = new ICS_API_UpdateTINRequestData();

        // Act
        Test.startTest();
        String jsonResult = requestData.prepareTINJson(testAccount.Id);
        Test.stopTest();

        // Assert
        Assert.areEqual(true, jsonResult != null, 'JSON result should not be null even without assessment response');
        Map<String, Object> deserializedResult = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        List<Object> taxInfo = (List<Object>)deserializedResult.get('taxInfo');
        Assert.isFalse(taxInfo.isEmpty(), 'Tax info should not be empty');
        Map<String, Object> taxInfoEntry = (Map<String, Object>)taxInfo[0];
        Assert.areEqual('', taxInfoEntry.get('mainTaxResidency'), 'mainTaxResidency should be empty string when no assessment response');
    }
}