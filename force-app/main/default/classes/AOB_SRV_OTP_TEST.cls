/**
 * Test Class for AOB_SRV_CommerceCloudConnecto
 *
 * <p>DBP-2401</p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Feb 17th 2021
 */
@IsTest
public class AOB_SRV_OTP_TEST {
  @TestSetup
  public static void testSetUp() {
    User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(
      communityUser.contactId
    );
    Product2 parentProduct = AOB_DAL_TestFactory.createProduct(
      AOB_TestConstants.PRODUCT_NAME,
      'ZRCP'
    );
    Product2 product = AOB_DAL_TestFactory.createProduct(
      AOB_TestConstants.PRODUCT_NAME,
      'ZPLP'
    );
    AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(
      product.Id,
      'D'
    );
    AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(
      parentProduct,
      product
    );
    AOB_ApplicationLineItem__c newApplicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(
      parentProduct.Id,
      app.Id
    );
  }

  /**
   * @description Method used to Test get CCAccessToken
   */
  @isTest
  public static void callOTP_Test() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_application__c app = [SELECT Id FROM AOB_application__c LIMIT 1];
    System.runAs(communityUser) {
      Test.startTest();
      string response = AOB_SRV_OTP.callOTP(
        '34567890',
        'M567898',
        '56789',
        'GEN',
        app.id
      );
      Test.stopTest();
      system.assertNotEquals(response, null);
    }
  }
  /**
   * @description Method used to Test get CCAccessToken
   */
  @isTest
  public static void getOTPMessage_Test() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      Map<String, String> msgMap = AOB_SRV_OTP.getOTPMessage();
      Test.stopTest();
      system.assertEquals(msgMap.get('0000'), 'OK');
    }
  }
}