/***************************************************************************************
@Name of the Component : SEL_ServiceTeam
@Description : Selector class for the SVC_ServiceTeam__c object
@Author : Raymond Magezi
@Created Date : 15 October 2025
User Story: SFP-53311
@Modification description: Created for technical review - replace inline SOQL with selector pattern
***************************************************************************************/
public inherited sharing class SEL_ServiceTeam extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Defines the default fields to be added to all queries created by the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'CMN_Team__c',
        'CMN_Team__r.Id',
        'CMN_Team__r.Name',
        'CMN_Team__r.CMN_Email__c',
        'SVC_Active__c',
        'SVC_ServiceType__c',
        'SVC_ServiceType__r.Id',
        'SVC_ServiceType__r.Name',
        'SVC_ServiceType__r.SVC_ServiceType__c',
        'SVC_ServiceType__r.SVC_Category__c',
        'SVC_ServiceType__r.SVC_SubCategory__c',
        'SVC_ServiceType__r.SVC_Active__c',
        'SVC_ApplicableProductCategories__c',
        'SVC_CaseRoutingQueue__c',
        'SVC_GroupId__c',
        'SVC_QueueBasedRouting__c',
        'CreatedDate',
        'LastModifiedDate'
    };

    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return SVC_ServiceTeam__c.SObjectType;
    }

    /**
     * @description Method to get list of fields to be part of response
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SVC_ServiceTeam__c.Id,
            SVC_ServiceTeam__c.Name,
            SVC_ServiceTeam__c.CMN_Team__c,
            SVC_ServiceTeam__c.SVC_ServiceType__c,
            SVC_ServiceTeam__c.SVC_Active__c
        };
    }

    /**
     * @description Creates a new instance of the selector via the application class
     * @return SEL_ServiceTeam
     */
    public static SEL_ServiceTeam newInstance() {
        return (SEL_ServiceTeam) ORG_Application.selector.newInstance(SVC_ServiceTeam__c.SObjectType);
    }

    /**
     * @description Select service teams by team ID and service type picklist for Uganda users
     * @author Raymond Magezi
     * @created Date 15 October 2025
     * @user Story SFP-53311
     * @param teamId The team ID to filter by
     * @param serviceTypePicklist The service type picklist value to filter by
     * @return List<SVC_ServiceTeam__c>
     **/
    public List<SVC_ServiceTeam__c> selectServiceTeamsByTeamAndServiceTypePicklist(Id teamId, String serviceTypePicklist) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('CMN_Team__c = :teamId AND SVC_Active__c = true AND SVC_ServiceType__r.SVC_ServiceType__c = :serviceTypePicklist');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('SVC_ServiceType__r.Name', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select service teams by team ID for general service type retrieval
     * @author Raymond Magezi
     * @created Date 15 October 2025
     * @user Story SFP-53311
     * @param teamId The team ID to filter by
     * @return List<SVC_ServiceTeam__c>
     **/
    public List<SVC_ServiceTeam__c> selectServiceTeamsByTeamId(Id teamId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('CMN_Team__c = :teamId AND SVC_Active__c = true');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('SVC_ServiceType__r.Name', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}