/***************************************************************************************
@Name of the Class :KYC_CTRL_RAASCustomer_Test
@Description :SFP-32239	 Test Class for KYC_CTRL_RAASCustomer
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_CTRL_RAASCustomer_Test {

     /**
     * @description This method is for SavePartyIdentityVerification positive test
     */
    @IsTest
    static void callIdValidationTest(){
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('UG');
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary',status='In Progress', PartyProfileId = profileProfileId);
        insert testSummary;
        Test.startTest();
        KYC_DTO_Response response = KYC_CTRL_RAASCustomer.callRAASCustomer(profileProfileId);
        Test.stopTest();
        Assert.areEqual('Success', response.status, 'Id velidation succeessful');
    }
    /**
     * @description This method is for SavePartyIdentityVerification negative test
     */
    @IsTest
    static void callIdValidationNeggativeTest(){
        try {
            Test.startTest();
            KYC_CTRL_RAASCustomer.callRAASCustomer(null) ;
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName(), 'callIdValidation failed');
        }
        
    }
}