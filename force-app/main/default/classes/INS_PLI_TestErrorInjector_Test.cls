/**
 * @description       : Test class for INS_PLI_TestErrorInjector Apex class to set boolean flag 
 * @author            : Madito Tsilo
 * @UserStory         : SFP-53079
 * @date              : 25-10-2025
 **/
@IsTest
private class INS_PLI_TestErrorInjector_Test {
    @IsTest
    static void testDefaultValue() {        
        Assert.isFalse(INS_PLI_TestErrorInjector.throwError,'throwError should default to false');
    }
    @IsTest
    static void testSetThrowErrorTrue() {        
        INS_PLI_TestErrorInjector.throwError = true;        
        Assert.isTrue(
            INS_PLI_TestErrorInjector.throwError,'throwError should be true when explicitly set');
        // Reset to avoid side effects
        INS_PLI_TestErrorInjector.throwError = false;
    }
}