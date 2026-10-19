/**
 * @description       : Selector Class for ApplicationFormProduct Entity
 * @author            : Ikyatha Naidu
 * @last modified by  : Tushar Walse
 * @last modified on  : 16-10-2024
**/
public inherited sharing class SEL_ApplicationFormProduct extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{'Id', 'ApplicationFormId', 'ProductId', 'Product.ProductCode','Product.Name'};
            
    /**
    * @description Implementation method for Account Object as part of fflib framweork
    * @author Ikyatha Naidu | 30-10-2023
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return ApplicationFormProduct.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @author Ikyatha Naidu| 05-31-2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ApplicationFormProduct.Id, 
            ApplicationFormProduct.ProductId,
            ApplicationFormProduct.Product2.Name
            };
    }
    
    /**
    * @description Method to fetch list of records based on ApplicationFormIds 
    * @author Tushar Walse | 30-09-2024
    * @param ids Set of id's of records to be retrieved
    * @return List<ApplicationFormProduct> 
    **/
    public List<ApplicationFormProduct> selectByApplicationFormIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ApplicationFormId in : ids');
        fieldQueryFactory.selectFields(fields); 
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}