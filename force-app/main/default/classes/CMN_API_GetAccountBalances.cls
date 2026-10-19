/**
 * @description Class used to Perform an API call to get Financial Account Balances from Finacle via ESB Middleware
 * @author Eduardo Salia
 * @date July 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56261
 * @LastModifiedReason: API Code Remediation and Indentation
 */
public with sharing class CMN_API_GetAccountBalances extends sbgplatform.ApiGatewayService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_API_GetAccountBalances');
    private static final String NAMED_CREDENTIAL = 'CHNW_PBB_SA_RelationshipManagementN';
    private static final String PATH_BALANCES = '/salesforce-balance-information/balance-information';
    //Generic Constants
    private static final String BLANK_STRING = '';
    //API specific
    private static final String ESB_IDENTIFICATION_NUMBER = '007';
    private static final String ESB_SYSTEM_IDENTIFICATION_NUMBER = '01';
    // balance types
    private static final Map<String, String> balanceCodeToDescriptionMap = new Map<String, String>{
        '0001' => 'Available Balance',
        '0002' => 'Actual  Balance',
        'CAA' => 'Current Account',
        'CLA' => 'Commercial Lending',
        'DDA' => 'Demand Draft',
        'LAA' => 'Loan Account',
        'OAB' => 'Office Account Basic',
        'OAP' => 'Office Account Pointing',
        'ODA' => 'Overdraft Account',
        'OSP' => 'Office System Pointing',
        'SBA' => 'Saving Bank Account',
        'TDA' => 'Term Deposit',
        'TUA' => 'Top Up Deposit'
    };

    public CMN_API_GetAccountBalances() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description This method performs an API request to ESB
     * @param recordId Id of our current record
     * @return CMN_DTO_AccountBalancesResponse responseObject
     */
    public CMN_DTO_AccountBalancesResponse getBalances(Id recordId) {
        //Prepare Request Objects
        CMN_DTO_AccountBalancesRequest dtoRequest = new CMN_DTO_AccountBalancesRequest();
        CMN_DTO_AccountBalancesRequest.requestObject dtoRequestObject = new CMN_DTO_AccountBalancesRequest.requestObject();
        CMN_DTO_RoutingInformation dtoRequestRoutingInformation = new CMN_DTO_RoutingInformation();
        List<CMN_DTO_RoutingInformation> dtoRequestRoutingInformationList = new List<CMN_DTO_RoutingInformation>();
        //Prepare Routing Information
        dtoRequestRoutingInformation.systemIdentificationNumber = ESB_IDENTIFICATION_NUMBER;
        dtoRequestRoutingInformation.applicationIdentificationNumber = ESB_IDENTIFICATION_NUMBER;
        dtoRequestRoutingInformationList.add(dtoRequestRoutingInformation);
        //Prepare DTO Object
        dtoRequestObject.routingInformation = dtoRequestRoutingInformationList;
        dtoRequestObject.cifSystemIdentificationNumber = ESB_SYSTEM_IDENTIFICATION_NUMBER;
        dtoRequestObject.customerRegNumber = BLANK_STRING;
        //Prepare Account Information
        String objectName = recordId.getSObjectType().getDescribe().getName();
        if (objectName == CMN_DAL_Account.OBJECT_NAME) {
            Account account = CMN_DAL_Account.findById(recordId);
            dtoRequestObject.cifCountry = account.ExternalCIFCountry__c;
            dtoRequestObject.customerUUID = account.ExternalCIFId__c;
            dtoRequestObject.customerIdNumber = account.ExternalCIFId__c;
            dtoRequestObject.uniqueTransactionIdentificationNumber = account.ExternalCIFId__c;
            dtoRequestObject.accountNo = account.ExternalCIFId__c;
        } else if (objectName == CMN_DAL_FinancialAccount.OBJECT_NAME) {
            FinServ__FinancialAccount__c financialAccount = CMN_DAL_FinancialAccount.findById(recordId);
            Account account = CMN_DAL_Account.findById(financialAccount.FinServ__PrimaryOwner__c);
            dtoRequestObject.cifCountry = account.ExternalCIFCountry__c;
            dtoRequestObject.customerUUID = account.ExternalCIFId__c;
            dtoRequestObject.customerIdNumber = account.ExternalCIFId__c;
            dtoRequestObject.uniqueTransactionIdentificationNumber = account.ExternalCIFId__c;
            dtoRequestObject.accountNo = financialAccount.FinServ__FinancialAccountNumber__c;
        }
        dtoRequest.request = dtoRequestObject;
        //Make API Callout
        post(PATH_BALANCES, JSON.serialize(dtoRequest));

        if (getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = getResponseBody();
            if (responseBody != null) {
                responseBody = responseBody.replace('"currency":', '"currencyCode":');
                CMN_DTO_AccountBalancesResponse responseObject = (CMN_DTO_AccountBalancesResponse) JSON.deserialize(
                    responseBody,
                    CMN_DTO_AccountBalancesResponse.class
                );
                return substituteBalanceTypes(responseObject);
            } else {
                LOGGER.error('No response body', (Exception) null);
            }
        } else {
            LOGGER.error('Response status: ' + getStatusCode(), (Exception) null);
        }
        return null;
    }

    /**
     * @description This method substitutes balance type codes with descriptions
     * @param responseObject responseObject
     * @return CMN_DTO_AccountBalancesResponse responseObject
     */
    public static CMN_DTO_AccountBalancesResponse substituteBalanceTypes(
        CMN_DTO_AccountBalancesResponse responseObject
    ) {
        for (CMN_DTO_BalanceInformation balance : responseObject.response.balances) {
            if (balanceCodeToDescriptionMap.containsKey(balance.balanceType))
                balance.balanceType = balanceCodeToDescriptionMap.get(balance.balanceType);
        }
        return responseObject;
    }

    /**
     * @description mocks a response returned from the Get Account Balances API
     */
    @testVisible
    private class AccountBalancesMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody(
                '{\"response\":{\"uniqueTransactionIdentificationNumber\":\"caf79ab4-3e47-4510-8d9d-8290cfbc347\",\"cifCountry\":\"ZA\",\"cifSystemIdentificationNumber\":\"01\",\"routingInformation\":[{\"systemIdentificationNumber\":\"007\",\"applicationIdentificationNumber\":\"007\"}],\"balances\":[{\"accountNo\":\"12123213\",\"balanceAmount\":\"123213213\",\"balanceType\":\"0001\",\"balanceDate\":\"213213123\",\"currency\":\"\"},{\"accountNo\":\"12123213\",\"balanceAmount\":\"123213213\",\"balanceType\":\"0002\",\"balanceDate\":\"213213123\",\"currency\":\"ZAR\"}]}}'
            );
            return response;
        }
    }
}