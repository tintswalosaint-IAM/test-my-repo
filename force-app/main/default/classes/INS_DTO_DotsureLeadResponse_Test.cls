@isTest
private class INS_DTO_DotsureLeadResponse_Test {
    
    @isTest
    static void testParseInnerResponseValid() {
        String jsonStr = '{"leadIds":[12345],"statusCode":201,"message":"Created"}';
        
        Test.startTest();
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            INS_DTO_DotsureLeadResponse.parseInnerResponse(jsonStr);
        Test.stopTest();
        
        Assert.isNotNull(innerRes, 'Inner should not be null');
        Assert.areEqual(201, innerRes.statusCode, 'statusCode should be 201');
    }
    
    @isTest
    static void testParseInnerResponseBlank() {
        Test.startTest();
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            INS_DTO_DotsureLeadResponse.parseInnerResponse('');
        Test.stopTest();
        
        Assert.isNull(innerRes, 'Inner should be null for blank input');
    }
    
    @isTest
    static void testParseInnerResponseInvalid() {
        Test.startTest();
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            INS_DTO_DotsureLeadResponse.parseInnerResponse('not-valid-json{{{');
        Test.stopTest();
        
        Assert.isNull(innerRes, 'Inner should be null for invalid JSON');
    }
    
    @isTest
    static void testIsInnerSuccessTrue() {
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            new INS_DTO_DotsureLeadResponse.InnerResponse();
        innerRes.statusCode = 201;
        innerRes.leadIds = new List<Integer>{12345};
        
        Test.startTest();
        Boolean result = INS_DTO_DotsureLeadResponse.isInnerSuccess(innerRes);
        Test.stopTest();
        
        Assert.isTrue(result, 'Should return true for successful inner');
    }
    
    @isTest
    static void testIsInnerSuccessFalse() {
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            new INS_DTO_DotsureLeadResponse.InnerResponse();
        innerRes.statusCode = 400;
        innerRes.leadIds = new List<Integer>();
        
        Test.startTest();
        Boolean result = INS_DTO_DotsureLeadResponse.isInnerSuccess(innerRes);
        Test.stopTest();
        
        Assert.isFalse(result, 'Should return false for failed inner');
    }
    
    @isTest
    static void testIsInnerSuccessNull() {
        Test.startTest();
        Boolean result = INS_DTO_DotsureLeadResponse.isInnerSuccess(null);
        Test.stopTest();
        
        Assert.isFalse(result, 'Should return false for null');
    }
    
    @isTest
    static void testExtractLeadIdValid() {
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            new INS_DTO_DotsureLeadResponse.InnerResponse();
        innerRes.leadIds = new List<Integer>{12345, 67890};
        
        Test.startTest();
        String leadId = INS_DTO_DotsureLeadResponse.extractLeadId(innerRes);
        Test.stopTest();
        
        Assert.areEqual('12345', leadId, 'Should extract first lead ID');
    }
    
    @isTest
    static void testExtractLeadIdEmpty() {
        INS_DTO_DotsureLeadResponse.InnerResponse innerRes = 
            new INS_DTO_DotsureLeadResponse.InnerResponse();
        innerRes.leadIds = new List<Integer>();
        
        Test.startTest();
        String leadId = INS_DTO_DotsureLeadResponse.extractLeadId(innerRes);
        Test.stopTest();
        
        Assert.isNull(leadId, 'Should return null for empty leadIds');
    }
    
    @isTest
    static void testExtractLeadIdNull() {
        Test.startTest();
        String leadId = INS_DTO_DotsureLeadResponse.extractLeadId(null);
        Test.stopTest();
        
        Assert.isNull(leadId, 'Should return null for null input');
    }
}