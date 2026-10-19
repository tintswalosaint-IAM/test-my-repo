/**
 * @description Test class to test the Outbound API call
 * <p/>
 * <p>VCCC-378</p>
 *
 * @see CMN_API_RestOutboundExample
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_API_RestOutboundExample_TEST
{
	/**
	 * @description To setup the List of Webservice Call Queue
	 *
	 * @return A list of queue items
	 */
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
				(
						CMN_API_RestOutboundExample.SERVICE_NAME,
						UserInfo.getUserId(),
						CMN_DAL_SObjectDomain.generateRandomName(),
						CMN_DAL_SObjectDomain.generateRandomName()
				);

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
	}

	/**
	 * @description Emulates a successful call and then checks that transformation code complete successfully
	 */
	@IsTest
	private static void successfulCallWithTransformer()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallWithTransformation(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), 'CMN_API_RestOutboundExample.DTO_Table');
	}

	/**
	 * @description Emulates a successful call and then checks that call was successful, but class name provided is invalid
	 */
	@IsTest
	private static void successfulCallWithInvalidTransformerClass()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallWithInvalidTransformation(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), UserInfo.getUserId());
	}

	/**
	 * @description Emulates a successful call and then checks that call was successful, but class name provided is invalid
	 */
	@IsTest
	private static void successfulCallWithWrongTransformClassType()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallWithInvalidTransformation(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), CMN_API_RestOutboundExample.SERVICE_NAME);
	}

	/**
	 * @description Emulates a successful call using simpler alternative
	 */
	@IsTest
	private static void successfulCallAlternative()
	{
		CMN_API_HttpBase handler = CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId());
		System.assertNotEquals(true, handler.callResult.mocking, 'Service Handler should not be mocking');
	}

	/**
	 * @description Emulates a successful call using a single parameter
	 */
	@IsTest
	private static void successfulCallWithSingleParameter()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), CMN_DAL_SObjectDomain.generateRandomName());
	}

	/**
	 * @description Emulates a successful call using parameters
	 */
	@IsTest
	private static void successfulCallWithParameters()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), new Set<String> {CMN_DAL_SObjectDomain.generateRandomName()});
	}

	/**
	 * @description Emulates a successful call using parameter map
	 */
	@IsTest
	private static void successfulCallWithParameterMap()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), parameters);
	}

	/**
	 * @description Retrieves the response as a Table using parameter input on helper class method
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 * @see CMN_API_RestOutboundExample.DTO_Table.transform
	 */
	@IsTest
	private static void responseAsTableUsingParameterMap()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), parameters);
	}

	/**
	 * @description Retrieves the response as a Table
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 * @see CMN_API_RestOutboundExample.DTO_Table.transform
	 */
	@IsTest
	private static void getResponseAsTable()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId());
	}

	/**
	 * @description Retrieves the response as a Table with alternative test that injects in a parameter
	 *
	 * @see CMN_API_HttpBaseOutbound.getResponseAsTable
	 * @see CMN_API_RestOutboundExample.DTO_Table.transform
	 */
	@IsTest
	private static void getResponseAsTableAlternative()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId(), CMN_DAL_SObjectDomain.generateRandomName());
	}

	/**
	 * @description Emulates a failed call
	 */
	@IsTest
	private static void failedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.failedCall(setup());
	}

	/**
	 * @description Emulates a failed call due to response parse failure
	 */
	@IsTest
	private static void parseFailed()
	{
		CMN_API_RestBaseOutboundTestHelper.parseFailed(setup());
	}

	/**
	 * @description Emulates a call that is aborted because no ID was provided
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	@IsTest
	private static void abortedCallNoId()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(CMN_API_RestOutboundExample.SERVICE_NAME, null);
	}

	/**
	 * @description Emulates a call that is aborted because no ID was provided, uses an overload method that takes a parameter map
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	@IsTest
	private static void abortedCallWithParameters()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(CMN_API_RestOutboundExample.SERVICE_NAME, null, parameterMap);
	}

	/**
	 * @description Emulates a call that is aborted because the API has been disabled for the current user
	 */
	@IsTest
	private static void abortAPIDisabled()
	{
		CMN_DAL_DataFactory.disableAPI(CMN_API_RestOutboundExample.SERVICE_NAME);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
	}

	/**
	 * @description Emulates a call that is returns a mock response because the API has been mocked for the current user
	 */
	@IsTest
	private static void mockAPI()
	{
		CMN_DAL_DataFactory.mockAPI(CMN_API_RestOutboundExample.SERVICE_NAME);
		CMN_API_HttpBase handler = CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId());
		System.assertEquals(true, handler.callResult.mocking, 'Service Handler is not mocking as expected');
	}

	/**
	 * @description Tests to see if the getBaseURL works as expected
	 */
	@IsTest
	private static void getBaseUrl()
	{
		CMN_API_RestOutboundExample service = new CMN_API_RestOutboundExample();

		Test.startTest();

		String baseUrl = service.getBaseUrl();

		Test.stopTest();

		System.assertNotEquals(service.getWebServiceEndPoint(), baseUrl, 'Invalid base URL');
	}

	/**
	 * @description Ensures that use of DTO Json base class thows error for a method that should be overrriden
	 */
	@IsTest
	private static void checkJsonDtoMethodOverride()
	{
		CMN_DTO_Base dtoMethodOverride = new DTO_MethodOverride();

		Test.startTest();

		try
		{
			dtoMethodOverride = dtoMethodOverride.deserialize(null);
			System.assert(false, 'Exception not thrown as expected.');
		}
		catch(JSONException jsonError)
		{
			System.assert(true, 'Exception Thrown as expected');
		}

		Test.stopTest();
	}

	/**
	 * @description Used to test base dto functionality
	 */
	private class DTO_MethodOverride extends CMN_DTO_JsonBase
	{

	}
}