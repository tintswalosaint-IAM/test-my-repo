/**
 * @description SFP-32986 Class used  to test ICS_DTO_SAPCreateCYTRequest_Test
 * @author Rukesh
 * @date 21/10/2024
 *****************************************************
 * @last modified on  : 21/10/2024
 * @last modified by  : Rukesh
 * @last modified description: updated to align with the latest version of ICS_DTO_SAPCreateCYTRequest_Test
 */
@istest
public class ICS_DTO_SAPCreateCYTRequest_Test {
@IsTest
    public static void testICS_DTO_SAPCreateCYTRequest() {
         test.starttest();
        ICS_DTO_SAPCreateCYTRequest constantConstructor = new ICS_DTO_SAPCreateCYTRequest();
        test.stoptest();
         Assert.areEqual(true, (constantConstructor != null), 'Initialized constructor.');
}
}