/**
 * @description       : Selector Class for ProcessInstanceNode
 * @author            : Mbuyiseni Mbhokane
 * @last modified on  : 05-04-2025
 * @last modified by  : Agisanang Shole
 * 						added a selector method to query instance node by single instance Id
 * 
 * @last modified on            : 12-03-2026
 * @last modified by            : Vikash Beersye
 * @modification description    : [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
**/
public with sharing class SEL_ProcessInstanceNode extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{
        'Id',
        'ProcessNodeName',
        'ProcessInstanceId',
        'CompletedDate',
        'CreatedBy.Name',
        'LastActor.WI_PersonnelNumber__c',
        'LastActor.Name'
    };

    /**
    * @description Implementation method for ProcessInstanceNode Object as part of fflib framweork
    * @author Mbuyiseni Mbhokane | 07-16-2024 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return ProcessInstanceNode.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @author Mbuyiseni Mbhokane | 07-16-2024 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ProcessInstanceNode.Id, 
            ProcessInstanceNode.ProcessNodeName, 
            ProcessInstanceNode.ProcessInstanceId, 
            ProcessInstanceNode.CompletedDate
        };
    }

    /**
    * @description query ProcessInstanceNode by instance ids
    * @author Mbuyiseni Mbhokane | 07-16-2024 
    * @param instanceIds 
    * @return List<ProcessInstanceNode> 
    **/
    public List<ProcessInstanceNode> getInstanceNodesByInstanceIds(Set<Id> instanceIds){
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ProcessInstanceId IN :instanceIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
    * @description query ProcessInstanceNode by instance id
    * @author Agisanang Shole | 05-04-2025 
    * @param instanceId
    * @return List<ProcessInstanceNode> 
    **/
    public List<ProcessInstanceNode> getInstanceNodesBySingleInstanceId(Id instanceId){
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ProcessInstanceId =: instanceId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}