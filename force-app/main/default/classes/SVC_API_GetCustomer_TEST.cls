/**
 * @description Test class for SVC_API_GetCustomer
 *
 * @see SVC_API_GetCustomer
 *
 * @author Accenture
 *
 * @date April 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetCustomer_TEST
{
	private static Integer nUMBEROFITEMSTOCREATE = 10;

	/**
	 * @description Sets up the RestContext Objects
	 */
	private static void setupRestContext()
	{
		CMN_API_InboundTestHelper.setupRestContext();
	}

	/**
	 * @description Check that a customer can be found via Identity Number
	 */
	@IsTest
	private static void findByIdentityNumber()
	{
		setupRestContext();

		SVC_DAL_DataFactory.generatePersonAccounts(nUMBEROFITEMSTOCREATE);

		//This parameter should be used, but since no account exists, we expected the ID parameter to be checked new
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_EXTERNAL_ID, CMN_DAL_SObjectDomain.generateRandomNumber());
		IdentityDocument newIdentityDocument = (IdentityDocument)CMN_UTIL_System.getRandomItem(SVC_DAL_IdentityDocument.getAll());

		//We're expecting account to be retrieved correctly
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_ID_NUMBER, newIdentityDocument.Name);

		Test.startTest();

		SVC_URL_Customer.findCustomer();
		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_GetCustomer.SERVICE_NAME);
		SVC_API_GetCustomer.DTO_Response dtoResponse = (SVC_API_GetCustomer.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetCustomer.DTO_Response.class);

		Test.stopTest();

		System.assertEquals(newIdentityDocument.RelatedLegalEntityId, dtoResponse.id, 'Incorrect customer found');
	}
	/**
	 * @description Check that a customer can be found by External Id
	 */
	@IsTest
	private static void findByExternalId()
	{
		setupRestContext();

		Account newAccount = (Account)CMN_UTIL_System.getRandomItem(SVC_DAL_DataFactory.generatePersonAccounts(nUMBEROFITEMSTOCREATE));

		//The system should find the account by external id and not use the identity document
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_EXTERNAL_ID, newAccount.ExternalCIFId__c);
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_ID_NUMBER, CMN_DAL_SObjectDomain.generateRandomNumber());

		Test.startTest();

		SVC_URL_Customer.findCustomer();
		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_GetCustomer.SERVICE_NAME);
		SVC_API_GetCustomer.DTO_Response dtoResponse = (SVC_API_GetCustomer.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetCustomer.DTO_Response.class);

		Test.stopTest();

		System.assertEquals(newAccount.Id, dtoResponse.id, 'Incorrect customer found');
	}

	/**
	 * @description Check that a customer can be found via Phone Number
	 */
	@IsTest
	private static void findByPhoneNumber()
	{
		setupRestContext();

		Account newAccount = (Account)CMN_UTIL_System.getRandomItem(SVC_DAL_DataFactory.generatePersonAccounts(nUMBEROFITEMSTOCREATE));

		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_EXTERNAL_ID, CMN_DAL_SObjectDomain.generateRandomNumber());
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_ID_NUMBER, CMN_DAL_SObjectDomain.generateRandomNumber());
		//System must use the phone number to retrieve the account
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_PHONE, newAccount.Phone);

		Test.startTest();

		SVC_URL_Customer.findCustomer();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_GetCustomer.SERVICE_NAME);

		SVC_API_GetCustomer.DTO_Response dtoResponse = (SVC_API_GetCustomer.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetCustomer.DTO_Response.class);

		Test.stopTest();

		System.assertEquals(newAccount.Id, dtoResponse.id, 'Incorrect customer found');
	}

	/**
	 * @description Check that no customer is found if external id is provided that isn't unique
	 */
	@IsTest
	private static void externalIdNotUnique()
	{
		setupRestContext();

		List<Account> newAccounts = SVC_DAL_DataFactory.generatePersonAccounts(nUMBEROFITEMSTOCREATE);

		Account newAccount1 = newAccounts[0];
		Account newAccount2 = newAccounts[1];

		newAccount2.ExternalCIFId__c = newAccount1.ExternalCIFId__c;
		update newAccount2;

		//No results should be returned for this external Id as it's duplicated
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_EXTERNAL_ID, newAccount1.ExternalCIFId__c);

		Test.startTest();

		SVC_URL_Customer.findCustomer();
		SVC_API_GetCustomer.DTO_Response dtoResponse = (SVC_API_GetCustomer.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetCustomer.DTO_Response.class);
		
		Test.stopTest();
		System.assertEquals(null, dtoResponse.id, 'No Customer should be found.');
	}

	/**
	 * @description Check that no customer is found if phone number is provided that isn't unique
	 */
	@IsTest
	private static void phoneNotUnique()
	{
		setupRestContext();

		List<Account> newAccounts = SVC_DAL_DataFactory.generatePersonAccounts(nUMBEROFITEMSTOCREATE);

		Account newAccount1 = newAccounts[0];
		Account newAccount2 = newAccounts[1];

		newAccount2.Phone = newAccount1.Phone;
		update newAccount2;

		//No results should be returned for this Phone Number as it's duplicated
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_PHONE, newAccount1.Phone);

		Test.startTest();

		SVC_URL_Customer.findCustomer();

		SVC_API_GetCustomer.DTO_Response dtoResponse = (SVC_API_GetCustomer.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetCustomer.DTO_Response.class);

		Test.stopTest();

		System.assertEquals(null, dtoResponse.id, 'No Customer should be found.');
	}

	/**
	 * @description Check that no customer is found if identity number is provided that isn't unique
	 */
	@IsTest
	private static void identityNumberNotUnique()
	{
		setupRestContext();

		SVC_DAL_DataFactory.generatePersonAccounts(nUMBEROFITEMSTOCREATE);

		List<IdentityDocument> newIdentityDocuments = SVC_DAL_IdentityDocument.getAll();

		IdentityDocument newIdentityDocument1 = newIdentityDocuments[0];
		IdentityDocument newIdentityDocument2 = newIdentityDocuments[1];

		newIdentityDocument2.Name = newIdentityDocument1.Name;
		update newIdentityDocument2;

		//No results should be returned for this Identity Number as it's duplicated
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_ID_NUMBER, newIdentityDocument1.Name);

		Test.startTest();

		SVC_URL_Customer.findCustomer();

		SVC_API_GetCustomer.DTO_Response dtoResponse = (SVC_API_GetCustomer.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetCustomer.DTO_Response.class);

		Test.stopTest();

		System.assertEquals(null, dtoResponse.id, 'No Customer should be found.');
	}

	/**
	 * @description Check that error is thrown if no valid parameters are provided
	 */
	@IsTest
	private static void noParametersProvided()
	{
		setupRestContext();

		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_EXTERNAL_ID, CMN_UTIL_String.EMPTY);
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_ID_NUMBER, CMN_UTIL_String.EMPTY);
		RestContext.request.addParameter(SVC_API_GetCustomer.QUERY_PARAM_PHONE, CMN_UTIL_String.EMPTY);

		Test.startTest();

		SVC_URL_Customer.findCustomer();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_GetCustomer.SERVICE_NAME, SVC_API_GetCustomer.ERROR_PREFIX);

		Test.stopTest();

		System.AssertNotEquals(SVC_API_GetCustomer.QUERY_PARAM_EXTERNAL_ID,'123', 'Value are different');
	}
}