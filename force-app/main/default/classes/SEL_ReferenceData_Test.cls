@isTest
private class SEL_ReferenceData_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create parent reference data
        AOB_ReferencedData__c parentRef = new AOB_ReferencedData__c(
            Name = 'Test Parent',
            AOB_Code__c = 'PAR001',
            AOB_SapField__c = 'TEST_FIELD',
            AOB_CountryCode__c = 'US',
            AOB_ProductCategory__c = 'Category1'
        );
        insert parentRef;
        
        // Create child reference data
        AOB_ReferencedData__c childRef = new AOB_ReferencedData__c(
            Name = 'Test Child',
            AOB_Code__c = 'CHD001',
            AOB_SapField__c = 'TEST_FIELD',
            AOB_CountryCode__c = 'US',
            AOB_ProductCategory__c = 'Category2',
            AOB_Parent__c = parentRef.Id
        );
        insert childRef;
    }
    
    @isTest
    static void testGetSObjectType() {
        // Arrange
        SEL_ReferenceData selector = new SEL_ReferenceData();
        
        // Act
        Schema.SObjectType result = selector.getSObjectType();
        
        // Assert
        Assert.areEqual(AOB_ReferencedData__c.sObjectType, result, 
            'Should return AOB_ReferencedData__c SObject type');
    }
    
    @isTest
    static void testGetSObjectFieldList() {
        // Arrange
        SEL_ReferenceData selector = new SEL_ReferenceData();
        
        // Act
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        
        // Assert
        Assert.areEqual(6, fields.size(), 'Should return 6 fields');
        Assert.areEqual(true, fields.contains(AOB_ReferencedData__c.Id), 'Should contain Id field');
        Assert.areEqual(true, fields.contains(AOB_ReferencedData__c.Name), 'Should contain Name field');
        Assert.areEqual(true, fields.contains(AOB_ReferencedData__c.AOB_Code__c), 'Should contain AOB_Code__c field');
        Assert.areEqual(true, fields.contains(AOB_ReferencedData__c.AOB_SapField__c), 'Should contain AOB_SapField__c field');
        Assert.areEqual(true, fields.contains(AOB_ReferencedData__c.AOB_CountryCode__c), 'Should contain AOB_CountryCode__c field');
        Assert.areEqual(true, fields.contains(AOB_ReferencedData__c.AOB_ProductCategory__c), 'Should contain AOB_ProductCategory__c field');
    }
    
    @isTest
    static void testGetReferencedDataName() {
        // Arrange
        SEL_ReferenceData selector = new SEL_ReferenceData();
        String sapCode = 'TEST_FIELD';
        String fieldName = 'Name';
        
        // Act
        Test.startTest();
        List<AOB_ReferencedData__c> results = selector.getReferencedDataName(sapCode, fieldName);
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(0, results.size(), 'Should return reference data records');
        for(AOB_ReferencedData__c ref : results) {
            Assert.areEqual(sapCode, ref.AOB_SapField__c, 
                'Should return records matching the SAP field');
        }
    }
    
    @isTest
    static void testGetChildReferencedData() {
        // Arrange
        SEL_ReferenceData selector = new SEL_ReferenceData();
        String parentName = 'Test Parent';
        
        // Act
        Test.startTest();
        List<AOB_ReferencedData__c> results = selector.getChildReferencedData(parentName);
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(0, results.size(), 'Should return child reference data records');
        for(AOB_ReferencedData__c ref : results) {
            Assert.areEqual('Test Child', ref.Name, 
                'Should return child records with correct name');
        }
    }
    
    @isTest
    static void testNoDataFound() {
        // Arrange
        SEL_ReferenceData selector = new SEL_ReferenceData();
        String nonExistentSapCode = 'NONEXISTENT';
        String fieldName = 'Name';
        
        // Act
        Test.startTest();
        List<AOB_ReferencedData__c> results = selector.getReferencedDataName(nonExistentSapCode, fieldName);
        Test.stopTest();
        
        // Assert
        Assert.areEqual(0, results.size(), 'Should return empty list when no matching records found');
    }
}