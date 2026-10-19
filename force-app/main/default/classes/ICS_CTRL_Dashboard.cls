/**
 * @description class used as controller for  SBO-UK Dashboard Feature
 *
 * Story:SFP-37439
 *
 * @author Ramya Gurram
 *
 * @date Dec 29 2023
 * @last modified on  : 29-01-2025
 * @last modified by  : Tushar Walse
 * @Modification Description :SFP-37439class used as controller for SBO-UK Dashboard
 */
public without sharing class ICS_CTRL_Dashboard {
    //Logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_Dashboard');

    /**
     * @description get boolean to get stage value for verification
     * @param parentId  AccountId
     * @return Boolean
     */
    @AuraEnabled
    Public static boolean navigatetoGBG(string parentId) {
        try{
            boolean navigateGBG = true;
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List < ApplicationForm > appData = selectorApplicationForm.selectByAccountId(parentId);

            if (appData[0].stage == 'Awaiting Verification') {
                navigateGBG = true;
            } else {
                navigateGBG = false;
            }
            return navigateGBG;
        }catch(exception exc){
            LOGGER.error(exc.getmessage(),' Failed to fetch applicationForm records: navigatetoGBG');
            throw new AuraHandledException(exc.getmessage());
        }
    }

    /**
     * @description redirect to review page while application is in Review
     * @param parentId  AccountId
     * @return Boolean
     */
    @AuraEnabled
    Public static string redirectingBasedOnStage(string parentId) {
        try{
            String redirectTo = '';
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List < ApplicationForm > appData = selectorApplicationForm.selectByAccountId(parentId);

            if (String.isEmpty(appData[0].stage)) {
                redirectTo = '';  // or appData[0].stage if you want to keep it null
            } else {
                redirectTo = appData[0].stage;
            }
            return redirectTo;
        }catch(exception exc){
            LOGGER.error(exc.getmessage(),' Failed to fetch applicationForm records: redirectingBasedOnStage');
            throw new AuraHandledException(exc.getmessage());
        }
    }


    /**
     * @description get boolean to check Joint or not
     * @param parentId  AccountId
     * @return JSON
     */
    @AuraEnabled
    public static string checkIsJoint(string parentId) {
        try {
            if (String.isBlank(parentId)) {
                throw new IllegalArgumentException('Parent ID cannot be null or empty');
            }

            SEL_Applicant selectorApplicantForm = new SEL_Applicant();
            Applicant appData = selectorApplicantForm.selectByAccountId(parentId);

            boolean isJoint = false;
            boolean isPrimary = false;

            if (appData != null) {
                switch on appData.role {
                    when 'Primary Applicant' {
                        isJoint = true;
                        isPrimary = true;
                    }
                    when 'Co-Applicant' {
                        isJoint = true;
                        isPrimary = false;
                    }
                    when '',null {
                        isJoint = false;
                        isPrimary = true;
                    }
                }
            }

            Map<String, Boolean> resultMap = new Map<String, Boolean>{
                'isPrimary' => isPrimary,
                'isJoint' => isJoint
            };

            return JSON.serialize(resultMap);

        } catch (Exception e) {
            LOGGER.error('Failed to check joint or single: ' + e.getMessage(), 'checkIsJoint');
            throw new AuraHandledException('An error occurred while processing your request. Please try again later.');
        }
    }
      /**
     * @description check opertion account selected value from primay account
     * @param parentId  AccountId
     * @return JSON
     */
   
    @AuraEnabled
    public static String getOperationAccountValue(String parentId) {
     try{

     
            // Retrieve Application Forms associated with the Parent ID
            List<ApplicationForm> appFormList = fetchApplicationForms(parentId);
    
            // Retrieve the primary applicant's Account ID
            String primaryAccId = fetchPrimaryApplicantAccountId(appFormList);
    
            // Retrieve and return the Operation Account value
            return getOperationAccount(primaryAccId);
     }catch (Exception e) {
             LOGGER.error('Error while processing getOperationAccountValue: ' + e.getMessage(), 'getOperationAccountValue');
             throw new AuraHandledException('An error occurred while processing your request. Please try again later.');
         }
    }
     /**
     * @description check opertion account selected value from primay account
     * @param parentId  AccountId
     * @return JSON
     */
   
     @AuraEnabled
     public static boolean fetchApplicationFormWithStage(String parentId) {
         try {
             if (String.isBlank(parentId)) {
                 throw new IllegalArgumentException('Parent ID cannot be null or empty');
             }
             List<ApplicationForm> appFormList = fetchApplicationForms(parentId);
             Integer count =0;
             for(ApplicationForm form : appFormList){
                if(form.stage != 'Awaiting Verification'){
                    count++;
                }
             }
             return appFormList.size() == count;
     
         } catch (Exception e) {
             LOGGER.error('Error while processing fetchApplicationFormWithStage: ' + e.getMessage(), 'fetchApplicationFormWithStage');
             throw new AuraHandledException('An error occurred while processing your request. Please try again later.');
         }
     }
    
    /**
     * Helper method to fetch Application Forms by Parent ID
     */
    private static List<ApplicationForm> fetchApplicationForms(String parentId) {
        try {
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List<ApplicationForm> formData = selectorApplicationForm.selectByAccountId(parentId);
    
            Map<String, String> opportunityMapId = new Map<String, String>();
            for (ApplicationForm form : formData) {
                opportunityMapId.put(form.Id, form.OpportunityId);
            }
    
            return selectorApplicationForm.selectByOpportunityIds(opportunityMapId.values());
    
        } catch (Exception exc) {
            LOGGER.error('Failed to retrieve Opportunity Info: ' + exc.getMessage(), 'fetchApplicationForms');
            throw new AuraHandledException('An error occurred while retrieving application forms.');
        }
    }
    
    /**
     * Helper method to fetch the Primary Applicant's Account ID
     */
    private static String fetchPrimaryApplicantAccountId(List<ApplicationForm> appFormList) {
        Set<Id> appAccountIds = new Set<Id>();
        for (ApplicationForm app : appFormList) {
            appAccountIds.add(app.AccountId);
        }
    
        SEL_Applicant selectorApplicantForm = new SEL_Applicant();
        List<Applicant> appData = selectorApplicantForm.selectPrimaryApplicantByAccountIds(appAccountIds);
    
        if (!appData.isEmpty()) {
            return appData[0].AccountId;
        }
    
        return null;
    }
    
    /**
     * Helper method to retrieve the Operation Account value
     */
    private static String getOperationAccount(String primaryAccId) {
        string questionValue;
       
        try {
            SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
            List<AssessmentQuestionResponse> responseData = new  List<AssessmentQuestionResponse> ();
            responseData = selectorAssessmentqueResponse.selectByParentId(primaryAccId);
            if(responseData == null){
                responseData = new  List<AssessmentQuestionResponse> ();
            }
    
            for (AssessmentQuestionResponse responseNameData : responseData) {
                if (responseNameData.Name.contains('Operation of Account')) {
                    questionValue= responseNameData.ResponseValue;
                }
            }
            return questionValue;
    
        } catch (Exception exc) {
            LOGGER.error('Failed to retrieve operation account: ' + exc.getMessage(), 'getOperationAccount');
            throw new AuraHandledException('An error occurred while retrieving the operation account.');
        }
    }
    
    /**
    * @description Get the JSON key of the message to be displayed to the applicant
    * @author Tushar Walse | 12-12-2024 
    * @param accId AccountId of the community user
    * @return String JSON key of the message to be displayed
    **/
    @AuraEnabled
 	public static String getApplicantMessage(String accId) {
        String messageKey = null;
        try {
            LOGGER.warn('getApplicantMessage called for Account ID: ' + accId);
 
            ApplicationForm[] applicationForms = new SEL_ApplicationForm().selectByAccountId(accId);
            Opportunity opportunity = new SEL_Opportunity().selectById(applicationForms[0].OpportunityId);
            if(opportunity == null) {
                return messageKey;
            }
           
            if(opportunity.StageName == 'Closed Lost') {
                messageKey = 'ics_closedlost_' + opportunity.Loss_Reason__c.toLowerCase().replaceAll('[\\u00A0\\s]', '');
            } else if(opportunity.StageName == 'Closed Declined') {
                messageKey = 'ics_closeddeclined_' + opportunity.ICS_Decline_Reason__c.toLowerCase().replaceAll('[\\u00A0\\s]', '');
            } else {
                if(opportunity.Required_Approval_Processes__c != null && opportunity.Required_Approval_Processes__c.contains('Need GSD Approval;')
                     && !opportunity.Required_Approval_Processes__c.contains('GSD Approval Confirmed;')) {
                    messageKey = 'ics_gsd';
                }
                applicationForms = new SEL_ApplicationForm().selectByOpportunityId(opportunity.Id);
                Set<Id> accountIds = new Set<Id>();
                Boolean ukraineException = false;
                
                 
                sel_User userInfoSelector =new sel_User();
                List<User> userData = userInfoSelector.selectUsersByIds(new set<Id>{userInfo.getuserId()});
                for(ApplicationForm applicationForm : applicationForms) {
                    accountIds.add(applicationForm.AccountId);
                    if(applicationForm.stage == 'On Hold' && (applicationForm.On_hold_reason__c == 'Ukraine Exception' ||applicationForm.On_hold_reason__c == 'Challenging Risk Rating' ||applicationForm.On_hold_reason__c == 'Application Issues (RFT)' )) {
                        ukraineException = true;
                    }else if(applicationForm.opportunity.Required_Approval_Processes__c != null && applicationForm.opportunity.Required_Approval_Processes__c.contains('Need Captain letter Approval;')
                        && !applicationForm.opportunity.Required_Approval_Processes__c.contains('Captain Letter Approval Confirmed;'+applicationForm.AccountId)
                            && applicationForm.AccountId ==  userData[0].Contact.AccountId) {
                                messageKey = 'ics_captain';
                    }
                }
                if(ukraineException) {
                    messageKey = 'ics_ukraineexception';
                }
                PartyProfile[] partyProfiles = new SEL_PartyProfile().selectByAccountIds(new set<id>{accId});
                Boolean matchesFound = false;
                for(PartyProfile partyProfile : partyProfiles) {
                    if(partyProfile.WorldcheckStatus__c == 'Matches found') {
                        matchesFound = true;
                    }
                }
                if(matchesFound) {
                    messageKey = 'ics_matchesfound';
                }
                PartyIdentityVerification[] partyIdentityVerifications = new SEL_PartyIdentityVerification().selectByPartyProfileIds((new Map<Id, PartyProfile>(partyProfiles)).keySet());
                Boolean digitalVerificationFailed = false;
                for(PartyIdentityVerification partyIdentityVerification : partyIdentityVerifications) {
                    if((partyIdentityVerification.Result == 'Digital Verification Rejected' || partyIdentityVerification.Result == 'On Hold') && partyIdentityVerification.PartyProfile.AccountId == accId) {
                        digitalVerificationFailed = true;
                    }
                }
                for(PartyIdentityVerification partyIdentityVerification : partyIdentityVerifications) {
                    if(partyIdentityVerification.Result == 'Manually Confirmed' || partyIdentityVerification.Result == 'Digitally Confirmed'
                    
                    ) {
                        digitalVerificationFailed = false;
                    }
                }
                if(digitalVerificationFailed) {
                    messageKey = 'ics_digitalverificationfailed';
                }
            }
 
            if(messageKey != null && messageKey.startsWith('ics_closedlost_')) {
                String mapString = checkIsJoint(accId);
                Map<String, Boolean> checkIsJointInfoMap = (Map<String, Boolean>)JSON.deserialize(mapString, Map<String, Boolean>.class);
                if(checkIsJointInfoMap.get('isJoint') && !checkIsJointInfoMap.get('isPrimary')) {
                    messageKey = 'ics_closedlostjointapplicant';
                }
            }
         
        } catch (Exception e) {
            LOGGER.error('Error in getApplicantMessage: {0}\nargument: {1}\nline: {2}', new Object[]{e.getMessage(), accId, e.getLineNumber()});
            
        }
           return messageKey;
    }
    /**
     * @description get all application form List
     * @param accId AccountId
     * @return List < ApplicationForm >
     */

    @AuraEnabled
    public static List < ApplicationForm > fetchApplicationFormList(String accId) {
        List < ApplicationForm > appFormList = new List < ApplicationForm > ();
        try{
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List < ApplicationForm > formData = selectorApplicationForm.selectByAccountId(accId);
            Map < String, String > opportunityMapId = new Map < String, String > ();
            for (ApplicationForm form: formData) {
                opportunityMapId.put(form.Id, form.OpportunityId);
            }
            appFormList = selectorApplicationForm.selectByOpportunityIds(opportunityMapId.values());
        }catch(exception exc){

            LOGGER.error(exc.getmessage(),' Failed to retreive Opportunity Info');
            throw new AuraHandledException(exc.getmessage());
        }
        return appFormList;
    }
	  /**
     * @description get json format of Result GBG response
     * @param accId AccountId
     * @return json format
     */
    @AuraEnabled
     Public static string fetchVerificationResult(string accId){
          Map<string,string> resultMap = new Map<string,string>();
          string result='';
        try{
            SEL_PartyIdentityVerification verificationSelector =new SEL_PartyIdentityVerification();


            sel_PartyProfile profileSelector = new sel_PartyProfile();
            PartyProfile profileInfo =  profileSelector.selectByAccountAndRecordType(accId,'ICS_PartyProfile');
            List<PartyIdentityVerification> verificationResultList= verificationSelector.selectByPartyProfileIds(new set<Id>{profileInfo.id});
            PartyIdentityVerification verificationResult = new PartyIdentityVerification();
            if(verificationResultList.isEmpty()){
                resultMap.put('result','Not Received');
            }else{
                verificationResult = verificationResultList[0];
            }
            if(verificationResult.Result == 'Digital Verification Rejected' || verificationResult.Result == 'Manual Verification Rejected' ){
                resultMap.put('result','false');
            }else if(verificationResult.Result == 'Digitally Confirmed' || verificationResult.Result == 'Manually Confirmed' ){
                resultMap.put('result','true');
            }else if(verificationResult.Result == 'On Hold'){
                resultMap.put('result','hold');
            }
            ApplicationForm[] applicationForms = new SEL_ApplicationForm().selectByAccountId(accId);
            Opportunity opportunity = new SEL_Opportunity().selectById(applicationForms[0].OpportunityId);
            if(opportunity != null && opportunity.Required_Approval_Processes__c != null && opportunity.Required_Approval_Processes__c.contains('Need Captain letter Approval;')
                && !opportunity.Required_Approval_Processes__c.contains('Captain Letter Approval Confirmed;'+accId)) {
                        resultMap.put('result','ics_captain');
            }

        }catch(exception exc){
            resultMap.put('result','Error');
            LOGGER.error(exc.getmessage(),' No Records found for PartyIdnetityVerification');
            throw new AuraHandledException(exc.getmessage());

        }
        result = json.serialize(resultMap);
         return result;
    }




    /**
     * @description get primary applicant's name
     * @param accId Application form AccountId
     * @return primary applicant's name
     */

    @AuraEnabled
    public static List < String > getPrimaryApplicantName(String accId) {
         List < string > name = new list < string > ();
        try{
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List < ApplicationForm > formData = selectorApplicationForm.selectByAccountId(accId);
            Map < String, String > opportunityMapId = new Map < String, String > ();
            for (ApplicationForm form: formData) {
                opportunityMapId.put(form.Id, form.OpportunityId);
            }
            SEL_Applicant selectorApplicant = new SEL_Applicant();
            List < Applicant > primaryAccountData = selectorApplicant.selectPrimaryApplicantByOppIds(opportunityMapId.values());

            for (Applicant primaryAccountDataB: primaryAccountData) {
                name.add(primaryAccountDataB.Account.Name);
            }
        }catch(exception exc){

            LOGGER.error(exc.getmessage(),'Error occured in fetching PrimaryApplicantName: getPrimaryApplicantName');
            throw new AuraHandledException(exc.getmessage());
        }
        return name;
    }


    /**
     * @description to fetch accountId
     * @return String account id
     */
    @AuraEnabled
    Public static string fetchCurrentApplictaionId() {

        String accountId = '';
        try{
        map < string, string > userMap = new Map < string, string > ();
        if (Schema.sObjectType.User.isAccessible()){
            for (user userData: [SELECT id, contact.accountid from user where id =: userinfo.getuserid()]) {
                userMap.put(userData.id, userData.contact.accountid);
            }
        }
            if (Schema.sObjectType.ApplicationForm.isAccessible() ||  userMap.containskey(userinfo.getuserid())){
                ApplicationForm formData = [select id, opportunityId, accountid from applicationform
                    where accountid =: userMap.get(userinfo.getuserid())
                    and opportunity.iswon = false limit 1
                ];

                if (formData != null) {
                    accountId = formData.accountid;
                }
            }else{
                LOGGER.error('No Permission to access ApplicationForm');
            }
         }catch(exception exc){
            LOGGER.error(exc.getmessage(),'Unable to fetch applicatioform:fetchCurrentApplictaionId ');
            throw new AuraHandledException(exc.getmessage());
        }
               return accountId;
    }
    /**
     * @description method to get declined stage value
     * @param accId
     * @return string Declined stage
     */
    @AuraEnabled
    public static string getDeclinedStageValue(string accId) {
        try {
            if (String.isBlank(accId)) {
                throw new IllegalArgumentException('Account ID cannot be null or empty');
            }

            SEL_Opportunity selectOpportunityData = new SEL_Opportunity();
            List<Opportunity> opps = selectOpportunityData.selectByAccountId(accId);

            if (opps.isEmpty()) {
                LOGGER.warn('No opportunities found for Account ID: ' + accId);
                return JSON.serialize(new List<Opportunity>());
            }

            return JSON.serialize(opps);

        } catch (Exception e) {
            LOGGER.error('Error occurred in getDeclinedStageValue: ' + e.getMessage(), e);
            throw new AuraHandledException('An error occurred while retrieving opportunity data. Please try again later.');
        }
    }
     /**
     * @description method to get Status and Result
     * @param accId
     * @return string Status and Result
     **/
    @AuraEnabled
    public static string getPartyProfileStageReason(string accId) {
        Map<string,string> resultMap = new Map<string,string>();
        string result='';
      try{
          SEL_PartyIdentityVerification verificationSelector =new SEL_PartyIdentityVerification();
          sel_PartyProfile profileSelector = new sel_PartyProfile();
          PartyProfile profileInfo =  profileSelector.selectByAccountAndRecordType(accId,'ICS_PartyProfile');
          List<PartyIdentityVerification> verificationResultList= verificationSelector.selectByPartyProfileIds(new set<Id>{profileInfo.id});
          PartyIdentityVerification verificationResult = new PartyIdentityVerification();
          if(verificationResultList.size() == 1){
            verificationResult = verificationResultList[0];
            if(verificationResult.Result == 'On Hold' && verificationResult.Status == 'In Progress'){
                resultMap.put('result','true');
            }
          }
      }catch(exception exc){
          resultMap.put('result','Error');
          LOGGER.error(exc.getmessage(),' No Records found for PartyIdnetityVerification');
          throw new AuraHandledException(exc.getmessage());
      }
      result = json.serialize(resultMap);
       return result;
    }
      /**
* @description To fetch the current application ID associated with the user.
* @return The ID of the current application or an empty string if not found.
*/
    @auraEnabled
    Public static boolean verifyIsClosedWon() {
        try{
        Boolean isClosedWon=false;
        map<string,string> userMap = new Map<string,string>();
        for(user userData : [SELECT id, contact.accountid from user where id =: userinfo.getuserid()]) {
            userMap.put(userData.id,userData.contact.accountid);
        }
        if(userMap.containskey(userinfo.getuserId())) {
            List<ApplicationForm> formDataList =[select id,opportunityId,accountid from applicationform
                                                 where accountid=:userMap.get(userinfo.getuserId())
                                                 and opportunity.iswon =true and opportunity.isclosed=true];
            if(formDataList.size() >0) {
                isClosedWon = true;
            }
        }
        else{
            isClosedWon = false;
        }
        return isClosedWon;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
}