/***************************************************************************************
@Name of the Component : SEL_ServiceType
@Description : Selector class for the SVC_ServiceType__c object
@Author : Raymond Magezi
@Created Date : 15 October 2025
User Story: SFP-53311
@Modification description: Created for technical review - replace inline SOQL with selector pattern
***************************************************************************************/
public inherited sharing class SEL_ServiceType extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Defines the default fields to be added to all queries created by the Query Factory
     * @return Set of field names as strings
     */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'SVC_Active__c',
        'SVC_AuthenticationLevel__c',
        'SVC_Category__c',
        'SVC_ClientTier__c',
        'SVC_Description__c',
        'SVC_Entitlement__c',
        'SVC_ExternalId__c',
        'SVC_Keywords__c',
        'SVC_Priority__c',
        'SVC_RequiredSkill__c',
        'SVC_ServiceType__c',
        'SVC_SubCategory__c',
        'SVC_Team__c',
        'CreatedDate',
        'LastModifiedDate',
        'CreatedById',
        'LastModifiedById',
        'SystemModstamp'
    };

    /**
     * @description Returns the SObject type for this selector
     * @return Schema.SObjectType The SVC_ServiceType__c SObject type
     * @see SVC_ServiceType__c
     */
    public override Schema.SObjectType getSObjectType() {
        return SVC_ServiceType__c.SObjectType;
    }

    /**
     * @description Returns the default fields to include in selector queries
     * @return List<Schema.SObjectField> List of essential SVC_ServiceType__c fields
     * @see SVC_ServiceType__c
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SVC_ServiceType__c.Id,
            SVC_ServiceType__c.Name,
            SVC_ServiceType__c.SVC_Category__c,
            SVC_ServiceType__c.SVC_ServiceType__c,
            SVC_ServiceType__c.SVC_Active__c
        };
    }

    /**
     * @description Creates a new instance of the SEL_ServiceType selector using the application factory
     * @return SEL_ServiceType New instance of the service type selector
     * @see ORG_Application.selector
     */
    public static SEL_ServiceType newInstance() {
        return (SEL_ServiceType) ORG_Application.selector.newInstance(SVC_ServiceType__c.SObjectType);
    }

    /**
     * @description Selects service types that have non-null categories, ordered by category name
     * @return List<SVC_ServiceType__c> List of service types with categories, ordered ascending by SVC_Category__c
     * @see SVC_ServiceType__c.SVC_Category__c
     * @author Raymond Magezi
     * @created Date 15 October 2025
     * @user Story SFP-53311
     */
    public List<SVC_ServiceType__c> selectServiceTypesWithCategories() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('SVC_Category__c != null');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('SVC_Category__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Selects service types with non-null SVC_ServiceType__c field for picklist option generation
     * @return List<SVC_ServiceType__c> List of service types with SVC_ServiceType__c values, ordered ascending
     * @see SVC_ServiceType__c.SVC_ServiceType__c
     * @author Raymond Magezi
     * @created Date 15 October 2025
     * @user Story SFP-53311
     */
    public List<SVC_ServiceType__c> selectServiceTypePicklistOptions() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('SVC_ServiceType__c != null');
        fieldQueryFactory.selectField('SVC_ServiceType__c');
        fieldQueryFactory.selectField('Name');
        fieldQueryFactory.setOrdering('SVC_ServiceType__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}