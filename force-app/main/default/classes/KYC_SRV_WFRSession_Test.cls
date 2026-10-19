/***************************************************************************************
@Name of the Class :KYC_SRV_WFRSession_Test
@Description :SFP-32209 Test Class for KYC_SRV_WFRSession
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_SRV_WFRSession_Test {

    /**
     * @description Test method for callWfrSessionTokenTest to test positive results
     */
    @IsTest
    private static void callWfrSessionTokenUGTest() {
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        Test.startTest();
        KYC_DTO_Response response = KYC_SRV_WFRSession.callWfrSessionToken(ppId);
        Test.stopTest();
        Assert.areEqual('Success', response.status, 'WFR Session Token');
    }
    /**
     * @description Test method for callWfrSessionTokenTest to test positive results
     */
    @IsTest
    private static void callWfrSessionTokenZATest() {
        Id ppId = KYC_TestDataFactory.createPartyProfile('ZA');
        Test.startTest();
        KYC_DTO_Response response = KYC_SRV_WFRSession.callWfrSessionToken(ppId);
        Test.stopTest();
        Assert.areEqual('Success', response.status, 'WFR Session Token');
    }
    /**
     * @description Test method for callWfrSessionTokenTest  to test negative results
     */
    @IsTest
    private static void callWfrSessionTokenNegativeTest() {
        try {
           Test.startTest(); 
           KYC_SRV_WFRSession.callWfrSessionToken(null);
           Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('Attempt to de-reference a null object', e.getMessage(), 'Attempt to de-reference a null object');
        }
    }
}