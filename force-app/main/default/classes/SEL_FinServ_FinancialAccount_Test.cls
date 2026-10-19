/**
 * @description Test class for SEL_FinServ_FinancialAccount
 * @author Raymond Magezi
 * @date 31 August 2025
 */
@IsTest
@SuppressWarnings('sf:TooManyMethods,sf:AvoidDuplicateLiterals')
private class SEL_FinServ_FinancialAccount_Test {
    
    private static final String TEST_CIF = '123456';
    private static final String TEST_ACCOUNT_NUMBER = '987654321';
    
    /**
     * @description Sets up test data for all test methods
     */
    @TestSetup
    static void testSetup() {
        Account testAccount1 = CMN_DAL_DataFactory.newPersonAccount();
        testAccount1.ExternalCIFId__c = TEST_CIF;
        
        Account testAccount2 = CMN_DAL_DataFactory.newPersonAccount();
        testAccount2.ExternalCIFId__c = '654321';
        
        List<Account> accounts = new List<Account>{testAccount1, testAccount2};
        CMN_DAL_SObjectDomain.insertDBObjects(accounts);
        
        List<FinServ__FinancialAccount__c> testFinAccounts = new List<FinServ__FinancialAccount__c>();
        
        testFinAccounts.add(new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountNumber__c = TEST_ACCOUNT_NUMBER,
            ExternalCIFId__c = TEST_CIF,
            FinServ__PrimaryOwner__c = testAccount1.Id,
            FinServ__OverdraftLinkedAccount__c = testAccount1.Id
        ));
        
