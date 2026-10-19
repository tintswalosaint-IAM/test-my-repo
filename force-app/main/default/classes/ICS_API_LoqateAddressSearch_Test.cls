/**
* @description  Class used  as test class for ICS_API_LoqateAddressSearch
*
* Story: SFP-33996
*
* @author Ikyatha Naidu
* @date 11/01/2024
* @last modified on  :1/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest Version
*/
@istest
private class ICS_API_LoqateAddressSearch_Test { 
    @TestSetup
    static void makeData() {
     ICS_DAL_TestFactory.createAccount();
    }
    Private static testMethod void callDefinitionIdTest(){
       Account accountObj =[select id from account limit 1];
        test.starttest();
        ICS_API_LoqateAddressSearch searchAddress = new ICS_API_LoqateAddressSearch('IN','test','ContainerType');
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_LoqateAddressSearch.SERVICE_NAME,accountObj.id);
        searchAddress.process(obj);
        string address = searchAddress.getResponseBody();
        Assert.areEqual(true,(address !=null),'Searchaddress was retreived');
        test.stoptest();
    }
    @isTest
    static void testAddressSearchFailed() {
        Account accountObj=[select id from account limit 1];
       
        test.starttest(); 
        ICS_API_LoqateAddressSearch addressService = new ICS_API_LoqateAddressSearch('','','Container'); 
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_LoqateAddressRetrieve.SERVICE_NAME,accountObj.id);
        addressService.process(obj);
        string address = addressService.getResponseBody();
        Assert.areEqual(false,(address == null),'address was not  retreived');
        test.stoptest();
       
    }
}