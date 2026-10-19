/**
* @description       : Selector class for CMN_Question_Response__c entity.
*                      Provides reusable query methods to retrieve question
*                      response records by Id, User, Assessment, and completion
*                      status using the fflib selector framework.
Ver       Date         Author                                                         Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026      Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270)
1.B      March 2026    jyothsna.datla@standardbank.co.za                  sync FHQ dashboard with guest FHQ update    PPBSF-335
*/
public inherited sharing class SEL_CMNQuestionResponse extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Returns the SObjectType for CMN_Question_Response__c.
    *              Required implementation for the fflib selector framework.
    * @return Schema.SObjectType CMN_Question_Response__c SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return CMN_Question_Response__c.sObjectType;
    }
    
    /**
    * @description Returns the list of fields to be included in selector queries.
    *              This is the single source of truth for field selection.
    * @return List<Schema.SObjectField> List of CMN_Question_Response__c fields
    **/

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_Question_Response__c.Id,
            CMN_Question_Response__c.Name,
            CMN_Question_Response__c.CMN_Response_Value_Number__c,
            CMN_Question_Response__c.User_Id__c,
            CMN_Question_Response__c.Id_Type__c,
            CMN_Question_Response__c.Id_Number__c,
            CMN_Question_Response__c.Is_Completed__c,
            CMN_Question_Response__c.Ping_Id__c,
            CMN_Question_Response__c.CMN_Sequence__c,
            CMN_Question_Response__c.CMN_Source__c,
            CMN_Question_Response__c.CMN_Response_Display__c,
            CMN_Question_Response__c.CMN_Rule_Set_Version__c,
            CMN_Question_Response__c.CMN_Response_Value__c,
            CMN_Question_Response__c.CMN_Question_Text__c,
            CMN_Question_Response__c.CMN_Question__c,   
            CMN_Question_Response__c.CMN_Assessment__c,
            CMN_Question_Response__c.CMN_Response_Timestamp__c,
            CMN_Question_Response__c.CreatedDate,
            CMN_Question_Response__c.CMN_Category__c
        };
    }
    
    /**
    * @description Retrieves a CMN_Question_Response__c record based on the provided Id.
    * @param questionResponseId Id of the question response record
    * @return CMN_Question_Response__c Matching question response record, or null if Id is blank
    **/
    
    public CMN_Question_Response__c selectById(String questionResponseId) {
        if (String.isBlank(questionResponseId)) {
            return null;
        }
        String safeQuestionResponseId = String.escapeSingleQuotes(questionResponseId);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('Id = :safeQuestionResponseId');
        fieldQueryFactory.setLimit(1);
        List<CMN_Question_Response__c> results = Database.query(fieldQueryFactory.toSOQL());
        return results.isEmpty() ? null : results[0];
    }
    
    /**
    * @description Retrieves incomplete question responses for a specific user.
    * @param userId Id of the user
    * @return List<CMN_Question_Response__c> List of incomplete question responses
    **/
    public List<CMN_Question_Response__c> selectIncompleteResponseofUser(Id userId) {
        if (userId == null) {
            return new List<CMN_Question_Response__c>();
        }
        String safeUserId = String.escapeSingleQuotes(String.valueOf(userId));
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('User_Id__c = :safeUserId AND Is_Completed__c = false');
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
    * @description Retrieves question responses for the provided set of response Ids.
    * @param ids Set of CMN_Question_Response__c record Ids
    * @return List<CMN_Question_Response__c> List of matching question responses
    **/
    public List<CMN_Question_Response__c> selectQuestionResponsesById(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return new List<CMN_Question_Response__c>();
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.selectField('CMN_Question__r.Question_ID__c');
        fieldQueryFactory.setCondition('Id IN :ids');
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Retrieves question responses for a specific user.
    * @param userId Id of the user
    * @return List<CMN_Question_Response__c> List of question responses for the user
    **/
    public List<CMN_Question_Response__c> selectByUserId(String userId) {
        if (String.isBlank(userId)) {
            return new List<CMN_Question_Response__c>();
        }
        String safeUserId = String.escapeSingleQuotes(userId);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('User_Id__c = :safeUserId');
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Retrieves question responses for a specific Guest user.
    * @param idNumber ID number of the Guest user
    * @return List<CMN_Question_Response__c> List of question responses for the Guest user
    **/
    public List<CMN_Question_Response__c> selectByIdNumber(String idNumber) {
        if (String.isBlank(idNumber)) {
            return new List<CMN_Question_Response__c>();
        }
        String safeIdNumber = String.escapeSingleQuotes(idNumber);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('Id_Number__c = :safeIdNumber');
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Retrieves question responses for a specific assessment,
    *              ordered by CMN_Sequence__c in ascending order.
    * @param assessmentId Id of the CMN_Assessment__c record
    * @return List<CMN_Question_Response__c> Ordered list of question responses
    */
    public List<CMN_Question_Response__c> selectByAssessmentId(Id assessmentId) {
        if (assessmentId == null) {
            return new List<CMN_Question_Response__c>();
        }
        String safeAssessmentId = String.escapeSingleQuotes(String.valueOf(assessmentId));
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition(
            'CMN_Assessment__c = :safeAssessmentId AND CMN_Category__c != null'
        );
        fieldQueryFactory.setOrdering(
            'CMN_Sequence__c',
            sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING,
            true
        );
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
        /**
* @description Method to fetch list of question responses based on idNumber
* @param idNumber
* @return List<CMN_Question_Response__c>
*/
    public List<CMN_Question_Response__c> selectByIdNumberwithNouserId(String idNumber) {
        if (String.isBlank(idNumber)) {
            return new List<CMN_Question_Response__c>();
        }
        String safeIdNumber = String.escapeSingleQuotes(idNumber);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('Id_Number__c = :safeIdNumber AND User_Id__c = null');
        return Database.query(fieldQueryFactory.toSOQL());
    }
}