/***************************************************************************************
@Name of the Class : BCB_FetchAppAndRenderAsPdf_Test
@description       : Test Class for BCB_FetchAppAndRenderAsPdf vf page.
@Author            : yaswanth.tikkisetti@standardbank.co.za 
@Date              : June 2022
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 04-04-2024
@Modification Description : SFP-37302
***************************************************************************************/
@isTest class BCB_FetchAppAndRenderAsPdf_Test {
    @isTest static  void bcbFetchAppAndRenderTest() 
    {

        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        insert app;
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].Application__c=app[0].id;
        insert lstApp;
        Individual ind = BCB_DAL_TestFactory.createIndividual();
        ind.Application_Participant__c = lstApp[0].id;
        insert ind;
        ApexPages.CurrentPage().getparameters().put('id', app[0].Id);
        Test.startTest();
        BCB_FetchAppAndRenderAsPdf res = new BCB_FetchAppAndRenderAsPdf();
        Test.stopTest();
       Assert.areEqual(res.lstApps.size(), 1,'No of Apps should be 1');

    }
}