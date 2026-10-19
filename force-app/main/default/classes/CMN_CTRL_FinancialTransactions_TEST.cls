/**
 * @description Test Class for CMN_CTRL_FinancialTransactions Class
 * @author Eduardo Salia
 * @date July 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56261, SFP-56274
 * @LastModifiedReason: API Code Remediation and Indentation
 */
@IsTest(SeeAllData=false)
public class CMN_CTRL_FinancialTransactions_TEST {
    private static Account testAccount;
    private static FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();

    @TestSetup
    private static void setup() {
        Map<String, Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName();

        testAccount = new Account();

        testAccount.RecordTypeId = recordTypes.get('PersonAccount').getRecordTypeId();
        testAccount.FirstName = 'Test';
        testAccount.LastName = 'Account';
        testAccount.ExternalCIFUUID__c = 'Test_1';
        testAccount.ExternalCIFId__c = 'Test_2';
        testAccount.AccountNumber = 'Test_3';
        testAccount.ExternalCIFCountry__c = 'ZA';
        testAccount.CMN_BPGUID__pc = 'Test_BPGUID';
        insert testAccount;

        financialAccount.FinServ__PrimaryOwner__c = testAccount.Id;
        financialAccount.FinServ__FinancialAccountNumber__c = '12123213';
        financialAccount.Name = 'testname';
        financialAccount.FinServ__FinancialAccountType__c = 'testtype';
        financialAccount.FinServ__Status__c = 'teststat';
        insert financialAccount;
    }

    // ─── CMN_API_GetFinancialTransactions ────────────────────────────────────

    @isTest
    private static void testGetLatestTransactions() {
        FinServ__FinancialAccount__c testFinancialAccount = [
            SELECT Id, FinServ__FinancialAccountNumber__c, FinServ__PrimaryOwner__c
            FROM FinServ__FinancialAccount__c
            LIMIT 1
        ];

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetFinancialTransactions.FinancialTransactionsMockResponse());
        
        Test.startTest();
        CMN_DTO_FinancialTransactionsResponse responseObject = new CMN_API_GetFinancialTransactions()
            .getLatestTransactions(testFinancialAccount.Id);
        Test.stopTest();

        Assert.isNotNull(responseObject);
        Assert.isNotNull(responseObject.response);
        Assert.isNotNull(responseObject.response.cifSystemIdentificationNumber);
        Assert.isNotNull(responseObject.response.uniqueTransactionIdentificationNumber);
        Assert.isNotNull(responseObject.response.cifCountry);
        Assert.isTrue(responseObject.response.transactions.size() == 2, 'Two transactions should be returned');
        Assert.isTrue(responseObject.response.transactions[0].transactionType == 'Deposit', 'First transaction type should be Deposit');
        Assert.isTrue(responseObject.response.transactions[0].description == 'STATEMENT COSTS 000000450 POSTED STMT FEE 0216', 'First transaction description should match expected');

