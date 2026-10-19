/**
 * Test class for AOB_CTRL_BeforeWeBegin
 * 
 * <p>DPB-1156</p> 
 * 
 * @author Achraf ABOUL (aaboul@salesforce.com)
 * 
 * @date Nov 11th 2020
 */
@IsTest
public with sharing class AOB_CTRL_BeforeWeBegin_Test {
    
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
       AOB_DAL_TestFactory.createCommunityUser();
    }
    /**
	 * Test method for AOB_CTRL_BeforeWeBegin.getRelatedProducts
	 */
	@IsTest
	private static void getRelatedProducts_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Product2 newProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME,'ZTCC');
        AOB_ApplicationLineItem__c newApplicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(newProduct.Id, newApplication.Id);
        AOB_RequiredDocument__c newRequiredDocument = AOB_DAL_TestFactory.createRequiredDocument(newProduct.Id, AOB_TestConstants.REQUIRED_DOC_DESCRIPTION, AOB_TestConstants.REQUIRED_DOC_HELPTEXT, AOB_TestConstants.REQUIRED_DOC_ORDER);
        AOB_ProductQualifications__c newProductQualification = AOB_DAL_TestFactory.createProductQualification(newProduct.Id, AOB_TestConstants.PRODUCT_QUALIF_DESCRIPTION, AOB_TestConstants.PRODUCT_QUALIF_HELPTEXT, AOB_TestConstants.PRODUCT_QUALIF_ORDER);
        User admin = AOB_DAL_TestFactory.createUser(AOB_Constants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            Test.startTest();
            String relatedProductsStr = AOB_CTRL_BeforeWeBegin.getRelatedProducts(newApplication.Id);
            Test.stopTest();
            List<Product2> relatedProducts = (List<Product2>) JSON.deserialize(relatedProductsStr, List<Product2>.class);
            System.assertEquals(1, relatedProducts.size());

            Product2 relatedProduct = relatedProducts.get(0);
            System.assertEquals(1, relatedProduct.Required_Documents__r.size());
            System.assertEquals(1, relatedProduct.Product_Qualifications__r.size());

            AOB_RequiredDocument__c relatedRequiredDocument = relatedProduct.Required_Documents__r.get(0);
            System.assertEquals(newRequiredDocument.AOB_Description__c, relatedRequiredDocument.AOB_Description__c);
            System.assertEquals(newRequiredDocument.AOB_HelpText__c, relatedRequiredDocument.AOB_HelpText__c);
            System.assertEquals(newRequiredDocument.AOB_Order__c, relatedRequiredDocument.AOB_Order__c);

            AOB_ProductQualifications__c relatedProductQualification = relatedProduct.Product_Qualifications__r.get(0);
            System.assertEquals(newProductQualification.AOB_Description__c, relatedProductQualification.AOB_Description__c);
            System.assertEquals(newProductQualification.AOB_HelpText__c, relatedProductQualification.AOB_HelpText__c);
            System.assertEquals(newProductQualification.AOB_Order__c, relatedProductQualification.AOB_Order__c); 
        }  
    }
    /**
	 * Test method for AOB_CTRL_BeforeWeBegin.getRelatedProducts (throw exception scenario)
	 */
	@IsTest
	private static void getRelatedProducts_Exception_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Id newApplicationId = newApplication.Id;
        delete newApplication;
        User admin = AOB_DAL_TestFactory.createUser(AOB_Constants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){ 
            Test.startTest();
            Exception exc;
            try{
                String relatedProductsStr = AOB_CTRL_BeforeWeBegin.getRelatedProducts(newApplicationId);
            }
            catch(Exception e){
                exc = e;
            }
            System.assertNotEquals(null, exc);
            System.assertEquals(AOB_Constants.SCRIPT_THROWN_EXCEPTION, exc.getMessage());
            Test.stopTest();
        }  
    }
}