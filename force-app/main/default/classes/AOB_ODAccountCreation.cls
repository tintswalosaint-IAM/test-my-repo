/***************************************************************************************
@ Author            : Amarnath Reddy (amarnath.reddy@standardbank.co.za)
@ Date              : June 2022
@ Name of the Class : AOB_ODAccountCreation
@ Description       : Class for handling Account Creation API calls, processing responses, and storing results in wrappers.
@ Last Modified By  : Jagadish Thummala.
@ Last Modified On  : 15/02/2024.
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_ODAccountCreation {

    // HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/create-account-retail/creation';

    // Used for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_ODAccountCreation'); 

    /**
     * @description Invokes the account creation process for a list of applications without a child application.
     * @param applicationList List of Application__c records.
     * @return JSON-serialized response map containing the result of the account creation.
     */
    public static String invokeAccountCreation(List<Application__c> applicationList) {
        return invokeAccountCreation(applicationList, null);
    }

    /**
     * @description Invokes the account creation process, handling both parent and child applications.
     *              Checks for existing accounts and invalid applications before proceeding.
     * @param applicationList List of Application__c records.
     * @param childApplication Optional child Application__c record.
     * @return JSON-serialized response map containing the result of the account creation.
     */
    public static String invokeAccountCreation(List<Application__c> applicationList, Application__c childApplication) {
        if (applicationList.isEmpty() || applicationList[0] == null) {
            return buildErrorResponse('Invalid application list');
        }

        Boolean isChildAcc = (childApplication != null && childApplication.AOB_Schema_Code__c == 'SBCHD');   
        Application__c app = new SEL_Application().selectAppById(applicationList[0].Id);
        Map<String, Object> responseMap = makeAccountCreationCallout(app, childApplication, isChildAcc);
        String accountNumber = (String)responseMap.get('accountNumber') ?? '';
        
        Id targetAppId = isChildAcc ? childApplication.Id : applicationList[0].Id;
        if (String.isBlank(accountNumber)) {
            Verification__c verificationInstance = new Verification__c(
                Application__c = targetAppId,
                Verification_Source__c = 'OD Account Create',
                AOB_DSX_Response__c = String.valueOf(responseMap),
                Verification_Status__c = 'Failed'
            );
            AOB_FlowController.createVerificationWithInstance(verificationInstance);
        } else {
            AOB_FlowController.createVerificationRecord(applicationList[0], 'OD Account Create', 'Success');
        }
    
        return JSON.serialize(responseMap);
    }

    /**
     * @description Builds a standardized error response as JSON.
     * @param errorDescription Description of the error.
     * @return JSON-serialized error response map.
     */
    private static String buildErrorResponse(String errorDescription) {
        Map<String, Object> responseMap = new Map<String, Object>{
            'status' => 'FAILED',
            'ErrorDescription' => errorDescription
        };
        return JSON.serialize(responseMap);
    }
    
    /**
     * @description Performs the HTTP callout for account creation and processes the response.
     * @param applicationRecord The parent Application__c record.
     * @param childApplication Optional child Application__c record.
     * @param isChildAcc Flag indicating if this is a child account.
     * @return Map containing the parsed response data.
     */
    public static Map<String, Object> makeAccountCreationCallout(Application__c applicationRecord, Application__c childApplication, Boolean isChildAcc) {
        AOB_ODAccountCreationBean accountCreationBeanRecord = createAccountCreationBean(applicationRecord, childApplication);
    
        // Prepare HTTP Request
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(accountCreationBeanRecord));
        system.debug('json body >>>>>>>>>>>>>>> '+JSON.serialize(accountCreationBeanRecord));
        Http http = new Http();
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        
        if (Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
            AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
        
        HttpResponse httpResponse = http.send(httpRequest);
        system.debug('response body >>>>>>>>>>>>>>> '+ httpResponse.getBody());
        if (httpResponse.getStatusCode() != CMN_API_HttpBase.HTTP_OK) {
            responseToReturnObject = handleFailedResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        } else {
            responseToReturnObject = handleSuccessfulResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        }
        
        return responseToReturnObject;
    }
    
    /**
     * @description Handles failed HTTP responses by extracting error details and logging.
     * @param httpResponse The HTTP response.
     * @param responseToReturnObject The response map to update.
     * @param applicationRecord The parent Application__c record.
     * @param childApplication Optional child Application__c record.
     * @param isChildAcc Flag indicating if this is a child account.
     * @return Updated response map with failure details.
     */
    public static Map<String, Object> handleFailedResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application__c applicationRecord, Application__c childApplication, Boolean isChildAcc) {
        String responseBody = httpResponse.getBody();
        String errorMessage = 'No Response From Server';
        String error = '';
        
        if (String.isNotBlank(responseBody)) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            errorMessage = (String) responseObject.get('moreInformation') ?? errorMessage;
            error = (String) responseObject.get('ErrorDescription') ?? '';
        }
        
        responseToReturnObject = new Map<String, Object>{
            'status' => 'FAILED',
            'statusCode' => httpResponse.getStatusCode(),
            'ErrorDescription' => errorMessage,
            'error' => error
        };
        
        LOGGER.error('AOB_ODAccountCreation.makeAccountCreationCallout: Failed response received', new String[]{errorMessage, (isChildAcc ? childApplication.Id : applicationRecord.Id)});
        return responseToReturnObject;
    }

    /**
     * @description Handles successful HTTP responses by parsing account details and checking for embedded errors.
     * @param httpResponse The HTTP response.
     * @param responseToReturnObject The response map to update.
     * @param applicationRecord The parent Application__c record.
     * @param childApplication Optional child Application__c record.
     * @param isChildAcc Flag indicating if this is a child account.
     * @return Updated response map with success details or fallback to failure if errors found.
     */
    public static Map<String, Object> handleSuccessfulResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application__c applicationRecord, Application__c childApplication, Boolean isChildAcc) {
        String responseBody = httpResponse.getBody();
        if (String.isBlank(responseBody)) {
            return handleFailedResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        }
        
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String errorMessage = (String) responseObject.get('ErrorDescription') ?? '';
        
        if (String.isNotBlank(errorMessage)) {
            return handleFailedResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        }
        
        if (!responseObject.containsKey('ODAccountAddRes')) {
            LOGGER.error('AOB_ODAccountCreation.makeAccountCreationCallout: Unexpected response format', new String[]{'AOB_ODAccountCreation.makeAccountCreationCallout', (isChildAcc ? childApplication.Id : applicationRecord.Id)});
            return handleFailedResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        }
    
        Map<String, Object> odAccountAddRes = (Map<String, Object>) responseObject.get('ODAccountAddRes');
        if (odAccountAddRes == null || !odAccountAddRes.containsKey('ODaccountNumber')) {
            LOGGER.error('AOB_ODAccountCreation.makeAccountCreationCallout: Unexpected response format', new String[]{'AOB_ODAccountCreation.makeAccountCreationCallout', (isChildAcc ? childApplication.Id : applicationRecord.Id)});
            return handleFailedResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        }
    
        Map<String, Object> odaccountNumber = (Map<String, Object>) odAccountAddRes.get('ODaccountNumber');
        if (odaccountNumber == null || !odaccountNumber.containsKey('accountNumber')) {
            LOGGER.error('AOB_ODAccountCreation.makeAccountCreationCallout: Unexpected response format', new String[]{'AOB_ODAccountCreation.makeAccountCreationCallout', (isChildAcc ? childApplication.Id : applicationRecord.Id)});
            return handleFailedResponse(httpResponse, responseToReturnObject, applicationRecord, childApplication, isChildAcc);
        }
        
        responseToReturnObject = new Map<String, Object>{
            'status' => 'SUCCESS',
            'accountNumber' => odaccountNumber.get('accountNumber')
        };
        return responseToReturnObject;
    }
    
    /**
     * @description Creates the ODAccountAddRqInfo object populated with data from the application.
     * @param applicationRecord The parent Application__c record.
     * @param childApplication Optional child Application__c record.
     * @param mData Map of metadata values.
     * @return Populated ODAccountAddRqInfo instance.
     */
    public static AOB_ODAccountCreationBean.ODAccountAddRqInfo createAccountAddRq(Application__c applicationRecord, Application__c childApplication, Map<String, Object> mData) {
        Boolean isChildAcc = (childApplication != null && childApplication.AOB_Schema_Code__c == 'SBCHD');

        AOB_ODAccountCreationBean.AccountTypeInfo accountType = new AOB_ODAccountCreationBean.AccountTypeInfo();
        accountType.schemaCode = isChildAcc ? childApplication.AOB_Schema_Code__c ?? '' : applicationRecord.AOB_Schema_Code__c ?? ''; 
        
        AOB_ODAccountCreationBean.bankInformation bankInfo = new AOB_ODAccountCreationBean.bankInformation();
        bankInfo.bankId = applicationRecord.AOB_Nationality__c ?? ''; 
        bankInfo.branchId = applicationRecord.AOB_Preferred_Branch__c ?? '';
    
        AOB_ODAccountCreationBean.ODAcctGeneralInformation acctGeneralInfo = new AOB_ODAccountCreationBean.ODAcctGeneralInformation();
        acctGeneralInfo.despatchMode = String.valueOf(mData.get('acctGeneralInfo.despatchMode')) ?? '';
    
        AOB_ODAccountCreationBean.accountLimitsInfo accountLimits = new AOB_ODAccountCreationBean.accountLimitsInfo();
        accountLimits.expiryDate = String.valueOf(mData.get('accountLimits.expiryDate')) ?? '';
        accountLimits.documentDate = String.valueOf(mData.get('accountLimits.documentDate')) ?? '';
        accountLimits.drawingPowerIndicator = String.valueOf(mData.get('accountLimits.drawingPowerIndicator')) ?? '';
    
        AOB_ODAccountCreationBean.ODAccountAddRqInfo accountAddRq = new AOB_ODAccountCreationBean.ODAccountAddRqInfo();
        accountAddRq.customerNumber = isChildAcc ? childApplication.AOB_Customer_Id__c ?? '' : applicationRecord.AOB_Customer_Id__c ?? '';
        accountAddRq.accountType = accountType;
        accountAddRq.accountCurrency = applicationRecord.AOB_Selected_Currency__c ?? ''; 
        accountAddRq.bankInfo = bankInfo;
        accountAddRq.ODAcctGeneralInfo = acctGeneralInfo;
        accountAddRq.accountLimits = accountLimits;
        accountAddRq.localCalculationFlag = String.valueOf(mData.get('accountAddRq.localCalculationFlag')) ?? '';
    
        return accountAddRq;
    }

    /**
     * @description Creates the ODaccountAddCustomDataInfo object populated with data from the application.
     * @param applicationRecord The parent Application__c record.
     * @param childApplication Optional child Application__c record.
     * @param mData Map of metadata values.
     * @return Populated ODaccountAddCustomDataInfo instance.
     */
    public static AOB_ODAccountCreationBean.ODaccountAddCustomDataInfo createAccountAddCustomData(Application__c applicationRecord, Application__c childApplication, Map<String, Object> mData) {
        Boolean isChildAcc = (childApplication != null && childApplication.AOB_Schema_Code__c == 'SBCHD');

        AOB_ODAccountCreationBean.ODaccountAddCustomDataInfo accountAddCustomData = new AOB_ODAccountCreationBean.ODaccountAddCustomDataInfo();
        accountAddCustomData.missEntered = String.valueOf(mData.get('accountAddCustomData.missEntered')) ?? '';
        accountAddCustomData.pricingCode = isChildAcc ? childApplication.AOB_Pricing_Option__c ?? '' : applicationRecord.AOB_Pricing_Option__c ?? '';
        accountAddCustomData.PHCode = String.valueOf(mData.get('accountAddCustomData.PHCode')) ?? '';
        accountAddCustomData.EFTFlag = String.valueOf(mData.get('accountAddCustomData.EFTFlag')) ?? '';
        accountAddCustomData.WPBFlag = String.valueOf(mData.get('accountAddCustomData.WPBFlag')) ?? '';
        accountAddCustomData.INTCRAccountFlag = String.valueOf(mData.get('accountAddCustomData.INTCRAccountFlag')) ?? '';
        accountAddCustomData.INTDRAccountFlag = String.valueOf(mData.get('accountAddCustomData.INTDRAccountFlag')) ?? '';
        accountAddCustomData.selfPrintChequeBook = String.valueOf(mData.get('accountAddCustomData.selfPrintChequeBook')) ?? '';
        accountAddCustomData.channelID = String.valueOf(mData.get('accountAddCustomData.channelID')) ?? '';
        accountAddCustomData.PFNum = String.valueOf(mData.get('accountAddCustomData.PFNum')) ?? ''; 
        accountAddCustomData.applicationHealthCode = String.valueOf(mData.get('accountAddCustomData.applicationHealthCode')) ?? '';
    
        Boolean isMobileMoneySelected = (applicationRecord.AOB_Mode_Of_Payment__c == 'Mobile Money');
        accountAddCustomData.alternativeInstitutionName = isMobileMoneySelected ? applicationRecord.AOB_Operator_Name__c ?? '' : applicationRecord.AOB_Name_Of_Bank__c ?? ''; 
        accountAddCustomData.alternativeAccountName = applicationRecord.AOB_Alternative_Account_Name__c ?? '';
        accountAddCustomData.alternativeAccountNumber = isMobileMoneySelected ? applicationRecord.AOB_Mobile_Money_Number__c ?? '' : applicationRecord.AOB_Alternative_Account_Number__c ?? '';
        accountAddCustomData.DepositCurrency = applicationRecord.AOB_Selected_Currency__c ?? '';
    
        if (applicationRecord.WI_ClientType__c != 'Staff Assist') {
            Map<String, PPB_TransactionLimit__mdt> limits = new Map<String, PPB_TransactionLimit__mdt>();
            for (PPB_TransactionLimit__mdt limitRecord : [SELECT Label, limit__c FROM PPB_TransactionLimit__mdt WHERE Label IN ('UGX limit', 'USD limit') WITH USER_MODE]) {
                limits.put(limitRecord.Label, limitRecord);
            }
            String selectedCurrency = applicationRecord.AOB_Selected_Currency__c ?? 'UGX';
            Decimal limitValue = limits.get(selectedCurrency + ' limit')?.limit__c ?? 0;
            accountAddCustomData.DepositAmountLimitValue = String.valueOf(limitValue);
            accountAddCustomData.TransferAmountLimitValue = String.valueOf(limitValue);
        }
    
        accountAddCustomData.TransferAmountCurrency = applicationRecord.AOB_Selected_Currency__c ?? '';
    
        return accountAddCustomData;
    }

    /**
     * @description Creates and populates the AOB_ODAccountCreationBean for the API request.
     * @param applicationRecord The parent Application__c record.
     * @param childApplication Optional child Application__c record.
     * @return Populated AOB_ODAccountCreationBean instance.
     */
    public static AOB_ODAccountCreationBean createAccountCreationBean(Application__c applicationRecord, Application__c childApplication) {
        Map<String, Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_ODAccountCreation');
        AOB_ODAccountCreationBean accountCreationBeanRecord = new AOB_ODAccountCreationBean();
    
        AOB_ODAccountCreationBean.ODAccountAddRqInfo accountAddRq = createAccountAddRq(applicationRecord, childApplication, mData);
        AOB_ODAccountCreationBean.ODaccountAddCustomDataInfo accountAddCustomData = createAccountAddCustomData(applicationRecord, childApplication, mData);
    
        accountCreationBeanRecord.ODAccountAddRq = accountAddRq;
        accountCreationBeanRecord.ODAccountAddCustomData = accountAddCustomData;
        
        return accountCreationBeanRecord;
    }
}