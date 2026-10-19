/***************************************************************************************

@Name of the Component : SEL_RecommededAction_Test
@Description : Test Class for SEL_RecommendedAction.
@Author : Kenneth Dlamini
@Created Date : 2024-09-22
/***************************************************************************************
@Last Modified By : Kenneth Dlamini
@Last Modified On : 2025-07-25
@Modification description: SFP-36986, SFP-36989
***************************************************************************************/
@isTest
public class SEL_RecommendedAction_Test {
    @testSetup
    static void setupData(){
        User testUser = LoadSalesforceOffersTestDataFactory.createTestUser(1);   
        Account testAccount = LoadSalesforceOffersTestDataFactory.createTestAccount(testUser);
        LoadSalesforceOffersTestDataFactory.createTestCase(testUser, testAccount);
        LoadSalesforceOffersTestDataFactory.loadClientOffers(testUser, testAccount);
    }

    @IsTest
    static void verifyTestCaseCreationRecord(){
        List<Case> retrieveTestCases = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
        Assert.areEqual(1, retrieveTestCases.size(), 'Successful.');
    }

    @isTest
    static void selectTop3Recommendations(){
        SEL_RecommendedAction recommendation = new SEL_RecommendedAction();
        Case testCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
        List<sbgpers__Recommended_Action__c> top3Offers = recommendation.selectRecommendedActionsByCaseId(testCase.Id);
        Assert.areEqual(3, top3Offers.size(), 'Successful.');
    }

    @isTest
    /**
     * @description Select all available recommended actions for the client that have been actioned.
     * @author Kenneth Dlamini | 2024-OCt-04
     * @param recordId
     * @return List<sbgpers__Recommended_Action__c>
     **/
    static void selectAllRecommendationsByAccId(){
        SEL_RecommendedAction recommendation = new SEL_RecommendedAction();
        Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com']; 
        List<sbgpers__Recommended_Action__c> allOffers = recommendation.selectRecommendedActionsByAccountId(accInfo.Id);
        Assert.areEqual(0, allOffers.size(), 'Successful.');
    }

    @isTest
    static void selectTop3RecommendationsByAccId(){
        SEL_RecommendedAction recommendation = new SEL_RecommendedAction();
        Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com']; 
        List<sbgpers__Recommended_Action__c> top3Offers = recommendation.selectTop3RecommendedActionsByAccountId(accInfo.Id);
        Assert.areEqual(3, top3Offers.size(), 'Successful.');
    }

    @isTest
    static void selectRecommendatonDetails(){
        SEL_RecommendedAction recommendation = new SEL_RecommendedAction();
        Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com'];    
        sbgpers__Recommended_Action__c offerRecord = [SELECT Id FROM sbgpers__Recommended_Action__c
            WHERE sbgpers__Account__c =: accInfo.Id LIMIT 1]; 
        sbgpers__Recommended_Action__c sfOffersRecordDetails = recommendation.selectRecommendedActionById(offerRecord.Id);
        Assert.areEqual(offerRecord.Id, sfOffersRecordDetails.Id, 'Successful.');
    }

    @isTest
    static void selectExpiredRecommendations(){
        SVC_ClientRecommendationEngineSettings__mdt customSettings = SVC_ClientRecommendationEngineSettings__mdt.getInstance('SVC_LineItemsPerClient');
        String systemId = customSettings.SVC_System_ID__c;
        DateTime currentDateTime = Date.today();
        Date currentDate = Date.valueOf(currentDateTime.format('yyyy-MM-dd'));
        List<sbgpers__Recommended_Action__c> expiredOffers = [SELECT Id, 
          sbgpers__Category__c
          FROM sbgpers__Recommended_Action__c
          WHERE sbgpers__External_System_Id__c =: systemId
          AND sbgpers__Valid_Until__c <=:currentDate ];
        Assert.areEqual(1, expiredOffers.size(), 'Successful.');
    }
}