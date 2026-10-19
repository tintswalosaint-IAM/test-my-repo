/***************************************************************************************
@ Author            :Amarnath reddy
@ Date              :July 2022
@ Name of the Class :AOB_FetchAppAndRenderAsPdf_Test
@description       :Test Class for AOB_FetchAppAndRenderAsPdf apex class
@ Last Modified By  :Jagadish thummala
@ Last Modified On  :14-09-2023
@ Modification description : SFP-29804
***************************************************************************************/

@isTest class AOB_FetchAppAndRenderAsPdf_Test {
    @isTest static  void aobFetchAppAndRenderTest() 
    {

        List<Application__c> app = AOB_TestDataFactory.createApplication(1);
        insert app;
        ApexPages.CurrentPage().getparameters().put('id', app[0].Id);
        Test.startTest();
        AOB_FetchAppAndRenderAsPdf res = new AOB_FetchAppAndRenderAsPdf();
        Test.stopTest();
        Assert.areEqual(res.lstApps.size(), 1,'No of Apps should be 1');

    }


    @isTest static  void aobFetchAppAndRenderTest1() 
    {
        List<Application__c> app = AOB_TestDataFactory.createApplication(1);
        insert app;
        Application__c app1 = new SEL_Application().selectAppById(app[0].id);
        List<Application__c> app2 =  new SEL_Application().selectApplicationById(new list<id>{app[0].id});
        Assert.areNotEqual(null, 1,'No of Apps should be 1');
        Assert.areNotEqual(app2, null);
    }
}