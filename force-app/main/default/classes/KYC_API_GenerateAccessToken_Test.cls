/***************************************************************************************
@Name of the Class :KYC_API_GenerateAccessToken_Test
@Description :SFP-32817 Test Class for KYC_API_GenerateAccessToken
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@ISTEST
public class KYC_API_GenerateAccessToken_Test {
@IsTest
    
    /**
     * @description Test method for KYC_API_GenerateAccessToken
     */
    static void KYCAPIGenerateAccessTokenTest() {
        Test.startTest();
        KYC_API_GenerateAccessToken accessTokenServiceCall = new KYC_API_GenerateAccessToken('');
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_GenerateAccessToken.SERVICE_NAME);
        accessTokenServiceCall.process(obj);
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(accessTokenServiceCall.getResponseBody());
        Test.stopTest();
        Assert.areEqual('eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0xIiwicGkuYXRtIjoieHkwaCJ9.eyJzY3AiOltdLCJhdXRob3JpemF0aW9uX2RldGFpbHMiOltdLCJjbGllbnRfaWQiOiJiNzEyNThiNi00NzQwLTQxOTctYTc4OS05MDBhYmM2OGY3NzMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiNXk5NDhTQkVFZjdIZ040SERGMDFJTyIsInN1YiI6ImI3MTI1OGI2LTQ3NDAtNDE5Ny1hNzg5LTkwMGFiYzY4Zjc3MyIsIm5iZiI6MTcyNjA1MzM2MywiaWQiOiJiNzEyNThiNi00NzQwLTQxOTctYTc4OS05MDBhYmM2OGY3NzMiLCJpYXQiOjE3MjYwNTMzNjMsImV4cCI6MTcyNjA1Njk2M30.Ep-pWgIjU9jzzPEmJBi_wzQTkMIgd7Kv8tday9blwshG4xxDgGlccdqSmLAOBWq3jNQDR20sdI2--ZagBzwFLMhPTuhz2cY_0V2sZ1I81iWj7Ke99eWht17kmKHbrnft1c9G3v3TCiK94iiLOYB_4Wz3SDN8xAZH5f9ej3zFTNRjp4iFyNAex_W2FkgfXcJwZuv27BVXU31AwyAg56VYUU9Wv5Xy7Z_6ZD8_zwQm9cXptaEJISBlbvBanm3WXmya2t4a47pCKbi_NcCvMImQO7qH04wXXCYGphZ-Oc32M-9AQLadYlFqD9KL479VKotVuQNRe6p4I2iI3Ipjx_P2uA', (String) jsonMap.get('access_token'),'Excpected Value accessToken');

    }
}