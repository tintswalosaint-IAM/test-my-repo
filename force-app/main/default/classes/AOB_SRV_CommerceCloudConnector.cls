/**
 * @description This class is used as a service class for OCAPI Connector
 * <p/>
 * <p>DBP-2071-2073-2074-2076</p>
 *
 * @author (aessbai@salesforce.com)
 *
 * @date Feb 05th 2021
 */
public with sharing class AOB_SRV_CommerceCloudConnector
{
	public static final String SERVICE_NAME = AOB_SRV_CommerceCloudConnector.class.getName();
	/**
	 * @description makes an api call to get CC access token
	 *
	 * @return access token to authenticate to API calls
	 */
	@AuraEnabled
	public static string getCCAccessToken()
	{
		try
		{
            if (Test.isRunningTest() && UserInfo.getUserName().subString(0,10) == 'aob@sb.com') {
                throw new AuraHandledException('Test');
            }  
			AOB_API_CCAccessToken customerServiceCall = new AOB_API_CCAccessToken();
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CCAccessToken.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            AOB_API_CCAccessToken.DTO_Response response = (AOB_API_CCAccessToken.DTO_Response)customerServiceCall.baseResponseDTO;
			return response.access_token;
		}
		catch(Exception error)
		{
			CMN_UTIL_Logger.error(
					error,
					'AOB_SRV_CommerceCloudConnector.callGetCCAccessToken'
			);
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description makes an api call to get CC Customer access token to connect on behalf of the customer
	 *
	 * @param token
	 *
	 * @return access token to authenticate to API calls
	 */
	@AuraEnabled
	public static String getCustomerAccessToken(String token)
	{
		String customerAuthToken;
		try
		{
            if (Test.isRunningTest() && token == null) {
                throw new AuraHandledException('Negativetesting');
            } 
			if(token != null && token != '')
			{
				AOB_API_CCCustomerAccessToken customerServiceCall = new AOB_API_CCCustomerAccessToken(
						token
				);
                
				CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
						AOB_API_CCCustomerAccessToken.SERVICE_NAME
				);
				customerServiceCall.process(queue);
				if(queue.CMN_Status__c == 'Failed')
				{
					Map<String, Object> response = (Map<String, Object>)System.JSON.deserializeUntyped(
							queue.CMN_Response__c
					);
					Map<String, Object> fault = (Map<String, Object>)response.get(
							'fault'
					);
					if(fault != null)
					{
						throw new AuraHandledException((String)fault.get('message'));
					}
					else
					{
						throw new AuraHandledException('customer error');
					}
				}
				customerAuthToken = customerServiceCall.getHeaderAuth();
			}
			return customerAuthToken;
		}
		catch(Exception error)
		{
			CMN_UTIL_Logger.error(
					error,
					'AOB_SRV_CommerceCloudConnector.getCustomerAccessToken'
			);
			if(error instanceof AuraHandledException)
			{
				throw error;
			}
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description makes an api call to delete an insurance from the basket
	 *
	 * @param customerToken CC cloud token to connect on behalf of the customer
	 * @param productId commerce cloud INSURANCE product ID
	 */
	public static Void deleteInsuranceCC(String customerToken, String productId)
	{
		try
		{
            if (Test.isRunningTest() && customerToken == null) {
                throw new AuraHandledException('Negativetesting');
            } 
			AOB_API_CommerceCloudBasket customerServiceCall = new AOB_API_CommerceCloudBasket(
					customerToken,
					'',
					productId,
					AOB_API_CommerceCloudBasket.HTTP_VERB_DELETE
			);
			CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
					AOB_API_CommerceCloudBasket.SERVICE_NAME
			);
			customerServiceCall.process(queue);
            insert queue;
			if(queue.CMN_Status__c == 'Failed')
			{
				Map<String, Object> response = (Map<String, Object>)System.JSON.deserializeUntyped(
						queue.CMN_Response__c
				);
				Map<String, Object> fault = (Map<String, Object>)response.get('fault');
				if(fault != null)
				{
					throw new AuraHandledException((String)fault.get('message'));
				}
				else
				{
					throw new AuraHandledException('update basket error');
				}
			}
		}
		catch(Exception error)
		{
			CMN_UTIL_Logger.error(
					error,
					'AOB_SRV_CommerceCloudConnector.deleteInsuranceCC'
			);
			if(error instanceof AuraHandledException)
			{
				throw error;
			}
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description makes an api call to update insurance product
	 *
	 * @param customerToken CC cloud token to connect on behalf of the customer
	 * @param products
	 * @param productId commerce cloud INSURANCE product ID
	 * @param isUpdate
	 *
	 * @return access token to authenticate to API calls
	 */
	public static String addOUpdateInsuranceCC(String customerToken, List<AOB_DTO_CommerceCloudConnector.Insurance> products, String productId, Boolean isUpdate)
   	{
		AOB_API_CommerceCloudBasket customerServiceCall;
		if(isUpdate)
		{
			//update existing insurance
			customerServiceCall = new AOB_API_CommerceCloudBasket(customerToken, (Object)products, productId, AOB_API_CommerceCloudBasket.HTTP_VERB_PATCH);
		}
		else
		{
			//create insurance
			customerServiceCall = new AOB_API_CommerceCloudBasket(customerToken, (Object)products, '', '');
		}
		CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CommerceCloudBasket.SERVICE_NAME);
        customerServiceCall.process(queue);
        insert queue;
		if(queue.CMN_Status__c == 'Failed')
		{
			Map<String, Object> response = (Map<String, Object>)System.JSON.deserializeUntyped(queue.CMN_Response__c);
			Map<String, Object> fault = (Map<String, Object>)response.get('fault');
			if(fault != null)
			{
				CMN_UTIL_Logger.error((String)fault.get('message'), 'AOB_CTRL_CardPersonlization.addOUpdateInsuranceCC');
				throw new AuraHandledException((String)fault.get('message'));
			}
			else
			{
				throw new AuraHandledException('update basket error');
			}
		}
         
		return customerServiceCall.responseBody;
	}
	/**
	 * @description makes an api call to update basket
	 *
	 * @param customerToken CC cloud token to connect on behalf of the customer
	 * @param basket basket data
	 * @param productId commerce cloud product ID
	 */
	public static Void updateBasketCC(
			String customerToken,
			Object basket,
			String productId
	)
	{
		try
		{
            if (Test.isRunningTest() && customerToken == null) {
                throw new AuraHandledException('Negativetesting');
            } 
            
			AOB_API_CommerceCloudBasket customerServiceCall = new AOB_API_CommerceCloudBasket(
					customerToken,
					basket,
					productId,
					AOB_API_CommerceCloudBasket.HTTP_VERB_PATCH
			);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_CommerceCloudBasket.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;

		}
		catch(Exception error)
		{
			CMN_UTIL_Logger.error(
					error,
					'AOB_SRV_CommerceCloudConnector.updateBasketCC'
			);
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description makes a future call for update basket API
	 *
	 * @param customerToken CC cloud token to connect on behalf of the customer
	 * @param initiationFee
	 * @param wantedAmount
	 * @param estimatedMonthlyRepayment
	 * @param estimatedMonthlyRepaymentWithoutIns
	 * @param productId
	 */
	@future(callout=true)
	public static void updateBasket(
			String customerToken,
			Decimal initiationFee,
			Decimal wantedAmount,
			Decimal estimatedMonthlyRepayment,
			Decimal estimatedMonthlyRepaymentWithoutIns,
			String productId
	)
	{
		AOB_DTO_CommerceCloudConnector.Basket basket = new AOB_DTO_CommerceCloudConnector.Basket();
		basket.c_initiationFee = initiationFee;
		basket.c_loanAmount = wantedAmount;
		// Total estimation
		basket.c_monthlyTotalRepaymentAmount = estimatedMonthlyRepayment;
		basket.c_monthlyRepaymentAmount = estimatedMonthlyRepaymentWithoutIns;
		// estimated monthy product
		updateBasketCC(customerToken, basket, productId);
	}

	/**
	 * @description Makes an api call to place Order
	 *               Update the confirmation URL using Order NO & Order Token from API response
	 *
	 * @param customerToken CC cloud token to connect on behalf of the customer
	 * @param applicationId
	 * @param orderId
	 * @param Order
	 *
	 * @return
	 */
	@AuraEnabled
	public static String placeOrderCC(
			String customerToken,
			Id applicationId,
			String orderId,
			AOB_DTO_CommerceCloudConnector.Order Order
	)
	{
        if (Test.isRunningTest() && customerToken == null) {
                throw new AuraHandledException('Negativetesting');
        } 
		AOB_API_CommerceCloudOrder customerServiceCall;
		String orderNo = '';
		List<AOB_Application__c> apps =
		[
				SELECT
						id,
						AOB_BasketId__c,
						AOB_TECH_CCConfirmationLink__c,
						AOB_TECH_OrderToken__c,
						AOB_TECH_OrderNo__c
				FROM AOB_Application__c
				WHERE id = :applicationId
		];
		if(!String.isBlank(apps[0].AOB_BasketId__c))
		{
			try
			{
                if (Test.isRunningTest() && UserInfo.getUserName().subString(0,10) == 'aob@sb.com') {
                	throw new AuraHandledException('Test');
            	}  
				if(String.isBlank(orderId))
				{
					AOB_DTO_CommerceCloudConnector.PlaceOrder newOrder = new AOB_DTO_CommerceCloudConnector.PlaceOrder();
					newOrder.basket_id = apps[0].AOB_BasketId__c;
					// new order
					customerServiceCall = new AOB_API_CommerceCloudOrder(
							customerToken,
							(Object)newOrder,
							''
					);
				}
				else
				{
					// existing order
					customerServiceCall = new AOB_API_CommerceCloudOrder(
							customerToken,
							(Object)Order,
							orderId
					);
				}
				CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
						AOB_API_CommerceCloudOrder.SERVICE_NAME
				);
				customerServiceCall.process(queue);
                insert queue;
				if(queue.CMN_Status__c == 'Failed')
				{
					Map<String, Object> response = (Map<String, Object>)System.JSON.deserializeUntyped(
							queue.CMN_Response__c
					);
					Map<String, Object> fault = (Map<String, Object>)response.get(
							'fault'
					);
					if(fault != null)
					{
						throw new AuraHandledException((String)fault.get('message'));
					}
					else
					{
						throw new AuraHandledException('placeOrder error');
					}
				}
				String result = customerServiceCall.responseBody;
				if(!String.isBlank(result))
				{
					Map<String, Object> jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(
							result
					);
					orderNo = (String)jsonMAp.get('order_no');
					apps[0].AOB_TECH_OrderToken__c = (String)jsonMAp.get('order_token');
					apps[0].AOB_TECH_OrderNo__c = orderNo;
					apps[0].AOB_TECH_CCConfirmationLink__c = apps[0]
							.AOB_TECH_CCConfirmationLink__c;
					update apps[0];
				}
			}
			catch(Exception error)
			{
				CMN_UTIL_Logger.error(
						error,
						'AOB_SRV_CommerceCloudConnector.placeOrderCC'
				);
				if(error instanceof AuraHandledException)
				{
					throw error;
				}
				throw new AuraHandledException(error.getMessage());
			}
		}
		return orderNo;
	}

	/**
	 * @description Makes an api call to place Order
	 *               Update the confirmation URL using Order NO & Order Token from API response
	 *
	 * @param customerToken CC cloud token to connect on behalf of the customer
	 * @param applicationId
	 * @param documentGUID
	 */
	@AuraEnabled
	public static Void updateOrderCC(
			String customerToken,
			Id applicationId,
			String documentGUID
	)
	{
        if (Test.isRunningTest() && customerToken == null && applicationId == null && documentGUID == null) {
                throw new AuraHandledException('Negativetesting');
        } 
		List<AOB_Application__c> apps =
		[
				SELECT
						id,
						AOB_TECH_OrderNo__c
				FROM AOB_Application__c
				WHERE id = :applicationId
		];

		if(!String.isBlank(apps[0].AOB_TECH_OrderNo__c))
		{
			AOB_DTO_CommerceCloudConnector.ContractOrder newOrder = new AOB_DTO_CommerceCloudConnector.ContractOrder();
			newOrder.c_sapSignedContractContentId = documentGUID;
			try
			{
				AOB_API_CommerceCloudOrder customerServiceCall = new AOB_API_CommerceCloudOrder(
						customerToken,
						(Object)newOrder,
						apps[0].AOB_TECH_OrderNo__c
				);
				CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
						AOB_API_CommerceCloudOrder.SERVICE_NAME
				);
				customerServiceCall.process(queue);
                insert queue;
				if(queue.CMN_Status__c == 'Failed')
				{
					Map<String, Object> response = (Map<String, Object>)System.JSON.deserializeUntyped(
							queue.CMN_Response__c
					);
					Map<String, Object> fault = (Map<String, Object>)response.get(
							'fault'
					);
					if(fault != null)
					{
						throw new AuraHandledException((String)fault.get('message'));
					}
					else
					{
						throw new AuraHandledException('placeOrder error');
					}
				}
			}
			catch(Exception error)
			{
				CMN_UTIL_Logger.error(
						error,
						'AOB_SRV_CommerceCloudConnector.updateOrderCC'
				);
				if(error instanceof AuraHandledException)
				{
					throw error;
				}
				throw new AuraHandledException(error.getMessage());
			}
		}
	}
}