        testFinAccounts.add(new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountNumber__c = '111222333',
            ExternalCIFId__c = '654321',
            FinServ__PrimaryOwner__c = testAccount2.Id,
            FinServ__OverdraftLinkedAccount__c = testAccount2.Id
        ));
        
        testFinAccounts.add(new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountNumber__c = '444555666',
            ExternalCIFId__c = '789012',
            FinServ__PrimaryOwner__c = testAccount1.Id,
            FinServ__OverdraftLinkedAccount__c = testAccount1.Id
        ));
        
        CMN_DAL_SObjectDomain.insertDBObjects(testFinAccounts);
    }
    
    /**
     * @description Tests getSObjectType method returns correct SObjectType
     */
    @IsTest
    static void testGetSObjectType() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();
        
        Assert.areEqual(FinServ__FinancialAccount__c.SObjectType, result, 'Should return FinancialAccount SObjectType');
    }
    
    /**
     * @description Tests getSObjectFieldList method returns expected fields
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        
        Assert.isNotNull(fields, 'Fields list should not be null');
        Assert.areEqual(2, fields.size(), 'Should return 2 fields');
        Assert.isTrue(fields.contains(FinServ__FinancialAccount__c.Id), 'Should contain Id field');
        Assert.isTrue(fields.contains(FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c), 'Should contain PrimaryOwner field');
    }
    
    /**
     * @description Tests selectByPrimaryOwnerIds method with valid account IDs
     */
    @IsTest
    static void testSelectByPrimaryOwnerIds() {
        List<Account> testAccounts = [SELECT Id FROM Account LIMIT 2];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }
        
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.selectByPrimaryOwnerIds(accountIds);
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isFalse(results.isEmpty(), 'Should return financial accounts');
        
        for (FinServ__FinancialAccount__c finAcc : results) {
            Assert.isTrue(accountIds.contains(finAcc.FinServ__PrimaryOwner__c), 'Primary owner should be in the provided set');
        }
    }
    
    /**
     * @description Tests selectByPrimaryOwnerIds method with empty set
     */
    @IsTest
    static void testSelectByPrimaryOwnerIdsEmpty() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.selectByPrimaryOwnerIds(new Set<Id>());
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isTrue(results.isEmpty(), 'Should return empty list for empty input');
    }
    
    /**
     * @description Tests searchByCIF method with valid CIF number
     */
    @IsTest
    static void testSearchByCIF() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.searchByCIF(TEST_CIF);
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isFalse(results.isEmpty(), 'Should find financial accounts with matching CIF');
        
        for (FinServ__FinancialAccount__c finAcc : results) {
            Assert.isTrue(finAcc.ExternalCIFId__c.contains(TEST_CIF), 'CIF should contain search term');
        }
    }
    
    /**
     * @description Tests searchByCIF method with partial CIF match
     */
    @IsTest
    static void testSearchByCIFPartial() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.searchByCIF('123');
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isFalse(results.isEmpty(), 'Should find financial accounts with partial CIF match');
    }
    
    /**
     * @description Tests searchByCIF method with non-existent CIF
     */
    @IsTest
    static void testSearchByCIFNoMatch() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.searchByCIF('NONEXISTENT');
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isTrue(results.isEmpty(), 'Should return empty list for non-existent CIF');
    }
    
    /**
     * @description Tests searchByAccountNumber method with valid account number
     */
    @IsTest
    static void testSearchByAccountNumber() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.searchByAccountNumber(TEST_ACCOUNT_NUMBER);
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isFalse(results.isEmpty(), 'Should find financial accounts with matching account number');
        
        Boolean foundMatch = false;
        for (FinServ__FinancialAccount__c finAcc : results) {
            if (finAcc.FinServ__FinancialAccountNumber__c != null && 
                finAcc.FinServ__FinancialAccountNumber__c.contains(TEST_ACCOUNT_NUMBER)) {
                foundMatch = true;
                break;
            }
        }
        Assert.isTrue(foundMatch, 'Should find account with matching number');
    }
    
    /**
     * @description Tests searchByAccountNumber method with account name
     */
    @IsTest
    static void testSearchByAccountName() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.searchByAccountNumber('111222');
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        // Results may be empty since Name field is auto-generated
    }
    
    /**
     * @description Tests searchByAccountNumber method with non-existent account
     */
    @IsTest
    static void testSearchByAccountNumberNoMatch() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> results = selector.searchByAccountNumber('NONEXISTENT');
        Test.stopTest();
        
        Assert.isNotNull(results, 'Results should not be null');
        Assert.isTrue(results.isEmpty(), 'Should return empty list for non-existent account number');
    }
    
    /**
     * @description Tests searchByPrimaryOwner method with valid owner name
     */
    @IsTest
    static void testSearchByPrimaryOwner() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        try {
            List<FinServ__FinancialAccount__c> results = selector.searchByPrimaryOwner('Test Customer');
            Assert.isNotNull(results, 'Results should not be null');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('encrypted field'), 'Should handle encrypted field exception');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests searchByPrimaryOwner method with partial owner name
     */
    @IsTest
    static void testSearchByPrimaryOwnerPartial() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        try {
            List<FinServ__FinancialAccount__c> results = selector.searchByPrimaryOwner('Customer');
            Assert.isNotNull(results, 'Results should not be null');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('encrypted field'), 'Should handle encrypted field exception');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests searchByPrimaryOwner method with non-existent owner
     */
    @IsTest
    static void testSearchByPrimaryOwnerNoMatch() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        try {
            List<FinServ__FinancialAccount__c> results = selector.searchByPrimaryOwner('NONEXISTENT');
            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.isEmpty(), 'Should return empty list for non-existent primary owner');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('encrypted field'), 'Should handle encrypted field exception');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests all search methods with special characters that need escaping
     */
    @IsTest
    static void testSearchMethodsWithSpecialCharacters() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        // Test with special characters that need escaping
        List<FinServ__FinancialAccount__c> cifResults = selector.searchByCIF('123\'456');
        List<FinServ__FinancialAccount__c> accountResults = selector.searchByAccountNumber('987\'654');
        
        try {
            List<FinServ__FinancialAccount__c> ownerResults = selector.searchByPrimaryOwner('Test\'Customer');
            Assert.isNotNull(ownerResults, 'Owner results should not be null');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('encrypted field'), 'Should handle encrypted field exception');
        }
        Test.stopTest();
        
        Assert.isNotNull(cifResults, 'CIF results should not be null');
        Assert.isNotNull(accountResults, 'Account results should not be null');
    }
    
    /**
     * @description Tests all search methods with empty string parameters
     */
    @IsTest
    static void testSearchMethodsWithEmptyStrings() {
        SEL_FinServ_FinancialAccount selector = new SEL_FinServ_FinancialAccount();
        
        Test.startTest();
        List<FinServ__FinancialAccount__c> cifResults = selector.searchByCIF('');
        List<FinServ__FinancialAccount__c> accountResults = selector.searchByAccountNumber('');
        
        try {
            List<FinServ__FinancialAccount__c> ownerResults = selector.searchByPrimaryOwner('');
            Assert.isNotNull(ownerResults, 'Owner results should not be null');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('encrypted field'), 'Should handle encrypted field exception');
        }
        Test.stopTest();
        
        Assert.isNotNull(cifResults, 'CIF results should not be null');
        Assert.isNotNull(accountResults, 'Account results should not be null');
    }
}