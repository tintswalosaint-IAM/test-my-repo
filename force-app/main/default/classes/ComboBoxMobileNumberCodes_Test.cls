@isTest
public with sharing class ComboBoxMobileNumberCodes_Test {
    @isTest
    static void getListOfCountryCodesTest() {
        Test.startTest();
        List<Country_Codes__mdt> result = ComboBoxMobileNumberCodes.getListOfCountryCodes();
        Test.stopTest();

        System.assert(result.size() > 0, 'Failed to get a list of country codes');
    }
}