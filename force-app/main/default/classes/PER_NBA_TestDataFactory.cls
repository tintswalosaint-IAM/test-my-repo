/**
 * @description       : Test Data Factor for PER NBA Data Provider
 * @author            : Derek Hughes
 * @group             : PER: Personalisation
 * @last modified on  : 05-03-2024
 * @last modified by  : Derek Hughes
**/
@isTest
public with sharing class PER_NBA_TestDataFactory {
    
    public static  user insertTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testuser',
            Email='testuser@test.test',
            EmailEncodingKey='UTF-8',
            LastName='Test User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey='Europe/Berlin',
            Username='test.user.dev@stdb.chnwrmdev',
            RM_AE_Code__c = '0054321');
        insert testUser;
        return testUser;
    }

    public static Account createTestAccount() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.ExternalCIFId__c = '100001';
        testAccount.RelationshipMgrCode__c = '0054321';
        testAccount.ExternalIdentifier__c = 'ZA01100001';
        insert testAccount;
        return testAccount;
    }

    public static sbgpers.RecommendedAction getRecommendedActionInstance() {
        sbgpers.RecommendedAction action = new sbgpers.RecommendedAction();
        action.accountId = null;
        action.accountName = 'Test Customer';
        action.CountryCode = 'GB';
        action.category = 'Customer Retention';
        action.subCategory = 'Dormant Account';
        action.portfolioCode = 'GB007';
        action.details = 'Please call your customer as their account has become dormant';
        action.clientCIF = '90021777';
        action.clientName = 'Test Customer' + '*';
        action.nextSteps = 'These are your next steps';
        action.identifier = 'ID00001';
        action.validFrom= Date.today(); 
        action.validUntil = Date.today(); 
        return action;
    }

    public static sbgpers.RecommendedActionResult getActionResultInstance() {
        sbgpers.RecommendedActionResult actionResult = new sbgpers.RecommendedActionResult();
        actionResult.recordId = null;
        actionResult.identifier = 'ID00001';
        actionResult.response = 'Test Response';
        actionResult.reason = 'Test Reason';
        actionResult.notes = 'Test Notes';
        return actionResult;
    }

    public static List<sbgpers__Recommended_Action_Response__c> createResponses(String countryCode) {

        List<sbgpers__Recommended_Action_Response__c> newResponses = new List<sbgpers__Recommended_Action_Response__c>();

        newResponses.add(new sbgpers__Recommended_Action_Response__c(
            sbgpers__Country_Code__c = countryCode,
            sbgpers__Category__c = 'Customer Retention',
            sbgpers__Sub_Category__c = 'Customer Retention',
            sbgpers__Response__c = 'Could not discuss with client',
            sbgpers__Reason__c = 'Never contact client again'
        ));

        newResponses.add(new sbgpers__Recommended_Action_Response__c(
            sbgpers__Country_Code__c = countryCode,
            sbgpers__Category__c = 'Customer Retention',
            sbgpers__Sub_Category__c = 'Customer Retention',
            sbgpers__Response__c = 'Follow-up Required',
            sbgpers__Reason__c = 'Client not available'
        ));

        
        newResponses.add(new sbgpers__Recommended_Action_Response__c(
            sbgpers__Country_Code__c = countryCode,
            sbgpers__Response__c = 'Action completed',
            sbgpers__Reason__c = 'Product taken up'
        ));

          
        newResponses.add(new sbgpers__Recommended_Action_Response__c(
            sbgpers__Country_Code__c = countryCode,
            sbgpers__Response__c = 'Action completed',
            sbgpers__Reason__c = 'Product NOT taken up'
        ));
                
        insert newResponses;
        return newResponses;
    }

}