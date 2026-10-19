/**
* @description    :Test Class for INS_Create_Quote_Beneficiaries 
* @author         :Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Oct 2023
*/
@isTest
public class INS_Create_Quote_Beneficiaries_Test {
    
    /**
    * @description    : Test method for sending Beneficiary data 
    **/    
    @isTest
    static void testCreateQuoteBeneficiaries() {
        // Create a test InsurancePolicyParticipant record
        List<InsurancePolicyParticipant> memberList = new List<InsurancePolicyParticipant>();
        InsurancePolicyParticipant member = new InsurancePolicyParticipant();
        // Set member fields as needed for testing
        member.BirthDate__c = Date.newInstance(1980, 1, 1);
        member.RelationshipToInsured = 'SPOUSE';
        member.IdentityNumber__c = '12345';
        member.Allocation__c = 20;
        member.Initial__c = 'Mr';
        member.FirstName__c = 'Test';
        member.LastName__c = 'Last name';    
        String quoteNumber = '12345';
        String benefitId = '23456';     
        member.RelationshipToInsured = 'CHILD';
        member.Person_Id__c = '76790';
        member.Member_Id__c = '2233445';
        memberList.add(member);
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Post'));
        
        // Call the CreateQuoteBeneficiaries method
        Test.startTest();
        
        memberList = INS_Create_Quote_Beneficiaries.createQuoteBeneficiariesBulk(memberList, quoteNumber,benefitId, 'KENYA');
        memberList[0].Funeral_Benefit_Id__c = '123654';
        memberList = INS_Create_Quote_Beneficiaries.createQuoteBeneficiariesBulk(memberList, quoteNumber,benefitId, 'UGANDA');
        Test.stopTest();
        
        Assert.areEqual('40596', memberList[0].Beneficiary_Id__c, 'Beneficiary_Id__c should be 40596');

    }
    
    
    
    /**
    * @description    : Test method for sending Beneficiary data 
    **/    
    @isTest
    static void testUpdateQuoteBeneficiaries() {
        // Create a test InsurancePolicyParticipant record
        List<InsurancePolicyParticipant> memberList = new List<InsurancePolicyParticipant>();
        InsurancePolicyParticipant member = new InsurancePolicyParticipant();
        // Set member fields as needed for testing
        member.BirthDate__c = Date.newInstance(1980, 1, 1);
        member.RelationshipToInsured = 'SPOUSE';
        member.IdentityNumber__c = '12345';
        member.Allocation__c = 20;
        member.Initial__c = 'Mr';
        member.FirstName__c = 'Test';
        member.LastName__c = 'Last name';    
        String quoteNumber = '12345';
        String benefitId = '23456';     
        member.RelationshipToInsured = 'CHILD';
        member.Person_Id__c = '76790';
        member.Member_Id__c = '2233445';
        memberList.add(member);
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('Put'));
        
        // Call the CreateQuoteBeneficiaries method
        Test.startTest();
        
        memberList = INS_Create_Quote_Beneficiaries.createQuoteBeneficiariesBulk(memberList, quoteNumber,benefitId, 'KENYA');
        memberList[0].Funeral_Benefit_Id__c = '123654';
        memberList = INS_Create_Quote_Beneficiaries.createQuoteBeneficiariesBulk(memberList, quoteNumber,benefitId, 'UGANDA');
        Test.stopTest();
        
        Assert.areEqual('40596', memberList[0].Beneficiary_Id__c, 'Beneficiary_Id__c should be 40596');
    }
    
    
    /**
    * @description    : Test method for deleting Beneficiary data 
    **/     
    @isTest
    static void testDeleteQuoteMembers() {
        // Set member ID and quote number for testing
        List<String> beneficiaryIds = new List<String>();
        String beneficiaryId = 'memberId123';
        beneficiaryIds.add(beneficiaryId);
        String quoteNumber = '12345';
        
        // Set mock callout response
        MockHttpResponseGenerator mockResponse = new MockHttpResponseGenerator('Post');
        Test.setMock(HttpCalloutMock.class, mockResponse);
        
        // Call the deleteQuoteMembers method
        Test.startTest();
        INS_Create_Quote_Beneficiaries.deleteQuoteBeneficiaries(beneficiaryIds, quoteNumber);
        Test.stopTest();
        Assert.areEqual(200, mockResponse.statusCode, 'The HTTP status code should be 200 after deleteQuoteBeneficiaries method call');
        
        
    }
    
    
    
    /**
    * @description    : Mock Test Class for INS_Create_Quote_Beneficiaries, generating fake responses
    * @author         :Raja Arsalan (raja.arsalan@standardbank.co.za)
    
    **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        /**
        * @description    : Property to get the statusCode
        **/
        public Integer statusCode { get; private set; }
        /**
        * @description    : Property to get the request Type
        **/
        public string reqType { get; private set; }
        /**
        * @description    : constructor of the mock class
        * @param reqType
        **/
        public MockHttpResponseGenerator(string reqType){
            this.reqType = reqType;
        }
        
        
        /**
        * @description    : fake response
        * @param request
        * @return response
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(reqType == 'Post')
            {
		        response.setBody('{"beneficiaries": [{"beneficiaryId": "40596","beneficiaryKey": null,"allocationAmount": 0,"allocationType": "PERCENTAGE","personId": "76790","benefitId": "1346","initials": "","title": "","firstName": "KG","surname": "KG","gender": "FEMALE","identityType": "SAIDENTITYDOCUMENT","identityNumber": "55566699933302","dateOfBirth": "1962-10-10T01:00:00Z","relationship": "DAUGHTER","contacts": []}],"validationResult": {"isValid": true,"validationMessages": [],"fullValidationMessage": "Valid"}}');
            } else {
                response.setBody('{"referenceNumber": null,"beneficiaries": [{"beneficiaryId": "40596","beneficiaryKey": null,"allocationAmount": 0,"allocationType": "PERCENTAGE","personId": "76790","benefitId": "1346","initials": "","title": "","firstName": "KG","surname": "KG","gender": "FEMALE","identityType": "SAIDENTITYDOCUMENT","identityNumber": "55566699933302","dateOfBirth": "1962-10-10T01:00:00Z","relationship": "DAUGHTER","contacts": []}],"validationResult": {"isValid": true,"validationMessages": [],"fullValidationMessage": "Valid"}}');
            }
            statusCode = 200;
            response.setStatusCode(statusCode);
            return response;
        }
    }
}