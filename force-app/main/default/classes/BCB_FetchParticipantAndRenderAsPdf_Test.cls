/**
 * @description Test Class for BCB_FetchParticipantAndRenderAsPdf vf page
 *
 *
 * @author yaswanth.tikkisetti@standardbank.co.za
 *
 * @date June 2022
 */
@isTest class BCB_FetchParticipantAndRenderAsPdf_Test {
    @isTest static  void bcbFetchParticipantAndRenderAsPdf() 
    {

        List<Application_Participant__c> app = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert app;
        ApexPages.CurrentPage().getparameters().put('id', app[0].Id);
        Test.startTest();
        BCB_FetchParticipantAndRenderAsPdf res = new BCB_FetchParticipantAndRenderAsPdf();
        Test.stopTest();
        Assert.areEqual(res.lstApps.size(), 1,'No of Apps should be 1');

    }
}