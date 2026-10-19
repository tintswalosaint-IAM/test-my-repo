/**
 * @description Controller Class for Handling Financial Transactions API from Finacle via ESB Middleware
 * @author Eduardo Salia
 * @date July 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56261, SFP-56272, SFP-56274
 * @LastModifiedReason: API Code Remediation and Indentation
 */
public with sharing class CMN_CTRL_FinancialTransactions {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_CTRL_FinancialTransactions');
    /**
     * @description This method handles All Financial Transaction related operations
     *
     * @param recordId Id of our current record on the LWC Component
     *
     * @return CMN_DTO_FinancialTransactionsResponse responseObject
     */
    
    @AuraEnabled
    public static CMN_DTO_FinancialTransactionsResponse getLatestFinancialTransactions(String recordId) {
        try {
            return new CMN_API_GetFinancialTransactions().getLatestTransactions(recordId);
        } catch (Exception error) {
            LOGGER.error('CMN_CTRL_FinancialTransactions.getLatestFinancialTransactions', error);
            throw new AuraHandledException(error.getMessage() + ' | ' + error.getStackTraceString());
        }
    }

    /**
     * @description This method handles All Financial Transaction related operations
     *
     * @param recordId Id of our current record on the LWC Component
     *
     * @return CMN_DTO_AccountBalancesResponse responseObject
     */
    @AuraEnabled
    public static CMN_DTO_AccountBalancesResponse getLatestAccountBalances(String recordId) {
        try {
            CMN_DTO_AccountBalancesResponse response = new CMN_API_GetAccountBalances().getBalances(recordId);
            try {
                extractAndUpdateAccountBalances(response);
            } catch (Exception error) {
                LOGGER.error(error.getMessage(), error);
            }
            return response;
        } catch (Exception error) {
            LOGGER.error('CMN_CTRL_FinancialTransactions.getLatestAccountBalances', error);
            throw new AuraHandledException(error.getMessage() + ' | ' + error.getStackTraceString());
        }
    }

    /**
     * @description This method retrieves Product Portfolio for a specific client
     *
     * @param accountId Id of our current record on the LWC Component
     *
     * @return List<Id> Id's of new financial accounts
     *
     */
    @AuraEnabled
    public static List<Id> getProductPortfolio(String accountId) {
        List<Id> accountIds = new List<Id>();
        try {
            CMN_DTO_ProductPortfolioResponse response = new CMN_API_GetProductPortfolio()
                .getProductPortfolio(accountId);
            if (response != null) {
                accountIds = new List<Id>(refreshFinancialAccounts(response, accountId));
            }
            return accountIds;
        } catch (Exception error) {
            LOGGER.error('CMN_CTRL_FinancialTransactions.getProductPortfolio', error);
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description This method creates Financial Accounts for Product Portfolio for a specific client
     *
     * @param response This is our CMN_DTO_ProductPortfolioResponse variable
     * @param accountId This is our Record Id
     *
     * @return Set<Id> Id's of new financial accounts
     */
    private static Set<Id> refreshFinancialAccounts(CMN_DTO_ProductPortfolioResponse response, String accountId) {
        List<FinServ__FinancialAccount__c> createFinancialAccounts = new List<FinServ__FinancialAccount__c>();
        List<FinServ__FinancialAccount__c> updateFinancialAccounts = new List<FinServ__FinancialAccount__c>();
        // get existing financial accounts, prepare map by account number
        List<FinServ__FinancialAccount__c> existingFinancialAccounts = [
            SELECT Id, Name, FinServ__FinancialAccountNumber__c, FinServ__FinancialAccountType__c, FinServ__Status__c
            FROM FinServ__FinancialAccount__c
            WHERE FinServ__PrimaryOwner__c = :accountId
        ];
        // prepare financial accounts
        RecordType recordType = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'BankingAccount'
        ];
        for (CMN_DTO_ProductPortfolio portfolio : response.accountProductDetails) {
            Integer index = findAccountIndex(existingFinancialAccounts, portfolio.accountNumber);
            if (index == null) {
                FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
                financialAccount.RecordTypeId = recordType.Id;
                financialAccount.FinServ__PrimaryOwner__c = accountId;
                financialAccount.FinServ__FinancialAccountNumber__c = portfolio.accountNumber;
                financialAccount.Name = portfolio.productName;
                financialAccount.FinServ__FinancialAccountType__c = portfolio.accountType;
                financialAccount.FinServ__Status__c = portfolio.accountStatus;
                financialAccount.FinServ__Country__c = 'South Africa';
                financialAccount.ExternalCIFCountry__c = 'ZA';
                financialAccount.ExternalIdentifier__c = 'ZA01' + portfolio.accountNumber;
                financialAccount.CurrencyIsoCode = 'ZAR';
                createFinancialAccounts.add(financialAccount);
            } else {
                FinServ__FinancialAccount__c existingFinancialAccount = existingFinancialAccounts.get(index);
                Boolean doUpdateAccount = false;
                if (existingFinancialAccount.Name != portfolio.productName) {
                    existingFinancialAccount.Name = portfolio.productName;
                    doUpdateAccount = true;
                }
                if (existingFinancialAccount.FinServ__FinancialAccountType__c != portfolio.accountType) {
                    existingFinancialAccount.FinServ__FinancialAccountType__c = portfolio.accountType;
                    doUpdateAccount = true;
                }
                if (existingFinancialAccount.FinServ__Status__c != portfolio.accountStatus) {
                    existingFinancialAccount.FinServ__Status__c = portfolio.accountStatus;
                    doUpdateAccount = true;
                }
                if (doUpdateAccount) {
                    updateFinancialAccounts.add(existingFinancialAccount);
                }
                existingFinancialAccounts.remove(index);
            }
        }
        // insert financial accounts
        if (!createFinancialAccounts.isEmpty()) {
            insert createFinancialAccounts;
        }
        // update financial accounts
        if (!updateFinancialAccounts.isEmpty()) {
            update updateFinancialAccounts;
        }
        // remove existing accounts that were not returned from API
        if (!existingFinancialAccounts.isEmpty()) {
            delete existingFinancialAccounts;
        }
        //
        List<FinServ__FinancialAccount__c> financialAccounts = [
            SELECT Id
            FROM FinServ__FinancialAccount__c
            WHERE FinServ__PrimaryOwner__c = :accountId
        ];
        Map<Id, FinServ__FinancialAccount__c> financialAccountsMap = new Map<Id, FinServ__FinancialAccount__c>(
            financialAccounts
        );
        return financialAccountsMap.keySet();
    }

    /**
     * @description Searches for a Financial Account by its number
     * @param financialAccounts List of Financial Account records
     * @param accountNumber Financial Account number
     * @return Integer index
     */
    private static Integer findAccountIndex(
        List<FinServ__FinancialAccount__c> financialAccounts,
        String accountNumber
    ) {
        for (Integer i = 0; i < financialAccounts.size(); i++) {
            FinServ__FinancialAccount__c financialAccount = financialAccounts[i];
            if (financialAccount.FinServ__FinancialAccountNumber__c == accountNumber) {
                return i;
            }
        }
        return null;
    }

    /**
     * @description This method extracts Account Numbers and updates Balances
     *
     * @param accountBalances this is our wrapper class param
     */
    public static void extractAndUpdateAccountBalances(CMN_DTO_AccountBalancesResponse accountBalances) {
        if (accountBalances != null && accountBalances.response != null && accountBalances.response.balances != null) {
            Map<String, String> accountNumberToBalanceAmountMap = new Map<String, String>();
            for (CMN_DTO_BalanceInformation balance : accountBalances.response.balances) {
                if (String.isNotBlank(balance.accountNo)) {
                    accountNumberToBalanceAmountMap.put(balance.accountNo.trim(), balance.balanceAmount);
                }
            }

            if (accountNumberToBalanceAmountMap != null) {
                updateAccountBalances(accountNumberToBalanceAmountMap);
            }
        }
    }

    /**
     * @description This method updates Financial Account Balances
     *
     * @param accountNumberToBalanceAmountMap this is our Map<String,String> with Account Number Key and Balance Amount Value
     */
    public static void updateAccountBalances(Map<String, String> accountNumberToBalanceAmountMap) {
        List<FinServ__FinancialAccount__c> financialAccounts = CMN_DAL_FinancialAccount.getByAccountNumbers(
            accountNumberToBalanceAmountMap.KeySet()
        );
        if (financialAccounts != null && !financialAccounts.isEmpty()) {
            List<FinServ__FinancialAccount__c> financialAccountsToUpdate = new List<FinServ__FinancialAccount__c>();
            for (FinServ__FinancialAccount__c financialAccount : financialAccounts) {
                String balanceAmount = accountNumberToBalanceAmountMap.get(
                    financialAccount.FinServ__FinancialAccountNumber__c
                );
                if (String.isNotBlank(balanceAmount) && balanceAmount.isNumeric()) {
                    financialAccount.FinServ__Balance__c = Decimal.valueOf(balanceAmount);
                    financialAccountsToUpdate.add(financialAccount);
                }
            }

            if (financialAccountsToUpdate != null && !financialAccountsToUpdate.isEmpty()) {
                update financialAccountsToUpdate;
            }
        }
    }
}