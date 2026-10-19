/**
 * @description Selector Class for SVC Queue Team Mapping Custom Metadata.
 * @author Hlayisani Hlungwane
 * @created Date 25 August 2026
 * 25- 09 -10      Hlayisani Hlungwani      SFP-55563 Insurance: Manual case creation 
 *                                                     should reflect status of new
 */
public inherited sharing class SVC_QueueTeamMappingSelector
    extends sbgplatform.fflib_SObjectSelector
{
    // Fields used by the selector
    private static final Set<String> fields = new Set<String>
    {
        'Label',
        'SVC_Team__c',
        'SVC_Queue__c'
    };

    /**
     * @description Returns the Custom Metadata SObject type used by this selector.
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType()
    {
        return SVC_QueueTeamMapping__mdt.SObjectType;
    }

    /**
     * @description Returns the list of Custom Metadata fields available to the selector.
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField>
        {
            SVC_QueueTeamMapping__mdt.Label,
            SVC_QueueTeamMapping__mdt.SVC_Team__c,
            SVC_QueueTeamMapping__mdt.SVC_Queue__c
        };
    }

    /**
     * @description Retrieves queue mappings for a specified team.
     * @param teamName Team name used to find the queue mapping.
     * @return List<SVC_QueueTeamMapping__mdt> Queue mappings for the team.
     */
    public List<SVC_QueueTeamMapping__mdt> getQueues(String teamName)
    {
        if (String.isBlank(teamName))
        {
            return new List<SVC_QueueTeamMapping__mdt>();
        }

        sbgplatform.fflib_QueryFactory queryFactory =
            newQueryFactory(false, false, false);

        queryFactory.setCondition('SVC_Team__c = :teamName');
        queryFactory.selectFields(fields);

        return Database.query(queryFactory.toSOQL());
    }
}