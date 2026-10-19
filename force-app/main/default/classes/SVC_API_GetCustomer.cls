/**
 * @description Inbound Apex Rest handler which will process requests related to retrieving
 * specified customer information about a customer identified by various parameters such as BPID or Phone Number
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class SVC_API_GetCustomer extends CMN_API_RestBaseInbound
{
	@TestVisible
	private static final String ERROR_PREFIX = 'Did not receive any of the following valid query parameters: ';
	private static final String ERROR_INVALID_PARAMS = ERROR_PREFIX + '{0},{1} or {2}';
	private static final String ERROR_NONE_OR_MULTIPLE_ACCOUNTS_FOUND = 'No Accounts or Multiple Accounts Found for {0} {1}';

	@TestVisible
	private static final String QUERY_PARAM_EXTERNAL_ID = 'externalId';
	@TestVisible
	private static final String QUERY_PARAM_ID_NUMBER = 'identityNumber';
	@TestVisible
	private static final String QUERY_PARAM_PHONE = 'phone';

	public static final String SERVICE_NAME = SVC_API_GetCustomer.class.getName();

	/**
	 * @description Initialise additional object members relating serialising the response
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Will review the query params, and the execute a query, if no valid query parameters are provided an exception will be thrown
	 * all parameters will be processed; processing will take the order of most specific to least specific
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		String phoneParameter = request.params.get(QUERY_PARAM_PHONE);
		String identityParameter = request.params.get(QUERY_PARAM_ID_NUMBER);
		String externalIdParameter = request.params.get(QUERY_PARAM_EXTERNAL_ID);

		String chosenParameter = CMN_UTIL_String.EMPTY;
		String chosenValue = CMN_UTIL_String.EMPTY;

		if(String.isBlank(phoneParameter) && String.isBlank(identityParameter) && String.isBlank(externalIdParameter))
		{
			throw new SearchException(String.format(ERROR_INVALID_PARAMS, new List<String>
			{
					QUERY_PARAM_EXTERNAL_ID, QUERY_PARAM_PHONE, QUERY_PARAM_ID_NUMBER
			}));
		}
		else
		{
			Account foundAccount;

			if(String.isNotBlank(externalIdParameter))
			{
				chosenParameter = QUERY_PARAM_EXTERNAL_ID;
				chosenValue = externalIdParameter;
				foundAccount = SVC_DAL_Account.findByExternalCfId(externalIdParameter);
			}

			if(foundAccount == null && String.isNotBlank(identityParameter))
			{
				chosenParameter = QUERY_PARAM_ID_NUMBER;
				chosenValue = identityParameter;
				foundAccount = SVC_DAL_Account.findByIdentityNumber(identityParameter);

				if(foundAccount != null)
				{
					dtoResponse.identityNumber = identityParameter;
				}
			}

			if(foundAccount == null && String.isNotBlank(phoneParameter))
			{
				chosenParameter = QUERY_PARAM_PHONE;
				chosenValue = phoneParameter;
				foundAccount = SVC_DAL_Account.findByPhoneNumber(phoneParameter);
			}

			if(foundAccount != null)
			{
				dtoResponse.success = true;
				dtoResponse.populate(foundAccount);
			}
			else
			{
				dtoResponse.success = false;
				dtoResponse.error = String.format(ERROR_NONE_OR_MULTIPLE_ACCOUNTS_FOUND, new List<String>
				{
						chosenParameter,
						chosenValue
				});
			}
		}

	}

	/**
	 * @description Response DTO which contains the found Contact
	 */
	@TestVisible
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String contactId;
		public String email;
		public String externalIdentifier;
		public String firstName;
		public String id;
		public String identityNumber;
		public String lastName;
		public String mailingCity;
		public String mailingCountry;
		public String mailingState;
		public String mailingStreet;
		public String mobilePhone;
		public String name;
		public String phone;
		public String segment;
        public String relationshipMGRcode;

		public Boolean success;
		public String error;

	   /**
	    * @description Response DTO which contains the found Contact
	    * @param foundAccount Account
	    */
		public void populate(Account foundAccount)
		{
			contactId = foundAccount.PersonContactId;
			email = foundAccount.PersonEmail;
			externalIdentifier = foundAccount.ExternalCIFId__c;
			firstName = foundAccount.FirstName;
			id = foundAccount.Id;
			lastName = foundAccount.LastName;
			mailingCity = foundAccount.PersonMailingCity;
			mailingCountry = foundAccount.PersonMailingCountry;
			mailingState = foundAccount.PersonMailingState;
			mailingStreet = foundAccount.PersonMailingStreet;
			name = foundAccount.Name;
			phone = foundAccount.Phone;
			segment = foundAccount.FinServ__MarketingSegment__c;
            relationshipMGRcode = foundAccount.RelationshipMgrCode__c;
		}
	}
}