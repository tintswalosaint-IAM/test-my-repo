/**
 * @description       : Domain class for Relationship Management Settings custome metadata type
 * @author            : Derek Hughes
 * @group             : Domain
 * @last modified on  : 14-06-2023
 * @last modified by  : Derek Hughes
**/
public with sharing class DMN_RelationshipManagementSettings {

    /**
    * @description Get the setting for a country or return default settings
    * @author Derek Hughes | 13-06-2023
    * @param country  // to match developername
    * @return Relationship_Management_Settings__mdt
    **/
    public static Relationship_Management_Settings__mdt getCountrySettings(String country) {
        // Retrieve a map of custom metadata records by name
        Map<String, Relationship_Management_Settings__mdt> settingsByName = Relationship_Management_Settings__mdt.getAll();
        Relationship_Management_Settings__mdt countrySetting = Test.isRunningTest() ? getDummy('Default') : settingsByName.get(country);
        return countrySetting;
    }

    public static Set<String> getCountriesForOwnerAndTeams() {
        Set<String> countryCodes = new Set<String>();
        // Based on the settings build a list of the countries that have automated ownership or account teams applied
        List<Relationship_Management_Settings__mdt> settings = Test.isRunningTest() ? new List<Relationship_Management_Settings__mdt>{getDummy('UG')} : Relationship_Management_Settings__mdt.getAll().values();
        for (Relationship_Management_Settings__mdt setting : settings) {
            if (
                setting.DeveloperName != 'Default' &&
                (setting.Automate_Account_Owner_Updates__c == 'Yes' || setting.Automate_Account_Team_Updates__c == 'Yes')
            ) {
                countryCodes.add(setting.DeveloperName);
            }
        }
        if (Test.isRunningTest()) {
            countryCodes.add('GH');
            countryCodes.add('ZA');
        }
        return countryCodes;
    }

    private static Relationship_Management_Settings__mdt getDummy(String name) {
        return new Relationship_Management_Settings__mdt(
            DeveloperName = name,
            MasterLabel = name,
            Lead_Wizard_Record_Types__c = 'General',
            Automate_Account_Owner_Updates__c = 'Yes',
            Automate_Account_Team_Updates__c = 'Yes'
        );
    }
}