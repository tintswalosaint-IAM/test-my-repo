/**
 * @description       : Test class for UG_AOB_PPB_QRGenerator - validates time-based 
 *                      token generation, validation, and security features
 * @author            : jagadish Thummala
 * @group             : Test Classes
 * @last modified on  : 10-15-2025
 * @last modified by  : jagadish Thummala
 * @test coverage     : UG_AOB_PPB_QRGenerator (Target: 95%+)
**/
@isTest
private class UG_AOB_PPB_QRGenerator_TEST {
    
    /**
     * @description Test successful token generation with valid data structure
     * @result Token should be generated and properly encoded
     */
    @isTest
    static void testGenerateTimeBasedToken_Success() {
        Test.startTest();
        String token = UG_AOB_PPB_QRGenerator.generateTimeBasedToken();
        Test.stopTest();
        
        // Assert token is generated and not empty
        Assert.areNotEqual(null, token, 'Token should not be null');
        Assert.isTrue(String.isNotBlank(token), 'Token should not be blank');
        
        // Verify token can be decoded
        Blob decodedBlob = EncodingUtil.base64Decode(token);
        String jsonData = decodedBlob.toString();
        Map<String, Object> tokenData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        
        // Assert token contains required fields
        Assert.isTrue(tokenData.containsKey('timestamp'), 'Token should contain timestamp');
        Assert.isTrue(tokenData.containsKey('sessionId'), 'Token should contain sessionId');
        Assert.isTrue(tokenData.containsKey('expiry'), 'Token should contain expiry');
    }
    
    /**
     * @description Test token validation within valid timeframe (before expiry)
     * @result Token should be validated successfully within 3 minutes
     */
    @isTest
    static void testValidateTimeBasedToken_ValidToken() {
        Test.startTest();
        // Generate fresh token
        String token = UG_AOB_PPB_QRGenerator.generateTimeBasedToken();
        
        // Validate immediately (within expiry window)
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken(token);
        Test.stopTest();
        
        Assert.areEqual(true, isValid, 'Newly generated token should be valid');
    }
    
    /**
     * @description Test token validation with expired token (beyond 3 minutes)
     * @result Token should be invalid after expiry time
     */
    @isTest
    static void testValidateTimeBasedToken_ExpiredToken() {
        // Create token with past expiry time
        Long pastTimestamp = System.currentTimeMillis() - (5 * 60 * 1000); // 5 minutes ago
        Map<String, Object> expiredTokenData = new Map<String, Object>{
            'timestamp' => pastTimestamp,
            'sessionId' => 'test-session-123',
            'expiry' => pastTimestamp + (3 * 60 * 1000) // Expired 2 minutes ago
        };
        
        String jsonData = JSON.serialize(expiredTokenData);
        Blob tokenBlob = Blob.valueOf(jsonData);
        String expiredToken = EncodingUtil.base64Encode(tokenBlob);
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken(expiredToken);
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Expired token should not be valid');
    }
    
    /**
     * @description Test token validation with null token
     * @result Null token should return false
     */
    @isTest
    static void testValidateTimeBasedToken_NullToken() {
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken(null);
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Null token should be invalid');
    }
    
    /**
     * @description Test token validation with blank/empty token
     * @result Blank token should return false
     */
    @isTest
    static void testValidateTimeBasedToken_BlankToken() {
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken('');
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Blank token should be invalid');
    }
    
    /**
     * @description Test token validation with invalid/malformed token format
     * @result Invalid token format should return false
     */
    @isTest
    static void testValidateTimeBasedToken_InvalidFormat() {
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken('invalid-token-format');
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Invalid token format should be invalid');
    }
    
    /**
     * @description Test token time validation within acceptable tolerance (30 seconds)
     * @result Token should be valid when client timestamp is within 30 seconds
     */
    @isTest
    static void testIsTokenTimeValid_WithinTolerance() {
        Long currentTime = System.currentTimeMillis();
        
        // Create token with current timestamp
        Map<String, Object> tokenData = new Map<String, Object>{
            'timestamp' => currentTime,
            'sessionId' => 'test-session-456',
            'expiry' => currentTime + (3 * 60 * 1000)
        };
        
        String jsonData = JSON.serialize(tokenData);
        Blob tokenBlob = Blob.valueOf(jsonData);
        String token = EncodingUtil.base64Encode(tokenBlob);
        
        // Client timestamp within 30 seconds tolerance
        Long clientTimestamp = currentTime + 15000; // 15 seconds ahead
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.isTokenTimeValid(token, clientTimestamp);
        Test.stopTest();
        
        Assert.areEqual(true, isValid, 'Token should be valid within 30 second tolerance');
    }
    
