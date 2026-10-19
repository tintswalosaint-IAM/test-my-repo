/**
* @description       : Selector class for CMN_FHQ_CalculationFormula__mdt entity.
*                      Provides reusable query methods to retrieve category
*                      calculation formulas from Custom Metadata using the
*                      fflib selector framework.
* @author            : Preetham.Thernakal-Gandla@standardbank.co.za, Taimoor.Shaik@standardbank.co.za
* @created on        : Feb 2026
* @last modified on  :
* @last modified by  :
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
public inherited sharing class SEL_CMNCategoryCalculationFormulas extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Fields to be queried for CMN_FHQ_CalculationFormula__mdt records.
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'DeveloperName',
        'Label',
        'Category__c',
        'CMN_Weight__c',
        'Formula__c',
        'isComplex__c',
        'Normalized_Field__c',
        'Normalize__c',
        'Order__c',
        'Saved_to_Field__c'
    };
        
    /**
    * @description Returns the SObjectType for CMN_FHQ_CalculationFormula__mdt.
    *              Required implementation for the fflib selector framework.
    * @return Schema.SObjectType CMN_FHQ_CalculationFormula__mdt SObjectType
    **/
    public override Schema.SObjectType getSObjectType() {
        return CMN_FHQ_CalculationFormula__mdt.sObjectType;
    }
    
    /**
    * @description Returns the list of fields to be included in selector queries.
    * @return List<Schema.SObjectField> List of CMN_FHQ_CalculationFormula__mdt fields
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_FHQ_CalculationFormula__mdt.Id,
            CMN_FHQ_CalculationFormula__mdt.DeveloperName,
            CMN_FHQ_CalculationFormula__mdt.Label,
            CMN_FHQ_CalculationFormula__mdt.Category__c,
            CMN_FHQ_CalculationFormula__mdt.CMN_Weight__c,
            CMN_FHQ_CalculationFormula__mdt.Formula__c,
            CMN_FHQ_CalculationFormula__mdt.isComplex__c,
            CMN_FHQ_CalculationFormula__mdt.Normalized_Field__c,
            CMN_FHQ_CalculationFormula__mdt.Normalize__c,
            CMN_FHQ_CalculationFormula__mdt.Order__c,
            CMN_FHQ_CalculationFormula__mdt.Saved_to_Field__c
        };
    }
    
    /**
    * @description Retrieves all CMN_FHQ_CalculationFormula__mdt records.
    * @return List<CMN_FHQ_CalculationFormula__mdt> List of category calculation formulas
    **/
    public List<CMN_FHQ_CalculationFormula__mdt> getCategoryCalculationFormulas() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);

        fieldQueryFactory.selectFields(fields);

        return (List<CMN_FHQ_CalculationFormula__mdt>)
            Database.query(fieldQueryFactory.toSOQL());
    }

}