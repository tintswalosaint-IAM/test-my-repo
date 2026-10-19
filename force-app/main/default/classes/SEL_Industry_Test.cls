/**
 * @File Name         : SEL_Industry_Test.cls
 * @Description       : Test Class for Selector class for CMN_Industry__c SObject used to encapsulate queries following fflib pattern.
 * @Author            : Ramya Gurram
 * @Last Modified By  : Ramya Gurram
 * @Last Modified On  : September 12, 2025
 */
@IsTest
public class SEL_Industry_Test {
 private static final String RECORD_TYPE_MANUFACTURING = 'Manufacturing';
    private static final String RECORD_TYPE_TECHNOLOGY = 'Technology';
    private static final String MAIN_INDUSTRY_TEST = 'Test Main Industry';
    private static final String SUB_INDUSTRY_TEST = 'Test Sub Industry';
    private static final String RISK_RATING_LOW = 'Low';
    private static final String SLUG_ID_TEST = 'test-slug-id';
    
    /**
     * @description Setup test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        // Get RecordTypes for CMN_Industry__c
        List<RecordType> recordTypes = [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'CMN_Industry__c' 
            AND IsActive = true
            LIMIT 2
        ];
        
        // If no record types exist, create some test records without specific record types
        List<CMN_Industry__c> testIndustries = new List<CMN_Industry__c>();
        
        if (!recordTypes.isEmpty()) {
            // Create test records with first available record type
            testIndustries.add(new CMN_Industry__c(
               
                CMN_MainIndustry__c = MAIN_INDUSTRY_TEST,
                CMN_SubIndustry__c = SUB_INDUSTRY_TEST,
                CMN_RiskRating__c = RISK_RATING_LOW,
                CMN_SlugID__c = '-1',
                CMN_Active__c = true,
                RecordTypeId = recordTypes[0].Id
            ));
            
            testIndustries.add(new CMN_Industry__c(
               
                CMN_MainIndustry__c = MAIN_INDUSTRY_TEST,
                CMN_SubIndustry__c = SUB_INDUSTRY_TEST,
                CMN_RiskRating__c = RISK_RATING_LOW,
                CMN_SlugID__c = '-2',
                CMN_Active__c = false,
                RecordTypeId = recordTypes[0].Id
            ));
            
            // If there's a second record type, create records with it
            if (recordTypes.size() > 1) {
                testIndustries.add(new CMN_Industry__c(
                   
                    CMN_MainIndustry__c = MAIN_INDUSTRY_TEST,
                    CMN_SubIndustry__c = SUB_INDUSTRY_TEST,
                    CMN_RiskRating__c = RISK_RATING_LOW,
                    CMN_SlugID__c = '-3',
                    CMN_Active__c = true,
                    RecordTypeId = recordTypes[1].Id
                ));
            }
        } else {
            // Create basic test records without specific record types
            testIndustries.add(new CMN_Industry__c(
               
                CMN_MainIndustry__c = MAIN_INDUSTRY_TEST,
                CMN_SubIndustry__c = SUB_INDUSTRY_TEST,
                CMN_RiskRating__c = RISK_RATING_LOW,
                CMN_SlugID__c = '1-1',
                CMN_Active__c = true
            ));
            
            testIndustries.add(new CMN_Industry__c(
               
                CMN_MainIndustry__c = MAIN_INDUSTRY_TEST,
                CMN_SubIndustry__c = SUB_INDUSTRY_TEST,
                CMN_RiskRating__c = RISK_RATING_LOW,
                CMN_SlugID__c = '2-2',
                CMN_Active__c = false
            ));
        }
        
        insert testIndustries;
    }
    
    /**
     * @description Test getSObjectType method
     */
    @IsTest
    static void testGetSObjectType() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // When
        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();
        
