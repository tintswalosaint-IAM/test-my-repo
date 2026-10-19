/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :March 2022
@ Name of the Class :AOB_IdentityApplicantTest
@ Description       :Test class to cover AOB_IdentityApplicant.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
 /**
  * @description Test class to cover AOB_IdentityApplicant.
 */
@isTest
public class AOB_IdentityApplicantTest {
    /**
      * @description test class to cover the success response
      */
    @istest static void invokeIdentifiiCallouttest() {
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList;
        Test.startTest();
        String repStatus =AOB_IdentityApplicant.invokeIdv(new List<String>{appList[0].Id});
        Test.stopTest();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
       Assert.areEqual((String)m.get('status'), 'Success','The status should be Success');
    }
     /**
      * @description test class to cover the failed response
      */
    @istest static void invokeIdentifiiGETDocumentsCallouttest() {
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList;
        Test.startTest();
        String repStatus = AOB_IdentityApplicant.invocableGETMethod(appList, 'testrecordid');
        Test.stopTest();
        AOB_Identify_BodyBean.Response responseMap = (AOB_Identify_BodyBean.Response) JSON.deserialize(repStatus, AOB_Identify_BodyBean.Response.class);
       Assert.areEqual(responseMap.IdentityImages.isEmpty(), false,'Response image should return False');
    }
}