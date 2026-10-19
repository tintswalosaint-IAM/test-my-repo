/**
* @author            : Ihtishaam Mohammoodally
* @description       : TestClass for InsIVRScripts [SFP-32781]
* @date 			  : 22-07-2024
**/
@isTest(SeeAllData = false)
public class InsIVRScriptsTest {

    @TestSetup
    private static void buildTestData(){
        Account account = new Account(RecordTypeId = Schema.getGlobalDescribe()
                                                .get('Account').getDescribe()
                                                .getRecordTypeInfosByDeveloperName()
                                                .get('PersonAccount').getRecordTypeId(),
                                      FirstName = 'Test',
                                      LastName = 'Test',
                                      Phone = '12345678',
                                      PersonMobilePhone  = '12345678');
        
        Database.insert(account);
        amazonconnect__AC_ContactChannels__c amazonConnect = new amazonconnect__AC_ContactChannels__c(
                                                                                amazonconnect__ContactId__c = '6ea66507-5b2a-4270-acb8-59a7d55ee5f1',
            																	amazonconnect__InitiationMethod__c = 'Outbound',
                                                                                amazonconnect__QueueName__c = 'Insurance - SBIB OAN - Sales - Car');
      Database.insert(amazonConnect);
    }
    
    @isTest
    private static void testinvokeMethod(){
        Account personAccount = [Select Id,FirstName,LastName,PersonMobilePhone From Account where LastName = 'Test'limit 1];  
        amazonconnect__AC_ContactChannels__c amazonConnect = [Select Id,amazonconnect__ContactId__c,amazonconnect__QueueName__c,amazonconnect__InitiationMethod__c,
                                                              amazonconnect__CustomerNumber__c From amazonconnect__AC_ContactChannels__c
                                                              Where  amazonconnect__ContactId__c = '6ea66507-5b2a-4270-acb8-59a7d55ee5f1'
                                                              limit 1];
        
        Map<String, Object> inputMap = new Map<String, Object>{
            'recordId' => (Object) personAccount.Id,
            'amazonConnectContactId' => (Object) amazonConnect.amazonconnect__ContactId__c
        };
            
        InsIVRScripts.invokeMethod('runFlow',inputMap, new Map<String, Object>(),new Map<String, Object>());
        EngagementInteraction engagementInteraction = [Select Id From EngagementInteraction limit 1];
        Assert.isNotNull(engagementInteraction.Id, 'Engagement Interaction has been created successfully');

    }
    
}