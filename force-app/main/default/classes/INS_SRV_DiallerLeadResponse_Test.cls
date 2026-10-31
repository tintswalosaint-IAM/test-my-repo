@isTest
private class INS_SRV_DiallerLeadResponse_Test {
    
    // ============================================================
    // NESTED ERROR PARSING TESTS (Cover parseNestedError + extractNestedErrorMsg)
    // ============================================================
    
    @isTest
    static void testParseNestedErrorWithErrorMessage() {
        INS_DTO_DiallerLeadsResponse dto = new INS_DTO_DiallerLeadsResponse();
        dto.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto.error.errorDescription = '{"error":{"errorDescription":"{\\"error\\":{\\"errorMessage\\":\\"Nested error message here\\"}}"}}';
        
        Test.startTest();
        String result = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('Nested error message here', result, 
            'Should extract errorMessage from nested errorDescription');
    }
    
    @isTest
    static void testParseNestedErrorWithInvalidJson() {
        INS_DTO_DiallerLeadsResponse dto = new INS_DTO_DiallerLeadsResponse();
        dto.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto.error.errorDescription = '{"error":{"errorDescription":"not-valid-json{{"}}';
        
        Test.startTest();
        String result = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('not-valid-json{{', result, 
            'Should return raw text when nested JSON is invalid');
    }
    
    @isTest
    static void testParseNestedErrorWithoutErrorKey() {
        INS_DTO_DiallerLeadsResponse dto = new INS_DTO_DiallerLeadsResponse();
        dto.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto.error.errorDescription = '{"error":{"errorDescription":"{\\"message\\":\\"Some message\\"}"}}';
        
        Test.startTest();
        String result = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('Default error', result, 
            'Should return default when no error key in nested JSON');
    }
    
    @isTest
    static void testParseNestedErrorWithErrorAsString() {
        INS_DTO_DiallerLeadsResponse dto = new INS_DTO_DiallerLeadsResponse();
        dto.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto.error.errorDescription = '{"error":{"errorDescription":"{\\"error\\":\\"some string error\\"}"}}';
        
        Test.startTest();
        String result = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('Default error', result, 
            'Should return default when error is not a Map');
    }
    
    @isTest
    static void testParseNestedErrorWithoutErrorMessage() {
        INS_DTO_DiallerLeadsResponse dto = new INS_DTO_DiallerLeadsResponse();
        dto.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto.error.errorDescription = '{"error":{"errorDescription":"{\\"error\\":{\\"detail\\":\\"Some detail\\"}}"}}';
        
        Test.startTest();
        String result = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('Default error', result, 
            'Should return default when errorMessage not found in nested error');
    }
    
    // ============================================================
    // EXISTING TESTS
    // ============================================================
    
    @isTest
    static void testExtractErrorMessageWithDTO() {
        INS_DTO_DiallerLeadsResponse dto1 = new INS_DTO_DiallerLeadsResponse();
        dto1.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto1.error.errorDescription = '{"error":[{"detail":"Provided credentials are invalid","title":"Unauthorized"}]}';
        
        Test.startTest();
        String result1 = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto1, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('Provided credentials are invalid', result1, 
            'Should extract detail from nested errorDescription');
    }
    
    @isTest
    static void testExtractFromErrorsArrayWithTitleFallback() {
        INS_DTO_DiallerLeadsResponse dto = new INS_DTO_DiallerLeadsResponse();
        dto.error = new INS_DTO_DiallerLeadsResponse.ConnexError();
        dto.error.errorDescription = '{"error":[{"title":"Only title here"}]}';
        
        Test.startTest();
        String result = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto, 'Default error');
        Test.stopTest();
        
        Assert.areEqual('Only title here', result, 
            'Should fallback to title when detail is missing');
    }
}