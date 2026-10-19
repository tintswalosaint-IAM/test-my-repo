/**
 * @description Test class for Financial account share selector class
 * Story: SFP-54179
 * @autor Alex Niyonsaba
 * @date 12th Nov 2025
 */
@IsTest
private class SEL_FinServ_FinancialAccount_Share_Test {
  @IsTest
  static void testSelectManualSharesByParentIdAndUserId() {
    SEL_FinServ_FinancialAccount_Share selector = new SEL_FinServ_FinancialAccount_Share();

    Test.startTest();
    List<FinServ__FinancialAccount__Share> results = selector.selectManualSharesByParentIdAndUserId(
      new Set<Id>(),
      new Set<Id>()
    );
    Test.stopTest();

    Assert.areEqual(0, results.size(), 'Expected no matching share record');
  }

  @IsTest
  static void testSelectManualSharesByUserId() {
    SEL_FinServ_FinancialAccount_Share selector = new SEL_FinServ_FinancialAccount_Share();

    Test.startTest();
    List<FinServ__FinancialAccount__Share> results = selector.selectManualSharesByUserId(
      new Set<Id>()
    );
    Test.stopTest();

    Assert.areEqual(0, results.size(), 'Expected no matching share record');
  }

  @IsTest
  static void testSelectManualSharesByParentId() {
    SEL_FinServ_FinancialAccount_Share selector = new SEL_FinServ_FinancialAccount_Share();

    Test.startTest();
    List<FinServ__FinancialAccount__Share> results = selector.selectManualSharesByParentId(
      new Set<Id>()
    );
    Test.stopTest();

    Assert.areEqual(
      0,
      results.size(),
      'Expected no manual share record for given parent'
    );
  }
}