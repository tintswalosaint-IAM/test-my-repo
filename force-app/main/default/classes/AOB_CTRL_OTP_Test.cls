/**
 * AOB_CTRL_OTP test Class
 *
 * <p>DBP-1638-1639-1640-1641</p>
 *
 *  @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Jan 1st 2021
 */
@isTest
public class AOB_CTRL_OTP_Test {
  /**
   * @description Test setup method to insert all Test data
   */
  @TestSetup
  public static void testSetUp() {
    User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    List<AOB_Country_Settings__mdt> appSettings = AOB_DAL_TestFactory.loadCountrySettings();
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
   * @description Method used to Test callgetAccessToken
   */
  @isTest
  public static void callAccessToken_Test() {
    User communityUser = [
      SELECT Id
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      string token = AOB_CTRL_OTP.callAccessToken();
      Test.stopTest();
      system.assertEquals(token, 'AAIkYzc0NmM');
    }
  }
  /**
   * @description Method used to Test callgetAccessToken
   */
  @isTest
  public static void generateData_Test() {
    User communityUser = [
      SELECT Id
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      AOB_DTO_OTP response = AOB_CTRL_OTP.generateData();
      Test.stopTest();
      system.assertNotEquals(response, null);
    }
  }


  /**
   * @description Method used to Test callFindOpenApplications
   */
  @isTest
  public static void checkOTPAttempts_Test() {
    final String MAX_ATTEMPTS_DEVELOPER_NAME = 'Max_Attempts';
    User communityUser = [
      SELECT Id
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    final List<AOB_AppSettings__mdt> techSettings = [
      SELECT MasterLabel, AOB_Value__c
      FROM AOB_AppSettings__mdt
      WHERE DeveloperName = :MAX_ATTEMPTS_DEVELOPER_NAME
    ];

    System.runAs(communityUser) {
      AOB_application__c app = [
        SELECT Id, AOB_TECH_OTPAttempts__c
        FROM AOB_application__c
        LIMIT 1
      ];
      Test.startTest();
      Boolean canAttempt = AOB_SRV_OTP.checkOTPAttempts(app.id, true, false);
      app = [
        SELECT Id, AOB_TECH_OTPAttempts__c
        FROM AOB_application__c
        WHERE Id = :app.Id
      ];
      system.assertEquals(
        app.AOB_TECH_OTPAttempts__c <
        Decimal.valueOf(techSettings[0].AOB_Value__c),
        canAttempt,
        'Wrong returned value from AOB_CTRL_OTP.checkOTPAttempts'
      );
      app.AOB_TECH_OTPAttempts__c = Decimal.valueOf(
        techSettings[0].AOB_Value__c
      );
      update app;
      canAttempt = AOB_SRV_OTP.checkOTPAttempts(app.id, true, false);
      Test.stopTest();
      app = [
        SELECT Id, AOB_TECH_OTPAttempts__c
        FROM AOB_application__c
        WHERE Id = :app.Id
      ];
      system.assertEquals(
        app.AOB_TECH_OTPAttempts__c <
        Decimal.valueOf(techSettings[0].AOB_Value__c),
        canAttempt,
        'Wrong returned value from AOB_CTRL_OTP.checkOTPAttempts'
      );
    }
  }
}