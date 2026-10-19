/**
 * @description API and DTO to facilitate the callout of the ATM Get Cards
 *
 * @see SVC_API_GetCards_TEST
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class SVC_API_GetCards extends SVC_API_PingOutboundBase
{
	@TestVisible
	private static final String SERVICE_NAME = SVC_API_GetCards.class.getName();

	private String externalCIFUUId;
	private static final String ERROR_MISSING_EXTERNALCIFUUID = 'The ExternalCIFUUID__c is null';

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();
		baseTableDTOType = DTO_Table.class;
	}

	/**
	 * @description Name of your service to be used when looking up custom settings for you service
	 *
	 * @return the service name
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Returns the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetCardsMock();
	}

	/**
	 * @description Override the HTTP verb to use
	 *
	 * @return HTTP Verb
	 */
	protected override String getVerb()
	{
		return HTTP_VERB_GET;
	}
	/**
	 * @description Method checks to see if the web service should be allowed to run, requires a Customer BPID to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();

		if(!abort)
		{
			if(CMN_UTIL_System.getSObjectTypeById(queueItem.CMN_TriggeringObjectId__c) == Account.SObjectType)
			{
				Account foundAccount = SVC_DAL_Account.findById(queueItem.CMN_TriggeringObjectId__c);
				externalCIFUUId = foundAccount?.ExternalCIFUUID__c;
			}
			else if(CMN_UTIL_System.getSObjectTypeById(queueItem.CMN_TriggeringObjectId__c) == Contact.SObjectType)
			{
				Contact foundContact = SVC_DAL_Contact.findById(queueItem.CMN_TriggeringObjectId__c);
				externalCIFUUId = foundContact?.Account?.ExternalCIFUUID__c;
			}
			else
			{
				callResult.errors.add(ERROR_MISSING_EXTERNALCIFUUID);
				abort = true;
			}

			if(String.isBlank(externalCIFUUId))
			{
				callResult.errors.add(ERROR_MISSING_EXTERNALCIFUUID);
				abort = true;
			}
		}

		return abort;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String>
						{
								EncodingUtil.urlEncode(externalCIFUUId, UTF8_ENCODING_SCHEME)
						}
				);
	}

	/**
	 * @description Returns the webservice response as a table
	 */
	private class DTO_Table extends CMN_API_HttpBaseOutbound.DTO_BaseTable
	{
		/**
		 * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
		 *
		 * @param dtoBase Input dto for transformation
		 */
		public override void transform(CMN_DTO_Base dtoBase)
		{
			super.transform(dtoBase);

			addColumn('Card Number', 'cardNumber', 'text');
			addColumn('Card Type', 'cardTypeDescription', 'text');
			addColumn('Card Status', 'hotcard', 'text');
			addColumn('Issued For', 'surname', 'text');
			addColumn('Issue Date', 'cardIssueDate', 'date');
			addColumn('Withdrawal Limit', 'monthlyWdrLimit', 'number');
			addColumn('Withdrawal Used', 'monthlyWdrUsed', 'number');
			addColumn('EAP Limit', 'monthlyEapLimit', 'number');
			addColumn('EAP Limit Used', 'monthlyEapUsed', 'number');

			addColumn('Card Group Code', 'cardGroupCode', 'text');
			//addColumn('Card Group Description', 'cardGroupDescription', 'text');
			addColumn('Card Type', 'cardGroupDescription', 'text');

			DTO_Response dtoResponse = (DTO_Response)dtoBase;

			for(DTO_Card dtoCard : dtoResponse.cards)
			{
				addRow(dtoCard);
			}
		}
	}

	/**
	 * @description DTO Containing the list of Cards belonging to an account
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public Integer error;
		public List<DTO_Card> cards;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	/**
	 * @description DTO Containing Card information
	 */
	private class DTO_Card
	{
		public Integer cardError;
		public Decimal dailyWdrLimit;
		public Decimal dailyWdrUsed;
		public Decimal monthlyEapLimit;
		public Decimal monthlyEapUsed;
		public Decimal monthlyWdrLimit;
		public Decimal monthlyWdrUsed;
		public Long cardNumber;
		public String cardGroupCode;
		public String cardGroupDescription;
		public String cardIssueDate;
		public String cardTypeCode;
		public String cardTypeDescription;
		public String hotcard;
		public String initial;
		public String surname;
	}

	/**
	 * @description Mock class for returning test data
	 */
	private class SVC_API_GetCardsMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"error":0,"cards":[{"cardNumber":4172900020000233,"surname":"OJ  HAVEN","initial":"","hotcard":"A","dailyWdrLimit":31000,"dailyWdrUsed":24,"monthlyWdrLimit":1100,"monthlyWdrUsed":195,"monthlyEapLimit":100,"monthlyEapUsed":10,"cardTypeCode":"M","cardTypeDescription":"VISA ONE MAN BUSINESS","cardIssueDate":"2020-11-05","cardError":0,"cardGroupCode":"10","cardGroupDescription":"DEBIT CARD"},{"cardNumber":4172900020000241,"surname":"OJ  HAVEN","initial":"","hotcard":"A","dailyWdrLimit":1000,"dailyWdrUsed":30,"monthlyWdrLimit":31000,"monthlyWdrUsed":150,"monthlyEapLimit":0,"monthlyEapUsed":0,"cardTypeCode":"M","cardTypeDescription":"VISA ONE MAN BUSINESS","cardIssueDate":"2020-11-05","cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD"},{"cardNumber":4215760030044921,"surname":"WORKING","initial":"","hotcard":"A","dailyWdrLimit":1000,"dailyWdrUsed":0,"monthlyWdrLimit":31000,"monthlyWdrUsed":0,"monthlyEapLimit":0,"monthlyEapUsed":0,"cardTypeCode":"M","cardTypeDescription":"VISA CORPORATE CARD","cardIssueDate":"2020-11-30","cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD"},{"cardNumber":4215760030044947,"surname":"WORKING","initial":"","hotcard":"A","dailyWdrLimit":1000,"dailyWdrUsed":0,"monthlyWdrLimit":31000,"monthlyWdrUsed":0,"monthlyEapLimit":0,"monthlyEapUsed":0,"cardTypeCode":"M","cardTypeDescription":"VISA CORPORATE CARD","cardIssueDate":"2020-11-30","cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD"},{"cardNumber":4215760030044954,"surname":"WORKING","initial":"","hotcard":"A","dailyWdrLimit":1000,"dailyWdrUsed":0,"monthlyWdrLimit":31000,"monthlyWdrUsed":0,"monthlyEapLimit":0,"monthlyEapUsed":0,"cardTypeCode":"M","cardTypeDescription":"VISA CORPORATE CARD","cardIssueDate":"2020-11-30","cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD"},{"cardNumber":4215760030044962,"surname":"WORKING","initial":"","hotcard":"A","dailyWdrLimit":1000,"dailyWdrUsed":0,"monthlyWdrLimit":31000,"monthlyWdrUsed":0,"monthlyEapLimit":0,"monthlyEapUsed":0,"cardTypeCode":"M","cardTypeDescription":"VISA CORPORATE CARD","cardIssueDate":"2020-11-30","cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD"},{"cardNumber":5221182035904042,"surname":"WORKING","initial":"","hotcard":"A","dailyWdrLimit":0,"dailyWdrUsed":0,"monthlyWdrLimit":0,"monthlyWdrUsed":0,"monthlyEapLimit":1000,"monthlyEapUsed":100,"cardTypeCode":"M","cardTypeDescription":"MASTERCARD-OTHER","cardIssueDate":"2020-11-30","cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD"}]}';
		private final String demoResponse = '{"cards":[{"cardError":0,"cardGroupCode":"10","cardGroupDescription":"CREDIT CARD","cardIssueDate":"2020-11-05","cardNumber":4172900020000233,"cardTypeCode":"M","cardTypeDescription":"GOLD CREDIT CARD","dailyWdrLimit":31000,"dailyWdrUsed":24,"hotcard":"A","initial":"J","monthlyEapLimit":10000,"monthlyEapUsed":1000,"monthlyWdrLimit":10000,"monthlyWdrUsed":1000,"surname":"DOE"},{"cardError":0,"cardGroupCode":"10","cardGroupDescription":"CHEQUE CARD","cardIssueDate":"2020-11-05","cardNumber":4172900020000241,"cardTypeCode":"M","cardTypeDescription":"GOLD CHEQUE CARD","dailyWdrLimit":1000,"dailyWdrUsed":30,"hotcard":"A","initial":"J","monthlyEapLimit":10000,"monthlyEapUsed":1000,"monthlyWdrLimit":10000,"monthlyWdrUsed":1000,"surname":"DOE"}],"error":0}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(demoResponse);
		}
	}
}