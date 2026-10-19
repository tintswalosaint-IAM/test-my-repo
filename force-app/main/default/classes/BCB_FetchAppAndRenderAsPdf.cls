/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :July 2023
@ Name of the Class :BCB_FetchAppAndRenderAsPdf
@description       :Apex class for Visualforce page to render a pdf for application summary to send it to DSX.
@ Last Modified By  :Ravi Myaka 
@ Last Modified On  :18-04-2024
@ Modification Description : SFP-37845
***************************************************************************************/
public without sharing class BCB_FetchAppAndRenderAsPdf {

    /*** @description Vf pagelist of Participant for set and get*/
    public Application_Participant__c listAppPart{get;set;}
    /*** @description Vf pagelist of Participant for set and get*/
    public List<Individual> listIndividual{get;set;}
    /**
     * @description Vf pagelist of applications for set and get
     */
    public List<Application__c> lstApps{get;set;}
    /**
     * @description Vf page fetches the apps and sends to DSX
     */
    public BCB_FetchAppAndRenderAsPdf() {

        lstApps = new List<Application__c>();
        listAppPart = new Application_Participant__c();
        listIndividual = new List<Individual>();
        /**
        * @description Fetching the applications with the id
        */   
        String applicationId = ApexPages.CurrentPage().getparameters().get('id');
        lstApps= new SEL_Application().selectAppsById(applicationId);
        listAppPart = new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(lstApps[0].Id);
        listIndividual= new  SEL_Individual().findParticipantById(listAppPart.Id);
    }
}