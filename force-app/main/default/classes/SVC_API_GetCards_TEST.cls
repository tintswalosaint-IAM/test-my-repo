/**
 * @description Test class for SVC_API_GetCards
 *
 * @see SVC_API_GetCards
 *
 * @author Accenture
 *
 * @date May 2021
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetCards_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;

	/**
	 * @description Creates required data for test
	 */
	@TestSetup
	private static void setup()
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>
		{
				Account.SObjectType, Contact.SObjectType
		});

		SVC_DAL_DataFactory.generateAccounts(unitOfWork, NUMBER_OF_ITEMS_TO_GENERATE, true);
		SVC_DAL_DataFactory.generateContacts(unitOfWork, NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE);

		unitOfWork.commitWork();
	}

	/**
	 * @description Emulates a successful call and checks that the code to transform to a table has been implemented
	 *
	 * @see SVC_API_GetCards.DTO_Table.transform
	 */
	@IsTest
	private static void successfulCallFromContact()
	{
		Contact newContact = SVC_DAL_Contact.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SVC_API_GetCards.SERVICE_NAME, newContact.Id);
	}

	/**
	 * @description Emulates a successful call and checks that the code to transform to a table has been implemented
	 *
	 * @see SVC_API_GetCards.DTO_Table.transform
	 */
	@IsTest
	private static void successfulCallFromAccount()
	{
		Account newAccount = CMN_DAL_Account.getAllPersonAccounts().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SVC_API_GetCards.SERVICE_NAME, newAccount.Id);
	}

	/**
	 * @description Emulates a failed call with an empty ExternalCIFID
	 *
	 * @see SVC_API_GetCards.abortRequest
	 */
	@IsTest
	private static void abortedMissingAccountExternalCFUUId()
	{
		Account newAccount = CMN_DAL_Account.getAll().iterator().next();
		newAccount.ExternalCIFUUID__c = CMN_UTIL_String.EMPTY;
		update newAccount;

		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetCards.SERVICE_NAME, newAccount.Id);
	}

	/**
	 * @description Checks that a call is aborted when the Id string provided is for neither an account or contact
	 */
	@IsTest
	private static void abortedWrongTriggerObjectIdType()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetCards.SERVICE_NAME, UserInfo.getUserId());
	}
}