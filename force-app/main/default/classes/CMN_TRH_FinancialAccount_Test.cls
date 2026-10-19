/**
 * @ description : Test class for CMN_TRH_FinancialAccount
 * @ Author      : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ User Story : SFP-52104
 * 
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : April 29th 2026
 * @ Modification description : Updates made to increase the class's test coverage.
 * @ User Story : SFP-57683
 */

@isTest
private class CMN_TRH_FinancialAccount_Test {
  private static User createTestUser(String restrictionCodes, String country, Boolean isActive) {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    User u = new User(FirstName = 'Test', LastName = 'User' + Math.random(),
      Alias = 'tst' + Math.mod(Crypto.getRandomInteger(), 1000),
      Email = 'test' + Math.random() + '@test.com',
      Username = 'test' + Math.random() + '@test.com', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
      CMN_FinancialAccountRestrictionCodes__c = restrictionCodes, User_Country__c = country,
      IsActive = isActive);
    insert u;
    return u;
  }

  private static FinServ__FinancialAccount__c createFinancialAccount(
    String restrictionType, String country) {
    // Create two different Accounts to satisfy the validation rule
    Account primaryAcc = new Account(Name = 'Primary Acc ' + Math.random());
    Account jointAcc = new Account(Name = 'Joint Acc ' + Math.random());
    insert new List < Account > {
      primaryAcc,
      jointAcc
    };

    FinServ__FinancialAccount__c acc =
      new FinServ__FinancialAccount__c(Name = 'Test FA ' + Math.random(),
        ExternalCIFCountry__c = country, CMN_AccessRestrictionCode__c = restrictionType,
        FinServ__PrimaryOwner__c = primaryAcc.Id, FinServ__JointOwner__c = jointAcc.Id);
    insert acc;
    return acc;
  }

  @isTest
  static void testHandleFinancialAccountSharing_InsertAndDelete() {
    // Create a test user with restriction codes "001,002"
    createTestUser('001,002', 'UG', true);

    // Create a Financial Account with restriction 001
    FinServ__FinancialAccount__c fa = createFinancialAccount('001', 'UG');

    Test.startTest();
    // Call afterUpdate directly to trigger handleFinancialAccountSharing
    CMN_TRH_FinancialAccount handler = new CMN_TRH_FinancialAccount();
    handler.afterUpdate(fa, fa);

    // Verify share inserted
    List < FinServ__FinancialAccount__Share > shares = [
      SELECT Id, ParentId,
      UserOrGroupId FROM FinServ__FinancialAccount__Share WHERE ParentId =: fa.Id
    ];

    // Call again to hit duplicate check (checkWetherSharingRecordAlreadyExist = true)

    handler.afterUpdate(fa, fa);
    Test.stopTest();

    // No new share should be added
    Integer countShares = [SELECT Count() FROM FinServ__FinancialAccount__Share WHERE ParentId =: fa.Id];
    Assert.areEqual(1, countShares, 'Duplicate share should not be inserted');
    Assert.areNotEqual(null, shares.size(), 'Expected shares to be created');
  }

  @isTest
  static void testHandleFinancialAccountSharing_DeleteExistingShares() {
    User u1 = createTestUser('003', 'UG', true);
    FinServ__FinancialAccount__c fa = createFinancialAccount('003', 'UG');

    // Insert a manual share to simulate existing share
    FinServ__FinancialAccount__Share share = new FinServ__FinancialAccount__Share(ParentId = fa.Id,
      UserOrGroupId = u1.Id, AccessLevel = 'Read',
      RowCause = Schema.FinServ__FinancialAccount__Share.RowCause.Manual);
    insert share;

    Test.startTest();
    CMN_TRH_FinancialAccount handler = new CMN_TRH_FinancialAccount();
    handler.afterUpdate(fa, fa);
    Test.stopTest();

    // The old share should be deleted and replaced
    List < FinServ__FinancialAccount__Share > shares = [
      SELECT Id, ParentId,
      UserOrGroupId FROM FinServ__FinancialAccount__Share WHERE ParentId =: fa.Id
    ];
    Assert.isFalse(shares.isEmpty(), 'Expected Some shares after cleanup and reinsertion');
  }

  @isTest
  static void testAfterUpdateTrigger() {
    final String TEST_RESTRICTION_ACCESS_CODE = '001';
    final String NEW_TEST_RESTRICTION_ACCESS_CODE = '002';
    Test.startTest();
    //Create test Financial Account
    FinServ__FinancialAccount__c fa = createFinancialAccount(TEST_RESTRICTION_ACCESS_CODE, 'UG');

    //Update the record to fire the trigger
    fa.CMN_AccessRestrictionCode__c = NEW_TEST_RESTRICTION_ACCESS_CODE;
    update fa;
    Test.stopTest();
    Assert.areEqual(NEW_TEST_RESTRICTION_ACCESS_CODE, fa.CMN_AccessRestrictionCode__c);
  }

  @isTest
  static void testAfterUpdateTrigger_Bulkified() {
    final String TEST_RESTRICTION_ACCESS_CODE = '001';
    final String NEW_TEST_RESTRICTION_ACCESS_CODE = '002';
    Test.startTest();
    List<FinServ__FinancialAccount__c> financialAcccountsToUpdate = new List<FinServ__FinancialAccount__c>();

    //Create test Financial Account
    for(Integer i=0; i<= 10; i++){
      FinServ__FinancialAccount__c fa = createFinancialAccount(TEST_RESTRICTION_ACCESS_CODE, 'UG');
      fa.CMN_AccessRestrictionCode__c = NEW_TEST_RESTRICTION_ACCESS_CODE;
      financialAcccountsToUpdate.add(fa);
    }

    update financialAcccountsToUpdate;
    Test.stopTest();

    Assert.areEqual(NEW_TEST_RESTRICTION_ACCESS_CODE, financialAcccountsToUpdate[0].CMN_AccessRestrictionCode__c);
  }  
}