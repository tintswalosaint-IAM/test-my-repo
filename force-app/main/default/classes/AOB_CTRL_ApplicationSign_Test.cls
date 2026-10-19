/**
* AOB_CTRL_ApplicationSign Test Class
*
* <p>DBP-3231</p>
*
* @author (mark.bailey2@standardbank.co.za)
*
* @date Jul 12th 2021
*/
@isTest
public class AOB_CTRL_ApplicationSign_Test {
  /**
   * @description Test setup method to insert all Test data
   */
  @TestSetup
  public static void testSetUp() {
    User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(
      communityUser.contactId
    );
    Product2 parentProduct = AOB_DAL_TestFactory.createProduct(
      AOB_TestConstants.PRODUCT_NAME,
      'ZWCC'
    );
    AOB_ApplicationLineItem__c newApplicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(
      parentProduct.Id,
      app.Id
    );
  }

  /**
   * @description Method used to Test getProductName
   */
  @isTest
  public static void getProductNameTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_Application__c app = [
        SELECT id 
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      String productName = AOB_CTRL_ApplicationSign.getProductName(app.Id);
      Test.stopTest();
      system.assertEquals(productName, AOB_TestConstants.PRODUCT_NAME);
    }
  }

  @isTest
  public static void getProductNameFailTest(){ 
     Boolean failed=false;
      Test.startTest();
      try{
        String productName = AOB_CTRL_ApplicationSign.getProductName(null);
      }
      catch(exception e){
          failed=true;    
      }
      Test.stopTest();
      system.assertEquals(failed,true);
  }

  /**
   * @description Method used to Test getApplicationSigned
   */
  @isTest
  public static void getApplicationSignedTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_Application__c app = [
        SELECT id 
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      Boolean appSigned = AOB_CTRL_ApplicationSign.getApplicationSigned(app.Id);
      Test.stopTest();
      system.assertEquals(appSigned, false);
    }
  }

  @isTest
  public static void getApplicationSignedFailTest(){ 
     Boolean failed=false;
      Test.startTest();
      try{
        Boolean appSigned = AOB_CTRL_ApplicationSign.getApplicationSigned(null);
      }
      catch(exception e){
          failed=true;    
      }
      Test.stopTest();
      system.assertEquals(failed,true);
  }

  /**
   * @description Method used to Test setApplicationSigned
   */
  @isTest
  public static void setApplicationSignedTest() {
    User communityUser = [
      SELECT Id, contactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    AOB_Application__c app = [
        SELECT id 
        FROM AOB_Application__c 
        WHERE AOB_Contact__c = :communityUser.contactId 
        LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      Boolean appSigned = AOB_CTRL_ApplicationSign.setApplicationSigned(app.Id);
      Test.stopTest();
      system.assertEquals(appSigned, true);
    }
  }

  @isTest
  public static void setApplicationSignedFailTest(){ 
     Boolean failed=false;
      Test.startTest();
      try{
        Boolean appSigned = AOB_CTRL_ApplicationSign.setApplicationSigned(null);
      }
      catch(exception e){
          failed=true;    
      }
      Test.stopTest();
      system.assertEquals(failed,true);
  }
}