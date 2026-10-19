/***************************************************************************************
@ Author            : Taimoor.shaik@standardbank.co.za
@ Date              : Jan-2026
@ Name of the Class : PRX_REST_QuestionnaireResponse
@ Description       : REST API endpoint in Universal Org to receive questionnaire
                      responses from Mall Org. Deserialises inbound payload,
                      maps question orders to Record IDs, persists
                      CMN_Question_Response__c records, and triggers
                      FHQ calculations on completion.
@ Last Modified By  : Taimoor.shaik@standardbank.co.za
@ Last Modified On  : 24-03-2026
@ Modification Description :
1.0   Jan-2026   Taimoor.shaik@standardbank.co.za   Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270)
2.0   Mar-2026   Taimoor.shaik@standardbank.co.za   SyncGuestUser Assesment and Lead(PPBSF-341)

***************************************************************************************/
@RestResource(urlMapping='/api/questionnaire/responses/*')
global with sharing class PRX_REST_QuestionnaireResponse {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PRX_REST_QuestionnaireResponse');

    private static final String SOURCE_EXPERIENCE = 'Experience';

    private static Id ruleSetVersionId;
    private static Date dateOfBirth;
    private static Datetime assessmentStartTime;
    private static String submittedBy;
    private static Boolean hasIncompleteResponse = false;
    @TestVisible private static Boolean throwException = false;

    /**
     * @description HTTP POST handler. Receives and persists questionnaire responses from Mall Org.
     *              On full completion triggers FHQ score calculations and returns activity scores.
     * @return PRX_DTO_QuestionnaireResponse.ResponseWrapper containing success status and message
     */
    @HttpPost
    global static PRX_DTO_QuestionnaireResponse.ResponseWrapper saveQuestionnaireResponses() {
        PRX_DTO_QuestionnaireResponse.ResponseWrapper apiResponse =
            new PRX_DTO_QuestionnaireResponse.ResponseWrapper();

        try {
            String requestBody = RestContext.request.requestBody.toString();
            LOGGER.info(
                'PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses: requestBody={0}',
                new List<Object>{ requestBody }
            );

            PRX_DTO_QuestionnaireRequest.RequestWrapper requestData =
                (PRX_DTO_QuestionnaireRequest.RequestWrapper) JSON.deserialize(
                    requestBody,
                    PRX_DTO_QuestionnaireRequest.RequestWrapper.class
                );

            if (!isValidRequest(requestData, apiResponse)) {
                return apiResponse;
            }

            PRX_UTIL_QuestionnaireScoring.initialise();
            parseRequestMetadata(requestData);

            Map<Integer, Id> orderToQuestionIdMap     = buildOrderToQuestionIdMap();
            Map<String, CMN_Question_Response__c> existingResponseMap = New Map<String, CMN_Question_Response__c>();
            if(String.isNotBlank(requestData.userId)){
                existingResponseMap = loadExistingIncompleteResponses(requestData.userId);
            }
            List<CMN_Question_Response__c> responseRecords =
                buildResponseRecords(requestData, orderToQuestionIdMap, existingResponseMap);

            LOGGER.info(
                'PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses: Total records to upsert={0}',
                new List<Object>{ responseRecords.size() }
            );

            if (!responseRecords.isEmpty()) {
                apiResponse = processUpsertResults(responseRecords, apiResponse);
            }

        } catch (JSONException jsonException) {
            apiResponse.success = false;
            apiResponse.message = 'Invalid JSON format: ' + jsonException.getMessage();
            RestContext.response.statusCode = 400;
            LOGGER.error(
                'PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses: JSONException={0}',
                new List<Object>{ jsonException.getMessage() },
                jsonException
            );

        } catch (Exception generalException) {
            apiResponse.success = false;
            apiResponse.message = 'Error saving responses: ' + generalException.getMessage();
            RestContext.response.statusCode = 500;
            LOGGER.fatal(
                'PRX_REST_QuestionnaireResponse.saveQuestionnaireResponses: Unexpected exception={0}',
                new List<Object>{ generalException.getMessage() },
                generalException
            );
        }

        return apiResponse;
    }
    
    
    // ─── Guest to Registered User Assessment Sync ────────────────────────────────

/**
 * @description HTTP PATCH handler. Receives the Mall Org Account ID and new
 *              Salesforce User ID after a guest user converts to a registered user.
 *              Finds the CMN_Assessment__c record where User_Id__c matches the
 *              Account ID and updates it with the real Salesforce User ID.
 * @return PRX_DTO_QuestionnaireResponse.ResponseWrapper containing success status and message
 */ 
    @HttpPatch
global static PRX_DTO_QuestionnaireResponse.ResponseWrapper syncGuestAssessmentUser() {
    PRX_DTO_QuestionnaireResponse.ResponseWrapper apiResponse =
        new PRX_DTO_QuestionnaireResponse.ResponseWrapper();

    try {
        String requestBody = RestContext.request.requestBody.toString();

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: requestBody={0}',
            new List<Object>{ requestBody }
        );

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        String idNumber = (String) payload.get('idNumber');
        String userId   = (String) payload.get('userId');

        if (String.isBlank(idNumber) || String.isBlank(userId)) {
            apiResponse.success = false;
            apiResponse.message = 'idNumber and userId are required';
            RestContext.response.statusCode = 400;
            LOGGER.warn(
                'PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: Missing idNumber or userId'
            );
            return apiResponse;
        }

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: idNumber={0} | userId={1}',
            new List<Object>{ idNumber, userId }
        );

        // Query all Assessment records matching the passport/ID number
        SEL_CMNAssessment assesmentSelector = new SEL_CMNAssessment();
        List<CMN_Assessment__c> assessments = assesmentSelector.selectByIdNumber(idNumber);

        if (assessments.isEmpty()) {
            apiResponse.success = false;
            apiResponse.message = 'No Assessment found for idNumber: ' + idNumber;
            RestContext.response.statusCode = 404;
            LOGGER.warn('PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: No Assessment found for idNumber={0}',new List<Object>{ idNumber }
            );
            return apiResponse;
        }

        // Update User_Id__c on all matching Assessment records
        for (CMN_Assessment__c assessment : assessments) {
            assessment.User_Id__c = userId;
        }
        checkResponseRecordAssesmentPermissions();
        update assessments;
        
        // ── Sync Lead Source System Reference ────────────────────────────
		// Only fires if Assessment update succeeded
			syncLeadSourceReference(idNumber, userId);
		// ─────────────────────────────────────────────────────────────────
		
        // ── Sync Question Response User ID ───────────────────────────────
			syncQuestionResponseUserId(idNumber, userId);
		// ─────────────────────────────────────────────────────────────────

        apiResponse.success = true;
        apiResponse.message = 'Successfully updated ' + assessments.size() + ' Assessment record(s) for idNumber: ' + idNumber;
        RestContext.response.statusCode = 200;

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: Successfully updated {0} assessment(s) with userId={1}',
            new List<Object>{ assessments.size(), userId }
        );

    } catch (DmlException dmlEx) {
        apiResponse.success = false;
        apiResponse.message = 'DML error updating Assessment: ' + dmlEx.getMessage();
        RestContext.response.statusCode = 500;
        LOGGER.error('PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: DmlException={0}',new List<Object>{ dmlEx.getMessage() },dmlEx
        );

    } catch (Exception generalException) {
        apiResponse.success = false;
        apiResponse.message = 'Error syncing guest assessment: ' + generalException.getMessage();
        RestContext.response.statusCode = 500;
        LOGGER.fatal(
            'PRX_REST_QuestionnaireResponse.syncGuestAssessmentUser: Unexpected exception={0}',
            new List<Object>{ generalException.getMessage() },
            generalException
        );
    }

    return apiResponse;
}
    
    /**
 * @description Syncs Lead Source_System_Reference__c with the real Salesforce
 *              User ID after guest-to-registered conversion.
 *              Only updates Lead records where:
 *              - ID_Number__c matches the Assessment Id_Number__c
 *              - Source_System_Reference__c is currently null
 * @param idNumber Passport/ID number to match against Lead.ID_Number__c
 * @param userId   Real Salesforce User ID to set on Source_System_Reference__c
 */