        // Then
       Assert.areEqual(CMN_Industry__c.sObjectType, result, 'Should return CMN_Industry__c SObjectType');
    }
    
    /**
     * @description Test getSObjectFieldList method
     */
    @IsTest
    static void testGetSObjectFieldList() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // When
        Test.startTest();
        List<Schema.SObjectField> result = selector.getSObjectFieldList();
        Test.stopTest();
        
        // Then
       Assert.areNotEqual(null, result, 'Result should not be null');
       Assert.isFalse(result.isEmpty(), 'Result should not be empty');
        Assert.isTrue(result.contains(CMN_Industry__c.Id), 'Should contain Id field');
       Assert.isTrue(result.contains(CMN_Industry__c.CMN_MainIndustry__c), 'Should contain CMN_MainIndustry__c field');
       Assert.isTrue(result.contains(CMN_Industry__c.CMN_Active__c), 'Should contain CMN_Active__c field');
    }
    
    /**
     * @description Test selectByRecordType method with valid parameters
     */
    @IsTest
    static void testSelectByRecordType_ValidParameters() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // Get the first available record type name
        List<RecordType> recordTypes = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SObjectType = 'CMN_Industry__c' 
            AND IsActive = true
            LIMIT 1
        ];
        
        if (recordTypes.isEmpty()) {
            // Skip this test if no record types are available
            return;
        }
        
        String recordTypeName = recordTypes[0].Name;
        
        // When
        Test.startTest();
        List<CMN_Industry__c> activeResults = selector.selectByRecordType(true, recordTypeName);
        List<CMN_Industry__c> inactiveResults = selector.selectByRecordType(false, recordTypeName);
        Test.stopTest();
        
        // Then
        Assert.areNotEqual(null, activeResults, 'Active results should not be null');
         Assert.areNotEqual(null, inactiveResults, 'Inactive results should not be null');
        
        // Verify all returned records match the criteria
        for (CMN_Industry__c industry : activeResults) {
           Assert.areEqual(true, industry.CMN_Active__c, 'All returned records should be active');
            Assert.areEqual(recordTypeName, industry.RecordType.Name, 'All returned records should have correct record type');
        }
        
        for (CMN_Industry__c industry : inactiveResults) {
            Assert.areEqual(false, industry.CMN_Active__c, 'All returned records should be inactive');
            Assert.areEqual(recordTypeName, industry.RecordType.Name, 'All returned records should have correct record type');
        }
    }
    
    /**
     * @description Test selectByRecordType method with blank record type
     */
    @IsTest
    static void testSelectByRecordType_BlankRecordType() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // When
        Test.startTest();
        List<CMN_Industry__c> resultNull = selector.selectByRecordType(true, null);
        List<CMN_Industry__c> resultEmpty = selector.selectByRecordType(true, '');
        List<CMN_Industry__c> resultBlank = selector.selectByRecordType(true, '   ');
        Test.stopTest();
        
        // Then
       Assert.areEqual(null, resultNull, 'Should return null for null record type');
        Assert.areEqual(null, resultEmpty, 'Should return null for empty record type');
        Assert.areEqual(null, resultBlank, 'Should return null for blank record type');
    }
    
    /**
     * @description Test selectByRecordTypeId method with valid parameters
     */
    @IsTest
    static void testSelectByRecordTypeId_ValidParameters() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // Get a test record
        List<CMN_Industry__c> testRecords = [
            SELECT Id, RecordType.Name, CMN_Active__c 
            FROM CMN_Industry__c 
            WHERE CMN_Active__c = true
            LIMIT 1
        ];
        
        if (testRecords.isEmpty()) {
            // Skip this test if no test records are available
            return;
        }
        
        CMN_Industry__c testRecord = testRecords[0];
        String recordTypeName = testRecord.RecordType?.Name;
        
        // When
        Test.startTest();
        List<CMN_Industry__c> results = selector.selectByRecordTypeIds(
            testRecord.CMN_Active__c, 
            recordTypeName, 
            new set<string>{testRecord.Id}
        );
        Test.stopTest();
        
        // Then
        Assert.areNotEqual(null, results, 'Results should not be null');
        Assert.areEqual(1, results.size(), 'Should return exactly one record');
       Assert.areEqual(testRecord.Id, results[0].Id, 'Should return the correct record');
        Assert.areEqual(testRecord.CMN_Active__c, results[0].CMN_Active__c, 'Active status should match');
    }
    
    /**
     * @description Test selectByRecordTypeId method with blank record type
     */
    @IsTest
    static void testSelectByRecordTypeId_BlankRecordType() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        String testId = 'a0012345678901234'; // Valid format Id for testing
        
        // When
        Test.startTest();
        List<CMN_Industry__c> resultNull = selector.selectByRecordTypeIds(true, null, new set<string>{testId});
        List<CMN_Industry__c> resultEmpty = selector.selectByRecordTypeIds(true, '', new set<string>{testId});
        List<CMN_Industry__c> resultBlank = selector.selectByRecordTypeIds(true, '   ', new set<string>{testId});
        Test.stopTest();
        
        // Then
       Assert.areEqual(null, resultNull, 'Should return null for null record type');
       Assert.areEqual(null, resultEmpty, 'Should return null for empty record type');
        Assert.areEqual(null, resultBlank, 'Should return null for blank record type');
    }
    
    /**
     * @description Test selectByRecordTypeId method with non-existent record
     */
    @IsTest
    static void testSelectByRecordTypeId_NonExistentRecord() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // Get the first available record type name
        List<RecordType> recordTypes = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SObjectType = 'CMN_Industry__c' 
            AND IsActive = true
            LIMIT 1
        ];
        
        if (recordTypes.isEmpty()) {
            // Skip this test if no record types are available
            return;
        }
        
        String recordTypeName = recordTypes[0].Name;
        String nonExistentId = 'a0012345678901234'; // Valid format but non-existent Id
        
        // When
        Test.startTest();
        List<CMN_Industry__c> results = selector.selectByRecordTypeIds(true, recordTypeName, new set<string>{nonExistentId});
        Test.stopTest();
        
        // Then
        Assert.areNotEqual(null, results, 'Results should not be null');
       Assert.areEqual(0, results.size(), 'Should return empty list for non-existent record');
    }
    
    /**
     * @description Test that selector returns all expected fields
     */
    @IsTest
    static void testSelectByRecordType_ReturnsAllFields() {
        // Given
        SEL_Industry selector = new SEL_Industry();
        
        // Get the first available record type name
        List<RecordType> recordTypes = [
            SELECT Id, Name 
            FROM RecordType 
            WHERE SObjectType = 'CMN_Industry__c' 
            AND IsActive = true
            LIMIT 1
        ];
        
        if (recordTypes.isEmpty()) {
            // Skip this test if no record types are available
            return;
        }
        
        String recordTypeName = recordTypes[0].Name;
        
        // When
        Test.startTest();
        List<CMN_Industry__c> results = selector.selectByRecordType(true, recordTypeName);
        Test.stopTest();
        
        // Then
        if (!results.isEmpty()) {
            CMN_Industry__c industry = results[0];
            
            // Verify all expected fields are populated (not testing for null as some may be optional)
            Assert.areNotEqual(null, industry.Id, 'Id should not be null');
            Assert.areNotEqual(null, industry.Name, 'Name should not be null');
            // Note: Other fields might be null depending on test data, so we just verify they're accessible
            
            // Test field access without throwing exceptions
            String mainIndustry = industry.CMN_MainIndustry__c;
            String subIndustry = industry.CMN_SubIndustry__c;
            String riskRating = industry.CMN_RiskRating__c;
            String slugId = industry.CMN_SlugID__c;
            Boolean isActive = industry.CMN_Active__c;
            String recordTypeNameField = industry.RecordType?.Name;
            
            Assert.areEqual(true, isActive, 'Active field should be true for active records');
            Assert.areEqual(recordTypeName, recordTypeNameField, 'Record type name should match');
        }
    }
}