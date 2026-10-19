/***************************************************************************************
@ Author            :Amarnath reddy
@ Date              :July 2022
@ Name of the Class :AOB_FetchAppAndRenderAsPdf
@description       :Class for fetching data to create a visualforce page
@ Last Modified By  :Jagadish thummala
@ Last Modified On  :14-09-2023
@ Modification description : SFP-29804
***************************************************************************************/

public without sharing class AOB_FetchAppAndRenderAsPdf {

    /**
     * @description Vf pagelist of applications for set and get
     */
    public List<Application__c> lstApps{get;set;}
    /**
     * @description Vf page fetches the apps and sends to DSX
     */
    public AOB_FetchAppAndRenderAsPdf() {

        lstApps = new List<Application__c>();
        /**
        * @description Fetching the applications with the id
        */   
        String applicationId = ApexPages.CurrentPage().getparameters().get('id');
        lstApps= new SEL_Application().selectAppsById(applicationId);

    }
}