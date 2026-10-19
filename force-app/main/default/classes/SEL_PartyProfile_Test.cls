/**
 * @Name of the class: SEL_PartyProfile_Test.cls
 * @description Test class for Selector Class for PartyProfile Entity Test class
 *  
 * Story: SFP-37439
 * 
 * @autor Ikyatha Naidu  
*
* @date 29/03/2024
*********************************
* @last modified on  :  07/11/2024
* @last modified by  : Dhriven Hamlall
* @ Modification Description :SFP-32079, Updated to latest version
 */
@isTest
public class SEL_PartyProfile_Test {
    
    /**
     * @description Setup test data for PartyProfile tests
     */
    @testSetup
    static void setupTestData() {
        Account accRec = ICS_DAL_TestFactory.createAccount();        
       ICS_DAL_TestFactory.createPartyProfile(accRec.Id); 
        ICS_DAL_TestFactory.createBusinessOwnerPartyProfile(accRec.Id);
        
        // Create PartyProfile for Account
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;
        PartyProfile ppAcc = WI_DAL_DataFactory.createPartyProfile(null, acc.Id, null);
        insert ppAcc;
        
        // Create PartyProfile for Lead
        Lead leadObj = WI_DAL_DataFactory.createLead(null);
        insert leadObj;
        PartyProfile ppLead = WI_DAL_DataFactory.createPartyProfile(null, null, leadObj.Id);
        insert ppLead;
    }

