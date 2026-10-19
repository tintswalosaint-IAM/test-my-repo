/**
 * @description SFP-32986 Class used to process ID and Address request from Rely comply
 * @author Swapnil Walse, Ikyatha Naidu
 * @date 23/04/2024
 * Last Modified By IKYATHA NAIDU
 * Last Modified Date 23/04/2024
 * Modification Description: Updated to latest version 
 *  
 * @ last modified on: 06-25-2025
 * @ last modified by: Ridhima Saxena
 * @ Modification Description: SFP-50546
 * 
 * @ last modified on: 07-28-2025
 * @ last modified by: Ridhima Saxena
 * @ Modification Description: SFP-51055 - Improve on the Customer-facing comms being sent throughout the onboarding journey.
 * 
 * @last modified on: 13-10-2025
 * @last modified by: Tushar Walse
 * @Modification Description: SFP-52492 Reconfigure the GSD Referral Process -     closed opportunities
 * 
 * @ last modified on: 14-10-2025
 * @ last modified by: Tushar Walse
 * @ Modification Description: SFP-53780 UAT BUG: Needed improvement on Joint opp with GSD Prohibited country and CASE: GSD Sanctioned and GSD Prohibited in the same application
 * 
 * @ last modified on: 15-10-2025
 * @ last modified by: Ramya Gurram
 * @ Modification Description: SFP-53780 UAT BUG: Needed improvement on Joint opp with GSD Prohibited country and CASE: GSD Sanctioned and GSD Prohibited in the same application
 * 
*@last modified on  : 05-03-2026
* @last modified by  :Ikyatha Naidu
* @Modification Description :  SFP-56493   updated the check logic for CRA and ID address

* @last modified on  : 26-02-2026
* @last modified by  : Ridhima Saxena
* @Modification Description : SFP-54515 updated logic for ID verification
 * 
 */
