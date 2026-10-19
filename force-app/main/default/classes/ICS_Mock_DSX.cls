/**
 * @description Mock class for DSX callout
* @author Gnitsevich Anton
 * @date January 2023 
*/
@testVisible
public class ICS_Mock_DSX {

 /**
     * @description mocks a response returned from the Store Document API
     */
    @testVisible
    public class StoreDocumentMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object 
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('\"documentId\":\"abcdefgh-1234-5678-9012-34567890abcd\"}');
            return response;
        }
    }
    
    /**
     * @description mocks a response returned from the Update Retention API
     */
    @testVisible
    public class UpdateMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('');
            return response;
        }
    }
    
    /**
     * @description mocks a response returned from the Search Documents API
     */
    @testVisible
    private class SearchDocumentsMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
    	@testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"pageInfo\":{"currentPage\":100,\"totalPages\":101,"pageSize\":101,\"totalCount\":1},\"documents\":[{\"documentId\":\"abcdefgh-1234-5678-9012-34567890abcd\",\"salesforceId\":\"0013L00000V6nITQAZ\",\"clientNo\":null,\"clientName\":null,\"documentType\":\"Proof of Loan\",\"retentionDate\":\"2999-01-01T00:00:00Z\",\"documentDate\":\"2023-01-01T00:00:00Z\",\"documentName\":\"John-Johns-ProofofLoan-2023-01-01.txt\"}]}');
            return response;
        }
    }
    
    /**
     * @description mocks a response returned from the Download Document API
     */
    @testVisible
    private class DownloadDocumentMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
    	@testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setHeader('Content-Disposition', 'attachment; filename=John-Johns-ProofofLoan-2023-01-01.txt; filename*=UTF-8\'\'John-Johns-ProofofLoan-2023-01-01.txt');
            response.setHeader('Date', '2023-01-01T00:00:00Z');
            response.setHeader('Content-Length', '27');
            response.setHeader('Content-Type', 'text/plain');
            response.setBodyAsBlob(Blob.valueOf('ProofOfLoan Text Contents'));
            return response;
        }
    }
    
            /**
     * @description mocks a response returned from the Update Retention API fail
     */
    @testVisible
    public class DSXMockResponseFail implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_BAD_REQUEST);
            response.setBody('Failed');
            return response;
        }
    }

}