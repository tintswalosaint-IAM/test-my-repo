/**
 * @Name of the class: SEL_IdentityDocument_Test
 * @description Test class for the SEL_IdentityDocument selector class
 * 
 * Story: SFP-37439
 * 
 * @author Ikyatha Naidu
 * @date 29/03/2024
 *********************************
 * @last modified on: 01/07/2024
 * @last modified by: Ikyatha Naidu
 * @Modification Description: SFP-30275, Updated to latest version
 */
@isTest
public class SEL_IdentityDocument_Test {
      /**
     * @description test setup
     */
    @testSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        PartyProfile party = ICS_DAL_TestFactory.createPartyProfile(acc.Id);
        ICS_DAL_TestFactory.createIdentityDocument(acc.Id, party.Id);
    }

    /**
     * @description Verify the getSObjectType method
     */
    @isTest
    static void testGetSObjectType() {
        SEL_IdentityDocument partyProfileSelector = new SEL_IdentityDocument();
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();  
        Assert.areEqual(IdentityDocument.SObjectType, sObjectType, 'Expected IdentityDocument SObjectType.');
    }

    /**
     * @description Verify the getSObjectFieldList method
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_IdentityDocument partyProfileSelector = new SEL_IdentityDocument();
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();
        Assert.areNotEqual(0, sObjectFieldList.size(), 'Expected fields list to contain at least one item.');
    }

    /**
     * @description Verify the selectIdentityDocumentsByAccountId method
     */
    @isTest
    static void testSelectByAccountId() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SEL_IdentityDocument identityDocumentSelector = new SEL_IdentityDocument();       
        Test.startTest();
        List<IdentityDocument> identityDocumentList = identityDocumentSelector.selectByAccountId(acc.Id);
        Test.stopTest();
        Assert.areNotEqual(0, identityDocumentList.size(), 'Expected IdentityDocument list to contain at least one item.');
    }

    /**
     * @description Verify the selectIdentityDocumentsByAccountIds method
     */
    @isTest
    static void testSelectByAccountIds() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Set<Id> ids = new Set<Id>{acc.Id};
        SEL_IdentityDocument identityDocumentSelector = new SEL_IdentityDocument();        
        Test.startTest();
        List<IdentityDocument> identityDocumentList = identityDocumentSelector.selectByAccountIds(ids);  
        Test.stopTest();
        Assert.areNotEqual(0, identityDocumentList.size(), 'Expected IdentityDocument list to contain at least one item.');
    }

    /**
     * @description Verify the selectIdentityDocumentByPartyProfileId method
     */
    @isTest
    static void testSelectByPartyProfileId() {
        PartyProfile party = [SELECT Id FROM PartyProfile LIMIT 1];
        SEL_IdentityDocument identityDocumentSelector = new SEL_IdentityDocument();        
        Test.startTest();
        IdentityDocument identityDoc = identityDocumentSelector.selectByPartyProfileId(party.Id);
        Test.stopTest();
        Assert.areNotEqual(null, identityDoc, 'Expected IdentityDocument to be returned.');
    }


    @IsTest
    static void testSelectByName() {
        IdentityDocument existingDoc = [SELECT Id, Name FROM IdentityDocument LIMIT 1];
        
        SEL_IdentityDocument identityDocumentSelector = new SEL_IdentityDocument();
        Test.startTest();
        List<IdentityDocument> result = identityDocumentSelector.selectByName(existingDoc.Name);
        Test.stopTest();

        Assert.areNotEqual(0, result.size(), 'Expected at least one IdentityDocument to be returned');
        Assert.isNotNull(result[0].RelatedLegalEntityId, 'RelatedLegalEntityId should not be null');
    }
}