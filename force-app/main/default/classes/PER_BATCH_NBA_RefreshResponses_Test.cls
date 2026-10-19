/**
 * @description       : Test for the PER_BATCH_NBA_RefreshREsponses calss.
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 18-04-2024
 * @last modified by  : Derek Hughes
**/
@IsTest(seeAllData=false)
public with sharing class PER_BATCH_NBA_RefreshResponses_Test {

    @isTest
    private static void testBatch() {

        // 2 should be retained and 2 should be deleted
        PER_NBA_TestDataFactory.createResponses('UG'); 

        // these should not be affected by the update for Uganda
        PER_NBA_TestDataFactory.createResponses('NA'); 

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());

        Test.startTest();
            
            PER_BATCH_NBA_RefreshResponses.run();

        Test.stopTest();

        List<sbgpers__Recommended_Action_Response__c> ugResponses2 = [SELECT Id, Name FROM sbgpers__Recommended_Action_Response__c WHERE sbgpers__Country_Code__c='UG']; 
        List<sbgpers__Recommended_Action_Response__c> naResponses2 = [SELECT Id, Name FROM sbgpers__Recommended_Action_Response__c WHERE sbgpers__Country_Code__c='NA']; 

        Assert.areEqual(5, ugResponses2.size(), 'Incorrect number of UG response');
        Assert.areEqual(4, naResponses2.size(), 'Incorrect number of NA reponses');

    }

}