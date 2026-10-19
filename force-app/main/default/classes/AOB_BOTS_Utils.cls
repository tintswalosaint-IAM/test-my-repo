/**
 * @description Utility methods for Botswana project
 *
 * @author VenkataRamadevi Ravuri
 *
 * @date april 9th 2023
 */
public with sharing class AOB_BOTS_Utils {
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = AOB_Utils.class.getName();
    /**
    * @description to get the user language
    * returns String
    */
    public static String getUserLanguage(){
        //If the flow screen does not have any records with the user language, default to English 
        String language = UserInfo.getLanguage();
        
        return language;
    } 

    /**
     * @description	method to fetch the picklist values from the refrenced Data Table
     * @param 	sapFields
     * @return	Map<String, List<AOB_DTO_SelectOption>>
     */
    public static Map<String, List<AOB_DTO_SelectOption>> getAllPicklistEntriesCodes(List<String> sapFields) {
        Map<String, List<AOB_DTO_SelectOption>> result = new Map<String, List<AOB_DTO_SelectOption>>();
        System.debug('userInfo'+ UserInfo.getLanguage());
        List<AOB_ReferencedData__c> referencedDataList = [
            SELECT Id, AOB_Code__c, Name, AOB_Default__c, AOB_SAPField__c
            FROM AOB_ReferencedData__c
            WHERE AOB_SAPField__c IN :sapFields AND AOB_Language__c = :UserInfo.getLanguage() AND AOB_isActive__c = TRUE
            ORDER BY AOB_Sequence__c ASC
        ];
        for (AOB_ReferencedData__c data : referencedDataList) {
            if (result.containskey(data.AOB_SAPField__c)) {
                result.get(data.AOB_SAPField__c).add(new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c));
            } else {
                result.put(data.AOB_SAPField__c, new List<AOB_DTO_SelectOption>{ new AOB_DTO_SelectOption(data.AOB_Code__c, data.Name, data.AOB_Default__c) });
            }
        }
        return result;
    }
}