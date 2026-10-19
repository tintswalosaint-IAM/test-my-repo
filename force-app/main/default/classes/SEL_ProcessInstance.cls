/**
 * @description                 : Selector Class for ProcessInstance
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 07-02-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_ProcessInstance extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return ProcessInstance.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ProcessInstance.Id,
            ProcessInstance.TargetObjectId,
            ProcessInstance.Status,
            ProcessInstance.ProcessDefinitionId,
            ProcessInstance.Status,
            ProcessInstance.CompletedDate,
            ProcessInstance.CreatedDate,
            ProcessInstance.LastModifiedDate,
            ProcessInstance.SubmittedById,
            ProcessInstance.LastActorId            
        };
    }    

    /**
     * @description Select by id
     * @param id
     * @return ProcessInstance
     */
    public ProcessInstance selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by TargetObjectId
     * @param id TargetObjectId
     * @return ProcessInstance
     */
    public List<ProcessInstance> selectByTargetObjectId(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('TargetObjectId IN : ids');
        fieldQueryFactory.setOrdering('LastModifiedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
     * @description Select by TargetObjectId with createddate
     * @param id TargetObjectId
     * @return ProcessInstance
     */
    public List<ProcessInstance> selectByTargetObjectIdWithCreatedDate(String id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('TargetObjectId =: id');
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by set of Ids
     * @param ids
     * @return List<ProcessInstance>
     */
    public List<ProcessInstance> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select records with particular status
     * @param targetObjectType Type name of the target object
     * @param targetObjectRecordType Record type name
     * @param status Status of the approval request
     * @return List<ProcessInstance>
     */
    public List<ProcessInstance> selectByTargetObjectTypeTargetObjectRecordTypeAndStatus(String targetObjectType, String targetObjectRecordType, String status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('TargetObject.Type = :targetObjectType AND TargetObject.RecordType.Name = :targetObjectRecordType AND Status = :status');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}