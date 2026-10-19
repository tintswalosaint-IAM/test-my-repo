/**
 * @description Finscan controller
 * @author Gnitsevich Anton
 * Modified by Ofentse Sacha
 * @date January 2024
 */
public with sharing class ICS_CTRL_Finscan {
    /**
     * @description final logger instance used for logging messages in the ICS_CTRL_Finscan class.
     * created using the sbgplatform.rflib_LoggerUtil factory method.
	*/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS Screening - ICS_CTRL_Finscan');
    /**
     * @description Outcome string for not screened status.
	*/
    private static final String SCREENING_STATUS_NONE = 'Not screened';
    /**
     * @description Outcome string for screening no matches found status.
	*/
    private static final String SCREENING_STATUS_HITSNOTFOUND = 'No matches found';
    /**
     * @description Outcome string for screening matches found status.
	*/
    private static final String SCREENING_STATUS_HITSFOUND = 'Matches found';
    /**
     * @description SBO recordType name string.
	*/
    private static final String SBO_RECORDTYPE = 'ICS_PartyProfile';
    /**
     * @description Outcome string for screening confirmed match approved to continue status.
	*/
    public static final String SCREENING_STATUS_HITSCONFIRMED = 'Match confirmed - Continue with process';
    /**
     * @description Outcome string for screening confirmed match declined status.
	*/
    public static final String SCREENING_STATUS_HITSDECLINED = 'Match confirmed - True match declined';
    /**
     * @description Outcome string for screening match discounted status.
	*/
    private static final String SCREENING_STATUS_HITSDISCOUNTED = 'Matches discounted';
    /**
     * @description Outcome string for screening match api error status.
	*/
    private static final String SCREENING_STATUS_ERROR = 'Error';
    /**
     * @description Outcome string for PEP screening category.
	*/
    private static final String OUTCOME_CATEGORY_PEP = 'PEP';
    /**
     * @description Outcome string for Adverse Media screening category.
	*/
    private static final String OUTCOME_CATEGORY_ADVERSEMEDIA = 'Adverse Media';
    /**
     * @description Outcome string for Sanctions screening category.
	*/
    private static final String OUTCOME_CATEGORY_SANCTIONS = 'Sanctions';
    /**
     * @description Outcome string for Watchlist screening category.
	*/
    private static final String OUTCOME_CATEGORY_WATCHLIST = 'Watch List';
    /**
     * @description Outcome string for Black List screening category.
	*/
    private static final String OUTCOME_CATEGORY_BLACKLIST = 'Black List';
    /**
     * @description Outcome string for Uncategorised screening category.
	*/
    private static final String OUTCOME_CATEGORY_NONE = 'Uncategorised';
    /**
     * @description Outcome string for confirmed match screening status.
	*/
    private static final Set<String> OUTCOME_STATUS_CONFIRMEDHIT = new Set<String>{ 'CONFIRMED MATCH' };
    /**
     * @description Outcome string for safe match screening status.
	*/
    private static final Set<String> OUTCOME_STATUS_SAFE = new Set<String>{ 'SAFE' };
    /**
     * @description Outcome string for Status field to ignore.
	*/
    private static final Set<String> OUTCOME_STATUS_IGNORE = new Set<String>{ 'RESEARCH' };
    /**
     * @description Set of Finscan outcome reasons.
	*/
    private static final Set<String> OUTCOME_REASON_WEAK = new Set<String>{
        'Country of Residence does not match', 'Country of Nationality does not match', 'Photo ID does not match'
    };
    /**
     * @description Checks if the current user has the permission to create a new client in the system.
     * @return Boolean True if the user has the permission, otherwise false.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean hasNewClientPermission() {
        try{
            ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
            return helper.hasNewClientPermission();
           } catch (Exception ex) {
        LOGGER.error('Error checking new client permission: ' + ex.getMessage());
        throw new AuraHandledException('An error occurred while checking new client permission. Please contact your system administrator.');
    	}
    }

    /**
     * @description Checks if the current user has the permission for IOM compliance operations.
     * @return Boolean True if the user has the permission, otherwise false.
     */
    @AuraEnabled(cacheable=true)
    public static Boolean hasIOMCompliancePermission() {
        try{
            ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
            return helper.hasIOMCompliancePermission();
           } catch (Exception ex) {
        LOGGER.error('Error checking IOM compliance: ' + ex.getMessage());
        throw new AuraHandledException('An error occurred while checking new IOM compliance. Please contact your system administrator.');
    	}
    }
    
    /**
     * @description This method returns Screening results
     * @param id ApplicationForm Id or Account Id
     * @return ScreeningInfo result, matches with outcomes
     */
    @AuraEnabled
	public static ScreeningInfo getScreeningInfo(String id) {
        ScreeningInfo result = new ScreeningInfo();
        try {
        Id accountId;
        Id idRecord = (Id) id;
        SEL_PartyProfile verificationSelector = new SEL_PartyProfile();
    
            if ('PartyProfile' == idRecord.getSobjectType().getDescribe().getName()) {
                PartyProfile verification = verificationSelector.selectById(idRecord);
                result.worldcheckStatus = verification.WorldcheckStatus__c;
                accountId = verification.AccountId;
            }else {
            accountId = idRecord;
        	}
    
            List<PartyProfile> verifications = verificationSelector.selectByAccountId(accountId);
            if (verifications.isEmpty()) {
                return null;
            }
            
            PartyProfile verification = verifications[0];
            result.verification = verification;
            final SEL_PartyScreeningSummary screeningSummarySelector = new SEL_PartyScreeningSummary();
            List<PartyScreeningSummary> matches = screeningSummarySelector.selectByPartyProfileIdWithPartyScreeningSteps(verification.Id);
            result.matches = matches;
        } catch (Exception e) {
            final String message = 'GetScreeningInfo exception - [ID: ]'+ id + '[Exception Message: ]' + e.getMessage();
            LOGGER.error(message);
            throw new AuraHandledException('An error occurred while getting Screening Info. Please contact your system administrator.');
        }
        return result;
    }

    /**
     * @description This method inserts an outcome record
     * @param matchId Match Key
     * @param category Selected Category
     * @param status Selected Status
     * @param reason Selected Reason
     * @param subreason Selected Reason
     * @param comments Comments
     * @return Result result
     */
    @AuraEnabled
    public static Result saveOutcome(String matchId, String category, String status, String reason, String subreason, String comments) {
        Result result = new Result();
        try {
            ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
            final SEL_PartyScreeningSummary partyScreeningSummarySelector = new SEL_PartyScreeningSummary();
            PartyScreeningSummary match = partyScreeningSummarySelector.selectById(matchId);
            final SEL_PartyProfile verificationSelector = new SEL_PartyProfile();
            PartyProfile verification = verificationSelector.selectById(match.PartyProfileId);
            final SEL_ApplicationForm applicationFormSelector = new SEL_ApplicationForm();
        	ApplicationForm application = applicationFormSelector.selectById(verification.AccountId, false);
            
            if (verification.isClientOnboarded__c || verification.isClientCancelled__c) {
                result.isSuccess = false;
                result.message = 'This Screening is locked as related Client is not in Onboarding.';
                return result;
            }
    
            PartyScreeningStep outcome = helper.createOutcome(match, category, status, reason, subreason, comments, OUTCOME_REASON_WEAK, OUTCOME_STATUS_CONFIRMEDHIT);
           
    		Boolean isUnique = checkExistingOutcome(result, match, category, status, reason);
            if (!isUnique) {
                return result;
            }
            
            ICS_DTO_FinscanResponse.PairsUpdate results;
            
            if(OUTCOME_STATUS_CONFIRMEDHIT.contains(outcome.Status)||outcome.Reason__c.contains('True match-Declined')){
               results = ICS_API_Finscan.doPairsUpdate(verification.AccountId, Decimal.valueOf(match.ScreeningMatchKey__c), outcome);
            }

            if (OUTCOME_STATUS_CONFIRMEDHIT.contains(outcome.Status)) {
               helper.handleConfirmedHit(outcome, verification, application, match, result, results, status);
           	}
            
            
            CMN_UTIL_FLS.updateRecordWithFLSCheck(match); 
            List<SObject> partyScreeningStepList = new List<SObject>{ outcome };
            SObjectAccessDecision outcomeListDecision = Security.stripInaccessible(AccessType.CREATABLE, partyScreeningStepList);
            insert outcomeListDecision.getRecords();
                
            if (outcome.Reason__c.contains('True match-Declined')) {
                helper.handleTrueMatchDeclined(outcome, verification, application, match, result, results, status);
            }
            
            final SEL_PartyScreeningStep partyScreeningStepSel = new SEL_PartyScreeningStep();
            PartyScreeningStep outcomestep = partyScreeningStepSel.selectById(outcomeListDecision.getRecords()[0].Id);
            
            result.isSuccess = true;
            result.outcome = outcomestep;    
    
        } catch (Exception ex) {
            String message = 
                'Save Outcome exception - [Screening Match Result ID: ]'+ matchId + '[Exception Message: ]' + ex.getMessage();
            LOGGER.error(message);
            result.isSuccess = false;
            result.message = 'Save Outcome exception. Please contact your System Administrator.';
            throw new AuraHandledException(result.message);
        }
        return result;
    }
    
    /**
     * @description check existing outcome helper method
     * @param match Party Screening Summary
     * @param String Category
     * @param String Status
     * @param String Reason
     */
    public static Boolean checkExistingOutcome(Result result, PartyScreeningSummary match, String category, String status, String reason){
        final SEL_PartyScreeningStep partyScreeningStepSelector = new SEL_PartyScreeningStep();
        List <PartyScreeningStep> existingOutcomes = partyScreeningStepSelector.selectByIdorSummaryId(match.Id, false);  
        for (PartyScreeningStep existingOutcome : existingOutcomes) {
            Boolean isDuplicate =
                existingOutcome.ScreeningMatchCategory__c == category &&
                existingOutcome.Status == status &&
                existingOutcome.Reason__c == reason;
            if (isDuplicate) {
                result.isSuccess = false;
                result.message = 'This Outcome duplicates an existing Outcome in it\'s category.';
                return false;
            }
        }
        return true;
    }
    
    /**
     * @description This method confirms previously created outcome
     * @param outcomeId Outcome Id
     * @return Result result
     */
    @AuraEnabled
    public static Result confirmOutcome(Id outcomeId) {
        Result result = new Result();
        try {
            final SEL_PartyScreeningStep partyScreeningStepSel = new SEL_PartyScreeningStep();
            PartyScreeningStep outcome = partyScreeningStepSel.selectById(outcomeId);
            
        if (OUTCOME_STATUS_IGNORE.contains(outcome.Status) || outcome.OutcomeConfirmationDate__c != null || outcome.OutcomeChallengeDate__c != null) {
            result.isSuccess = false;
            result.message = 'This status cannot be confirmed as it\'s either an internal status or it has already been confirmed/challenged.';
            return result;
        }
    
            final SEL_PartyScreeningSummary partyScreeningSummarySelector = new SEL_PartyScreeningSummary();
            PartyScreeningSummary match = partyScreeningSummarySelector.selectById(outcome.ScreeningSummaryId);
            final SEL_PartyProfile verificationSelector = new SEL_PartyProfile();
            PartyProfile verification = verificationSelector.selectById(match.PartyProfileId);
            
        if (verification.isClientOnboarded__c || verification.isClientCancelled__c) {
            result.isSuccess = false;
            result.message = 'This Screening is locked as related Client has completed Onboarding.';
            return result;
        }
    
        ICS_DTO_FinscanResponse.PairsUpdate results = ICS_API_Finscan.doPairsUpdate(verification.AccountId, Decimal.valueOf(match.ScreeningMatchKey__c), outcome);
        if (results == null) {
            result.isSuccess = false;
            result.message = 'Finscan Pairs Update request was unsuccessful. Please contact your System Administrator.';
            return result;
        }
    
            outcome.OutcomeConfirmationDate__c = Datetime.now();
            CMN_UTIL_FLS.updateRecordWithFLSCheck(outcome);
    
            final SEL_PartyScreeningStep partyScreeningStepSelect = new SEL_PartyScreeningStep();
            outcome = partyScreeningStepSelect.selectById(outcome.Id);
            result.isSuccess = true;
            result.outcome = outcome;
            
            updateScreeningSummaryStatus(outcome, result);
            updateState(verification.Id);
        } catch (Exception ex) {
            String message =  'Confirm Outcome exception - [Outcome ID: ]'+ outcomeId + '[Exception Message:]'+ ex.getMessage();
            LOGGER.error(message);
            result.isSuccess = false;
            result.message = 'Confirm Outcome exception. Please contact your System Administrator.';
            throw new AuraHandledException('Confirm Outcome exception. Please contact your System Administrator.');
        }
        return result;
    }
  
    /**
     * @description Updates the screening summary status based on existing outcomes.
     * If there are two weak confirmed outcomes or a non-weak confirmed outcome, 
     * it sets the summary as reviewed and disables safe actions.
     * @param outcome The PartyScreeningStep outcome to be evaluated.
     * @param result The Result object to store the status and other information.
     */
    private static void updateScreeningSummaryStatus(PartyScreeningStep outcome, Result result) {
        List<PartyScreeningStep> existingOutcomes = new SEL_PartyScreeningStep().selectByIdorSummaryId(outcome.ScreeningSummaryId, false);
        
        Integer weakTrueCount = 0;
        Boolean hasWeakFalseWithDate = false;
            for (PartyScreeningStep step : existingOutcomes) {
                if (step.isWeakStatus__c == true && step.OutcomeConfirmationDate__c != null) {
                    weakTrueCount++;
                } else if (step.isWeakStatus__c == false && step.OutcomeConfirmationDate__c != null) {
                    hasWeakFalseWithDate = true;
                }
            }
        
        PartyScreeningSummary summary = new SEL_PartyScreeningSummary().selectById(outcome.ScreeningSummaryId);
            if (weakTrueCount == 2 || hasWeakFalseWithDate) {
            	summary.isReviewed__c = true;
                result.safeDisable = true;
            }
        CMN_UTIL_FLS.updateRecordWithFLSCheck(summary);
    }

    /**
     * @description This method challenges/cancels previously created outcome
     * @param outcomeId Outcome Id
     * @return Result result
     */
    @AuraEnabled
    public static Result challengeOutcome(Id outcomeId) {
        Result result = new Result();
        try {
            final SEL_PartyScreeningStep partyScreeningStepSel = new SEL_PartyScreeningStep();
            PartyScreeningStep outcome = partyScreeningStepSel.selectById(outcomeId);
    
        if (OUTCOME_STATUS_IGNORE.contains(outcome.Status) || outcome.OutcomeConfirmationDate__c != null || outcome.OutcomeChallengeDate__c != null) {
            result.isSuccess = false;
            result.message = 'This status cannot be challenged as it\'s either an internal status or it has already been confirmed/challenged.';
            return result;
        }
    
            SEL_PartyScreeningSummary partyScreeningSummarySelector = new SEL_PartyScreeningSummary();
            final PartyScreeningSummary match = partyScreeningSummarySelector.selectById(outcome.ScreeningSummaryId);
            final SEL_PartyProfile verificationSelector = new SEL_PartyProfile();
            PartyProfile verification = verificationSelector.selectById(match.PartyProfileId);
    
        if (verification.isClientOnboarded__c || verification.isClientCancelled__c) {
            result.isSuccess = false;
            result.message = 'This Screening is locked as related Client has completed Onboarding.';
            return result;
        }
    
            outcome.OutcomeChallengeDate__c = Datetime.now();
            CMN_UTIL_FLS.updateRecordWithFLSCheck(outcome);
            updateState(verification.Id);
            final SEL_PartyScreeningStep partyScreeningStepSelect = new SEL_PartyScreeningStep();
            outcome = partyScreeningStepSelect.selectById(outcome.Id);
            result.isSuccess = true;
            result.outcome = outcome;
    
        } catch (Exception ex) {
            final String message =
                'Challenge Outcome exception - [Outcome ID: ]'+ outcomeId + '[Exception Message:]'+ ex.getMessage();
            LOGGER.error(message);
            result.isSuccess = false;
            result.message = 'Challenge Outcome exception. Please contact your System Administrator.';
            throw new AuraHandledException('Challenge Outcome exception. Please contact your System Administrator.');
        }
        return result;
    }
  
     /**
     * @description This method calculates and updates all related matches' review state, application's and account's worldcheck status
     * @param verificationId Verification Id
     */
    @TestVisible
     private static void updateState(Id verificationId) {
        SEL_PartyScreeningSummary partyScreeningSummarySelector = new SEL_PartyScreeningSummary();
        List<PartyScreeningSummary> matches = partyScreeningSummarySelector.selectByPartyProfileIdWithPartyScreeningSteps(verificationId);
        List<PartyScreeningSummary> matchesToUpdate = new List<PartyScreeningSummary>();
        Boolean areAllReviewed = true;
        ScreeningFlags flags = new ScreeningFlags();
         
        for (PartyScreeningSummary match : matches) {
            if (match.IsReviewed__c == true) {
                continue;
            }
            List<PartyScreeningStep> outcomes = match.PartyScreeningSteps;

            processCategory(match.IsPEP__c, OUTCOME_CATEGORY_PEP, outcomes, flags);
            processCategory(match.IsAdverseMedia__c, OUTCOME_CATEGORY_ADVERSEMEDIA, outcomes, flags);
            processCategory(match.IsSanctioned__c, OUTCOME_CATEGORY_SANCTIONS, outcomes, flags);
            processCategory(match.IsWatchlist__c, OUTCOME_CATEGORY_WATCHLIST, outcomes, flags);
            processCategory(match.IsBlacklist__c, OUTCOME_CATEGORY_BLACKLIST, outcomes, flags);
            processCategory(match.IsUncategorised__c, OUTCOME_CATEGORY_NONE, outcomes, flags);
            if (flags.isReviewed == true) {
                match.IsReviewed__c = true;
                matchesToUpdate.add(match);
            }
            else {
                areAllReviewed = false;
            }
        }
        if (!matchesToUpdate.isEmpty()) {
        	CMN_UTIL_FLS.updateRecordsWithFLSCheck(matchesToUpdate);
        }
         
        SEL_PartyProfile applicantSelector = new SEL_PartyProfile();
        PartyProfile applicant = applicantSelector.selectById(verificationId);
        SEL_ApplicationForm selApplicationForm = new SEL_ApplicationForm();
        selApplicationForm.selectById(applicant.AccountId, false);
        updateStatus(areAllReviewed, flags.confirmedHitPresent, applicant);
    }
    
    /**
     * @description Processes the given outcome category if the condition is met and updates the status flags.
     * @param fieldCondition The boolean fields that needs to be true to process the category.
     * @param outcomeCategory The category to be checked.
     * @param isReviewed boolean for reviewed matches
     * @param outcomes outcomes list
     * @param confirmedHitPresent boolean for hits confirmed
     */
    private static void processCategory(Boolean fieldCondition, String outcomeCategory, List<PartyScreeningStep> outcomes, ScreeningFlags flags) {
        if (fieldCondition) {
            String categoryStatus = checkCategoryStatus(outcomes, outcomeCategory);
            if (categoryStatus == 'confirmedhit') {
                flags.confirmedHitPresent = true;
                flags.isReviewed = true;
            } else if (categoryStatus == 'pendingreview') {
                flags.isReviewed = false;
            }
        }
    }
    
    /**
     * @description Updates the WorldcheckStatus of the applicant based on the review status and confirmed hit presence.
     * @param areAllReviewed Indicates if all items have been reviewed.
     * @param confirmedHitPresent Indicates if a confirmed hit is present.
     * @param applicant The applicant record to be updated.
     */
    private static void updateStatus(Boolean areAllReviewed, Boolean confirmedHitPresent, PartyProfile applicant) {
		ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();        
        if (areAllReviewed) {
            String newScreeningStatus = '';
            if (confirmedHitPresent) {
                newScreeningStatus = SCREENING_STATUS_HITSCONFIRMED;
            } else if (!confirmedHitPresent) {
                newScreeningStatus = helper.ContinueCheck(applicant, SCREENING_STATUS_HITSCONFIRMED, SCREENING_STATUS_HITSDISCOUNTED);
            }
            if (String.isNotBlank(newScreeningStatus)) {
                applicant.WorldcheckStatus__c = newScreeningStatus;
                CMN_UTIL_FLS.updateRecordWithFLSCheck(applicant);
            }
        } else if (applicant.WorldcheckStatus__c != SCREENING_STATUS_HITSFOUND) {
            applicant.WorldcheckStatus__c = SCREENING_STATUS_HITSFOUND;
            CMN_UTIL_FLS.updateRecordWithFLSCheck(applicant);
        }
    }

    /**
     * @description This method calculates category' review state
     * @param outcomes outcomes list
     * @param category category name
     * @return String category status
     */
   @TestVisible
   private static String checkCategoryStatus(List<PartyScreeningStep> outcomes, String category) {
        Boolean isReviewed = false;
        Boolean confirmedHitPresent = false;
        Boolean weakSafePresent = false;
        for (PartyScreeningStep outcome : outcomes) {
            if (outcome.ScreeningMatchCategory__c != category || outcome.OutcomeConfirmationDate__c == null) {
                continue;
            }
            if (OUTCOME_STATUS_CONFIRMEDHIT.contains(outcome.Status)) {
                confirmedHitPresent = true;
                isReviewed = true;
                break;
            }
            evaluateSafeOutcome(outcome, isReviewed, weakSafePresent);
        }
        if (confirmedHitPresent == true) { 
            return 'confirmedhit'; 
        }
        else if (isReviewed == true) { 
            return 'reviewed'; 
        }
        return 'pendingreview'; 
    }
    
    /**
     * @description Evaluates the safe outcome status of a given outcome and updates the review state and weak safe presence.
     * @param outcome The PartyScreeningStep outcome to evaluate.
     * @param isReviewed The  review state.
     * @param weakSafePresent The current weak safe presence state to be updated.
     */
    private static void evaluateSafeOutcome(PartyScreeningStep outcome, Boolean isReviewed, Boolean weakSafePresent) {
        if (OUTCOME_STATUS_SAFE.contains(outcome.Status)) {
        if (!outcome.isWeakStatus__c || weakSafePresent) {
            If(!isReviewed){
            	isReviewed = true;
            }
        } else if (outcome.isWeakStatus__c) {
            weakSafePresent = true;
        }
    }
    }
    
    /**
     * @description This method invokes a screening callout, saves data, and updates the screening status for the application, account, and party profile.
     * @param applicationId The ID of the application to be screened.
     */
    public static void screenApplication(String applicationId) {
        ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
        Account account = null;
        try {
            final SEL_ApplicationForm applicationFormSelector = new SEL_ApplicationForm();
            ApplicationForm application = applicationFormSelector.selectById(applicationId, true);
            final SEL_Account accountSelector = new SEL_Account();
            account = accountSelector.selectById(application.AccountId);
            final SEL_PartyProfile partProfileSelector = new SEL_PartyProfile();
            List<PartyProfile> partProfileSelectorList = partProfileSelector.selectByAccountId(account.Id);
 			PartyProfile applicant;
     		for(PartyProfile partyProfile:partProfileSelectorList){
                if(Schema.SObjectType.PartyProfile.getRecordTypeInfosById().get(partyProfile.RecordTypeId).getDeveloperName() == 'ICS_PartyProfile'){
                    applicant = partyProfile;
                }
            }

            if (partProfileSelectorList.isEmpty() || applicant.isClientOnboarded__c || applicant.isClientCancelled__c) {
                return;
            }
            ICS_DTO_FinscanResponse.MultiLookup multiLookupResults = ICS_API_Finscan.doLookup(account.Id);
            if (multiLookupResults == null) {
                helper.updateScreeningStatus(applicant, application, SCREENING_STATUS_ERROR);
                return;
            }
            processLookupResults(multiLookupResults, applicant, application);
        } catch (Exception ex) {
            handleException(ex, account, applicationId);
        }
    } 
    /**
     * @description Processes the lookup results and updates the screening matches.
     * @param multiLookupResults The results from the Finscan lookup.
     * @param verifications The list of party profiles.
     * @param applicant The primary party profile.
     * @param account The account associated with the application.
     * @param application The application being screened.
     * @param verification The primary verification.
     */
    private static void processLookupResults(ICS_DTO_FinscanResponse.MultiLookup multiLookupResults, PartyProfile applicant, ApplicationForm application) {
        ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
        Integer responseStatusCode = multiLookupResults.responseStatusCode;
        ICS_DTO_FinscanResponse.Lookup results = multiLookupResults.responses[0];
        helper.updateVerificationDetails(applicant, responseStatusCode, results.message);
        SEL_PartyScreeningSummary screeningSummarySelector = new SEL_PartyScreeningSummary();
        List<PartyScreeningSummary> existingScreeningMatches = screeningSummarySelector.selectByPartyProfileIdWithPartyScreeningSteps(applicant.Id);
        Map<Decimal, PartyScreeningSummary> existingScreeningMatchesMap = helper.mapExistingScreeningMatches(existingScreeningMatches);
        List<PartyScreeningSummary> newScreeningMatches = new List<PartyScreeningSummary>();
        List<PartyScreeningSummary> updateScreeningMatches = new List<PartyScreeningSummary>();
        processScreeningResults(results.searchResults[0], existingScreeningMatchesMap, newScreeningMatches, updateScreeningMatches, applicant);
        saveScreeningMatches(updateScreeningMatches, newScreeningMatches, applicant);
        updateStatusBasedOnMatches(newScreeningMatches, applicant, application);
    }    
    /**
     * @description Processes the screening results and updates or creates new screening matches.
     * @param screeningResult The screening result from the Finscan lookup.
     * @param existingScreeningMatchesMap The map of existing screening matches.
     * @param newScreeningMatches The list of new screening matches to be created.
     * @param updateScreeningMatches The list of existing screening matches to be updated.
     * @param verification The primary verification.
     */
    private static void processScreeningResults(ICS_DTO_FinscanResponse.SearchResult screeningResult, Map<Decimal, PartyScreeningSummary> existingScreeningMatchesMap, List<PartyScreeningSummary> newScreeningMatches, List<PartyScreeningSummary> updateScreeningMatches, PartyProfile verification) {
        	ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
            for (ICS_DTO_FinscanResponse.SearchMatch finscanScreeningMatch : screeningResult.searchMatches) {
                if(!finscanScreeningMatch.listName.contains('Watchlist')){
     				if (existingScreeningMatchesMap.containsKey(finscanScreeningMatch.listProfileKey)) {
                    	PartyScreeningSummary sfScreeningMatch = existingScreeningMatchesMap.get(finscanScreeningMatch.listProfileKey);
                    	sfScreeningMatch = helper.updateScreeningMatch(sfScreeningMatch, finscanScreeningMatch);
                    	updateScreeningMatches.add(sfScreeningMatch);
            		} else {
                    	PartyScreeningSummary sfScreeningMatch = new PartyScreeningSummary();
                    	sfScreeningMatch.PartyProfileId = verification.Id;
                        sfScreeningMatch.OwnerId = verification.OwnerId;
                    	sfScreeningMatch.ScreeningMatchKey__c = String.valueOf(finscanScreeningMatch.listProfileKey);
                    	sfScreeningMatch = helper.updateScreeningMatch(sfScreeningMatch, finscanScreeningMatch);
                    	newScreeningMatches.add(sfScreeningMatch);
            		}
                }
        }
    }
    /**
     * @description Saves the screening matches to the database.
     * @param updateScreeningMatches The list of existing screening matches to be updated.
     * @param newScreeningMatches The list of new screening matches to be created.
     * @param verification The party profile.
     */
    @TestVisible
    private static void saveScreeningMatches(List<PartyScreeningSummary> updateScreeningMatches, List<PartyScreeningSummary> newScreeningMatches, PartyProfile verification) {
        if (!updateScreeningMatches.isEmpty()) {
            CMN_UTIL_FLS.updateRecordsWithFLSCheck(updateScreeningMatches);
            	
        }
    
        if (!newScreeningMatches.isEmpty()) {
            CMN_UTIL_FLS.insertRecordsWithFLSCheck(newScreeningMatches);
            
        }

    }

    /**
     * @description Updates the status based on the new screening matches.
     * @param newScreeningMatches The list of new screening matches.
     * @param applicant The primary party profile.
     * @param account The account associated with the application.
     * @param application The application being screened.
     */
    private static void updateStatusBasedOnMatches(List<PartyScreeningSummary> newScreeningMatches, PartyProfile applicant, ApplicationForm application) {
        ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
    
        if (!newScreeningMatches.isEmpty() && applicant.WorldcheckStatus__c != SCREENING_STATUS_HITSCONFIRMED) {
            helper.updateScreeningStatus(applicant, application, SCREENING_STATUS_HITSFOUND);
            return;
        }
    
        if (String.isBlank(applicant.WorldcheckStatus__c) || applicant.WorldcheckStatus__c == SCREENING_STATUS_NONE) {
            helper.updateScreeningStatus(applicant, application, SCREENING_STATUS_HITSNOTFOUND);
        }
    }

    /**
     * @description Handles exceptions that occur during the screening process.
     * @param ex The exception that occurred.
     * @param account The account associated with the application.
     * @param applicationId The ID of the application being screened.
     */
    private static void handleException(Exception ex, Account account, String applicationId) {
        String accountIdString;
        if (account == null) {
            accountIdString = 'N/A';
        } else {
            accountIdString = account.Id;
        }
    
        final String message = 'Screen Application exception - [Account ID:] ' + accountIdString + ' [Exception Message:] ' + ex.getMessage();
        ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
        LOGGER.error(message);
        final SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        PartyProfile applicant = partyProfileSelector.selectByAccountAndRecordType(account.Id, SBO_RECORDTYPE);
        final SEL_ApplicationForm applicationFormSelector = new SEL_ApplicationForm();
        ApplicationForm application = applicationFormSelector.selectById(applicationId, true);
        helper.updateScreeningStatus(applicant, application, SCREENING_STATUS_ERROR);
    }
    

    /**
     * @description This method performs Finscan Client Update (onboarded/cancelled) call and updates screening for multiple accounts.
     * @param accountIds List of Account Ids
     * @param decision onboarded/cancelled
     * @return Boolean success/failure flag
     */
    @AuraEnabled
    public static Boolean updateClient(List<String> accountIds, String decision) {
        List<PartyProfile> verificationsToUpdate = new List<PartyProfile>();
    
        try {
            ICS_CTRL_FinscanHelper helper = ICS_CTRL_FinscanHelper.getInstance();
            for (String accountId : accountIds) {
                ICS_DTO_FinscanResponse.ClientUpdate results = ICS_API_Finscan.doClientUpdate(accountId, decision);
    
                if (results != null && results.message == 'Completed') {
                    final SEL_PartyProfile verificationSelector = new SEL_PartyProfile();
                    List<PartyProfile> verifications = verificationSelector.selectByAccountId(accountId);
    
                    if (!verifications.isEmpty()) {
                        PartyProfile verification = verifications[0];
                        verification.ResponseStatusCode__c = results.responseStatusCode;
                        verification.ResponseMessage__c = results.message.left(255);
                        helper.updateClientStatus(verification, decision);
                        verificationsToUpdate.add(verification);
                    }
                }
            }
          
           
            if (!verificationsToUpdate.isEmpty()) {
                CMN_UTIL_FLS.updateRecordsWithFLSCheck(verificationsToUpdate);
            }
            return true;
    
        } catch (Exception ex) {
            String errorDetails = '';
            for (String accountId : accountIds) {
                errorDetails += 'Client Update exception - [Account ID: ' + accountId + '] [Exception Message: ' + ex.getMessage() + ']\n';
            }
    
            LOGGER.error(errorDetails);
    
            throw new AuraHandledException('An error occurred while updating the clients. Details: ' + ex.getMessage());
        }
    }
    
     
    
	/**
     * @description Class screeningFlags used to determine the review status and presence of confirmed hits.
     */
    public class ScreeningFlags {
       /** 
         * @description Indicates whether the screening has been reviewed.
         * @type Boolean
         */
        public Boolean isReviewed;
        /** 
         * @description Indicates whether a confirmed hit is present in the screening.
         * @type Boolean
         */
        public Boolean confirmedHitPresent;
    	/**
         * @description Constructor to initialize the screening flags with default values.
         * Sets isReviewed to false and confirmedHitPresent to false.
         */
        public ScreeningFlags() {
            this.isReviewed = false;
            this.confirmedHitPresent = false;
        }
    }
    
    /**
     * @description Represents the screening information for a party in a Finscan process.
     */
    public class ScreeningInfo {
        /**
         * @description Contains the verification profile for the party being screened.
         */
        @AuraEnabled public PartyProfile verification { get; set; }
        /**
         * @description A list of summary information for any matches found during the party screening.
         */
        @AuraEnabled public List<PartyScreeningSummary> matches { get; set; }
        /**
         * @description The status of the party in relation to World-Check screening.
         */
        @AuraEnabled public String worldcheckStatus { get; set; }
    }
    /**
     * @description Represents the result of a party screening step in a Finscan process.
     */
    public class Result {
        /**
         * @description Indicates whether the screening step was successful.
         */
        @AuraEnabled public Boolean isSuccess { get; set; }
        /**
         * @description Indicates whether to disable outcome or not.
         */
        @AuraEnabled public Boolean safeDisable { get; set; }
        /**
         * @description Provides a message related to the screening step result.
         */
        @AuraEnabled public String message { get; set; }
        /**
         * @description Contains the outcome of the party screening step.
         */
        @AuraEnabled public PartyScreeningStep outcome { get; set; }
    }
}