/***************************************************************************************
* @ Author            : prem.lingala@standardbank.co.za
* @ Date              : Mar 2024
* @ Name of the Class : PRX_API_MockNegativeResponseGenTest
* @description       : This Apex class, PRX_API_MockNegativeResponseGenerator, is designed
*                       to provide a mock implementation for handling negative responses
*                       in HTTP callouts within Apex unit tests. It implements the HttpCalloutMock  
*                       interface to simulate HTTP responses without actually making external
*                       HTTP requests during testing.
*
*                       The class contains a single method, 'respond', which is required by the
*                       HttpCalloutMock interface. This method takes an HTTPRequest object as
*                       input and returns an HTTPResponse object.
*
*                       In this implementation, the 'respond' method always returns an HTTPResponse
*                       object with a status code of 500, indicating an Internal Server Error, and
*                       a JSON-formatted error message in the response body. This allows test methods
*                       that use this mock class to simulate scenarios where the external HTTP service
*                       being called encounters an error.
@ Last Modified By  :prem.lingala@standardbank.co.za
@ Last Modified On  :Mar 2024
@ Jira Ticket       : SFP-29221, SFP-34158
* ---------------------------------------------------------------------------
*version   Date               Developer                  Description
* ---------------------------------------------------------------------------
  1.0    Mar 2024   prem.lingala@standardbank.co.za   Initial Version
***************************************************************************************/
@isTest
public class PRX_API_MockNegativeResponseGenTest  implements HttpCalloutMock  {
     /**
     * @description Responds to an HTTP request with a mocked error response.
     * @param req The HTTP request.
     * @return The HTTP response with a status code indicating an error and an error message in the body.
     */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setBody('{"error": "Mocked error response"}');
        return res;
    }
}