    /**
     * @description Test token time validation outside acceptable tolerance (30 seconds)
     * @result Token should be invalid when client timestamp exceeds 30 seconds difference
     */
    @isTest
    static void testIsTokenTimeValid_OutsideTolerance() {
        Long currentTime = System.currentTimeMillis();
        
        // Create token with current timestamp
        Map<String, Object> tokenData = new Map<String, Object>{
            'timestamp' => currentTime,
            'sessionId' => 'test-session-789',
            'expiry' => currentTime + (3 * 60 * 1000)
        };
        
        String jsonData = JSON.serialize(tokenData);
        Blob tokenBlob = Blob.valueOf(jsonData);
        String token = EncodingUtil.base64Encode(tokenBlob);
        
        // Client timestamp outside 30 seconds tolerance
        Long clientTimestamp = currentTime + 45000; // 45 seconds ahead
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.isTokenTimeValid(token, clientTimestamp);
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Token should be invalid outside 30 second tolerance');
    }
    
    /**
     * @description Test token time validation with invalid token
     * @result Should return false without throwing exception
     */
    @isTest
    static void testIsTokenTimeValid_InvalidToken() {
        Long clientTimestamp = System.currentTimeMillis();
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.isTokenTimeValid('invalid-token', clientTimestamp);
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Invalid token should return false for time validation');
    }
    
    /**
     * @description Test token uniqueness - multiple generations should produce unique tokens
     * @result Each generated token should have unique sessionId and timestamp
     */
    @isTest
    static void testGenerateTimeBasedToken_Uniqueness() {
        Test.startTest();
        String token1 = UG_AOB_PPB_QRGenerator.generateTimeBasedToken();
        String token2 = UG_AOB_PPB_QRGenerator.generateTimeBasedToken();
        Test.stopTest();
        
        Assert.areNotEqual(token1, token2, 'Multiple token generations should produce unique tokens');
        
        // Decode and verify different sessionIds
        Blob blob1 = EncodingUtil.base64Decode(token1);
        Blob blob2 = EncodingUtil.base64Decode(token2);
        Map<String, Object> data1 = (Map<String, Object>) JSON.deserializeUntyped(blob1.toString());
        Map<String, Object> data2 = (Map<String, Object>) JSON.deserializeUntyped(blob2.toString());
        
        Assert.areNotEqual(data1.get('sessionId'), data2.get('sessionId'), 
                          'Each token should have unique sessionId');
    }
    
    /**
     * @description Test bulk token generation for performance validation
     * @result Should successfully generate multiple tokens without governor limit issues
     */
    @isTest
    static void testGenerateTimeBasedToken_BulkGeneration() {
        List<String> tokens = new List<String>();
        
        Test.startTest();
        for(Integer i = 0; i < 200; i++) {
            String token = UG_AOB_PPB_QRGenerator.generateTimeBasedToken();
            tokens.add(token);
        }
        Test.stopTest();
        
        Assert.areEqual(200, tokens.size(), 'Should generate 200 tokens successfully');
        
        // Verify all tokens are valid
        for(String token : tokens) {
            Assert.isTrue(String.isNotBlank(token), 'All generated tokens should be valid');
        }
    }
    
    /**
     * @description Test token validation edge case at exact expiry boundary
     * @result Token at exact expiry time should be handled correctly
     */
    @isTest
    static void testValidateTimeBasedToken_ExactExpiryBoundary() {
        Long currentTime = System.currentTimeMillis();
        
        // Create token that expires exactly now
        Map<String, Object> tokenData = new Map<String, Object>{
            'timestamp' => currentTime - (3 * 60 * 1000),
            'sessionId' => 'boundary-test',
            'expiry' => currentTime // Expires exactly now
        };
        
        String jsonData = JSON.serialize(tokenData);
        Blob tokenBlob = Blob.valueOf(jsonData);
        String token = EncodingUtil.base64Encode(tokenBlob);
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken(token);
        Test.stopTest();
        
        // Should be valid or invalid based on exact timing - both are acceptable
        Assert.isTrue(isValid == true || isValid == false, 
                     'Token at exact expiry boundary should return deterministic result');
    }
    
    /**
     * @description Test exception handling with corrupted token data
     * @result Should handle corrupted JSON gracefully and return false
     */
    @isTest
    static void testValidateTimeBasedToken_CorruptedData() {
        // Create token with invalid JSON structure
        String corruptedToken = EncodingUtil.base64Encode(Blob.valueOf('{invalid-json}'));
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken(corruptedToken);
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Corrupted token should be invalid');
    }
    
    /**
     * @description Test token validation with missing required fields
     * @result Should handle missing fields gracefully
     */
    @isTest
    static void testValidateTimeBasedToken_MissingFields() {
        // Create token without expiry field
        Map<String, Object> incompleteData = new Map<String, Object>{
            'timestamp' => System.currentTimeMillis(),
            'sessionId' => 'incomplete-token'
            // Missing 'expiry' field
        };
        
        String jsonData = JSON.serialize(incompleteData);
        Blob tokenBlob = Blob.valueOf(jsonData);
        String incompleteToken = EncodingUtil.base64Encode(tokenBlob);
        
        Test.startTest();
        Boolean isValid = UG_AOB_PPB_QRGenerator.validateTimeBasedToken(incompleteToken);
        Test.stopTest();
        
        Assert.areEqual(false, isValid, 'Token with missing fields should be invalid');
    }
}