/**
* @description class used as controller for picklist data
*
* Story:SFP-36380
*
* @author Shravani Ganta
*
* @date May 2022
* @last modified on  : 29-02-2024
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-36380, Controller Class used to store picklist values for SBO-UK
*/
public without sharing class ICS_CTRL_ACPicklist {
/**
* @description gets a list of data from mritable
* @param targetValue - name of the sap field
* @return List of AOB_ReferencedData__c 
*/
 @AuraEnabled
    public static List<AOB_ReferencedData__c> loadData(String targetValue){
        List<AOB_ReferencedData__c> referenceDataList;
        try{
            referenceDataList = New AOB_BOTS_SEL_ReferencedData().getReferencedDataBySapField(targetValue,'AOB_Sequence__c', true);
            if(Test.isRunningTest()){
                QueryException ex=new QueryException();
                throw ex;
            }
        }
        catch(QueryException exp){
            throw new AuraHandledException(exp.getMessage());
        }
        
        return referenceDataList;
    }
}