private static void syncLeadSourceReference(String idNumber, String userId) {
    try {
        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncLeadSourceReference: idNumber={0} | userId={1}',
            new List<Object>{ idNumber, userId }
        );

        // Query all Lead records matching idNumber where Source_System_Reference__c is null
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leads = leadSelector.selectByIdNumberWithoutSystemReference(idNumber);

        if (leads.isEmpty()) {
            LOGGER.info(
                'PRX_REST_QuestionnaireResponse.syncLeadSourceReference: No matching Leads found for idNumber={0}',
                new List<Object>{ idNumber }
            );
            return;
        }

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncLeadSourceReference: Found {0} Lead(s) to update for idNumber={1}',
            new List<Object>{ leads.size(), idNumber }
        );

        // Update Source_System_Reference__c on all matching Lead records
        for (Lead lead : leads) {
            lead.Source_System_Reference__c = userId;
        }

        update leads;

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncLeadSourceReference: Successfully updated {0} Lead(s) with userId={1}',
            new List<Object>{ leads.size(), userId }
        );
        if (throwException) { 
                 throw new AuraHandledException('Test exception'); 
             }

    } catch (DmlException dmlEx) {
        // Log and swallow — Lead sync failure must not roll back Assessment update
        LOGGER.error('PRX_REST_QuestionnaireResponse.syncLeadSourceReference: DmlException={0}',new List<Object>{ dmlEx.getMessage() },dmlEx
        );
        
    } catch (Exception ex) {
        // Log and swallow — Lead sync failure must not roll back Assessment update
        LOGGER.error(
            'PRX_REST_QuestionnaireResponse.syncLeadSourceReference: Unexpected exception={0}',
            new List<Object>{ ex.getMessage() },
            ex
        );
    }
}
    /**
 * @description Syncs CMN_Question_Response__c User_Id__c with the real Salesforce
 *              User ID after guest-to-registered conversion.
 *              Only updates Question Response records where:
 *              - Id_Number__c matches the Assessment Id_Number__c
 *              - User_Id__c is currently null
 * @param idNumber Passport/ID number to match against CMN_Question_Response__c.Id_Number__c
 * @param userId   Real Salesforce User ID to set on User_Id__c
 */
