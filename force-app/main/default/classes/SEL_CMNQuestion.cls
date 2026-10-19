/**
* @description       : Selector class for CMN_Question__c entity.
*                      Provides reusable query methods to retrieve questions,
*                      including active questions and ordered question lists,
*                      using the fflib selector framework.
* @author            : Taimoor.Shaik@standardbank.co.za, Preetham.Thernakal-Gandla@standardbank.co.za
* @created on        : Feb 2026
* @last modified on  :
* @last modified by  :
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
public inherited sharing class SEL_CMNQuestion extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Fields to be queried for CMN_Question__c records.
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'Is_Active__c',
        'CMN_Order__c',
        'CMN_Version_Number__c'
    };
    
    /**
    * @description SOQL condition used to filter active questions.
    */
    private static final string activeCondition = 'Is_Active__c = true';
                
    /**
    * @description Returns the SObjectType for CMN_Question__c.
    *              Required implementation for the fflib selector framework.
    * @return Schema.SObjectType CMN_Question__c SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return CMN_Question__c.sObjectType;
    }
    
    /**
    * @description Returns the list of fields to be included in selector queries.
    * @return List<Schema.SObjectField> List of CMN_Question__c fields
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_Question__c.Id,
            CMN_Question__c.Name,
            CMN_Question__c.Is_Active__c,
            CMN_Question__c.CMN_Order__c
        };
    }
    
    /**
    * @description Retrieves a CMN_Question__c record based on the provided Id.
    * @param QuestionId Id of the question record
    * @return CMN_Question__c Matching question record, or null if Id is null
    **/
    public CMN_Question__c selectById(String QuestionId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if (QuestionId == null) {
            return null;
        } else {
            fieldQueryFactory.setCondition('id = :QuestionId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
    * @description Retrieves all active CMN_Question__c records.
    * @return List<CMN_Question__c> List of active questions
    **/
    public List<CMN_Question__c> selectActiveQuestions() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition(activeCondition);
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
    * @description Retrieves all active CMN_Question__c records ordered by CMN_Order__c.
    * @return List<CMN_Question__c> List of active questions sorted in ascending order
    **/
    public List<CMN_Question__c> selectActiveQuestionsInOrder() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition(activeCondition);
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering(
            'CMN_Order__c',
            sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING,
            true
        );
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
}