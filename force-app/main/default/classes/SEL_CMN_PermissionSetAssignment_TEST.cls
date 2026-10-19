/**
 * @description       : Test class for SEL_CMN_PermissionSetAssignment
 * @author            : Given Khupai
 * @last modified on  : 07-08-2026
 * @LastModified by   : Given Khupai
 * @UserStory         : SFP-46473
 * @LastModifiedReason: Updated test class to cover selectById, error handling and standards compliance
 **/
@isTest
private class SEL_CMN_PermissionSetAssignment_TEST {

    private static final String NON_EXISTENT_PERM_SET = 'NonExistent_PermSet_XYZ_999';

    @isTest
    static void getSObjectFieldListReturnsExpectedFields() {
        // Arrange
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        // Assert
        Assert.isFalse(fields.isEmpty(), 'Field list should not be empty');
        Assert.isTrue(
            fields.contains(PermissionSetAssignment.Id),
            'Field list should contain Id'
        );
        Assert.isTrue(
            fields.contains(PermissionSetAssignment.AssigneeId),
            'Field list should contain AssigneeId'
        );
        Assert.isTrue(
            fields.contains(PermissionSetAssignment.PermissionSetId),
            'Field list should contain PermissionSetId'
        );
    }

    @isTest
    static void getSObjectTypeReturnsPermissionSetAssignment() {
        // Arrange
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            Schema.SObjectType sObjType = selector.getSObjectType();
        Test.stopTest();

        // Assert
        Assert.areEqual(
            PermissionSetAssignment.SObjectType,
            sObjType,
            'SObject type should be PermissionSetAssignment'
        );
    }

    @isTest
    static void selectByIdPositiveOutcome() {
        // Arrange
        Id currentUserId = UserInfo.getUserId();

        List<PermissionSetAssignment> existingAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :currentUserId
            LIMIT 1
        ];

        if (existingAssignments.isEmpty()) {
            return;
        }

        Set<Id> assignmentIds = new Set<Id>{ existingAssignments[0].Id };
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<PermissionSetAssignment> results = selector.selectById(assignmentIds);
        Test.stopTest();

