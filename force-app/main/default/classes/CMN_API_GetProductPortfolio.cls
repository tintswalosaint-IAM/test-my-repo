/**
 * @description Class used to Perform an API call to get Client Product Portfolio from SAP via ESB Middleware
 * @author Eduardo Salia
 * @date October 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56274
 * @LastModifiedReason: API Code Remediation and Indentation
 */
public with sharing class CMN_API_GetProductPortfolio extends sbgplatform.ApiGatewayService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_API_GetProductPortfolio');
    private static final String NAMED_CREDENTIAL = 'CHNW_PBB_SA_RelationshipManagementN';
    private static final String PATH_CUSTOMER = '/customer-account-list/customer';

    public CMN_API_GetProductPortfolio() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description This method performs an API request to ESB
     * @param recordId Id of our Account record
     * @return CMN_DTO_ProductPortfolioResponse responseObject
     */
    public CMN_DTO_ProductPortfolioResponse getProductPortfolio(Id recordId) {
        Account account = CMN_DAL_Account.findById(recordId);
        String path = PATH_CUSTOMER + '/' + account.CMN_BPGUID__pc;

        get(path);

        if (getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = getResponseBody();
            if (responseBody != null) {
                return (CMN_DTO_ProductPortfolioResponse) JSON.deserialize(
                    responseBody,
                    CMN_DTO_ProductPortfolioResponse.class
                );
            } else {
                LOGGER.error('No response body', (Exception) null);
            }
        } else {
            LOGGER.error('Response status: ' + getStatusCode(), (Exception) null);
        }
        return null;
    }

    /**
     * @description mocks a response returned from the Get Product Portfolio API
     */
    @testVisible
    private class ProductPortfolioMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody(
                '{"accountProductDetails":[{"accountNumber":"12123213","accountName":"a fin acc","accountType":"INVESTMENT","productNumber":"17","productName":"RETAIL WHOLESALE CALL DEPOSIT","accountStatus":"OPEN"},{"accountNumber":"333123"}]}'
            );
            return response;
        }
    }
}