/**
 * @description Test class to test all trigger functions (uses underlying bulk functions)
 *               Used to instantiate and execute Trigger Handlers associated with SObjects.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
//@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') //Class using Test Helper classes
private class CMN_FACTORY_WebserviceManager_TEST {

	private static final Integer INVALID_RETRIES = 1000;
	/**
	 * @description Method to test queue items in a separate transaction
	 * from the changes as a result of API calls
	 *
	 * @param serviceName as input
	 */
	
	 private static void runServiceNameTest(String serviceName) {
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(serviceName);
		Test.startTest();
		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		Test.stopTest();
		List<CMN_WebserviceCallQueue__c> foundItems = CMN_DAL_WebserviceCallQueue.findByServiceName(queueItem.CMN_Service__c);
		Assert.areEqual(false, foundItems.isEmpty(), 'No queue items were saved as expected.');
		Assert.areEqual(CMN_DAL_WebserviceCallQueue.STATUS_ABORTED, foundItems[0].CMN_Status__c, 'Service status is incorrect.');
	}

	@IsTest
	private static void handlerClassNotFound() {
		runServiceNameTest(CMN_DAL_SObjectDomain.generateRandomName());
	}

	@IsTest
	private static void handlerClassInvalid() {
		runServiceNameTest(CMN_FACTORY_WebserviceManager.class.getName());
	}

	@IsTest
	private static void handlerCommitFailure() {
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RestOutboundExample.SERVICE_NAME);
		//The default length of this field is  2 digits; this should result in a  DML error being thrown on commit
		queueItem.CMN_Retries__c = INVALID_RETRIES;
		Test.startTest();
		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		Test.stopTest();
		List<CMN_WebserviceCallQueue__c> foundItems = CMN_DAL_WebserviceCallQueue.findByServiceName(queueItem.CMN_Service__c);
		Assert.areEqual(false, foundItems.isEmpty(), 'No queue items were saved as expected.');
		Assert.areEqual(CMN_DAL_WebserviceCallQueue.STATUS_FAILED, foundItems[0].CMN_Status__c, 'Service status is incorrect.');
	}

	/**
	 * @description create a request dto used to do a synchronous call from an invocable method
	 *
	 * @return request DTO
	 */
	private static CMN_FACTORY_WebserviceManager.DTO_Request setupRequestDto() {
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = new CMN_FACTORY_WebserviceManager.DTO_Request();
		dtoRequest.triggerObjectId = UserInfo.getUserId();
		dtoRequest.webServiceClassName = CMN_API_RestOutboundExample.SERVICE_NAME;
		dtoRequest.transformToTable = true;
		return dtoRequest;
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and returns a table response
	 */
	@IsTest
	private static void invokeSuccessfulWithTableResponse() {
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.parameters = 'foo=bar,bar=foo';
		Test.startTest();
		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		Assert.areEqual(false, dtoResponses.isEmpty(), 'No responses received');
		Assert.areEqual(true, CMN_UTIL_String.contains(dtoResponses[0].payload, 'bar'), 'Parameter not processed correctly');
		Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponses[0].payload);
		List<Object> dtoColumns = (List<Object>)attributeMap.get('columns');
		Assert.areNotEqual(true, dtoColumns.isEmpty(), 'Table has no columns.');
		List<Object> dtoRows = (List<Object>)attributeMap.get('rows');
		Assert.areNotEqual(true, dtoRows.isEmpty(), 'Table has no rows.');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class a transformed class
	 */
	@IsTest
	private static void invokeSuccessfulWithTransformedResponse() {
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		dtoRequest.transformClassName = CMN_API_RestOutboundExample.DTO_Table.class.getName();
		Test.startTest();
		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		Assert.areEqual(false, dtoResponses.isEmpty(), 'No responses received');
		Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponses[0].payload);
		List<Object> dtoColumns = (List<Object>)attributeMap.get('columns');
		Assert.areNotEqual(true, dtoColumns.isEmpty(), 'Table has no columns.');
		List<Object> dtoRows = (List<Object>)attributeMap.get('rows');
		Assert.areNotEqual(true, dtoRows.isEmpty(), 'Table has no rows.');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and returns a element value from the response JSON
	 */
	@IsTest
	private static void invokeSuccessfulWithElementValueResponse() {
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		dtoRequest.elementName = CMN_API_RestOutboundExample.TITLE_FIELD_NAME;
		Test.startTest();
		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		Assert.areEqual(false, dtoResponses.isEmpty(), 'No responses received');
		Assert.areEqual(true, String.isNotBlank(dtoResponses[0].elementValue), 'Element value was not extracted');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class and returns a table response
	 */
	@IsTest
	private static void invokeSuccessfulWithInvalidTransformClassName(){
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		dtoRequest.transformClassName = CMN_API_RestOutboundExample.class.getName();
		Test.startTest();
		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		Assert.areEqual(false, dtoResponses.isEmpty(), 'No responses received');
		Assert.areEqual(true, dtoResponses.iterator().next().payload.contains(CMN_API_HttpBaseOutbound.ERROR_INVALID_TYPE), 'Exception not thrown');
	}

	/**
	 * @description Will test that service class is execute successfully through invocable class but should not return a table structure
	 */
	@IsTest
	private static void invokeSuccessfulWithStandardResponse() {
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.transformToTable = false;
		Test.startTest();
		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		Assert.areEqual(false, dtoResponses.isEmpty(), 'No responses received');
		Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponses[0].payload);
		List<Object> dtoColumns = (List<Object>)attributeMap.get('columns');
		Assert.areEqual(null, dtoColumns, 'Response should not be a table');
	}

	/**
	 * @description Test that if a handler has a failed call then response is still returned of the errors
	 */
	@IsTest
	private static void invokeFail() {
		CMN_API_HttpBaseOutboundMock.returnErrorResponse = true;
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		Test.startTest();
		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		Assert.areEqual(false, dtoResponses.isEmpty(), 'No responses received');
	}

	/**
	 * @description Will check the handling of parameters when invoking web service
	 */
	@IsTest
	private static void invokeWithInvalidParameter() {
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = setupRequestDto();
		dtoRequest.parameters = 'foo=bar=foo';
		Test.startTest();
		CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});
		Test.stopTest();
		List<sbgplatform__rflib_Log__c> appLogs = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areNotEqual(true, appLogs.isEmpty(), 'Invalid parameter not logged');
	}
}