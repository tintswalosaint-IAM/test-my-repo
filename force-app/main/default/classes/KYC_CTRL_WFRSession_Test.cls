/***************************************************************************************
@Name of the Class :KYC_CTRL_WFRSession_Test
@Description :SFP-32170 Test Class for KYC_CTRL_WFRSession
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version 
****************************************************************************************/
@isTest
private class KYC_CTRL_WFRSession_Test {

     /**
     * @description This method is for callWfrSessionToke positive test
     */
    @IsTest
    static void callWfrSessionTokenTest(){
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        Test.startTest();
        KYC_DTO_Response response = KYC_CTRL_WFRSession.callWfrSessionToken(ppId) ;
        Test.stopTest();
        Assert.areEqual('Success', response.status, 'call wfr session token succeessful');
    }
     /**
     * @description This method is for callWfrSessionToke negative test
     */
    @IsTest
    static void callWfrSessionTokenNegativeTest(){
        try {
         Test.startTest();   
         KYC_CTRL_WFRSession.callWfrSessionToken(null) ;
         Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName(), 'call wfr session token failed');
        }
        
    }
}