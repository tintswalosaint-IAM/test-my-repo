/**
 * @description       : Test for PER_NBA_DataProvider
* @author            : Gul Aamir (CloudSmiths)
* @group             : PER: Personalisation
 * @last modified on  : 18-04-2024
 * @last modified by  : Derek Hughes
 * Helper classes     : APIMockResponseGenerator,PER_NBA_TestDataFactory
**/

@isTest
public with sharing class PER_NBA_DataProvider_Test {    

    @isTest
    private static void getActionsForPortfolioCodeTest() {
        User testUser = PER_NBA_TestDataFactory.insertTestUser();
        PER_NBA_TestDataFactory.createResponses('ZA');
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig(); 
        config.configCountryCode = 'ZA';
        config.declinedResponses = 'Decided not to action';

        System.runAs(testUser) {
            Test.startTest();
                PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
                rdp.setConfig(config);
                List<sbgpers.RecommendedAction> actions = rdp.getActionsForPortfolioCode(testUser.RM_AE_Code__c);
            Test.stopTest();
            
            Assert.areEqual(5, actions.size(), 'Expected 5 action records from the Mock response');
        }
    }

    @isTest
    private static void getActionsForPortfolioCodeWithAccTest() {
        User testUser = PER_NBA_TestDataFactory.insertTestUser();
        PER_NBA_TestDataFactory.createResponses('GB');
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig(); 
        config.configCountryCode = 'GB';
        config.declinedResponses = 'Decided not to action';

        // System.Test.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());

        System.runAs(testUser) {
            PER_NBA_TestDataFactory.createTestAccount();
            Test.startTest();
                PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
                rdp.setConfig(config);
                List<sbgpers.RecommendedAction> actions = rdp.getActionsForPortfolioCode(testUser.RM_AE_Code__c);
            Test.stopTest();

            Assert.areEqual(5, actions.size(), 'Expected 5 action records from the Mock response');
        }
    }

    @isTest
    private static void getActionsForClientExternalIdTest() {
        User testUser = PER_NBA_TestDataFactory.insertTestUser();
        PER_NBA_TestDataFactory.createResponses('ZA');
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig(); 
        config.configCountryCode = 'ZA';
        config.declinedResponses = 'Decided not to action';

        System.runAs(testUser) {
            PER_NBA_TestDataFactory.createTestAccount();
            Test.startTest();
                PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
                rdp.setConfig(config);
                List<sbgpers.RecommendedAction> actions = rdp.getActionsForClientExternalId('ZA01100001');
            Test.stopTest();

            Assert.areEqual(2, actions.size(), 'Expected 2 action records using the external Id from the Mock response');
        }
    }
    
    @isTest
    private static void getActionsForClientExternalIdNonZATest() {
        User testUser = PER_NBA_TestDataFactory.insertTestUser();
        PER_NBA_TestDataFactory.createResponses('GB');
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig(); 
        config.configCountryCode = 'GB';
        config.declinedResponses = 'Decided not to action';

        // System.Test.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());

        System.runAs(testUser) {
            PER_NBA_TestDataFactory.createTestAccount();
            Test.startTest();
                PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
                rdp.setConfig(config);
                List<sbgpers.RecommendedAction> actions = rdp.getActionsForClientExternalId('ZA01100001');
            Test.stopTest();

            Assert.areEqual(2, actions.size(), 'Expected 2 action records using the external Id from the Mock response');
        }
    }


    @isTest
    private static void updateActionCompleteTest() {
        User testUser = PER_NBA_TestDataFactory.insertTestUser();
        PER_NBA_TestDataFactory.createResponses('ZA');
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig(); 
        config.configCountryCode = 'ZA';
        config.declinedResponses = 'Decided not to action';
        sbgpers.RecommendedAction actionUpdated;

        System.runAs(testUser) {
            PER_NBA_TestDataFactory.createTestAccount();
            sbgpers.RecommendedAction action = PER_NBA_TestDataFactory.getRecommendedActionInstance();
            sbgpers.RecommendedActionResult actionResult = PER_NBA_TestDataFactory.getActionResultInstance();
            Test.startTest();
                PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
                rdp.setConfig(config);
                actionUpdated = rdp.updateActionComplete(action,actionResult);
            Test.stopTest();
        }
        Assert.areEqual('Completed', actionUpdated.status, 'The action was not updated to status "Completed"');
    }

    @isTest
    private static void updateActionDismissTest() {
        User testUser = PER_NBA_TestDataFactory.insertTestUser();
        PER_NBA_TestDataFactory.createResponses('GB');
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig(); 
        config.configCountryCode = 'GB';
        config.declinedResponses = 'Decided not to action';
        sbgpers.RecommendedAction actionUpdated;

        // System.Test.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new PER_API_NBA_Service_Test.MockSuccess());

        System.runAs(testUser) {
            PER_NBA_TestDataFactory.createTestAccount();
            sbgpers.RecommendedAction action = PER_NBA_TestDataFactory.getRecommendedActionInstance();
            sbgpers.RecommendedActionResult actionResult = PER_NBA_TestDataFactory.getActionResultInstance();
            Test.startTest();
                PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
                rdp.setConfig(config);
                actionUpdated = rdp.updateActionDismiss(action,actionResult);
            Test.stopTest();
        }
        Assert.areEqual('Dismissed', actionUpdated.status, 'The action was not updated to status "Dismissed"');
    }

    @isTest
    private static void notSupportedMethodsTest() { 
        sbgpers.RecommendedAction action = PER_NBA_TestDataFactory.getRecommendedActionInstance();
        PER_NBA_DataProvider rdp = new PER_NBA_DataProvider();
        Boolean exceptionSnooze = false;
        Boolean exceptionUnsnooze = false;
        Boolean exceptionOpportunity = false;
        Test.startTest();
            try{
                rdp.updateActionSnooze(action,'Test Reason',1);
            }
            catch(exception ex) {
                exceptionSnooze = true;
            }

            try{
                rdp.updateActionUnsnooze(action);
            }
            catch(exception ex){
                exceptionUnsnooze = true;
            }

            try{
                rdp.updateActionOpportunity(action,'TestId');
            }
            catch(exception ex){
                exceptionOpportunity = true;
            }
        Test.stopTest();
        Assert.isTrue(exceptionSnooze, 'updateActionSnooze method did not throw an exception');
        Assert.isTrue(exceptionUnsnooze, 'updateActionUnsnooze method did not throw an exception');
        Assert.isTrue(exceptionOpportunity, 'updateActionOpportunity method did not throw an exception');
    }
}