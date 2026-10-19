/**
 * @description       : SFP-55759 - Test class for SBFC_API_MoonbaseDocument.
 *                      Verifies request body generation, successful and failed
 *                      Moonstone API callouts, exception handling, queue item
 *                      population and utility methods.
 * @author            : Gigyasu Jain
 * @group             : SBFC 
 * @last modified on  : 08-07-2026
 * @last modified by  : Gigyasu Jain
**/



@IsTest
public class SBFC_API_MoonbaseDocumentTest {
   
   /**
    * @description Sets up common test data for the Moonstone API test methods.
    */
   @testSetup
   static void setupData() {

        Account acc = new Account(
            LastName = 'Test Person',
            PersonEmail = 'test@test.com',
            CMN_IdentityNumber__pc = '7008200173082'
        );
        insert acc;

        Lead lead = new Lead(
            LastName = 'Lead',
            Company = 'Test Company',
            FinServ__RelatedAccount__c = acc.Id
        );
        insert lead;
    }

    
    /**
     * @description Verifies request context initialization and request body generation.
     */
    @IsTest
    static void testInitialiseAndGetRequestBody() {

        Lead lead = [
            SELECT Id,
                   FinServ__RelatedAccount__c
            FROM Lead
            LIMIT 1
        ];

        Account account = [
            SELECT Id,
                   Name,
                   PersonEmail,
                   CMN_IdentityNumber__pc,
                   OwnerId
            FROM Account
            LIMIT 1
        ];

        User usr = [
            SELECT Id,
                   RM_AE_Code__c
            FROM User
            WHERE Id = :account.OwnerId
            LIMIT 1
        ];

        SBFC_API_MoonbaseDocument api =
            new SBFC_API_MoonbaseDocument();

        Test.startTest();

        api.initialise(
            lead,
            account,
            usr,
            1,
            0,
            'Life Insurance'
        );

        String requestBody =
            SBFC_API_MoonbaseDocument.getRequestBody();

        Test.stopTest();

        Assert.isNotNull(requestBody);
        Assert.isTrue(requestBody.contains('3825_main'));
        Assert.isTrue(requestBody.contains('disclosure'));
        Assert.isTrue(requestBody.contains(account.Name));
        Assert.isTrue(requestBody.contains(account.CMN_IdentityNumber__pc));
        Assert.isTrue(requestBody.contains('Life Insurance'));
    }

    /**
     * @description Verifies the response abbreviation utility method.
     */
    @IsTest
    static void testAbbreviate() {

        String input = '';

        for (Integer i = 0; i < 1000; i++) {
            input += 'A';
        }

        String output =
            SBFC_API_MoonbaseDocument.abbreviate(input, 100);

        Assert.isTrue(output.length() <= 100);

        Assert.areEqual(
            'Test',
            SBFC_API_MoonbaseDocument.abbreviate('Test', 100)
        );
        
        Assert.isNull(
            SBFC_API_MoonbaseDocument.abbreviate(null, 100)
        );
    }
    
