/**
 * @description Loqate Find Address with Text Test Class
 * 
 * @Name of the Class : ICS_CTRL_LoqateAddressTest
 * @description  SFP-33996 class used as test Class for ICS_CTRL_LoqateAddress controller for SBO-UK - 
 * @Author SHRAVANI GANTA
 * @Date April 22nd 2024
 * @Last modified on  : 17-05-2024
 * @Last modified by  : Ruchi Agrawal
 */
@isTest
public class ICS_CTRL_LoqateAddressTest {
    
    /**
     * @description Test for findAddress method with valid parameters
     */
    @isTest
    static void testFindAddressWithValidParameters() {
        Test.startTest();
        final String result = ICS_CTRL_LoqateAddress.findAddress('US', '123 Main St', 'Container');
        Test.stopTest(); 
        
        Assert.isNotNull(result, 'Expected non-null result for findAddress with valid parameters');
    }
    /**
     * @description Test for findAddress method with empty parameters
     */
    @isTest
    static void testFindAddressWithEmptyParameters() {
        Test.startTest();
        final String result = ICS_CTRL_LoqateAddress.findAddress('', '', '');
        Test.stopTest(); 
        Assert.isNotNull(result, 'Expected non-null result for findAddress with empty parameters');
    }

    /**
     * @description Test for retrieveAddress method with empty string parameter
     */
    @isTest
    static void testRetrieveAddressWithEmptyParameter() {
        Test.startTest();
        final String results = ICS_CTRL_LoqateAddress.retrieveAddress('');
        Test.stopTest(); 
        
        Assert.isNotNull(results, 'Expected non-null result for retrieveAddress with empty parameter');
    }

    
    

    /**
     * @description Test for retrieveAddress method with valid parameter
     */
    @isTest
    static void testRetrieveAddressWithValidParameter() {
        Test.startTest();
        final String results = ICS_CTRL_LoqateAddress.retrieveAddress('IN|LP|A|27614485|1_ENG');
        Test.stopTest(); 
        
        Assert.isNotNull(results, 'Expected non-null result for retrieveAddress with valid parameter');
    }
}