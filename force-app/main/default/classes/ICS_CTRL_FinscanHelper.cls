/**
 * @description Finscan controller helper class for ICS Screening functionalities.
 * @author Ofentse Sacha
 * @date December 2023
 */
public with sharing class ICS_CTRL_FinscanHelper{
    /**
     * @description Singleton instance.
     */
    private static ICS_CTRL_FinscanHelper instance;
    /**
     * @description maximum length for a long text area field.
	*/
    @TestVisible private static Integer longTextAreaMaxLength = 131072;
    /**
     * @description CustomNotificationType Id.
	*/
    private static final Id NOTIFICATIONTYPEID = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'ICS_Relationship_Manager_Notification'].Id;
    /**
     * @description Private constructor to prevent instantiation.
     */
    @TestVisible
    private ICS_CTRL_FinscanHelper() {}
    /**
     * @description Gets the single instance of ICS_CTRL_FinscanHelper.
     * @return ICS_CTRL_FinscanHelper The single instance of the class.
     */
    
    public static ICS_CTRL_FinscanHelper getInstance() {
        if (instance == null) {
            instance = new ICS_CTRL_FinscanHelper();
        }
        return instance;
    }
    /**
     * @description final logger instance used for logging messages in the ICS_CTRL_FinscanHelper class.
     * created using the sbgplatform.rflib_LoggerUtil factory method.
	*/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS Screening - ICS_CTRL_FinscanHelper'); 
    /**
     * @description Checks if the current user has the permission to create a new client in the system.
     * @return Boolean True if the user has the permission, otherwise false.
     */
    public Boolean hasNewClientPermission() {
        try {
            return FeatureManagement.checkPermission('SBO_ManageScreeningReviews');
        } catch (Exception ex) {
            LOGGER.error('Error checking new client permission: ' + ex.getMessage());
            return false;
        }
    }
    /**
     * @description Checks if the current user has the permission for IOM compliance operations.
     * @return Boolean True if the user has the permission, otherwise false.
     */
    public Boolean hasIOMCompliancePermission() {
        try {
            return FeatureManagement.checkPermission('SBO_IOMCompliance');
        } catch (Exception ex) {
            LOGGER.error('Error checking IOM compliance permission: ' + ex.getMessage());
            return false;
        }
    }
    /**
     * @description Create outcome
     * @param match Party Screening Summary
     * @param category Category
     * @param status Status
     * @param reason Reason
     * @param subreason Sub Reason
     * @param comments Comments
     * @return PartyScreeningStep
     */
    public PartyScreeningStep createOutcome(PartyScreeningSummary match, String category, String status, String reason, String subreason, String comments, Set<String> OUTCOME_REASON_WEAK, Set<String> OUTCOME_STATUS_CONFIRMEDHIT) {
        PartyScreeningStep outcome = new PartyScreeningStep();
        outcome.Name = match.name;
        outcome.ScreeningSummaryId = match.Id;
        outcome.ScreeningMatchCategory__c = category;
        outcome.Status = status;
        outcome.Reason__c = reason;
        outcome.SubReason__c = subreason;
        outcome.Comments__c = comments;
        outcome.Type = 'World Check';
        
        if (OUTCOME_REASON_WEAK.contains(outcome.Reason__c)) {
            outcome.isWeakStatus__c = true;
        }
        if (OUTCOME_STATUS_CONFIRMEDHIT.contains(outcome.Status)) {
            outcome.OutcomeConfirmationDate__c = Datetime.now();
        }
        
        return outcome;
    }
	
    /**
     * @description Closes the declined Opportunity related to the given Account ID.
     * This method is called when the outcome status contains 'True match-declined'.
     * It sets the stage of the related Opportunity to 'Closed Decline' and the reason to 'Declined'.
     * @param accountId The Account ID to find the related Opportunity.
     * @param outcomeReason The reason for the outcome.
     */
    public void closeDeclinedOpportunity(Id accountId, String outcomeReason, ApplicationForm application, PartyProfile verification, PartyScreeningSummary match) {
        try {
            SEL_Opportunity opportunitySelector = new SEL_Opportunity();
            Opportunity opp = opportunitySelector.selectById(application.OpportunityId);
    
            if (opp.StageName != 'Closed Declined') {
                updateOpportunityStageAndReason(opp, outcomeReason, match);
            }
           CMN_UTIL_FLS.updateRecordWithFLSCheck(opp);
        } catch (Exception e) {
            LOGGER.error('Error closing Opportunity: ' + e.getMessage());
        }
    }
    /**
     * @description Updates the stage and decline reason for the given Opportunity.
     * @param opp The Opportunity to update.
     * @param outcomeReason The reason for the outcome.
     */
    private void updateOpportunityStageAndReason(Opportunity opp, String outcomeReason, PartyScreeningSummary match) {
        opp.StageName = 'Closed Declined';
        opp.CloseDate = Date.today();
        opp.ICS_Decline_Reason__c = determineDeclineReason(outcomeReason, match);
    }
    /**
     * @description Determines the decline reason based on the outcome reason.
     * @param outcomeReason The outcome reason.
     * @return String The decline reason.
     */
    @TestVisible
    private String determineDeclineReason(String outcomeReason, PartyScreeningSummary match) {
        switch on outcomeReason {
            when 'Confirmed PEP-True match-Declined' {
                return 'Confirmed PEP';
            }
            when 'Confirmed Adverse Media-True match-Declined' {
                if( match.ScreeningMatchCategory__c=='CRIME - FINANCIAL' || match.FinscanCategoryList__c.contains('FinCrime')){
					return 'Confirmed FinCrime';
                }else{
					return 'Confirmed Adverse Media';
                }
            }
            when 'Confirmed Blacklist-True match-Declined' {
                return 'Confirmed Blacklist';
            }
            when 'Confirmed Sanctions-True match-Declined' {
                return 'Confirmed Sanctions';
            }
            when else {
                return 'IOM Other reasons';
            }
        }
    }
    
    /**
     * @description Update Reviewed and Screening Status on 
     * 		PartyScreeningSummary records and Account record
     * @param partyProfileId The PartyProfileId used to query the PartyScreeningSummary records.
     */
    public void updateReviewed(PartyProfile verification) {
        try {
            final SEL_PartyScreeningSummary screeningSummarySelector = new SEL_PartyScreeningSummary();
            List<PartyScreeningSummary> matchesToUpdate = screeningSummarySelector.selectByPartyProfileIdWithPartyScreeningSteps(verification.Id);

            for (PartyScreeningSummary record : matchesToUpdate) {
                record.IsReviewed__c = true;
            }

            if (!matchesToUpdate.isEmpty()) {
                CMN_UTIL_FLS.updateRecordsWithFLSCheck(matchesToUpdate);
            }
            
        } catch (Exception e) {
            LOGGER.error('An unexpected error on updateReviewed occured: ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if all PartyScreeningSummary records related to a PartyProfile are reviewed.
     * @param verification The PartyProfile used to query the PartyScreeningSummary records.
     * @return boolean True if all records are reviewed, otherwise false.
     */
    public boolean checkReviewed(PartyProfile verification) {
        try {
            final SEL_PartyScreeningSummary screeningSummarySelector = new SEL_PartyScreeningSummary();
            List<PartyScreeningSummary> matchesCheck = screeningSummarySelector.selectByPartyProfileIdWithPartyScreeningSteps(verification.Id);
    
            for (PartyScreeningSummary record : matchesCheck) {
                if (!record.IsReviewed__c) {
                    return false;
                }
            }
            return true;
    
        } catch (Exception e) {
            LOGGER.error('An unexpected error occurred in checkReviewed: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Updates verification details.
     * @param verification The party profile to update.
     * @param responseStatusCode The response status code from the Finscan lookup.
     * @param responseMessage The response message from the Finscan lookup.
     */
    public void updateVerificationDetails(PartyProfile verification, Integer responseCode, String responseMessage) {
        try{
            verification.LastProfileReviewDate = Datetime.now();
            verification.ResponseStatusCode__c = responseCode;
            verification.ResponseMessage__c = responseMessage.left(255);
            verification.isUpdateAvailable__c = false;
            CMN_UTIL_FLS.updateRecordWithFLSCheck(verification);
        }catch(Exception e) {
            LOGGER.error('An unexpected error occurred in updateVerificationDetails: ' + e.getMessage());
        }
    }
    
    /**
     * @description Maps existing screening matches by their keys.
     * @param existingScreeningMatches The list of existing screening matches.
     * @return Map<Decimal, PartyScreeningSummary> The map of existing screening matches.
     */
    public Map<Decimal, PartyScreeningSummary> mapExistingScreeningMatches(List<PartyScreeningSummary> existingScreeningMatches) {
            Map<Decimal, PartyScreeningSummary> existingScreeningMatchesMap = new Map<Decimal, PartyScreeningSummary>();
            for (PartyScreeningSummary existingScreeningMatch : existingScreeningMatches) {
                existingScreeningMatchesMap.put(Decimal.valueOf(existingScreeningMatch.ScreeningMatchKey__c), existingScreeningMatch);
            }
        return existingScreeningMatchesMap;
    }
	/**
     * @description Retrieves the IDs of adverse media screening matches.
     * @param screeningMatches The list of screening matches to check for adverse media.
     * @return Set<Id> The set of IDs of adverse media screening matches.
     */
    public Set<Id> getAdverseMediaIds(List<PartyScreeningSummary> screeningMatches) {
        Set<Id> ids = new Set<Id>();
        for (PartyScreeningSummary partyScreenSummaryObj : screeningMatches) {
            if (partyScreenSummaryObj.IsAdverseMedia__c) {
                ids.add(partyScreenSummaryObj.Id);
            }
        }
        return ids;
    }
  
	 /**
     * @description Updates the screening status for the applicant, account, and application.
     * @param applicant The primary party profile.
     * @param account The account associated with the application.
     * @param application The application being screened.
     * @param status The screening status to set.
	*/
    public void updateScreeningStatus(PartyProfile applicant, ApplicationForm application, String status) {
        try{
            applicant.WorldcheckStatus__c = status;
            if(applicant.WorldcheckStatus__c == 'Matches found'){
                notifyOwner(applicant);
            }
            CMN_UTIL_FLS.updateRecordWithFLSCheck(applicant);
        }catch (Exception e) {
            LOGGER.error('An unexpected error occurred in updateScreeningStatus: ' + e.getMessage() + '[ ExceptionStack: ]' + e.getStackTraceString());
        }      
    }
    /**
     * Handles processing when the outcome status is confirmed as a hit.
     * @param outcome The PartyScreeningStep object containing status and reason information.
     * @param verification The PartyProfile object associated with the screening process.
     * @param application The ApplicationForm object related to the screening process.
     * @param match The PartyScreeningSummary object representing the screening match details.
     * @param result The Result object that will be updated based on the processing.
     * @param results The ICS_DTO_FinscanResponse.PairsUpdate object that contains pairs update results.
     * @param status The status string that will be updated based on the processing.
     */
    public void handleConfirmedHit(PartyScreeningStep outcome, PartyProfile verification, ApplicationForm application, PartyScreeningSummary match, ICS_CTRL_Finscan.Result result, ICS_DTO_FinscanResponse.PairsUpdate results, String status) {
        match.IsReviewed__c = true;
        result.safeDisable = true;
        CMN_UTIL_FLS.updateRecordWithFLSCheck(match);
    
        Boolean reviewedAll = checkReviewed(verification);
        if (reviewedAll) {
            if (outcome.Reason__c.contains('True match-Declined')) {
               status = ICS_CTRL_Finscan.SCREENING_STATUS_HITSDECLINED;
            }else{
               status = ICS_CTRL_Finscan.SCREENING_STATUS_HITSCONFIRMED;
            }      
            updateScreeningStatus(verification, application, status);
        }
    
        if (results == null) {
            result.isSuccess = false;
            result.message = 'Finscan Pairs Update request was unsuccessful. Please contact your System Administrator.';
            return;
        }
    }
    /**
     * Handles processing when the outcome reason indicates a true match that was declined.
     * @param outcome The PartyScreeningStep object containing status and reason information.
     * @param verification The PartyProfile object associated with the screening process.
     * @param application The ApplicationForm object related to the screening process.
     * @param match The PartyScreeningSummary object representing the screening match details.
     * @param result The Result object that will be updated based on the processing.
     * @param results The ICS_DTO_FinscanResponse.PairsUpdate object that contains pairs update results.
     * @param status The status string that will be updated based on the processing.
     */
    
    public void handleTrueMatchDeclined(PartyScreeningStep outcome, PartyProfile verification, ApplicationForm application, PartyScreeningSummary match, ICS_CTRL_Finscan.Result result, ICS_DTO_FinscanResponse.PairsUpdate results, String status) {
        match.IsReviewed__c = true;
    
        if (results == null) {
            result.isSuccess = false;
            result.message = 'Finscan Pairs Update request was unsuccessful. Please contact your System Administrator.';
            return;
        }
        status = ICS_CTRL_Finscan.SCREENING_STATUS_HITSDECLINED;
        updateScreeningStatus(verification, application, status);
        updateReviewed(verification);
        closeDeclinedOpportunity(verification.AccountId, outcome.Reason__c, application, verification, match);
    }

    /**
     * @description This method checks all PartyScreeningStep records related to a given PartyProfile.
     * @param applicant The PartyProfile object representing the applicant.
     * @param confirmedStatus The status string to be assigned when the process should continue.
     * @param discountedStatus The status string to be assigned when the process should be discounted.
     * @return The new screening status based on the PartyScreeningStep records.
     */
    public String ContinueCheck(PartyProfile applicant, String confirmedStatus, String discountedStatus) {
        final SEL_PartyScreeningSummary partyScreeningSummarySelector = new SEL_PartyScreeningSummary();
        List<PartyScreeningSummary> screeningSummaries = partyScreeningSummarySelector.selectByPartyProfileIdWithPartyScreeningSteps(applicant.Id);
        String newScreeningStatus = discountedStatus;
        
        for (PartyScreeningSummary summary : screeningSummaries) {
            for (PartyScreeningStep step : summary.PartyScreeningSteps) {
                if (step.Reason__c.contains('Continue with process')) {
                    newScreeningStatus = confirmedStatus;
                    return newScreeningStatus;
                }
            }
        }
        
        return newScreeningStatus;
    }  
    /**
     * @description Updates the client status based on the decision.
     * @param verification The PartyProfile record to be updated.
     * @param decision The decision to determine the status update (e.g., 'onboarded' or 'cancelled').
     */
    public void updateClientStatus(PartyProfile verification, String decision) {
        try {
            if ('onboarded'.equals(decision)) {
                verification.isClientOnboarded__c = true;
            } else if ('cancelled'.equals(decision)) {
                verification.isClientCancelled__c = true;
            }
        } catch (Exception ex) {
            final String message = 'Error updating client status - [verification ID:]'  + verification.Id + '[Exception Message: ]'+ ex.getMessage();
            LOGGER.error(message);
        }
    }
    
    /**
     * @description Serializes and logs JSON value if it exceeds the maximum length allowed.
     * @param value The value to be serialized.
     * @param sfScreeningMatch The screening match record.
     * @param fieldName The name of the field being serialized.
     * @return String The serialized JSON value.
     */
    public String serializeAndLog(Object value, PartyScreeningSummary sfScreeningMatch, String fieldName) {
        String json = JSON.serialize(value, true);
        if (json.length() > longTextAreaMaxLength) {
            final String message = fieldName +
                ' JSON value was not saved since value length exceeded maximum allowed - [Max allowed: ]' + longTextAreaMaxLength +'[Actual: ]' + json.length() + '[Verification.Id: ]' + sfScreeningMatch.PartyProfileId +'[ScreeningMatchKey: ]' + sfScreeningMatch.ScreeningMatchKey__c;
            LOGGER.error(message);
            return null;
        } else {
            return json;
        }
    }
    /**
     * @description Serializes linked entities and logs JSON value if it exceeds the maximum length allowed.
     * @param linkedEntitiesSource The source of the linked entities.
     * @param sfScreeningMatch The screening match record.
     * @return String The serialized JSON value for linked entities.
     */
    public String serializeLinkedEntities(ICS_DTO_FinscanResponse.LinkedEntities linkedEntitiesSource, PartyScreeningSummary sfScreeningMatch) {
        List<Object> linkedEntities = new List<Object>();
            for (Integer i = 0; i < linkedEntitiesSource.listProfileKey.size(); i++) {
                Map<String, Object> linkedEntity = new Map<String, Object>();
                linkedEntity.put('listProfileKey', linkedEntitiesSource.listProfileKey[i]);
                linkedEntity.put('uid', linkedEntitiesSource.uid[i]);
                linkedEntity.put('name', linkedEntitiesSource.name[i]);
                linkedEntity.put('pep', linkedEntitiesSource.pep[i]);
                linkedEntity.put('pepDescription', linkedEntitiesSource.pepDescription[i]);
                linkedEntity.put('category', linkedEntitiesSource.category[i]);
                linkedEntity.put('listCategory', linkedEntitiesSource.listCategory[i]);
                linkedEntities.add(linkedEntity);
            }
        return serializeAndLog(linkedEntities, sfScreeningMatch, 'Linked Entities');
    }
    /**
     * @description This method updates screening match record fields based on finscan response' screening match
     * @param sfScreeningMatch screening match record
     * @param finscanScreeningMatch finscan screening match
     * @return PartyScreeningSummary updated screening match record
     */
    public PartyScreeningSummary updateScreeningMatch(PartyScreeningSummary sfScreeningMatch, ICS_DTO_FinscanResponse.SearchMatch finscanScreeningMatch) {
        sfScreeningMatch.IsUncategorised__c = finscanScreeningMatch.fnsCategories.contains('Standard Bank::Other (Individuals)');
        sfScreeningMatch.IsPEP__c = finscanScreeningMatch.fnsCategories.contains('PEP');
        sfScreeningMatch.IsAdverseMedia__c = finscanScreeningMatch.fnsCategories.contains('AdverseMedia');
        sfScreeningMatch.IsSanctioned__c = finscanScreeningMatch.fnsCategories.contains('SANCTIONS-INDIVIDUALS');
        sfScreeningMatch.IsBlacklist__c = finscanScreeningMatch.listName.contains('Standard Bank Black List');
        sfScreeningMatch.IsWatchlist__c = finscanScreeningMatch.listName.contains('SBO Watchlist');
        sfScreeningMatch.NameList__c = finscanScreeningMatch.listName;
        sfScreeningMatch.RankScore__c = finscanScreeningMatch.rankScore;
        sfScreeningMatch.RankValue__c = String.valueOf(finscanScreeningMatch.rankValue.abbreviate(16));
        sfScreeningMatch.Name = finscanScreeningMatch.displayLine.abbreviate(80);
        sfScreeningMatch.AliasList__c = finscanScreeningMatch.dynamicFields.listAliases.abbreviate(2048);
        sfScreeningMatch.BirthdateList__c = finscanScreeningMatch.dynamicFields.listDOBs.abbreviate(255);
        sfScreeningMatch.GenderList__c = finscanScreeningMatch.dynamicFields.listGender.abbreviate(255);
        sfScreeningMatch.CitizenshipList__c = finscanScreeningMatch.dynamicFields.listCitizenships.abbreviate(255);
        sfScreeningMatch.CountryList__c = finscanScreeningMatch.dynamicFields.listCountries.abbreviate(255);
        if (finscanScreeningMatch.listRecordDetail.listRecord.worldCheck != null) {
            sfScreeningMatch.FinscanCategoryList__c = finscanScreeningMatch.fnsCategories.abbreviate(255);
            sfScreeningMatch.PEPCategoryList__c = finscanScreeningMatch.dynamicFields.listPEPCategory;
            sfScreeningMatch.ScreeningMatchCategory__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.category.abbreviate(80);
            sfScreeningMatch.CategoryDescription__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.categoryDescription.abbreviate(2048);
            sfScreeningMatch.Subcategory__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.subcategory.abbreviate(80);
            sfScreeningMatch.SubcategoryDescription__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.subcategoryDescription.abbreviate(2048);
            sfScreeningMatch.BirthPlace__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.place_of_birth.abbreviate(255);
            sfScreeningMatch.ScreeningMatchPosition__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.person.position.abbreviate(255);
            sfScreeningMatch.Information__c = finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.further_information.abbreviate(32768);
            sfScreeningMatch.LocationList__c = serializeAndLog(finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.locations.location, sfScreeningMatch, 'Location');
            sfScreeningMatch.CompanyList__c = serializeAndLog(finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.companies, sfScreeningMatch, 'Company');
            sfScreeningMatch.KeywordList__c = serializeAndLog(finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.keywords.keywordDescription, sfScreeningMatch, 'Keyword');
            sfScreeningMatch.ExternalSourceList__c = serializeAndLog(finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.external_sources.uri, sfScreeningMatch, 'ExternalSource');
            sfScreeningMatch.LinkedEntityList__c = serializeLinkedEntities(finscanScreeningMatch.listRecordDetail.listRecord.worldCheck.details.linked_to, sfScreeningMatch);
        }
        return sfScreeningMatch;
    }
    /**
     * @description This method notifies application owner about new screening matches
     * @param verification PartyProfile record
     */
    public void notifyOwner(PartyProfile verification) {
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(NOTIFICATIONTYPEID);
        notification.setTargetId(verification.id);
        notification.setTitle('Screening Matches Found');
        notification.setBody('Please review new screening matches for the application ' + verification.Account.Name);
        Set<String> recipientsIds = new Set<String>{ verification.OwnerId };
        
        notification.send(recipientsIds);
        checkMatchesFound(verification.accountId);
    }
    
    /**
     * @description This method performs Email Trigger if Finscan Matches Found.
     * @param accountIds List of Account Ids
     * @param decision Matches Found
     * @return voud
     */
    @future
    public static void checkMatchesFound(id accountId) {
    ICS_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
    Map<string, string> labelInfo = (Map<string, string>) JSON.deserialize(labelData.Description__c, map<string, string>.class);
    EmailTemplate emailTemplate = [SELECT Id,Subject,Description, HtmlValue FROM EmailTemplate WHERE Name = :labelInfo.get('SBO_MatchesFoundNotification')];
    List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE Address=:labelInfo.get('isleOfManOrgWideAddress')];
	Integer maxEmailsAllowed = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations(); 
        List<ApplicationForm> appFormRecords = new SEL_ApplicationForm().selectByAccountIds(new set<id> {accountId});
         string OppId;
   		 if(appFormRecords.size()>0){
      		 OppId =  appFormRecords[0].opportunityId;
   		}
    SEL_Opportunity oppSelector = new SEL_Opportunity();
    Opportunity oppData  = oppSelector.selectById(OppId);
    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
     if ((oppData.Owner.email != null && messages.size() < maxEmailsAllowed ) || Test.isRunningtest()){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
         		
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(false);
                    
                    String emailTextBody = emailTemplate.HtmlValue;
                    emailTextBody = emailTextBody.replace('{{{opportunity.Name}}}', oppData.Name);
         emailTextBody = emailTextBody.replace('{{{opportunity.Link}}}',URL.getOrgDomainUrl().toExternalForm() + '/' + OppId);

                    String emailSubject = emailTemplate.Subject;
                    
                    message.setTemplateID(emailTemplate.Id); 
                    message.setWhatId(oppData.Id);
                     if(lstEmailAddress.size()>0){
                         message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
                     }
                    message.setSubject(emailSubject);
                    message.setHtmlBody(emailTextBody);
                    List<string> toAddresses = new List<string>();
                    toAddresses.add(oppData.Owner.email);
                    message.setToAddresses(toAddresses);
                    if( !Test.isRunningtest()) {
                        messages.add(message);
                    }
                } else {
                    LOGGER.error('Email Limit got Exceeded');
                }
            
             if (!Test.isRunningTest() && messages.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
    

}