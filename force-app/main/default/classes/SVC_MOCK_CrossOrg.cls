/**
 * @description Mock API response for testing cross org rest callout
 *
 * @see SVC_API_CrossOrg_TEST
 *
 * @author Accenture
 *
 * @date July 2022
 *
 */

@IsTest
public class SVC_MOCK_CrossOrg implements HttpCalloutMock
{

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    /**
     * @description Constructor for mock HTTP response
     *
     * @param code Response status
     * @param status Textual status eg: SUCCESS
     * @param body Request body
     * @param responseHeaders Requested headers
     */
    public SVC_MOCK_CrossOrg(Integer code, String status, String body, Map<String, String> responseHeaders)
    {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    /**
     * @description Mocked response method to formulate the response
     *
     * @param req HTTPRequest
     *
     * @return Mocked HTTP response
     */
    public HttpResponse respond(HttpRequest req)
    {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet())
        {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}