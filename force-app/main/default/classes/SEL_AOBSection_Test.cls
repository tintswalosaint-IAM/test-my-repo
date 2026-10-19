/*************************************************************************************
 * @description Field Selector Layer
 * @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
 * @date Oct 29th 2021
 *************************************************************************************
 * @last Modified By : Ikyatha Naidu
 * @last Modified On : 06-06-2024
 * @modification description: SFP-30128 updated to latest version and added method to fetch child fields
 *************************************************************************************/
@isTest
public class SEL_AOBSection_Test {

    @TestSetup
    static void setupTestData() {
        List<AOB_FlowScreen__c> FlowScreenList = ICS_DAL_TestFactory.createScreen();
        ICS_DAL_TestFactory.createSection(FlowScreenList[0].Id);
    }

    /**
    * @description Verify that the SObjectType returned is AOB_ScreenSection__c.SObjectType
    */
    @IsTest
    static void testGetSObjectType() {
        SEL_AOBSection sectionSelector = new SEL_AOBSection();
        Test.startTest();
        Schema.SObjectType sObjectType = sectionSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(AOB_ScreenSection__c.SObjectType, sObjectType, 'The returned SObjectType does not match AOB_ScreenSection__c.SObjectType');
    }

    /**
    * @description Verify that the SObjectFieldList returned is not empty and contains valid fields
    */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_AOBSection sectionSelector = new SEL_AOBSection();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = sectionSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = AOB_ScreenSection__c.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in AOB_ScreenSection__c field map');
        }
    }

    /**
    * @description Verify that a list of AOB_ScreenSection__c is returned for the given screen name
    */
    @IsTest
    static void testSelectSectionsByScreenName() {
        SEL_AOBSection sectionSelector = new SEL_AOBSection();
        Test.startTest();
        List<AOB_ScreenSection__c> screenSectionListData = sectionSelector.selectSectionsByScreenName('ICS UK Pre-Account Details');
        Test.stopTest();
        Assert.areEqual(3, screenSectionListData.size(), 'Expected 3 AOB_ScreenSection__c records for the screen name: ICS UK Pre-Account Details');
    }

    /**
    * @description Verify that a list of AOB_ScreenSection__c is returned for the given list of screen names
    */
    @IsTest
    static void testSelectSectionsByScreenNameList() {
        SEL_AOBSection sectionSelector = new SEL_AOBSection();
        List<String> listScreenNames = new List<String>{'ICS UK Pre-Account Details'};
        Test.startTest();
        List<AOB_ScreenSection__c> screenSectionListData = sectionSelector.selectSectionsByScreenNameList(listScreenNames);
        Test.stopTest();
        Assert.areEqual(3, screenSectionListData.size(), 'Expected 3 AOB_ScreenSection__c records for the screen names: ICS UK Pre-Account Details');
    }
}