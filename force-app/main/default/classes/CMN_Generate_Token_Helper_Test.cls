/**
 * @description Test class for CMN_Generate_Token_Helper. Migrated to framework setMock pattern.
 * @author Khaliq Abdul (khaliq.abdul@standardbank.co.za)
 * @date Feb 19th 2024
 * @LastModified: May, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-60467
 * @LastModifiedReason: API Code Remediation — helper migrated to sbgplatform.ApiService; tests now mock
 *   via sbgplatform.ApiService.setMock instead of Test.setMock.
 */
@isTest
public class CMN_Generate_Token_Helper_Test {
    @isTest
    static void testGetAccessToken() {
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForAccessToken());
        Test.startTest();
        final String accessTokenPing = CMN_Generate_Token_Helper.getAccessToken();
        Test.stopTest();
        Assert.areEqual('pingAccessToken111', accessTokenPing, 'Access token should be pingAccessToken111');
    }

    @isTest
    static void testGetAccessTokenError() {
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockHttpForAccessTokenError());
        Test.startTest();
        final String accessTokenPing = CMN_Generate_Token_Helper.getAccessToken();
        Test.stopTest();
        Assert.areEqual(null, accessTokenPing, 'Access token is null on non-200');
    }

    @isTest
    static void testGetAccessTokenCatch() {
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockHttpAccessTokenCatch());
        Test.startTest();
        final String accessTokenPing = CMN_Generate_Token_Helper.getAccessToken();
        Test.stopTest();
        Assert.areEqual(null, accessTokenPing, 'Access token should be null when body has null access_token');
    }

    public class MockHttpResponseGeneratorForAccessToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            final HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "pingAccessToken111"}');
            response.setStatusCode(200);
            return response;
        }
    }

    public class MockHttpForAccessTokenError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            final HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": null}');
            response.setStatusCode(400);
            return response;
        }
    }

    public class MockHttpAccessTokenCatch implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            final HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": null}');
            response.setStatusCode(200);
            return response;
        }
    }
}