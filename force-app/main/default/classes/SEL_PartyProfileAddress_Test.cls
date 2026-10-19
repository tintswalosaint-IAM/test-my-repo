/**
 * @Name of the Class : SEL_PartyProfileAddress_Test
 * @description       : SFP-36380 Selector Test class for SEL_PartyProfileAddress object.
 *                      This test class is designed to validate the functionality of the SEL_PartyProfileAddress
 *                      selector methods. It ensures that the methods for retrieving PartyProfileAddress records 
 *                      work as expected across different scenarios.
 * 
 * @author            : Ikyatha Naidu 
 * @date              : 17/05/2024
 ********************************************
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @Modification Description : Updated to the latest version, added comprehensive test methods to cover
 *                              various use cases and ensure robust testing of the selector methods.
 **/

@IsTest
public class SEL_PartyProfileAddress_Test {
	@TestSetup
    static void setupTestData() {

  		Account testAccount = ICS_DAL_TestFactory.createAccount();
        PartyProfile profileData = ICS_DAL_TestFactory.createPartyProfile(testAccount.id);
        ICS_DAL_TestFactory.createPartyProfileAddress(profileData.id, 'Residential Address', Date.today() - 30, null);
    }
    /**
     * @description: Tests that the `getSObjectType` method returns the correct SObjectType for the PartyProfileAddress` .
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_PartyProfileAddress partyProfileSelector = new SEL_PartyProfileAddress();
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();
        Assert.areEqual(PartyProfileAddress.SObjectType, sObjectType, 'Unexpected SObjectType');
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();
        Map<String, Schema.SObjectField> fieldMap = PartyProfileAddress.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.areEqual(true, fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in field map');
        }
    }

    /**
     * @description: Tests the `selectById` method to ensure it correctly retrieves a `PartyProfileAddress`record based on its ID. 
     */
    @IsTest
    static void selectPartyProfileAddressByIdTestMethod() {
       PartyProfileAddress preaddressData=[select id from PartyProfileAddress limit 1];
        SEL_PartyProfileAddress selPartyProfileAddress = new SEL_PartyProfileAddress();
        Test.startTest();
        List<PartyProfileAddress> PartyProfileAddressList = selPartyProfileAddress.selectById(preaddressData.id);
        Test.stopTest();
        Assert.areEqual(true, PartyProfileAddressList.size() > 0, 'Expected PartyProfileAddressList to contain at least one item.');
    }

    /**
     * @description: Tests the `selectCurrentAddressByPartyProfileId`method to ensure it retrieves the current address records for a given `PartyProfile` ID. 
     */
    @IsTest
    static void selectPartyProfileAddressByPartyProfileIdTestMethod() {
        
        PartyProfile profileData = [select id from partyprofile limit 1];
        SEL_PartyProfileAddress selPartyProfileAddress = new SEL_PartyProfileAddress();
        Test.startTest();
        List<PartyProfileAddress> PartyProfileAddressList = selPartyProfileAddress.selectCurrentAddressByPartyProfileId(profileData.id);
        Test.stopTest();
        Assert.areEqual(true, PartyProfileAddressList.size() > 0, 'Expected PartyProfileAddressList to contain at least one item.');
    }

    /**
     * @description: Verifies that the `selectByPartyProfileType` method correctly retrieves alternative address types (e.g., 'Other') for a given `PartyProfile` ID
     */
    @IsTest
    static void selectAltAddressByPartyProfileIdTestMethod() {
        
        PartyProfile profileData =[select id from PartyProfile limit 1];
        PartyProfileAddress ProfileAddress = ICS_DAL_TestFactory.createPartyProfileAddress(profileData.id, 'Other', null, null);

        SEL_PartyProfileAddress selPartyProfileAddress = new SEL_PartyProfileAddress();
        Test.startTest();
        List<PartyProfileAddress> PartyProfileAddressList = selPartyProfileAddress.selectByPartyProfileType(profileData.id, ProfileAddress.AddressType);
        Test.stopTest();
        Assert.areEqual(true, PartyProfileAddressList.size() > 0, 'Expected PartyProfileAddressList to contain at least one item.');
    }

    /**
     * @description: Tests the `selectCurrentResAddressByPartyProfileIds` method to ensure it retrieves the current residential address records for a set of `PartyProfile` IDs. 
     */
    @IsTest
    static void selectCurrentResAddressBySetOfPartyProfileIdsTestMethod() {
        PartyProfile profileData =[select id from PartyProfile limit 1];
        ICS_DAL_TestFactory.createPartyProfileAddress(profileData.id, 'Residential Address', Date.today() - 60, null);
        SEL_PartyProfileAddress selPartyProfileAddress = new SEL_PartyProfileAddress();
        Test.startTest();
        List<PartyProfileAddress> PartyProfileAddressList = selPartyProfileAddress.selectCurrentResAddressByPartyProfileIds(new Set<Id>{profileData.id});
        Test.stopTest();
        Assert.areEqual(true, PartyProfileAddressList.size() > 0, 'Expected PartyProfileAddressList to contain at least one item.');
    }

    /**
     * @description: Validates that the `selectPreviousAddressByPartyProfileId` method retrieves previous address 
     *                records for a given `PartyProfile` ID. The method is expected to return a list with past address records.
     */
    @IsTest
    static void selectPreviousPartyProfileAddressByPartyProfileIdTestMethod() {
        PartyProfile profileData =[select id from PartyProfile limit 1];
        ICS_DAL_TestFactory.createPartyProfileAddress(profileData.id, 'Residential Address', Date.today() - 60, Date.today() - 30);
        SEL_PartyProfileAddress selPartyProfileAddress = new SEL_PartyProfileAddress();
        Test.startTest();
        List<PartyProfileAddress> PartyProfileAddressList = selPartyProfileAddress.selectPreviousAddressByPartyProfileId(profileData.id);
        Test.stopTest();
        Assert.areEqual(true, PartyProfileAddressList.size() > 0, 'Expected PartyProfileAddressList to contain at least one item.');
    }

    /**
     * @description: Tests the `selectCoPartyProfileAddressByPartyProfileId` method to ensure it retrieves correspondence 
     *                addresses for a given `PartyProfile` ID. The method should return a list of correspondence addresses.
     */
    @IsTest
    static void selectCoPartyProfileAddressByPartyProfileIdTestMethod() {
        PartyProfile profileData =[select id from PartyProfile limit 1];
        ICS_DAL_TestFactory.createPartyProfileAddress(profileData.id, 'Correspondence Address', Date.today() - 60, Date.today() - 30);
        SEL_PartyProfileAddress selPartyProfileAddress = new SEL_PartyProfileAddress();
        Test.startTest();
        List<PartyProfileAddress> PartyProfileAddressList = selPartyProfileAddress.selectCorrespondanceAddressByPartyProfileId(profileData.id);
        Test.stopTest();
        Assert.areEqual(true, PartyProfileAddressList.size() > 0, 'Expected PartyProfileAddressList to contain at least one item.');
    }

}