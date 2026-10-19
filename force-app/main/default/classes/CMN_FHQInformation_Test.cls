/***************************************************************************************
@ Author            : jyothsna.datla@standardbank.co.za
@ Date              : 18-02-2026
@ Name of the Class : CMN_FHQInformation_Test
 Ver       Date         Author                              Modification       
1.0      Feb 2026   jyothsna.datla@standardbank.co.za         Initial Version(PPBSF-291) 
***************************************************************************************/
@IsTest
private class CMN_FHQInformation_Test {

    /**
     * @description Helper method to create a Lead record with or without
     * Source_System_Reference__c for testing different scenarios.
     */
    private static Lead createLead(Boolean withReference) {
        Lead l = new Lead(
            LastName = 'TestLead',
            Company  = 'TestCompany'
        );
        if (withReference) {
            l.Source_System_Reference__c = PRX_CTRL_Constants.SOURCESYSREFERENCE;
        }
        insert l;
        return l;
    }

    /**
     * @description Helper method to create CMN_Question_Response__c records
     * linked to a specific User_Id__c and question text.
     */
    private static CMN_Question_Response__c createResponse(
            String userId, String questionText) {
        CMN_Question_Response__c resp = new CMN_Question_Response__c(
            User_Id__c            = userId,
            CMN_Question_Text__c  = questionText,
            CMN_Response_Value__c = 'Yes'
        );
        insert resp;
        return resp;
    }

    /**
     * @description Tests FHQData method when a blank recordId is passed
     * and verifies that an empty map is returned.
     */
    @IsTest
    static void testBlankRecordId() {
        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData('');
        Test.stopTest();
        Assert.areEqual(0, result.size(), 'Expected empty map for blank recordId');
    }

    /**
     * @description Tests FHQData method when a null recordId is passed
     * and verifies that an empty map is returned.
     */
    @IsTest
    static void testNullRecordId() {
        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData(null);
        Test.stopTest();
        Assert.areEqual(0, result.size(), 'Expected empty map for null recordId');
    }

    /**
     * @description Tests FHQData method when the user does not have
     * read permission on Lead object and verifies empty response.
     */
    @IsTest
    static void testNoLeadPermission() {
        Lead l = createLead(true);
        CMN_FHQInformation.simulateNoPermission = true;
        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData(l.Id);
        Test.stopTest();
        CMN_FHQInformation.simulateNoPermission = false;
        Assert.areEqual(0, result.size(), 'Expected empty map when permission denied');
    }

    /**
     * @description Tests scenario where Lead exists but does not contain
     * Source_System_Reference__c, causing selector to return no records.
     */
    @IsTest
    static void testLeadNotFoundBySelector() {
        Lead l = createLead(false); // no Source_System_Reference__c → selector returns []
        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData(l.Id);
        Test.stopTest();
        Assert.areEqual(0, result.size(), 'Expected empty map when selector returns no leads');
    }

    /**
     * @description Tests FHQData method when Lead has Source_System_Reference__c
     * but no CMN Question Responses exist.
     */
    @IsTest
    static void testLeadWithReferenceNoResponses() {
        Lead l = createLead(true);
        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData(l.Id);
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areEqual(0, result.size(), 'Expected empty map when no responses exist');
    }

    /**
     * @description Tests FHQData method when Lead has valid responses
     * and verifies that responses are added to the map correctly.
     */
    @IsTest
    static void testLeadWithReferenceAndResponses() {
        Lead l = createLead(true);
        createResponse(PRX_CTRL_Constants.SOURCESYSREFERENCE, 'What is your monthly income?');
        createResponse(PRX_CTRL_Constants.SOURCESYSREFERENCE, 'Do you have savings?');

        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData(l.Id);
        Test.stopTest();

        Assert.areEqual(2, result.size(), 'Expected 2 entries in responseMap');
        Assert.isTrue(result.containsKey('What is your monthly income?'));
        Assert.isTrue(result.containsKey('Do you have savings?'));
    }

    /**
     * @description Tests scenario where response contains blank
     * CMN_Question_Text__c and verifies it is excluded from the map.
     */
    @IsTest
    static void testResponseWithBlankQuestionText() {
        Lead l = createLead(true);
        createResponse(PRX_CTRL_Constants.SOURCESYSREFERENCE, 'Valid Question?');
        insert new CMN_Question_Response__c(
            User_Id__c            = PRX_CTRL_Constants.SOURCESYSREFERENCE,
            CMN_Response_Value__c = 'ShouldBeSkipped'
        );

        Test.startTest();
        Map<String, CMN_Question_Response__c> result =
            CMN_FHQInformation.FHQData(l.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Blank question text responses should be excluded');
        Assert.isTrue(result.containsKey('Valid Question?'));
    }

    /**
     * @description Tests the exception handling of FHQData method
     * by simulating an internal error and verifying AuraHandledException.
     */
    @IsTest
    static void testFHQDataCatchBlock() {
        CMN_FHQInformation.simulateFHQDataError = true;
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            CMN_FHQInformation.FHQData('someId');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        CMN_FHQInformation.simulateFHQDataError = false;
        Assert.isTrue(exceptionThrown, 'Expected AuraHandledException from FHQData catch block');
    }

    /**
     * @description Tests exception handling in getFHQMetadata method
     * when metadata retrieval fails.
     */
    @IsTest
    static void testGetFHQMetadataCatchBlock() {
        CMN_FHQInformation.simulateMetadataError = true;
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            CMN_FHQInformation.getFHQMetadata();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        CMN_FHQInformation.simulateMetadataError = false;
        Assert.isTrue(exceptionThrown, 'Expected AuraHandledException from getFHQMetadata catch block');
    }

    /**
     * @description Tests hasLeadReadPermission method when user
     * has valid read access to Lead object and field.
     */
    @IsTest
    static void testPermissionMethodPositive() {
        Boolean result = CMN_FHQInformation.hasLeadReadPermission();
        Assert.areEqual(true, result, 'System Admin should have Lead read access');
    }

    /**
     * @description Tests hasLeadReadPermission method when permission
     * is simulated as false using test flag.
     */
    @IsTest
    static void testPermissionMethodNegative() {
        CMN_FHQInformation.simulateNoPermission = true;
        Boolean result = CMN_FHQInformation.hasLeadReadPermission();
        CMN_FHQInformation.simulateNoPermission = false;
        Assert.areEqual(false, result, 'Expected false when permission is simulated off');
    }

    /**
     * @description Tests getFHQMetadata method under normal conditions
     * and verifies metadata records are returned successfully.
     */
    @IsTest
    static void testMetadataHappyPath() {
        Test.startTest();
        List<FHQ_Question_Configuration__mdt> data =
            CMN_FHQInformation.getFHQMetadata();
        Test.stopTest();
        Assert.areNotEqual(null, data, 'Metadata list should not be null');
    }
}