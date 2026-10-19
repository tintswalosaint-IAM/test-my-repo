/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :July 2023
@ Name of the Class :BCB_FetchParticipantAndRenderAsPdf
@description       :Apex class for Visualforce page to render a pdf for application participant summary to send it to DSX.
@ Last Modified By  :Ravi Myaka 
@ Last Modified On  :18-04-2024
@ Modification Description : SFP-37845
***************************************************************************************/
public without sharing class BCB_FetchParticipantAndRenderAsPdf {

    /**
     * @description Vf pagelist of Participant for set and get
     */
    public List<Application_Participant__c> lstApps{get;set;}
    /**
     * @description Vf pagelist of applications for set and get
     */
    public List<Application__c> lstApplications{get;set;}
     /**
     * @description Vf pagelist of Individual for set and get
     */
    public List<Individual> lstIndividual{get;set;}
    /**
     * @description Vf page fetches the apps and sends to DSX
     */
    public BCB_FetchParticipantAndRenderAsPdf() {

        lstApps = new List<Application_Participant__c>();
        lstIndividual = new List<Individual>();
        lstApplications = new List<Application__c>();
        /**
        * @description Fetching the Participant with the id
        */   
        String participantId = ApexPages.CurrentPage().getparameters().get('id');
        lstApps= new SEL_ApplicationParticipant().selectApplicationParticpantById(participantId);
        lstApplications= new SEL_Application().selectAppsById(lstApps[0].Application__c);
        lstIndividual= new  SEL_Individual().findParticipantById( participantId);
   
    }
}