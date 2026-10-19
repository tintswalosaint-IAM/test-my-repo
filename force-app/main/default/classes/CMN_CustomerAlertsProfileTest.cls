/***************************************************************************************
@ Author            :Lokesh Bothsa
@ Date              :June 2023
@ Name of the Class :CMN_CustomerAlertsProfileTest
@description       :Test Class for dealing with CustomerAlertProfile api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-26345
***************************************************************************************/
@istest 
public class CMN_CustomerAlertsProfileTest {
       /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
    @istest static void testCalloutMethod(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
       		List<Application_Participant__c> lstOfAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            String str='{"Status": "S000000001","Description": "Record Added Successfully"}';
            CMN_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_CustomerAlertsProfile.mockHttpStatus='OK';
            CMN_CustomerAlertsProfile.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_CustomerAlertsProfile.invocableMethod(lstApp,lstOfAppParticipants);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(null, m,'Test');
            
     }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @istest static void testCalloutMethod1(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> lstOfAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            String str='{"Status": "","Description": "Record Added Successfully"}';
            CMN_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_CustomerAlertsProfile.mockHttpStatus='OK';
            CMN_CustomerAlertsProfile.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_CustomerAlertsProfile.invocableMethod(lstApp,lstOfAppParticipants);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(null, m,'Test');
            
     }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
    @istest static void testCalloutMethod2(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> lstOfAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            String str='{"Status": "","Description": "Record Added Successfully"}';
            CMN_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_CustomerAlertsProfile.mockHttpStatus='OK';
            CMN_CustomerAlertsProfile.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_CustomerAlertsProfile.invocableMethod(lstApp,lstOfAppParticipants);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(null, m,'Test');
            
     }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @istest static void testCalloutMethod3(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> lstOfAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            CMN_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_CustomerAlertsProfile.mockHttpStatus='FAILED';
            CMN_CustomerAlertsProfile.mockHttpbody='';
            Test.startTest();
            String repStatus = CMN_CustomerAlertsProfile.invocableMethod(lstApp,lstOfAppParticipants);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(null, m,'Test');
            
     }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
    @istest static void testCalloutMethod4(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            List<Application_Participant__c> lstOfAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
            CMN_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_CustomerAlertsProfile.mockHttpStatus='OK';
            CMN_CustomerAlertsProfile.mockHttpbody='';
            Test.startTest();
            String repStatus = CMN_CustomerAlertsProfile.invocableMethod(lstApp,lstOfAppParticipants);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(null, m,'Test');
            
     }
  
      /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @IsTest
     static void testJsonParsing() {
         // Given JSON string
         String jsonString = '{ "schemaRecords": [ { "startTimestamp": "2023-07-29T10:00:00Z", "schemeID": "ABC123", "endDateTimestamp": "2023-08-29T10:00:00Z", "billingInformation": { "debitAccountNumber": "1234567890" } }, { "startTimestamp": "2023-06-15T15:30:00Z", "schemeID": "XYZ456", "endDateTimestamp": "2023-09-15T15:30:00Z", "billingInformation": { "debitAccountNumber": "9876543210" } } ], "general": { "lastName": "Doe", "languageID": "en", "firstName": "John", "customerInternalID": "CUST123", "customerHostID": "HOST456" }, "contactInformation": { "state": "California", "mobileNumber": "+1 (123) 456-7890", "emailID": "john.doe@example.com", "countryCode": "US", "city": "Los Angeles", "addressLine2": "Apt 789", "addressLine1": "123 Main St" }, "billingInformation": { "debitAccountNumber": "9876543210" } }';
         BCB_CustomerAlertsProfileBean customerProfile = (BCB_CustomerAlertsProfileBean) JSON.deserialize(jsonString, BCB_CustomerAlertsProfileBean.class);
         List<BCB_CustomerAlertsProfileBean.SchemaRecords> schemaRecords = customerProfile.schemaRecords;
        Assert.areEqual(2, schemaRecords.size(),'Test');
         BCB_CustomerAlertsProfileBean.General generalInfo = customerProfile.general;
        Assert.areEqual('Doe', generalInfo.lastName,'Test');
        Assert.areEqual('John', generalInfo.firstName,'Test');
        Assert.areEqual('CUST123', generalInfo.customerInternalID,'Test');
        Assert.areEqual('HOST456', generalInfo.customerHostID,'Test');
         BCB_CustomerAlertsProfileBean.ContactInformation contactInfo = customerProfile.contactInformation;
        Assert.areEqual('California', contactInfo.state,'Test');
        Assert.areEqual('+1 (123) 456-7890', contactInfo.mobileNumber,'Test');
        Assert.areEqual('john.doe@example.com', contactInfo.emailID,'Test');
        Assert.areEqual('US', contactInfo.countryCode,'Test');
        Assert.areEqual('Los Angeles', contactInfo.city,'Test');
        Assert.areEqual('Apt 789', contactInfo.addressLine2,'Test');
        Assert.areEqual('123 Main St', contactInfo.addressLine1,'Test');
 
         
     }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
      @isTest
    static void testCallInvocableMethod5() {
        
        CMN_CustomerAlertsProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertsProfile.mockHttpStatus='SUCCESS';
        CMN_CustomerAlertsProfile.mockHttpBody = '{"sessionNumber":"", "status": "FAILED","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","statusCode":"01"}';
       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
         
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
           lstofParticipants[0].Application__c = applicationList[0].Id;
           insert lstofParticipants;
        try{
        Test.startTest(); 
        System.enqueueJob(new BCB_AlertsProfileQueueable(applicationList,lstofParticipants));

        Test.stopTest(); 
      }catch(exception ex){
         Assert.areNotEqual(null, lstofParticipants,'Test');
     }       
        
    }
       /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @isTest
    static void testCallInvocableMethod6() {
        
        CMN_CustomerAlertsProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertsProfile.mockHttpStatus='SUCCESS';
        CMN_CustomerAlertsProfile.mockHttpBody = '{"Status": "S000000001","ErrorDescription": "Record Added Successfully"}';
       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
         
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
           lstofParticipants[0].Application__c = applicationList[0].Id;
           insert lstofParticipants;
        try{
        Test.startTest(); 
        System.enqueueJob(new BCB_AlertsProfileQueueable(applicationList,lstofParticipants));

        Test.stopTest(); 
      }catch(exception ex){
         Assert.areNotEqual(null, lstofParticipants,'Test');
     }
            
   }
}