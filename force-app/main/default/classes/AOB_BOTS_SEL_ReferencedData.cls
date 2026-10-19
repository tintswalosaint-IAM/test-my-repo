/**
 * @description       : Selector Class for AOB_ReferencedData__c Entity
 * @author            : Narendra Teja
 * @last modified on  : 09-04-2023
 * @last modified by  : Narendra Teja
**/
@SuppressWarnings('PMD.SOQLInjection') 
public inherited sharing class AOB_BOTS_SEL_ReferencedData extends sbgplatform.fflib_SObjectSelector{
     private static Set<String> fields = new Set<String>{'Id', 
        'Name',
        'AOB_Code__c',
        'AOB_SapField__c',
        'AOB_CountryCode__c',
        'AOB_ProductCategory__c',
        'AOB_Value__c'
        
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
    * @param AOB_SapField 
    * @param fieldName 
    * @param FLS_Scecurity 
    * @return List<AOB_ReferencedData__c> 
    **/
    public List<AOB_ReferencedData__c> getReferencedDataBySapField(String AOB_SapField, String fieldName , Boolean FLS_Scecurity) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('AOB_SapField__c =:AOB_SapField');
    	fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering(fieldName, sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
        if(FLS_Scecurity){
            fieldQueryFactory.setEnforceFLS(true);
        }
    	return Database.query(fieldQueryFactory.toSOQL());
    }

     /**
    * @description Method to fetch list of Applications based on Application Id
    * @param sapCode 
    * @param cardCode 
    * @return List<AOB_ReferencedData__c> 
    **/
    public List<AOB_ReferencedData__c> getReferencedDataName(String sapCode,String cardCode) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('AOB_SapField__c =:sapCode AND AOB_Code__c=:cardCode');
    	fieldQueryFactory.selectFields(fields);      
    	return Database.query(fieldQueryFactory.toSOQL());  
    }

    /**
    * @description Method to fetch AOB_ReferencedData__c based on Application Id
    * @param cardCode 
    * @return AOB_ReferencedData__c
    **/
    public AOB_ReferencedData__c getReferencedDataByCode(String cardCode) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('AOB_Code__c=:cardCode');
    	fieldQueryFactory.selectFields(fields); 
        fieldQueryFactory.setLimit(1);     
    	return Database.query(fieldQueryFactory.toSOQL());  
    } 

}