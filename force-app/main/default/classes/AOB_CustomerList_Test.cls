/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_NIRA
@ Description       : Test class to cover AOB_CustomerList.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/**
    * @description Test class to cover AOB_CustomerList
    *
    */
@isTest
public class AOB_CustomerList_Test {
    /**
    * @description TestMethod to check the Arguments
    *
    */
    @isTest
    static void nullArgumentCheck(){
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        test.startTest();
        try{ 
            Lead ld1 = new lead(lastname ='test');     
            List<Lead> ldList1 = new List<Lead>{ld1};      
            AOB_CustomerList.invokeCustomerList(ldList1);             
        }catch(exception e){
            Assert.areEqual(e.getMessage().contains('Argument cannot be null'), true, 'It will show result');
        }
        test.stopTest();
    }
    /**
    * @description TestMethod to check the  customer List and failed status 
    *
    */
    @isTest
    static void customerListStatusCheck(){
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;
        List<Lead> ldList = new List<Lead>{ld};
        String str='{"customers":[{"uuid":"10300460267","accountNumber":"823565","status":"SUCCESS","prominentInfluentialPerson":{"relationType":{}},"personDetails":{"firstName":"DAVID","citizenshipCountry":{}},"addresses":[{"line1":"NYABUHIKYE TRADING CENTER","addressTypes":[{"addressType":"Mailing","startDate":"2007-10-12T00:00:00.000","endDate":"2099-12-31T00:00:00.000"}],"city":"NYABUHIKYE TRADING CENTER","countryCode":"NYABUHIKYE TRADING CENTER"}],"identifications":[{"issuingCountry":"UG","documentCode":"D0001"}]}]}';
        AOB_CustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerList.mockHttpStatus ='OK';
        AOB_CustomerList.mockHttpBody = str;
        test.startTest();
        String repStatus = AOB_CustomerList.invokeCustomerList(ldList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will show status');
    }
    /**
      * @description TestMethod to check the  customer List and SUCCESS status 
    *
    */
    @isTest
    static void customerListStatusCheckSuccess(){
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;
        List<Lead> ldList = new List<Lead>{ld};
        String str='{"customers":[{"uuid":null,"accountNumber":"823565","status":"SUCCESS","prominentInfluentialPerson":{"relationType":{}},"personDetails":{"firstName":"DAVID","citizenshipCountry":{}},"addresses":[{"line1":"NYABUHIKYE TRADING CENTER","addressTypes":[{"addressType":"Mailing","startDate":"2007-10-12T00:00:00.000","endDate":"2099-12-31T00:00:00.000"}],"city":"NYABUHIKYE TRADING CENTER","countryCode":"NYABUHIKYE TRADING CENTER"}],"identifications":[{"issuingCountry":"UG","documentCode":"D0001"}]}]}';
        AOB_CustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerList.mockHttpStatus ='OK';
        AOB_CustomerList.mockHttpBody = str;
        test.startTest();
        String repStatus = AOB_CustomerList.invokeCustomerList(ldList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will show status');
    }
    /**
    * @description TestMethod to check the server error case.
    *
    */
      @isTest
      static void customerListStatusCheckFailedServerError(){
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;
        List<Lead> ldList = new List<Lead>{ld};
        AOB_CustomerList.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerList.mockHttpStatus ='OK';
        AOB_CustomerList.mockHttpBody = null;
        test.startTest();
        String repStatus = AOB_CustomerList.invokeCustomerList(ldList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();
        Assert.areEqual((String)m.get('status'), 'NO_CONTENT', 'It will show status');
    }
    /**
    * @description TestMethod to check the exception 
    *
    */
    @isTest
      static void customerListNullCheck(){
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;
        List<Lead> ldList = new List<Lead>{ld};
        AOB_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerList.mockHttpStatus = 'OK';
        AOB_CustomerList.mockHttpbody = '';
        test.startTest();
        try {
            AOB_CustomerList.invokeCustomerList(ldList);
        } catch(Exception e) {
            Assert.areEqual(e.getMessage().contains('Attempt to de-reference a null object'), 'FAILED','Exception Handling Check');
        }
        test.stopTest();
    }
}