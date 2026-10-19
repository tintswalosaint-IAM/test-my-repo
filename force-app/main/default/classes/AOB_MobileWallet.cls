/***************************************************************************************
@ Author            :Jagadish Thummala
@ Date              :June 2022
@ Name of the Class :AOB_MobileWallet
@ Description       :Class for dealing Mobile Funding
@ Last Modified By  : Jagadish Thummala
@ Last Modified On  : 24 SEP 2025
@ Modification Description : [SFP-51922]Split fund equally across multiple Application__c records; allow explicit amount parameter
@ Last Modified By  : Alex Niyonsaba
@ Last Modified On  : 06 JUL 2026
@ Modification Description : [SFP-59073] Cast amount to Integer to fix 'Invalid amount' API error rsponse.
***************************************************************************************/
public with sharing class AOB_MobileWallet {
    private AOB_MobileWallet(){}
    
    // HTTP Constants
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String USER_AGENT = 'User-Agent';
    private static final String PATH_CALLOUT = '/wallet/mobile/transaction';
    
    // Response Keys
    private static final String KEY_STATUS = 'status';
    private static final String KEY_STATUS_CODE = 'statusCode';
    private static final String KEY_ERROR_DESCRIPTION = 'ErrorDescription';
    private static final String KEY_WALLET_STATUS = 'walletStatus';
    
    // Status Values
    private static final String RESPONSE_STATUS_FAILED = 'FAILED';
    private static final String RESPONSE_STATUS_NO_CONTENT = 'NO_CONTENT';
    private static final String API_SUCCESS_CODE = '01';
    private static final Integer HTTP_STATUS_OK = 200;
    private static final Integer HTTP_STATUS_NO_CONTENT = 204;
    private static final Integer HTTP_STATUS_INTERNAL_ERROR = 500;
    
    // Verification Constants
    private static final String VERIFICATION_SOURCE = 'Mobile Wallet';
    private static final String VERIFICATION_STATUS_SUCCESS = 'Success';
    private static final String VERIFICATION_STATUS_FAILED = 'Failed';
    
    // Other Constants
    private static final String COUNTRY_PHONE_CODE = '256';
    private static final String METADATA_WALLET_FUNCTION = 'walletfunction';
    private static final String METADATA_WALLET_CLIENT = 'walletClient';
    
    // Used for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_MobileWallet');
    public static Map<String, Object> responseToReturnObject;
    public static Map<String, Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_MobileWallet');

    /**
    * @description Original entry (kept for compatibility) – falls back to using first record amount
    * @param applicationList List of Application__c records to fund
    * @return JSON serialized response map as String
    */
    public static String invokeWalletFunding(List<Application__c> applicationList) {
        return invokeWalletFunding(applicationList, null);
    }

    /**
    * @description Overload that accepts an explicit total fund amount. If null, falls back to record field.
    * @param applicationList List of Application__c records to fund
    * @param explicitTotalFund Total amount to split; if null uses first record’s AOB_Fund_Amount__c
    * @return JSON serialized response map as String
    */
    public static String invokeWalletFunding(List<Application__c> applicationList, Decimal explicitTotalFund) {
        if (applicationList == null || applicationList.isEmpty()) {
            return null;
        }

        Application__c primary = applicationList[0];
        Decimal totalFund = getTotalFund(primary, explicitTotalFund);
        Map<String, Object> responseMap = makeMobileWalletCallout(applicationList, totalFund);

        if (!isSuccessfulResponse(responseMap)) {
            return handleVerification(primary, responseMap, VERIFICATION_STATUS_FAILED);
        }

        return processWalletStatus(applicationList, responseMap, primary);
    }

    /**
    * @description Determines the total funding amount, using explicit value if provided or falling back to record field
    * @param primary Primary Application__c record
    * @param explicitTotalFund Explicit total funding amount (optional)
    * @return Decimal total funding amount
    */
    private static Decimal getTotalFund(Application__c primary, Decimal explicitTotalFund) {
        if (explicitTotalFund != null) {
            return explicitTotalFund;
        }
        
        return primary.AOB_Fund_Amount__c == null ? 0 : decimal.valueOf(primary.AOB_Fund_Amount__c);
    }

    /**
    * @description Checks if the response indicates a successful API call
    * @param responseMap Response map from API call
    * @return Boolean indicating success
    */
    private static Boolean isSuccessfulResponse(Map<String, Object> responseMap) {
        return responseMap != null && responseMap.get(KEY_STATUS) == HTTP_STATUS_OK && (String)responseMap.get(KEY_STATUS_CODE) == API_SUCCESS_CODE;
    }

    /**
    * @description Processes the wallet status check and updates the response
    * @param applicationList List of Application__c records
    * @param responseMap Initial response map
    * @param primary Primary Application__c record
    * @return JSON serialized updated response map as String
    */
    private static String processWalletStatus(List<Application__c> applicationList, Map<String, Object> responseMap, Application__c primary) {
        String walletStatusResponse = AOB_FlowController.invokeMobileWalletStatusCheckCallout(applicationList, JSON.serialize(responseMap));
        Map<String, Object> walletStatusResponseMap = (Map<String, Object>) JSON.deserializeUntyped(walletStatusResponse);

        updateResponseWithStatus(responseMap, walletStatusResponseMap);
        return handleVerification(primary, responseMap, VERIFICATION_STATUS_SUCCESS);
    }

    /**
    * @description Updates the response map with status information from wallet check
    * @param responseMap Original response map
    * @param statusMap Status map from wallet check
    */
    private static void updateResponseWithStatus(Map<String, Object> responseMap, Map<String, Object> statusMap) {
        if (statusMap == null) {
            return;
        }
        if (statusMap.containsKey(KEY_ERROR_DESCRIPTION)) {
            responseMap.put(KEY_ERROR_DESCRIPTION, statusMap.get(KEY_ERROR_DESCRIPTION));
        }
        responseMap.put(KEY_WALLET_STATUS, (String) statusMap.get(KEY_STATUS));
    }

    /**
    * @description Creates a verification record and returns serialized response
    * @param applicationRecord Application__c record for verification
    * @param responseMap Response map to store
    * @param status Verification status (Success or Failed)
    * @return JSON serialized response map as String
    */
    private static String handleVerification(Application__c applicationRecord, Map<String, Object> responseMap, String status) {
        Verification__c verificationInstance = new Verification__c(
            Application__c = applicationRecord.Id,
            Verification_Source__c = VERIFICATION_SOURCE,
            AOB_DSX_Response__c = JSON.serialize(responseMap),
            Verification_Status__c = status
        );
        AOB_FlowController.createVerificationWithInstance(verificationInstance);
        return JSON.serialize(responseMap);
    }

    /**
     * @description Prepare and execute callout with explicit total fund
     * @param applicationList List of Application__c records
     * @param totalFund Total funding amount
     * @return Response map from API call
     */
    public static Map<String, Object> makeMobileWalletCallout(List<Application__c> applicationList, Decimal totalFund) {
        AOB_MobileWalletBean mobileWalletBeanRecord = prepareMobileWalletBean(applicationList, totalFund);
        HttpRequest httpRequest = prepareHttpRequest(mobileWalletBeanRecord);
        return sendHttpRequest(httpRequest, applicationList[0]);
    }

    /**
     * @description Backward-compatible callout – uses first record amount
     * @param applicationList List of Application__c records
     * @return Response map from API call
     */
    public static Map<String, Object> makeMobileWalletCallout(List<Application__c> applicationList) {
        Decimal tf = getFallbackTotalFund(applicationList);
        return makeMobileWalletCallout(applicationList, tf);
    }

    /**
     * @description Gets fallback total fund from first record
     * @param applicationList List of Application__c records
     * @return Decimal fallback total fund
     */
    private static Decimal getFallbackTotalFund(List<Application__c> applicationList) {
        if (applicationList == null || applicationList.isEmpty()) {
            return 0;
        }
        return applicationList[0].AOB_Fund_Amount__c == null ? 0 : decimal.valueOf(applicationList[0].AOB_Fund_Amount__c);
    }

    /**
     * @description Prepare bean with payload and multiple transfers using equal split of the total fund amount
     * @param applicationList List of Application__c records
     * @param totalFund Total funding amount to split
     * @return AOB_MobileWalletBean instance
     */
    private static AOB_MobileWalletBean prepareMobileWalletBean(List<Application__c> applicationList, Decimal totalFund) {
        List<Application__c> apps = applicationList == null ? new List<Application__c>(): applicationList ;
        Application__c primaryApp = apps.isEmpty() ? null : apps[0];
        Integer n = Math.max(1, apps.size());

        // Bulk query account numbers to optimize performance
        List<Id> appIds = new List<Id>();
        for (Application__c app : apps) {
            appIds.add(app.Id);
        }
        List<Application__c> freshApps = new SEL_Application().selectApplicationById(appIds); 
        Map<Id, String> acctMap = new Map<Id, String>();
        for (Application__c freshApp : freshApps) {
            acctMap.put(freshApp.Id, freshApp.AOB_Account_Number__c);
        }

        // Round total to currency precision
        Decimal totalRounded = (totalFund == null ? 0 : totalFund).setScale(2);

        // Equal split to 2 decimals; remainder goes to the last transfer to preserve exact total
        Decimal perPart = (n > 0) ? (totalRounded / n).setScale(2) : 0;
        Decimal sumParts = (perPart * n).setScale(2);
        Decimal remainder = (totalRounded - sumParts).setScale(2);

        AOB_MobileWalletBean mobileWalletBeanRecord = new AOB_MobileWalletBean();
        mobileWalletBeanRecord.function = String.valueOf(mData.get(METADATA_WALLET_FUNCTION)) == null ? '': String.valueOf(mData.get(METADATA_WALLET_FUNCTION));
        AOB_MobileWalletBean.Payload payloadRecord = createPayload(primaryApp, totalRounded);
        List<AOB_MobileWalletBean.Transfer> transferRecordList = createTransfers(apps, n, perPart, remainder, acctMap);
        mobileWalletBeanRecord.payload = payloadRecord;
        mobileWalletBeanRecord.transfer = transferRecordList;

        return mobileWalletBeanRecord;
    }

    /**
     * @description Creates the payload for the mobile wallet bean
     * @param primaryApp Primary Application__c record
     * @param totalRounded Rounded total funding amount
     * @return Payload instance
     */
    private static AOB_MobileWalletBean.Payload createPayload(Application__c primaryApp, Decimal totalRounded) {
        AOB_MobileWalletBean.Payload payloadRecord = new AOB_MobileWalletBean.Payload();
        payloadRecord.requestTime = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        payloadRecord.transactionReference = primaryApp == null ? String.valueOf(System.now().getTime()): primaryApp.Id;

        payloadRecord.name = primaryApp == null ? '' :  primaryApp.AOB_FirstName__c + ' ' + primaryApp.AOB_LastName__c;
        payloadRecord.amount = string.valueOf(totalRounded.intValue());
        payloadRecord.sessionNumber = String.valueOf(System.now().getTime());
        payloadRecord.mobileNumber = primaryApp == null ? '': (COUNTRY_PHONE_CODE + primaryApp.AOB_Phone__c);
        return payloadRecord;
    }

    /**
     * @description Creates list of transfers with split amounts
     * @param apps List of Application__c records
     * @param n Number of applications
     * @param perPart Amount per part
     * @param remainder Remainder to add to last transfer
     * @param acctMap Map of application Id to account number
     * @return List of Transfer instances
     */
    private static List<AOB_MobileWalletBean.Transfer> createTransfers(List<Application__c> apps, Integer n, Decimal perPart, Decimal remainder, Map<Id, String> acctMap) {
        List<AOB_MobileWalletBean.Transfer> transferRecordList = new List<AOB_MobileWalletBean.Transfer>();
        for (Integer i = 0; i < n; i++) {
            Application__c app = apps[i];
            AOB_MobileWalletBean.Transfer transferRecord = new AOB_MobileWalletBean.Transfer();

            transferRecord.accountNo = acctMap.get(app.Id);

            Decimal thisAmount = (i == n - 1) ? (perPart + remainder).setScale(2) : perPart;
            transferRecord.amount = string.valueOf(thisAmount.intValue());
            transferRecord.name = app.AOB_FirstName__c + ' ' + app.AOB_LastName__c;

            transferRecordList.add(transferRecord);
        }
        return transferRecordList;
    }

    /**
     * @description Prepare HttpRequest for the callout
     * @param mobileWalletBeanRecord Mobile wallet bean with payload
     * @return Prepared HttpRequest
     */
    private static HttpRequest prepareHttpRequest(AOB_MobileWalletBean mobileWalletBeanRecord) {
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD_POST);
        httpRequest.setHeader(USER_AGENT, String.valueOf(mData.get(METADATA_WALLET_CLIENT)));
        httpRequest.setBody(JSON.serialize(mobileWalletBeanRecord));
        return httpRequest;
    }

    /**
     * @description Send HttpRequest and shape response
     * @param httpRequest Prepared HTTP request
     * @param applicationRecord Application__c record for logging
     * @return Response map
     */
    private static Map<String, Object> sendHttpRequest(HttpRequest httpRequest, Application__c applicationRecord) {
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Http http = new Http();
            setupMockIfTesting();

            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            if (statusCode != CMN_API_HttpBase.HTTP_OK) {
                return handleFailedResponse(statusCode, 'No Response From Server', applicationRecord);
            }

            String responseBody = httpResponse.getBody();
            if (String.isBlank(responseBody)) {
                return handleNoContentResponse();
            }

            responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            responseMap.put(KEY_STATUS, HTTP_STATUS_OK);
            return responseMap;
        } catch (Exception ex) {
            return handleException(ex, applicationRecord);
        }
    }

    /**
     * @description Sets up mock response if running in test context
     */
    private static void setupMockIfTesting() {
        if (Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
            AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
    }

    /**
     * @description Handles failed HTTP responses
     * @param statusCode HTTP status code
     * @param errorMessage Error message
     * @param applicationRecord Application__c for logging
     * @return Error response map
     */
    private static Map<String, Object> handleFailedResponse(Integer statusCode, String errorMessage, Application__c applicationRecord) {
        Map<String, Object> responseMap = new Map<String, Object>{
            KEY_STATUS => RESPONSE_STATUS_FAILED, 
            KEY_STATUS_CODE => statusCode, 
            KEY_ERROR_DESCRIPTION => errorMessage
        };
        LOGGER.error('AOB_MobileWallet.makeMobileWalletCallout ', new String[] {'AOB_MobileWallet.makeMobileWalletCallout', applicationRecord.Id, errorMessage});
        return responseMap;
    }

    /**
     * @description Handles no content responses
     * @return No content response map
     */
    private static Map<String, Object> handleNoContentResponse() {
        Map<String, Object> responseMap = new Map<String, Object>{
            KEY_STATUS => RESPONSE_STATUS_NO_CONTENT, 
            KEY_STATUS_CODE => HTTP_STATUS_NO_CONTENT, 
            KEY_ERROR_DESCRIPTION => 'No response body'
        };
        LOGGER.error('AOB_MobileWallet.makeMobileWalletCallout : No response body');
        return responseMap;
    }

    /**
     * @description Handles exceptions during callout
     * @param ex Exception caught
     * @param applicationRecord Application__c for logging
     * @return Error response map
     */
    private static Map<String, Object> handleException(Exception ex, Application__c applicationRecord) {
        LOGGER.error('AOB_MobileWallet.makeMobileWalletCallout: Exception ', new String[] {'AOB_MobileWallet.makeMobileWalletCallout', applicationRecord.Id}, ex);
        return new Map<String, Object>{
            KEY_STATUS => RESPONSE_STATUS_FAILED, 
            KEY_ERROR_DESCRIPTION => ex.getMessage(), 
            KEY_STATUS_CODE => HTTP_STATUS_INTERNAL_ERROR
        };
    }
}