    /**
     * @description Verify the SObjectType functionality
     */
    @IsTest
    static void testGetSObjectType() {
        SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();
        Assert.areEqual(PartyProfile.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
     * @description Verify the SObjectFieldList functionality
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();
        Map<String, Schema.SObjectField> fieldMap = PartyProfile.SObjectType.getDescribe().fields.getMap();              
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.areEqual(true, fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    } 
      
    /**
     * @description Verify the selection of PartyProfile by Account Ids
     */
    @isTest
    private static void testSelectByAccountIds(){
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_PartyProfile profileSelector = new SEL_PartyProfile();
        Test.startTest();   
        List<PartyProfile> partyProfileList = profileSelector.selectByAccountIds(new Set<Id>{accRec.Id});       
        profileSelector.selectByAccountIds(null);
        Test.stopTest();
        Assert.areEqual(true, partyProfileList != null, 'Expected PartyProfileList to contain at least one item.');
    }
    
    /** 
     * @description Verify the selection of PartyProfiles by Ids
     */
    @isTest
    public static void testSelectByIds(){
        PartyProfile profileData = [SELECT Id FROM PartyProfile LIMIT 1];
        SEL_PartyProfile profileSelector = new SEL_PartyProfile();
        Test.startTest();   
        List<PartyProfile> partyProfileList = profileSelector.selectByIds(new Set<Id>{profileData.Id});      
        profileSelector.selectByIds(null);
        Test.stopTest();
        Assert.areEqual(true, partyProfileList != null, 'PartyProfile list to return records .');
    }
   
    /** 
     * @description Verify the selection of PartyProfile by Id
     */
    @isTest
    public static void testSelectById(){
        PartyProfile profileData = [SELECT Id FROM PartyProfile LIMIT 1];
        SEL_PartyProfile profileSelector = new SEL_PartyProfile();
        Test.startTest();   
        PartyProfile partyProfileData = profileSelector.selectById(profileData.Id);      
        profileSelector.selectById(null);
        Test.stopTest();
        Assert.areNotEqual(null, partyProfileData, 'Expected PartyProfile to contain at least one item.');
    }
  
    /** 
     * @description Verify the selection of PartyProfiles by Account Id
     */
    @isTest
    public static void testSelectByAccountId(){
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_PartyProfile profileSelector = new SEL_PartyProfile();
        Test.startTest();   
        List<PartyProfile> partyProfileList = profileSelector.selectByAccountId(accRec.Id);       
        profileSelector.selectByAccountId(new set<Id>{accRec.Id});
        List<PartyProfile> partyProfileRoleList = profileSelector.selectByAccountIdANDPrimaryIdentifier(accRec.Id,'test role');
        profileSelector.selectByAccountIdandPrimaryIdentificationName(new set<Id>{accRec.Id},new set<string>{'test role'});
        Test.stopTest();
        Assert.areEqual(true, partyProfileList != null, 'PartyProfileList not to be empty.');
        Assert.areEqual(true, partyProfileRoleList != null, 'partyProfileRoleList not to be empty.');
    }
     /** 
     * @description Verify the selection of PartyProfiles by Account Id
     */
    @isTest
    public static void testselectByAccountAndRecordType(){
        Account accRec = [SELECT Id FROM Account LIMIT 1]; 
        SEL_PartyProfile profileSelector = new SEL_PartyProfile(); 
        Test.startTest();   
       PartyProfile partyProfileList = profileSelector.selectByAccountAndRecordType(accRec.Id,'ICS_PartyProfile');   
        profileSelector.selectByIdsandRecordType(new set<Id>{accRec.Id},'ICS_PartyProfile');
        Test.stopTest();
        Assert.areEqual(true, partyProfileList != null, 'Expected PartyProfileList to contain at least one item.');
    }
    
     
    /** 
     * @description Verify the selection of Business Owner PartyProfile by Account Id
     */
    @isTest
    public static void testSelectBusinessOwnerByPartyProfileIds(){
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_PartyProfile profileSelector = new SEL_PartyProfile();
        Test.startTest();   
        List<PartyProfile> partyProfileList = profileSelector.selectBusinessOwnerByPartyProfileId(accRec.Id);      
        profileSelector.selectBusinessOwnerByPartyProfileId(null); 
        Test.stopTest();
        Assert.areEqual(false, !partyProfileList.IsEmpty(), 'Expected PartyProfileList zero.');
    }
    /** 
     * @description Verify the selection of PartyProfiles by RelatedPartyProfileId Id
     */
  @isTest
    static void selectByRelatedPartyProfileIdsTest() {
        List<PartyProfile> profiles = [SELECT Id, RelatedPartyProfileId FROM PartyProfile];
        Set<Id> relatedIds = new Set<Id>();
        for (PartyProfile p : profiles) {
            relatedIds.add(p.RelatedPartyProfileId);
        }
        SEL_PartyProfile selector = new SEL_PartyProfile();
        List<PartyProfile> result = selector.selectByRelatedPartyProfileIds(relatedIds);
        selector.selectByPartyAssetFund(profiles[0].id);
        Assert.areEqual(4, result.size(), '4 profiles should have been returned.');
    }
    /** 
     * @description Verify the selection of PartyProfiles by RelatedPartyProfileId Id
     */
     @isTest
    static void selectByFirstLastNameandDateofBirthTest() { 
        List<PartyProfile> profiles = [SELECT Id,Birthdate__c, RelatedPartyProfileId FROM PartyProfile];
        Set<Id> relatedIds = new Set<Id>();
        for (PartyProfile p : profiles) {
            relatedIds.add(p.RelatedPartyProfileId);
        }

        SEL_PartyProfile selector = new SEL_PartyProfile();
        List<PartyProfile> result = selector.selectByFirstLastNameandDateofBirth('','',profiles[0].Birthdate__c,'');
        Assert.areEqual(2, result.size(), '2 profiles should have been returned.');
    }
      
    /**
* @author Dhriven Hamlall | 7-11-2024
* @description Unit test for the selectInsuranceIndividualPartyProfileById method in the SEL_PartyProfile class.
*              Verifies that PartyProfile records associated with a Lead and filtered by the 'Insurance_Individual' 
*              RecordType are successfully selected.
* @test Creates a test Lead, retrieves PartyProfile records filtered by 'Insurance_Individual' RecordType 
*       using the selectInsuranceIndividualPartyProfileById method, and asserts that the result is not empty.
*/
    @IsTest
    static void leadSelectInsuranceIndividualPartyProfileById() {
        SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'Smith' LIMIT 1];
        Test.startTest();
        List<PartyProfile> profilesByLead = partyProfileSelector.selectInsuranceIndividualPartyProfileById(lead.Id, true);
        Test.stopTest(); 
        Assert.areEqual(true, !profilesByLead.isEmpty(), 'Expected profilesByLead to contain at least one item.');
    }
    
    /**
* @author Dhriven Hamlall | 7-11-2024
* @description Unit test for the selectInsuranceIndividualPartyProfileById method in the SEL_PartyProfile class.
*              Verifies that PartyProfile records associated with an Account and filtered by the 'Insurance_Individual' 
*              RecordType are successfully selected.
* @test Creates a test Account, retrieves PartyProfile records filtered by 'Insurance_Individual' RecordType 
*       using the selectInsuranceIndividualPartyProfileById method, and asserts that the result is not empty.
*/
    
    @IsTest
    static void accountSelectInsuranceIndividualPartyProfileById() {
        SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        Account acc = [Select Id FROM Account WHERE LastName = 'Snow' LIMIT 1];
        Test.startTest();
        List<PartyProfile> profilesByAccount = partyProfileSelector.selectInsuranceIndividualPartyProfileById(acc.Id, false);
        Test.stopTest();
        Assert.areEqual(true, !profilesByAccount.isEmpty(), 'Expected profilesByAccount to contain at least one item.');
    }
}