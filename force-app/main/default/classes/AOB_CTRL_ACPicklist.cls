/**
 * @description       : This function will 
 * @author            : Chibuye Kunda
 * @group             : 
 * @last modified on  : 10-14-2021
 * @last modified by  : Chibuye Kunda
**/
public with sharing class AOB_CTRL_ACPicklist {
    /**
    * @description This function will search for potential matches
    * @param   targetValue
    * @return List<AOB_ReferencedData__c> 
    **/
    @AuraEnabled
    public static List<AOB_ReferencedData__c> loadData(String targetValue){
        List<AOB_ReferencedData__c> referenceDataList;
        try{
            referenceDataList = New AOB_BOTS_SEL_ReferencedData().getReferencedDataBySapField(targetValue,'Name', true);
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