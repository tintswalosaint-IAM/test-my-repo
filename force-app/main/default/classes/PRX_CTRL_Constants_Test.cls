/***************************************************************************************
@ Author : mamidalar@stanbic.com
@ Date : 7 june, 2024
@ Name of the Class : PRX_CTRL_ConstantsTest
@description : Test class to validate the constants declared in PRX_CTRL_Constants class.
@ Last Modified By : Krishna Ranjan
@ Last Modified On : 7 june, 2024
@ Modification Description : SFP - 31923
***************************************************************************************/
@isTest
public class PRX_CTRL_Constants_Test {
    /**
     * @description : Validates that the constants have the expected values.
     */
    @isTest
    static void testConstants() {
       Test.startTest();
    PRX_CTRL_Constants result = new PRX_CTRL_Constants();
    Test.stopTest();
    Assert.areEqual('Perx', result.productInfo, 'ProductInfo should be Perx');
    }
}