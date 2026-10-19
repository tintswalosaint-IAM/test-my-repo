/**
 * @description SFP-32986 Class used as test class for ICS_DTO_SendCRADetails
 * @author Ikyatha Naidu
 * @date 22/04/2024
 ***************************************************** 
 * @last modified on  : 31/08/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: Initital Version
 */
@IsTest
private class ICS_DTO_SendCRADetails_Test {
    
    @IsTest
    static void testDTOStructure() {
        // Create test data
        ICS_DTO_SendCRADetails.input testInput = new ICS_DTO_SendCRADetails.input();
        testInput.identifier = 'TEST123';
        testInput.firstName = 'John';
        testInput.middleName = 'Doe';
        testInput.lastName = 'Smith';
        testInput.idDocumentType = 'Passport';
        testInput.idDocumentCode = 'ABC123';
        testInput.birthdate = Date.newInstance(1990, 1, 1);
        
        ICS_DTO_SendCRADetails.requestMap testMap1 = new ICS_DTO_SendCRADetails.requestMap();
        testMap1.key = 'TestKey1';
        testMap1.value = 'TestValue1';
        
        ICS_DTO_SendCRADetails.requestMap testMap2 = new ICS_DTO_SendCRADetails.requestMap();
        testMap2.key = 'TestKey2';
        testMap2.value = 'TestValue2';
        
        testInput.data = new List<ICS_DTO_SendCRADetails.requestMap>{testMap1, testMap2};
        
        ICS_DTO_SendCRADetails testDTO = new ICS_DTO_SendCRADetails();
        testDTO.input = testInput;
        
        // Perform assertions
        Assert.isNotNull(testDTO.input, 'OrEqual: Input should not be null');
        Assert.areEqual('TEST123', testDTO.input.identifier, 'OrEqual: Identifier should match');
        Assert.areEqual('John', testDTO.input.firstName, 'OrEqual: First name should match');
        Assert.areEqual('Doe', testDTO.input.middleName, 'OrEqual: Middle name should match');
        Assert.areEqual('Smith', testDTO.input.lastName, 'OrEqual: Last name should match');
        Assert.areEqual('Passport', testDTO.input.idDocumentType, 'OrEqual: ID document type should match');
        Assert.areEqual('ABC123', testDTO.input.idDocumentCode, 'OrEqual: ID document code should match');
        Assert.areEqual(Date.newInstance(1990, 1, 1), testDTO.input.birthdate, 'OrEqual: Birthdate should match');
        
        Assert.isNotNull(testDTO.input.data, 'OrEqual: Data list should not be null');
        Assert.areEqual(2, testDTO.input.data.size(), 'OrEqual: Data list should contain 2 items');
        Assert.areEqual('TestKey1', testDTO.input.data[0].key, 'OrEqual: First data item key should match');
        Assert.areEqual('TestValue1', testDTO.input.data[0].value, 'OrEqual: First data item value should match');
        Assert.areEqual('TestKey2', testDTO.input.data[1].key, 'OrEqual: Second data item key should match');
        Assert.areEqual('TestValue2', testDTO.input.data[1].value, 'OrEqual: Second data item value should match');
    }
    
    @IsTest
    static void testEmptyDTO() {
        ICS_DTO_SendCRADetails emptyDTO = new ICS_DTO_SendCRADetails();
        
        Assert.isNull(emptyDTO.input, 'OrEqual: Input should be null for empty DTO');
    }
    
    @IsTest
    static void testInputWithNullValues() {
        ICS_DTO_SendCRADetails.input testInput = new ICS_DTO_SendCRADetails.input();
        
        Assert.isNull(testInput.identifier, 'OrEqual: Identifier should be null');
        Assert.isNull(testInput.firstName, 'OrEqual: First name should be null');
        Assert.isNull(testInput.middleName, 'OrEqual: Middle name should be null');
        Assert.isNull(testInput.lastName, 'OrEqual: Last name should be null');
        Assert.isNull(testInput.idDocumentType, 'OrEqual: ID document type should be null');
        Assert.isNull(testInput.idDocumentCode, 'OrEqual: ID document code should be null');
        Assert.isNull(testInput.birthdate, 'OrEqual: Birthdate should be null');
        Assert.isNull(testInput.data, 'OrEqual: Data list should be null');
    }
    
    @IsTest
    static void testRequestMapWithNullValues() {
        ICS_DTO_SendCRADetails.requestMap testMap = new ICS_DTO_SendCRADetails.requestMap();
        
        Assert.isNull(testMap.key, 'OrEqual: Key should be null');
        Assert.isNull(testMap.value, 'OrEqual: Value should be null');
    }
}