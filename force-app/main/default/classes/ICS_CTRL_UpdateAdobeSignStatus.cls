/***************************************************************************************
@ Author            :Ikyatha Naidu
@ Date              :2024-02-24
@ Name of the Class :ICS_CTRL_UpdateAdobeSignStatus
@ Description       :class used to update ApplicationForm Status  after signing the applicationform 
@ Last Modified By  :Ikyatha Naidu
@ Last Modified On  :2024-02-24
@ Modification Description :SFP-30254
***************************************************************************************/  
public without sharing class ICS_CTRL_UpdateAdobeSignStatus {
   private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_UpdateAdobeSignStatus');
    private static final String RISK_RATING_STAGE = 'Risk Rating';
    private ICS_CTRL_UpdateAdobeSignStatus(){}
    /**
    * @description update signed ApplicationForm Status and related Opportunity Stage
    * @param newRecipientsList
    */
    public static void updateStatusesOnSignature(List<Echosign_Dev1__SIGN_Recipients__c> newRecipientsList) {
        Map<Id, Set<Id>> agreementToSignedContactsMap = new Map<Id, Set<Id>>();
        Set<Id> allContactIds = new Set<Id>();
        
        // Process recipients and build maps
        for (Echosign_Dev1__SIGN_Recipients__c recipient : newRecipientsList) {
            if (recipient.echosign_dev1__Status__c == ICS_Constants.Signed) {
                if (!agreementToSignedContactsMap.containsKey(recipient.echosign_dev1__Agreement__c)) {
                    agreementToSignedContactsMap.put(recipient.echosign_dev1__Agreement__c, new Set<Id>());
                }
                agreementToSignedContactsMap.get(recipient.echosign_dev1__Agreement__c).add(recipient.echosign_dev1__Contact__c);
                allContactIds.add(recipient.echosign_dev1__Contact__c);
            }
        }
        
        if (allContactIds.isEmpty()){
            return;
        }
        
        // Query ApplicationForms and update
        List<ApplicationForm> formsToUpdate = new List<ApplicationForm>();
        Map<Id, Set<Id>> accountToFormIdsMap = new Map<Id, Set<Id>>();
        
        for (ApplicationForm form : [SELECT Id, AccountId, OpportunityId, Stage 
                                     FROM ApplicationForm 
                                     WHERE Account.PersonContactId IN :allContactIds]) {
            form.Stage = ICS_Constants.Signed;
            formsToUpdate.add(form);
            
            if (!accountToFormIdsMap.containsKey(form.AccountId)) {
                accountToFormIdsMap.put(form.AccountId, new Set<Id>());
            }
            accountToFormIdsMap.get(form.AccountId).add(form.Id);
        }
        
        if (!formsToUpdate.isEmpty()) {
            update formsToUpdate;
            updateStages(accountToFormIdsMap);
        }
    }
    public static void updateStages(Map<Id, Set<Id>> accountToFormIdsMap) {
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
        try {
            List<ApplicationForm> allForms = selectorFormData.selectByAccountIds(accountToFormIdsMap.keySet());
            Map<Id, List<ApplicationForm>> accountToFormsMap = groupFormsByAccount(allForms);
            Map<Id, Opportunity> opportunitiesToUpdate = identifyOpportunitiesToUpdate(accountToFormsMap);
            
            updateOpportunities(opportunitiesToUpdate);
        } catch (Exception exc) {
            LOGGER.error('Error occurred while updating Opportunities to Risk Rating: ' + exc.getMessage(), exc);
        }
    }
    @InvocableMethod(label='fetch User Id' description='Get Adobe Licensed User' category='User')
    Public static List<string> fetchAdobeUser(){
        sel_user userSelector = new sel_user();
        ics_customlabel__mdt adobeUserInfo = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('Adobe_Sign_send_behalf_of_user');
        User userData = userSelector.selectByName(adobeUserInfo.Description__c);
        return new List<string>{userData.Id};
    }
    private static Map<Id, List<ApplicationForm>> groupFormsByAccount(List<ApplicationForm> forms) {
        Map<Id, List<ApplicationForm>> accountToFormsMap = new Map<Id, List<ApplicationForm>>();
        
        for (ApplicationForm form : forms) {
            if (!accountToFormsMap.containsKey(form.AccountId)) {
                accountToFormsMap.put(form.AccountId, new List<ApplicationForm>());
            }
            accountToFormsMap.get(form.AccountId).add(form);
        }
        
        return accountToFormsMap;
    }
    
    private static Map<Id, Opportunity> identifyOpportunitiesToUpdate(Map<Id, List<ApplicationForm>> accountToFormsMap) {
        Map<Id, Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
        
        for (Id accountId : accountToFormsMap.keySet()) {
            List<ApplicationForm> accountForms = accountToFormsMap.get(accountId);
            processAccountForms(accountForms, opportunitiesToUpdate);
        }
        
        return opportunitiesToUpdate;
    }
    
    private static void processAccountForms(List<ApplicationForm> accountForms, Map<Id, Opportunity> opportunitiesToUpdate) {
        if (areAllFormsSigned(accountForms[0].OpportunityId)) {
            Id opportunityId = accountForms[0].OpportunityId;
            if (opportunityId != null) {
                addOpportunityToUpdate(opportunityId, opportunitiesToUpdate);
            }
        }
    }
    
    private static Boolean areAllFormsSigned(string oppId) {
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();

            List<ApplicationForm> formList = new List<ApplicationForm>();
            formList = selectorFormData.selectByOpportunityId(oppId);
        integer counter=0;
        for (ApplicationForm form : formList) {
            if (form.Stage == ICS_Constants.Signed) {
                counter = counter+1;
            }
        }
        return (counter == formList.size());
    }
    
    private static void addOpportunityToUpdate(Id opportunityId, Map<Id, Opportunity> opportunitiesToUpdate) {
        opportunitiesToUpdate.put(opportunityId, new Opportunity(
            Id = opportunityId,
            StageName = RISK_RATING_STAGE
        ));
    }
    
    private static void updateOpportunities(Map<Id, Opportunity> opportunitiesToUpdate) {
        if (!opportunitiesToUpdate.isEmpty()) {
            database.update(opportunitiesToUpdate.values()) ;
            LOGGER.info('Updated ' + opportunitiesToUpdate.size() + ' Opportunities to Risk Rating stage');
            List<ApplicationForm> formList = new List<ApplicationForm>();
            if( opportunitiesToUpdate.size()>0){
                Opportunity opp= opportunitiesToUpdate.values()[0];
                SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
                formList = selectorFormData.selectByOpportunityId(opp.Id);
                List<string> accountIds= new List<string>();
                
                for (ApplicationForm formInfo : formList) {
                    accountIds.add(formInfo.accountId);
                }
                if(accountIds.size()>0){
                    for(string accId: accountIds) {
                    	ICS_API_SendCRADetails.callCRA(accId);
                    }
                }
            }
            
        }
    }
}