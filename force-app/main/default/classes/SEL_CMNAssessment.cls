/**
* @description       : Selector class for CMN_Assessment__c entity.
*                      Provides reusable query methods to retrieve assessment
*                      records by Id and User, including the latest assessment,
*                      using the fflib selector framework.
* @author            : Preetham.Thernakal-Gandla@standardbank.co.za, Taimoor.Shaik@standardbank.co.za
* @created on        : FEB 2026
* @last modified on  : Mar 2026
* @last modified by  : Taimoor.shaik@standardbank.co.za
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026      Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270)
1.B      Mar 2026       Preetham.Thernakal-Gandla@standardbank.co.za       sync assessment records with guest user(PPBSF-271)
*/
public inherited sharing class SEL_CMNAssessment extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Returns the SObjectType for CMN_Assessment__c.
    *              Required implementation for the fflib selector framework.
    * @return Schema.SObjectType CMN_Assessment__c SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return CMN_Assessment__c.sObjectType;
    }
    
    /**
    * @description Returns the list of fields to be included in selector queries.
    *              This is the single source of truth for field selection.
    * @return List<Schema.SObjectField> List of CMN_Assessment__c fields
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_Assessment__c.Id,
            CMN_Assessment__c.Name,
            CMN_Assessment__c.CMN_Assessment_Start_Date__c,
            CMN_Assessment__c.CMN_Completed_By__c,
            CMN_Assessment__c.CMN_Expenses_Score__c,
            CMN_Assessment__c.CMN_Emergency_Fund_Score__c,
            CMN_Assessment__c.CMN_Debt_to_Income_Score__c,
            CMN_Assessment__c.CMN_Insurance_Score__c,
            CMN_Assessment__c.CMN_Retirement_Readiness_Score__c,
            CMN_Assessment__c.CMN_DTI_Percent__c,
            CMN_Assessment__c.CMN_Withdrawal_Rate__c,
            CMN_Assessment__c.CMN_Return_Rate__c,
            CMN_Assessment__c.CMN_Assessment_Completion_Date__c,
            CMN_Assessment__c.CMN_Future_Value__c,
            CMN_Assessment__c.Id_Number__c,
            CMN_Assessment__c.Id_Type__c,
            CMN_Assessment__c.OwnerId,
            CMN_Assessment__c.CMN_Metrics_Available__c,
            CMN_Assessment__c.PING_Id__c,
            CMN_Assessment__c.CMN_Retirement_Age__c,
            CMN_Assessment__c.CMN_Retirement_Percent_of_Target__c,
            CMN_Assessment__c.CMN_Version_Number__c,
            CMN_Assessment__c.CMN_Status__c,
            CMN_Assessment__c.User_Id__c,
            CMN_Assessment__c.CMN_Years_to_Retirement__c,
            CMN_Assessment__c.CMN_Retirement_Target__c,
            CMN_Assessment__c.CMN_Overall_Score__c
        };
    }
    
    /**
    * @description Retrieves a CMN_Assessment__c record based on the provided Id.
    * @param assessmentId Id of the assessment record
    * @return CMN_Assessment__c Matching assessment record, or null if Id is blank
    **/
    public CMN_Assessment__c selectById(String assessmentId) {
           
        if (String.isBlank(assessmentId)) {
            return null;
        }
        String safeAssessmentId = String.escapeSingleQuotes(assessmentId);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('Id = :safeAssessmentId');
        fieldQueryFactory.setLimit(1);
        List<CMN_Assessment__c> results = Database.query(fieldQueryFactory.toSOQL());
        return results.isEmpty() ? null : results[0];
    }
    
    /**
    * @description Retrieves the most recently created CMN_Assessment__c record for a specific user.
    * @param userId Value of User_Id__c field
    * @return CMN_Assessment__c Latest assessment record, or null if none found
    */
    public CMN_Assessment__c selectLatestByUserId(String userId) {
        if (String.isBlank(userId)) {
            return null;
        }
        String safeUserId = String.escapeSingleQuotes(userId);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('User_Id__c = :safeUserId');
        fieldQueryFactory.setOrdering(
            'CreatedDate',
            sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING
        );
        fieldQueryFactory.setLimit(1);
        List<CMN_Assessment__c> results = Database.query(fieldQueryFactory.toSOQL());
        return results.isEmpty() ? null : results[0];
    }
    
    /**
    *
    * @description Retrieves the most recently created CMN_Assessment__c record for a specific Id Number.
    * @param idNumber Value of Id_Number__c field
    * @return CMN_Assessment__c Latest assessment record, or null if none found
    */
    public CMN_Assessment__c selectLatestByIdNumber(String idNumber) {
        if (String.isBlank(idNumber)) {
            return null;
        }
        String safeIdNumber = String.escapeSingleQuotes(idNumber);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('Id_Number__c = :safeIdNumber');
        fieldQueryFactory.setOrdering(
            'CreatedDate',
            sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING
        );
        fieldQueryFactory.setLimit(1);
        List<CMN_Assessment__c> results = Database.query(fieldQueryFactory.toSOQL());
        return results.isEmpty() ? null : results[0];
    }
    
     /**
* @description Method to fetch list of CMN_Assessment__c based on IdNumber

* @param idNumber
* @return List<CMN_Assessment__c>
*/
    public List<CMN_Assessment__c> selectByIdNumber(String idNumber) {
        
        if (String.isBlank(idNumber)) {
            return null;
        }
        String safeIdNumber = String.escapeSingleQuotes(idNumber);
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('Id_Number__c = :safeIdNumber');
        List<CMN_Assessment__c> results = Database.query(fieldQueryFactory.toSOQL());
        return results.isEmpty() ? null : results;
    }

}