/**
* @description  Class used  as test class for ICS_API_LoqateAddressRetrieve
*
* Story: SFP-33996 
*
* @authon Ikyatha Naidu
* @date 11/01/2024
* @last modified on  :1/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest Version 
*/
@isTest
private class ICS_API_LoqateAddressRetrieve_Test {
    @isTest
    static void testRetreiveAddress() {
       
        Account accountObj = ICS_DAL_TestFactory.createAccount();
         test.starttest();
        ICS_API_LoqateAddressRetrieve addressService = new ICS_API_LoqateAddressRetrieve('northStreet');
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_LoqateAddressRetrieve.SERVICE_NAME,accountObj.id);
        addressService.process(obj);
        string address = addressService.getResponseBody();
        Assert.areEqual(true,(address !=null),'address was retreived');
        test.stoptest();
       
    }
	@isTest
    static void testAddressFailed() {
        
        Account accountObj = ICS_DAL_TestFactory.createAccount();
        test.starttest();
        ICS_API_LoqateAddressRetrieve addressService = new ICS_API_LoqateAddressRetrieve('');
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_LoqateAddressRetrieve.SERVICE_NAME,accountObj.id);
        addressService.process(obj);
        string address = addressService.getResponseBody();
        Assert.areEqual(false,(address == null),'address was not  retreived');
        test.stoptest();
       
    }
    

}