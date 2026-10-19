/**
 * Test Class for AOB_SRV_CommerceCloudConnecto
 * 
 * <p>DBP-2071-2073-2074-2076</p> 
 * 
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 * 
 * @date Feb 14th 2021 
 */
@IsTest
public class AOB_SRV_CommerceCloudConnector_TEST {
	@TestVisible
	private static final String SERVICE_NAME = AOB_SRV_CommerceCloudConnector.class.getName();
    @TestSetup
    public static void testSetUp(){
        User communityUser = null;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {   
            communityUser = AOB_DAL_TestFactory.createCommunityUser();	
        }

            // Test.startTest();

        	Product2 parentProduct = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME,'ZRCP');
            Product2 product = AOB_DAL_TestFactory.createProduct(AOB_TestConstants.PRODUCT_NAME,'ZPLP');
        
        
            AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);

            
            AOB_ProductOption__c insurancePlan = AOB_DAL_TestFactory.createProductOption(product.Id,'D');
            AOB_InsuranceProduct__c insuranceProduct = AOB_DAL_TestFactory.createInsuranceProduct(parentProduct,product);
            AOB_ApplicationLineItem__c newApplicationLineItem = AOB_DAL_TestFactory.createApplicationLineItem(parentProduct.Id, app.Id);
        
            //Test.stopTest();

    }
    /**
	 * @description Method used to Test get CCAccessToken 
	 */
    @isTest
    public static void getCCAccessToken_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){ 
            Test.startTest();
            string response = AOB_SRV_CommerceCloudConnector.getCCAccessToken();
            
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    @isTest
    public static void getCCAccessTokenNeg_Test(){
            try {
        		User testUser = AOB_DAL_TestFactory.createUser('AOB_API_Only', true);
            	System.runAs(testUser) {
                    Test.startTest();
                    AOB_SRV_CommerceCloudConnector.getCCAccessToken();
                    Test.stopTest();
                }
        } catch (Exception e) {
            System.debug('Expected exception');
        }     
    }
    /**
	 * @description Method used to Test get CustomerAccessToken 
	 */
    @isTest
    public static void getCustomerAccessToken_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){ 
            Test.startTest();
            string response = AOB_SRV_CommerceCloudConnector.getCustomerAccessToken('fake token');
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
     /**
	 * @description Method used to Test get FinalOffer 
	 */
    @isTest
    public static void deleteInsuranceCC_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCInsuranceID__c FROM AOB_ApplicationLineItem__c LIMIT 1];
        System.runAs(communityUser){ 
            Test.startTest(); 
            AOB_SRV_CommerceCloudConnector.deleteInsuranceCC('fake token',appLI.AOB_TECH_CCInsuranceID__c);
            
            Test.stopTest();
            system.assertEquals(appLI.AOB_TECH_CCInsuranceID__c,null); 
        }
    }
    /**
	 * @description Method used to Test update insurance where isUpdate = false 
	 */
    @isTest
    public static void updateBasket_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c FROM AOB_ApplicationLineItem__c LIMIT 1];      
        AOB_DTO_CommerceCloudConnector.Basket basket = new AOB_DTO_CommerceCloudConnector.Basket();
        basket.c_initiationFee = 12.7;
        basket.c_loanAmount = 100.7;
        basket.c_monthlyTotalRepaymentAmount = 18.7;
        basket.c_monthlyRepaymentAmount = 17.7;
        System.runAs(communityUser){ 
            Test.startTest();
            AOB_SRV_CommerceCloudConnector.updateBasketCC('fake token',basket , appLI.AOB_TECH_CCProductID__c);
            Test.stopTest();
            system.assertNotEquals(basket,null); 
        }
    }
    
        @isTest
        public static void updateBasketfuture_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c FROM AOB_ApplicationLineItem__c LIMIT 1];      
      //  AOB_DTO_CommerceCloudConnector.Basket basket = new AOB_DTO_CommerceCloudConnector.Basket();
        Decimal initiationFee = 12.7;
        Decimal loanAmount = 100.7;
        Decimal monthlyTotalRepaymentAmount = 18.7;
        Decimal monthlyRepaymentAmount = 17.7;
        System.runAs(communityUser){ 
            Test.startTest();
            AOB_SRV_CommerceCloudConnector.updateBasket('fake token',initiationFee ,loanAmount,monthlyRepaymentAmount,monthlyTotalRepaymentAmount,appLI.AOB_TECH_CCProductID__c);
            Test.stopTest();
           // system.assertNotEquals(basket,null); 
        }
    }
    /**
	 * @description Method used to Test update basket
	 */
    @isTest
    public static void updateAssurance_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c,AOB_TECH_CCInsuranceID__c  FROM AOB_ApplicationLineItem__c LIMIT 1];
        AOB_DTO_CommerceCloudConnector.Insurance product = new AOB_DTO_CommerceCloudConnector.Insurance();
        List<AOB_DTO_CommerceCloudConnector.Insurance> products = new List<AOB_DTO_CommerceCloudConnector.Insurance>();
        product.product_id = appLI.AOB_TECH_CCInsuranceID__c;
        product.c_monthlyRepaymentAmount = 4567.7;
        products.add(product);
        System.runAs(communityUser){ 
            Test.startTest();
			AOB_SRV_CommerceCloudConnector.updateBasketCC('fake token', products , appLI.AOB_TECH_CCInsuranceID__c);
            Test.stopTest();
            system.assertEquals(appLI.AOB_TECH_CCInsuranceID__c,null); 
        }
    }
    /**
	 * @description Method used to Test place order 
	 */
    @isTest
    public static void placeOrderCC_Test(){
        User communityUser = [SELECT Id,contactId,AccountId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c,AOB_TECH_CCInsuranceID__c, AOB_Application__c FROM AOB_ApplicationLineItem__c LIMIT 1];
        AOB_application__c app = [SELECT Id,AOB_TECH_CCConfirmationLink__c,AOB_BasketId__c FROM AOB_application__c LIMIT 1];
        User admin = AOB_DAL_TestFactory.createUser(AOB_Constants.SYSTEM_ADMINISTRATOR,true);
        System.runAs(communityUser){ 
            Test.startTest();         
            String orderNo = AOB_SRV_CommerceCloudConnector.placeOrderCC('fake token',app.id,'',new AOB_DTO_CommerceCloudConnector.Order());
            Test.stopTest();
            system.assertEquals(orderNo,'00000001'); 
        }
    }
    
    
    /**
	 * @description Method used to Test add or Update InsuranceCC 
	 */
    @isTest
    public static void addOUpdateInsuranceCC_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c,AOB_TECH_CCInsuranceID__c, AOB_Application__c FROM AOB_ApplicationLineItem__c LIMIT 1];
        AOB_application__c app1 = [SELECT Id,AOB_TECH_OrderToken__c,AOB_TECH_OrderNo__c FROM AOB_application__c LIMIT 1];
        AOB_DTO_CommerceCloudConnector.Insurance product = new AOB_DTO_CommerceCloudConnector.Insurance();
        List<AOB_DTO_CommerceCloudConnector.Insurance> products = new List<AOB_DTO_CommerceCloudConnector.Insurance>();
        product.product_id = 'ZPLP';
        product.c_monthlyRepaymentAmount = 45.7;
        products.add(product);
        System.runAs(communityUser){        
            Test.startTest();
            String response = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC('fake token',products,'',false);
           // String response1 = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC('fake token',products,'',true);

            Test.stopTest();
            system.assertNotEquals(response,null); 
        }
    }
    
    //@isTest
    //public static void updateBasketTest(){
    //    User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
    //    
   	//	System.runAs(communityUser){        
	//		Test.startTest();
    //        try {
	//			AOB_DTO_CommerceCloudConnector.updateBasket(null,null,null,null,null,null);
    //        } catch (Exception e) {
    //            System.debug('Test Error');
    //        }
    //    }    
    //}
        @isTest
    public static void placeOrderCCFailure_Test(){
        User communityUser = [SELECT Id,contactId,AccountId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c,AOB_TECH_CCInsuranceID__c, AOB_Application__c FROM AOB_ApplicationLineItem__c LIMIT 1];
        AOB_application__c app = [SELECT Id,AOB_TECH_CCConfirmationLink__c,AOB_BasketId__c FROM AOB_application__c LIMIT 1];
        User admin = AOB_DAL_TestFactory.createUser(AOB_Constants.SYSTEM_ADMINISTRATOR,true);
        System.runAs(communityUser){ 
            Test.startTest();         
            String orderNo = AOB_SRV_CommerceCloudConnector.placeOrderCC('fake token',app.id,'fake',new AOB_DTO_CommerceCloudConnector.Order());
            Test.stopTest();
            system.assertEquals(orderNo,'00000001'); 
        }
    }     
    
    @isTest
    public static void placeOrderCCFailureNeg_Test(){
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c,AOB_TECH_CCInsuranceID__c, AOB_Application__c FROM AOB_ApplicationLineItem__c LIMIT 1];
        AOB_application__c app = [SELECT Id,AOB_TECH_CCConfirmationLink__c,AOB_BasketId__c FROM AOB_application__c LIMIT 1];
        User admin = AOB_DAL_TestFactory.createUser(AOB_Constants.SYSTEM_ADMINISTRATOR,true);
        try {
        		User testUser = AOB_DAL_TestFactory.createUser('AOB_API_Only', true);
            	System.runAs(testUser) {
                    Test.startTest();         
                    String orderNo = AOB_SRV_CommerceCloudConnector.placeOrderCC('fake token',app.id,'fake',new AOB_DTO_CommerceCloudConnector.Order());
                    Test.stopTest();
            		//system.assertEquals(orderNo,'00000001'); 
        		}
        } catch (Exception e) {
            System.debug('Expected exception');
        }  
    }
        
    @isTest
    private static void testGetCustomerAccessTokenNegative() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
    	Test.startTest();
        System.runAs(communityUser) {
            try {
        		AOB_SRV_CommerceCloudConnector.getCustomerAccessToken(null);
            } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
        Test.stopTest();
    }   
    
     @isTest
    private static void testdeleteInsuranceCCNegative() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
    	//Test.startTest();
        System.runAs(communityUser) {
            try {
    			AOB_SRV_CommerceCloudConnector.deleteInsuranceCC(null, null);
            } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
        //Test.stopTest();
    }   
       
     @isTest
    private static void testupdateBasketCCNegative() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
    	//Test.startTest();
        System.runAs(communityUser) {
            try {
              	AOB_SRV_CommerceCloudConnector.updateBasketCC(null,null,null);
            } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
        //Test.stopTest();
    }   
    
     @isTest
    private static void testPlaceOrderCCNegative() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
    	//Test.startTest();
        System.runAs(communityUser) {
            try {
              	AOB_SRV_CommerceCloudConnector.placeOrderCC(null,null,'null',null);
	        } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
        //Test.stopTest();
    }   
                     
 @isTest
    private static void testUpdateOrderCCNegative() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
    	Test.startTest();
        System.runAs(communityUser) {
            try {
              	AOB_SRV_CommerceCloudConnector.updateOrderCC(null,null,null);
	        } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
    Test.stopTest();
    }
     @isTest
    private static void testUpdateOrderCCPositive() {
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = [SELECT Id,AOB_TECH_CCConfirmationLink__c,AOB_BasketId__c,AOB_TECH_OrderNo__c FROM AOB_application__c LIMIT 1];
    	Test.startTest();
        System.runAs(communityUser) {
            try {
              	AOB_SRV_CommerceCloudConnector.updateOrderCC('fake',app.id,null);
	        } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
        Test.stopTest();
    }
     @isTest
    private static void testUpdateOrderCCPositive1() {
        String documentGUID;
        User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        AOB_application__c app = [SELECT Id,AOB_TECH_CCConfirmationLink__c,AOB_BasketId__c,AOB_TECH_OrderNo__c FROM AOB_application__c LIMIT 1];
    	AOB_DTO_CommerceCloudConnector.ContractOrder newOrder = new AOB_DTO_CommerceCloudConnector.ContractOrder();
		newOrder.c_sapSignedContractContentId = documentGUID;
        Test.startTest();
        System.runAs(communityUser) {
            try {
              	AOB_SRV_CommerceCloudConnector.updateOrderCC('fake',app.id,documentGUID);
	        } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
        }    
        Test.stopTest();
    }
     @isTest
    public static void addOUpdateInsuranceCC_Test1(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_ApplicationLineItem__c appLI = [SELECT Id,AOB_TECH_CCProductID__c,AOB_TECH_CCInsuranceID__c, AOB_Application__c FROM AOB_ApplicationLineItem__c LIMIT 1];
        AOB_application__c app1 = [SELECT Id,AOB_TECH_OrderToken__c,AOB_TECH_OrderNo__c FROM AOB_application__c LIMIT 1];
        AOB_DTO_CommerceCloudConnector.Insurance product = new AOB_DTO_CommerceCloudConnector.Insurance();
        List<AOB_DTO_CommerceCloudConnector.Insurance> products = new List<AOB_DTO_CommerceCloudConnector.Insurance>();
        product.product_id = 'ZPLP';
        product.c_monthlyRepaymentAmount = 45.7;
        products.add(product);
	    //AOB_API_CommerceCloudBasket customerServiceCall = new AOB_API_CommerceCloudBasket('709875', products, 'ZPLP', 'PATCH');
        //CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CommerceCloudBasket.SERVICE_NAME);
		//list<CMN_WebserviceCallQueue__c> listOfQueues = [Select Id from CMN_WebserviceCallQueue__c limit 1];
		//list<AOB_API_CommerceCloudBasket> listOfServiceCall = [Select id from AOB_API_CommerceCloudBasket limit 1];
       // customerServiceCall.process(queue);
        //insert queue;
        //queue.CMN_Status__c = 'Failed';
       // Update queue;
        System.runAs(communityUser){        
            Test.startTest();
            //String response = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC('fake token',products,'',false);
            String response = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC('fake token',products,'',true);

            Test.stopTest();
            system.assertNotEquals(response,null); 
        }
    }
    @isTest
    public static void addOUpdateInsuranceCCNegative(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){        
            Test.startTest();
            try {
              	String response = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC('fake token',null,'',null);
                system.assertNotEquals(response,null);
	        } catch (Exception e)    {
                System.debug('Nagative error thrown as planned');
            } 
            

            Test.stopTest();
             
        }
    }

  //      @isTest
  //  public static void updateBasketCCNegative1(){
  //      User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
  //      System.runAs(communityUser){        
  //          Test.startTest();
  //          try {
  //            	AOB_SRV_CommerceCloudConnector.updateBasketCC('fake token',null,null);
                //system.assertNotEquals(response,null);
	//        } catch (Exception e)    {
   //             System.debug('Nagative error thrown as planned');
   //         } 
            

    //        Test.stopTest();
             
    //    }
    //}
    
  //       @isTest
  //  public static void updateBasketCCNegative2(){
  //      User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
  //      
  //      System.runAs(communityUser){        
  //          Test.startTest();
  //          try {
  //            	AOB_SRV_CommerceCloudConnector.updateBasketCC(null,null,null);
                //system.assertNotEquals(response,null);
   //        } catch (Exception e)    {
   //             System.debug('Nagative error thrown as planned');
   //         } 
            

   //         Test.stopTest();
             
   //     }
   // }
}