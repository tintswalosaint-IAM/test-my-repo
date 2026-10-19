/**
 * @description Class used to Perform an API call to get Latest 10 Financial Transactions from Finacle via ESB Middleware
 * @author Eduardo Salia
 * @date July 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56272
 * @LastModifiedReason: API Code Remediation and Indentation
 */
public with sharing class CMN_API_GetFinancialTransactions extends sbgplatform.ApiGatewayService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_API_GetFinancialTransactions');
    private static final String NAMED_CREDENTIAL = 'CHNW_PBB_SA_RelationshipManagementN';
    private static final String PATH_TRANSACTIONS = '/salesforce-account-transaction-information/transaction-information';
    //Generic Constants
    private static final String BLANK_STRING = '';
    private static final String NUMBER_OF_TRANSACTIONS = '10';
    private static final String DATE_PREFIX = '0';
    private static final String DATE_DIVIDER = '-';
    //API specific
    private static final String ESB_IDENTIFICATION_NUMBER = '007';
    private static final String ESB_SYSTEM_IDENTIFICATION_NUMBER = '01';

    public CMN_API_GetFinancialTransactions() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description This method performs an API request to ESB
     * @param recordId Id of our Financial Account record
     * @return CMN_DTO_FinancialTransactionsResponse responseObject
     */
    public CMN_DTO_FinancialTransactionsResponse getLatestTransactions(Id recordId) {
        //Prepare Request Data
        FinServ__FinancialAccount__c financialAccount = CMN_DAL_FinancialAccount.findById(recordId);
        if (financialAccount == null) {
            LOGGER.error('Financial Account "' + recordId + '" is not available', (Exception) null);
            return null;
        }
        Account account = CMN_DAL_Account.findById(financialAccount.FinServ__PrimaryOwner__c);
        //Prepare Request Wrapper Objects
        CMN_DTO_FinancialTransactionsRequest dtoRequest = new CMN_DTO_FinancialTransactionsRequest();
        CMN_DTO_FinancialTransactionsRequest.requestObject dtoRequestObject = new CMN_DTO_FinancialTransactionsRequest.requestObject();
        CMN_DTO_RoutingInformation dtoRequestRoutingInformation = new CMN_DTO_RoutingInformation();
        List<CMN_DTO_RoutingInformation> dtoRequestRoutingInformationList = new List<CMN_DTO_RoutingInformation>();
        //Prepare Routing Information Wrapper Object
        dtoRequestRoutingInformation.systemIdentificationNumber = ESB_IDENTIFICATION_NUMBER;
        dtoRequestRoutingInformation.applicationIdentificationNumber = ESB_IDENTIFICATION_NUMBER;
        dtoRequestRoutingInformationList.add(dtoRequestRoutingInformation);
        //Prepare Request DTO Wrapper Object
        dtoRequestObject.routingInformation = dtoRequestRoutingInformationList;
        dtoRequestObject.uniqueTransactionIdentificationNumber = account.ExternalCIFId__c;
        dtoRequestObject.cifCountry = account.ExternalCIFCountry__c;
        dtoRequestObject.cifSystemIdentificationNumber = ESB_SYSTEM_IDENTIFICATION_NUMBER;
        dtoRequestObject.customerUUID = account.ExternalCIFId__c;
        dtoRequestObject.customerIdNumber = account.ExternalCIFId__c;
        dtoRequestObject.customerRegNumber = BLANK_STRING;
        dtoRequestObject.accountNo = financialAccount.FinServ__FinancialAccountNumber__c;
        dtoRequestObject.transactionsStartDt = getFormattedDateString(true);
        dtoRequestObject.transactionsEndDt = getFormattedDateString(false);
        dtoRequestObject.numberOfTransactions = NUMBER_OF_TRANSACTIONS;
        dtoRequest.request = dtoRequestObject;
        //Make API Callout
        post(PATH_TRANSACTIONS, JSON.serialize(dtoRequest));

        if (getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = getResponseBody();
            if (responseBody != null) {
                responseBody = responseBody.replace('"currency":', '"currencyCode":');
                return (CMN_DTO_FinancialTransactionsResponse) JSON.deserialize(
                    responseBody,
                    CMN_DTO_FinancialTransactionsResponse.class
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
     * @description This method builds a Date String in format 'YYYY-MM-DD'
     * @param applyDateFilter Date Filter Flag
     * @return String formattedDate
     */
    public static String getFormattedDateString(Boolean applyDateFilter) {
        String formattedDate;
        Date returnDate;
        Date dateToday = Date.today();
        Date dateBack = dateToday.addMonths(-6);
        if (applyDateFilter) {
            returnDate = dateBack;
        } else {
            returnDate = dateToday;
        }
        // construct string
        String year = String.valueOf(returnDate.year());
        String month = String.valueOf(returnDate.month());
        String day = String.valueOf(returnDate.day());
        formattedDate = year;
        if (month.length() < 2) {
            formattedDate += DATE_DIVIDER + DATE_PREFIX + month;
        } else {
            formattedDate += DATE_DIVIDER + month;
        }
        if (day.length() < 2) {
            formattedDate += DATE_DIVIDER + DATE_PREFIX + day;
        } else {
            formattedDate += DATE_DIVIDER + day;
        }
        return formattedDate;
    }

    /**
     * @description mocks a response returned from the Get Financial Transactions API
     */
    @TestVisible 
    private class FinancialTransactionsMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody(
                '{"response":{"uniqueTransactionIdentificationNumber":"caf79ab4-3e47-4510-8d9d-8290cfbc347","cifCountry":"ZA","cifSystemIdentificationNumber":"01","routingInformation":[{"systemIdentificationNumber":"007","applicationIdentificationNumber":"007"}],"transactions":[{"transactionDt":"2021-01-14","description":"STATEMENT COSTS 000000450 POSTED STMT FEE 0216","creditDebit":"D","amount":"-33","currency":"ZAR","transactionType":"Deposit"},{"transactionDt":"2021-01-15","description":"STATEMENT COSTS 000000450 POSTED STMT FEE 0217","creditDebit":"D","amount":"-33","currency":"ZAR","transactionType":"Deposit"}]}}'
            );
            return response;
        }
    }
}