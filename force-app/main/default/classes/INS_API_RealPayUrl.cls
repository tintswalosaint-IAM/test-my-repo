/**
 * @description Sends a POST request to the INS_API_RealPayUrl API endpoint with the provided Request and get RealUrl.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @date May 20th 2024
 * @LastModified: April, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-60467
 * @LastModifiedReason: API Code Remediation
 */
public with sharing class INS_API_RealPayUrl extends sbgplatform.ApiService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_API_RealPayUrl');
    private static Map<String, Generic_Config__mdt> configMap = Generic_Config__mdt.getAll();
    private static final String REQUEST_ENV = configMap.get('FuneralClaims_ENV').Value__c;
    private static final String NAMED_CREDENTIAL = 'CHNW_IAM_INS_LibertyGatewayN';
    private static final String EC_NAME = 'CHNW_IAM_INS_LibertyGatewayE';

    public INS_API_RealPayUrl() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description Framework extension point. Attaches RealPay IBM-gateway headers (client_id /
     *   client_secret / org_client_id via EC `RealPay_*` merge fields) + Bearer + product/channel/
     *   transaction headers. Same pattern as INS_API_InitiatePush + INS_Funeral_Claims.
     */
    public override HttpRequest prepareHttpRequest(String path, String method, Object requestBody, String contentType) {
        HttpRequest req = super.prepareHttpRequest(path, method, requestBody, contentType);

        // Bearer is minted via CMN_Generate_Token_Helper, which now itself extends sbgplatform.ApiService.
        // Tests intercept both the helper's token mint AND this class's API call via the framework
        // mock — the caller's inner mock must be route-aware (branches on request endpoint).
        req.setHeader('Authorization', 'Bearer ' + CMN_Generate_Token_Helper.getAccessToken());

        req.setHeader('client_id', '{!$Credential.' + EC_NAME + '.RealPay_client_id}');
        req.setHeader('client_secret', '{!$Credential.' + EC_NAME + '.RealPay_client_secret}');
        req.setHeader('org_client_id', '{!$Credential.' + EC_NAME + '.RealPay_client_id}');

        req.setHeader('country_code', INS_Quote_Helper.CLIENT_COUNTRY_SA);
        req.setHeader('product_name', 'INS_QUOTE');
        req.setHeader('channel', 'salesforce');
        req.setHeader('transaction_id', generateTransactionId());
        req.setHeader('accept', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);

        return req;
    }

    private static String generateTransactionId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.substring(0, 8) +
            '-' +
            h.substring(8, 12) +
            '-' +
            h.substring(12, 16) +
            '-' +
            h.substring(16, 20) +
            '-' +
            h.substring(20);
    }

    /**
     * @description Obtains the Request for API.
     */
    public class Request {
        @InvocableVariable(label='contractNumber' description='Quote number' required=true)
        public String contractNumber;
        @InvocableVariable(label='identificationType' description='identification Type of the Customer')
        public String identificationType;
        @InvocableVariable(label='identityNumber' description='identityNumber of the Customer' required=true)
        public String identityNumber;
        @InvocableVariable(label='countryOfIssue' description='country Of Issue')
        public String countryOfIssue;
        @InvocableVariable(label='partySourceIdentifier' description='party Source Identifier' required=true)
        public String partySourceIdentifier;
        @InvocableVariable(label='firstName' description='Customer FirstName')
        public String firstName;
        @InvocableVariable(label='lastName' description='Customer LastName')
        public String lastName;
        @InvocableVariable(label='dateOfBirth' description='Customer dateOfBirth')
        public Date dateOfBirth;
        @InvocableVariable(label='gender' description='Customer gender')
        public String gender;
        @InvocableVariable(label='email' description='Customer email' required=true)
        public String email;
        @InvocableVariable(label='cellphoneNumber' description='Customer cellphoneNumber' required=true)
        public String cellphoneNumber;
        @InvocableVariable(label='addressType' description='address Type')
        public String addressType;
        @InvocableVariable(label='addressLine' description='Customer addressLine')
        public String addressLine;
        @InvocableVariable(label='city' description='Customer city')
        public String city;
        @InvocableVariable(label='postalCode' description='Customer postalCode')
        public String postalCode;
        @InvocableVariable(label='country' description='Claimant country')
        public String country;
        @InvocableVariable(label='instalmentAmount' description='Instalment Amount')
        public Integer instalmentAmount;
        @InvocableVariable(label='numberOfInstalments' description='Number Of Instalments')
        public Integer numberOfInstalments;
        @InvocableVariable(label='instalmentStartDate' description='Instalment Start Date')
        public String instalmentStartDate;
        @InvocableVariable(label='headerCountry' description='Passing Country through header')
        public String headerCountry;
        @InvocableVariable(label='collectionDay' description='Premium Collection Day')
        public String collectionDay;
        @InvocableVariable(label='productName' description='Product Name')
        public String productName;
    }

    /**
     * @description Obtains the Response from API Response.
     */
    public class Response {
        @InvocableVariable
        public String partySourceIdentifier;
        @InvocableVariable
        public String userId;
        @InvocableVariable
        public String sessionUrl;
        @InvocableVariable
        public String contractSequence;
        @InvocableVariable
        public String errorCode;
        @InvocableVariable
        public String errorDateTime;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String errorDescription;
    }

    /**
     * @description Invocable method to fetch RealPay session URL by sending an API request with customer and contract details.
     * @param requestDetails list of Request records (only the first is processed)
     * @return List<Response>
     */
    @InvocableMethod(
        Label='RealPayUrl'
        Description='Fetches RealPay session URL by sending an API request with customer and contract details.'
    )
    public static List<Response> execute(List<Request> requestDetails) {
        List<Response> responseList = new List<Response>();
        try {
            Request req = requestDetails[0];
            INS_API_RealPayUrl_DTO.RealPayUrlRequest requestRealPay = buildRealPayRequest(req);
            String path =
                '/' +
                REQUEST_ENV +
                '-sbg-exp-contract-api/api/contracts/' +
                req.contractNumber +
                '/card-tokenization';

            String responseBody = (String) new INS_API_RealPayUrl().post(path, JSON.serialize(requestRealPay));
            responseList.add(parseSuccessResponse(responseBody));
        } catch (Exception ex) {
            LOGGER.error(
                'INS_API_RealPayUrl.execute:Some Un-Handled Exception Occurred',
                new List<String>{ 'INS_API_RealPayUrl.execute', ex.getMessage() }
            );
            throw new INS_CustomException(ex.getMessage());
        }
        return responseList;
    }

    /**
     * @description Builds the RealPay request payload from the invocable Request.
     * @param req Request record
     * @return INS_API_RealPayUrl_DTO.RealPayUrlRequest
     */
    private static INS_API_RealPayUrl_DTO.RealPayUrlRequest buildRealPayRequest(Request req) {
        INS_API_RealPayUrl_DTO.RealPayUrlRequest requestRealPay = new INS_API_RealPayUrl_DTO.RealPayUrlRequest();
        requestRealPay.identificationType = (req.identificationType == 'NATIONAL ID')
            ? 'IdentityNumber'
            : req.identificationType;
        requestRealPay.identityNumber = req.identityNumber;
        requestRealPay.countryOfIssue = req.countryOfIssue;
        requestRealPay.partySourceIdentifier = req.partySourceIdentifier;
        requestRealPay.firstName = req.firstName;
        requestRealPay.lastName = req.lastName;
        Datetime dateOfBirthValue = req.dateOfBirth;
        requestRealPay.dateOfBirth = String.valueOf(dateOfBirthValue.format('yyyy-MM-dd'));
        requestRealPay.gender = req.gender;
        requestRealPay.email = req.email;
        String cellphoneNumber = req.cellphoneNumber;
        if (cellphoneNumber != null && cellphoneNumber.startsWith('256')) {
            cellphoneNumber = cellphoneNumber.replaceFirst('256', '0');
        }
        requestRealPay.cellphoneNumber = cellphoneNumber;

        INS_API_RealPayUrl_DTO.Address realPayAddress = new INS_API_RealPayUrl_DTO.Address();
        realPayAddress.addressType = req.addressType;
        realPayAddress.addressLine = req.addressLine;
        realPayAddress.city = req.city;
        realPayAddress.postalCode = req.postalCode;
        realPayAddress.country = req.country;
        requestRealPay.Address = realPayAddress;

        INS_API_RealPayUrl_DTO.Contract realPayContract = new INS_API_RealPayUrl_DTO.Contract();
        realPayContract.instalmentAmount = String.valueOf(req.instalmentAmount);
        realPayContract.numberOfInstalments = req.numberOfInstalments;
        realPayContract.instalmentStartDate = String.valueOf(System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss'));
        realPayContract.collectionDay = Integer.valueOf(
            req.collectionDay == 'last day of month' ? '99' : req.collectionDay
        );
        requestRealPay.Contract = realPayContract;
        return requestRealPay;
    }

    /**
     * @description Parses a successful RealPay response body into a Response wrapper.
     * @param responseBody Raw JSON response body
     * @return Response record with session URL/userId populated
     */
    private static Response parseSuccessResponse(String responseBody) {
        Response responses = new Response();
        if (responseBody != null) {
            INS_API_RealPayUrl_DTO.RealPayUrlResponse realPayUrlResponse = (INS_API_RealPayUrl_DTO.RealPayUrlResponse) JSON.deserialize(
                responseBody,
                INS_API_RealPayUrl_DTO.RealPayUrlResponse.class
            );
            responses.partySourceIdentifier = realPayUrlResponse.partySourceIdentifier;
            responses.userId = realPayUrlResponse.userId;
            responses.sessionUrl = realPayUrlResponse.sessionUrl;
            responses.contractSequence = realPayUrlResponse.contractSequence;
        } else {
            LOGGER.error(
                'INS_API_RealPayUrl.execute: No response body',
                new List<String>{ 'INS_API_RealPayUrl.execute' }
            );
        }
        return responses;
    }

    /**
     * @description Generates a UUID for correlating request/response logs.
     * @return String UUID
     */
    public static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.substring(0, 8) +
            '-' +
            h.substring(8, 12) +
            '-' +
            h.substring(12, 16) +
            '-' +
            h.substring(16, 20) +
            '-' +
            h.substring(20);
    }

    /**
     * @description Mocks a successful response returned from the RealPay URL API
     */
    @testVisible
    private class RealPayUrlSuccessMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class. Route-aware: returns OAuth token JSON for the
         *   helper's INS_InsuranceClaimsAccess call, and Liberty API JSON for the RealPay endpoint.
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setStatus('OK');
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setBody('{"access_token":"test-bearer"}');
            } else {
                response.setBody(
                    '{"partySourceIdentifier":"ptyId_001001001","userId":"UGCM930121003EGE",' +
                    '"sessionUrl":"https://uat.realpaycollect.com/rpswitch/?data=3FCCEAEC4B1E86AD7BEFB634C9F0E30C6:CYBSCARDUGX"}'
                );
            }
            return response;
        }
    }

    /**
     * @description Mocks an error response returned from the RealPay URL API
     */
    @testVisible
    private class RealPayUrlFailureMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class. Route-aware: returns a valid Bearer for the
         *   helper's token endpoint (so the prod path reaches the Liberty call), then 500 on the
         *   Liberty endpoint to drive the failure path.
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
                response.setStatus('OK');
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"test-bearer"}');
            } else {
                response.setStatusCode(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
                response.setStatus('Internal Server Error');
                response.setHeader('Content-Type', 'application/json');
                response.setBody(
                    '{"error":{"errorCode":400,"errorDateTime":"2024-06-20T10:41:36",' +
                        '"errorMessage":"/contract/instalmentStartDate [2024-07-03] is not a valid date-time-only",' +
                        '"errorDescription":"error"}}'
                );
            }
            return response;
        }
    }
}