    /**
     * @description Verifies successful Moonstone API callout processing.
     */
    @IsTest
    static void testProcessSuccess() {

    Lead lead = [
        SELECT Id,
               FinServ__RelatedAccount__c
        FROM Lead
        LIMIT 1
    ];

    Account account = [
        SELECT Id,
               Name,
               PersonEmail,
               CMN_IdentityNumber__pc,
               OwnerId
        FROM Account
        LIMIT 1
    ];

    User usr = [
        SELECT Id,
               RM_AE_Code__c
        FROM User
        WHERE Id = :account.OwnerId
        LIMIT 1
    ];

    String responseBody =
        '{"status":"success","msg":"Success","data":{"base64pdf":"dGVzdA=="}}';

    sbgplatform.ApiService.setMock(
        HttpCalloutMock.class,
        new MockResponse(200, responseBody)
    );

    SBFC_API_MoonbaseDocument api =
        new SBFC_API_MoonbaseDocument();

    api.initialise(
        lead,
        account,
        usr,
        1,
        0,
        'Life Insurance'
    );

    CMN_WebserviceCallQueue__c queueItem =
        new CMN_WebserviceCallQueue__c();

    Test.startTest();

    CMN_DAL_WebserviceCallQueue.ServiceCallResult result =
        api.process(queueItem);

    Test.stopTest();

        Assert.isTrue(result.completed);
        Assert.isFalse(result.failed);
        Assert.areEqual('200', result.statusCode);
        
        Assert.isNotNull(queueItem.CMN_Request__c);
        Assert.isNotNull(queueItem.CMN_Response__c);
        Assert.isNotNull(queueItem.CMN_URL__c);
}
    
  
    /**
     * @description Verifies failed Moonstone API callout processing.
     */
    @IsTest
    static void testProcessFailure() {

    Lead lead = [
        SELECT Id,
               FinServ__RelatedAccount__c
        FROM Lead
        LIMIT 1
    ];

    Account account = [
        SELECT Id,
               Name,
               PersonEmail,
               CMN_IdentityNumber__pc,
               OwnerId
        FROM Account
        LIMIT 1
    ];

    User usr = [
        SELECT Id,
               RM_AE_Code__c
        FROM User
        WHERE Id = :account.OwnerId
        LIMIT 1
    ];

    sbgplatform.ApiService.setMock(
        HttpCalloutMock.class,
        new MockResponse(
            500,
            '{"status":"FAILED"}'
        )
    );

    SBFC_API_MoonbaseDocument api =
        new SBFC_API_MoonbaseDocument();

    api.initialise(
        lead,
        account,
        usr,
        1,
        1,
        'Life Insurance'
    );

    CMN_WebserviceCallQueue__c queueItem =
        new CMN_WebserviceCallQueue__c();

    Test.startTest();

    CMN_DAL_WebserviceCallQueue.ServiceCallResult result =
        api.process(queueItem);

    Test.stopTest();

        Assert.isTrue(result.failed);
        Assert.areEqual('500', result.statusCode);
        
        Assert.isNotNull(queueItem.CMN_Request__c);
        Assert.isNotNull(queueItem.CMN_Response__c);
}
    
    
  /**
 * @description Verifies exception handling during Moonstone API callout processing.
 */
  @IsTest
  static void testProcessException() {

    Lead lead = [
        SELECT Id,
               FinServ__RelatedAccount__c
        FROM Lead
        LIMIT 1
    ];

    Account account = [
        SELECT Id,
               Name,
               PersonEmail,
               CMN_IdentityNumber__pc,
               OwnerId
        FROM Account
        LIMIT 1
    ];

    User usr = [
        SELECT Id,
               RM_AE_Code__c
        FROM User
        WHERE Id = :account.OwnerId
        LIMIT 1
    ];

    sbgplatform.ApiService.setMock(
        HttpCalloutMock.class,
        new MockResponse(true)
    );

    SBFC_API_MoonbaseDocument api = new SBFC_API_MoonbaseDocument();

    api.initialise(
        lead,
        account,
        usr,
        1,
        0,
        'Life Insurance'
    );

    CMN_WebserviceCallQueue__c queueItem =
        new CMN_WebserviceCallQueue__c();

    Test.startTest();

    CMN_DAL_WebserviceCallQueue.ServiceCallResult result =
        api.process(queueItem);

    Test.stopTest();

        Assert.isTrue(result.failed);
        Assert.isFalse(result.completed);
        Assert.isNotNull(result.responseBody);
}

    /**
     * @description Mock HTTP callout implementation for Moonstone API test scenarios.
     */
    public class MockResponse implements HttpCalloutMock {

    private final Integer statusCode;
    private final String responseBody;
    private final Boolean throwException;

    public MockResponse(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.throwException = false;
    }

    public MockResponse(Boolean throwException) {
        this.throwException = throwException;
    }

    public HttpResponse respond(HttpRequest request) {

        if (throwException) {
            throw new CalloutException('Mock Exception');
        }

        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody(responseBody);
        return response;
    }
}
    
  /**
* @description Verifies the Moonstone Request DTO can be instantiated and serialized successfully.
*/
   @IsTest
   static void testMoonstoneRequestDTO() {

    SBFC_MoonstoneRequestDTO request = new SBFC_MoonstoneRequestDTO();
    request.fspNo = '3825_main';
    request.fileType = 'disclosure';
    request.notifyByEmail = '0';

    request.params = new SBFC_MoonstoneRequestDTO.Params();
    request.params.cust_name = 'John Doe';
    request.params.id_no = '7008200173082';
    request.params.c_code = 'REP001';
    request.params.chk_one = 1;
    request.params.chk_two = 0;
    request.params.policy = 'Life Insurance';
    request.params.hub_sign = 0;
    request.params.manual_sign = 0;
    request.params.email_inpt = 'john@test.com';
    request.params.finalName = 'John Doe';
    request.params.finalIdNo = '7008200173082';

    String json = JSON.serialize(request);

    Assert.isNotNull(json);
    Assert.isTrue(json.contains('3825_main'));
    Assert.isTrue(json.contains('John Doe'));
    Assert.isTrue(json.contains('Life Insurance'));
}    
}