/**
* @description Class for fetch Rely Comply Tertiory Sector Records
*
* Story:SFP-
*
* @author Lokesh Bothsa
*
* @date August 2023
*/
public without sharing class BCB_CTRL_SectorPicklists {
    @AuraEnabled
    public static List<AOB_ReferencedData__c> fetchTertiorySectorCodes(string secondarySector){
        string query = 'SELECT Id,AOB_Code__c,Name,AOB_isActive__c,AOB_Language__c,AOB_CountryCode__c,AOB_Default__c,AOB_SAPField__c,AOB_Sequence__c from AOB_ReferencedData__c where AOB_Code__c LIKE  \'%' + secondarySector +'%\' And AOB_Code__c !=\''+secondarySector+'\'';
       
        List<AOB_ReferencedData__c> lstOfTertiorySectorCodes = Database.query(query);
        return lstOfTertiorySectorCodes;
    }
}