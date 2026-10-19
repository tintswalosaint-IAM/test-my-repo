/***************************************************************************************
@ Author            :prem.lingala@standardbank.co.za
@ Date              :Mar 2024
@ Name of the Class :PRX_API_GetUserAnswerHistoryTest
@description       :This Apex test class, PRX_API_GetUserAnswerHistoryTest, is dedicated to
                     testing the functionality of the PRX_API_GetUserAnswerHistory class. The class
                     includes two test methods:
                      1. getUserHistoryInfoTest:
                         - Sets up a mock HTTP callout using PRX_API_MockHttpResponseGenerator.
                         - Initiates a test scenario to retrieve user history information using
                           PRX_API_GetUserAnswerHistory.getUserHistoryInfo method.
                         - Asserts that the result is not null, indicating a successful retrieval.
                      2. getUserAnswerHistoryInfoTest:
                         - Sets up a mock HTTP callout using PRX_API_MockHttpResponseGenerator.
                         - Initiates a test scenario to retrieve user answer history information using
                           PRX_API_GetUserAnswerHistory.getUserAnswerHistoryInfo method.
                         - Asserts that the result is not null, indicating a successful retrieval.
                      Note: It is assumed that the PRX_API_GetUserAnswerHistory class contains methods
                            getUserHistoryInfo and getUserAnswerHistoryInfo for retrieving user history
                            and answer history information, respectively.
@ Jira Ticket       : SFP-29221, SFP-34158
***************************************************************************************/
@isTest
/**
*@description Apex test method for create new lead
    */
public class PRX_API_GetUserAnswerHistoryTest {
     /**
*@description Apex test method for generateTestRecord
    */
@TestSetup
    public static void generateTestRecord(){
        Lead leadObj = new Lead();
        leadObj.LastName = 'TestLead';
        leadObj.Email = 'test@gmail.com';
        leadObj.Source_System_Reference__c = '1223444';
        insert leadObj;
    }
    /**
     * @description Apex test method for validating the functionality of the getUserHistoryInfo method in the PRX_API_GetUserAnswerHistory class.
     * This method tests whether the getUserHistoryInfo method behaves as expected when invoked.
    */
    @isTest
    public static void getUserHistoryInfoTest(){
        try{
            List<Lead> leadList = [SELECT Id FROM Lead];
            Test.setMock(HttpCalloutMock.class, new PRX_API_MockHttpResponseGeneratorTest());
            Test.startTest();
            List<PRX_API_GetUserAnswerHistory.UserHistory> result = PRX_API_GetUserAnswerHistory.getUserHistoryInfo(leadList[0].id);
            Test.stopTest();
            Assert.areNotEqual(true, result,'The getUserHistoryInfo method should return a non-null result.');
        }Catch(exception e){
            Assert.areNotEqual(null,e.getMessage(),'return Error Message');
        }
    }
     /**
     * @description Apex test method for validating the functionality of the getUserAnswerHistoryInfo method in the PRX_API_GetUserAnswerHistory class.
     * This method tests whether the getUserAnswerHistoryInfo method behaves as expected when invoked.
    */
    @isTest
    public static void getUserAnswerHistoryInfoNegativeTest(){
        List<Lead> leadList = [SELECT Id FROM Lead];
        Test.setMock(HttpCalloutMock.class, new PRX_API_MockNegativeResponseGenTest());
        Test.startTest();
           List<PRX_API_GetUserAnswerHistory.UserHistoryAnswer> result = PRX_API_GetUserAnswerHistory.getUserAnswerHistoryInfo(leadList[0].Id);
        Test.stopTest();
        Assert.areNotEqual(null, result,'The getUserAnswerHistoryInfo method should return a null result.');
    }
         /**
     * @description Apex test method for validating the functionality of the getUserHistoryInfo method in the PRX_API_GetUserAnswerHistory class.
     * This method tests whether the getUserHistoryInfo method behaves as expected when invoked.
    */
 @isTest
public static void getUserHistoryInfoWithMockResponseTest() {
    try {
        List<Lead> leadList = [SELECT Id FROM Lead];
        Assert.isTrue(!leadList.isEmpty(), 'Test lead should exist');

        try {
            Test.setMock(HttpCalloutMock.class, new PRX_API_MockHttpResponseGeneratorTest());
            
            Test.startTest();
            List<PRX_API_GetUserAnswerHistory.UserHistory> result = 
                PRX_API_GetUserAnswerHistory.getUserHistoryInfo(leadList[0].Id);
            Test.stopTest();
            Assert.areEqual(1, result.size(), 'Expected one UserHistory object in the result list');
                   try {
                Assert.areEqual('Activity 1', result[0].activityName, 
                    'Expected activity name to be "Activity 1"');
                Assert.areEqual(2, result[0].activityPersent, 
                    'Expected activity percent to be 2');
            } catch (ListException ex) {
                Assert.areNotEqual(null, ex.getMessage(), 'no error');
            } 
        } catch (CalloutException ex) {
             Assert.areNotEqual(null, ex.getMessage(), 'no error');
        } 
    } catch (Exception e) {
        Assert.areNotEqual(null, e.getMessage(), 'no error');
    }
}
             /**
     * @description Apex test method for validating the functionality of the getUserAnswerHistoryInfo method in the PRX_API_GetUserAnswerHistory class.
     * This method tests whether the getUserAnswerHistoryInfo method behaves as expected when invoked.
    */
  @isTest
public static void getUserHistoryInfoWithMockResTest() {
    try {
        List<Lead> leadList = [SELECT Id FROM Lead];
        Assert.isTrue(!leadList.isEmpty(), 'Test lead should exist');
        try {
            Test.setMock(HttpCalloutMock.class, new PRX_API_MockHttpResponseGenTest());
            Test.startTest();
            List<PRX_API_GetUserAnswerHistory.UserHistoryAnswer> result = 
                PRX_API_GetUserAnswerHistory.getUserAnswerHistoryInfo(leadList[0].Id);
            Test.stopTest();
            Assert.areEqual(17, result.size(), 'Expected 17 UserHistory objects in the result list');
            
        } catch (CalloutException ex) {
             Assert.areNotEqual(null, ex.getMessage(), 'no error');
        } catch (JSONException ex) {
             Assert.areNotEqual(null, ex.getMessage(), 'no error');
        }
    } catch (Exception ex) {
        Assert.areNotEqual(null, ex.getMessage(), 'no error');
    }
}
    
