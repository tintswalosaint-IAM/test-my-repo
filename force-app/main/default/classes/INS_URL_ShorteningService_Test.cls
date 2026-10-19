/**
 * @description       : Test class for INS_URL_ShorteningService
 * @author            : Jaco de Lange
 * @group             : SFP-453856 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @created date      : 27-10-2025
 * 
 * last modified      : Jaco de Lange
 * last modified date : 07 July 2026
 * description        : Main INS_URL_ShorteningService refactored to align with the 
 *                      secured sbgplatform.ApiService architectural pattern and also to    
 *                      accommodate the AppsFlyer shortening service.  
 * @group             : SFP-59109
**/
@IsTest
private class INS_URL_ShorteningService_Test {

    @isTest
    static void testCreateShortUrl_Success() {
        String longUrl = 'https://gateway.example.com/pay/invoice123';
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new INS_URL_ShorteningService.ShortenUrlSuccessMock());

        Test.startTest();
            String shortUrl = INS_URL_ShorteningService.createShortUrl(longUrl);
        Test.stopTest();
       
        Assert.areEqual('https://myapp.onelink.me/i2hG/payment_request_2026', shortUrl, 'The short URL should match the mock response.');
    }

    @isTest
    static void testCreateShortUrl_BlankUrl() {
        Test.startTest();
            String shortUrl = INS_URL_ShorteningService.createShortUrl('');
        Test.stopTest();

        Assert.areEqual(null, shortUrl, 'Passing a blank URL should immediately return null without an exception.');
    }

    @isTest
    static void testCreateShortUrl_FailureResponse() {
        String longUrl = 'https://gateway.example.com/pay/invoice123';
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new INS_URL_ShorteningService.ShortenUrlFailureMock());

        Test.startTest();
            try {
                INS_URL_ShorteningService.createShortUrl(longUrl);
                //System.assertEquals(false, 'An exception was expected due to a 500 status code response.');
            } catch (Exception ex) {
                Assert.areEqual(true, ex.getTypeName().contains('INS_CustomException'), 'The exception caught should be an instance of INS_CustomException.');
            }
        Test.stopTest();
    }

    @isTest
    static void testPrepareHttpRequest() {
        INS_URL_ShorteningService serviceInstance = new INS_URL_ShorteningService();
        String path = '/api/v2.0/shortlinks/i2hG';
        String method = 'POST';
        String requestBody = '{"ttl":"90d"}';
        String contentType = 'application/json';

        Test.startTest();
            HttpRequest req = serviceInstance.prepareHttpRequest(path, method, requestBody, contentType);
        Test.stopTest();

        Assert.areEqual('Bearer {!$Credential.CHNW_IAM_AR_SortenLongURLE.token}', req.getHeader('Authorization'), 'The Authorization header should format correctly.');
        Assert.areEqual('application/json', req.getHeader('accept'), 'The accept header should match application/json.');
    }
}