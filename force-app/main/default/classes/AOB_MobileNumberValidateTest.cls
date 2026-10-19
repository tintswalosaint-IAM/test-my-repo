/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_NIRA
@ Description       : Test Class for AOB_MobileNumberValidate
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/**
* @description Test Class for AOB_MobileNumberValidate
*/
@isTest
public class AOB_MobileNumberValidateTest {
    /**
    * @description TestMethod to check the Status Description if successful
    *
    */
    @istest static void testDescriptionSuccessful(){    
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList; 
        String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"0","Description":"Successful"},"Resultz":{"CustomerReference":"256782793556","Area":"WALLET","StatusCode":"0","StatusDescription":"ACTIVE","CustomerName":"DENNIS  STANLEY MBOGO","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
        AOB_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_MobileNumberValidate.mockHttpStatus='OK';
        AOB_MobileNumberValidate.mockHttpbody=str;
        Test.startTest();
        String resultList = AOB_MobileNumberValidate.invokeMobileNumberCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();  
       Assert.areEqual((String)m.get('Description'), 'Successful','It will show status');
    }
    /**
    * @description TestMethod to check the StatusDescription if FAILED due to server error
    *
    */
    @istest static void testServerErrorState(){    
      
        List<Application__c>appList=AOB_TestDataFactory.createApplication(1);
        insert appList; 
        String str='{"httpCode": "401","httpMessage": "Unauthorized","moreInformation": "Client certificates for application authentication are missing in the API request."}'; 
        AOB_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_MobileNumberValidate.mockHttpStatus='Ok';
        AOB_MobileNumberValidate.mockHttpbody= str;
        Test.startTest();
        String resultList = AOB_MobileNumberValidate.invokeMobileNumberCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();  
       Assert.areEqual((String)m.get('status'), 'FAILED','It will show status');
    }
    /**
    * @description TestMethod to check the StatusDescription if FAILED due to no response
    *
    */
    @istest static void testNoContent(){    
      
        List<Application__c>appList=AOB_TestDataFactory.createApplication(1);
        insert appList; 
        AOB_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_MobileNumberValidate.mockHttpStatus='Ok';
        AOB_MobileNumberValidate.mockHttpbody= null;
        Test.startTest();
        String resultList = AOB_MobileNumberValidate.invokeMobileNumberCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();  
       Assert.areEqual((String)m.get('status'), 'NO_CONTENT','It will show status');
    }
    /**
    * @description TestMethod to check the Status in negative Response
    *
    */
    @istest static void testVerificationFailed(){  
    List<Application__c>appList=AOB_TestDataFactory.createApplication(1);
    insert appList; 
    String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"100","Description":"UNABLE TO VERIFY CUSTOMER REFERENCE AT THE MOMENT"},"Resultz":{"CustomerReference":"","Area":"WALLET","StatusCode":"0","StatusDescription":"","CustomerName":"","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
    AOB_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
    AOB_MobileNumberValidate.mockHttpStatus='Ok';
    AOB_MobileNumberValidate.mockHttpbody= str;
    Test.startTest();
    String resultList = AOB_MobileNumberValidate.invokeMobileNumberCallout(appList);
    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
    Test.stopTest();  
   Assert.areEqual((String)m.get('status'), 'FAILED','It will show status');
}
/**
    * @description TestMethod to check the Status in negative Response
    *
    */
    @istest static void testException(){  
        Test.startTest();
        try {
            AOB_MobileNumberValidate.invokeMobileNumberCallout(null);
        } catch(Exception e) {
            Assert.areEqual('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();  
    
        
    }
}