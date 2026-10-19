/**
* @description TestClass for AOB_Otp_Handler from main flow screen mobile and Email including Resend
*
* Story:SFP-12449
*
* @author Vamshi Krishna (vamshi.marripelly@standardbank.co.za)
*
* @date June 2022
*/
@isTest
  public class AOB_OtpHandler_Test {
    /**
     * @description Otp test
     */
        @isTest
        static void testOtp(){
        // Load the test accounts from the static resource
        
        List<sObject> ls = Test.loadData(Account.sObjectType, 'TestAccountLoad');
        
        // Verify that  test accounts were created
        System.assertEquals(ls.size() == 1, true,'size of the Accounts is 1');
        
        // Get first test account
        Account a1 = (Account)ls[0];
        //Create related lead based on account id
        List<Lead> lst = new List<Lead>();
        Lead ld=AOB_TestDataFactory.createLead();
        ld.lastname=a1.name;
        ld.company=ld.lastname;
        ld.FinServ__RelatedAccount__c=a1.id;
        lst.add(ld);
        //Insert List of leads
        insert lst;
        
        Test.startTest();
         
        Map<String, String> otp = (Map<String,String>) JSON.deserialize( AOB_OtpHandler.verifyEmail(lst), Map<String,String>.class);
        
        //passing null list
        List<Lead> nullLst = new List<Lead>();
        AOB_OtpHandler.verifyEmail(nullLst);
        
        //Call phone Otp which recieves a string
        String otpForPhone=AOB_OtpHandler.generateOtpForPhone();
        
        Test.stopTest();
        System.assertEquals(otp.isEmpty(), false,'otp should be empty');
        System.assertEquals(otpForPhone!=null, true,'otp for phone should not be null');
        
        
    }
}