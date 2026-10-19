/**
 * @description                 : Selector Class for ApplicationFormHistory
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 22-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_ApplicationFormHistory extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return ApplicationFormHistory.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ApplicationFormHistory.Id,
            ApplicationFormHistory.ApplicationFormId,
            ApplicationFormHistory.CreatedById,
            ApplicationFormHistory.CreatedDate,
            ApplicationFormHistory.Field,
            ApplicationFormHistory.OldValue,
            ApplicationFormHistory.NewValue
        };
    }    

    /**
     * @description Select by id
     * @param id
     * @return ApplicationFormHistory
     */
    public ApplicationFormHistory selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by set of Ids
     * @param ids
     * @return List<ApplicationFormHistory>
     */
    public List<ApplicationFormHistory> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }


    /**
    * @description Select by a set of ApplicationForm Ids
    * @author Tushar Walse | 21-02-2025 
    * @param applicationFormIds set of ApplicationForm Ids
    * @return List<ApplicationFormHistory> List of records
    **/
    public List<ApplicationFormHistory> selectByApplicationFormIds(Set<Id> applicationFormIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ApplicationFormId IN : applicationFormIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by ApplicationForm Id
    * @author Tushar Walse | 21-02-2025 
    * @param applicationFormId ApplicationForm Id
    * @param newValue value to use for filtering
    * @return List<ApplicationFormHistory> List of records
    **/
    public List<ApplicationFormHistory> selectByApplicationFormId(Id applicationFormId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ApplicationFormId = : applicationFormId');
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by ApplicationForm Id
    * @author Tushar Walse | 21-02-2025 
    * @param applicationFormId ApplicationForm Id
    * @param newValue value to use for filtering
    * @return List<ApplicationFormHistory> List of records
    **/
    public List<ApplicationFormHistory> selectByApplicationFormIdAndField(Id applicationFormId, String field) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ApplicationFormId = : applicationFormId AND Field = : field');
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

}