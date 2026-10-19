/**
 * @ description : Test class for CMN_UserUtil
 * @ Author      : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ User Story : SFP-52102
 **/
@isTest
public class CMN_UserUtil_Test {

  @isTest
  static void testSplitAndTrimCommaSeperatedCodes() {
    String restrictionCodesString = ' 001 , 002 , 003 ';
    List < String > expected = new List < String > {
      '001',
      '002',
      '003'
    };

    Test.startTest();
    List < String > result = CMN_UserUtil.splitAndTrimCommaSeperatedCodes(restrictionCodesString);
    Test.stopTest();

    Assert.areEqual(result, expected, 'Should return trimmed non-empty codes');
  }

  @isTest
  static void testSplitAndTrimCommaSeperatedCodesException() {
    try {
      String restrictionCodesString = 'THROW';
      Test.startTest();
      CMN_UserUtil.splitAndTrimCommaSeperatedCodes(restrictionCodesString);
      Test.stopTest();

    } catch (AuraHandledException e) {
      Assert.areEqual(e.getMessage(), 'Script-thrown exception');
    }
  }
}