        if (responseObject.response.routingInformation != null) {
            Assert.isTrue(responseObject.response.routingInformation.size() == 1, 'One routing information record should be returned');
            Assert.isTrue(responseObject.response.routingInformation[0].applicationIdentificationNumber == '007', 'Application identification number should be 007');
            Assert.isTrue(responseObject.response.routingInformation[0].systemIdentificationNumber == '007', 'System identification number should be 007');
        }
    }

    @isTest
    private static void testGetLatestFinancialTransactions() {
        FinServ__FinancialAccount__c testFinancialAccount = [
            SELECT Id, FinServ__FinancialAccountNumber__c, FinServ__PrimaryOwner__c
            FROM FinServ__FinancialAccount__c
            LIMIT 1
        ];

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetFinancialTransactions.FinancialTransactionsMockResponse());
        Test.startTest();
        CMN_DTO_FinancialTransactionsResponse responseObject = CMN_CTRL_FinancialTransactions.getLatestFinancialTransactions(
            testFinancialAccount.Id
        );
        Test.stopTest();

        Assert.isNotNull(responseObject);
        Assert.isNotNull(responseObject.response);
    }

    @isTest
    private static void testGetLatestTransactionsNullFinancialAccount() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        // Passing an Account Id to a method expecting a FinancialAccount Id
        // exercises the null-guard path (no callout made)
        CMN_DTO_FinancialTransactionsResponse responseObject = new CMN_API_GetFinancialTransactions()
            .getLatestTransactions(testAcc.Id);
        Test.stopTest();

        Assert.isNull(responseObject, 'Response should be null when financial account is not found');
    }

    @isTest
    private static void testGetFormattedDateString() {
        Test.startTest();
        String startDate = CMN_API_GetFinancialTransactions.getFormattedDateString(true);
        String endDate = CMN_API_GetFinancialTransactions.getFormattedDateString(false);
        Test.stopTest();

        Assert.isNotNull(startDate);
        Assert.isNotNull(endDate);
        // Verify format YYYY-MM-DD
        Assert.isTrue(startDate.length() == 10, 'Start date should be in YYYY-MM-DD format');
        Assert.isTrue(endDate.length() == 10, 'End date should be in YYYY-MM-DD format');
        Assert.isTrue(startDate < endDate, 'Start date should be before end date');
    }

    // ─── CMN_API_GetAccountBalances ──────────────────────────────────────────

    @isTest
    private static void testGetAccountBalances() {
        FinServ__FinancialAccount__c testFinancialAccount = [
            SELECT Id, FinServ__FinancialAccountNumber__c, FinServ__PrimaryOwner__c
            FROM FinServ__FinancialAccount__c
            LIMIT 1
        ];

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetAccountBalances.AccountBalancesMockResponse());
        
        Test.startTest();
        CMN_DTO_AccountBalancesResponse responseObject = new CMN_API_GetAccountBalances()
            .getBalances(testFinancialAccount.Id);
        Test.stopTest();

        Assert.isNotNull(responseObject);
        Assert.isNotNull(responseObject.response);
        Assert.isNotNull(responseObject.response.cifSystemIdentificationNumber);
        Assert.isNotNull(responseObject.response.uniqueTransactionIdentificationNumber);
        Assert.isNotNull(responseObject.response.cifCountry);
        Assert.isTrue(responseObject.response.balances.size() == 2, 'Two balances should be returned');
        Assert.isTrue(responseObject.response.balances[0].accountNo == '12123213', 'First account number should be 12123213');
        Assert.isTrue(responseObject.response.balances[0].balanceType == 'Available Balance', 'First balance type should be Available Balance');
        Assert.isTrue(responseObject.response.balances[1].balanceType == 'Actual  Balance', 'Second balance type should be Actual Balance');

        if (responseObject.response.routingInformation != null) {
            Assert.isTrue(responseObject.response.routingInformation.size() == 1, 'One routing information record should be returned');
            Assert.isTrue(responseObject.response.routingInformation[0].applicationIdentificationNumber == '007', 'Application identification number should be 007');
            Assert.isTrue(responseObject.response.routingInformation[0].systemIdentificationNumber == '007', 'System identification number should be 007');
        }
    }

    @isTest
    private static void testGetLatestAccountBalances() {
        Account testAcc = [
            SELECT Id, ExternalCIFUUID__c, ExternalCIFId__c, ExternalCIFCountry__c, AccountNumber
            FROM Account
            LIMIT 1
        ];

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetAccountBalances.AccountBalancesMockResponse());
        
        Test.startTest();
        CMN_DTO_AccountBalancesResponse responseObject = CMN_CTRL_FinancialTransactions.getLatestAccountBalances(
            testAcc.Id
        );
        Test.stopTest();

        Assert.isNotNull(responseObject);
        Assert.isNotNull(responseObject.response);

        FinServ__FinancialAccount__c updatedFinancialAccount = [
            SELECT Id, FinServ__Balance__c
            FROM FinServ__FinancialAccount__c
            WHERE FinServ__PrimaryOwner__c = :testAcc.Id
            LIMIT 1
        ];

        Assert.isTrue(updatedFinancialAccount.FinServ__Balance__c == Decimal.valueOf('123213213'), 'Updated balance should match expected value');
    }

    @isTest
    private static void testGetBalancesWithAccountRecordId() {
        // Covers the Account branch in getBalances (objectName == CMN_DAL_Account.OBJECT_NAME)
        Account testAcc = [SELECT Id FROM Account LIMIT 1];

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetAccountBalances.AccountBalancesMockResponse());
        
        Test.startTest();
        CMN_DTO_AccountBalancesResponse responseObject = new CMN_API_GetAccountBalances().getBalances(testAcc.Id);
        Test.stopTest();

        Assert.isNotNull(responseObject, 'Response should not be null for Account record Id');
        Assert.isNotNull(responseObject.response);
    }

    // ─── getProductPortfolio ─────────────────────────────────────────────────

    @isTest
    private static void testGetProductPortfolio() {
        Account testAcc = [
            SELECT Id, ExternalCIFUUID__c, ExternalCIFId__c, ExternalCIFCountry__c, AccountNumber
            FROM Account
            LIMIT 1
        ];

        FinServ__FinancialAccount__c orphanFinancialAccount = new FinServ__FinancialAccount__c(
            FinServ__PrimaryOwner__c = testAcc.Id,
            FinServ__FinancialAccountNumber__c = '99999999',
            Name = 'to-be-deleted',
            FinServ__FinancialAccountType__c = 'legacy',
            FinServ__Status__c = 'CLOSED'
        );
        insert orphanFinancialAccount;

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetProductPortfolio.ProductPortfolioMockResponse());
        
        Test.startTest();
        List<Id> createdAccountIds = CMN_CTRL_FinancialTransactions.getProductPortfolio(testAcc.Id);
        Test.stopTest();

        List<FinServ__FinancialAccount__c> financialAccounts = [
            SELECT Id, FinServ__FinancialAccountNumber__c, Name, FinServ__FinancialAccountType__c, FinServ__Status__c
            FROM FinServ__FinancialAccount__c
            WHERE FinServ__PrimaryOwner__c = :testAcc.Id
            ORDER BY FinServ__FinancialAccountNumber__c
        ];

        Assert.isTrue(financialAccounts.size() == 2, 'Expected two financial accounts after refresh');
        Assert.isTrue(createdAccountIds.size() == 2, 'Expected returned IDs to match persisted accounts');
        Assert.isTrue(financialAccounts[0].FinServ__FinancialAccountNumber__c == '12123213', 'First financial account number should match expected');
        Assert.isTrue(financialAccounts[0].Name == 'RETAIL WHOLESALE CALL DEPOSIT', 'First financial account name should match expected');
        Assert.isTrue(financialAccounts[0].FinServ__FinancialAccountType__c == 'INVESTMENT', 'First financial account type should match expected');
        Assert.isTrue(financialAccounts[0].FinServ__Status__c == 'Open', 'First financial account status should match expected');
        Assert.isTrue(financialAccounts[1].FinServ__FinancialAccountNumber__c == '333123', 'Second financial account number should match expected');

        List<FinServ__FinancialAccount__c> orphanRecords = [
            SELECT Id
            FROM FinServ__FinancialAccount__c
            WHERE Id = :orphanFinancialAccount.Id
        ];
        Assert.isTrue(orphanRecords.isEmpty(), 'Orphan financial account should be deleted');
    }
}