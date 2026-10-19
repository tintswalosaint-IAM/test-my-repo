/**
 * @description                 : Selector Class for ProcessInstanceWorkItem
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 08-02-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_ProcessInstanceWorkItem extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return ProcessInstanceWorkItem.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ProcessInstanceWorkItem.Id,
            ProcessInstanceWorkItem.ProcessInstanceId,
            ProcessInstanceWorkItem.ActorId,
            ProcessInstanceWorkItem.OriginalActorId,
            ProcessInstanceWorkItem.CreatedDate
        };
    }    

    /**
     * @description Select by Id
     * @param id Id of the ProcessInstanceWorkItem record
     * @return ProcessInstanceWorkItem
     */
    public ProcessInstanceWorkItem selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by TargetObjectId
     * @param id ProcessInstance.TargetObjectId
     * @return List<ProcessInstanceWorkItem>
     */
    public List<ProcessInstanceWorkItem> selectByTargetObjectId(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ProcessInstance.TargetObjectId =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by set of Ids
     * @param ids Set of Ids
     * @return List<ProcessInstanceWorkItem>
     */
    public List<ProcessInstanceWorkItem> selectByIds(set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by set of ProcessInstance Ids
     * @param ids Set of ProcessInstanceIds
     * @return List<ProcessInstanceWorkItem>
     */
    public List<ProcessInstanceWorkItem> selectByProcessInstanceIds(set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ProcessInstanceId IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
}