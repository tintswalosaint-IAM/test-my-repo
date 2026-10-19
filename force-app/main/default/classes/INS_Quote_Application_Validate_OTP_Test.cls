/**
 * @description       : SFP-26913 Test Class of INS_Quote_Application_Validate_OTP invocable class to validate OTP
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
@isTest(seeallData = false)
public class INS_Quote_Application_Validate_OTP_Test {

/**
 * @description       : SFP-26913 Test Method of INS_Quote_Application_Validate_OTP invocable class to validate OTP
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
    @isTest
    public static void testValidateOTPPass(){
        
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
        INS_Quote_Application_SingleRequestMock fakeValidateOTP = new INS_Quote_Application_SingleRequestMock(
            200, 
            'Complete', 
            '{"statusDescription":"Token validation successful"}', 
            null);

        Map<String, HttpCalloutMock> endpointsToTest = new Map<String, HttpCalloutMock>();
        endpointsToTest.put('callout:INS_Generate_and_Validate_OTP/ug/oauth2/token', fakeAccessToken);
        endpointsToTest.put('callout:INS_Generate_and_Validate_OTP/simple-mandate/v1.0/check-otp', fakeValidateOTP);
        HttpCalloutMock multiCalloutMock = new INS_Quote_Application_MockHttpResponse(endpointsToTest);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        List<String> returnedResponse = new List<String>();
        returnedResponse.add('000000000,fakeAccountName,5236445212,fakeStatusCode,fakeStatudMessage,fakeRequestId,fakeOTPCode');


        Test.startTest();
        INS_Quote_Application_Validate_OTP.validateOTP(returnedResponse);
        Assert.areNotEqual(null,multiCalloutMock,'multiCalloutMock is NULL.');
        Test.stopTest();
    }
}