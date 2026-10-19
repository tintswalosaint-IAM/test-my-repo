/*************************************************************
 * @description SFP-32986 class is used to test ICS_DTO_SAP_CreateRelationRequest
 *
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima
 * Last Modified Date 21/10/2024
 * Last Modified Description: Initial Version
 */
@isTest
public class ICS_DTO_SAP_CreateRelationRequest_Test {
    static testmethod void testRelationshipRequest(){
        test.starttest();
        ICS_DTO_SAP_CreateRelationRequest constantConstructor = new ICS_DTO_SAP_CreateRelationRequest();
        test.stoptest();
         Assert.areEqual(true, (constantConstructor != null), 'Initialized constructor.');
    }
}