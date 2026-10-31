/**
* @description       : Class for Selector Class for Account Entity Test class
*@Name of the Class: SEL_Account_Test.cls
* @Story: SFP-36390
* @date May 2022
* @last modified on: 29-02-2024 
* @last modified by: Ikyatha Naidu
* @ Modification Description: SFP-36390, used new field signing arrangement SBO-UK
*/

@IsTest
@SuppressWarnings('PMD.TooManyMethods, PMD.UseCollectionIsEmpty, PMD.AvoidDuplicateLiterals')
private class SEL_Account_Test {

    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(
                Name = 'Test Account',
                ExternalIdentifier__c = 'CM9045678900EQ'
        );
        insert testAccount;
    }

    @IsTest
    static void testGetSObjectType() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        Schema.SObjectType sObjectType = accountSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Account.SObjectType, sObjectType, 'The returned SObjectType does not match Account.SObjectType');
    }

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

    @IsTest
    static void testSelectById() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Account accountQueryList = new SEL_Account();
        Test.startTest();
        Account acc = accountQueryList.selectById(accRec.Id);
        Test.stopTest();
        Assert.isNotNull(acc, 'Expected a non-null Account for Account ID: ' + accRec.Id);
    }

    @IsTest
    static void testSelectByPersonIdentityNumber() {
        Account personAccount = new Account(
            FirstName = 'Identity',
            LastName = 'Match',
            CMN_IdentityNumber__pc = 'ID-12345',
            ExternalIdentifier__c = 'EXT-12345'
        );
        insert personAccount;

        SEL_Account accountSelector = new SEL_Account();

        Test.startTest();
        List<Account> accounts = accountSelector.selectByPersonIdentityNumber(
            new Set<String>{'ID-12345'}
        );
        Test.stopTest();

        Assert.areEqual(1, accounts.size(), 'Expected one matching Account.');
        Assert.areEqual(personAccount.Id, accounts[0].Id, 'The selected Account should match the test Account.');
        Assert.areEqual('EXT-12345', accounts[0].ExternalIdentifier__c);
    }

    @IsTest
    static void testSelectByIdWithNullId() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        Account acc = accountSelector.selectById(null);
        Test.stopTest();
        Assert.isNull(acc, 'The Account should be null for a null ID.');
    }

    @IsTest
    static void testSelectByIds() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Account accountQueryList = new SEL_Account();
        Test.startTest();
        List<Account> accList = accountQueryList.selectByIds(new Set<Id>{accRec.Id});
        Test.stopTest();
        Assert.areEqual(1, accList.size(), 'Expected 1 Account for Account ID: ' + accRec.Id + ' but got ' + accList.size());
    }

    @IsTest
    static void testSelectByIdsWithEmptySet() {
        SEL_Account accountSelector = new SEL_Account();
        Test.startTest();
        List<Account> accList = accountSelector.selectByIds(new Set<Id>());
        Test.stopTest();
        Assert.isTrue(accList.isEmpty(), 'The Account list should be empty for an empty set of IDs.');
    }

    @IsTest
    static void testSelectMethodsWithNullIds() {
        SEL_Account accountSelector = new SEL_Account();

        Test.startTest();
        List<Account> accounts = accountSelector.selectByIds(null);
        Account accountWithIndividualId = accountSelector.selectByIdWithPersonIndividualId(null);
        Account accountWithServicingFields = accountSelector.selectByIdWithServicingFields(null);
        Test.stopTest();

        Assert.isNull(accounts, 'The Account list should be null for null IDs.');
        Assert.isNull(accountWithIndividualId, 'The Account should be null for a null ID.');
        Assert.isNull(accountWithServicingFields, 'The Account should be null for a null ID.');
    }

    @IsTest
    static void testSelectByPersonExternalIdentifier() {
        Account testAccount = [SELECT Id, ExternalIdentifier__c FROM Account WHERE ExternalIdentifier__c = 'CM9045678900EQ' LIMIT 1];
        SEL_Account accountSelector = new SEL_Account();

        Test.startTest();
        List<Account> accounts = accountSelector.selectByPersonExternalIdentifier(
            new Set<String>{testAccount.ExternalIdentifier__c}
        );
        Test.stopTest();

        Assert.areEqual(1, accounts.size(), 'Expected the Account matching the external identifier.');
        Assert.areEqual(testAccount.Id, accounts[0].Id, 'The selected Account should match the test Account.');
    }

    @IsTest
    static void testSelectByJsonData() {
        SEL_Account accountQueryList = new SEL_Account();
        String jsonData = '{"firstName":"tester","lastName":"tester","Phone":"+57 9019898989","Email":"test@gmail.com","birthDate":"2006-12-15","countryCode":"57","productCode":"1"}';
        Test.startTest();
        List<Account> accList = accountQueryList.selectByFirstLastNameBirthday(jsonData);
        Test.stopTest();
        Assert.isTrue(accList.isEmpty(), 'Expected empty Account list for the given JSON data but got ' + accList.size() + ' records');
    }

    @IsTest
    static void testSelectByFirstLastNameBirthdayReturnsMatch() {
        Account personAccount = new Account(
            FirstName = 'Json',
            LastName = 'Match',
            PersonBirthdate = Date.newInstance(2006, 12, 15),
            ExternalCIFCountry__c = 'OS'
        );
        insert personAccount;

        SEL_Account accountSelector = new SEL_Account();
        String jsonData = '{"firstName":" json ","lastName":" match ","birthDate":"2006-12-15"}';

        Test.startTest();
        List<Account> accounts = accountSelector.selectByFirstLastNameBirthday(jsonData);
        Test.stopTest();

        Assert.areEqual(1, accounts.size(), 'Expected one Account matching the JSON criteria.');
        Assert.areEqual(personAccount.Id, accounts[0].Id, 'The selected Account should match the test Account.');
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

    @IsTest
    static void testSelectByIdentityNumberWithOpportunities() {
        Account testAccount = new Account(
                FirstName = 'Test',
                LastName = 'User',
                PersonEmail = 'test@example.com',
                PersonMobilePhone = '1234567890',
                FinServ__Gender__pc = 'Male',
                CMN_IdentityNumber__pc = '1234567890123'
        );

        Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                INS_OnboardingStep__c = 'Step 1',
                Total_Cover_Amount__c = 100000,
                Total_Monthly_Premium__c = 500
        );

        Test.startTest();
        CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Account.SObjectType, Opportunity.SObjectType }
        );

        unitOfWork.registerNew(testAccount);
        unitOfWork.registerNew(testOpportunity, Opportunity.AccountId, testAccount);
        unitOfWork.commitWork();

        SEL_Account accountSelector = new SEL_Account();
        List<Account> result = accountSelector.selectByIdentityNumberWithOpportunities('1234567890123');
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Expected 1 Account but got ' + result.size());
        Assert.areEqual('1234567890123', result[0].CMN_IdentityNumber__pc, 'Identity number should match');
        Assert.areEqual(1, result[0].Opportunities.size(), 'Expected 1 Opportunity but got ' + result[0].Opportunities.size());
        Assert.areEqual('Test Opportunity', result[0].Opportunities[0].Name, 'Opportunity name should match');
    }

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
        accountSelector.selectPersonAccountByEmail(testAccount.PersonEmail);
        accountSelector.selectByPersonExternalIdentifier(new set<string>{});
        Test.stopTest();

        Assert.isNotNull(result, 'Expected a non-null Account');
        Assert.areEqual(testAccount.Id, result.Id, 'Account ID should match');
    }
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
        Assert.areEqual(testAccount.Id, result.Id);
	}
    @IsTest
	static void testSelectPersonAccountByEmail() {
        Account testAccount = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@test.com'
        );
        insert testAccount;
    
        SEL_Account accountSelector = new SEL_Account();
    
        Test.startTest();
        List<Account> result = accountSelector.selectPersonAccountByEmail('john.doe@test.com');
        Test.stopTest();
    
        Assert.areEqual(1, result.size(), 'Expected one account to be returned');
        Assert.areEqual('john.doe@test.com', result[0].PersonEmail);
	}

}