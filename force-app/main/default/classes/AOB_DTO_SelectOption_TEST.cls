/**
* @description  Test Class for AOB_DTO_SelectOption
* @author Dayakar
* @date  11-03-2023
*/
@isTest
public class AOB_DTO_SelectOption_TEST {
  /**
  * @description test method for AOB_DTO_SelectOption 
  */
  @isTest
  static void AOB_SelectOptionTest() {
    Test.StartTest();
    AOB_DTO_SelectOption option = new AOB_DTO_SelectOption('a', 'b');
    Test.stopTest();
    Assert.areEqual(option.value, 'a');
    Assert.areEqual(option.label, 'b');
  }
     /**
  * @description test method for AOB_DTO_SelectOption 
  */
  @isTest
  static void AOB_SelectOptionTest1() {
    Test.StartTest();
    AOB_DTO_SelectOption option = new AOB_DTO_SelectOption('a', 'b',true);
    Test.stopTest();
    Assert.areEqual(option.value, 'a');
    Assert.areEqual(option.label, 'b');
  }
}