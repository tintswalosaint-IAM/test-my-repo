/**
 * @description Rest Resource for processing Inbound Service
 *
 * @author Accenture
 * 
 * @date 2021
 */
@RestResource(UrlMapping='/v1/Customer/*')
global inherited sharing class SVC_URL_Customer
{
	/**
	 * @description Will retrieve attributes for an existing customer
	 */
	@HttpGet
	global static void findCustomer()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(SVC_API_GetCustomer.SERVICE_NAME);
	}
}