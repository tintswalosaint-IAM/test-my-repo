/**
 * @description       : Test for DMN_RelationshipManagementSettings
 * @author            : Derek Hughes
 * @group             : Test
 * @last modified on  : 14-06-2023
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class DMN_RelationshipManagementSettings_Test {

    @IsTest
    static void testGetters () {
        Test.startTest();
        Relationship_Management_Settings__mdt countrySettings =  DMN_RelationshipManagementSettings.getCountrySettings ('XX');
        Test.stopTest();
        Assert.areEqual(countrySettings.DeveloperName, 'Default', 'Could not find Default settings');
    }

    @IsTest
    static void testCountriesMDT() {
        Test.startTest();
        Set<String> countryCodes = DMN_RelationshipManagementSettings.getCountriesForOwnerAndTeams();
        Test.stopTest();
        Assert.areEqual(true, !countryCodes.isEmpty(), 'No Country Found!');
    }

}