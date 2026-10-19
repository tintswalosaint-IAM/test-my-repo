/***************************************************************************************
@Name of the Class :KYC_SRV_IdValidation_Test
@Description :SFP-40754 Test Class for KYC_SRV_IdValidation
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version 
****************************************************************************************/

@isTest
private class KYC_SRV_IdValidation_Test {
    /**
     * @description Test method for callIdValidation to test positive results
     */
    @IsTest
    private static void callIdValidationTest() {
        Id ppId = KYC_TestDataFactory.createPartyProfile('AF');
        Test.startTest();
        KYC_DTO_Response response = KYC_SRV_IdValidation.callIdValidation(ppId);
        Test.stopTest();
        Assert.areEqual('Success', response.status, 'Id validation status success');
    }
 
    /**
     *  @description Test method for callIdValidation to test negative results
     */
    @IsTest
    private static void callIdValidationNegativeTest() {
        KYC_TestDataFactory.createPartyProfile('AF');
        try {
           Test.startTest(); 
           KYC_SRV_IdValidation.callIdValidation(null);
           Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('Attempt to de-reference a null object', e.getMessage(), 'Attempt to de-reference a null object');
        }
    }
}