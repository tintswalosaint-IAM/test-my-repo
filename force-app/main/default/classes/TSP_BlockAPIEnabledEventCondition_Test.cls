/**
 * @description Test class for TSP_BlockAPIEnabledEventCondition to validate Transaction Security Policy
 * that blocks assignment of API-enabled Permission Sets unless they are on the approved allowlist.
 * This class tests both positive scenarios (blocking unauthorized API access) and negative scenarios
 * (allowing approved Permission Sets and handling edge cases).
 *
 * @author Jagadish Thummala
 * @date January 2026
 * @group Security
 * @see TSP_BlockAPIEnabledEventCondition
 * @Userstory : SFP-54919
 */
@isTest
public class TSP_BlockAPIEnabledEventCondition_Test {

    // Constants for common values
    private static final String ASSIGN_OPERATION = 'AssignedToUsers';
    private static final String CREATE_OPERATION = 'Created';
    private static final String TEST_USERNAME = 'testuser@example.com';
    private static final String DUMMY_PS_ID = '0PS000000000001';
    private static final String INVALID_PS_ID = '0PS000000000XXX';
    private static final String ALLOWED_PS_NAME = 'Integration_User';
    private static final String ALLOWED_PS_LABEL = 'Integration User';
    private static final String API_ENABLED_PS_NAME = 'Test_API_Enabled_PS';
    private static final String API_ENABLED_PS_LABEL = 'Test API Enabled PS';
    private static final String NO_API_PS_NAME = 'Test_No_API_PS';
    private static final String NO_API_PS_LABEL = 'Test No API PS';
    private static final String MULTI_API_PS_NAME = 'Test_Multi_API_PS';
    private static final String MULTI_API_PS_LABEL = 'Test Multi API PS';
    private static final String PARENT_IDS_JSON_KEY = 'ParentIds';

    // ------------ POSITIVE TEST CASES ------------

    /**
     * @description Validates that the Transaction Security Policy blocks assignment of a Permission Set
     * that has API access enabled but is NOT on the approved allowlist. This is the primary security
     * control to prevent unauthorized API access.
     *
     * Test Setup:
     * - Creates PermissionSet with PermissionsApiEnabled = true
     * - PermissionSet name is NOT in the allowlist
     *
     * Expected Result: evaluate() returns TRUE (block the assignment)
     */
    @isTest
    static void testBlockAPIEnabledPermissionSet() {
        PermissionSet testPS = new PermissionSet(
            Name = API_ENABLED_PS_NAME,
            Label = API_ENABLED_PS_LABEL,
            PermissionsApiEnabled = true
        );
        insert testPS;

        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":"' + testPS.Id + '"}';
        testEvent.Username = TEST_USERNAME;
        testEvent.EventIdentifier = 'TEST-001';

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(true, result, 'Should block API-enabled PermissionSet not on allow-list');
    }

    /**
     * @description Validates that the Transaction Security Policy allows assignment of a Permission Set
     * that has API access enabled when it IS on the approved allowlist. This ensures legitimate
     * integrations can function properly.
     *
     * Test Setup:
     * - Creates PermissionSet named 'Integration_User' with PermissionsApiEnabled = true
     * - Explicitly adds 'Integration_User' to the allowlist
     *
     * Expected Result: evaluate() returns FALSE (allow the assignment)
     */
    @isTest
    static void testAllowWhitelistedAPIPermissionSet() {
        PermissionSet testPS = new PermissionSet(
            Name = ALLOWED_PS_NAME,
            Label = ALLOWED_PS_LABEL,
            PermissionsApiEnabled = true
        );
        insert testPS;

        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":"' + testPS.Id + '"}';
        testEvent.Username = TEST_USERNAME;
        testEvent.EventIdentifier = 'TEST-002';

        Test.startTest();
        TSP_BlockAPIEnabledEventCondition.allowedPermSetNames = new Set<String>{ALLOWED_PS_NAME};

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);
        Test.stopTest();