private static void syncQuestionResponseUserId(String idNumber, String userId) {
    try {
        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncQuestionResponseUserId: idNumber={0} | userId={1}',
            new List<Object>{ idNumber, userId }
        );

        // Query all Question Response records matching idNumber where User_Id__c is null
        SEL_CMNQuestionResponse questionResponseSelector = new SEL_CMNQuestionResponse();
        List<CMN_Question_Response__c> responses = questionResponseSelector.selectByIdNumberwithNouserId(idNumber);

        if (responses.isEmpty()) {
            LOGGER.info(
                'PRX_REST_QuestionnaireResponse.syncQuestionResponseUserId: No matching Question Responses found for idNumber={0}',
                new List<Object>{ idNumber }
            );
            return;
        }

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncQuestionResponseUserId: Found {0} Question Response(s) to update for idNumber={1}',
            new List<Object>{ responses.size(), idNumber }
        );

        // Update User_Id__c on all matching Question Response records
        for (CMN_Question_Response__c response : responses) {
            response.User_Id__c = userId;
        }

        update responses;

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.syncQuestionResponseUserId: Successfully updated {0} Question Response(s) with userId={1}',
            new List<Object>{ responses.size(), userId }
        );
        if (throwException) { 
                 throw new AuraHandledException('Test exception'); 
             }

    } catch (DmlException dmlEx) {
        // Log and swallow — Question Response sync failure must not roll back Assessment update
        LOGGER.error( 'PRX_REST_QuestionnaireResponse.syncQuestionResponseUserId: DmlException={0}',new List<Object>{ dmlEx.getMessage() },dmlEx
        );
    } catch (Exception ex) {
        // Log and swallow — Question Response sync failure must not roll back Assessment update
        LOGGER.error(
            'PRX_REST_QuestionnaireResponse.syncQuestionResponseUserId: Unexpected exception={0}',
            new List<Object>{ ex.getMessage() },
            ex
        );
    }
}
    

    // ─── Request Validation ──────────────────────────────────────────────────────

    /**
     * @description Validates the deserialised request payload for required fields.
     *              Sets HTTP 400 and populates the error message on the response wrapper
     *              when validation fails.
     * @param requestData Deserialised request payload
     * @param apiResponse Response wrapper to populate on validation failure
     * @return True when validation passes; false otherwise
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    private static Boolean isValidRequest(
        PRX_DTO_QuestionnaireRequest.RequestWrapper requestData,
        PRX_DTO_QuestionnaireResponse.ResponseWrapper apiResponse
    ) {
        if (requestData == null
            || requestData.responses == null
            || requestData.responses.isEmpty()) {
            apiResponse.success = false;
            apiResponse.message = 'No responses provided';
            RestContext.response.statusCode = 400;
            LOGGER.warn(
                'PRX_REST_QuestionnaireResponse.isValidRequest: Rejected - no responses in payload'
            );
            return false;
        }

        return true;
    }

    // ─── Metadata Parsing ────────────────────────────────────────────────────────

    /**
     * @description Parses date of birth, assessment start time, and submitter name
     *              from the request payload into class-level state variables.
     * @param requestData Deserialised request payload
     */
    private static void parseRequestMetadata(
        PRX_DTO_QuestionnaireRequest.RequestWrapper requestData
    ) {
        if (String.isNotBlank(requestData.dob)) {
            List<String> dateParts = requestData.dob.split('-');
            dateOfBirth = Date.newInstance(
                Integer.valueOf(dateParts[2]),
                Integer.valueOf(dateParts[1]),
                Integer.valueOf(dateParts[0])
            );
            LOGGER.debug(
                'PRX_REST_QuestionnaireResponses.parseRequestMetadata: dateOfBirth={0}',
                new List<Object>{ dateOfBirth }
            );
        }

        if (String.isNotBlank(requestData.startTime)) {
            try {
                assessmentStartTime = Datetime.valueOfGmt(requestData.startTime);
                LOGGER.debug(
                    'PRX_REST_QuestionnaireResponses.parseRequestMetadata: assessmentStartTime={0}',
                    new List<Object>{ assessmentStartTime }
                );
            } catch (Exception parseException) {
                LOGGER.debug(
                    'PRX_REST_QuestionnaireResponses.parseRequestMetadata: Invalid startTime format={0}',
                    new List<Object>{ parseException.getMessage() }
                );
            }
        }

        if (String.isNotBlank(requestData.name)) {
            submittedBy = requestData.name;
        }

        LOGGER.debug(
            'PRX_REST_QuestionnaireResponses.parseRequestMetadata: submittedBy={0}',
            new List<Object>{ submittedBy }
        );
    }

    // ─── Question Order Map Builder ──────────────────────────────────────────────

    /**
     * @description Queries active CMN_Question__c records and builds a map of
     *              CMN_Order__c (Integer) to Question Record ID.
     *              Also captures the ruleSetVersionId from the first record.
     * @return Map of question order integer to Salesforce Question Record ID
     */
    private static Map<Integer, Id> buildOrderToQuestionIdMap() {
        Map<Integer, Id> orderToQuestionIdMap = new Map<Integer, Id>();

        try {
            SEL_CMNQuestion questionSelector = new SEL_CMNQuestion();
            List<CMN_Question__c> activeQuestions = questionSelector.selectActiveQuestions();

            LOGGER.info(
                'PRX_REST_QuestionnaireResponses.buildOrderToQuestionIdMap: activeQuestions.size={0}',
                new List<Object>{ activeQuestions.size() }
            );

            ruleSetVersionId = activeQuestions[0].CMN_Version_Number__c;

            for (CMN_Question__c question : activeQuestions) {
                if (question.CMN_Order__c != null) {
                    Integer questionOrder = Integer.valueOf(question.CMN_Order__c);
                    orderToQuestionIdMap.put(questionOrder, question.Id);
                }
            }
        } catch (Exception queryException) {
            LOGGER.error(
                'PRX_REST_QuestionnaireResponses.buildOrderToQuestionIdMap: Query failed={0}',
                new List<Object>{ queryException.getMessage() },
                queryException
            );
        }

        return orderToQuestionIdMap;
    }

    // ─── Existing Response Loader ────────────────────────────────────────────────

    /**
     * @description Loads existing incomplete CMN_Question_Response__c records for the
     *              given user so that upsert updates rather than duplicates them.
     * @param userId Salesforce User ID of the respondent
     * @return Map of CMN_Question__c ID string to existing incomplete response record
     */
    private static Map<String, CMN_Question_Response__c> loadExistingIncompleteResponses(
        String userId
    ) {
        Map<String, CMN_Question_Response__c> existingResponseMap =
            new Map<String, CMN_Question_Response__c>();
        SEL_CMNQuestionResponse questionResponseSelector = new SEL_CMNQuestionResponse();

        for (CMN_Question_Response__c existingResponse
                : questionResponseSelector.selectIncompleteResponseofUser(userId)) {
            existingResponseMap.put(existingResponse.CMN_Question__c, existingResponse);
        }

        return existingResponseMap;
    }

    // ─── Response Record Builder ─────────────────────────────────────────────────

    /**
     * @description Iterates the inbound question responses and maps each to a
     *              CMN_Question_Response__c SObject ready for upsert.
     * @param requestData Full deserialised request payload
     * @param orderToQuestionIdMap Map of order integer to Question Record ID
     * @param existingResponseMap Map of Question ID string to existing incomplete response
     * @return List of CMN_Question_Response__c records ready for upsert
     */
    private static List<CMN_Question_Response__c> buildResponseRecords(
        PRX_DTO_QuestionnaireRequest.RequestWrapper requestData,
        Map<Integer, Id> orderToQuestionIdMap,
        Map<String, CMN_Question_Response__c> existingResponseMap
    ) {
        List<CMN_Question_Response__c> responseRecords = new List<CMN_Question_Response__c>();
        Boolean isCompleted = requestData.isCompleted == true;
        hasIncompleteResponse = !isCompleted;

        for (PRX_DTO_QuestionnaireRequest.QuestionResponse questionResponse
                : requestData.responses) {

            LOGGER.debug(
                'PRX_REST_QuestionnaireResponses.buildResponseRecords: order={0}, category={1}, hasConditionalInput={2}',
                new List<Object>{
                    questionResponse.order,
                    questionResponse.category,
                    questionResponse.hasConditionalInput
                }
            );

            if (String.isBlank(questionResponse.value)) {
                continue;
            }

            CMN_Question_Response__c responseRecord = new CMN_Question_Response__c();

            Id questionRecordId = resolveQuestionId(questionResponse, orderToQuestionIdMap);
            responseRecord.CMN_Question__c              = questionRecordId;
            responseRecord.CMN_Response_Value_Number__c = resolveNumericValue(questionResponse, questionRecordId);
            responseRecord.CMN_Question_Text__c         = questionResponse.questionText;
            responseRecord.CMN_Response_Value__c        = questionResponse.value;
            responseRecord.CMN_Response_Display__c      = questionResponse.value;
            responseRecord.Is_Completed__c              = isCompleted;
            responseRecord.CMN_Sequence__c              = questionResponse.order;
            responseRecord.User_Id__c                   = requestData.userId;
            responseRecord.CMN_Source__c                = SOURCE_EXPERIENCE;
            responseRecord.CMN_Response_Timestamp__c    = System.now();
            responseRecord.CMN_Category__c              = questionResponse.category;
            responseRecord.Id_Type__c                   = requestData.idType;
            responseRecord.Id_Number__c                 = requestData.idNumber;
            responseRecord.Ping_Id__c                   = requestData.pingId;
            responseRecord.CMN_Rule_Set_Version__c      = ruleSetVersionId;

            // Carry the existing record ID so Database.upsert performs an update
            String questionKey = String.valueOf(questionRecordId);
            if (String.isNotBlank(questionKey) && existingResponseMap.containsKey(questionKey)) {
                responseRecord.Id = existingResponseMap.get(questionKey).Id;
            }

            responseRecords.add(responseRecord);
        }

        return responseRecords;
    }

    /**
     * @description Resolves the Salesforce Question Record ID from the order map,
     *              falling back to the questionId field in the payload if not found.
     * @param questionResponse Individual question response from the payload
     * @param orderToQuestionIdMap Map of order integer to Question Record ID
     * @return Resolved Question Record ID, or null if neither source provides one
     */
    private static Id resolveQuestionId(
        PRX_DTO_QuestionnaireRequest.QuestionResponse questionResponse,
        Map<Integer, Id> orderToQuestionIdMap
    ) {
        if (questionResponse.order != null
                && orderToQuestionIdMap.containsKey(questionResponse.order)) {
            Id resolvedId = orderToQuestionIdMap.get(questionResponse.order);
            LOGGER.debug(
                'PRX_REST_QuestionnaireResponses.resolveQuestionId: Resolved by order={0}, id={1}',
                new List<Object>{ questionResponse.order, resolvedId }
            );
            return resolvedId;
        }

        if (String.isNotBlank(questionResponse.questionId)) {
            LOGGER.debug(
                'PRX_REST_QuestionnaireResponses.resolveQuestionId: Fallback to payload questionId={0}',
                new List<Object>{ questionResponse.questionId }
            );
            return questionResponse.questionId;
        }

        return null;
    }

    /**
     * @description Determines the numeric value for CMN_Response_Value_Number__c.
     *              Priority order: conditional input value > currency conversion > scoring lookup.
     * @param questionResponse Individual question response from the payload
     * @param questionRecordId Resolved Question Record ID
     * @return Resolved Decimal value, or null if no rule applies
     */
    private static Decimal resolveNumericValue(
        PRX_DTO_QuestionnaireRequest.QuestionResponse questionResponse,
        Id questionRecordId
    ) {
        if (questionResponse.hasConditionalInput == true) {
            Decimal conditionalResult =
                questionResponse.conditionalValue == null ? 0 : questionResponse.conditionalValue;
            LOGGER.debug(
                'PRX_REST_QuestionnaireResponses.resolveNumericValue: Conditional value={0}',
                new List<Object>{ conditionalResult }
            );
            return conditionalResult;
        }

        if (questionResponse.type == 'Currency'
                && String.isNotBlank(questionResponse.value)) {
            try {
                Decimal currencyResult = Decimal.valueOf(questionResponse.value);
                LOGGER.debug(
                    'PRX_REST_QuestionnaireResponses.resolveNumericValue: Currency value={0}',
                    new List<Object>{ currencyResult }
                );
                return currencyResult;
            } catch (Exception conversionException) {
                LOGGER.error(
                    'PRX_REST_QuestionnaireResponses.resolveNumericValue: Currency conversion failed={0}',
                    new List<Object>{ conversionException.getMessage() },
                    conversionException
                );
            }
        }

        String questionName =
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(questionRecordId);
        if (String.isNotBlank(questionName) && String.isNotBlank(questionResponse.value)) {
            Decimal scoreResult =
                PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(questionName, questionResponse.value);
            if (scoreResult != null) {
                LOGGER.debug('PRX_REST_QuestionnaireResponses.resolveNumericValue: Score={0} for questionName={1}',new List<Object>{ scoreResult, questionName }
                );
                return scoreResult;
            }
        }

        return null;
    }

    // ─── Upsert Processing ───────────────────────────────────────────────────────

    /**
     * @description Upserts response records, evaluates results, and on full success
     *              triggers FHQ calculations then populates activity scores on the response.
     * @param responseRecords List of records to upsert
     * @param apiResponse Current response wrapper to populate
     * @return Updated ResponseWrapper
     */
    private static PRX_DTO_QuestionnaireResponse.ResponseWrapper processUpsertResults(
        List<CMN_Question_Response__c> responseRecords,
        PRX_DTO_QuestionnaireResponse.ResponseWrapper apiResponse
    ) {
        checkResponseRecordPermissions();
        Database.UpsertResult[] upsertResults = Database.upsert(responseRecords, true);

        List<String> errorMessages = new List<String>();
        Integer successCount = 0;

        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (upsertResults[i].isSuccess()) {
                successCount++;
            } else {
                for (Database.Error upsertError : upsertResults[i].getErrors()) {
                    String errorDetail = 'Record ' + i + ': ' + upsertError.getMessage() + ' (Fields: ' + upsertError.getFields() + ')';
                    errorMessages.add(errorDetail);
                    LOGGER.error('PRX_REST_QuestionnaireResponse.processUpsertResults: DML error={0}', new List<Object>{ errorDetail });
                }
            }
        }

        if (!errorMessages.isEmpty()) {
            apiResponse.success = false;
            apiResponse.message = 'Partial success: ' + successCount + ' of '
                + responseRecords.size() + ' records saved. Errors: '
                + String.join(errorMessages, '; ');
            apiResponse.recordsSaved = successCount;
            RestContext.response.statusCode = 207;
            return apiResponse;
        }

        if (!hasIncompleteResponse) {
            CMN_FHQ_Calculation.performCalculations(
                responseRecords, dateOfBirth, assessmentStartTime, submittedBy
            );
        }

        apiResponse = populateActivityScores(apiResponse);
        apiResponse.success = true;
        apiResponse.message = 'Successfully saved ' + successCount + ' responses';
        apiResponse.recordsSaved = successCount;
        RestContext.response.statusCode = 201;

        return apiResponse;
    }

    /**
     * @description Reads the CMN_Assessment__c record produced by FHQ calculations
     *              and populates ActivityDTO entries on the response wrapper.
     * @param apiResponse Current response wrapper to populate with activities
     * @return Updated ResponseWrapper with activity list
     */
    private static PRX_DTO_QuestionnaireResponse.ResponseWrapper populateActivityScores(
        PRX_DTO_QuestionnaireResponse.ResponseWrapper apiResponse
    ) {
        CMN_Assessment__c calculatedAssessment = CMN_FHQ_Calculation.createdAssessment;

        if (calculatedAssessment == null) {
            return apiResponse;
        }

        SEL_CMNAssessment assessmentSelector = new SEL_CMNAssessment();
        CMN_Assessment__c assessmentRecord =
            assessmentSelector.selectById(calculatedAssessment.Id);

        LOGGER.info(
            'PRX_REST_QuestionnaireResponse.populateActivityScores: assessmentId={0}',
            new List<Object>{ assessmentRecord?.Id }
        );

        apiResponse.activities = new List<PRX_DTO_QuestionnaireResponse.ActivityDTO>();
        apiResponse.activities.add(new PRX_DTO_QuestionnaireResponse.ActivityDTO('General'));

        if (assessmentRecord.CMN_Expenses_Score__c != null) {
            apiResponse.activities.add(new PRX_DTO_QuestionnaireResponse.ActivityDTO('Expenses', assessmentRecord.CMN_Expenses_Score__c));
        }
        if (assessmentRecord.CMN_Debt_to_Income_Score__c != null) {
            apiResponse.activities.add(new PRX_DTO_QuestionnaireResponse.ActivityDTO('Personal Debt', assessmentRecord.CMN_Debt_to_Income_Score__c));
        }
        if (assessmentRecord.CMN_Insurance_Score__c != null) {
            apiResponse.activities.add(new PRX_DTO_QuestionnaireResponse.ActivityDTO('Insurance', assessmentRecord.CMN_Insurance_Score__c));
        }
        if (assessmentRecord.CMN_Emergency_Fund_Score__c != null) {
            apiResponse.activities.add(new PRX_DTO_QuestionnaireResponse.ActivityDTO('Emergency Fund', assessmentRecord.CMN_Emergency_Fund_Score__c));
        }
        if (assessmentRecord.CMN_Retirement_Readiness_Score__c != null) {
            apiResponse.activities.add(new PRX_DTO_QuestionnaireResponse.ActivityDTO('Retirement Target', assessmentRecord.CMN_Retirement_Readiness_Score__c));
        }

        return apiResponse;
    }

    /**
     * @description Validates that the current user has permissions to create, update,
     *              and read CMN_Question_Response__c records before DML operations.
     */
    private static void checkResponseRecordPermissions() {
        Boolean hasCreateable = Schema.sObjectType.CMN_Question_Response__c.isCreateable();
        Boolean hasUpdateable = Schema.sObjectType.CMN_Question_Response__c.isUpdateable();
        Boolean hasReadable = Schema.sObjectType.CMN_Question_Response__c.isAccessible();

        if (!hasCreateable || !hasUpdateable || !hasReadable) {
            LOGGER.warn('PRX_REST_QuestionnaireResponse.checkResponseRecordPermissions: Insufficient permissions - CreateablePermission={0}, UpdatablePermission={1}, ReadablePermission={2}',new List<Object>{ hasCreateable, hasUpdateable, hasReadable });
        }
    }
    
    /**
     * @description Validates that the current user has permissions to create, update,
     *              and read CMN_Assessment__c  records before DML operations.
     */
    private static void checkResponseRecordAssesmentPermissions() {
        Boolean hasCreateable = Schema.sObjectType.CMN_Assessment__c .isCreateable();
        Boolean hasUpdateable = Schema.sObjectType.CMN_Assessment__c .isUpdateable();
        Boolean hasReadable = Schema.sObjectType.CMN_Assessment__c .isAccessible();

        if (!hasCreateable || !hasUpdateable || !hasReadable) {
            LOGGER.warn('PRX_REST_QuestionnaireResponse.checkResponseRecordPermissions: Insufficient permissions - CreateablePermission={0}, UpdatablePermission={1}, ReadablePermission={2}',new List<Object>{ hasCreateable, hasUpdateable, hasReadable });
        }
    }
}