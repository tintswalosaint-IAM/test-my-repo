/**
 * @description       : Test class for INS_CTRL_TokenValidator
 * @author            : Jaco de Lange
 * @group             : IAM : SFP - 48887 : Premium Collection Gateway - Customer Authorizes Payment
 * @last modified on  : 07-01-2025
 * 
 * @last modified on  : 05-11-2025
 * @modified by       : Jaco de Lange
 * @modification description : Add messages to all of the asserts
**/
@isTest
public class INS_CTRL_TokenValidator_Test {
    //Helper method to create a test CMN_Request__c record
    private static CMN_Request__c createRequest(String token, DateTime expirationDate, String status) {
        String requestRecordTypeId = Schema.SObjectType.CMN_Request__c.getRecordTypeInfosByName().get('Wallet Payment Request').getRecordTypeId();
        CMN_Request__c req = new CMN_Request__c(
            recordTypeId = requestRecordTypeId,
            Contract_Number__c = '1111',
            Secure_Access_Token__c = token,
            Secure_Access_Token_Expiration_Date__c = expirationDate,
            Status__c = status
        );
        insert req;
        return req;
    }
    @isTest
    static void test_getPaymentRequestByToken_valid() {
        String token = 'valid-token';
        createRequest(token, DateTime.now().addHours(3), 'Pending');
    
        Test.startTest();
            CMN_Request__c result = INS_CTRL_TokenValidator.getPaymentRequestByToken(token);
        Test.stopTest();

        assert.areNotEqual(null, result, 'We should have 1 request record');
        assert.areEqual(token, result.Secure_Access_Token__c, 'secure access tokens should match');
    }
    @isTest
    static void test_getPaymentRequestByToken_expired() {
        String token = 'expired-token';
        createRequest(token, DateTime.now().addHours(-2), 'Pending');

        Test.startTest();
                try {
                    INS_CTRL_TokenValidator.getPaymentRequestByToken(token);
                    assert.areEqual(false, 'Expected AuraHandledException', 'Expired token');
                } catch (AuraHandledException e) {
                    assert.isFalse(e.getMessage().contains('Access Denied'));
                }
        Test.stopTest();
    }
    @isTest
    static void test_getPaymentRequestByToken_invalid() {
        Test.startTest();
            try {
                INS_CTRL_TokenValidator.getPaymentRequestByToken('nonexistent-token');
               assert.areEqual(false, 'Expected AuraHandledException', 'token not found');
            } catch (AuraHandledException e) {
                assert.isFalse(e.getMessage().contains('Access Denied'));
            }
        Test.stopTest();
    }
    @isTest
    static void test_paymentRequestCallOut_success() {
        String token = 'success-token';
        CMN_Request__c req = createRequest(token, DateTime.now().addHours(1), 'Pending');

        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new Mock_InstalmentResponseSuccess());

        Test.startTest();
             String result = INS_CTRL_TokenValidator.paymentRequestCallOut(token);
        Test.stopTest();

        assert.areEqual('Success', result, 'callout successful');

        // Verify the status is updated
        CMN_Request__c updatedReq = [SELECT Status__c FROM CMN_Request__c WHERE Id = :req.Id];
        assert.areEqual('Pending Approval', updatedReq.Status__c, 'Status updated to Pending Approval');
    }
    @isTest
    static void test_paymentRequestCallOut_invalidToken() {
        Test.startTest();
        try {
            INS_CTRL_TokenValidator.paymentRequestCallOut('invalid-token');
           assert.areEqual(false, 'Expected AuraHandledException', 'Invalid token');
        } catch (AuraHandledException e) {
            assert.isFalse(e.getMessage().contains('Access Denied'));
        }
        Test.stopTest();
    }
    // Mock class for callout simulation
    private class Mock_InstalmentResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"instalmentResponse":[{"instalmentStatus":"Success"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}