public without sharing class ICS_API_GBGIDPOAProcessResultHandler { 
    // Constants
    private static final String SCREENING = 'Awaiting Screening';
    private static final String AD_SCREENING = 'GBGAddressScreening';
    private static final String ID_SCREENING = 'GBGIdentityScreening';
    private static final String AD_CONFIRMED = 'AddressConfirmed';
    private static final String ID_CONFIRMED = 'IdentityConfirmed';
    private static final String AD_CONFIRMED_TYPE = 'Document';
    private static final String ID_CONFIRMED_TYPE = 'Facial Biometric';
    private static final String ID_ADDRESS = 'identity_and_address';
    private static final String ACCEPTED = 'Accepted';
    private static final String NOT_ACCEPTED = 'Not Accepted';
    private static final String FULL_CRA = 'full_cra';

    // Instance variables
    private List<Account> accList = new List<Account>();
    private List<PartyIdentityVerification> verifyList = new List<PartyIdentityVerification>();
    
    private final SEL_Account selectorAccount = new SEL_Account();
   
    @TestVisible private ApplicationForm formData = new ApplicationForm();
    @TestVisible private PartyProfile pProfile = new PartyProfile();
    
    private PartyIdentityVerification verify = new PartyIdentityVerification();
    private ICS_DTO_RCVerifyAssessmentResponse aResponse = new ICS_DTO_RCVerifyAssessmentResponse();
    public static  String customerId;
    private String assessmentConfig = '';
    @TestVisible private final Integer noofPsteps = 2;

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_GBGIDPOAProcessResultHandler');

    /**
     * @description Response inner class
     */
    public class Response {
        public String status;
        public String errorMessage;
        public String accountId;
        public String responseBody;
        public String custIdentity;
        public String sfVerifyId;
    }

    /**
     * @description Process the response from Rely Comply
     * @param requestData Request data as JSON string
     * @param sName Service name
     * @return Response as JSON string
     */
    public String responseCall(String requestData, String sName) {
        Response resp = new Response();
        try {
            this.aResponse = (ICS_DTO_RCVerifyAssessmentResponse)JSON.deserialize(requestData, ICS_DTO_RCVerifyAssessmentResponse.class);

            customerId = this.aResponse.data.assessments.edges[0].node.customer.identifier;
            this.accList = this.selectorAccount.selectByIds(new Set<Id>{customerId});

            if (this.accList.isEmpty()) {
                LOGGER.error('Unable to find Account List');
                return createErrorResponse('Account not found', resp);
            }
            SEL_PartyProfile partyData = new SEL_PartyProfile();
            SEL_PartyIdentityVerification selectorVerification = new SEL_PartyIdentityVerification();
            this.pProfile = partyData.selectByAccountAndRecordType(this.accList[0].Id, ICS_Constants.SBO_RECNAME);
            this.verifyList = selectorVerification.selectByThirdPartyVerfdentifier(new set<string>{this.aResponse.data.assessments.edges[0].node.customer.id});

            if (this.aResponse.data.assessments.edges.isEmpty()) {
                return createErrorResponse('No assessments found', resp);
            }

            processAssessment(resp);
            return JSON.serialize(resp);
        } catch (Exception e) {
            return createErrorResponse(e.getMessage(), resp);
        }
    }

    private void processAssessment(Response resp) {
        for (PartyIdentityVerification eachVerification : this.verifyList) {
            if (eachVerification.ThirdPartyVerfdentifier == this.aResponse.data.assessments.edges[0].node.customer.id) {
                this.verify = eachVerification;
                break;
            }
        }

        this.assessmentConfig = this.aResponse.data.assessments.edges[0].node.assessmentConfig.name;
        if (this.assessmentConfig.contains(ID_ADDRESS)) {
            updateVerification();
            processVerificationSteps(resp);
        }
        else if(this.assessmentConfig.contains(FULL_CRA)){
            processRiskInfo();
        }
    }
    private void processRiskInfo() {
        SEL_PartyProfileRisk riskInfoSelector = new SEL_PartyProfileRisk();
      
        List<PartyProfileRisk> existingRiskInfoList =   riskInfoSelector.selectByPartyProfileIds(new set<Id>{this.pProfile.Id});
        PartyProfileRisk profileRisk = new PartyProfileRisk();
        for(PartyProfileRisk riskInfo : existingRiskInfoList){
         
            profileRisk.Id = riskInfo.Id;
           
        }
       
        
        profileRisk.PartyProfileId = this.pProfile.Id;
        profileRisk.Name = this.assessmentConfig.replace('_', ' ').capitalize();
        profileRisk.Type = 'Initial';

        String resultContext = this.aResponse.data.assessments.edges[0].node.screenings.edges[0].node.resultContext;
        profileRisk.Full_CRA_Result__c = resultContext;
        
        Map<String, Object> craResponse = (Map<String, Object>)JSON.deserializeUntyped(resultContext);
        
        // Process CRA response fields
        for (String key : craResponse.keySet()) {
            switch on key {
                when 'total_score' {
                    profileRisk.Risk_Score__c = (Decimal)craResponse.get(key);
                }
                when 'group_risk_rating' {
                    profileRisk.RiskCategory = (String)craResponse.get(key);
                }
            }
        }
        
        upsert profileRisk;
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
         List<ApplicationForm> formDataList = selectorFormData.selectByAccountId(this.pProfile.AccountId);
       
        if( profileRisk.RiskCategory.equalsIgnoreCase('High') == true){
            ApplicationForm formInfo = new ApplicationForm(
                Id = formDataList[0].Id,
                Enhanced_Due_Diligence_Required__c = profileRisk.RiskCategory.equalsIgnoreCase('High')
            );
            update formInfo;
        }
        // Update Application Form if exists
        SEL_Opportunity oppSelector= new SEL_Opportunity();
        Opportunity opp= oppSelector.selectById(formDataList[0].opportunityID);
        
        if(opp.Required_Approval_Processes__c == null || opp.Required_Approval_Processes__c.contains('Need GSD Approval;')==false){
            List<InputOutput> inputs = new List<InputOutput>();
            InputOutput input = new InputOutput();
            input.accId = this.pProfile.AccountId;
            inputs.add(input);
            updateOpportunityStage(inputs);
        }
                
    }
    
    /**
     * @description                 : Class to carry inputs from flow to updateOpportunityStage method
     * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
     * @author                      : Tushar Walse
     * @date                        : 21-09-2024
     * @ last modified on            : 21-09-2024
     * @ last modified by            : Tushar Walse
     * @ modification description    : Created
     */
    public class InputOutput {
        @InvocableVariable
        public String accId;
        @InvocableVariable
        public String gsdString;
    }

    private static Set<String> scheduledOpportunities = new Set<String>();
    @InvocableMethod(label='update Opportunity After GSD' description='updates Opportunity stage' category='Opportunity')
    public static void updateOpportunityStage(List<InputOutput> inputs){

        String accId = inputs[0].accId;
        String gsdString = inputs[0].gsdString;
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
        List<ApplicationForm> formDataList = selectorFormData.selectByAccountId(accId);
        if (!formDataList.isEmpty()) {

            ApplicationForm formInfo = new ApplicationForm(
                Id = formDataList[0].Id,
                stage='Awaiting Document Upload',
                On_hold_reason__c = null
            );
            update formInfo;
            
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            Integer stageCounter = 0;
         	List<ApplicationForm> appData = selectorApplicationForm.selectByOpportunityId(formDataList[0].opportunityId);
            List<Applicationform> formList = new List<Applicationform>();
            for(ApplicationForm formObj:  appData){
                if(gsdString != null && formObj.Id != formDataList[0].Id){
                    formObj.stage = 'Awaiting Document Upload';
                    formList.add(formObj);
                }
               
            }
            if(formList.size()>0){
                database.update(formList); 
            }

            if(!scheduledOpportunities.contains(formDataList[0].opportunityId)) {
                scheduledOpportunities.add(formDataList[0].opportunityId);
                
                ICS_OpportunityStageUpdateScheduler scheduler = new ICS_OpportunityStageUpdateScheduler(formDataList[0].opportunityId);
                DateTime dt = DateTime.now().addMinutes(2);
                String cronExp = dt.second() + ' ' + dt.minute() + ' ' + 
                                dt.hour() + ' ' + dt.day() + ' ' + 
                                dt.month() + ' ? ' + dt.year();
                String uniqueJobName = 'opporutunity update ' + formDataList[0].opportunityId + ' ' + 
                                System.now().getTime() + ' ' + 
                                Math.round(Math.random() * 1000000);
                System.schedule(uniqueJobName, cronExp, scheduler);
            }

            Opportunity opportunityRecord = new SEL_Opportunity().selectById(formDataList[0].opportunityId);
            if (opportunityRecord?.StageName?.startsWith('Closed')) {
                return;
            }
            List<ApplicationForm> appDataAfterUpdate = selectorApplicationForm.selectByOpportunityId(formDataList[0].opportunityId);
            for(ApplicationForm formObj:  appDataAfterUpdate){
                
                if (formObj.stage == 'Awaiting Document Upload') {
                    stageCounter++;
                }
            }
            if (stageCounter == appData.size() ) {
                Opportunity opp = gsdString == null ? new Opportunity(Id = appData[0].opportunityId, StageName = 'Documents upload') : new Opportunity(Id = appData[0].opportunityId, StageName = 'Documents upload', Required_Approval_Processes__c = gsdString);
                update opp;
             }
        }
    }
    
    private void updateVerification() {
        this.verify.PartyProfileId = this.pProfile.Id;
        this.verify.OwnerId =this.pProfile.ownerId;
        this.verify.reportURL = this.aResponse.data.assessments.edges[0].node.customer.pageURL;
        this.verify.Name = this.assessmentConfig.replace('_', ' ').capitalize();
        this.verify.VerificationRequestDate = (DateTime)JSON.deserialize('"' + this.aResponse.data.assessments.edges[0].node.created + '"', DateTime.class);
        this.verify.RequestCompletionDate = (DateTime)JSON.deserialize('"' + this.aResponse.data.assessments.edges[0].node.updated + '"', DateTime.class);
        this.verify.ThirdPartyVerfdentifier = this.aResponse.data.assessments.edges[0].node.customer.id;

        if (this.aResponse.data.assessments.edges[0].node.complete) {
            setCompletedVerificationStatus();
        } else {
            this.verify.Status = 'In Progress';
            this.verify.Result = 'On Hold';
        }

        upsertVerification();
    }
	
     private void setCompletedVerificationStatus() {
        Boolean hasCases = false;
        Boolean hasManuallyRejectedCase = false;
        
        // Check all screening edges for cases and manually rejected status
        for (ICS_DTO_RCVerifyAssessmentResponse.Edge eachScreeningEdge : this.aResponse.data.assessments.edges[0].node.screenings.edges) {
            if (!eachScreeningEdge.node.cases.edges.isEmpty()) {
                hasCases = true;
                // Check if the case outcome is Identity Inconclusive or Identity Conclusive
                String caseOutcome = eachScreeningEdge.node.cases.edges[0].node.outcome;
                if (caseOutcome == 'IdentityInconclusive' || caseOutcome == 'IdentityConclusive') {
                    hasManuallyRejectedCase = true;
                    break;
                }
            }
        }
        
        // Set verification result based on conditions
        if (hasCases) {
            if (hasManuallyRejectedCase) {
                this.verify.Result = 'Manual Verification Rejected';
            } else {
                this.verify.Result = 'Manually Confirmed';
            }
        } else {
            // No cases present - use digital verification logic
            this.verify.Result = (this.aResponse.data.assessments.edges[0].node.status == ID_CONFIRMED) 
                ? 'Digitally Confirmed' 
                : 'Digital Verification Rejected';
        }
        
        this.verify.Status = 'Completed';
    }

    private void upsertVerification() {
        try {
           
                upsert this.verify;
            
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), 'Failed to upsert PartyIdentity Verification Record');
        }
    }

    private void processVerificationSteps(Response resp) {
        SEL_PartyIdentityVerificationStep selectorVerificationStep = new SEL_PartyIdentityVerificationStep();
        List<PartyIdentityVerificationStep> vSteps = selectorVerificationStep.selectByVerificationId(new Set<Id>{this.verify.Id});
        Map<String, PartyIdentityVerificationStep> verificationStepsMap = new Map<String, PartyIdentityVerificationStep>();
        
        for (PartyIdentityVerificationStep eachVerificationStep : vSteps) {
            verificationStepsMap.put(eachVerificationStep.Name, eachVerificationStep);
        }

        List<PartyIdentityVerificationStep> identityStepList = new List<PartyIdentityVerificationStep>();
        Integer counter = 0;
        PartyIdentityVerificationStep identityStep = new PartyIdentityVerificationStep();
        for (ICS_DTO_RCVerifyAssessmentResponse.Edge eachScreeningEdge : this.aResponse.data.assessments.edges[0].node.screenings.edges) {
            identityStep = createIdentityStep(eachScreeningEdge, verificationStepsMap);
            if (identityStep != null) {
                identityStepList.add(identityStep);
                if (identityStep.VerificationDecision == ACCEPTED) {
                    counter++;
                }
            }
        }

        upsertIdentitySteps(identityStepList);

        if (counter == 2) {
            updateFormAndOpportunity(counter);
        }

        setSuccessResponse(resp);
    }

    private PartyIdentityVerificationStep createIdentityStep(ICS_DTO_RCVerifyAssessmentResponse.Edge eachScreeningEdge, 
                                                         Map<String, PartyIdentityVerificationStep> verificationStepsMap) {
        PartyIdentityVerificationStep step = new PartyIdentityVerificationStep();
        step.PartyIdentityVerificationId = this.verify.Id;
        step.Name = eachScreeningEdge.node.screeningConfig.name;
        
        setStepStatus(step, eachScreeningEdge);
        setStepId(step, eachScreeningEdge, verificationStepsMap);
        
        String screeningType = eachScreeningEdge.node.screeningConfig.screeningType;
        if (screeningType == AD_SCREENING || screeningType == ID_SCREENING) {
            setStepTypeAndDecision(step, eachScreeningEdge, screeningType);
            return step;
        }
        
        return null;
    }
    
    private void setStepStatus(PartyIdentityVerificationStep step, ICS_DTO_RCVerifyAssessmentResponse.Edge screeningEdge) {
        Boolean hasNoEdges = screeningEdge.node.cases.edges.isEmpty();
        Boolean isComplete = hasNoEdges ? this.aResponse.data.assessments.edges[0].node.complete 
                                        : screeningEdge.node.cases.edges[0].node.closed;
        step.Status = isComplete ? 'Completed' : 'In Progress';
    }
    
    private void setStepId(PartyIdentityVerificationStep step, ICS_DTO_RCVerifyAssessmentResponse.Edge screeningEdge, 
                           Map<String, PartyIdentityVerificationStep> verificationStepsMap) {
        String configName = screeningEdge.node.screeningConfig.name;
        if (verificationStepsMap.containsKey(configName)) {
            step.Id = verificationStepsMap.get(configName).Id;
        }
    }
    
    private void setStepTypeAndDecision(PartyIdentityVerificationStep step, ICS_DTO_RCVerifyAssessmentResponse.Edge screeningEdge, 
                                        String screeningType) {
        Boolean isAdScreening = screeningType == AD_SCREENING;
        step.Type = isAdScreening ? AD_CONFIRMED_TYPE:ID_CONFIRMED_TYPE ;
        
        String expectedOutcome = isAdScreening ? AD_CONFIRMED : ID_CONFIRMED;
        String actualOutcome = screeningEdge.node.cases.edges.isEmpty() 
            ? screeningEdge.node.outcome 
            : screeningEdge.node.cases.edges[0].node.outcome;
        
        step.VerificationDecision = (actualOutcome == expectedOutcome) ? ACCEPTED : NOT_ACCEPTED;
    }

     @TestVisible
    private class VerificationStatus {
        public Integer acceptedCount = 0;
        public Boolean isDocumentAccepted = false;
        public Boolean isFacialAccepted = false;
    }
    
    private void upsertIdentitySteps(List<PartyIdentityVerificationStep> identityStepList) {
        try {
            processIdentitySteps(identityStepList);
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), 'Failed to upsert PartyIdentity Verification Step Records');
        }
    }
    
    private void processIdentitySteps(List<PartyIdentityVerificationStep> identityStepList) {
        upsert identityStepList;
        
        String productName = getSelectedProduct(customerId);
        VerificationStatus status = getVerificationStatus(identityStepList);
        Id templateId = determineEmailTemplate(status, productName,customerId);
        
        sendEmail(customerId, templateId, productName);
    }
    
    private String getSelectedProduct(String customerId) {
        String jsonString = ICS_CTRL_OnboardingFormCreator.selectedAccount(customerId);
        Map<String, Object> returnData = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        return returnData.containsKey('Selected Account') 
            ? (String)returnData.get('Selected Account') 
            : '';
    }
    
    private VerificationStatus getVerificationStatus(List<PartyIdentityVerificationStep> steps) {
        VerificationStatus status = new VerificationStatus();
        
        for(PartyIdentityVerificationStep step: steps) {
            if(step.VerificationDecision == 'ACCEPTED') {
                updateVerificationStatus(status, step.Type);
            }
        }
        
        return status;
    }
    
    private void updateVerificationStatus(VerificationStatus status, String verificationType) {
        status.acceptedCount++;
        
        if(verificationType == 'Document') {
            status.isDocumentAccepted = true;
        } else if(verificationType == 'Facial Biometric') {
            status.isFacialAccepted = true;
        }
    }
    @TestVisible
    private Id determineEmailTemplate(VerificationStatus status, String productName,String accountId) {
        Boolean isMailSend=false;
        if (status.acceptedCount == 2) {
            return getEmailTemplateId('SBO_ContinueWithApplication');
        }
        
        if (status.acceptedCount == 0) {
            if(isMailSend!=true)
            {
                isMailSend=true;
               sendEmailonDigitalVetifionFail(accountId); 
               sendDigitalVerificationFailNotification(accountId);
            } 
            return getEmailTemplateId('SBO_IDAndAddressDocumentationRequired');
        }
        if (status.acceptedCount < 2 && isMailSend!=true) {
            isMailSend=true;
            sendEmailonDigitalVetifionFail(accountId);
            sendDigitalVerificationFailNotification(accountId);
        }
        return getSingleVerificationTemplate(status, productName);
    }
    
    
    private Id getSingleVerificationTemplate(VerificationStatus status, String productName) {
        if (!status.isFacialAccepted) {
            return getEmailTemplateId('SBO_IDDocumentationRequired');
        }
        
        if (!status.isDocumentAccepted) {
            return getDocumentVerificationTemplate(productName);
        }
        
        return null;
    }
    
    private Id getDocumentVerificationTemplate(String productName) {
        String templateName = productName == 'Seafarer' 
            ? 'SBO_OnlineSeafarerFailedAddress'
            : 'SBO_AddressDocumentsRequired';
            
        return getEmailTemplateId(templateName);
    }
    
    private Id getEmailTemplateId(String templateName) {
        return [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1].Id;
    }
	@future(callout=true)
    public static void sendEmail(String accountId,string templateId,string prodName) {
        try {

            // Fetch email templates and URLs
            Ics_CustomLabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
            Ics_CustomLabel__mdt portalUrlData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('SBOAccountOnboardingPortalUrl');
            Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);

            // Fetch the first email template (Seaferer Account Email)
            EmailTemplate template = [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate WHERE id=: templateId];
            
            // Fetch Opportunity and Account data
            SEL_Account accRecord = new SEL_Account();
            Account acc = accRecord.selectById(accountId);
            
            // Fetch application form for the opportunity
            ApplicationForm apf = [SELECT Id, opportunityId FROM ApplicationForm WHERE accountId = :accountId];
            SEL_Opportunity opp = new SEL_Opportunity();
            Opportunity oppRec = opp.selectById(apf.opportunityId);

            // Check remaining email invocations allowed
            Integer maxEmailsAllowed = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations();
            if (maxEmailsAllowed > 0) {
                // Prepare the main email message
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                string addressInfo='';
                if(prodName == 'Seafarer') {
                    addressInfo = 'seafererOrgWideAddress';
                }else{
                    addressInfo = 'isleOfManOrgWideAddress';
                }
               List<OrgWideEmailAddress> lstEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :labelInfo.get(addressInfo)];
                if (!lstEmailAddress.isEmpty()) {
                    message.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
                }

                // Set email body, subject, and other properties
                String emailHtmlBody = template.HtmlValue;
                emailHtmlBody = emailHtmlBody.replace('{{{Owner.Email}}}', oppRec.Owner.Email);
                if (oppRec != null && oppRec.Owner != null && oppRec.Owner.Name != null) {
                    emailHtmlBody = emailHtmlBody.replace('{{{Owner.Name}}}', oppRec.Owner.Name);
                }
                emailHtmlBody = emailHtmlBody.replace('{{{Account.Name}}}', acc.Name);
                message.setHtmlBody(emailHtmlBody);
                message.setTemplateId(template.Id);
                message.setReplyTo(oppRec.owner.email);
                message.setToAddresses(new List<String>{acc.PersonEmail});
                if (template.Name != 'SBO_ContinueWithApplication')
                {
					message.setCcAddresses(new List<String>{oppRec.owner.email});
                }
                message.setSubject(template.Subject);
                
                // Send email
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});        

                
            } else {
                Logger.error('Email sending limit reached. Cannot send more emails in this transaction.');
            }
        } catch (Exception e) {
            Logger.error('Error sending email: ' + e.getMessage());
        }
    }
     public static void sendEmailonDigitalVetifionFail(String accountId) {
        try {
            SEL_Account accRecord = new SEL_Account();
            accRecord.selectById(accountId);   
            SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm(); 
           List<ApplicationForm> formDataList = selectorFormData.selectByAccountId(accountId);
            if (formDataList.isEmpty()) {
                return;
            }
            ApplicationForm apf = formDataList[0];
            SEL_Opportunity opp = new SEL_Opportunity();
            Opportunity oppRec = opp.selectById(apf.opportunityId);
            
            Set<String> emails = new Set<String>();
            if (String.isNotBlank(oppRec.Owner.Email)) {
                emails.add(oppRec.Owner.Email);
            }
            
            if (emails.isEmpty()) {
                return;
            }
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(new List<String>(emails));
            message.setSubject('Digital Verification Failed - Manual Verification Required');
            
         String oppLink = URL.getOrgDomainUrl().toExternalForm() + '/' + oppRec.Id;
            String emailBody = 'Hi,<br/><br/>' +
                            'The following Opportunity has failed digital verification:<br/><br/>' +
                            'Opportunity Name: ' + oppRec.Name + '<br/>' +
                            'Opportunity link: <a href="' + oppLink + '">' + oppLink + '</a><br/><br/>' +
                            'Please complete the manual verification of the customer making sure you handle this via Rely Comply.<br/><br/>' +
                            'Thanks,';
            
            message.setHtmlBody(emailBody);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
            
        } catch (Exception e) {
             Logger.error('Error sending email: ' + e.getMessage());
        }
    }
    public static void sendDigitalVerificationFailNotification(String accountId) {
    try {
        // Fetch account and related records
        SEL_Account accRecord = new SEL_Account();
        Account acc = accRecord.selectById(accountId);
        
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm(); 
        List<ApplicationForm> formDataList = selectorFormData.selectByAccountId(accountId);
        if (formDataList.isEmpty()) {
            LOGGER.error('No ApplicationForm found for accountId: ' + accountId);
            return;
        }
        
        ApplicationForm apf = formDataList[0];
        SEL_Opportunity opp = new SEL_Opportunity();
        Opportunity oppRec = opp.selectById(apf.opportunityId);
        
        // Get owner ID for notification
        Set<String> ownerIds = new Set<String>();
        if (String.isNotBlank(oppRec.OwnerId)) {
            ownerIds.add(oppRec.OwnerId);
        }
        
        if (ownerIds.isEmpty()) {
            LOGGER.error('No valid owner found for opportunity: ' + oppRec.Id);
            return;
        }
        
        // Fetch Notification Type ID
        List<CustomNotificationType> notificationTypes = [
            SELECT Id FROM CustomNotificationType 
            WHERE DeveloperName = 'ICS_Approval_Flow_Notifications'
        ];
        
        if (notificationTypes.isEmpty()) {
            LOGGER.error('CustomNotificationType not found');
            return;
        }
        
        // Prepare the notification type
        Id notificationTypeId = notificationTypes[0].Id;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Digital Verification Failed - Manual Verification Required');
        notification.setBody('Customer ' + acc.Name + ' has failed digital verification. Please complete manual verification via Rely Comply for opportunity: ' + oppRec.Name);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(oppRec.Id);
        
        if (!ownerIds.isEmpty()) {
            notification.send(ownerIds);
        }
    } catch (Exception e) {
        LOGGER.error(e.getMessage());
        throw new AuraHandledException(e.getMessage());   
    }
}
    private String createErrorResponse(String errorMessage, Response resp) {
        resp.status = 'Error';
        resp.errorMessage = errorMessage;
        resp.custIdentity = this.aResponse?.data?.assessments?.edges[0]?.node?.customer?.identifier;
        return JSON.serialize(resp);
    }

    private void setSuccessResponse(Response resp) {
        resp.status = 'Success';
        resp.accountId = this.accList[0].Id;
        resp.custIdentity = this.aResponse.data.assessments.edges[0].node.customer.identifier;
        resp.sfVerifyId = this.verify.Id;
    }

    /**
     * @description Updates the ApplicationForm stage to 'Awaiting Screening' and the Opportunity stage to 'Screening'
     * if the counter is equal to the specified number of steps.
     * @param counter Number of completed steps
     * @return Response string
     */
    public String updateFormAndOpportunity(Integer counter) {
       

        if (counter != this.noofPsteps) {
            return 'No update required';
        }

        try {
            this.formData = [SELECT Id, Stage, OpportunityId FROM ApplicationForm WHERE AccountId = :this.pProfile.AccountId LIMIT 1];
            if (this.formData == null) {
                return 'No ApplicationForm found';
            }

            this.formData.Stage = ICS_Constants.awaitScreening;

                update this.formData;
          

            return updateOpportunityStage();
        } catch (Exception exc) {
            LOGGER.error(exc.getMessage(), 'Error occurred while fetching and updating Opportunity');
            return 'Error occurred';
        }
    }

    /**
     * @description Updates the Opportunity stage to 'Screening' if all related ApplicationForms are in the 'Screening' stage.
     * @return Response string
     */
    public String updateOpportunityStage() {
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
      
            List<ApplicationForm> formList = new List<ApplicationForm>();
            formList = selectorFormData.selectByOpportunityId(this.formData.OpportunityId);
            Integer stageCounter = 0;

            for (ApplicationForm formInfo : formList) {
                if (formInfo.Stage == SCREENING) {
                    stageCounter++;
                }
            }

            if (stageCounter == formList.size()) {
               
                    Opportunity oppToUpdate = new Opportunity(
                        Id = this.formData.OpportunityId,
                        ICS_AllApplicationsCompleted__c= false,
                        StageName = ICS_Constants.screening
                    );
                    update oppToUpdate;
                return 'Updated';
            }
            return 'No update required';
      
    }
}