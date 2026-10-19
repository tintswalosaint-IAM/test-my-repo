/**
* @description  Class used  as test class for ICS_API_GenerateTokenGBG
*
* Story: SFP-37310
*
* @authon Ikyatha Naidu
* @date 11/01/2024
* @last modified on  :1/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest Version
*/
@isTest
private class ICS_API_GenerateTokenGBG_Test {
    @isTest
    static void testGetToken() {
          Account accountObj = ICS_DAL_TestFactory.createAccount();
        test.starttest();
        ICS_API_GenerateTokenGBG tokenService = new ICS_API_GenerateTokenGBG();
        tokenService.accountId = accountObj.id;
        tokenService.getQRInfo = false;
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateTokenGBG.SERVICE_NAME,accountObj.id);
        tokenService.process(obj);
        string qrCode = tokenService.getResponseBody();
        Assert.areEqual(true,(qrCode !=null),'token was retreived');
        test.stoptest();
       
    }

    

}