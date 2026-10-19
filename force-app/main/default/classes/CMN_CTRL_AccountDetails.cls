/**
 * @description Controller Class for handling Account Details
 * @author Gnitsevich Anton, Kojzar Lukasz
 * @date September 2021
 */
public without sharing class CMN_CTRL_AccountDetails {

    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CTRL_AccountDetails');

    /**
     * @description This method retrieves listing of Identity Documents available in FileNet
     * @param accountId account Id
     * @return 
     */
    @AuraEnabled
    public static List<CMN_DTO_CustomerDocInfoResponse> getIdentityDocumentListing(Id accountId) {
        List<CMN_DTO_CustomerDocInfoResponse> documentListing = new List<CMN_DTO_CustomerDocInfoResponse>();
        try {
        Account account = CMN_DAL_Account.findById(accountId);
        	 documentListing = CMN_API_GetAccountDetails.getCustomerDocumentInfo(account.ExternalCIFUUID__c);
            
        }catch (Exception error) {
             LOGGER.fatal('CMN_CTRL_AccountDetails.updateAccountDetails' , error);
			 throw new AuraHandledException(error.getMessage());
        }
        
        return documentListing;
       
    }

    /**
     * @description This method gets data from external system and updates given Account
     * @param accountId account Id
     * @param getKycStatus indicates if callout for KYC Status is needed
     * @param getCustomerStatus indicates if callout for Customer Status is needed
     * @param getFinancialAccounts indicates if callout for Financial Accounts is needed
     */
    @AuraEnabled
    public static void updateAccountDetails(Id accountId, Boolean getKycStatus, Boolean getCustomerStatus , Boolean getFinancialAccounts) {
        // safeguard against nulls coming from lwc
        getKycStatus = getKycStatus == true;
        getCustomerStatus = getCustomerStatus == true;
        getFinancialAccounts = getFinancialAccounts == true;
        //
        Boolean doGetAnything = getKycStatus || getFinancialAccounts || getCustomerStatus;
        if (!doGetAnything) {
            return;
        }
        try {
            Account account = CMN_DAL_Account.findById(accountId);
            // callouts and DML ops
            Boolean updateAccount = false;
            CMN_DTO_AuthenticationResponse accessToken;
            if (getKycStatus || getCustomerStatus) {
                accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
            }
            if (getKycStatus) {
                String kycStatus = getKycStatus(account.ExternalCIFUUID__c, accessToken);
                if (String.isNotBlank(kycStatus)) {
                    account.FinServ__KYCStatus__c = kycStatus;
                    updateAccount = true;
                }
            }
            if (getCustomerStatus) {
                String customerStatus = getCustomerStatus(account.ExternalCIFUUID__c, accessToken);
                if (customerStatus != null) {
                    account.Customer_Status__c = customerStatus;
                    updateAccount = true;
                }
            }
            if (updateAccount) {
                update account;
            }

             // callouts and DML ops
            if (getFinancialAccounts) {
                CMN_CTRL_FinancialTransactions.getProductPortfolio(accountId);
            }
            
        } catch (Exception error) {
            LOGGER.fatal('CMN_CTRL_AccountDetails.updateAccountDetails' , error);
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description This method returns Customer Status for requested account Id
     * @param customerGuid customer GUID to identify Account in external system
     * @param accessToken token for callout authentication
     * @return String Customer Status
     */
    private static String getCustomerStatus(String customerGuid, CMN_DTO_AuthenticationResponse accessToken) {
        String customerStatus = '';
        CMN_DTO_CustomerStatusesResponse response =
                CMN_API_GetAccountDetails.getCustomerStatuses(customerGuid, accessToken.access_token);
        if (response != null) {
            for (CMN_DTO_CustomerStatusesResponse.CustomerStatus data : response.customerStatuses) {
                if (data.description != null) {
                    customerStatus += data.description + '\n';
                }
            }
            customerStatus = customerStatus.removeEnd('\n');
        } else {
            return null;
        }
        return customerStatus;
    }
    
    /**
     * @description This method returns KYC status for requested account Id
     * @param customerGuid customer GUID to identify Account in external system
     * @param accessToken token for callout authentication
     * @return String KYC Status
     */
    private static String getKYCStatus(String customerGuid, CMN_DTO_AuthenticationResponse accessToken) {
        String kycStatus;
        CMN_DTO_CustomerValidityInfoResponse response =
            CMN_API_GetAccountDetails.getCustomerValidityInfo(customerGuid, accessToken.access_token);
        if (response != null) {
            for (CMN_DTO_CustomerValidityInfoResponse.ComplianceData data : response.GetCustomerValidityInfoResponse.complianceData) {
                if (data.ComplianceType.description == 'KYC Requirements') {
                    kycStatus = data.ComplianceStatus.description;
                    break;
                }
            }
        }
        return kycStatus;
    }
}