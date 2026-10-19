/*************************************************************
 * @description SFP-32986  Class used to test ICS_DTO_SAP_CreateAccountRequest_Test
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima
 * Last Modified Date 21/10/2024
 * Last Modified Description: Initial Version
 */
@isTest
public class ICS_DTO_SAP_CreateAccountRequest_Test {
	static testmethod void testConstructor(){
        test.starttest();
        ICS_DTO_SAP_CreateAccountRequest_Test constantConstructor = new ICS_DTO_SAP_CreateAccountRequest_Test();
        test.stoptest();
         Assert.areEqual(true, (constantConstructor != null), 'Initialized constructor.');
    }
}