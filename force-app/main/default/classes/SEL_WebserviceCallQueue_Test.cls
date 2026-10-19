/**
 * @description Test class for SEL_CMN_WebserviceCallQueue
 * @author Ridhima Saxena
 * @date 11-06-2025
 */
@IsTest
private class SEL_WebserviceCallQueue_Test {
    
    @TestSetup
    static void setupData() {
        CMN_WebserviceCallQueue__c record = new CMN_WebserviceCallQueue__c(
            CMN_StatusCode__c = '200',
            CMN_Service__c = 'TestService',
            CMN_Request__c = 'Test Request',
            CMN_Response__c = 'Test Response'
        );
        insert record;
    }
    
    @IsTest
    static void testGetSObjectType() {
        SEL_WebserviceCallQueue selector = new SEL_WebserviceCallQueue();
        Assert.areEqual(CMN_WebserviceCallQueue__c.sObjectType, selector.getSObjectType());
    }
    
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_WebserviceCallQueue selector = new SEL_WebserviceCallQueue();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Assert.areEqual(4, fields.size());
    }
    
    @IsTest
    static void testSelectSuccessfulCalls() {
        SEL_WebserviceCallQueue selector = new SEL_WebserviceCallQueue();
        List<CMN_WebserviceCallQueue__c> result = selector.selectbyServiceUserandStatus('200','TestService', UserInfo.getUserId());
        Assert.areEqual(1, result.size());
        Assert.areEqual('200', result[0].CMN_StatusCode__c);
    }
    
   
}