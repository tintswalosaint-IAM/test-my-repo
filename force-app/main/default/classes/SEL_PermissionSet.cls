/**
 * @description       : Selector class for PermissionSet
 * @author            : Jaco de Lange
 * @last modified on  : 01-15-2026
 * @LastModified by   : Jagadish Thunmmala
 * @UserStory         : SFP-54919
 * @LastModifiedReason: Created new methods to retrieve permission sets by Id
 **/
public inherited sharing class  SEL_PermissionSet extends sbgplatform.fflib_SObjectSelector{
    /**
    * @description Defines the default fields to be added to all queries created ny the Query Factory
    * @return List of Schema.SObjectField objects representing the fields
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'Label',
        'PermissionsApiEnabled'
    };
    /**
    * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
    * queries.
    * @return PermissionSet  object type
     */
    public override Schema.SObjectType getSObjectType() {
        return PermissionSet.SObjectType;
    }
    /**
     * Returns list of permission set for active user for given permission set name
     * @param permissionSetName
     * @return List<PermissionSet>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PermissionSet.Id,
            PermissionSet.Name,
            PermissionSet.Label,
            PermissionSet.PermissionsApiEnabled
        };
    }
    /**
     * @description Select profile by Name
     * @param permissionsetnames
     * @return List<Profile>
     **/
    public List<PermissionSet> selectByPermissionSetNames(List<String> permissionsetnames) {
        if(!Schema.SobjectType.PermissionSet.isAccessible()){
            return null;
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Name IN :permissionSetNames');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    } 

    /**
     * Returns list of permission sets for the given permission set Id.
     * @param permissionSetId Permission Set Id
     * @return List<PermissionSet>
     */
    public List<PermissionSet> selectByPermissionSetId(String permissionSetId) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Id = :permissionSetId');
        List<PermissionSet> records =
            (List<PermissionSet>) Database.query(queryFactory.toSOQL());
        // Enforce FLS on the queried fields
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            records
        );
        return (List<PermissionSet>) decision.getRecords();
    }
}