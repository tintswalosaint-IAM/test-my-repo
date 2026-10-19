/**
* @description Test Class for CMN_CTRL_AccountDetails class
*
* @author Gnitsevich Anton
*
* @date October 2021
*/
@IsTest
public with sharing class CMN_CTRL_AccountDetails_TEST {
    private static final Id ACCOUNT_RECORDTYPE_PERSON =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    @IsTest
    private static void testKYCStatusRequest() {
        Boolean getKycStatus = true;
        Boolean getCustomerStatus = false;
        Boolean getFinancialAccounts = false;
 
        // create account
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        insert acc;

        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, FinServ__KYCStatus__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('In progress', updatedAcc.FinServ__KYCStatus__c, 'KYC Status value should be returned');
    }

    @IsTest
    private static void testKYCStatusErrorRequest() {
        Boolean getKycStatus = true;
        Boolean getCustomerStatus = false;
        Boolean getFinancialAccounts = false;
      
        // create account
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        insert acc;

        CMN_API_GetAccountDetails.mockValidityInfoErrorResponse = true;
        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, FinServ__KYCStatus__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(null, updatedAcc.FinServ__KYCStatus__c, 'KYC Status value should be blank');
    }

    @IsTest
    private static void testKYCStatusBadRequest() {
        Boolean getKycStatus = true;
        Boolean getCustomerStatus = false;
        Boolean getFinancialAccounts = false;
      
        // create account
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        insert acc;

        CMN_API_GetAccountDetails.mockValidityInfoBadResponse = true;
        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, FinServ__KYCStatus__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(null, updatedAcc.FinServ__KYCStatus__c, 'KYC Status value should be blank');
    }

    @IsTest
    private static void testCustomerStatusRequest() {
        Boolean getKycStatus = false;
        Boolean getCustomerStatus = true;
        Boolean getFinancialAccounts = false;
       
        // create account
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        insert acc;

        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Customer_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('IN COLLECTIONS' + '\n' + 'SARB BP DATA NOT COMPLIANT' + '\n' + 'IMPORTANT CUSTOMER', updatedAcc.Customer_Status__c, 'Incorrect Customer Status retrieved');
    }

    @IsTest
    private static void testCustomerStatusErrorRequest() {
        Boolean getKycStatus = false;
        Boolean getCustomerStatus = true;
        Boolean getFinancialAccounts = false;

        // create account
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        insert acc;

        CMN_API_GetAccountDetails.mockCustomerStatusErrorResponse = true;

        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Customer_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(null, updatedAcc.Customer_Status__c, 'Customer Status should be blank');
    }

    @IsTest
    private static void testCustomerStatusEmptyRequest() {
        Boolean getKycStatus = false;
        Boolean getCustomerStatus = true;
        Boolean getFinancialAccounts = false;

        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        acc.Customer_Status__c = 'test';
        insert acc;

        CMN_API_GetAccountDetails.mockCustomerStatusEmptyResponse = true;

        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Customer_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(null, updatedAcc.Customer_Status__c, 'Customer Status should be blank');
    }

    @IsTest
    private static void testCustomerStatusBadRequest() {
        Boolean getKycStatus = false;
        Boolean getCustomerStatus = true;
        Boolean getFinancialAccounts = false;

        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        acc.Customer_Status__c = 'test';
        insert acc;

        CMN_API_GetAccountDetails.mockCustomerStatusBadResponse = true;

        Test.startTest();
        CMN_CTRL_AccountDetails.updateAccountDetails(acc.Id, getKYCStatus, getCustomerStatus,getFinancialAccounts);
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Customer_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('test', updatedAcc.Customer_Status__c, 'Customer Status should equal \'test\'');
    }

    @IsTest
    private static void testIdentityDocumentListing() {
        // create account
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';
        insert acc;

        Test.startTest();
        List<CMN_DTO_CustomerDocInfoResponse> documentListing = CMN_CTRL_AccountDetails.getIdentityDocumentListing(acc.Id);
        Test.stopTest();
        
        
        Assert.areNotEqual('', documentListing[0].docCategoryDesc, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docCategoryCode, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].cnttId, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docTitle, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docType, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docTypeName, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docContentType, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docContentTypeName, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].createdDt, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].docContLastUpdateDt, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].creationUserID, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].lastChangeUserID, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].path, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].language, 'Details for at least one Identity Document should be returned');
        Assert.areNotEqual(null, documentListing[0].additionalDoc, 'Details for at least one Identity Document should be returned');
    }
}