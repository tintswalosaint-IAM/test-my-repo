/**
* @description Class for Mock data for all API test classes
*
*
* @author jagadish
* @date june 2023
*/
@isTest
public class BCB_HttpMockGenerator implements HttpCalloutMock{

    HttpResponse res;
    Map<String, HttpResponse> responseByEndpointOrContent;
 /**
     * @description Http mock generator constructor
     * @param r
     * @param responseByEndpointOrContent
     */
    public BCB_HttpMockGenerator(HttpResponse r, Map<String, HttpResponse> responseByEndpointOrContent) {
        res = r;
        this.responseByEndpointOrContent = responseByEndpointOrContent;
    }
    /**
     * @description Http respose
     * @param req
     * @return res
     */
    public HttpResponse respond(HttpRequest req) {

        if (responseByEndpointOrContent == null) {
            return res;
        }
        else {
            if (responseByEndpointOrContent.containsKey(req.getEndpoint())) {
                return responseByEndpointOrContent.get(req.getEndpoint());
            }

            for (String bodyPart : responseByEndpointOrContent.keySet()) {
                if (req.getBody() != null && req.getBody().containsIgnoreCase(bodyPart)) {
                    return responseByEndpointOrContent.get(bodyPart); 
                }
            }

        }
        return res;
    }
    /**
     * @description Http respose
     * @param statusCode
     * @param status
     * @param body
     */
    public static void setTestMockResponse(Integer statusCode, String status, String body) {
        setTestMockResponse(statusCode, status, body, null);
    }
    /**
     * @description Http respose
     * @param statusCode
     * @param status
     * @param body
     * @param responseByEndpointOrContent
     */
    public static void setTestMockResponse(Integer statusCode, String status, String body, Map<String, HttpResponse> responseByEndpointOrContent) {
        HttpResponse mockResp = new HttpResponse();

        if (statusCode != null) {
            mockResp.setStatusCode(statusCode);
        }

        if (status != null) {
            mockResp.setStatus(status);
        }

        if (body != null) {
            mockResp.setBody(body);
        }

        System.Test.setMock(
                HttpCalloutMock.class,
                new BCB_HttpMockGenerator(mockResp, responseByEndpointOrContent)
        );

    }
}