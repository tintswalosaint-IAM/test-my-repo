/**
* @description       : Selector class for CMN_Rule_Set_Version__c entity.
*                      Provides methods to retrieve rule set version records
*                      using the fflib selector framework.
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
public inherited sharing class SEL_CMNRuleSetVersion extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Fields to be queried for CMN_Rule_Set_Version__c records.
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'CMN_Return_Rate__c',
        'CMN_Withdrawal_Rate__c',
        'CMN_Default_Retirement_Age__c'
    };
                
    /**
    * @description Returns the SObjectType for CMN_Rule_Set_Version__c.
    *              Required implementation for the fflib selector framework.
    * @return Schema.SObjectType CMN_Rule_Set_Version__c SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return CMN_Rule_Set_Version__c.sObjectType;
    }
    
    /**
    * @description Returns the list of fields to be included in selector queries.
    * @return List<Schema.SObjectField> List of CMN_Rule_Set_Version__c fields
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_Rule_Set_Version__c.Id,
            CMN_Rule_Set_Version__c.Name,
            CMN_Rule_Set_Version__c.CMN_Return_Rate__c,
            CMN_Rule_Set_Version__c.CMN_Withdrawal_Rate__c,
            CMN_Rule_Set_Version__c.CMN_Default_Retirement_Age__c
        };
    }
    
    /**
    * @description Retrieves a CMN_Rule_Set_Version__c record based on the provided Id.
    * @param rulesetVersionId Id of the rule set version record
    * @return CMN_Rule_Set_Version__c Matching rule set version record, or null if Id is null
    */
    public CMN_Rule_Set_Version__c selectById(String rulesetVersionId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        
        if (rulesetVersionId == null) {
            return null;
        } else {
            fieldQueryFactory.setCondition('id = :rulesetVersionId');
        }
        
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);
        
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
}