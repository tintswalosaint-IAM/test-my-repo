/**
 * AOB_CTRL_CardPersonlization Test class
 *
 * <p>DPB-1279</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 25th 2020
 */
@isTest
public class AOB_CTRL_CardPersonlization_TEST {
    /**
     * @description Test setup method to insert all Test data
     */
    @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    }

    /**
     * @description Method used to Test callgetAccessToken
     */
    @isTest
    public static void callgetAccessToken_Test() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            string token = AOB_CTRL_CardPersonlization.callAccessToken();
            Test.stopTest();
            system.assertEquals(token, 'AAIkYzc0NmM');
        }
    }

    /**
     * @description Method used to Test callFindOpenApplications
     */
    @isTest
    public static void callFindOpenApplications_Test() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            string response = AOB_CTRL_CardPersonlization.callFindOpenApplications();
            Test.stopTest();
            system.assertNotEquals(response, null);
        }
    }
    /**
     * @description Method used to Test etCardPersonalization
     */
    @isTest
    public static void getCardPersonalization_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZPLP');
        AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id, 'D');
        AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct, product);
        AOB_ApplicationLineItem__c newApplicationLineItem = createApplicationLineItem11(parentProduct.Id, app.Id);
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_CardPersonalization response = AOB_CTRL_CardPersonlization.getCardPersonalization((Id) app.Id);
            Test.stopTest();
            system.assertNotEquals(response, null);
        }
    }
    /**
     * @description Method used to Test etCardPersonalization Exception
     */
    @isTest
    public static void getCardPersonalization_Exception_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        System.runAs(communityUser) {
            Test.startTest();
            Exception exc;
            try {
                AOB_DTO_CardPersonalization response = AOB_CTRL_CardPersonlization.getCardPersonalization(parentProduct.Id);
            } catch (Exception e) {
                exc = e;
            }
            Test.stopTest();
            system.assertNotEquals(null, exc);
        }
    }

    /**
     * @description Method used to Test updateAppLineItem
     */
    @isTest
    public static void updateAppLineItem_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        parentProduct.ExternalId = parentProduct.Id;
        update parentProduct;
        AOB_ApplicationLineItem__c newApplicationLineItem = createApplicationLineItem11(parentProduct.Id, app.Id);
        final Decimal WANTED_AMOUNT = 1000;
        final Decimal CONTRACT_DURATION = 20;
        final Decimal ESTIMATED_MONTHLY_REPAY = 2000;
        System.runAs(communityUser) {
            Test.startTest();
            AOB_CTRL_CardPersonlization.updateAppLineItem(WANTED_AMOUNT, CONTRACT_DURATION, ESTIMATED_MONTHLY_REPAY, parentProduct.Id, app.Id);
            Test.stopTest();
            List<AOB_ApplicationLineItem__c> appLineItem = [
                SELECT Id, AOB_RequestedValue__c, AOB_ContractDuration__c, AOB_EstimatedMonthlyRepayment__c
                FROM AOB_ApplicationLineItem__c
                WHERE AOB_Application__c = :app.Id AND AOB_Product__r.ExternalId = :parentProduct.Id
            ];
            System.assertEquals(false, appLineItem.isEmpty());
            System.assertEquals(WANTED_AMOUNT, appLineItem[0].AOB_RequestedValue__c);
            System.assertEquals(CONTRACT_DURATION, appLineItem[0].AOB_ContractDuration__c);
            System.assertEquals(ESTIMATED_MONTHLY_REPAY, appLineItem[0].AOB_EstimatedMonthlyRepayment__c);
        }
    }

    /**
     * @description Method used to Test setDataToSalesforce
     */
    @isTest
    public static void deselectInsurance_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZPLP');
        AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id, 'D');
        AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct, product);
        AOB_ApplicationLineItem__c newApplicationLineItem = createApplicationLineItem11(parentProduct.Id, app.Id);
        string ss = '{"insuranceId":"'+insurancePlan.AOB_InsurancePlanID__c+'","insuranceProductDesc":"'+insurancePlan.AOB_Product__c+'","insuranceName" :""}';
        System.runAs(communityUser) {
            Test.startTest();
            try{
            AOB_CTRL_CardPersonlization.deselectInsurance('token', app.Id, 'ZRCP');
            AOB_CTRL_CardPersonlization.setDataToSalesforce('token',908.90,908.90,'9999',true,'test','ZRCP',app.id,'87658','453',ss);
            }catch(exception e){
                System.debug('test'+e.getMessage());
            }
            Test.stopTest();
        }
        app = [SELECT id, AOB_TECH_hasInsurance__c FROM AOB_application__c];
        system.AssertEquals(app.AOB_TECH_hasInsurance__c, false);
    }
    
    public static AOB_ApplicationLineItem__c createApplicationLineItem11(
    Id productId,
    Id applicationId
  ) {
      try {
          system.debug('prod id'+productId);
          system.debug('applicationId'+applicationId);
        AOB_ApplicationLineItem__c newApplicationLineItem = new AOB_ApplicationLineItem__c(
          AOB_Product__c = productId,
          AOB_Application__c = applicationId,
          AOB_TECH_CCInsuranceID__c = 'test'
        );
        insert newApplicationLineItem;
        return newApplicationLineItem;
      } catch (Exception e) {
          System.debug(LoggingLevel.INFO, 'AOB_DAL_TestFactory, Failing to create application line item for application: ' + applicationId);
          return null;
      }
  }
}