/***************************************************************************************
@Name of the Class :KYC_SRV_GenerateAccessToken_Test
@Description :SFP-32170 Test Class for KYC_SRV_GenerateAccessToken
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_SRV_GenerateAccessToken_Test {
    /**
     * @description Test method for getAccessToken
     */
    @isTest
    static void getAccessTokenTest() {
        Test.startTest();
        String access_token =  KYC_SRV_GenerateAccessToken.getAccessToken();
        Test.stopTest();
        Assert.isNotNull(access_token, 'access_token not null');
    }
    
    /**
     * @description Test method for getAccessToken
     */
    @isTest
    static void getAccessTokenNegTest() {
        try{
            Test.startTest();
            KYC_API_GenerateAccessToken.isFailed=false;
            KYC_SRV_GenerateAccessToken.getAccessToken();
            Test.stopTest();
        }Catch(exception ex){
             Assert.AreEqual('Script-thrown exception',ex.getMessage(),'Expected Script thrown Expection');
        }
    }
}