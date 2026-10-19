/**
 * @description Transaction Security Policy condition class that blocks assignment of API-enabled
 * Permission Sets unless they are on an approved allowlist. This policy helps prevent unauthorized
 * API access by monitoring PermissionSetEventStore events and validating against custom metadata
 * configuration (API_Allowed_Permission_set__mdt).
 *
 * The policy triggers on 'AssignedToUsers' operations and evaluates the PermissionsApiEnabled
 * flag of the Permission Set being assigned. Permission Sets on the allowlist are exempt from
 * blocking, enabling legitimate integration users to maintain API access.
 *
 * @author Jagadish Thummala
 * @date January 2026
 * @group Security
 * @see API_Allowed_Permission_set__mdt
 * @see PermissionSetEventStore
 * @Userstory : SFP-54919
 */
global with sharing class TSP_BlockAPIEnabledEventCondition implements TxnSecurity.EventCondition {
    /**
     * @description RFLIB Logger instance for tracking policy evaluation events and errors.
     * Initialized with context name 'BlockAPIEnabledEventCondition' for log filtering.
     */
    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('TSP_BlockAPIEnabledEventCondition');
   
    /**
     * @description Cached set of approved Permission Set names that are allowed to grant API access.
     * Populated from API_Allowed_Permission_set__mdt custom metadata where Is_Active__c = true.
     * The cache is loaded once per transaction on first access to minimize SOQL queries.
     *
     * This property is public with a setter to support test class override scenarios where
     * custom metadata may not be available or needs to be mocked.
     */
    public static Set<String> allowedPermSetNames {
        get {
            if (allowedPermSetNames == null) {
                allowedPermSetNames = new Set<String>();
                try {
                    for (API_Allowed_Permission_set__mdt mdt : [
                        SELECT DeveloperName
                        FROM API_Allowed_Permission_set__mdt
                        WHERE Is_Active__c = true
                        WITH SECURITY_ENFORCED
                    ]) {
                        allowedPermSetNames.add(mdt.DeveloperName);
                    }
                } catch (Exception e) {
                    // Log and proceed with an empty allowlist to fail-safe (do not block due to metadata issues)
                    LOGGER.error('TSP_BlockAPIEnabledEventCondition.allowedPermSetNames getter', e);
                }
            }
            return allowedPermSetNames;
        }
        set;
    }
   
    /**
     * @description Evaluates whether a Permission Set assignment should be blocked based on
     * API access permissions and allowlist membership. This method is called by the Salesforce
     * Transaction Security framework when a PermissionSetEventStore event occurs.
     *
     * @param event The SObject event from the Transaction Security framework. Expected to be
     * PermissionSetEventStore instance containing assignment operation details.
     * @return Boolean TRUE to block the Permission Set assignment, FALSE to allow it.
     * Returns FALSE for any validation failures or exceptions to prevent
     * false positives that could disrupt legitimate operations.
     */
    public boolean evaluate(SObject event) {
        if (!(event instanceof PermissionSetEventStore)) {
            return false;
        }
       
        PermissionSetEventStore psEvent = (PermissionSetEventStore) event;
       
        if (psEvent.Operation != 'AssignedToUsers' || String.isBlank(psEvent.ParentIdList)) {
            return false;
        }
       
        String permSetId = extractPermSetId(psEvent.ParentIdList);
        if (String.isBlank(permSetId)) {
            return false;
        }
       
        PermissionSet permSet = getPermissionSet(permSetId);
        if (permSet == null) {
            return false;
        }
       
        if (isAllowed(permSet.Name)) {
            return false;
        }
       
        return permSet.PermissionsApiEnabled;
    }
    
    /**
     * @description Extracts the Permission Set ID from the JSON ParentIdList.
     * Handles both String and List formats.
     * @param parentIdListJson The JSON string from the event.
     * @return The extracted ID or null if invalid.
     */
    private String extractPermSetId(String parentIdListJson) {
        try {
            Map<String, Object> wrapper = (Map<String, Object>) JSON.deserializeUntyped(parentIdListJson);
            Object idsObj = wrapper.get('ParentIds');
           
            if (idsObj instanceof String) {
                return (String) idsObj;
            } else if (idsObj instanceof List<Object> && !((List<Object>) idsObj).isEmpty()) {
                return (String) ((List<Object>) idsObj)[0];
            }
        } catch (Exception e) {
            LOGGER.error('TSP_BlockAPIEnabledEventCondition.extractPermSetId', e);
        }
        return null;
    }
    
    /**
     * @description Retrieves the Permission Set by ID.
     * @param permSetId The ID to query.
     * @return The PermissionSet record or null if not found.
     */
    private PermissionSet getPermissionSet(String permSetId) {
        List<PermissionSet> psRecords = new SEL_PermissionSet().selectByPermissionSetId(permSetId);
        return psRecords.isEmpty() ? null : psRecords[0];
    }
    
    /**
     * @description Checks if the Permission Set name is in the allowlist.
     * @param permSetName The name to check.
     * @return True if allowed, false otherwise.
     */
    private boolean isAllowed(String permSetName) {
        return allowedPermSetNames.contains(permSetName);
    }
}