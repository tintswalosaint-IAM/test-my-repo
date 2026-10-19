/***************************************************************************************
@Name of the Class :ICS_CTRL_InvokeSAP_Test
@Description : Class used to test ICS_CTRL_InvokeSAP
@Author :Ruchi Agarwal
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Ruchi Agarwal
* Last Modified Date OCT 22 2024
* Last Modified Description: Added assertions for test verification
****************************************************************************************/
@isTest
public class ICS_CTRL_InvokeSAP_Test {
    
    
    @TestSetup 
    static void setupData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(acc.id);
        
        ICS_DAL_TestFactory.createApplicationForm(acc.id, testOpportunity.id);
    }
    
    @isTest
    static void testSAPCreateCustomerCallSapService() {
        // Get test data
        List<Opportunity> lstOpportunity = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Assert.areEqual(true, !lstOpportunity.isEmpty(), 'Test opportunity should exist');
        
        // Setup mock
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        
        Test.startTest();
          CMN_WebserviceCallQueue__c sapCalls=(CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateAccount', lstOpportunity[0].id,lstOpportunity[0].AccountId,false);
        Test.stopTest();
        
     
        Assert.areEqual(true, sapCalls !=null, 'Expected a Webservice call queue record');
    }
    
    @isTest
    static void testSAPCreateCYTCallSapService() {
        // Get test data
        List<Opportunity> lstOpportunity = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Assert.areEqual(true, !lstOpportunity.isEmpty(), 'Test opportunity should exist');
        
        // Setup mock
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        
        Test.startTest();
         CMN_WebserviceCallQueue__c sapCalls=(CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateCYT', lstOpportunity[0].id,lstOpportunity[0].AccountId,false);
        Test.stopTest();
        
        // Verify web service call was logged
      
        Assert.areEqual(true, sapCalls !=null, 'Expected CYT call should be logged');
    }
    
    /**
     * @description mocks a successful response returned from the API call
     */
    public class CreateCustomerMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            String body = '{"Party":[{"PartyReference":{"PartyIdentification":[{"PartyIdentificationType":"identificationNumber","PartyIdentification":{"IdentifierValue":{"Value":"0090170526"}}},{"PartyIdentificationType":"Type","PartyIdentification":{"IdentifierValue":{"Value":"BusinessPartnerID"}}}]},"AdditionalData":{"CategoryInformation":{"Category":[{"CategoryItem":"header","CategoryDetails":[{"CategoryType":"correlationID","CategoryIdentifierValue":"8044329e-331f-daab-3c52-5a4ebe826f15"},{"CategoryType":"channelID","CategoryIdentifierValue":"SB678656760621A"},{"CategoryType":"UserID","CategoryIdentifierValue":"MCA_USR"}]},{"CategoryItem":"providerStatus","CategoryDetails":[{"CategoryType":"statusMessage","CategoryIdentifierValue":"Your request was successfully processed"},{"CategoryType":"statusCode","CategoryIdentifierValue":"S"},{"CategoryType":"VerificationStatus","CategoryIdentifierValue":"057"}]}]}}}]}';
            response.setStatusCode(CMN_API_Service.HTTP_OK);
            response.setBody(body);
            return response;
        }
    }
}