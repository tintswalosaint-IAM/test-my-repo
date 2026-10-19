/*------------------------------------------------------------
Author:        Raymond Magezi
Description:   Test class for CMN_UTIL_EmailValidator
Test Class:    CMN_UTIL_EmailValidator_TEST

History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------
23-02-2026  Raymond Magezi     Initial creation
------------------------------------------------------------*/
@IsTest
private class CMN_UTIL_EmailValidator_TEST {
    
    private static final String VALID_EMAIL = 'test@example.com';
    private static final String INVALID_EMAIL = 'invalid-email';
    
    @IsTest
    private static void testIsValidEmail_Valid() {
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.isValidEmail(VALID_EMAIL);
        Test.stopTest();
        
        Assert.isTrue(result);
    }
    
    @IsTest
    private static void testIsValidEmail_Invalid() {
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.isValidEmail(INVALID_EMAIL);
        Test.stopTest();
        
        Assert.isFalse(result);
    }
    
    @IsTest
    private static void testIsValidEmail_Blank() {
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.isValidEmail('');
        Test.stopTest();
        
        Assert.isFalse(result);
    }
    
    @IsTest
    private static void testIsValidEmail_Null() {
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.isValidEmail(null);
        Test.stopTest();
        
        Assert.isFalse(result);
    }
    
    @IsTest
    private static void testAreValidCcAddresses_Valid() {
        List<String> ccAddresses = new List<String>{VALID_EMAIL, 'test2@example.com'};
        
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.areValidCcAddresses(ccAddresses);
        Test.stopTest();
        
        Assert.isTrue(result);
    }
    
    @IsTest
    private static void testAreValidCcAddresses_Invalid() {
        List<String> ccAddresses = new List<String>{VALID_EMAIL, INVALID_EMAIL};
        
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.areValidCcAddresses(ccAddresses);
        Test.stopTest();
        
        Assert.isFalse(result);
    }
    
    @IsTest
    private static void testAreValidCcAddresses_Null() {
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.areValidCcAddresses(null);
        Test.stopTest();
        
        Assert.isTrue(result);
    }
    
    @IsTest
    private static void testAreValidCcAddresses_Empty() {
        Test.startTest();
        Boolean result = CMN_UTIL_EmailValidator.areValidCcAddresses(new List<String>());
        Test.stopTest();
        
        Assert.isTrue(result);
    }
}