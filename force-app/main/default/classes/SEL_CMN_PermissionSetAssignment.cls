/*------------------------------------------------------------
Author:        Given Khupai
Company:       Salesforce
Description:   Selector class for PermissionSetAssignment.
               Provides query methods for permission set
               assignment lookups by user and permission set name.
Test Class:    SEL_CMN_PermissionSetAssignment_TEST
2026-06-23     Given Khupai     Initial version (SFP-55625)
------------------------------------------------------------*/
public with sharing class SEL_CMN_PermissionSetAssignment extends sbgplatform.fflib_SObjectSelector {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SEL_CMN_PermissionSetAssignment');
    private static final String LOG_AREA = 'Permission Set Assignment Selector';
    private static final String FORCED_EXCEPTION_MESSAGE = 'Forced exception for test';

    @TestVisible
    private static Boolean forceSelectByUserAndPermissionSetNameException = false;
    @TestVisible
    private static Boolean forceSelectByAssigneeAndPermissionSetIdsException = false;

    public SEL_CMN_PermissionSetAssignment() {
        super(false, true, true);
    }

    public override Schema.SObjectType getSObjectType() {
        return PermissionSetAssignment.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PermissionSetAssignment.Id,
            PermissionSetAssignment.AssigneeId,
            PermissionSetAssignment.PermissionSetId
        };
    }

    /**
     * Purpose    : Retrieves PermissionSetAssignment records by record IDs
     * Parameters : idSet - Set of PermissionSetAssignment record IDs
     * Returns    : List<PermissionSetAssignment>
     */
    public List<PermissionSetAssignment> selectById(Set<Id> idSet) {
        if (idSet == null || idSet.isEmpty()) {
            return new List<PermissionSetAssignment>();
        }
        return (List<PermissionSetAssignment>) selectSObjectsById(idSet);
    }

    /*------------------------------------------------------------
    *   Purpose:    Retrieves Permission Set Assignments for a given
    *               user and permission set name.
    *               Uses SYSTEM_MODE because PermissionSetAssignment
    *               is a setup object that standard profiles cannot
    *               read. This is a system-level permission check,
    *               not a user data query, so elevated access is
    *               appropriate here - scoped to this query only, not
    *               the whole selector.
    *   Parameters: userId — the Id of the user (AssigneeId)
    *               permissionSetName — the API name of the Permission Set
    *   Returns:    List<PermissionSetAssignment>
    *--------------------------------------------------------------*/
    public List<PermissionSetAssignment> selectByUserAndPermissionSetName(Id userId, String permissionSetName) {
        if (userId == null || String.isBlank(permissionSetName)) {
            return new List<PermissionSetAssignment>();
        }
        try {
            if (Test.isRunningTest() && forceSelectByUserAndPermissionSetNameException) {
                throw new System.QueryException(FORCED_EXCEPTION_MESSAGE);
            }
            String query = 'SELECT Id, AssigneeId, PermissionSetId ' +
                           'FROM PermissionSetAssignment ' +
                           'WHERE AssigneeId = :userId ' +
                           'AND PermissionSet.Name = :permissionSetName';
            Map<String, Object> bindMap = new Map<String, Object>{
                'userId' => userId,
                'permissionSetName' => permissionSetName
            };
            return Database.queryWithBinds(query, bindMap, AccessLevel.SYSTEM_MODE);
        } catch (Exception ex) {
            LOGGER.error(
                'selectByUserAndPermissionSetName() failed for userId={0}, permissionSetName={1}, Error={2}',
                LOG_AREA,
                new List<Object>{ userId, permissionSetName, ex.getMessage() },
                ex
            );
            throw ex;
        }
    }

    /*------------------------------------------------------------
    *   Purpose:    Bulk lookup of existing Permission Set Assignments for a
    *               set of assignees against a set of Permission Set Ids.
    *               Intended to replace per-record SOQL-in-loop existence
    *               checks in calling code with a single query. Uses
    *               SYSTEM_MODE for the same setup-object reason as
    *               selectByUserAndPermissionSetName() above.
    *   Parameters: assigneeIds — Set of User Ids
    *               permissionSetIds — Set of PermissionSet Ids
    *   Returns:    List<PermissionSetAssignment>
    *--------------------------------------------------------------*/
    public List<PermissionSetAssignment> selectByAssigneeAndPermissionSetIds(Set<Id> assigneeIds, Set<Id> permissionSetIds) {
        if (assigneeIds == null || assigneeIds.isEmpty() || permissionSetIds == null || permissionSetIds.isEmpty()) {
            return new List<PermissionSetAssignment>();
        }
        try {
            if (Test.isRunningTest() && forceSelectByAssigneeAndPermissionSetIdsException) {
                throw new System.QueryException(FORCED_EXCEPTION_MESSAGE);
            }
            return [
                SELECT Id, AssigneeId, PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId IN :assigneeIds
                  AND PermissionSetId IN :permissionSetIds
                WITH SYSTEM_MODE
            ];
        } catch (Exception ex) {
            LOGGER.error(
                'selectByAssigneeAndPermissionSetIds() failed for assigneeIds size={0}, permissionSetIds size={1}, Error={2}',
                LOG_AREA,
                new List<Object>{ assigneeIds.size(), permissionSetIds.size(), ex.getMessage() },
                ex
            );
            throw ex;
        }
    }
}