        Assert.areEqual(false, result, 'Should allow whitelisted PermissionSet with API access');
    }

    /**
     * @description Validates that Permission Sets without API access are allowed regardless of
     * whether they are on the allowlist. This confirms the policy only targets API-enabled Permission Sets.
     *
     * Test Setup:
     * - Creates PermissionSet with PermissionsApiEnabled = false
     *
     * Expected Result: evaluate() returns FALSE (allow the assignment)
     */
    @isTest
    static void testAllowNonAPIPermissionSet() {
        PermissionSet testPS = new PermissionSet(
            Name = NO_API_PS_NAME,
            Label = NO_API_PS_LABEL,
            PermissionsApiEnabled = false
        );
        insert testPS;

        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":"' + testPS.Id + '"}';
        testEvent.Username = TEST_USERNAME;

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should allow PermissionSet without API access');
    }

    /**
     * @description Validates the policy correctly handles scenarios where multiple Permission Sets
     * are assigned simultaneously (ParentIdList contains array of IDs). Tests that the policy
     * evaluates the first Permission Set in the array.
     *
     * Test Setup:
     * - Creates PermissionSet with PermissionsApiEnabled = true
     * - ParentIdList contains array with test PS ID and additional dummy ID
     *
     * Expected Result: evaluate() returns TRUE (block when first ID has API enabled)
     */
    @isTest
    static void testBlockAPIWithMultipleParentIds() {
        PermissionSet testPS = new PermissionSet(
            Name = MULTI_API_PS_NAME,
            Label = MULTI_API_PS_LABEL,
            PermissionsApiEnabled = true
        );
        insert testPS;

        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":["' + testPS.Id + '","' + DUMMY_PS_ID + '"]}';
        testEvent.Username = TEST_USERNAME;

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(true, result, 'Should block when first ID in array has API enabled');
    }

    // ------------ NEGATIVE TEST CASES ------------

    /**
     * @description Validates that the policy only processes PermissionSetEventStore events.
     * Tests graceful handling when a different event type is passed.
     *
     * Test Setup:
     * - Passes ApiEvent instead of PermissionSetEventStore
     *
     * Expected Result: evaluate() returns FALSE (no blocking action)
     */
    @isTest
    static void testNonPermissionSetEvent() {
        ApiEvent apiEvent = new ApiEvent();

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(apiEvent);

        Assert.areEqual(false, result, 'Should return false for non-PermissionSetEventStore events');
    }

    /**
     * @description Validates that the policy only triggers on 'AssignedToUsers' operations.
     * Tests that other operations (Create, Update, Delete) are ignored.
     *
     * Test Setup:
     * - Creates event with Operation = 'Created' instead of 'AssignedToUsers'
     *
     * Expected Result: evaluate() returns FALSE (no blocking action)
     */
    @isTest
    static void testWrongOperation() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = CREATE_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":"' + DUMMY_PS_ID + '"}';

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when Operation is not AssignedToUsers');
    }

    /**
     * @description Validates graceful handling when ParentIdList is an empty string.
     * Tests defensive programming against missing data.
     *
     * Test Setup:
     * - ParentIdList = '' (empty string)
     *
     * Expected Result: evaluate() returns FALSE (no blocking action, fail safely)
     */
    @isTest
    static void testBlankParentIdList() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '';

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when ParentIdList is blank');
    }

    /**
     * @description Validates graceful handling when ParentIdList is null.
     * Tests null safety in the evaluation logic.
     *
     * Test Setup:
     * - ParentIdList = null
     *
     * Expected Result: evaluate() returns FALSE (no blocking action, fail safely)
     */
    @isTest
    static void testNullParentIdList() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = null;

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when ParentIdList is null');
    }

    /**
     * @description Validates error handling when ParentIdList contains invalid JSON.
     * Tests that JSON parsing errors are caught and handled gracefully.
     *
     * Test Setup:
     * - ParentIdList contains malformed JSON string
     *
     * Expected Result: evaluate() returns FALSE (catch exception, fail safely)
     */
    @isTest
    static void testMalformedParentIdListJSON() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{invalid json}';
        testEvent.Username = TEST_USERNAME;

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when JSON is malformed');
    }

    /**
     * @description Validates handling when ParentIdList JSON is valid but missing the required
     * 'ParentIds' field. Tests schema validation logic.
     *
     * Test Setup:
     * - Valid JSON but without 'ParentIds' key
     *
     * Expected Result: evaluate() returns FALSE (missing required field, fail safely)
     */
    @isTest
    static void testMissingParentIdsInJSON() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"OtherField":"value"}';

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when ParentIds is missing from JSON');
    }

    /**
     * @description Validates handling when ParentIds array exists but contains no elements.
     * Tests empty collection handling.
     *
     * Test Setup:
     * - ParentIdList = '{"ParentIds":[]}'
     *
     * Expected Result: evaluate() returns FALSE (no Permission Sets to evaluate)
     */
    @isTest
    static void testEmptyParentIdsArray() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":[]}';

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when ParentIds array is empty');
    }

    /**
     * @description Validates null safety when the entire event object is null.
     * Tests the outermost defensive check.
     *
     * Test Setup:
     * - Pass null as the event parameter
     *
     * Expected Result: evaluate() returns FALSE (null check passes, fail safely)
     */
    @isTest
    static void testNullEvent() {
        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(null);

        Assert.areEqual(false, result, 'Should return false for null event');
    }

    /**
     * @description Validates error handling when querying with an invalid Permission Set ID.
     * Tests that SOQL exceptions (no records found or invalid ID format) are handled gracefully.
     *
     * Test Setup:
     * - ParentIdList contains non-existent Permission Set ID
     *
     * Expected Result: evaluate() returns FALSE (catch query exception, fail safely)
     */
    @isTest
    static void testInvalidPermissionSetId() {
        PermissionSetEventStore testEvent = new PermissionSetEventStore();
        testEvent.Operation = ASSIGN_OPERATION;
        testEvent.ParentIdList = '{"' + PARENT_IDS_JSON_KEY + '":"' + INVALID_PS_ID + '"}';
        testEvent.Username = TEST_USERNAME;

        TSP_BlockAPIEnabledEventCondition eventCondition = new TSP_BlockAPIEnabledEventCondition();
        Boolean result = eventCondition.evaluate(testEvent);

        Assert.areEqual(false, result, 'Should return false when PermissionSet query fails');
    }
}