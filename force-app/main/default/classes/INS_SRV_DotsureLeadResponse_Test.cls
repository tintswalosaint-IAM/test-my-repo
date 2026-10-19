/**
 * @description Test class for INS_SRV_DotsureLeadResponse
 *              Covers all branches: success, client error, server error, 
 *              edge cases, and exception paths
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-22
 **/
@isTest
private class INS_SRV_DotsureLeadResponse_Test {
    
    // ==========================================
    // EMPTY / BLANK RESPONSE
    // ==========================================
    
    @isTest
    static void testEmptyResponseBody() {
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, '');
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Status should be UNKNOWN for empty body');
        Assert.isNotNull(result.failureMessage, 'Failure message should be set');
    }
    
    @isTest
    static void testNullResponseBody() {
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, null);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Status should be UNKNOWN for null body');
    }
    
    // ==========================================
    // SUCCESS PATH
    // ==========================================
    
    @isTest
    static void testSuccessResponse() {
        String successBody = '{' +
            '"status_code": 200,' +
            '"LeadGenerationResponse": {' +
                '"message": "{\\"leadIds\\":[12345],\\"statusCode\\":201,\\"message\\":\\"Created\\"}"' +
            '}}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, successBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.SUCCESS, 
            result.status, 'Status should be SUCCESS');
        Assert.areEqual('12345', result.leadReferenceNumber, 
            'Lead reference should be 12345');
    }
    
    // ==========================================
    // CLIENT ERROR (400/401)
    // ==========================================
    
    @isTest
    static void testClientError400() {
        String clientErrorBody = '{' +
            '"status_code": 400,' +
            '"status": "Duplicate lead",' +
            '"message": "Lead already exists in Dotsure"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, clientErrorBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.CLIENT_ERROR, 
            result.status, 'Status should be CLIENT_ERROR');
        Assert.areEqual('Lead already exists in Dotsure', result.failureMessage, 
            'Failure message should match');
    }
    
    @isTest
    static void testClientError401() {
        String clientErrorBody = '{' +
            '"status_code": 401,' +
            '"message": "Unauthorized access"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, clientErrorBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.CLIENT_ERROR, 
            result.status, 'Status should be CLIENT_ERROR for 401');
    }
    
    // ==========================================
    // SERVER ERROR (5xx)
    // ==========================================
    
    @isTest
    static void testServerError502() {
        String serverErrorBody = '{' +
            '"status_code": 502,' +
            '"message": "Bad Gateway"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(502, serverErrorBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.SERVER_ERROR, 
            result.status, 'Status should be SERVER_ERROR');
        Assert.isTrue(result.failureMessage.contains('502'), 
            'Failure message should contain HTTP status code');
    }
    
    @isTest
    static void testServerError500() {
        String serverErrorBody = '{"message": "Internal Server Error"}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(500, serverErrorBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.SERVER_ERROR, 
            result.status, 'Status should be SERVER_ERROR for 500');
    }
    
    // ==========================================
    // INVALID JSON (catch block)
    // ==========================================
    
    @isTest
    static void testInvalidJson() {
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, 'not-valid-json{{{');
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Status should be UNKNOWN for invalid JSON');
        Assert.isTrue(result.failureMessage.contains('Unable to process'), 
            'Failure message should mention processing error');
    }
    
    // ==========================================
    // MISSING LeadGenerationResponse
    // ==========================================
    
    @isTest
    static void testMissingLeadGenerationResponse() {
        String body = '{"status_code": 200, "message": "Some message"}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Status should be UNKNOWN');
    }
    
    @isTest
    static void testLeadGenerationResponseNull() {
        String body = '{"status_code": 200, "LeadGenerationResponse": null}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Status should be UNKNOWN for null LeadGenerationResponse');
    }
    
    @isTest
    static void testBlankInnerJson() {
        String body = '{' +
            '"status_code": 200,' +
            '"LeadGenerationResponse": {"message": ""}' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Status should be UNKNOWN for blank inner JSON');
    }
    
    // ==========================================
    // INNER RESPONSE BUSINESS ERROR
    // ==========================================
    
    @isTest
    static void testInnerBusinessError400() {
        String body = '{' +
            '"status_code": 200,' +
            '"LeadGenerationResponse": {' +
                '"message": "{\\"statusCode\\":400,\\"message\\":\\"Duplicate lead\\"}"' +
            '}}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.CLIENT_ERROR, 
            result.status, 'Inner 400 should be CLIENT_ERROR');
    }
    
    @isTest
    static void testInnerBusinessErrorUnknown() {
        String body = '{' +
            '"status_code": 200,' +
            '"LeadGenerationResponse": {' +
                '"message": "{\\"statusCode\\":999,\\"message\\":\\"Unknown error\\"}"' +
            '}}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, 
            result.status, 'Inner 999 should be UNKNOWN');
    }
    
    // ==========================================
    // extractMessage BRANCHES
    // ==========================================
    
    @isTest
    static void testExtractMessageNull() {
        // No 'message' field in response
        String body = '{"status_code": 400}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.isNotNull(result.failureMessage, 
            'Failure message should be default when message is null');
    }
    
    @isTest
    static void testExtractMessageBlank() {
        // Blank message field
        String body = '{"status_code": 400, "message": ""}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.isNotNull(result.failureMessage, 
            'Failure message should be default when blank');
    }
    
    @isTest
    static void testExtractMessageWithInnerJson() {
        // Message contains nested JSON with 'message' field
        String body = '{' +
            '"status_code": 400,' +
            '"message": "{\\"message\\":\\"Extracted inner message\\"}"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual('Extracted inner message', result.failureMessage, 
            'Should extract inner message from JSON');
    }
    
    @isTest
    static void testExtractMessagePlainText() {
        // Message is plain text (not JSON)
        String body = '{' +
            '"status_code": 400,' +
            '"message": "Plain text error message"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.areEqual('Plain text error message', result.failureMessage, 
            'Should return plain text as-is');
    }
    
    // ==========================================
    // status_code NULL CASE
    // ==========================================
    
    @isTest
    static void testStatusCodeNull() {
        String body = '{"status_code": null, "message": "Test"}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
    }
    
    @isTest
    static void testNoStatusCodeField() {
        String body = '{"message": "No status code field"}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, body);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
    }
    
    // ==========================================
    // ResponseResult.isSuccess() METHOD
    // ==========================================
    
    @isTest
    static void testIsSuccessMethod() {
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            new INS_SRV_DotsureLeadResponse.ResponseResult();
        
        result.status = INS_SRV_DotsureLeadResponse.ResponseStatus.SUCCESS;
        Test.startTest();
        Assert.isTrue(result.isSuccess(), 'isSuccess should return true');
        
        result.status = INS_SRV_DotsureLeadResponse.ResponseStatus.CLIENT_ERROR;
        Assert.isFalse(result.isSuccess(), 'isSuccess should return false');
        Test.stopTest();
    }
}