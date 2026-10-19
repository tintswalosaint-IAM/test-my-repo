/**
 * @description       : Selector Class for ApplicationDocument Entity
 * @author            : Narendra Teja
 * @last modified on  : 03-08-2023
 * @last modified by  : Ramya Gurram
 * @ Modification Description : Used  External_Id__c for document name and added new method to get documents
**/
@SuppressWarnings('PMD.SOQLInjection') 
public inherited sharing class AOB_BOTS_SEL_ApplicationDocument extends sbgplatform.fflib_SObjectSelector{

    private static Set<String> fields = new Set<String>{
        'Id', 
        'Name', 
        'Document_Type__c', 
        'Application__c',
        'Application_Participant__c',
        'External_Id__c',
        'AOB_DocumentTypeDescription__c',
        'AOB_DocumentCode__c',
        'AOB_DocumentCodeDescription__c'
            
    };
        
    /**
    * @description Implementation method for ApplicationDocument Object as part of fflib framework
    * @author Narendra Teja | 03-07-2023 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return Application_Document__c.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Narendra Teja | 03-07-2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Application_Document__c.Id,
            Application_Document__c.Name,
            Application_Document__c.Application__c,
            Application_Document__c.Application_Participant__c,
            Application_Document__c.CreatedById,
            Application_Document__c.CurrencyIsoCode,
            Application_Document__c.AOB_DocumentCode__c,
            Application_Document__c.AOB_DocumentCodeDescription__c,
            Application_Document__c.Document_Type__c,
            Application_Document__c.AOB_DocumentTypeDescription__c,
            Application_Document__c.External_Id__c,
            Application_Document__c.LastModifiedById,
            Application_Document__c.OwnerId
        };
    }
    
    /**
     * Method to fetch list of ApplicationDocument based on Id
     * @param documentIds
     * @return List<Application_Document__c>
     */
    public List<Application_Document__c> selectApplicationDocumentById(List<Id> documentIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id in :documentIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }


    /**
     * Select by AppId & DocumentType
     * @param appId
     * @param Doctype
     * @return List<Application_Document__c>
     */
    public List<Application_Document__c> selectAppsByIdAndDoctype(String appId,String Doctype) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('Application__c = :appId and Document_Type__c=:Doctype');
        FieldQueryFactory.selectFields(fields);  
        return Database.query(FieldQueryFactory.toSOQL());
        
    }
    
     /**
     *@description Select by AppParticipantId & DocumentType
    * @param appId
     * @param Doctype
     * @return List<Application_Document__c>
     */
    public List<Application_Document__c> selectAppsParticipantByIdAndDoctype(String appId,String Doctype) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('Application_Participant__c = :appId and Document_Type__c=:Doctype');
        FieldQueryFactory.selectFields(fields);  
        return Database.query(FieldQueryFactory.toSOQL());
        
    }
    
    
    /**
     * Select by Application__c
     * @param appId
     * @return List<Application_Document__c>
     */
    public List<Application_Document__c> selectAppsByIdApplication(String appId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('Application__c = :appId');
        FieldQueryFactory.selectFields(fields);  
        return Database.query(FieldQueryFactory.toSOQL());
        
    }
    
    
    /**
     * Select by Application_Participant
     * @param appId
     * @return List<Application_Document__c>
     */
    public List<Application_Document__c> selectAppsByIdApplicationParcipant(String appId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('Application_Participant__c = :appId');
        FieldQueryFactory.selectFields(fields);  
        FieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        return Database.query(FieldQueryFactory.toSOQL());
        
    }
    
}