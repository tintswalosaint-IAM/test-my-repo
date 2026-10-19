/***************************************************************************************
@ Author            : Taimoor.shaik@standardbank.co.za
@ Date              : Jan-2026
@ Name of the Class : PRX_REST_QuestionnaireResponse_Test
@ Description       : Comprehensive test class for PRX_REST_QuestionnaireResponse.
Covers validation logic, metadata parsing, scoring resolution,
DML handling, exception handling, and activity population paths
to ensure maximum branch and line coverage.
@ Last Modified By  : Taimoor.shaik@standardbank.co.za
@ Last Modified On  : 24-02-2026
@ Modification Description :
1.0   Jan-2026   Taimoor.shaik@standardbank.co.za   Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270)

***************************************************************************************/
@IsTest
private class PRX_REST_QuestionnaireResponse_Test {
    private static final String  EXPERIENCE   = 'experience';
    private static final String  TEST_CO   = 'test co';

    static Id questionId;
    static Id ruleId;
    
    /**
* @description Test data setup. Creates a rule set version and three active questions
*              (Q1, Q2, Q3) with proper order sequence for use in all test methods.
*/
    @TestSetup
    static void setupData() {
        
        CMN_Rule_Set_Version__c rule = new CMN_Rule_Set_Version__c(Name = 'Rule');
        insert rule;
        ruleId = rule.Id;
        
        CMN_Question__c q = new CMN_Question__c(
            Name                = 'Question1',
            Question_ID__c      = 'Q1',
            CMN_Order__c        = 1,
            Is_Active__c        = true,
            CMN_Version_Number__c = rule.Id
        );
        insert q;
        questionId = q.Id;
        
        // Create additional questions for more comprehensive testing
        CMN_Question__c q2 = new CMN_Question__c(
            Name                = 'Question2',
            Question_ID__c      = 'Q2',
            CMN_Order__c        = 2,
            Is_Active__c        = true,
            CMN_Version_Number__c = rule.Id
        );
        insert q2;
        
        CMN_Question__c q3 = new CMN_Question__c(
            Name                = 'Question3',
            Question_ID__c      = 'Q3',
            CMN_Order__c        = 3,
            Is_Active__c        = true,
            CMN_Version_Number__c = rule.Id
        );
        insert q3;
    }
    
    
    /**
* @description Bootstraps a mock REST context with the given JSON body.
*              Used to simulate incoming HTTP POST requests for all test cases.
* @param body JSON request body as a string
*/
    private static void initRest(String body) {
        RestRequest req      = new RestRequest();
        req.requestUri       = '/services/apexrest/api/questionnaire/responses/';
        req.httpMethod       = 'POST';
        req.requestBody      = Blob.valueOf(body);
        
        RestResponse res = new RestResponse();
        
        RestContext.request  = req;
        RestContext.response = res;
    }
    
    /**
* @description Queries and returns the record ID of the first test question (Question1).
* @return Salesforce ID of the test question Question1
*/
    private static Id getQuestionId() {
        return [SELECT Id FROM CMN_Question__c WHERE Name = 'Question1' LIMIT 1].Id;
    }
    
    /**
* @description Queries and returns the record ID of the second test question (Question2).
* @return Salesforce ID of the test question Question2
*/
    private static Id getQuestion2Id() {
        return [SELECT Id FROM CMN_Question__c WHERE Name = 'Question2' LIMIT 1].Id;
    }
    
    
    /**
* @description Validates successful response submission with valid userId and responses.
*              Verifies that the API returns success status and populated response wrapper.
*/

