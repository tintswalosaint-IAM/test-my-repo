/**
* @description       : Selector class for FHQ_Answer_Scoring__mdt entity.
*                      Provides reusable query methods to retrieve answer scoring
*                      metadata records, including active scoring configurations,
*                      using the fflib selector framework.
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
public inherited sharing class SEL_FHQAnswerScoring extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Fields to be queried for FHQ_Answer_Scoring__mdt records.
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Question_Name__c',
        'Answer_Text__c',
        'Score_Value__c',
        'Is_Active__c',
        'Question_Order__c',
        'Category_Name__c'
    };
    
    /**
    * @description SOQL condition used to filter active answer scoring records.
    */
    private static final String activeCondition = 'Is_Active__c = true';
                
    /**
    * @description Returns the SObjectType for FHQ_Answer_Scoring__mdt.
    *              Required implementation for the fflib selector framework.
    * @return Schema.SObjectType FHQ_Answer_Scoring__mdt SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return FHQ_Answer_Scoring__mdt.sObjectType;
    }
    
    /**
    * @description Returns the list of fields to be included in selector queries.
    * @return List<Schema.SObjectField> List of FHQ_Answer_Scoring__mdt fields
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            FHQ_Answer_Scoring__mdt.Id,
            FHQ_Answer_Scoring__mdt.Question_Name__c,
            FHQ_Answer_Scoring__mdt.Answer_Text__c,
            FHQ_Answer_Scoring__mdt.Score_Value__c,
            FHQ_Answer_Scoring__mdt.Is_Active__c,
            FHQ_Answer_Scoring__mdt.Question_Order__c,
            FHQ_Answer_Scoring__mdt.Category_Name__c
        };
    }
    
    /**
    * @description Retrieves all active FHQ_Answer_Scoring__mdt records.
    * @return List<FHQ_Answer_Scoring__mdt> List of active answer scoring metadata records
    **/
    public List<FHQ_Answer_Scoring__mdt> selectActiveQuestions() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(false, false, false);

        fieldQueryFactory.setCondition(activeCondition);
        fieldQueryFactory.selectFields(fields);

        String query =
            String.escapeSingleQuotes(fieldQueryFactory.toSOQL());

        return Database.query(query);
    }
    
}