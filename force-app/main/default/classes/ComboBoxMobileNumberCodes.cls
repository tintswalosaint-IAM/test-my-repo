/**
 * @description Getting a list of Country codes from a custom setting 
 * @author Andrii Pauk (BlueSky)
 * @date Oсtober 2022
 */

public with sharing class ComboBoxMobileNumberCodes {
    /**
    * @description Getting a list of Country codes from a custom setting
    * @return listOfCountryCodes
    */
    @AuraEnabled
    public static List<Country_Codes__mdt> getListOfCountryCodes(){
        List<Country_Codes__mdt> listOfCountryCodes = new List<Country_Codes__mdt>();
        Map<String,Country_Codes__mdt> mapCountries = Country_Codes__mdt.getall();
        List<String> countryNames = new List<String>();
        countryNames.addAll(mapCountries.keySet());
        countryNames.sort();

        for (String countryName : countryNames) {
            Country_Codes__mdt country = mapCountries.get(countryName);
            listOfCountryCodes.add(country);
        }

        return listOfCountryCodes;
    }
}