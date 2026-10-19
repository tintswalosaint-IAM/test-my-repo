/**
 * @description Trigger Handler framework TEST handler class
 *
 * @author Adam Redlinski
 * @date 2023/06/05
 *
 * @modified by Sibonelo Ngcobo - [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
 * @date 2026/03/16
 */
public inherited sharing class WI_TRH_ServiceFulfillment extends CMN_TRH_BaseObject {
    private static final String PG_DEVELOPER_NAME = 'WI_RelationshipManagerHead';
    private static final String USER_ID_PREFIX = '005';
    private static final String ERROR_FIELD_MSG = 'Chosen Manager is not allowed. Please, chose a Manager from the W&I Relationship Manager Head group.';
    private static final String SUBMITTER_ERROR_MSG = 'Submitter cannot be the same as approver';
    private Set<Id> allowedManagersIdSet;
    private Map<Id, ServiceFulfillment__c> sfMap;
    private List<ProcessInstanceNode> nodes;
    
    /**
     * @description This method is called prior to execution of a BEFORE Trigger.
     * Use this to cache any data required into maps prior execution of the Trigger.
     */
    public override void bulkBefore() {
        
            Group pg = new Sel_Group().selectByDeveloperNameAndType(PG_DEVELOPER_NAME, 'Regular');

            if (String.IsBlank(pg.id)) {
                return;
            }
    
            this.allowedManagersIdSet = this.getPublicGroupUserMembersIdSet(new Set<Id>{
                    pg.Id
            }, new Set<Id>());
            
            SEL_ServiceFulfillment serviceFuifillmentSelector = new SEL_ServiceFulfillment();
            sfMap = new Map<Id, ServiceFulfillment__c> (serviceFuifillmentSelector.getServiceFulfillmentsWithProcessInstanceAndSteps(Trigger.newMap.keySet()));
    
            Id processInstanceId;
            for (ServiceFulfillment__c singleSF : sfMap.values()) {
                for (ProcessInstanceHistory step : singleSF.ProcessSteps) {
                    processInstanceId = step.ProcessInstanceId;
                }
            }
            
            SEL_ProcessInstanceNode processInstanceNodeSelector = new SEL_ProcessInstanceNode();
            nodes = processInstanceNodeSelector.getInstanceNodesBySingleInstanceId(processInstanceId);
        
    }


    /**
     * @description Method retrieves with recursion members of the public group which Id is passed
      * and if group contains another group it recursively retrieves members from the internal groups
     *
     * @param publicGroupIdsSet - Set<Id> publicGroupIdsSet -Id of group from where members will be retrieved
     * @param allowedManagersIdSet - Set<Id> allowedManagersIdSet - Id of user members of public groups
     */
    private Set<Id> getPublicGroupUserMembersIdSet(Set<Id> publicGroupIdsSet, Set<Id> allowedManagersIdSet) {
    if (allowedManagersIdSet == null) {
        allowedManagersIdSet = new Set<Id>();
    }

    if (publicGroupIdsSet == null || publicGroupIdsSet.isEmpty()) {
        return allowedManagersIdSet;
    }

    if (!Schema.sObjectType.GroupMember.isAccessible()) {
        return allowedManagersIdSet;
    }

    Set<Id> nestedGroupIds = new Set<Id>();
    List<GroupMember> groupMemberRecords = new SEL_GroupMember().selectByGroupId(publicGroupIdsSet);

    for (GroupMember memberRec : groupMemberRecords) {
        Id memberId = memberRec.UserOrGroupId;
        String memberPrefix = String.valueOf(memberId).left(3);

        if (memberPrefix == USER_ID_PREFIX) {
            allowedManagersIdSet.add(memberId);
        } else {
            nestedGroupIds.add(memberId);
        }
    }

    return nestedGroupIds.isEmpty()
        ? allowedManagersIdSet
        : getPublicGroupUserMembersIdSet(nestedGroupIds, allowedManagersIdSet);
}

    /**
     * @description Before update handler
     *
     * @param oldSo - Old record
     * @param so - New record
     */
    public override void beforeUpdate(SObject oldSo, SObject so) {
        super.beforeUpdate(oldSo, so);

        this.validateNewManager((ServiceFulfillment__c) so);

        ServiceFulfillment__c singleSf = sfMap.get(so.Id);
                
        if(singleSf.Status__c == 'Awaiting 2nd Line Approval' || singleSf.Status__c == 'Awaiting Approval') {
        this.validateApprover((ServiceFulfillment__c) so);
    }

    }

    /**
 * @description Method checks if approver in the approval process is not the same as an initial submitter. If yes, adds error and blocks process
 *
 * @param newRecord - WI_ServiceFulfillment__c newRecord record which triggers update
 */
    private void validateApprover(ServiceFulfillment__c newRecord) {
        Id currentUser = UserInfo.getUserId();
        ServiceFulfillment__c singleSf = sfMap.get(newRecord.Id);

    if (singleSf == null || singleSf.ProcessInstances == null || singleSf.ProcessInstances.isEmpty()) {
        return;
    }

    if (nodes == null || nodes.isEmpty()) {
        return;
    }

        for (ProcessInstance singleInstance : singleSf.ProcessInstances) {
        if (singleInstance.SubmittedById == currentUser) {
                    newRecord.addError(SUBMITTER_ERROR_MSG);
            return;
                }
            }
}

    /**
     * @description Validate Manager field changes on record
     * @param newRecord - New WI_ServiceFulfillment__c newRecord
     */
    private void validateNewManager(ServiceFulfillment__c newRecord) {
        if (newRecord?.Manager__c != null && !this.allowedManagersIdSet.contains(newRecord.Manager__c)) {
            newRecord.Manager__c.addError(ERROR_FIELD_MSG);
        }
    }
}