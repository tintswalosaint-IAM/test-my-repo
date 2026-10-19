/**
 * @description                 : Selector Class for ProcessInstanceStep
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 21-10-2024
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_ProcessInstanceStep extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return ProcessInstanceStep.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ProcessInstanceStep.Id,
            ProcessInstanceStep.ProcessInstanceId,
            ProcessInstanceStep.OriginalActorId,
            ProcessInstanceStep.ActorId,
            ProcessInstanceStep.Comments,
            ProcessInstanceStep.CreatedDate,
            ProcessInstanceStep.StepStatus,
            ProcessInstanceStep.stepnodeid
        };
    }    

    /**
     * @description Select by Id
     * @param Id of ProcessInstanceStep
     * @return ProcessInstanceStep
     */
    public ProcessInstanceStep selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by set of Ids
     * @param ids Set of ids of ProcessInstanceStep
     * @return List<ProcessInstanceStep>
     */
    public List<ProcessInstanceStep> selectByIds(set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by set of processInstanceIds
     * @param ids Set of ids of processInstanceIds
     * @return List<ProcessInstanceStep>
     */
    public List<ProcessInstanceStep> selectByProcessInstanceId(set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectField('ProcessInstance.Status');
        fieldQueryFactory.selectField('ProcessInstance.TargetObjectId');
        
        fieldQueryFactory.selectField('Actor.Name');
        fieldQueryFactory.selectField('OriginalActor.Name');

        fieldQueryFactory.setCondition('ProcessInstanceId IN : ids');
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select records with particular status
     * @param targetObjectType Type name of the target object
     * @param targetObjectRecordType Record type name
     * @param status Status of the approval request
     * @return List<ProcessInstanceStep>
     */
    public List<ProcessInstanceStep> selectByTargetObjectTypeTargetObjectRecordTypeAndStatus(String targetObjectType, String targetObjectRecordType, String status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ProcessInstance.TargetObject.Type = :targetObjectType AND ProcessInstance.TargetObject.RecordType.Name = :targetObjectRecordType AND ProcessInstance.Status = :status');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}