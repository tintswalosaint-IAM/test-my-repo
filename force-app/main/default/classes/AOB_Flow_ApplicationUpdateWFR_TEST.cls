@isTest
public class AOB_Flow_ApplicationUpdateWFR_TEST {
    @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    }

    /**
     * @description This method is used to test callGetCustomerAPI methd
     */
    @isTest
    public static void AOB_callGetCustomerAPI_Test() {
        User communityUser = [SELECT Id, ContactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        Account acc = [SELECT id FROM account WHERE id IN (SELECT accountId FROM contact WHERE id = :communityUser.contactId)];
        System.runAs(communityUser) {
            Test.startTest();
            Map<string, string> ProductData = new Map<string, string>();
            ProductData.put('Name', 'test');
            Product2 produit = (Product2) AOB_DAL_TesTFactory.genericObjectCreation('Product2', ProductData);
            insert produit;
            Map<string, string> ApplicationData = new Map<string, string>();
            ApplicationData.put('AOB_Customer__c', acc.id);
            ApplicationData.put('AOB_TECH_FlowNames__c', 'AOB_BeforeWeBegin,AOB_PersonalDetails,AOB_CardPersonalisation,AOB_CardDetails,AOB_CardFinalOffer');
            AOB_Application__c app = (AOB_Application__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c', ApplicationData);
            insert app;
            Map<string, string> AppLIData = new Map<string, string>();
            AppLIData.put('AOB_Application__c', app.id);
            AppLIData.put('AOB_Product__c', produit.id);
            insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_ApplicationLineItem__c', AppLIData);
            AOB_Flow_ApplicationUpdateWFR.updateApplication(new List<string>{ app.id });
            Test.stopTest();
            //system.assertNotEquals([SELECT Id, AOB_TECH_FlowNames__c, AOB_TECH_CurrentScreenNum__c FROM AOB_Application__c WHERE Id = :app.id].AOB_TECH_CurrentScreenNum__c, null);
        }
    }
}