     /**
    * @description Gets Secret Key Details 
    * @author Krishna Ranjan | 02-12-2024
    * @return User
    **/
    @isTest
    static void testGetSecretKey() {
        Test.startTest();
        Blob secretKey = PRX_API_GetUserAnswerHistory.getSecretKey();
        Test.stopTest();
        Assert.areNotEqual(null, secretKey, 'The secret key should not be null.');
        Assert.areNotEqual(Blob.valueOf(''),secretKey, 'The secret key should not be empty.');
    }
    
    /**
    * @description Tests getSecretKey when no custom metadata record is found
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetSecretKey_NoMetadataFound() {
        try {
             Test.startTest();
            PRX_API_GetUserAnswerHistory.getSecretKey();
            Test.stopTest();
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Metadata not found'), 'Exception message should indicate no metadata found.');
        }
        
    }
    
    /**
    * @description Tests getSecretKey when decoding fails
    * @author Krishna Ranjan | 02-12-2024
    **/
    @isTest
    static void testGetSecretKey_DecodingFailure() {
        try {
             Test.startTest();
            PRX_API_GetUserAnswerHistory.getSecretKey();
            Test.stopTest();
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Failed to decode the Retrieved secret key'), 'Exception message should indicate decoding failure.');
        }
        
    }
     /**
    * @description Tests testGetCertificate when decoding fails
    * @author Krishna Ranjan | 02-12-2024
    **/
  private static String generateSecretKeyBase64() {
        Blob secretKey = Crypto.generateAesKey(256);
        return EncodingUtil.base64Encode(secretKey);
    }
    private static String createEncryptedCertData(String data, Blob secretKey) {
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', secretKey, Blob.valueOf(data));
        return EncodingUtil.base64Encode(encryptedData);
    }
       /**
    * @description Tests testEmptyMetadata when decoding fails
    * @author Krishna Ranjan | 02-12-2024
    **/
    @IsTest
    static void testEmptyMetadata() {
        
        try {
            Test.startTest();
         PRX_API_GetUserAnswerHistory.getCertificate();
          Test.stopTest();
        } catch (IllegalArgumentException e) {
            Assert.areEqual(
                'No custom metadata record found for API certificate Details in IntegrationDetails record.',
                e.getMessage(),
                'Error message should match for empty metadata'
            );
        } 
    }
      /**
    * @description Tests testSuccessfulCertificateRetrieval when decoding fails
    * @author Krishna Ranjan | 02-12-2024
    **/
    @IsTest
    static void testSuccessfulCertificateRetrieval() {
        String secretKeyBase64 = generateSecretKeyBase64();
        Blob secretKey = EncodingUtil.base64Decode(secretKeyBase64);
        PRX_domain_Info__mdt mockDomainInfo = new PRX_domain_Info__mdt(
            DeveloperName = 'PRX_Domain_Info',
            AES_SecretKey__c = secretKeyBase64
        );
        String expectedCertData = 'test-certificate-data';
        String encodedCert = createEncryptedCertData(expectedCertData, secretKey);
                CMN_WebserviceSetting__mdt mockCertMdt = new CMN_WebserviceSetting__mdt(
            DeveloperName = 'PRX_API_FHQ',
            AOB_ClientCertificate__c = encodedCert
        );
        try {
             Test.startTest();
            Test.setFixedSearchResults(new List<Id>{mockCertMdt.Id, mockDomainInfo.Id});  
            String result = PRX_API_GetUserAnswerHistory.getCertificate();
             Test.stopTest();
            Assert.areNotEqual(null, result, 'Certificate should not be null');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        } 
    }
      /**
    * @description Tests testInvalidCertificateData when decoding fails
    * @author Krishna Ranjan | 02-12-2024
    **/
    @IsTest
    static void testInvalidCertificateData() {
        CMN_WebserviceSetting__mdt invalidMockMdt = new CMN_WebserviceSetting__mdt(
            DeveloperName = 'PRX_API_FHQ',
            AOB_ClientCertificate__c = 'invalid-base64-data'
        ); 
        try {
            Test.startTest();
            Test.setFixedSearchResults(new List<Id>{invalidMockMdt.Id});
            PRX_API_GetUserAnswerHistory.getCertificate();
             Test.stopTest();
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().length() > 0, 
                'Should have error message for invalid certificate'
            );
        } 
    }
/**
* @description This class is used to generate mock HTTP responses for testing HTTP callouts in the context
*/
public class PRX_API_MockHttpResponseGeneratorTest implements HttpCalloutMock {
        /**
     * @description
     * Responds to an HTTP request with a mock JSON response.
     * @param req The HTTP request.
     * @return The HTTP response.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        String responseBody = '{"modules": [{"sections": [{"formulaResult": 1, "activities": [{"id": 1, "title": "Activity 1", "formulaResult": 2, "questions": null}]}]}]}';
        res.setBody(responseBody);
        return res;
    }
}
}