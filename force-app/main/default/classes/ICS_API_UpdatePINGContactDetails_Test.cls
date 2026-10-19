/**
* @description  Class used  as test class for ICS_API_UpdatePINGContactDetails
*
* Story: SFP-31800
*
* @authon Ikyatha Naidu
* @date 15/05/2024
* @last modified on  :1/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest Version
*/
@istest
private class ICS_API_UpdatePINGContactDetails_Test { 
    Private static testMethod void callDefinitionIdTest(){
        Account accountObj = ICS_DAL_TestFactory.createAccount();
        test.starttest();
        ICS_API_UpdatePINGContactDetails updateService = new ICS_API_UpdatePINGContactDetails(); 
        updateService.conPingId='123456789';
        updateService.jsonData='{}';
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_UpdatePINGContactDetails.SERVICE_NAME,accountObj.id);
        updateService.process(obj);
        string conId = updateService.getResponseBody();
        Assert.areEqual(true,(conId !=null),'Contact updated');
        test.stoptest();
    }
}