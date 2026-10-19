/**
 * @description       : Class for Selector Class for Account Entity Test class
 *@Name of the Class: SEL_Account_Test.cls
 * @Story: SFP-36390
 * @date May 2022
 * @last modified on: 29-02-2024
 * @last modified by: Ikyatha Naidu
 * @ Modification Description: SFP-36390, used new field signing arrangement SBO-UK
 *
 * @ Modification Description : SFP-55759, Increased the code coverage for SEL_Account Class
 * @Last Modified on: 15-07-2026
 * @Last modified on: Amlendu Bajpai
 */

@IsTest
@SuppressWarnings('PMD.TooManyMethods, PMD.UseCollectionIsEmpty, PMD.AvoidDuplicateLiterals')
private class SEL_Account_Test {
    /**
     * @description: Setup test data for Account and Person Account records
     */
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(
            Name = 'Test Account',
            ExternalIdentifier__c = 'CM9045678900EQ'
        );
        insert testAccount;
        Date dateOfBirth = Date.newInstance(1990, 5, 15);
        Account testPersonAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonBirthdate = dateOfBirth
        );
        insert testPersonAccount;
    }
    /**
     * @description: Verify that the SObjectType is returned correctly
     * User Story : SFP-58522
     */
    @IsTest
    static void testGetSObjectType() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        Schema.SObjectType sObjectType = accountSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Account.SObjectType, sObjectType, 'The returned SObjectType does not match Account.SObjectType');
    }
    /**
     * @description: Verify that the list of SObject fields is returned correctly
     * User Story : SFP-58522
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = accountSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = Account.SObjectType.getDescribe().fields.getMap();
        Assert.isTrue(sObjectFieldList.size() > 0, 'The field list should not be empty');
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in Account field map');
        }
    }
    /**
     * @description: Verify that Accounts are returned for given Account ID with Person Individual ID
     * User Story : SFP-58522
     */
    @IsTest
    static void testSelectById() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Account accountQueryList = new SEL_Account();
        Test.startTest();
        Account acc = accountQueryList.selectById(accRec.Id);
        accountQueryList.selectByPersonIdentityNumber(new set<string>{'123'});
        Test.stopTest();
        Assert.isNotNull(acc, 'Expected a non-null Account for Account ID: ' + accRec.Id);
    }
    /**
     * @description: Verify that null is returned when a null ID is provided to selectById
     */
    @IsTest
    static void testSelectByIdWithNullId() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        Account acc = accountSelector.selectById(null);
        Test.stopTest();
        Assert.isNull(acc, 'The Account should be null for a null ID.');
    }
    /**
     * @description: Verify that Accounts are returned for given Account IDs
     * User Story : SFP-58522
     */
    @IsTest
    static void testSelectByIds() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Account accountQueryList = new SEL_Account();
        Test.startTest();
        List<Account> accList = accountQueryList.selectByIds(new Set<Id>{accRec.Id});
        Test.stopTest();
        Assert.areEqual(1, accList.size(), 'Expected 1 Account for Account ID: ' + accRec.Id + ' but got ' + accList.size());
    }
    /**
     * @description: Verify that an empty list is returned when an empty set of IDs is provided to selectByIds
     */
    @IsTest
    static void testSelectByIdsWithEmptySet() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        List<Account> accList = accountSelector.selectByIds(new Set<Id>());
        Test.stopTest();
        Assert.isTrue(accList.isEmpty(), 'The Account list should be empty for an empty set of IDs.');
    }
    /**
     * @description: Verify that Accounts are returned for given JSON data
     * User Story : SFP-58522
     */
    @IsTest
    static void testSelectByJsonData() {
        SEL_Account accountQueryList = new SEL_Account();
        String jsonData = '{"firstName":"tester","lastName":"tester","Phone":"+57 9019898989","Email":"test@gmail.com","birthDate":"2006-12-15","countryCode":"57","productCode":"1"}';
        Test.startTest();
        List<Account> accList = accountQueryList.selectByFirstLastNameBirthday(jsonData);
        Test.stopTest();
        Assert.isTrue(accList.isEmpty(), 'Expected empty Account list for the given JSON data but got ' + accList.size() + ' records');
    }
    /**
     * @description: Verify that Relationship Account IDs
     */
    @IsTest
    static void testselectByRelationship() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Account accountQueryList = new SEL_Account();
        Test.startTest();
        List<Account> accList = accountQueryList.selectByRelationship(accRec.Id);
        Test.stopTest();
        Assert.isTrue(accList.isEmpty(), 'Expected empty Account list for Account ID: ' + accRec.Id + ' but got ' + accList.size() + ' records');
    }
    /**
     * @description: Verify that Accounts are returned for given Account IDs
     */
    @IsTest
    static void testselectByAccountId() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Account accountQueryList = new SEL_Account();
        Test.startTest();
        List<Account> accList = accountQueryList.selectByAccountId(accRec.Id);
        Test.stopTest();
        Assert.areEqual(1, accList.size(), 'Expected 1 Account for Account ID: ' + accRec.Id + ' but got ' + accList.size());
    }
    
    /**
     * @description: Verify that Accounts are returned for given Account ID with Person Individual ID
     */
    @IsTest
    static void testSelectByIdWithPersonIndividualId() {
        Account testAccount = new Account(
            FirstName = 'Test',
        LastName = 'User',
        PersonEmail = 'test@example.com',
        PersonMobilePhone = '1234567890',
        FinServ__Gender__pc = 'Male',
        CMN_IdentityNumber__pc = '1234567890123'
            );
        
        Test.startTest();
        CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
        new List<Schema.SObjectType>{ Account.SObjectType }
        );
        
        unitOfWork.registerNew(testAccount);
        unitOfWork.commitWork();
        
        SEL_Account accountSelector = new SEL_Account();
        Account result = accountSelector.selectByIdWithPersonIndividualId(testAccount.Id);
        accountSelector.selectByIdWithServicingFields(testAccount.Id);
        accountSelector.selectByPersonExternalIdentifier(new set<string>{});
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected a non-null Account');
        Assert.areEqual(testAccount.Id, result.Id, 'Account ID should match');
    }
    /**
     * @description: Verify that Accounts are returned for given Account ID with Servicing Fields
     */
    @IsTest
    static void testSelectByIdWithServicingFields() {
        Account testAccount = new Account(
            FirstName = 'Jane',
        LastName = 'Doe',
        PersonEmail = 'jane@test.com',
        PersonMobilePhone = '1234567890'
            );
        insert testAccount;
        
        SEL_Account accountSelector = new SEL_Account();
        
        Test.startTest();
        Account result = accountSelector.selectByIdWithServicingFields(testAccount.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected account to be returned');
        Assert.areEqual(testAccount.Id, result.Id, 'Account ID should match');
    }
    /**
     * @description: Verify that Accounts are returned for given search criteria and record type IDs
     */
    @IsTest
    static void testSelectBySearchCriteria() {
        // Get an available Account Record Type
        Id recordTypeId;
        
        for (Schema.RecordTypeInfo rtInfo :
        Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            
            if (!rtInfo.isMaster() && rtInfo.isAvailable()) {
                recordTypeId = rtInfo.getRecordTypeId();
                break;
            }
        }
        
        Assert.isNotNull(
            recordTypeId,
        'An available Account Record Type is required for this test.'
            );
        
        Account testAccount = new Account(
            RecordTypeId = recordTypeId,
        Name = 'Search Test Account',
        ExternalCIFId__c = 'SEARCH_CIF_001',
        Phone = '9876543210'
            );
        insert testAccount;
        
        SEL_Account accountSelector = new SEL_Account();
        
        List<String> filterClauses = new List<String>{
            'Name LIKE \'%Search Test Account%\''
        };
        
        Set<Id> recordTypeIds = new Set<Id>{ recordTypeId };
        
        Test.startTest();
        
        List<Account> results = accountSelector.selectBySearchCriteria(
            filterClauses,
        recordTypeIds,
        50
            );
        
        Test.stopTest();
        
        Assert.areEqual(
            1,
        results.size(),
        'Expected one matching Account.'
            );
        
        Assert.areEqual(
            testAccount.Id,
        results[0].Id,
        'The returned Account should match the inserted Account.'
            );
        
        Assert.areEqual(
            'Search Test Account',
        results[0].Name,
        'The Account name should match.'
            );
    }
    /**
     * @description: Verify that Accounts are returned for given name, date of birth, and record type ID
     * User Story : SFP-58522
     */
    @IsTest
    static void testSelectByNameDobAndRecordType() {
        Id recordTypeId = [
            SELECT RecordTypeId
            FROM Account WHERE RecordType.DeveloperName LIKE '%Person%'
            LIMIT 1
        ].RecordTypeId;  
        Date dateOfBirth = Date.newInstance(1990, 5, 15);      
        
        SEL_Account accountSelector = new SEL_Account();
        
        Test.startTest();
        
        List<Account> results =
            accountSelector.selectByNameDobAndRecordType(
            'John',
        'Doe',
        dateOfBirth,
        recordTypeId
            );
        
        Test.stopTest();
        
        Assert.isNotNull(results, 'Expected a non-null result.');
        Assert.areEqual(
            1,
        results.size(),
        'Expected one Account to be returned.'
            );
    }
    /**
     * @description: Verify that an empty list is returned when no IDs are provided to selectByIdsWithPersonIndividualId
     */
    @IsTest
    static void testSelectByIdsWithPersonIndividualIdEmptyIds() {
        SEL_Account accountSelector = new SEL_Account();
        
        Test.startTest();
        
        List<Account> results =
            accountSelector.selectByIdsWithPersonIndividualId(
            new Set<Id>()
            );
        
        Test.stopTest();
        
        Assert.isNotNull(results, 'Expected an empty list, not null.');
        Assert.isTrue(
            results.isEmpty(),
        'Expected no Accounts for an empty Id set.'
            );
    }
    /**
     * @description: Verify that a Person Account can be selected by email
     */
    @IsTest
    static void testSelectPersonAccountByEmail() {
        Id personRecordTypeId;
        
        for (Schema.RecordTypeInfo rtInfo :
        Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            
            if (!rtInfo.isMaster()
            && rtInfo.getDeveloperName() == 'IAM_Person') {
                
                personRecordTypeId = rtInfo.getRecordTypeId();
                break;
            }
        }
        
        Assert.isNotNull(
            personRecordTypeId,
        'IAM_Person Record Type must exist for this test.'
            );
        
        Account personAccount = new Account(
            RecordTypeId = personRecordTypeId,
        FirstName = 'Email',
        LastName = 'Search',
        PersonEmail = 'emailsearch@test.com',
        ExternalIdentifier__c = 'EMAIL_SEARCH_001'
            );
        
        insert personAccount;
        
        SEL_Account accountSelector = new SEL_Account();
        
        Test.startTest();
        
        List<Account> results =
            accountSelector.selectPersonAccountByEmail(
            'emailsearch@test.com'
            );
        
        Test.stopTest();
        
        Assert.isNotNull(results, 'Expected a non-null result.');
        Assert.areEqual(
            1,
        results.size(),
        'Expected one Person Account to be returned.'
            );
        Assert.areEqual(
            personAccount.Id,
        results[0].Id,
        'Returned Person Account Id should match.'
            );
        Assert.areEqual(
            'emailsearch@test.com',
        results[0].PersonEmail,
        'Person Email should match.'
            );
    }
}