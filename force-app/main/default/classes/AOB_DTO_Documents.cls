/**
 * Class wrapper for documents
 * 
 * <p></p> 
 * 
 * @author Achraf ABOUL (aaboul@salesforce.com)
 * 
 * @date Dec 18th 2020 
 */
 public with sharing class AOB_DTO_Documents {
    public List<AOB_DTO_Document> documentsToUpload {get;set;}
    public String commerceSite {get;set;}
    @AuraEnabled
    public Integer errorCode {get;set;}
    @AuraEnabled
    public String message {get;set;}

    public AOB_DTO_Documents() {
        
    }
    public class AOB_DTO_Document {
        public String label {get;set;}
        public String conditionStatus {get;set;}
        public Boolean showToCustomer {get;set;}
        public String conditionCode {get;set;}
        public DOC_DTO_Conditions.ConditionKey conditionKey {get;set;}

        public AOB_DTO_Document() {
            conditionKey = new DOC_DTO_Conditions.ConditionKey();
        } 
    }
}