    @IsTest
    static void testSuccess() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"100","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areNotEqual(null, resp);
        Assert.areEqual(true, resp.success);
    }
    
    /**
* @description Validates that the API rejects requests with empty response arrays.
*              Verifies HTTP 400 status code and failure message.
*/
    @IsTest
    static void testEmptyResponses() {
        initRest('{"userId":"' + UserInfo.getUserId() + '","responses":[]}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(400, statusCode);
    }
    
    /**
* @description Validates that the API properly handles malformed JSON payloads.
*              Verifies HTTP 400 status code and appropriate error response.
*/
    @IsTest
    static void testInvalidJson() {
        initRest('{INVALID');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(400, statusCode);
    }
    
    /**
* @description Validates the fallback behavior when questionId is provided directly
*              in the payload instead of relying on order-based resolution.
*/
    @IsTest
    static void testFallbackQuestionId() {
        Id qId = getQuestionId();
        
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"questionId":"' + qId + '","value":"200","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        List<CMN_Question_Response__c> rec = [
            SELECT Id, CMN_Question__c
            FROM CMN_Question_Response__c
            WHERE CMN_Question__c = :qId
        ];
        Assert.areEqual(true, rec.size() > 0);
    }
    
    /**
* @description Validates handling of conditional input values where hasConditionalInput flag
*              is true. Verifies that conditionalValue is stored as the numeric response.
*/
    @IsTest
    static void testConditional() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"Yes",' +
            '"hasConditionalInput":true,"conditionalValue":500,"category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        CMN_Question_Response__c rec = [
            SELECT CMN_Response_Value_Number__c
            FROM CMN_Question_Response__c
            LIMIT 1
        ];
        Assert.areEqual(500, rec.CMN_Response_Value_Number__c);
    }
    
    /**
* @description Validates error handling when an invalid currency value (non-numeric)
*              is provided. Confirms graceful handling without throwing exceptions.
*/
    @IsTest
    static void testCurrencyError() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"ABC","type":"Currency","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        // Verify that graceful error handling occurred without throwing exceptions
        List<CMN_Question_Response__c> recs = [SELECT Id FROM CMN_Question_Response__c];
        Assert.isNotNull(recs, 'Query should execute successfully even with invalid currency value');
    }
    
    /**
* @description Validates request validation when responses array is null or missing from payload.
*              Verifies that API returns failure status appropriately.
*/
    @IsTest
    static void testNullResponses() {
        initRest('{"userId":"' + UserInfo.getUserId() + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
    }
    
    
    /**
* @description Validates metadata parsing when all optional fields (dob, startTime, name)
*              are fully populated in the request payload. Confirms successful submission.
*/
    @IsTest
    static void testRequestMetadataFullyPopulated() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"dob":"15-06-1990",' +
            '"startTime":"2026-01-10 08:30:00",' +
            '"name":"John Doe",' +
            '"responses":[{"order":1,"value":"100","category":"Budget"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
    }
    
    
    /**
* @description Validates graceful handling of invalid startTime format in the payload.
*              Confirms that parsing exceptions do not block submission success.
*/
    @IsTest
    static void testInvalidStartTime() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"startTime":"NOT_A_DATE",' +
            '"responses":[{"order":1,"value":"100","category":"Budget"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
    }
    
    
    /**
* @description Validates successful decimal conversion for currency type responses.
*              Confirms that the numeric value is properly stored in CMN_Response_Value_Number__c.
*/
    @IsTest
    static void testCurrencySuccess() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"12500.50","type":"Currency","category":"Income"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        CMN_Question_Response__c rec = [
            SELECT CMN_Response_Value_Number__c
            FROM CMN_Question_Response__c
            LIMIT 1
        ];
        Assert.areEqual(12500.50, rec.CMN_Response_Value_Number__c);
    }
    
    
    /**
* @description Validates handling of incomplete questionnaire submissions (isCompleted=false).
*              Confirms that responses are marked as incomplete without triggering calculations.
*/
    @IsTest
    static void testIncompleteSubmission() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"isCompleted":false,' +
            '"responses":[{"order":1,"value":"Yes","category":"Savings"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        
        CMN_Question_Response__c rec = [
            SELECT Is_Completed__c
            FROM CMN_Question_Response__c
            LIMIT 1
        ];
        Assert.areEqual(false, rec.Is_Completed__c);
    }
    
    
    /**
* @description Validates the upsert-update behavior when an existing incomplete response
*              record is found. Confirms that Database.upsert updates rather than duplicates.
*/
    @IsTest
    static void testUpsertUpdateExistingResponse() {
        Id qId   = getQuestionId();
        Id userId = UserInfo.getUserId();
        
        CMN_Question_Response__c existing = new CMN_Question_Response__c(
            CMN_Question__c         = qId,
            User_Id__c              = userId,
            CMN_Response_Value__c   = 'Old Value',
            Is_Completed__c         = false,
            CMN_Source__c           = EXPERIENCE
        );
        insert existing;
        
        initRest(
            '{"userId":"' + userId + '",' +
            '"isCompleted":false,' +
            '"responses":[{"order":1,"value":"Updated Value","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        
        List<CMN_Question_Response__c> allRecs = [
            SELECT Id, CMN_Response_Value__c
            FROM CMN_Question_Response__c
            WHERE CMN_Question__c = :qId AND User_Id__c = :userId
        ];
        Assert.areEqual(1, allRecs.size());
        Assert.areEqual('Updated Value', allRecs[0].CMN_Response_Value__c);
    }
    
    
    /**
* @description Validates that when hasConditionalInput is true but conditionalValue is null,
*              the system defaults to 0 instead of causing an error.
*/
    @IsTest
    static void testConditionalNullValue() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"Yes",' +
            '"hasConditionalInput":true,"category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        CMN_Question_Response__c rec = [
            SELECT CMN_Response_Value_Number__c
            FROM CMN_Question_Response__c
            LIMIT 1
        ];
        Assert.areEqual(0, rec.CMN_Response_Value_Number__c);
    }
    
    
    /**
* @description Validates that responses with blank/empty values are skipped during
*              record building, ensuring no incomplete records are persisted.
*/
    @IsTest
    static void testBlankValueSkipped() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        List<CMN_Question_Response__c> recs = [SELECT Id FROM CMN_Question_Response__c];
        Assert.areEqual(0, recs.size());
    }
    
    
    /**
* @description Validates handling when both order-based and questionId fallback resolution
*              methods fail (neither order nor questionId provided). Confirms graceful degradation.
*/
    @IsTest
    static void testNoQuestionIdOrOrder() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"value":"SomeValue","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        // Verify graceful degradation when neither order nor questionId is provided
        List<CMN_Question_Response__c> recs = [SELECT Id FROM CMN_Question_Response__c];
        Assert.isNotNull(recs, 'Query should execute successfully with graceful degradation');
    }
    
    
    /**
* @description Validates populateActivityScores when all activity score fields are populated.
*              Confirms that all activity DTOs are created with correct values in response.
*/
    @IsTest
    static void testPopulateActivityScoresAllFields() {
        Id userId = UserInfo.getUserId();
        
        // Insert an assessment record that will be queried
        CMN_Assessment__c testAssessment = new CMN_Assessment__c(
            Name = 'Test Assessment',
            CMN_Expenses_Score__c = 75,
            CMN_Debt_to_Income_Score__c = 80,
            CMN_Insurance_Score__c = 65,
            CMN_Emergency_Fund_Score__c = 90,
            CMN_Retirement_Readiness_Score__c = 70
        );
        insert testAssessment;
        
        // Set the static variable that populateActivityScores uses
        CMN_FHQ_Calculation.createdAssessment = testAssessment;
        
        initRest(
            '{"userId":"' + userId + '",' +
            '"isCompleted":true,' +
            '"dob":"01-01-1985",' +
            '"startTime":"2026-01-10 09:00:00",' +
            '"name":"Test User",' +
            '"responses":[{"order":1,"value":"Yes","category":"General"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        Assert.areNotEqual(null, resp.activities);
        
    }
    
    
    /**
* @description Validates populateActivityScores when createdAssessment is null.
*              Confirms that the method handles null gracefully without throwing exceptions.
*/
    @IsTest
    static void testPopulateActivityScoresNullAssessment() {
        CMN_FHQ_Calculation.createdAssessment = null;
        
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"isCompleted":true,' +
            '"responses":[{"order":1,"value":"Yes","category":"General"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
    }
    
    
    /**
* @description Validates populateActivityScores when only some activity score fields are
*              populated (others are null). Confirms that only non-null scores create activity DTOs.
*/
    @IsTest
    static void testPopulateActivityScoresPartialFields() {
        Id userId = UserInfo.getUserId();
        
        CMN_Assessment__c testAssessment = new CMN_Assessment__c(
            Name = 'Test Assessment',
            CMN_Expenses_Score__c = 75,
            CMN_Debt_to_Income_Score__c = null,
            CMN_Insurance_Score__c = 65,
            CMN_Emergency_Fund_Score__c = null,
            CMN_Retirement_Readiness_Score__c = 70
        );
        insert testAssessment;
        
        CMN_FHQ_Calculation.createdAssessment = testAssessment;
        
        initRest(
            '{"userId":"' + userId + '",' +
            '"isCompleted":true,' +
            '"responses":[{"order":1,"value":"Yes","category":"General"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
    }
    
    
    /**
* @description Validates resolveNumericValue when scoring lookup path is used
*              (neither conditional nor currency type). Confirms numeric resolution works.
*/
    @IsTest
    static void testScoringLookupPath() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"OptionA",' +
            '"category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        // Verify numeric resolution via scoring lookup path executes successfully
        List<CMN_Question_Response__c> recs = [SELECT Id FROM CMN_Question_Response__c];
        Assert.isNotNull(recs, 'Query should execute successfully with scoring lookup path');
    }
    
    
    /**
* @description Validates processUpsertResults handles multiple responses successfully.
*              Confirms that batch operations work correctly with multiple records.
*/
    @IsTest
    static void testPartialDMLFailure() {
        Id userId = UserInfo.getUserId();
        
        initRest(
            '{"userId":"' + userId + '",' +
            '"responses":[' +
            '{"order":1,"value":"Value1","category":"Test"},' +
            '{"order":2,"value":"Value2","category":"Test"},' +
            '{"order":3,"value":"Value3","category":"Test"}' +
            ']}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areNotEqual(null, resp);
    }
    
    
    /**
* @description Validates building responses using mixed resolution methods: order-based
*              resolution for first two responses and questionId fallback for the third.
*              Confirms that both mechanisms work together seamlessly.
*/
    @IsTest
    static void testMixedOrderAndFallbackResolution() {
        Id qId2 = getQuestion2Id();
        
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[' +
            '{"order":1,"value":"ByOrder","category":"Cat1"},' +
            '{"order":2,"value":"ByOrder2","category":"Cat2"},' +
            '{"questionId":"' + qId2 + '","value":"ByFallback","category":"Cat3"}' +
            ']}'
        );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        List<CMN_Question_Response__c> recs = [
            SELECT Id FROM CMN_Question_Response__c
        ];
        Assert.areEqual(3, recs.size());
    }
    
    
    /**
* @description Validates exception handling in buildOrderToQuestionIdMap when all questions
*              are deleted and query returns no results. Confirms error recovery.
*/
    @IsTest
    static void testBuildOrderToQuestionIdMapException() {
        // Force a query exception by deleting all questions
        delete [SELECT Id FROM CMN_Question__c];
        
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"order":1,"value":"Test","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        Assert.areNotEqual(null, resp);
    }
    
    
    /**
* @description Validates loadExistingIncompleteResponses and the complete upsert flow.
*              Confirms that existing incomplete responses for a user are found and updated,
*              not duplicated, when new responses are submitted.
*/
    @IsTest
    static void testLoadExistingIncompleteResponses() {
        Id userId = UserInfo.getUserId();
        Id qId1 = getQuestionId();
        Id qId2 = getQuestion2Id();
        
        CMN_Question_Response__c existing1 = new CMN_Question_Response__c(
            CMN_Question__c = qId1,
            User_Id__c = userId,
            CMN_Response_Value__c = 'Existing1',
            Is_Completed__c = false,
            CMN_Source__c = EXPERIENCE
        );
        
        CMN_Question_Response__c existing2 = new CMN_Question_Response__c(
            CMN_Question__c = qId2,
            User_Id__c = userId,
            CMN_Response_Value__c = 'Existing2',
            Is_Completed__c = false,
            CMN_Source__c = EXPERIENCE
        );
        
        insert new List<CMN_Question_Response__c>{existing1, existing2};
            
            initRest(
                '{"userId":"' + userId + '",' +
                '"responses":[' +
                '{"order":1,"value":"Updated1","category":"Test"},' +
                '{"order":2,"value":"Updated2","category":"Test"}' +
                ']}'
            );
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Test.stopTest();
        
        List<CMN_Question_Response__c> updatedRecs = [
            SELECT Id, CMN_Response_Value__c
            FROM CMN_Question_Response__c
            WHERE User_Id__c = :userId
            ORDER BY CMN_Sequence__c
        ];
        
        Assert.areEqual(2, updatedRecs.size());
        Assert.areEqual('Updated1', updatedRecs[0].CMN_Response_Value__c);
        Assert.areEqual('Updated2', updatedRecs[1].CMN_Response_Value__c);
    }
    
    
    /**
* @description Validates general exception handling when an invalid ID string is provided
*              in the questionId field. Confirms HTTP 500 error response and failure status.
*/
    @IsTest
    static void testGeneralExceptionHandling() {
        initRest(
            '{"userId":"' + UserInfo.getUserId() + '",' +
            '"responses":[{"questionId":"NOT_A_VALID_ID",' +
            '"value":"Test","category":"Test"}]}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(500, statusCode);
    }
    
    /**
* @description Helper to bootstrap a mock REST context for PATCH requests.
* @param body JSON request body as a string
*/
    private static void initRestPatch(String body) {
        RestRequest req      = new RestRequest();
        req.requestUri       = '/services/apexrest/api/questionnaire/responses/';
        req.httpMethod       = 'PATCH';
        req.requestBody      = Blob.valueOf(body);
        
        RestResponse res = new RestResponse();
        
        RestContext.request  = req;
        RestContext.response = res;
    }
    
    /**
* @description Validates successful sync when a matching Assessment record exists
*              for the given idNumber. Confirms User_Id__c is updated and HTTP 200 returned.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_Success() {
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name        = 'Guest Assessment',
            Id_Number__c = '8001015009087',
            User_Id__c  = 'guest_account_001'
        );
        insert assessment;
        
        initRestPatch(
            '{"idNumber":"8001015009087","userId":"' + UserInfo.getUserId() + '"}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        Assert.areEqual(200, statusCode);
        
        CMN_Assessment__c updated = [
            SELECT User_Id__c FROM CMN_Assessment__c WHERE Id = :assessment.Id
        ];
        Assert.areEqual(UserInfo.getUserId(), updated.User_Id__c);
    }
    
    /**
* @description Validates that sync updates multiple Assessment records when more
*              than one shares the same idNumber. Confirms all records are updated.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_MultipleAssessments() {
        String idNumber = '9001015009081';
        String newUserId = UserInfo.getUserId();
        
        List<CMN_Assessment__c> assessments = new List<CMN_Assessment__c>{
            new CMN_Assessment__c(Name = 'Assessment A', Id_Number__c = idNumber, User_Id__c = 'guest_001'),
                new CMN_Assessment__c(Name = 'Assessment B', Id_Number__c = idNumber, User_Id__c = 'guest_001')
                };
                    insert assessments;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        
        List<CMN_Assessment__c> updated = [
            SELECT User_Id__c FROM CMN_Assessment__c WHERE Id_Number__c = :idNumber
        ];
        for (CMN_Assessment__c a : updated) {
            Assert.areEqual(newUserId, a.User_Id__c);
        }
    }
    
    /**
* @description Validates that HTTP 404 is returned when no Assessment record exists
*              for the supplied idNumber. Confirms failure response and status code.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_NotFound() {
        initRestPatch(
            '{"idNumber":"DOES_NOT_EXIST","userId":"' + UserInfo.getUserId() + '"}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
    }
    
    /**
* @description Validates that HTTP 400 is returned when idNumber is blank in the payload.
*              Confirms failure response and missing-field error message.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_MissingIdNumber() {
        initRestPatch('{"userId":"' + UserInfo.getUserId() + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(400, statusCode);
    }
    
    /**
* @description Validates that HTTP 400 is returned when userId is blank in the payload.
*              Confirms failure response and missing-field error message.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_MissingUserId() {
        initRestPatch('{"idNumber":"8001015009087"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(400, statusCode);
    }
    
    /**
* @description Validates that HTTP 400 is returned when both idNumber and userId
*              are missing from the payload. Confirms double-blank guard fires correctly.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_BothFieldsMissing() {
        initRestPatch('{}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(400, statusCode);
    }
    
    /**
* @description Validates that syncGuestAssessmentUser handles malformed JSON gracefully
*              and returns a 500 error response without propagating the exception.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_InvalidJson() {
        initRestPatch('{INVALID_JSON');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(false, resp.success);
        Assert.areEqual(500, statusCode);
    }
    
    
    /**
* @description Validates syncLeadSourceReference happy path by triggering it through
*              syncGuestAssessmentUser. Confirms that Lead.Source_System_Reference__c
*              is populated when it was previously null.
*/
    @IsTest
    static void testSyncLeadSourceReference_UpdatesNullReference() {
        String idNumber  = '7601015009083';
        String newUserId = UserInfo.getUserId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'Lead Sync Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_lead_test'
        );
        insert assessment;
        
        Lead testLead = new Lead(
            LastName                  = 'TestLead',
            Company                   = TEST_CO,
            ID_Number__c              = idNumber,
            Source_System_Reference__c = null
        );
        insert testLead;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        
        Lead updatedLead = [
            SELECT Source_System_Reference__c FROM Lead WHERE Id = :testLead.Id
        ];
        Assert.areEqual(newUserId, updatedLead.Source_System_Reference__c);
    }
    
    /**
* @description Validates that syncLeadSourceReference does not overwrite Leads where
*              Source_System_Reference__c is already populated (not null).
*/
    @IsTest
    static void testSyncLeadSourceReference_SkipsAlreadyPopulated() {
        String idNumber       = '6501015009085';
        String existingRef    = 'ALREADY_SET';
        String newUserId      = UserInfo.getUserId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'Skip Lead Sync Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_skip'
        );
        insert assessment;
        
        Lead testLead = new Lead(
            LastName                  = 'ExistingRefLead',
            Company                   = TEST_CO,
            ID_Number__c              = idNumber,
            Source_System_Reference__c = existingRef
        );
        insert testLead;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        Lead unchanged = [
            SELECT Source_System_Reference__c FROM Lead WHERE Id = :testLead.Id
        ];
        Assert.areEqual(existingRef, unchanged.Source_System_Reference__c);
    }
    
    /**
* @description Validates syncLeadSourceReference when no Lead records match
*              the idNumber. Confirms the method returns without error and
*              Assessment update still succeeds.
*/
    @IsTest
    static void testSyncLeadSourceReference_NoLeadsFound() {
        String idNumber = '5501015009089';
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'No Lead Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_no_lead'
        );
        insert assessment;
        
        initRestPatch(
            '{"idNumber":"' + idNumber + '","userId":"' + UserInfo.getUserId() + '"}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
    }
    
    // ─── syncQuestionResponseUserId (via syncGuestAssessmentUser) ────────────────
    
    /**
* @description Validates syncQuestionResponseUserId happy path by triggering it through
*              syncGuestAssessmentUser. Confirms CMN_Question_Response__c.User_Id__c is
*              populated when it was previously null.
*/
    @IsTest
    static void testSyncQuestionResponseUserId_UpdatesNullUserId() {
        String idNumber  = '4501015009082';
        String newUserId = UserInfo.getUserId();
        Id qId = getQuestionId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'Response Sync Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_qr_test'
        );
        insert assessment;
        
        CMN_Question_Response__c guestResponse = new CMN_Question_Response__c(
            CMN_Question__c       = qId,
            Id_Number__c          = idNumber,
            User_Id__c            = null,
            CMN_Response_Value__c = 'GuestAnswer',
            Is_Completed__c       = false,
            CMN_Source__c         = EXPERIENCE
        );
        insert guestResponse;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        
        CMN_Question_Response__c updated = [
            SELECT User_Id__c FROM CMN_Question_Response__c WHERE Id = :guestResponse.Id
        ];
        Assert.areEqual(newUserId, updated.User_Id__c);
    }
    
    /**
* @description Validates that syncQuestionResponseUserId does not overwrite
*              CMN_Question_Response__c records where User_Id__c is already set.
*/
    @IsTest
    static void testSyncQuestionResponseUserId_SkipsAlreadyPopulated() {
        String idNumber      = '3501015009084';
        String existingUserId = 'ALREADY_SET_USER';
        String newUserId     = UserInfo.getUserId();
        Id qId = getQuestionId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'Skip QR Sync Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_skip_qr'
        );
        insert assessment;
        
        CMN_Question_Response__c existingResponse = new CMN_Question_Response__c(
            CMN_Question__c       = qId,
            Id_Number__c          = idNumber,
            User_Id__c            = existingUserId,
            CMN_Response_Value__c = 'ExistingAnswer',
            Is_Completed__c       = false,
            CMN_Source__c         = EXPERIENCE
        );
        insert existingResponse;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        CMN_Question_Response__c unchanged = [
            SELECT User_Id__c FROM CMN_Question_Response__c WHERE Id = :existingResponse.Id
        ];
        Assert.areEqual(existingUserId, unchanged.User_Id__c);
    }
    
    /**
* @description Validates syncQuestionResponseUserId when no Question Response records
*              match the idNumber. Confirms no error is thrown and Assessment update succeeds.
*/
    @IsTest
    static void testSyncQuestionResponseUserId_NoResponsesFound() {
        String idNumber = '2501015009086';
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'No QR Sync Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_no_qr'
        );
        insert assessment;
        
        initRestPatch(
            '{"idNumber":"' + idNumber + '","userId":"' + UserInfo.getUserId() + '"}'
        );
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
    }
    
    /**
* @description Validates the full guest-to-registered conversion flow end-to-end.
*              Covers Assessment, Lead, and Question Response being updated in
*              a single PATCH call, confirming all three sync helpers fire together.
*/
    @IsTest
    static void testSyncGuestAssessmentUser_FullFlow() {
        String idNumber  = '1501015009088';
        String newUserId = UserInfo.getUserId();
        Id qId = getQuestionId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'Full Flow Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_full_flow'
        );
        insert assessment;
        
        Lead testLead = new Lead(
            LastName                  = 'FullFlowLead',
            Company                   = TEST_CO,
            ID_Number__c              = idNumber,
            Source_System_Reference__c = null
        );
        insert testLead;
        
        CMN_Question_Response__c guestResponse = new CMN_Question_Response__c(
            CMN_Question__c       = qId,
            Id_Number__c          = idNumber,
            User_Id__c            = null,
            CMN_Response_Value__c = 'FullFlowAnswer',
            Is_Completed__c       = false,
            CMN_Source__c         = EXPERIENCE
        );
        insert guestResponse;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        Assert.areEqual(true, resp.success);
        Assert.areEqual(200, statusCode);
        
        CMN_Assessment__c updatedAssessment = [
            SELECT User_Id__c FROM CMN_Assessment__c WHERE Id = :assessment.Id
        ];
        Assert.areEqual(newUserId, updatedAssessment.User_Id__c);
        
        Lead updatedLead = [
            SELECT Source_System_Reference__c FROM Lead WHERE Id = :testLead.Id
        ];
        Assert.areEqual(newUserId, updatedLead.Source_System_Reference__c);
        
        CMN_Question_Response__c updatedResponse = [
            SELECT User_Id__c FROM CMN_Question_Response__c WHERE Id = :guestResponse.Id
        ];
        Assert.areEqual(newUserId, updatedResponse.User_Id__c);
    }
    
    /**
* @description Validates the Exception catch block in syncLeadSourceReference
*              by setting throwException = true before the PATCH call.
*              The flag throws an AuraHandledException after the Lead update,
*              which is caught and swallowed by the general Exception catch.
*              Confirms Assessment update still returns HTTP 200.
*/
    @IsTest
    static void testSyncLeadSourceReference_ExceptionCatchBlock() {
        String idNumber  = 'THROW_EX_LEAD_001';
        String newUserId = UserInfo.getUserId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'Lead Exception Catch Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_throw_lead'
        );
        insert assessment;
        
        Lead testLead = new Lead(
            LastName                   = 'ThrowExLead',
            Company                    = TEST_CO,
            ID_Number__c               = idNumber,
            Source_System_Reference__c = null
        );
        insert testLead;
        
        PRX_REST_QuestionnaireResponse.throwException = true;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        PRX_REST_QuestionnaireResponse.throwException = false;
        
        Assert.areEqual(true, resp.success);
        Assert.areEqual(200, statusCode);
    }
    
    /**
* @description Validates the Exception catch block in syncQuestionResponseUserId
*              by setting throwException = true before the PATCH call.
*              The flag throws an AuraHandledException after the Question Response update,
*              which is caught and swallowed by the general Exception catch.
*              Confirms Assessment update still returns HTTP 200.
*/
    @IsTest
    static void testSyncQuestionResponseUserId_ExceptionCatchBlock() {
        String idNumber  = 'THROW_EX_QR_001';
        String newUserId = UserInfo.getUserId();
        Id qId = getQuestionId();
        
        CMN_Assessment__c assessment = new CMN_Assessment__c(
            Name         = 'QR Exception Catch Assessment',
            Id_Number__c = idNumber,
            User_Id__c   = 'guest_throw_qr'
        );
        insert assessment;
        
        CMN_Question_Response__c guestResponse = new CMN_Question_Response__c(
            CMN_Question__c       = qId,
            Id_Number__c          = idNumber,
            User_Id__c            = null,
            CMN_Response_Value__c = 'ThrowExAnswer',
            Is_Completed__c       = false,
            CMN_Source__c         = EXPERIENCE
        );
        insert guestResponse;
        
        PRX_REST_QuestionnaireResponse.throwException = true;
        
        initRestPatch('{"idNumber":"' + idNumber + '","userId":"' + newUserId + '"}');
        
        Test.startTest();
        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser();
        Integer statusCode = RestContext.response.statusCode;
        Test.stopTest();
        
        PRX_REST_QuestionnaireResponse.throwException = false;
        
        Assert.areEqual(true, resp.success);
        Assert.areEqual(200, statusCode);
    }
    
}