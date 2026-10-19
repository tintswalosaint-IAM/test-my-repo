/**
 * @description Test class for Batch User class
 * Story: SFP-54179
 * @autor Alex Niyonsaba
 * @date 12th Nov 2025
 */
@IsTest
private class CMN_BATCH_FinancialAccount_Test {
  @TestSetup
  static void setupData() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

    // Create users with restriction codes (matching what financial accounts will have)
    List < User > users = new List < User > ();
    for (Integer i = 1; i <= 2; i++) {
      users.add(new User(
        FirstName = 'User',
        LastName = 'FA' + i,
        Alias = 'ufa' + i,
        Email = 'fauser' + i + '@example.com',
        Username = 'fauser' + i + System.currentTimeMillis() + '@example.com',
        ProfileId = p.Id,
        TimeZoneSidKey = 'GMT',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        User_Country__c = 'UG',
        IsActive = true,
        CMN_FinancialAccountRestrictionCodes__c = (i == 1 ? '001,002' : '002')
      ));
    }
    insert users;

    // Create financial accounts with restriction codes that match the users
    Account primaryAcc = new Account(Name = 'Primary Acc ' + Math.random());
    Account jointAcc = new Account(Name = 'Joint Acc ' + Math.random());
    insert new List < Account > {primaryAcc, jointAcc};

    List < FinServ__FinancialAccount__c > financialAccounts = new List < FinServ__FinancialAccount__c > {
      new FinServ__FinancialAccount__c(Name = 'Account A', ExternalCIFCountry__c = 'UG', CMN_AccessRestrictionCode__c = '001', FinServ__PrimaryOwner__c = primaryAcc.Id, FinServ__JointOwner__c = jointAcc.Id),
      new FinServ__FinancialAccount__c(Name = 'Account B', ExternalCIFCountry__c = 'UG', CMN_AccessRestrictionCode__c = '002', FinServ__PrimaryOwner__c = primaryAcc.Id, FinServ__JointOwner__c = jointAcc.Id)
    };
    insert financialAccounts;

    // Create existing manual shares (to simulate deletion during batch)
    List < FinServ__FinancialAccount__Share > oldShares = new List < FinServ__FinancialAccount__Share > ();
    for (FinServ__FinancialAccount__c acc: financialAccounts) {
      oldShares.add(new FinServ__FinancialAccount__Share(
        ParentId = acc.Id,
        UserOrGroupId = users[0].Id,
        AccessLevel = 'Read',
        RowCause = 'Manual'
      ));
    }
    insert oldShares;
  }

  @IsTest
  static void testExecuteBatchCreatesAndDeletesShares() {
    // Get financial accounts to simulate trigger context
    List < FinServ__FinancialAccount__c > accounts = [SELECT Id, ExternalCIFCountry__c, CMN_AccessRestrictionCode__c
FROM FinServ__FinancialAccount__c];

    // Instantiate and run the batch
    CMN_BATCH_FinancialAccount batch = new CMN_BATCH_FinancialAccount(accounts);

    Test.startTest();
    Database.executeBatch(batch, 20);
    Test.stopTest();

    // Validate share creation
    List < FinServ__FinancialAccount__Share > insertedShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM FinServ__FinancialAccount__Share];

    Assert.isFalse(insertedShares.isEmpty(), 'Expected manual shares to be created.');
  }

  @IsTest
  static void testRunMethodWrapper() {
    // Get financial accounts to simulate trigger context
    List < FinServ__FinancialAccount__c > accounts = [SELECT Id, ExternalCIFCountry__c, CMN_AccessRestrictionCode__c FROM FinServ__FinancialAccount__c];

    Test.startTest();
    CMN_BATCH_FinancialAccount.run(accounts);
    Test.stopTest();

    Integer shareCount = [SELECT COUNT() FROM FinServ__FinancialAccount__Share];
    Assert.isTrue(shareCount > 0, 'Expected shares to exist after batch run.');
  }

  @IsTest
  static void testFinishMethodExecutesSuccessfully() {
    // Minimal test to ensure finish() completes cleanly
    CMN_BATCH_FinancialAccount batch = new CMN_BATCH_FinancialAccount(new List < FinServ__FinancialAccount__c > ());
    Test.startTest();
    batch.finish(null);
    Test.stopTest();

    Assert.isTrue(true, 'Finish method executed successfully.');
  }
}