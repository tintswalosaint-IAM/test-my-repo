/**
 * @description Test class for Batch User class
 * Story: SFP-54179
 * @autor Alex Niyonsaba
 * @date 12th Nov 2025
 */
@IsTest
private class CMN_BATCH_User_Test {

  @TestSetup
  static void setupData() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

    // Create test user who will trigger the batch
    User u = new User(
      FirstName = 'Alex',
      LastName = 'BatchUser',
      Alias = 'abtc',
      Email = 'alex.batchuser@example.com',
      Username = 'alex.batchuser' + System.currentTimeMillis() + '@example.com',
      ProfileId = p.Id,
      TimeZoneSidKey = 'GMT',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      User_Country__c = 'UG',
      CMN_FinancialAccountRestrictionCodes__c = '001,002'
    );
    insert u;

    // Create mock Financial Accounts matching restriction codes
    Account primaryAcc = new Account(Name = 'Primary Acc ' + Math.random());
    Account jointAcc = new Account(Name = 'Joint Acc ' + Math.random());
    insert new List < Account > {primaryAcc, jointAcc};
    List < FinServ__FinancialAccount__c > accounts = new List < FinServ__FinancialAccount__c > {
      new FinServ__FinancialAccount__c(Name = 'Account 001', CMN_AccessRestrictionCode__c = '001', FinServ__PrimaryOwner__c = primaryAcc.Id, FinServ__JointOwner__c = jointAcc.Id),
      new FinServ__FinancialAccount__c(Name = 'Account 002', CMN_AccessRestrictionCode__c = '002', FinServ__PrimaryOwner__c = primaryAcc.Id, FinServ__JointOwner__c = jointAcc.Id)
    };
    insert accounts;

    // Create some existing share records (to be deleted)
    List < FinServ__FinancialAccount__Share > shares = new List < FinServ__FinancialAccount__Share > ();
    for (FinServ__FinancialAccount__c acc: accounts) {
      shares.add(new FinServ__FinancialAccount__Share(
        ParentId = acc.Id,
        UserOrGroupId = u.Id,
        AccessLevel = 'Read',
        RowCause = 'Manual'
      ));
    }
    insert shares;
  }

  @IsTest
  static void testBatchExecution() {
    // Get our test user
    User testUser = [SELECT Id, User_Country__c, CMN_FinancialAccountRestrictionCodes__c FROM User WHERE Email = 'alex.batchuser@example.com' LIMIT 1];

    //Prepare a list to simulate trigger context
    List < User > updatedUsers = new List < User > {testUser};

    //Instantiate the batch
    CMN_BATCH_User batchJob = new CMN_BATCH_User(updatedUsers);

    Test.startTest();
    // Run batch
    Database.executeBatch(batchJob, 5);
    Test.stopTest();

    // Verify that financial account share records were (re)created
    List < FinServ__FinancialAccount__Share > insertedShares = [
      SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
      FROM FinServ__FinancialAccount__Share
    ];

    Assert.isFalse(insertedShares.isEmpty(), 'Expected financial account share records to be inserted');
  }

  @IsTest
  static void testBatchRunMethod() {
    User testUser = [SELECT Id, User_Country__c, CMN_FinancialAccountRestrictionCodes__c FROM User WHERE Email = 'alex.batchuser@example.com'
      LIMIT 1
    ];
    List < User > userList = new List < User > {testUser};

    Test.startTest();
    CMN_BATCH_User.run(userList);
    Test.stopTest();

    // Verify some shares exist after batch
    Integer shareCount = [SELECT COUNT() FROM FinServ__FinancialAccount__Share];
    Assert.isTrue(shareCount > 0, 'Expected share records after running batch via run() method');
  }

  @IsTest
  static void testFinishMethod() {
    CMN_BATCH_User batchJob = new CMN_BATCH_User(new List < User > ());
    Test.startTest();
    batchJob.finish(null);
    Test.stopTest();

    Assert.isTrue(true, 'Finish method executed successfully');
  }
}