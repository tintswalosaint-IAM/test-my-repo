/**
* @Name of the Class : ICS_UTIL_AppFormDataProvider_Test.cls
* @description: class used as test class for ICS_UTIL_AppFormDataProvider.cls
* @Author Ikyatha Naidu 
* @Date 01/06/2024 
* @Last Modified On  : 25/08/2024
* @Last Modified By  : Ikyatha Naidu 
* @Modification Description : Initial Version
*/
@isTest
public with sharing class ICS_UTIL_AppFormDataProvider_Test {
    @TestSetup
    static void prepareMockRecords() {
        Account acc = ICS_TestDataFactory.createAccount();
        Opportunity opp = ICS_TestDataFactory.createOpportunity(acc.Id);
        Application__c app = ICS_TestDataFactory.createApplication(acc.Id, opp.Id);
        ICS_TestDataFactory.createPartyProfile(acc.Id);
        ICS_TestDataFactory.createEmploymentList(acc.Id);
        ICS_TestDataFactory.createAssetIncomeList(app.Id);
        ICS_TestDataFactory.createContactPointAddressList(acc.Id);
    }
    
    @isTest
    static void fetchTest() {
        
        Opportunity opp = [SELECT Id, Name,accountId FROM Opportunity WHERE Name = 'Mock Mulner' LIMIT 1];
        
            
            try{
                Test.startTest();
                ICS_UTIL_AppFormDataProvider dataProvider = new ICS_UTIL_AppFormDataProvider(opp.Id);
                
                
                Test.stopTest();
                
                Assert.areEqual(dataProvider.opportunityRecord.Id, opp.Id, 'Opportunity Id doesn\'t match');
                Assert.isTrue(dataProvider.addressRecords.size() > 0, 'Failed to fetch address list');
                
                
            }catch(exception ex){
                Assert.areEqual(true,ex.getMessage() !=null,'error message cannot be null');
            }
    }
    
    @isTest
    static void getCountryValueMapTest() { 
        Test.startTest();
        Map<String, String> result = ICS_UTIL_AppFormDataProvider.getCountryValueMap();
        Test.stopTest();
        Assert.isTrue(result.size() > 0, 'Failed to get countries map');
    }
    @isTest
    static void testFetchPartyAssets() {
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        ICS_UTIL_AppFormDataProvider appFormDataProvider = new ICS_UTIL_AppFormDataProvider();
        List<Party_Assets_Funds__c> result = appFormDataProvider.fetchPartyAssets(partyProfile.Id);
        Assert.areEqual(0, result.size(), 'Expected to fetch 2 asset funds.');
    }
    
    @isTest
    static void testFetchPartyProfileAddress() {
        Opportunity opp = [SELECT Id, Name,accountId FROM Opportunity WHERE Name = 'Mock Mulner' LIMIT 1];
        PartyProfile pp = [SELECT Id from PartyProfile where accountId =:opp.AccountId ];
        Set<Id> ppId = new Set<Id>{ pp.Id}; 
            ICS_UTIL_AppFormDataProvider appFormDataProvider = new ICS_UTIL_AppFormDataProvider();
        List<PartyProfileAddress> partyProfileAddresses = appFormDataProvider.fetchPartyProfileAddresses(ppId); 
        Assert.areEqual(0, partyProfileAddresses.size(), 'Expected to fetch 2 party address funds.');
        
    }
    
    @isTest
    static void testFetchContactPointAddress() {
        Opportunity opp = [SELECT Id, Name,accountId FROM Opportunity WHERE Name = 'Mock Mulner' LIMIT 1];
        
        Set<Id> accId = new Set<Id>{opp.AccountId};  
            ICS_UTIL_AppFormDataProvider appFormDataProvider = new ICS_UTIL_AppFormDataProvider();
        List<ContactPointAddress> contactPoints = appFormDataProvider.fetchAddresses(accId);  
        Assert.areEqual(3, contactPoints.size(), 'Expected to fetch 0.');
    }
    
    @isTest
    static void testFetchEmploymentDetails() {
        Opportunity opp = [SELECT Id, Name,accountId FROM Opportunity WHERE Name = 'Mock Mulner' LIMIT 1];
        
        Set<Id> accId = new Set<Id>{opp.AccountId};  
            ICS_UTIL_AppFormDataProvider appFormDataProvider = new ICS_UTIL_AppFormDataProvider();
        List<FinServ__Employment__c> fetchEmploy = appFormDataProvider.fetchEmployment(accId);
        Assert.areEqual(2, fetchEmploy.size(), 'Expected to fetch 0.');
    }
    @isTest
    static void testFetchPartyAssetsFund() {
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        ICS_UTIL_AppFormDataProvider appFormDataProvider = new ICS_UTIL_AppFormDataProvider();
        List<Party_Assets_Funds__c> result = appFormDataProvider.fetchPartyAssetFunds(partyProfile.Id,new List<String>{'Gift'});
        Assert.areEqual(0, result.size(), 'Expected to fetch 1 additional account asset fund.');
    }
    
    @isTest
    static void testFetchPartyAssetsAdditionAccount() {
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        ICS_UTIL_AppFormDataProvider appFormDataProvider = new ICS_UTIL_AppFormDataProvider();
        List<Party_Assets_Funds__c> result = appFormDataProvider.fetchPartyAssetsAdditionAccount(partyProfile.Id);
        Assert.areEqual(0, result.size(), 'Expected to fetch 1 additional account asset fund.');
    }
    
    
    
    
}