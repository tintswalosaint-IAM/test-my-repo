/***************************************************************************************
@Name of the Class :ICS_DTO_SAPCreateCustomerRequest_Test
@Description : Class used to test ICS_DTO_SAPCreateCustomerRequest
@Author :Ruchi Agarwal
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Ruchi Agarwal
* Last Modified Date Oct 22 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
public class ICS_DTO_SAPCreateCustomerRequest_Test {

static testmethod void testConstructor(){
        test.starttest();
        ICS_DTO_SAPCreateCustomerRequest constantConstructor = new ICS_DTO_SAPCreateCustomerRequest();
        test.stoptest();
         Assert.areEqual(true, (constantConstructor != null), 'Initialized constructor.');
    }
}