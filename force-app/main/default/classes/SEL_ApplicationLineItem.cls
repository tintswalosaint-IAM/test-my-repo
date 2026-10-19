/**
 * @description       : Selector Class for Application Line Item Entity
 * @author            : Narendra Teja
 * @last modified on  : 31-07-2023
 * @last modified by  : Siva Prasad
**/
public inherited sharing class SEL_ApplicationLineItem extends sbgplatform.fflib_SObjectSelector{
    private static Set<String> fields = new Set<String>{
        'Id', 
        'Name', 
        'Details__c', 
        'Application__c', 
        'AOB_Main__c', 
        'CNGCU_Price__c', 
        'Product__c', 
        'AOB_ProductCode__c', 
        'AOB_Status__c', 
        'CurrencyIsoCode',
        'AOB_Status__c'
       
    };
        
   
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Narendra Teja | 03-07-2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Application_Line_Item__c.Id, 
            Application_Line_Item__c.Name, 
            Application_Line_Item__c.CreatedDate, 
            Application_Line_Item__c.Details__c, 
            Application_Line_Item__c.Application__c,
            Application_Line_Item__c.CurrencyIsoCode,
            Application_Line_Item__c.AOB_Main__c,
            Application_Line_Item__c.LastModifiedById, 
            Application_Line_Item__c.CNGCU_Price__c,
            Application_Line_Item__c.Product__c,
            Application_Line_Item__c.AOB_ProductCode__c,
            Application_Line_Item__c.AOB_Status__c
        };
    }
    
    
     /**
    * @description Implementation method for Application Participant Object as part of fflib framweork
    * @author Narendra Teja | 03-07-2023 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
    	return Application_Line_Item__c.sObjectType;
    }
    
  
    /**
     * @description Method to fetch list of Application Line Item based on Id
     * @param appLineItemId
     * @return List<Application_Line_Item__c>
     */
    public List<Application_Line_Item__c> selectApplicationLineItemById(Id appLineItemId) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Id =:appLineItemId');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

     /**
     * @description Method to fetch list of Application Line Item based on List<Id>
     * @param appLineItemIdList
     * @return List<Application_Line_Item__c>
     */
    public List<Application_Line_Item__c> selectApplicationLineItemByIds(List<Id> appLineItemIdList) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Id IN:appLineItemIdList');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Method to fetch list of Application Participants based on Application Ids
     * @param applicationId
     * @return List<Application_Line_Item__c>
     */
    public List<Application_Line_Item__c> selectApplicationLineItemByApplicationId(String applicationId) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Application__c =:applicationId');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Method to fetch list of Application Participants based on Application Ids
     * @param applicationId
     * @param aobMain
     * @return List<Application_Line_Item__c>
     */
    public List<Application_Line_Item__c> selectApplicationLineItemByFilter(String applicationId, Boolean aobMain) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Application__c =:applicationId AND AOB_Main__c=:aobMain');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

}