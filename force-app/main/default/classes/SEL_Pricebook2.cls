/**
* @description       : Selector Class for Pricebook2 Entity
* @author            : Ihtishaam Mohammoodally
* @last modified on  : 01-11-2024
**/


public inherited sharing class SEL_Pricebook2 extends sbgplatform.fflib_SObjectSelector {

    private static Set<String> fields = new Set<String>{
                                                'Id',  
                                                'Name', 
                                                'IsActive',
                                                'CurrencyIsoCode'
            };
                
     /**
     *@description This is used to retrieve the sObject name when building the SOQL queries.
     *
     * @return Schema.SObjectType
    */
    public override Schema.SObjectType getSObjectType(){
        return Pricebook2.SObjectType;
    }
    

    /**
     *@description This is used to retrieve a specific set of SObject fields
     *
     * @return List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PricebookEntry.Id,
            Pricebook2.Name,
            Pricebook2.IsActive,
            Pricebook2.CurrencyIsoCode
        };
    }        
    
    /**
* @description Fetches a pricebook using a condition
* @param Condition
* @return List<Pricebook2>
*/
    public List<Pricebook2> selectPriceBook(String condition) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition(condition);
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);  
        return (List<Pricebook2>) Database.query(fieldQueryFactory.toSOQL());
    }
     
}