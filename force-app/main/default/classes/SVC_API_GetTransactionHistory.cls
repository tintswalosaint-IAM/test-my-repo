/**
 * @description API and DTO to facilitate the callout of the debit order get transactions related to an account
 *
 * @author Accenture
 *
 * @date February 2021
 */
@SuppressWarnings('PMD.ExcessivePublicCount') // public attributes required for DTO payload as Apex-defined data type in flow
public inherited sharing class SVC_API_GetTransactionHistory extends SVC_API_PingOutboundBase
{
	@TestVisible
	private static final String PARAMETER_ACCOUNT_NUMBER = 'accountNumber';
	@TestVisible
	private static final String PARAMETER_START_DATE = 'startDate';
	@TestVisible
	private static final String PARAMETER_END_DATE = 'endDate';
	@TestVisible
	private static final String PARAMETER_CARD_TYPE = 'cardType';
	@TestVisible
	private static final String PARAMETER_CARD_DAYS = 'days';
	@TestVisible
	private static final String CARD_TYPE_CREDIT = 'CREDIT';

	private static final String SOURCE_ID_CREDIT = '010';
	private static final String SOURCE_ID_DEBIT_CHEQUE = '110';
	private static final String ERROR_CREDIT_DAY_PARAMETER_NOT_PROVIDED = 'Credit card type calls require the days parameter that was not provided';
	private static final String ERROR_DATE_RANGE_PARAMETERS_NOT_PROVIDED = 'Non credit card types are required to pass a date range in the startDate and endDate parameters that were not provided';
	private static final String ERROR_PARAMETER_ACCOUNT_NUMBER_NOT_PROVIDED = 'Valid account number was not provided.';
	@TestVisible
	private static final String SERVICE_NAME = SVC_API_GetTransactionHistory.class.getName();

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
		baseTableDTOType = DTO_Table.class;
	}

	/**
	 * @description If there are reserved words in a particular service handler response, indicate what it should be replace with prior to de-serialisation
	 *
	 * @param searchTokens The search tokens to be found
	 * @param replaceTokens The token to replace with if matching search token is found
	 */
	protected override void getResponseReplacementTokens(List<String> searchTokens, List<String> replaceTokens)
	{
		super.getResponseReplacementTokens(searchTokens, replaceTokens);

		searchTokens.add('"currency"');
		replaceTokens.add('"currencySymbol"');
		searchTokens.add('"transaction"');
		replaceTokens.add('"aTransaction"');
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
	 * @description Does this API call require a triggering object id
	 *
	 * @return False, no triggering object required.
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();

		parameters.addAll(new Set<String> {PARAMETER_ACCOUNT_NUMBER});

		return parameters;
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run, requires relevant parameters to be set
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();

		if(!abort)
		{
			if(requestParameters.getFirst(PARAMETER_ACCOUNT_NUMBER) == null)
			{
				callResult.errors.add(ERROR_PARAMETER_ACCOUNT_NUMBER_NOT_PROVIDED);
				abort = true;
			}

			if(requestParameters.getFirst(PARAMETER_CARD_TYPE) == CARD_TYPE_CREDIT)
			{
				if(!requestParameters.exists(PARAMETER_CARD_DAYS))
				{
					callResult.errors.add(ERROR_CREDIT_DAY_PARAMETER_NOT_PROVIDED);
					abort = true;
				}

			}
			else
			{
				if(!requestParameters.exists(PARAMETER_START_DATE) || !requestParameters.exists(PARAMETER_END_DATE))
				{
					callResult.errors.add(ERROR_DATE_RANGE_PARAMETERS_NOT_PROVIDED);
					abort = true;
				}
			}
		}

		return abort;
	}

	/**
	 * @description Return the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetTransactionHistoryMock();
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

			addColumn('Description', 'transactionInformation', 'text');
			addColumn('Transaction Type', 'creditDebitIndicator', 'text');
			addColumn('Transaction Date', 'bookingDateTime', 'date');
			addColumn('Amount', 'amount', 'currency');

			DTO_Response dtoResponse = (DTO_Response)dtoBase;

			for(DTO_Transaction dtoTransaction : dtoResponse.data.aTransaction)
			{
				DTO_TransformedTransaction dtoRow = new DTO_TransformedTransaction();

				dtoRow.amount = dtoTransaction.amount.amount;
				dtoRow.currencySymbol = dtoTransaction.amount.currencySymbol;
				dtoRow.bookingDateTime = dtoTransaction.bookingDateTime;
				dtoRow.creditDebitIndicator = dtoTransaction.creditDebitIndicator;
				dtoRow.transactionInformation = dtoTransaction.transactionInformation;

				addRow(dtoRow);
			}
		}
	}

	/**
	 * @description The request to to be sent for retrieve Debit Order Transactions
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String accountNumber;
		public String accountSourceSystemId;
		public DTO_Parameters parameters = new DTO_Parameters();

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			accountNumber = dtoRequestParameters.getFirst(PARAMETER_ACCOUNT_NUMBER);
			String cardTypeParam = dtoRequestParameters.getFirst(PARAMETER_CARD_TYPE);

			if(cardTypeParam == CARD_TYPE_CREDIT)
			{
				parameters.days = dtoRequestParameters.getFirst(PARAMETER_CARD_DAYS);
				accountSourceSystemId = SOURCE_ID_CREDIT;
			}
			else
			{
				parameters.startDate = dtoRequestParameters.getFirst(PARAMETER_START_DATE);
				parameters.endDate = dtoRequestParameters.getFirst(PARAMETER_END_DATE);
				accountSourceSystemId = SOURCE_ID_DEBIT_CHEQUE;
			}

		}
	}

	/**
	 * @description Dto Structure for external API
	 */
	public class DTO_Parameters
	{
		public String days;
		public String startDate;
		public String endDate;
	}

	/**
	 * @description Dto Structure for external API
	 */
	private class DTO_TransformedTransaction
	{
		public Double amount;
		public String currencySymbol;
		public String bookingDateTime;
		public String creditDebitIndicator;
		public String transactionInformation;
	}

	/**
	 * @description A Dto representing the response received from the service
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_Data data;
		public DTO_Links links;
		public List<DTO_InputParameters> inputParameters;
		public DTO_OutputParameters outputParameters;

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
	 * @description Dto Structure for external API
	 */
	private class DTO_OutputParameters
	{
		public String morePages;
	}

	/**
	 * @description Dto Structure for external API
	 */
	private class DTO_Amount
	{
		public Double amount;
		public String currencySymbol;
	}

	/**
	 * @description Dto Structure for external API
	 */
	private class DTO_Transaction
	{
		public String accountId;
		public DTO_Amount amount;
		public String creditDebitIndicator;
		public String bookingDateTime;
		public String transactionInformation;
	}

	/**
	 * @description Dto Structure for external API
	 */
	private class DTO_Links
	{
		public String self;
	}

	/**
	 * @description Dto Structure for external API
	 */
	private class DTO_Data
	{
		public List<DTO_Transaction> aTransaction;
	}

	/**
	 * @description Dto Structure for external API
	 */
	private class DTO_InputParameters
	{
		public String name;
		public Boolean mandatory;
		public String description;
	}

	/**
	 * @description Mock class for returning test data
	 */
	private class SVC_API_GetTransactionHistoryMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"data":{"transaction":[{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-01-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-01-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-01-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-01-31T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-01-31T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-05T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-05T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":1000.00,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2020-02-06T00:00:00","transactionInformation":"CREDIT TRANSFER"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-12T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-12T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-18T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-19T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-19T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-26T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-26T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-02-28T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-02T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-02T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-05T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-05T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-05T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-05T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-06T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-06T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-06T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-06T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-11T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-11T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-18T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-18T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-18T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-25T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-25T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-31T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-03-31T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-01T00:00:00","transactionInformation":"BOL NAEDO REPRESENTATION"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-01T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-01T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-03T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-08T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-08T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-15T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-15T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-17T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-22T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-22T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-30T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-04-30T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-04T00:00:00","transactionInformation":"LOAN REPAYMENT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-06T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-06T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-13T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-13T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":6.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-18T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-20T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-20T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-27T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-27T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-05-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-01T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-01T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-04T00:00:00","transactionInformation":"LOAN REPAYMENT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-10T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-10T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-17T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-17T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-18T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-24T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-24T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":64.55,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-30T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":100.10,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-06-30T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-01T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-01T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-03T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-08T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-08T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-15T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-15T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-17T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-22T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-22T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-29T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-31T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-07-31T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-04T00:00:00","transactionInformation":"LOAN REPAYMENT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-05T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-05T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-12T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-12T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-17T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-19T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-19T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-26T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-26T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-28T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-31T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-08-31T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-02T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-02T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-04T00:00:00","transactionInformation":"LOAN REPAYMENT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-09T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-09T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-16T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-16T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-17T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-23T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-23T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-30T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":107.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-09-30T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-02T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-07T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-07T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-14T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-14T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":30.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-17T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-21T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-21T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-28T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-28T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-31T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":110.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-10-31T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-04T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-04T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-04T00:00:00","transactionInformation":"LOAN REPAYMENT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-11T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-11T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":33.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-17T00:00:00","transactionInformation":"STATEMENT COSTS"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-18T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-18T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-25T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-25T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":124.26,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-30T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":110.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-11-30T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-02T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-02T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-04T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-09T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-09T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-15T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-15T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2020-12-18T00:00:00","transactionInformation":"TRANSACTION REVERSAL"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2020-12-18T00:00:00","transactionInformation":"TRANSACTION REVERSAL"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-23T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-23T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-30T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":69.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-31T00:00:00","transactionInformation":"OVERDRAFT SERVICE FEE"},{"accountId":"0000010005967250","amount":{"amount":110.00,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2020-12-31T00:00:00","transactionInformation":"FIXED MONTHLY FEE"},{"accountId":"0000010005967250","amount":{"amount":134.44,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-04T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-06T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-06T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2021-01-07T00:00:00","transactionInformation":"TRANSACTION REVERSAL"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2021-01-07T00:00:00","transactionInformation":"TRANSACTION REVERSAL"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2021-01-08T00:00:00","transactionInformation":"TRANSACTION REVERSAL"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Credit","bookingDateTime":"2021-01-08T00:00:00","transactionInformation":"TRANSACTION REVERSAL"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-13T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-13T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":56.58,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-20T00:00:00","transactionInformation":"BOL NAEDO DEBIT"},{"accountId":"0000010005967250","amount":{"amount":28.92,"currency":null},"creditDebitIndicator":"Debit","bookingDateTime":"2021-01-20T00:00:00","transactionInformation":"BOL NAEDO DEBIT"}]},"links":{"self":"/accounts/0000010005967250/transactions?system-id=110"},"inputParameters":[{"name":"startDate","mandatory":false,"description":"Enquiry start date: yyyy-MM-dd. Default is 30 days back"},{"name":"endDate","mandatory":false,"description":"Enquiry end date: yyyy-MM-dd. Default is today"},{"name":"sortCriteria","mandatory":false,"description":"Transaction types to sort. Available values: [Normal, Reverse]"},{"name":"sortType","mandatory":false,"description":"Sort by type. Available values: [Date, Amount, TransactionType, StatementCode]"},{"name":"pageNo","mandatory":false,"description":"Page number"},{"name":"containerName","mandatory":false,"description":"Container name"},{"name":"baPage","mandatory":false,"description":"BA Page"},{"name":"sapPage","mandatory":false,"description":"SAP Page"}],"outputParameters":{"morePages":"no"}}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}