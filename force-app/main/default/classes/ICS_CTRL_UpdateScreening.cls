/**
* @description SFP-32986 Class used to update to next stage of FinScan
* @author Swapnil Walse, Ikyatha Naidu
* @date 23/04/2024
* Last Modified By IKYATHA NAIDU
* Last Modified Date 23/04/2024
* Modification Description: Updated to latest version
*/
public without sharing class ICS_CTRL_UpdateScreening {
    private ICS_CTRL_UpdateScreening(){}
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_UpdateScreening');

    @InvocableMethod(label='update PartyProfile stage' description='updates Opportunity stage' category='PartyProfile')
    Public static void updateStages(List<Id> accountIds){
     try{
         
        if(!accountIds.isempty()){
            sel_partyprofile profileData = new sel_PartyProfile();
            List<partyprofile> profileInfoList = profileData.selectByAccountId(accountIds[0]);
            
            PartyProfile partyProfileInfo;
     		for(PartyProfile partyProfile:profileInfoList){
                if(Schema.SObjectType.PartyProfile.getRecordTypeInfosById().get(partyProfile.RecordTypeId).getDeveloperName() == 'ICS_PartyProfile'){
                    partyProfileInfo = partyProfile;
                }
            }

            if(partyProfileInfo.worldcheckstatus__c == 'No matches found' || partyProfileInfo.worldcheckstatus__c == 'Matches discounted' 
               || partyProfileInfo.worldcheckstatus__c == 'Match confirmed - Continue with process' ) {
                    updateFormAndOpportunity(accountIds[0]);
               }
            
        }
     }catch(Exception ex){

            LOGGER.error(ex.getMessage(), 'Failed to update Application form');
        }

    }
    
      /**
     * @description This method updates the Application Form
     * @param accountIdId Account Id
     * @return String update response
     */
    public static String updateFormAndOpportunity(Id accountId) {

        string response='';
        
        try{
            SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
            List<ApplicationForm> formList = selectorFormData.selectByAccountId(accountId);
            ApplicationForm formData = new ApplicationForm();
            if(!formList.isempty()){
                formData = formList[0];
            }
            if (formData == null) {
                return 'No ApplicationForm found';
            }
            if(formData.Opportunity.stageName == 'Screening') {
                 formData.Stage = 'Awaiting Form Filling';
            
                database.update(formData,false) ;
                updateAppForm(formData.id);
                response = 'updated';

            }
        }catch(Exception ex){
            response ='Error';
            LOGGER.error(ex.getMessage(), 'Failed to update Application form');
        }
        return response;

    }
    /**
	* @description Updates the Opportunity stage to 'Screening' if all related ApplicationForms are in the 'Screening' stage.
    * @param formData ApplicationForm
	* @return Response string
	*/
    public static String updateOpportunityStage(ApplicationForm formData) {

        string response='';
        try{
            SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();

            List<ApplicationForm> formList = new List<ApplicationForm>();
            formList = selectorFormData.selectByOpportunityId(formData.OpportunityId);
            Integer stageCounter = 0;

            for (ApplicationForm formInfo : formList) {
                if (formInfo.Stage == 'Awaiting Form Filling') {
                    stageCounter++;
                }
            }
            if (stageCounter == formList.size() && formData.Opportunity.stagename == 'Screening') {

                Opportunity oppToUpdate = new Opportunity(
                    Id = formData.OpportunityId,
                    StageName = 'Application form'
                );
                update oppToUpdate;

            }

            return 'updated';
        }catch(Exception ex){
            response ='Error';
            LOGGER.error(ex.getMessage(), 'Failed to update Opportunity');
        }
        return response;
    }
    
    /**
	* @description Future method to Updates the Opportunity stage to ApplicationForms .
    * @param appId ApplicationForm Id
	*/
    @future
    Public static void updateAppForm(string appId){
        try{
            SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
            ApplicationForm  appForm = new ApplicationForm();
            appForm = selectorFormData.selectById(appId, true);
            
            updateOpportunityStage(appForm);
        }catch(Exception ex){

            LOGGER.error(ex.getMessage(), 'Failed to update Application form');
        }
    }
    
        /**
     * @description checkPartyProfileScreeningField
     * @param parentId  AccountId
     * @return String Screening Status
     */    
    @AuraEnabled
    Public static string checkPartyProfileScreeningField(string accId){
        String screeningStatus;
        try{
        PartyProfile profileInfo = new SEL_PartyProfile()
        .selectByAccountAndRecordType(accId, 'ICS_PartyProfile');
                if(profileInfo != null){
                    screeningStatus = profileInfo.WorldcheckStatus__c;
                }
                return screeningStatus;
        }catch(Exception ex){

            LOGGER.error(ex.getMessage(), 'Failed to get party profile');
            throw new AuraHandledException(ex.getmessage());
        }
    }
        /**
     * @description get boolean to get stage value for verification
     * @param parentId  AccountId
     * @return Boolean
     */
    @AuraEnabled
    Public static boolean navigatetoReview(string parentId) {
        try{
            boolean navigateScreening = true;
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List < ApplicationForm > appData = selectorApplicationForm.selectByAccountId(parentId);

            if (appData[0].stage == 'Awaiting Screening') {
                navigateScreening = true;
            } else {
                navigateScreening = false;
            }
            return navigateScreening;
        }catch(exception exc){
            LOGGER.error(exc.getmessage(),' Failed to fetch applicationForm records: navigateScreening');
            throw new AuraHandledException(exc.getmessage());
        }
    }
}