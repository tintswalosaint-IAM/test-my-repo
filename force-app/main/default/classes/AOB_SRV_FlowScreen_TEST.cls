/**
 * @description Test Class for AOB_SRV_FlowScreen
 * 
 * <p>DBP-1499</p> 
 * 
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 * 
 * @date Feb 8th 2021 
 */
@IsTest
public class AOB_SRV_FlowScreen_TEST {
	
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * @description Method used to Test get FinalOffer 
	 */
    @isTest
    public static void getFinalOfferTest(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
            AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
            Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME,'ZRCP');
          Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME,'ZPLP');
            AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id,'D');
            AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct,product);
        //   app.Id = '';
         //  Id idApplication = Id.valueOf(app.Id, true);
          //Id idProduct = Id.valueOf(parentProduct.Id, true);
           // System.debug(LoggingLevel.INFO, 'AOB_SRV_FlowScreen_Test, appId: ' + idApplication);
          //System.debug(LoggingLevel.INFO, 'AOB_SRV_FlowScreen_Test, product: ' + idProduct);
 // AOB_ApplicationLineItem__c newApplicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(parentProduct.Id, (id)app.Id);
          AOB_ApplicationLineItem__c newApplicationLineItem = createApplicationLineItem1(parentProduct.Id, (id)app.Id);
         //AOB_ApplicationLineItem__c newApplicationLineItem1 = AOB_DAL_TestFactory.createApplicationLineItem(idProduct, idApplication);
    
            AOB_FinalOffer__c offer = AOB_DAL_TestFactory.createFinalOffers(AOB_Constants.SCREEN_FINAL_OFFER);
            AOB_DAL_TestFactory.createProductFinalOffer(parentProduct.id,offer.id);
           
            //null test
            //Test.startTest();
            //AOB_DTO_FinalOffer response = AOB_SRV_FlowScreen.getFinalOffer(null);
            //Test.stopTest();
                    System.runAs(communityUser) {

            Test.startTest();
            AOB_DTO_FinalOffer response2 = AOB_SRV_FlowScreen.getFinalOffer((Id)app.Id);
         //  AOB_DTO_CardPersonalization response3 = AOB_SRV_FlowScreen.getCardPersonalization((Id)app.Id);
         //   AOB_DTO_FinalOffer response4 = AOB_CTRL_FinalOffer.getFinalOffer((Id) app.Id);
             Test.stopTest();
            system.assertNotEquals(response2,null,'');
          //  system.assertNotEquals(response3,null,'');
          //  system.assertNotEquals(response4,null,'');
                    }
    }
    
     public static AOB_ApplicationLineItem__c createApplicationLineItem1(
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
       //   AOB_HasInsurance__c = false,
         // AOB_ProductOption__c = ''
        );
        insert newApplicationLineItem;
        return newApplicationLineItem;
      } catch (Exception e) {
          System.debug(LoggingLevel.INFO, 'AOB_DAL_TestFactory, Failing to create application line item for application: ' + applicationId);
          return null;
      }
  }
    
    
  @isTest
    public static void isCustomerHasInsurance_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZPLP');
        AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id, 'D');
        AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct, product);
        AOB_ApplicationLineItem__c newApplicationLineItem = createApplicationLineItem1(parentProduct.Id, (id)app.Id);
        newApplicationLineItem.AOB_HasInsurance__c = true;
        update newApplicationLineItem;
        AOB_FinalOffer__c offer = AOB_DAL_TestFactory.createFinalOffers(AOB_Constants.SCREEN_FINAL_OFFER);
        System.runAs(communityUser) {
            Test.startTest();
            Boolean hasInsurance = AOB_CTRL_FinalOffer.isCustomerHasInsurance(app.Id);
            Test.stopTest();
            system.assert(hasInsurance);
        }
    }
  
     @isTest
    public static void getFinalOfferException_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];

        System.runAs(communityUser) {
            Test.startTest();
            Boolean hasException = false;
            try {
                AOB_DTO_FinalOffer response = AOB_CTRL_FinalOffer.getFinalOffer(communityUser.Id);
            } catch (Exception e) {
                hasException = true;
            }
            system.assert(hasException);
            Test.stopTest();
        }
    }

      @isTest
    public static void getFinalOffer_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZPLP');
        AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id, 'D');
        AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct, product);
        AOB_ApplicationLineItem__c newApplicationLineItem = createApplicationLineItem1(parentProduct.Id, (id)app.Id);
        AOB_FinalOffer__c offer = AOB_DAL_TestFactory.createFinalOffers(AOB_Constants.SCREEN_FINAL_OFFER);
        AOB_DAL_TestFactory.createProductFinalOffer(parentProduct.id, offer.id);
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_FinalOffer response = AOB_CTRL_FinalOffer.getFinalOffer((Id) app.Id);
            Test.stopTest();
            system.assertNotEquals(response, null);
        }
    }

    @isTest
    public static void getCardPersonalization_Test() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZRCP');
        Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME, 'ZPLP');
        AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id, 'D');
        AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct, product);
        AOB_ApplicationLineItem__c newApplicationLineItem =createApplicationLineItem1(parentProduct.Id, (id)app.Id);
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_CardPersonalization response = AOB_CTRL_CardPersonlization.getCardPersonalization((Id) app.Id);
            Test.stopTest();
            system.assertNotEquals(response, null);
        }
    }
  
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



   
 
}