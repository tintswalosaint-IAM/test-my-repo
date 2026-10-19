/**
 * @description Class has base methods that can be used to test and outbound service
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_API_RestBaseOutboundTestHelper
{
	private static final String ERROR_STATUS = 'Status invalid.';

	/**
	 * @description Will test successful execution of a web service call
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggerObjectId Id of the triggering object (optional)
	 *
	 * @return The handler executing the webservice (not if unsuccessful and exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCall(String webserviceName, Id triggerObjectId)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggerObjectId);
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description Will test successful execution of a web service call
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggerObjectId Id of the triggering object (optional)
	 * @param transformerClassName Class name to which to transform handler response
	 *
	 * @return The handler executing the webservice (not if unsuccessful and exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCallWithTransformation(String webserviceName, Id triggerObjectId, String transformerClassName)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggerObjectId);
		CMN_API_HttpBase handler = (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		System.assert(handler instanceof CMN_API_RestBaseOutbound, 'Handler not of type CMN_API_RestBaseOutbound');

		CMN_DTO_Base dtoBase = ((CMN_API_RestBaseOutbound)handler).transformResponse(transformerClassName);
		System.assertEquals(true, dtoBase != null, 'response transformed');
		System.debug('Transformed Response:' + dtoBase.serialize());

		return handler;
	}

	/**
	 * @description Will test successful execution was successful but transformation failed due to invalid transformerClassName
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggerObjectId Id of the triggering object (optional)
	 * @param transformerClassName Class name to which to transform handler response
	 *
	 * @return The handler executing the webservice (not if unsuccessful and exception will be thrown)
	 */
	@TestVisible
	private static CMN_DTO_Base successfulCallWithInvalidTransformation(String webserviceName, Id triggerObjectId, String transformerClassName)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggerObjectId);
		CMN_API_HttpBase handler = (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		System.assert(handler instanceof CMN_API_RestBaseOutbound, 'Handler not of type CMN_API_RestBaseOutbound');

		CMN_DTO_Base dtoBase;
		try
		{
			dtoBase = ((CMN_API_RestBaseOutbound)handler).transformResponse(transformerClassName);
		}
		catch(Exception error)
		{
			System.assert(true, 'Exception was thrown as expected');
		}

		System.assertEquals(null, dtoBase, 'Exception was not thrown as expected');

		return dtoBase;
	}

	/**
	 * @description Tests that an API call is made successfully
	 *
	 * @param queueItems The queue items to process
	 *
	 * @return A list of handlers that processed the request
	 */
	@TestVisible
	private static List<CMN_API_HttpBase> successfulCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (successfulCall):' + response.callResult);
			System.assertEquals(true, response.callResult.completed, ERROR_STATUS);
			System.assertEquals(true, String.isNotBlank(response.getQueueItem().CMN_Response__c), 'QueueItem response not set');
			System.assertNotEquals(CMN_DAL_WebserviceCallQueue.EMPTY_JSON_RESPONSE, response.getQueueItem().CMN_Response__c, 'Response Empty JSON');
		}

		return responses;
	}

	/**
	 * @description Will run a successful api call
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggeringObjectId id of the triggering object (optional)
	 * @param parameterName Name of a parameter to pass to the service handler
	 *
	 * @return The handler executing the webservice (not if unsuccessful an exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCall(String webserviceName, Id triggeringObjectId, String parameterName)
	{
		return successfulCall(webserviceName, triggeringObjectId, new Set<String> {parameterName});
	}

	/**
	 * @description Will run a successful api call
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggeringObjectId id of the triggering object (optional)
	 * @param parameterNames Names of a parameter to pass to the service handler
	 *
	 * @return The handler executing the webservice (not if unsuccessful an exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCall(String webserviceName, Id triggeringObjectId, Set<String> parameterNames)
	{
		Map<String, String> parameterMap = new Map<String, String>();

		for(String parameterName : parameterNames)
		{
			parameterMap.put(parameterName, CMN_DAL_SObjectDomain.generateRandomName());
		}

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggeringObjectId, parameterMap);
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description Will run a successful api call
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggeringObjectId id of the triggering object (optional)
	 * @param parameters Map of parameters to pass to the webservice
	 *
	 * @return The handler executing the webservice (not if unsuccessful an exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCall(String webserviceName, Id triggeringObjectId, Map<String, String> parameters)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggeringObjectId, parameters);
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description Will run a successful api call and then check that the method to transform response to table is properly implemented
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggeringObjectId id of the triggering object (optional)
	 * @param parameters Map of parameters to pass to the webservice
	 *
	 * @return he handler executing the webservice (not if unsuccessful an exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCallHasTableTransformer(String webserviceName, Id triggeringObjectId, Map<String, String> parameters)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggeringObjectId, parameters);
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description Will run a successful api call and then check that the method to transform response to table is properly implemented
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggeringObjectId id of the triggering object (optional)
	 * @param parameterName Name of a parameter to pass to the service handler (optional)
	 *
	 * @return The handler executing the webservice (not if unsuccessful an exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCallHasTableTransformer(String webserviceName, Id triggeringObjectId, String parameterName)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggeringObjectId, parameterName, CMN_DAL_SObjectDomain.generateRandomName());
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description Will run a successful api call and then check that the method to transform response to table is properly implemented
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggerObjectId Id of the triggering object (optional)
	 *
	 * @return The handler executing the webservice (not if unsuccessful and exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase successfulCallHasTableTransformer(String webserviceName, Id triggerObjectId)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggerObjectId);
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description Will run a successful api call and then check that the method to transform response to table is properly implemented
	 *
	 * @param queueItems A list of items to execute
	 *
	 * @return A list of the service handlers that executed the requests
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 */
	@TestVisible
	private static List<CMN_API_HttpBase> successfulCallHasTableTransformer(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		List<CMN_API_HttpBase> handlers = successfulCall(queueItems);

		for(CMN_API_HttpBase handler : handlers)
		{
			CMN_API_HttpBaseOutbound baseHandler = (CMN_API_HttpBaseOutbound)handlers.iterator().next();

			CMN_API_HttpBaseOutbound.DTO_BaseTable table = baseHandler.getResponseAsTable();
			System.assertEquals(false, table.columns == null || table.columns.isEmpty(), 'Columns not added as expected');
			System.assertEquals(false, table.rows == null || table.rows.isEmpty(), 'Rows not added as expected');
		}

		return handlers;
	}

	/**
	 * @description This method is use to test the date from API call if failed
	 *
	 * @param queueItems as input
	 */
	@TestVisible
	private static void failedCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;

		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (failedCall):' + response.callResult);
			//First test that all the calls have an error status
			System.assertEquals(true, response.callResult.failed, ERROR_STATUS);
			//Then check that the response body is what we expect
			System.assertEquals(CMN_API_HttpBase.ERR_INTERNAL_SERVER, response.callResult.responseBody);
		}
	}

	/**
	 * @description This method is use to test scenario when parse failed of a response
	 *
	 * @param queueItems as input
	 */
	@TestVisible
	private static void parseFailed(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		CMN_API_HttpBaseOutboundMock.failParse = true;

		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (parseFailed):' + response.callResult);
			System.assertEquals(true, response.callResult.failed, ERROR_STATUS);
		}
	}

	/**
	 * @description This method is use to test the Webservice call when the API abort
	 *
	 * @param queueItems as input
	 *
	 * @return list of http bases
	 *
	 * @see CMN_API_HttpBase.abortRequest
	 */
	@TestVisible
	private static List<CMN_API_HttpBase> abortedCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (abortedCall):' + response.callResult);
			System.assertEquals(true, response.callResult.aborted, ERROR_STATUS);
		}

		return responses;
	}

	/**
	 * @description This method is used to test that a webservice call aborts as expected
	 *
	 * @param webserviceName The class name of the webservice handler
	 * @param triggerObjectId The object that triggered the callout (optional)
	 *
	 * @return A list of handlers
	 *
	 * @see CMN_API_HttpBase.abortRequest
	 */
	@TestVisible
	private static CMN_API_HttpBase abortedCall(String webserviceName, Id triggerObjectId)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggerObjectId);
		return (CMN_API_HttpBase)abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}

	/**
	 * @description This method is used to test that a webservice call aborts as expected
	 *
	 * @param webserviceName The name of the web service handler
	 * @param triggeringObjectId id of the triggering object (optional)
	 * @param parameters Map of parameters to pass to the webservice
	 *
	 * @return The handler executing the webservice (not if not aborted an exception will be thrown)
	 */
	@TestVisible
	private static CMN_API_HttpBase abortedCall(String webserviceName, Id triggeringObjectId, Map<String, String> parameters)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(webserviceName, triggeringObjectId, parameters);
		return (CMN_API_HttpBase)CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();
	}
}