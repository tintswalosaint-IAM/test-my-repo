/**
 * @description       : Test class for CMN_API_GetAccessToken
 * @author            : Derek Hughes
 * @group             : Test Class
 * @last modified on  : 21-08-2023
 * @last modified by  : Derek Hughes
**/
@IsTest(SeeAllData=false)
public with sharing class CMN_API_GetAccessToken_Test {

    @isTest
    private static void testGetToken() {
        
        Boolean errorCaught1 = false;
        Boolean errorCaught2 = false;

        Test.startTest();
            CMN_DTO_AuthenticationResponse response1 = CMN_API_GetAccessToken.getPingToken();
            CMN_DTO_AuthenticationResponse response2 = CMN_API_GetAccessToken.getAccessToken('api');

            CMN_API_GetAccessToken.simulateError = true;
            try {
                CMN_DTO_AuthenticationResponse responseError1 = CMN_API_GetAccessToken.getPingToken();
            }
            catch (Exception e) {
                errorCaught1 = true;
            }
            try {
                CMN_DTO_AuthenticationResponse responseError2 = CMN_API_GetAccessToken.getAccessToken('api') ;
            }
            catch (Exception e) {
                errorCaught2 = true;
            }

        Test.stopTest();
        
        Assert.isNotNull(response1, 'Response should not be null');
        Assert.isNotNull(response2, 'Response should not be null');
        Assert.isTrue(errorCaught1, 'No exception was thrown');
        Assert.isTrue(errorCaught2, 'No exception was thrown');
    } 
    
}