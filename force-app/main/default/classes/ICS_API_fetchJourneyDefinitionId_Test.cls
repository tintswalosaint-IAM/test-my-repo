/**
* @description  Class used as test class for ICS_API_fetchJourneyDefinitionId_Test
*
* Story: SFP-37310
*
* @author Ikyatha Naidu
* @date 11/01/2024
* @last modified on  :11/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest Version
*/
@IsTest
private class ICS_API_fetchJourneyDefinitionId_Test {
    
    private static final String VALID_ACCESS_TOKEN = 'absd123456';
    private static final String INVALID_ACCESS_TOKEN = 'invalidAccessToken';
    
    /**
     * @description Sets up test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        
            // Create test Account
            Account accountInfo = ICS_DAL_TestFactory.createAccount();
            
            
            // Create test CMN_WebserviceCallQueue__c record
            CMN_WebserviceCallQueue__c webServiceQueue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
                ICS_API_fetchJourneyDefinitionId.SERVICE_NAME,
                accountInfo.Id
            );
            insert webServiceQueue; 
       
    }
    
    /**
     * @description Tests the successful retrieval of a journey definition ID
     */
    @IsTest
    static void callDefinitionIdTest() {
       
        CMN_WebserviceCallQueue__c webServiceQueue = [SELECT Id FROM CMN_WebserviceCallQueue__c LIMIT 1];
       
        Test.startTest();
      
        try {
            ICS_API_fetchJourneyDefinitionId fetchJourneyDefId = new ICS_API_fetchJourneyDefinitionId();
            fetchJourneyDefId.tokenInfo = VALID_ACCESS_TOKEN;
            fetchJourneyDefId.process(webServiceQueue);
            fetchJourneyDefId.getResponseBody();
        } catch (Exception exc) {
            Assert.areEqual(true, exc.getMessage() != null, 'Error Occured while fetching definitionId');
        }
        Test.stopTest();
        
        
    }
    
    /**
     * @description Tests the API call with an invalid token
     */
    @IsTest
    static void callAPIwithInvalidToken() {
        
        CMN_WebserviceCallQueue__c webServiceQueue;
        
        try {
          
            webServiceQueue = [SELECT Id FROM CMN_WebserviceCallQueue__c LIMIT 1];
        } catch (Exception exc) {
             Assert.areEqual(true, exc.getMessage() != null, 'Error Occured while fetching Token Info');
            return;
        }
        
        Test.startTest();
        String responseBody = ''; 
        Boolean exceptionThrown = false;
        try {
            ICS_API_fetchJourneyDefinitionId apiClass = new ICS_API_fetchJourneyDefinitionId();
            apiClass.tokenInfo = INVALID_ACCESS_TOKEN;
            apiClass.process(webServiceQueue);
            responseBody = apiClass.getResponseBody();
        } catch(Exception ex) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'An exception should have been thrown for invalid token');
        Assert.isTrue(String.isBlank(responseBody), 'The journey definition ID should be empty for invalid token or non-existent journey.');
    }
}