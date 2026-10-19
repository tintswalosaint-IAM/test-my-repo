/**
* @description  Class used as test class for ICS_CTRL_InvokeUpdateTIN_Test
*
* Story: SFP-37310
*
* @author Ramya Gurram
* @date 15/10/2024
* @last modified on  :16/10/2024
* @last modified by  :  Ramya Gurram
* @Modification Description : updated to latest Version
 ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 20-06-2025
 * @Modification description : SFP-49674
 ***************************************************************************************
*/
@IsTest
private class ICS_CTRL_InvokeUpdateTIN_Test {
    
    @TestSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        acc.ExternalCIFId__c = '123';
        update acc;
        
        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(acc.Id);
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(acc.Id);
        form.OpportunityId = opp.Id;
        update form;
    }
    
    @IsTest
    static void testProcessOpportunityFuture() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ApplicationForm form = [SELECT Id, AccountId, Account.ExternalCIFId__c 
                               FROM ApplicationForm 
                               WHERE AccountId = :testAccount.Id LIMIT 1];
        
        Assert.isNotNull(form, 'ApplicationForm should exist');
        Assert.isNotNull(form.Account.ExternalCIFId__c, 'Account should have ExternalCIFId__c');
        
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            ICS_CTRL_InvokeUpdateTIN.processOpportunityFuture(testAccount.Id);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.isFalse(exceptionThrown, 'processOpportunityFuture should complete without exceptions');
        
        List<CMN_WebserviceCallQueue__c> queueRecords = [SELECT Id FROM CMN_WebserviceCallQueue__c 
                                                        WHERE CMN_TriggeringObjectId__c = :testAccount.Id];
        Assert.isFalse(queueRecords.isEmpty(), 'Queue record should be created');
        Assert.areEqual(1, queueRecords.size(), 'Exactly one queue record should be created');
    }
}