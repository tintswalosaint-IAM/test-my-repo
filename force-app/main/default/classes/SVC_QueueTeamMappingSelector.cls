/**
 * @description Selector class for SVC Queue Team Mapping Custom Metadata.
 * @author Hlayisani Hlungwani
 * @created Date 25 August 2026
 * User Story: SFP-55563 Insurance: Manual case creation should reflect status of new
 */
public inherited sharing class SVC_QueueTeamMappingSelector
    extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Factory method to return a new selector instance.
     * @return SVC_QueueTeamMappingSelector
     */
    public static SVC_QueueTeamMappingSelector newInstance() {
        return new SVC_QueueTeamMappingSelector();
    }

    /**
     * @description Returns the Custom Metadata SObject type.
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return SVC_QueueTeamMapping__mdt.SObjectType;
    }

    /**
     * @description Returns the fields available to the selector.
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SVC_QueueTeamMapping__mdt.Label,
            SVC_QueueTeamMapping__mdt.SVC_Team__c,
            SVC_QueueTeamMapping__mdt.SVC_Queue__c
        };
    }

    /**
     * @description Retrieves queue mappings for a specified team.
     * @param teamName Team name used to find the queue mapping.
     * @return Queue mappings for the team.
     */
    public List<SVC_QueueTeamMapping__mdt> getQueues(String teamName) {
        if (String.isBlank(teamName)) {
            return new List<SVC_QueueTeamMapping__mdt>();
        }

        sbgplatform.fflib_QueryFactory queryFactory =
            newQueryFactory(false, true, true);

        queryFactory.setCondition('SVC_Team__c = :teamName');

        return (List<SVC_QueueTeamMapping__mdt>) Database.queryWithBinds(
            queryFactory.toSOQL(),
            new Map<String, Object>{
                'teamName' => teamName.trim()
            },
            AccessLevel.SYSTEM_MODE
        );

    }
    
}