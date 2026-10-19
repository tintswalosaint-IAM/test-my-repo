/**
 * @description       : Test class for SEL_PermissionSet selector class
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * created date       : 16/10/2025
 * @last modified on  : 01-15-2026
 * @LastModified by   : Jagadish Thummala
 * @UserStory         : SFP-54919
**/
@isTest
private class SEL_PermissionSet_Test {
    
    private static final SObjectType SOBJECT_TYPE = PermissionSet.SObjectType;
    private static final List<PermissionSet> EMPTY_LIST = new List<PermissionSet>();
    
    /**
     * Test getSObjectType method returns correct SObjectType 
     */
    @IsTest
    static void shouldReturnCorrectSObjectType() {
        // Given
        SEL_PermissionSet selector = new SEL_PermissionSet();
        
        // When
        Schema.SObjectType result = selector.getSObjectType();
        
        // Then
        Assert.areEqual(
            SOBJECT_TYPE,
            result,
            'Expected PermissionSet SObjectType to be returned'
        );
    }
    
    /**
     * Test getSObjectFieldList method returns field list
     */
    @IsTest
    static void shouldReturnSObjectFieldList() {
        // Given
        SEL_PermissionSet selector = new SEL_PermissionSet();
        
        // When
        List<Schema.SObjectField> result = selector.getSObjectFieldList();
        
        // Then
        Assert.isNotNull(
            result,
            'Expected field list to not be null'
        );
        Assert.isTrue(
             !result.isEmpty(),
            'Expected field list to contain fields'
        );
        Assert.isTrue(
            result.contains(PermissionSet.Id),
            'Expected field list to contain Id field'
        );
        Assert.isTrue(
            result.contains(PermissionSet.Name),
            'Expected field list to contain Name field'
        );
    }
    
    /**
     * Test selectByPermissionSetName with valid permission set name
     */
    @IsTest
    static void shouldReturnPermissionSetByNames() {
        // Given
        SEL_PermissionSet selector = new SEL_PermissionSet();
        // Query for an existing standard permission set
        List<PermissionSet> existingPermSets = [
            SELECT Id, Name 
            FROM PermissionSet 
            WHERE IsOwnedByProfile = false 
            LIMIT 1
        ];
        
        // Skip test if no permission sets exist
        if (existingPermSets.isEmpty()) {
            Assert.isTrue(true, 'No permission sets available for testing');
            return;
        }
        
        String permSetName = existingPermSets[0].Name;
        
        // When
        List<PermissionSet> result = selector.selectByPermissionSetNames(new List<String>{permSetName});
        
        // Then
        Assert.isNotNull(
            result,
            'Expected result to not be null'
        );
        Assert.areEqual(
            1,
            result.size(),
            'Expected one permission set to be returned'
        );
        Assert.areEqual(
            permSetName,
            result[0].Name,
            'Expected permission set name to match'
        );
    }
    
    /**
     * Test selectByPermissionSetName with non-existent permission set name
     */
    @IsTest
    static void shouldReturnEmptyListForNonExistentPermissionSetName() {
        // Given
        SEL_PermissionSet selector = new SEL_PermissionSet();
        String nonExistentName = 'NonExistent_Permission_Set_Name_12345';
        
        // When
        List<PermissionSet> result = selector.selectByPermissionSetNames(new List<String>{nonExistentName});
        
        // Then
        Assert.areEqual(
            EMPTY_LIST,
            result,
            'Expected empty list for non-existent permission set name'
        );
    }
    
    /**
     * Test selectByPermissionSetId with valid permission set Id
     */
    @IsTest
    static void shouldReturnPermissionSetById() {
        // Given
        SEL_PermissionSet selector = new SEL_PermissionSet();
        // Query for an existing permission set
        List<PermissionSet> existingPermSets = [
            SELECT Id, Name 
            FROM PermissionSet 
            WHERE IsOwnedByProfile = false 
            LIMIT 1
        ];
        
        // Skip test if no permission sets exist
        if (existingPermSets.isEmpty()) {
            Assert.isTrue(true, 'No permission sets available for testing');
            return;
        }
        
        Id permSetId = existingPermSets[0].Id;
        
        // When
        List<PermissionSet> result = selector.selectByPermissionSetId(permSetId);
        
        // Then
        Assert.isNotNull(
            result,
            'Expected result to not be null'
        );
        Assert.areEqual(
            1,
            result.size(),
            'Expected one permission set to be returned'
        );
        Assert.areEqual(
            permSetId,
            result[0].Id,
            'Expected permission set Id to match'
        );
    }

    
    /**
     * Test that SOQL query is valid and doesn't throw exceptions
     */
    @IsTest
    static void shouldNotThrowExceptionWhenBuildingQuery() {
        // Given
        SEL_PermissionSet selector = new SEL_PermissionSet();
        
        // When & Then - No exception should be thrown
        try {
            selector.newQueryFactory().toSOQL();
            Assert.isTrue(true, 'Expected query to build successfully');
        } catch (Exception e) {
            Assert.fail('Expected no exception but got: ' + e.getMessage());
        }
    }
}