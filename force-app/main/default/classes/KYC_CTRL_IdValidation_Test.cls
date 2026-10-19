/***************************************************************************************
@Name of the Class :KYC_CTRL_IdValidation_Test
@Description :SFP-32239	 Test Class for KYC_CTRL_IdValidation
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_CTRL_IdValidation_Test {

    /**
     * @description This method is for SavePartyIdentityVerification positive test
     */
    @IsTest
    static void callIdValidationTest(){
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        Test.startTest();
        KYC_DTO_Response response = KYC_CTRL_IdValidation.callIdValidation(ppId) ;
        Test.stopTest();
        Assert.areEqual('Success', response.status, 'Id validation succeessful');
    }
    /**
     * @description This method is for SavePartyIdentityVerification negative test
     */
    @IsTest
    static void callIdValidationNeggativeTest(){
        try {
            Test.startTest();
            KYC_CTRL_IdValidation.callIdValidation(null) ;
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName(), 'callIdValidation failed');
        }
    }
}