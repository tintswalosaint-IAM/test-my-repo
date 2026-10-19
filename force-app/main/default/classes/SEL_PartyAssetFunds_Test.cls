/**
 * @Name of the class: SEL_PartyAssetFunds_Test
 * @description Test class for the SEL_PartyAssetFunds class
 * 
 * Story: SFP-30128
 * 
 * @author Ikyatha Naidu
 * @date 09/11/2023
 ***************************************************************
 * @last modified on: 04-07-2024
 * @last modified by: Ikyatha Naidu
 * @ Modification Description: Updated to cover all new scenarios
 */
@isTest
public class SEL_PartyAssetFunds_Test {

    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        PartyProfile profileData = new PartyProfile(AccountId = acc.Id, Name = 'Test PartyProfile');
        insert profileData;
        Id wealthInCountryRecordTypeId = Schema.getGlobalDescribe().get('Party_Assets_Funds__c')
                                               .getDescribe()
                                               .getRecordTypeInfosByName()
                                               .get('Wealth in Country')
                                               .getRecordTypeId();
        Id sourceFundRecordTypeId = Schema.getGlobalDescribe().get('Party_Assets_Funds__c')
                                          .getDescribe()
                                          .getRecordTypeInfosByName()
                                          .get('Source of Funds')
                                          .getRecordTypeId();
        Id additionalAccountRecordTypeId = Schema.getGlobalDescribe().get('Party_Assets_Funds__c')
                                                 .getDescribe()
                                                 .getRecordTypeInfosByName()
                                                 .get('Additional Accounts')
                                                 .getRecordTypeId();
        
        Party_Assets_Funds__c assetFundWealth = new Party_Assets_Funds__c(
            Party_Profile__c = profileData.Id,
            Type__c = 'Ownership/shares in business',
            RecordTypeId = wealthInCountryRecordTypeId
        );
        insert assetFundWealth;

        Party_Assets_Funds__c assetFundSource = new Party_Assets_Funds__c(
            Party_Profile__c = profileData.Id,
            Type__c = 'Ownership/shares in business',
            RecordTypeId = sourceFundRecordTypeId
        );
        insert assetFundSource;

        Party_Assets_Funds__c assetFundAdditional = new Party_Assets_Funds__c(
            Party_Profile__c = profileData.Id,
            Type__c = 'Ownership/shares in business',
            RecordTypeId = additionalAccountRecordTypeId
        );
        insert assetFundAdditional;
    }

    /**
     * @description Verify the getSObjectType method
     */
    @IsTest
    static void testGetSObjectType() {
        SEL_PartyAssetFunds app = new SEL_PartyAssetFunds();
        Schema.SObjectType sObjectType = app.getSObjectType();   
        Assert.areEqual(Party_Assets_Funds__c.SObjectType, sObjectType, 'Unexpected SObjectType returned.');
    }

    /**
     * @description Verify the getSObjectFieldList method
     */
    @IsTest
    private static void getSObjectFieldListTest() {
        SEL_PartyAssetFunds app = new SEL_PartyAssetFunds();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Assert.areNotEqual(0, lst.size(), 'Expected to return a non-zero number of fields.');
    }

    /**
     * @description Verify selectAssetFundsByRecordType method
     */
    @IsTest
    public static void testSelectAssetFundsByRecordType() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile profileData = [SELECT Id,accountId FROM PartyProfile WHERE AccountId = :acc.Id LIMIT 1];
        List<String> typeList = new List<String>{'Ownership/shares in business'};       
        SEL_PartyAssetFunds app = new SEL_PartyAssetFunds();        
        Test.startTest();
        List<Party_Assets_Funds__c> assetListWealth = app.selectAssetFundsByRecordType(profileData.Id, typeList, 'Wealth');
        List<Party_Assets_Funds__c> assetListSource = app.selectAssetFundsByRecordType(profileData.Id, typeList, 'Funds');
         app.selectAssetFundsByRecordType(profileData.Id, typeList, 'Additional');
        app.selectByAccountId(profileData.accountId);
        List<Party_Assets_Funds__c> assetListFuture = app.selectAssetFundsByRecordType(profileData.Id, typeList, 'future');
        Test.stopTest();
        Assert.areEqual(1, assetListWealth.size(), 'Expected one wealth asset fund.');
        Assert.areEqual(1, assetListSource.size(), 'Expected one source of funds asset fund.');
        Assert.areEqual(0, assetListFuture.size(), 'Expected no future asset funds.');
    }

    /**
     * @description Verify selectDepositInfoByPartyProfileIds method
     */
    @IsTest
    public static void testSelectDepositInfoByPartyProfileIds() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :acc.Id LIMIT 1];
        
        Party_Assets_Funds__c depositFund = new Party_Assets_Funds__c(
            Party_Profile__c = profileData.Id,
            Initial_Deposit__c = 10000,
            RecordTypeId = Schema.getGlobalDescribe().get('Party_Assets_Funds__c').getDescribe().getRecordTypeInfosByName().get('Additional Accounts').getRecordTypeId()
        );
        insert depositFund;
        
        SEL_PartyAssetFunds app = new SEL_PartyAssetFunds();
        Set<Id> profileIds = new Set<Id>{profileData.Id};
        
        Test.startTest();
        List<Party_Assets_Funds__c> depositInfo = app.selectDepositInfoByPartyProfileIds(profileIds);
        
        Test.stopTest();
        Assert.areEqual(1, depositInfo.size(), 'Expected one deposit info record.');
        Assert.areEqual(depositFund.Id, depositInfo[0].Id, 'The deposit info record should match the inserted record.');
    }

    /**
     * @description Verify selectByPartyProfileType method
     */
    @IsTest
    public static void testSelectByPartyProfileType() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :acc.Id LIMIT 1];
        List<String> typeList = new List<String>{'Ownership/shares in business'};        
        SEL_PartyAssetFunds app = new SEL_PartyAssetFunds();        
        Test.startTest();
        List<Party_Assets_Funds__c> assetList = app.selectByPartyProfileType(new Set<Id>{profileData.Id}, 'Additional Accounts', typeList);
        app.selectByWherClause('id != null',profileData.id);
        Test.stopTest();
        Assert.areEqual(1, assetList.size(), 'Expected one asset fund.');
    }

    /**
     * @description Verify selectByPartyProfileIds method
     */
    @IsTest
    public static void testSelectByPartyProfileIds() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :acc.Id LIMIT 1];        
        SEL_PartyAssetFunds app = new SEL_PartyAssetFunds();
        Set<Id> profileIds = new Set<Id>{profileData.Id};       
        Test.startTest();
        List<Party_Assets_Funds__c> assetList = app.selectByPartyProfileIds(profileIds);
        app.selectByPartyProfileTypeList(profileData.Id,new List<string>{'Gift'});
        app.selectByPartyProfileTypewithRecordAssests(profileData.Id,'Gift','Wealth in Country',true);
          app.selectByContactId(new set<Id>{profileData.id});
        app.selectByPartyProfileBulkTypewithRecordAssests(profileData.Id,new List<string>{'Gift'},'Wealth in Country',true);
      
        Test.stopTest();
        Assert.areEqual(3, assetList.size(), 'Expected three asset funds.');
    }

    /**
     * @description Verify getRecordTypeIdByName method
     */
    @IsTest
    public static void getRecordTypeIdByNameTest() {
        Id recordTypeId = SEL_PartyAssetFunds.getRecordTypeIdByName('Party_Assets_Funds__c', 'Wealth in Country');
        Assert.areNotEqual(null, recordTypeId, 'Expected a non-null record type ID.');
    }
}