/**
 * @description       : Selector Class for AOB_ReferencedData__c Entity
 * @author            : Jagadish Thummala
 * @last modified on  : 11-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public inherited sharing class SEL_ReferenceData extends sbgplatform.fflib_SObjectSelector{
    private static Set<String> fields = new Set<String>{'Id', 
       'Name',
       'AOB_Code__c',
       'AOB_SapField__c',
       'AOB_CountryCode__c',
       'AOB_ProductCategory__c',
       'AOB_Parent__c'
       
   };

   /**
   * @description Implementation method for Lead Object as part of fflib framweork
   * @return Schema.SObjectType 
   **/
   public override Schema.SObjectType getSObjectType() {
       return AOB_ReferencedData__c.sObjectType;
   }

   /**
   * @description Method to get list of fields to be part of response
   * @return List<Schema.SObjectField> 
   **/
   public override List<Schema.SObjectField> getSObjectFieldList() {
       return new List<Schema.SObjectField> {
           AOB_ReferencedData__c.Id, 
           AOB_ReferencedData__c.Name,
           AOB_ReferencedData__c.AOB_Code__c,
           AOB_ReferencedData__c.AOB_SapField__c,
           AOB_ReferencedData__c.AOB_CountryCode__c,
           AOB_ReferencedData__c.AOB_ProductCategory__c
       };
   }

    /**
   * @description Method to fetch list of Applications based on Application Id
   * @param sapCode 
    * @param fieldName 
   * @return List<AOB_ReferencedData__c> 
   **/
   public List<AOB_ReferencedData__c> getReferencedDataName(String sapCode, String fieldName) {
       sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
       fieldQueryFactory.setCondition('AOB_SapField__c =:sapCode');
       fieldQueryFactory.selectFields(fields);   
       fieldQueryFactory.setOrdering(fieldName, sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);   
       return Database.query(fieldQueryFactory.toSOQL());  
   } 
    
    public List<AOB_ReferencedData__c> getChildReferencedData(String ParenentName) {
       sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
       fieldQueryFactory.setCondition('AOB_Parent__r.Name  =:ParenentName');
       fieldQueryFactory.selectFields(fields);   
       return Database.query(fieldQueryFactory.toSOQL());  
   }

     public List<AOB_ReferencedData__c> getReferencedDataByName(String name) {
       sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
       fieldQueryFactory.setCondition('Name  =:name');
       fieldQueryFactory.selectFields(fields);   
       return Database.query(fieldQueryFactory.toSOQL());  
   }

}