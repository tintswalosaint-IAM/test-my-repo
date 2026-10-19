/***************************************************************************************
@Name of the Class :public with sharing class KYC_SRV_SendSMS_Test 
@Description :SFP-40755 Test Class for KYC_SRV_SendSMS.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public  class KYC_SRV_SendSMS_Test {
    
   /**
    * @description This method used to test sendSMS method
    */
    @IsTest
    public static void sendSMSTest(){
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        Test.startTest();
        Integer statusCode=KYC_SRV_SendSMS.sendSMS(new set<id>{ppId});
        Test.stopTest();
        Assert.areEqual(200, statusCode,'SendSMS API should return a successful response code');
    }
    
    /**
    * @description This method used to test sendSMS method
    */
    @IsTest
    public static void sendSMSSATest(){
        Id ppId = KYC_TestDataFactory.createPartyProfile('ZA');
        Test.startTest();
        Integer statusCode=KYC_SRV_SendSMS.sendSMS(new set<id>{ppId});
        Test.stopTest();
        Assert.areEqual(200, statusCode,'SendSMS API should return a successful response code');
    }
    
    /**
    * @description This method used to test sendSMS method
    */
    @IsTest
    public static void sendSMSNegTest(){
        try{
            Test.startTest();
            KYC_SRV_SendSMS.sendSMS(new set<id>{null});
            Test.stopTest();
        }catch(exception ex){
           Assert.areEqual('Script-thrown exception', ex.getMessage(),'Test failed: Expected error message');
        }
    }   

       
}