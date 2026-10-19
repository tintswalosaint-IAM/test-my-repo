/**
 * @description       : 
 * @author            : jagadish Thummala
 * @group             : 
 * @last modified on  : 10-15-2025
 * @last modified by  : jagadish Thummala
**/
@isTest
public with sharing class UG_AOB_PPB_OtpHandler_TEST {

        /**
        * @description 
        * @author jagadish Thummala | 10-15-2025 
        **/
        @isTest
        static void testOtp(){
        List<sObject> ls = Test.loadData(Account.sObjectType, 'TestAccountLoad');       
        Assert.areEqual(ls.size() == 1, true,'size of the Accounts is 1');       
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
        Map<String, String> otp = (Map<String,String>) JSON.deserialize( UG_AOB_PPB_OtpHandler.verifyEmail(lst), Map<String,String>.class);       
        //passing null list
        List<Lead> nullLst = new List<Lead>();
        UG_AOB_PPB_OtpHandler.verifyEmail(nullLst);        
        //Call phone Otp which recieves a string
        String otpForPhone=UG_AOB_PPB_OtpHandler.generateOtpForPhone();       
        Test.stopTest();
        Assert.areEqual(otp.isEmpty(), false,'otp should be empty');
        Assert.areEqual(otpForPhone!=null, true,'otp for phone should not be null');               
    }
}