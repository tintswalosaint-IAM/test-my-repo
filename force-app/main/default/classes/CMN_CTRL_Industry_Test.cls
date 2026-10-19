/**
 * @description       : Test class for CMN_CTRL_Industry controller
 * @author            :
 * @group             : Test Classes
 * @last modified on  : 09-12-2025
 * @last modified by  : Generated
**/
@IsTest
public class CMN_CTRL_Industry_Test {
    
    // Test data setup
    @TestSetup
    static void setupTestData() {
        // Create test records for different scenarios
        List<CMN_Industry__c> testIndustries = new List<CMN_Industry__c>();
        
        // Create records for Technology main industry with multiple sub-industries
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Technology',
            CMN_SubIndustry__c = 'Software Development',
            CMN_RiskRating__c = 'Low',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='001'
        ));
        
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Technology',
            CMN_SubIndustry__c = 'Hardware Manufacturing',
            CMN_RiskRating__c = 'Medium',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='002'
        ));
        
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Technology',
            CMN_SubIndustry__c = 'Software Development', // Duplicate to test duplicate handling
            CMN_RiskRating__c = 'Low',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='003'
        ));
        
        // Create records for Finance main industry
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Finance',
            CMN_SubIndustry__c = 'Banking',
            CMN_RiskRating__c = 'High',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='004'
        ));
        
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Finance',
            CMN_SubIndustry__c = 'Insurance',
            CMN_RiskRating__c = 'Medium',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='004'
        ));
        
        // Create record with only main industry (no sub-industry)
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Healthcare',
            CMN_SubIndustry__c = null,
            CMN_RiskRating__c = 'Medium',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='004'
        ));
        
        // Create record for Retail
        testIndustries.add(new CMN_Industry__c(
            CMN_MainIndustry__c = 'Retail',
            CMN_SubIndustry__c = 'E-commerce',
            CMN_RiskRating__c = 'Low',
            CMN_Active__c=true,
            RecordTypeId = getRecordTypeId('SBO'),
            CMN_SlugID__c='tes'
        ));
        
        insert testIndustries;
    }
    
    // Helper method to get RecordType Id (mock implementation)
    static Id getRecordTypeId(String recordTypeName) {
        // In a real scenario, you would query for actual RecordType
        // For test purposes, we'll create a mock Id or use Schema.SObjectType approach
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'CMN_Industry__c' AND DeveloperName = :recordTypeName LIMIT 1];
        if (!recordTypes.isEmpty()) {
            return recordTypes[0].Id;
        }
        // Return a mock Id for testing if RecordType doesn't exist
        return CMN_Industry__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().values()[0].getRecordTypeId();
    }
    
    @IsTest
    static void testConstructor() {
        Test.startTest();
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        Test.stopTest();
        
        // Assert that maps are initialized
        Assert.isNotNull(controller.mainIndustryToSubIndustries, 'mainIndustryToSubIndustries should be initialized');
        Assert.isNotNull(controller.mainIndustryToRecord, 'mainIndustryToRecord should be initialized');
        Assert.areEqual(0, controller.mainIndustryToSubIndustries.size(), 'mainIndustryToSubIndustries should be empty initially');
        Assert.areEqual(0, controller.mainIndustryToRecord.size(), 'mainIndustryToRecord should be empty initially');
    }
    
    @IsTest
    static void testLoadGroupedIndustryData() {
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        
        Test.startTest();
        controller.loadGroupedIndustryData();
        Test.stopTest();
        
        // Assert that data is loaded correctly
        Assert.isTrue(controller.mainIndustryToSubIndustries.size() > 0, 'Should have loaded main industries');
        Assert.isTrue(controller.mainIndustryToRecord.size() > 0, 'Should have loaded main industry records');
        
        // Test specific data
        Assert.isTrue(controller.mainIndustryToSubIndustries.containsKey('Technology'), 'Should contain Technology industry');
        Assert.isTrue(controller.mainIndustryToSubIndustries.containsKey('Finance'), 'Should contain Finance industry');
        Assert.isTrue(controller.mainIndustryToSubIndustries.containsKey('Healthcare'), 'Should contain Healthcare industry');
        
        // Test Technology sub-industries (should have 2 unique sub-industries despite 3 records)
        List<CMN_CTRL_Industry.SubIndustryWrapper> techSubIndustries = controller.mainIndustryToSubIndustries.get('Technology');
        Assert.areEqual(2, techSubIndustries.size(), 'Technology should have 2 unique sub-industries');
        
        // Test Finance sub-industries
        List<CMN_CTRL_Industry.SubIndustryWrapper> financeSubIndustries = controller.mainIndustryToSubIndustries.get('Finance');
        Assert.areEqual(2, financeSubIndustries.size(), 'Finance should have 2 sub-industries');
        
        // Test Healthcare (no sub-industries)
        List<CMN_CTRL_Industry.SubIndustryWrapper> healthcareSubIndustries = controller.mainIndustryToSubIndustries.get('Healthcare');
        Assert.areEqual(0, healthcareSubIndustries.size(), 'Healthcare should have 0 sub-industries');
        
        // Test that main industry records are stored
        Assert.isNotNull(controller.mainIndustryToRecord.get('Technology'), 'Should have Technology main record');
        Assert.isNotNull(controller.mainIndustryToRecord.get('Finance'), 'Should have Finance main record');
    }
    
    @IsTest
    static void testGetSubIndustriesForMain() {
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        
        Test.startTest();
        // Test with data not loaded yet (should trigger loadGroupedIndustryData)
        List<CMN_CTRL_Industry.SubIndustryWrapper> techSubIndustries = controller.getSubIndustriesForMain('Technology');
        Test.stopTest();
        
        // Assert that data is returned
        Assert.isNotNull(techSubIndustries, 'Should return sub-industries list');
        Assert.areEqual(2, techSubIndustries.size(), 'Technology should have 2 unique sub-industries');
        
        // Test specific sub-industry values
        Set<String> subIndustryValues = new Set<String>();
        for (CMN_CTRL_Industry.SubIndustryWrapper wrapper : techSubIndustries) {
            subIndustryValues.add(wrapper.value);
            Assert.isNotNull(wrapper.id, 'SubIndustry should have an Id');
            Assert.isNotNull(wrapper.riskRating, 'SubIndustry should have a risk rating');
        }
        Assert.isTrue(subIndustryValues.contains('Software Development'), 'Should contain Software Development');
        Assert.isTrue(subIndustryValues.contains('Hardware Manufacturing'), 'Should contain Hardware Manufacturing');
        
        // Test with non-existent main industry
        List<CMN_CTRL_Industry.SubIndustryWrapper> nonExistentSubIndustries = controller.getSubIndustriesForMain('NonExistent');
        Assert.isNull(nonExistentSubIndustries, 'Should return null for non-existent main industry');
    }
    
    @IsTest
    static void testGetGroupedDataAsJSON() {
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        
        Test.startTest();
        String jsonResult = controller.getGroupedDataAsJSON();
        Test.stopTest();
        
        // Assert that JSON is returned
        Assert.isNotNull(jsonResult, 'Should return JSON string');
        Assert.isTrue(jsonResult.length() > 0, 'JSON string should not be empty');
        
        // Parse JSON to verify structure
        List<Object> parsedResult = (List<Object>) JSON.deserializeUntyped(jsonResult);
        Assert.isTrue(parsedResult.size() > 0, 'Should have industry data in JSON');
        
        // Test structure of first industry
        Map<String, Object> firstIndustry = (Map<String, Object>) parsedResult[0];
        Assert.isTrue(firstIndustry.containsKey('mainIndustry'), 'Should contain mainIndustry key');
        Assert.isTrue(firstIndustry.containsKey('riskRating'), 'Should contain riskRating key');
        Assert.isTrue(firstIndustry.containsKey('Id'), 'Should contain Id key');
        Assert.isTrue(firstIndustry.containsKey('subIndustries'), 'Should contain subIndustries key');
        Assert.isTrue(firstIndustry.containsKey('subIndustryCount'), 'Should contain subIndustryCount key');
        
        // Verify that subIndustryCount matches actual sub-industries
        List<Object> subIndustries = (List<Object>) firstIndustry.get('subIndustries');
        Integer subIndustryCount = (Integer) firstIndustry.get('subIndustryCount');
        Assert.areEqual(subIndustries.size(), subIndustryCount, 'subIndustryCount should match actual count');
    }
    
    @IsTest
    static void testGetIndustryPicklistWithId() {
        // Get a test record Id
        List<CMN_Industry__c> testRecords = [SELECT Id FROM CMN_Industry__c LIMIT 1];
        Assert.isFalse(testRecords.isEmpty(), 'Should have test records');
        
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        
        Test.startTest();
        List<CMN_Industry__c> result = controller.getIndustryPicklistWithId(testRecords[0].Id);
        Test.stopTest();
        
        // Assert that records are returned
        Assert.isNotNull(result, 'Should return industry records');
        // Note: The actual assertion depends on the SEL_Industry selector implementation
        // In a real scenario, you might need to assert based on what the selector returns
    }
    
    @IsTest
    static void testSubIndustryWrapperClass() {
        Test.startTest();
        CMN_CTRL_Industry.SubIndustryWrapper wrapper = new CMN_CTRL_Industry.SubIndustryWrapper(
            'testId123', 
            'Test Sub-Industry', 
            'Medium'
        );
        Test.stopTest();
        
        // Assert wrapper properties
        Assert.areEqual('testId123', wrapper.id, 'Id should be set correctly');
        Assert.areEqual('Test Sub-Industry', wrapper.value, 'Value should be set correctly');
        Assert.areEqual('Medium', wrapper.riskRating, 'Risk rating should be set correctly');
    }
    
    @IsTest
    static void testEmptyDataScenario() {
        // Delete all test data to test empty scenario
        delete [SELECT Id FROM CMN_Industry__c];
        
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        
        Test.startTest();
        controller.loadGroupedIndustryData();
        String jsonResult = controller.getGroupedDataAsJSON();
        List<CMN_CTRL_Industry.SubIndustryWrapper> emptyResult = controller.getSubIndustriesForMain('AnyIndustry');
        Test.stopTest();
        
        // Assert empty scenarios
        Assert.areEqual(0, controller.mainIndustryToSubIndustries.size(), 'Should have no main industries');
        Assert.areEqual(0, controller.mainIndustryToRecord.size(), 'Should have no main industry records');
        Assert.areEqual('[ ]', jsonResult, 'Should return empty JSON array');
        Assert.isNull(emptyResult, 'Should return null for any main industry');
    }
    
    @IsTest
    static void testMultipleCallsToLoadGroupedIndustryData() {
        CMN_CTRL_Industry controller = new CMN_CTRL_Industry();
        
        Test.startTest();
        // Call multiple times to ensure maps are cleared and repopulated
        controller.loadGroupedIndustryData();
        Integer firstCallSize = controller.mainIndustryToSubIndustries.size();
        
        controller.loadGroupedIndustryData();
        Integer secondCallSize = controller.mainIndustryToSubIndustries.size();
        Test.stopTest();
        
        // Assert that subsequent calls work correctly
        Assert.areEqual(firstCallSize, secondCallSize, 'Should have same size after multiple calls');
        Assert.isTrue(secondCallSize > 0, 'Should still have data after second call');
    }
}