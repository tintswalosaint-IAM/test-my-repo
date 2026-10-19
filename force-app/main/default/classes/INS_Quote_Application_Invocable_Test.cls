/**
 * @description       : SFP-26913 Test class of INS_Quote_Application_Invocable Invocable Class to generate and send OTP to the Customer
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
@isTest(seeallData = false)
public class INS_Quote_Application_Invocable_Test {
    
/**
 * @description       : SFP-26913 Test method to make the fake callouts
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
    @isTest
    public static void testSendOTPPass(){
        
        Map<String, String> accesTokenResponseHeaders = new Map<String, String>();
        accesTokenResponseHeaders.put('X-IBM-Client-Id','{!$Credential.INS_Generate_OTP.Client_Id}');
        accesTokenResponseHeaders.put('x-ibm-client-secret','{!$Credential.INS_Generate_OTP.Client_Secret}');
        accesTokenResponseHeaders.put('Content-Type','application/x-www-form-urlencoded');
        
        INS_Quote_Application_SingleRequestMock fakeAccessToken = new INS_Quote_Application_SingleRequestMock(
            200,
            'Complete',
            '{"access_token":"fakeToken"}',
            accesTokenResponseHeaders
        );
        INS_Quote_Application_SingleRequestMock fakeGenerateOTP = new INS_Quote_Application_SingleRequestMock(
            200, 
            'Complete', 
            '{"statusDescription":"Token generation successful"}', 
            null);

        Map<String, HttpCalloutMock> endpointsToTest = new Map<String, HttpCalloutMock>();
        endpointsToTest.put('callout:INS_Generate_and_Validate_OTP/ug/oauth2/token', fakeAccessToken);
        endpointsToTest.put('callout:INS_Generate_and_Validate_OTP/simple-mandate/v1.0/create-otp', fakeGenerateOTP);
        HttpCalloutMock multiCalloutMock = new INS_Quote_Application_MockHttpResponse(endpointsToTest);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        List<String> accountNumberList = new List<String>();
        accountNumberList.add('fakeAccountNumber');

        Test.startTest();
        INS_Quote_Application_Invocable.sendOTP(accountNumberList);
        Assert.areNotEqual(null, multiCalloutMock, 'multiCalloutMock is null');
        Test.stopTest();
    }
   
}