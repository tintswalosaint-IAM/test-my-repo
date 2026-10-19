/**
* @Name of the Class : SEL_PartyIdentityVerification_Test
* @description       : SFP-36380 Selector Test class for SEL_PartyIdentityVerification object.
* @author            :Ikyatha Naidu 
* @date              :18/05/2024
********************************************
* @last modified on  : 02/09/2024
* @last modified by  : Nagendra Mylavarapu
* @Modification Description : Added a new method to cover the selectByPartyProfileIdsAndName
**/
@istest
public class SEL_PartyIdentityVerification_Test {
    @IsTest
    static void GetSObjectTypeTestMethod() {
        SEL_PartyIdentityVerification partyProfileSelector = new SEL_PartyIdentityVerification();
        Test.startTest(); 
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(PartyIdentityVerification.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    @IsTest
    static void getSObjectFieldListTestMethod() {
        SEL_PartyIdentityVerification partyProfileSelector = new SEL_PartyIdentityVerification();
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();
        Test.startTest(); 
        Map<String, Schema.SObjectField> fieldMap = PartyIdentityVerification.SObjectType.getDescribe().fields.getMap();       
        Test.stopTest();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    @IsTest
    static void selectByPartyProfileIdsTestMethod() {
        Account testAccount =KYC_TestDataFactory.createAccount();
        PartyProfile profileData =KYC_TestDataFactory.createPartyProfile(testAccount.id);
        PartyIdentityVerification verification =KYC_TestDataFactory.createPartyIdentity(profileData.id);
         Test.startTest(); 
        SEL_PartyIdentityVerification prodQueryList = new SEL_PartyIdentityVerification();
        prodQueryList.selectByPartyProfileIds(new set<id>{profileData.id});
        Test.stopTest();
        Assert.areEqual(true, verification!=null, 'Able to fetch Verification Information by PartyProfileId');
        
    }
    @IsTest
    static void selectByPartyProfileAccountIdTestMethod() {
        Account testAccount =KYC_TestDataFactory.createAccount();
        PartyProfile profileData =KYC_TestDataFactory.createPartyProfile(testAccount.id);
        PartyIdentityVerification verification =KYC_TestDataFactory.createPartyIdentity(profileData.id);
         Test.startTest(); 
        SEL_PartyIdentityVerification prodQueryList = new SEL_PartyIdentityVerification();
        prodQueryList.selectByPartyProfileAccountId(testAccount.id);
        Test.stopTest();
        Assert.areEqual(true, verification!=null, 'Identity Verification Information by AccountID ');
        
    }
    @IsTest
    static void selectByPartyProfileIdAndNameTestMethod() {
        Account testAccount =KYC_TestDataFactory.createAccount();
        PartyProfile profileData =KYC_TestDataFactory.createPartyProfile(testAccount.id);
        PartyIdentityVerification verification =KYC_TestDataFactory.createPartyIdentity(profileData.id);
         Test.startTest(); 
        SEL_PartyIdentityVerification prodQueryList = new SEL_PartyIdentityVerification();
        prodQueryList.selectByPartyProfileIdsAndName(new set<id>{profileData.id},profileData.name);
        Test.stopTest();
        Assert.areEqual(true, verification!=null, 'Able to Fetch Verification Information by PartyProfileId and Name');
        
    }
    
}