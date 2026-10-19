/**
 * @description test class to test the Inbound API call that will echo exactly what was sent
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_API_RestInboundEcho_TEST
{
	/**
	 * @description This method is use to test a successful call to Echo service
	 */
	@IsTest
	private static void successfulCall()
	{
		DTO_InboundTest inboundRequest = new DTO_InboundTest();
		inboundRequest.helloWorld = CMN_DAL_SObjectDomain.generateRandomName();

		CMN_API_InboundTestHelper.setupRestContext(inboundRequest);
		RestContext.request.addParameter(CMN_DAL_SObjectDomain.generateRandomName(), CMN_DAL_SObjectDomain.generateRandomName());

		Test.startTest();

		CMN_URL_Echo.echo();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(CMN_API_RestInboundEcho.SERVICE_NAME);

		System.assertNotEquals(null, RestContext.response.responseBody, 'Response Body was not set.');
		System.assertEquals(inboundRequest.serialize(), RestContext.response.responseBody.toString(), 'Response does not match what was expected');
	}

	/**
	 * @description This method is use to test a failed call to Echo service
	 */
	@IsTest
	private static void failedCall()
	{
		DTO_InboundTest inboundRequest = new DTO_InboundTest();
		inboundRequest.helloWorld = CMN_DAL_SObjectDomain.generateRandomName();

		CMN_API_InboundTestHelper.setupRestContext(inboundRequest);
		RestContext.request.addParameter(CMN_DAL_SObjectDomain.generateRandomName(), CMN_DAL_SObjectDomain.generateRandomName());
		RestContext.request.addParameter(CMN_API_HttpBaseInbound.QUERY_PARAM_ADD_STACK_TRACE, String.valueOf(true));

		// this will result in an exception is throw
		CMN_API_HttpBaseInbound.returnErrorResponse = true;

		Test.startTest();

		CMN_URL_Echo.echo();

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(CMN_API_RestInboundEcho.SERVICE_NAME, CMN_UTIL_String.EMPTY);

		List<String> errors = CMN_UTIL_System.convertStringToList(queueItems.iterator().next().CMN_Errors__c, CMN_UTIL_String.CR + CMN_UTIL_String.LF);

		System.assertEquals(2, errors.size(), 'Expected Error Message and Stack Trace');
		System.assertEquals(CMN_API_HttpBaseInbound.ERROR_TEST_EXCEPTION_HANDLING, errors.iterator().next(), 'Invalid Error Message');
	}

	private class DTO_InboundTest extends CMN_DTO_JsonBase
	{
		public String helloWorld;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_InboundTest.class;
		}
	}
}