        // Assert
        Assert.isFalse(results.isEmpty(), 'Should return at least one assignment');
        Assert.areEqual(
            existingAssignments[0].Id,
            results[0].Id,
            'Returned record Id should match the queried Id'
        );
    }

    @isTest
    static void selectByIdEmptySetReturnsNoResults() {
        // Arrange
        Set<Id> emptyIdSet = new Set<Id>();
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<PermissionSetAssignment> results = selector.selectById(emptyIdSet);
        Test.stopTest();

        // Assert
        Assert.isTrue(
            results.isEmpty(),
            'Should return no assignments for an empty ID set'
        );
    }

    @isTest
    static void selectByUserAndPermissionSetNamePositiveOutcome() {
        // Arrange
        Id currentUserId = UserInfo.getUserId();

        List<PermissionSet> permSets = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE IsOwnedByProfile = FALSE
            LIMIT 1
        ];

        if (permSets.isEmpty()) {
            return;
        }

        PermissionSet targetPermSet = permSets[0];

        List<PermissionSetAssignment> existing = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :currentUserId
              AND PermissionSetId = :targetPermSet.Id
        ];

        if (existing.isEmpty()) {
            insert new PermissionSetAssignment(
                AssigneeId = currentUserId,
                PermissionSetId = targetPermSet.Id
            );
        }

        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<PermissionSetAssignment> results =
                selector.selectByUserAndPermissionSetName(
                    currentUserId,
                    targetPermSet.Name
                );
        Test.stopTest();

        // Assert
        Assert.isFalse(results.isEmpty(), 'Should return at least one assignment');
        Assert.areEqual(
            currentUserId,
            results[0].AssigneeId,
            'AssigneeId should match the queried user'
        );
    }

    @isTest
    static void selectByUserAndPermissionSetNameNullUserIdReturnsNoResults() {
        // Arrange
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<PermissionSetAssignment> results =
                selector.selectByUserAndPermissionSetName(null, 'AnyPermSetName');
        Test.stopTest();

        // Assert
        Assert.isTrue(
            results.isEmpty(),
            'Should return no assignments when userId is null'
        );
    }

    @isTest
    static void selectByUserAndPermissionSetNameExceptionIsLoggedAndRethrown() {
        // Arrange
        SEL_CMN_PermissionSetAssignment.forceSelectByUserAndPermissionSetNameException = true;
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();
        Boolean exceptionThrown = false;

        Test.startTest();
            // Act
            try {
                selector.selectByUserAndPermissionSetName(UserInfo.getUserId(), 'AnyPermSetName');
            } catch (System.QueryException ex) {
                exceptionThrown = true;
            }
        Test.stopTest();

        // Assert
        Assert.isTrue(exceptionThrown, 'Exception should have been re-thrown after logging');
    }

    @isTest
    static void selectByAssigneeAndPermissionSetIdsEmptyInputReturnsNoResults() {
        // Arrange
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<PermissionSetAssignment> results =
                selector.selectByAssigneeAndPermissionSetIds(new Set<Id>(), new Set<Id>());
        Test.stopTest();

        // Assert
        Assert.isTrue(
            results.isEmpty(),
            'Should return no assignments for empty assignee/permission set inputs'
        );
    }

    @isTest
    static void selectByAssigneeAndPermissionSetIdsExceptionIsLoggedAndRethrown() {
        // Arrange
        SEL_CMN_PermissionSetAssignment.forceSelectByAssigneeAndPermissionSetIdsException = true;
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();
        Boolean exceptionThrown = false;

        Test.startTest();
            // Act
            try {
                selector.selectByAssigneeAndPermissionSetIds(
                    new Set<Id>{ UserInfo.getUserId() },
                    new Set<Id>{ UserInfo.getUserId() }
                );
            } catch (System.QueryException ex) {
                exceptionThrown = true;
            }
        Test.stopTest();

        // Assert
        Assert.isTrue(exceptionThrown, 'Exception should have been re-thrown after logging');
    }

    @isTest
    static void selectByUserAndPermissionSetNameNegativeOutcome() {
        // Arrange
        Id currentUserId = UserInfo.getUserId();
        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act
            List<PermissionSetAssignment> results =
                selector.selectByUserAndPermissionSetName(
                    currentUserId,
                    NON_EXISTENT_PERM_SET
                );
        Test.stopTest();

        // Assert
        Assert.isTrue(
            results.isEmpty(),
            'Should return no assignments for a non-existent permission set name'
        );
    }

    @isTest
    static void selectByUserAndPermissionSetNameBulkOutcome() {
        // Arrange
        Id currentUserId = UserInfo.getUserId();

        List<PermissionSet> permSets = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE IsOwnedByProfile = FALSE
            LIMIT 5
        ];

        if (permSets.isEmpty()) {
            return;
        }

        Set<Id> permissionSetIds = new Set<Id>();
        for (PermissionSet ps : permSets) {
            permissionSetIds.add(ps.Id);
        }

        Set<Id> assignedPermissionSetIds = new Set<Id>();
        for (PermissionSetAssignment psa : [
            SELECT Id, PermissionSetId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :currentUserId
              AND PermissionSetId IN :permissionSetIds
        ]) {
            assignedPermissionSetIds.add(psa.PermissionSetId);
        }

        List<PermissionSetAssignment> assignmentsToInsert = new List<PermissionSetAssignment>();
        for (PermissionSet ps : permSets) {
            if (!assignedPermissionSetIds.contains(ps.Id)) {
                assignmentsToInsert.add(new PermissionSetAssignment(
                    AssigneeId = currentUserId,
                    PermissionSetId = ps.Id
                ));
            }
        }

        if (!assignmentsToInsert.isEmpty()) {
            insert assignmentsToInsert;
        }

        SEL_CMN_PermissionSetAssignment selector = new SEL_CMN_PermissionSetAssignment();

        Test.startTest();
            // Act — single bulk query across all permission sets for the user
            List<PermissionSetAssignment> results =
                selector.selectByAssigneeAndPermissionSetIds(
                    new Set<Id>{ currentUserId },
                    permissionSetIds
                );
        Test.stopTest();

        // Assert
        Assert.isTrue(
            results.size() >= permSets.size(),
            'Should return results for each queried permission set'
        );
    }
}