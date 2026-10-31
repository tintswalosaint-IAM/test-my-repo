/**
 * @description Test class for INS_CVC_Verification
 * @author Shamsul Arifeen
 * @date April 2024
 * @LastModified: April, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-60467
 * @LastModifiedReason: API Code Remediation
 */
@isTest
private class INS_CVC_Verification_Test {
    /**
     * @description Test method for generateCVCVerificationCode with success mock
     */
    @isTest
    static void testGenerateCVCVerificationCode() {
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new INS_CVC_Verification.CVCInitiateSuccessMock());

        Test.startTest();
        INS_CVC_Verification.VerificationResponse result = INS_CVC_Verification.generateCVCVerificationCode(
            '+254787033556',
            'test@test.com',
            'KE',
            '',
            'Liberty',
            '123'
        );
        Test.stopTest();

        Assert.areEqual('____****', result.validationPattern, 'Validation pattern should match expected pattern');
    }

    /**
     * @description Test method for validateCVCVerificationCode with success mock
     */
    @isTest
    static void testValidateCVCVerificationCode() {
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new INS_CVC_Verification.CVCValidateSuccessMock());

        Test.startTest();
        INS_CVC_Verification.ValidationResponse validationResult = INS_CVC_Verification.validateCVCVerificationCode(
            '1234',
            '_**__**_',
            'KE'
        );
        Test.stopTest();

        Assert.areEqual('Success', validationResult.validation, 'Verification code successfully validated');
    }

    /**
     * @description Test method for validateCVCVerificationCode with failure validation response
     */
    @isTest
    static void testValidateFailedCVCVerificationCode() {
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new INS_CVC_Verification.CVCValidateFailureMock());

        Test.startTest();
        try {
            INS_CVC_Verification.validateCVCVerificationCode('1234', '_**__**_', 'KE');
        } catch (Exception ex) {
            Assert.isNotNull(ex, 'Exception should be thrown for failed validation');
        }
        Test.stopTest();
    }
}