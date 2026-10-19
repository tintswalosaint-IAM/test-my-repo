/**
* @description  Class used  as test class for ICS_API_InvokeCRA
*
* Story:SFP-32986
*
* @authon Ikyatha Naidu
* @date 11/01/2024
* @last modified on  :1/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest Version
*/
@isTest
private class ICS_API_InvokeCRA_Test {
    @isTest
    static void testSendCRARequest() {
          Account accountObj = ICS_DAL_TestFactory.createAccount();
        opportunity opportunityObj = ICS_DAL_TestFactory.createOpportunity(accountObj.id);
        test.starttest();
        ICS_API_InvokeCRA serviceInfo = new ICS_API_InvokeCRA();
        
        serviceInfo.reqBody = '{"CustomerId":"'+accountObj.Id+'","CraKeys":[{"value":"'+opportunityObj.Id+'","key":"opportunity"},{"value":"false","key":"is_pep"},{"value":"false","key":"has_adverse_media"},{"value":"false","key":"has_high_net_worth"},{"value":"false","key":"shell_bank"},{"value":"false","key":"bearer_shares"},{"value":"false","key":"government_contracts"},{"value":"platinum_optimum _account","key":"product"},{"value":"salaried_employee_bank","key":"occupation_category"},{"value":"chief_executive","key":"occupation_position"},{"value":"408","key":"business_activity"},{"value":"IN","key":"residence"},{"value":"IN","key":"country_of_birth"},{"value":"IN","key":"nationality"},{"value":"IN","key":"country_of_wealth"},{"value":"IN","key":"country_of_funds"},{"value":"direct_non_face_to_face","key":"distribution_channel"}]}';
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_InvokeCRA.SERVICE_NAME,accountObj.id);
        serviceInfo.process(obj);
       
        Assert.areEqual(true,(serviceInfo !=null),'CRA Request sent , Received Success Response from ');
        test.stoptest();
       
        
    }
     @isTest
    static void testSendCRARequestFail() {
          Account accountObj = ICS_DAL_TestFactory.createAccount();
        test.starttest();
        ICS_API_InvokeCRA serviceInfo = new ICS_API_InvokeCRA();
        
        serviceInfo.reqBody = '{"CustomerId":"'+accountObj.Id+'","CraKeys":[{"value":"","key":"opportunity"},{"value":"false","key":"is_pep"},{"value":"false","key":"has_adverse_media"},{"value":"false","key":"has_high_net_worth"},{"value":"false","key":"shell_bank"},{"value":"false","key":"bearer_shares"},{"value":"false","key":"government_contracts"},{"value":"platinum_optimum _account","key":"product"},{"value":"salaried_employee_bank","key":"occupation_category"},{"value":"chief_executive","key":"occupation_position"},{"value":"408","key":"business_activity"},{"value":"IN","key":"residence"},{"value":"IN","key":"country_of_birth"},{"value":"IN","key":"nationality"},{"value":"IN","key":"country_of_wealth"},{"value":"IN","key":"country_of_funds"},{"value":"direct_non_face_to_face","key":"distribution_channel"}]}';
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_InvokeCRA.SERVICE_NAME,accountObj.id);
        serviceInfo.process(obj);
       
        Assert.areEqual(true,(serviceInfo !=null),'CRA Request sent with empty opportunityId');
        test.stoptest();
       
    }

    

}