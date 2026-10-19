/**
 * @description API and DTO to facilitate the callout of the debit order get transactions related to an account
 *
 * @author Accenture
 *
 * @date January 2021
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.ExcessivePublicCount') // Required in non standard format for external API
public inherited sharing class SVC_API_GetTransactions extends SVC_API_PingOutboundBase
{
	@TestVisible
	private static final String PARAMETER_ACCOUNT_NUMBER = 'account_number';

	@TestVisible
	private static final String SERVICE_NAME = SVC_API_GetTransactions.class.getName();

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

		parameters.addAll
				(
						new Set<String>
						{
								PARAMETER_ACCOUNT_NUMBER
						}
				);

		return parameters;
	}

	/**
	 * @description Return the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetTransactionsMock();
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

			addColumn('Transaction Date', 'transaction_date', 'date');
			addColumn('Reference', 'transaction_reference', 'text');
			addColumn('Type', 'transaction_type', 'text');
			addColumn('Status', 'transaction_status', 'text');
			addColumn('Amount', 'transactionAmount', 'text');
			addColumn('Reversible', 'can_reverse', 'Boolean');
			addColumn('SBSA Debit Order', 'standard_bank_debit_order', 'Boolean');
			//addColumn('Debi Check', 'debi_check', 'Boolean'); //Not included in design document

			DTO_Response dtoResponse = (DTO_Response)dtoBase;

			for(DTO_Transaction dtoTransaction : dtoResponse.debit_order_transactions)
			{
				//Ensures that we lift the amount from a sub-type onto the main transaction row
				dtoTransaction.transactionAmount = dtoTransaction.amount?.amount;
				addRow(dtoTransaction);
			}
		}
	}

	/**
	 * @description The request to to be sent for retrieve Debit Order Transactions
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String account_number;

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);
			account_number = dtoRequestParameters.getFirst(PARAMETER_ACCOUNT_NUMBER);
		}
	}

	/**
	 * @description A Dto representing the response received from the service
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_DisputeReason> debit_order_dispute_reasons;
		public Integer total_size;
		public List<DTO_Transaction> debit_order_transactions;
		public List<DTO_DisputeReason> stop_debit_order_reasons;
		public List<DTO_DisputeReason> debi_check_reasons;

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

	private class DTO_DisputeReason
	{
		public String code;
		public String description;
	}

	private class DTO_Amount
	{
		public Double amount;
		public String currencySymbol;
	}

	private class DTO_Transaction
	{
		public String transaction_date;
		public String effective_date;
		public String payment_medium_code;
		public DTO_Amount amount;
		public String transaction_id;
		public String transaction_reference;
		public String transaction_type;
		public String transaction_type_code;
		public String transaction_status;
		public Boolean can_reverse;
		public String gpp_message_identifier;
		public String mandate_reference_no;
		public Boolean debi_check;
		public Boolean stop_loaded;
		public Boolean reversed_already;
		public Boolean standard_bank_debit_order;
		public Decimal transactionAmount;
	}

	/**
	 * @description Mock class for returning test data
	 */
	private class SVC_API_GetTransactionsMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"debit_order_dispute_reasons":[{"code":"AUTHORITY","description":"No authority to debit"},{"code":"AMOUNT","description":"Debit in contravention to mandate"},{"code":"CANCELLED","description":"Contract has been cancelled"},{"code":"STOPPED","description":"Debit order has been stopped"}],"total_size":14,"debit_order_transactions":[{"transaction_date":"2021-09-28T22:12:00.000","effective_date":"2021-05-28T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":28.92,"currency":"ZAR"},"transaction_id":"AEAEF41F000E1EEB8FCDB1D3E5085908","transaction_reference":"SBSANAEDO   00061102237 201215","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201215/0001","mandate_reference_no":"(BF)QQC00000B349800001559MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":false},{"transaction_date":"2021-10-18T22:12:00.000","effective_date":"2021-05-28T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":56.58,"currency":"ZAR"},"transaction_id":"AEAEF41F000E1EEB8FCDB1D3E5083908","transaction_reference":"SBSANAEDO   00061101982 201215","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201215/0001","mandate_reference_no":"(BF)QQC00000B349800001558MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2021-10-26T22:12:00.000","effective_date":"2021-01-08T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":28.92,"currency":"ZAR"},"transaction_id":"AEA8F41F00121EEB8EB518F3166D532B","transaction_reference":"SBSANAEDO   00061102237 201209","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201209/0000","mandate_reference_no":"(BF)QQC00000B343800000054MAYON","debi_check":true,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":false},{"transaction_date":"2020-10-08T22:12:00.000","effective_date":"2020-10-08T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":56.58,"currency":"ZAR"},"transaction_id":"AEA8F41F00121EEB8EB518F3166D332B","transaction_reference":"SBSANAEDO   00061101982 201209","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201209/0000","mandate_reference_no":"(BF)QQC00000B343800000053MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":false},{"transaction_date":"2020-12-03T22:12:00.000","effective_date":"2020-12-03T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":134.44,"currency":"ZAR"},"transaction_id":"0200200000301EDB8DB784E3529ADDB9","transaction_reference":"SBSANAEDO   00061102490 201204","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201204/0000","mandate_reference_no":"(BF)QQC00000B338800000099MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-12-01T22:12:00.000","effective_date":"2020-12-01T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":28.92,"currency":"ZAR"},"transaction_id":"0200210000371EEB8D85128B1150F772","transaction_reference":"SBSANAEDO   00061102237 201202","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201202/0000","mandate_reference_no":"(BF)QQC00000B336800000057MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-12-01T22:12:00.000","effective_date":"2020-12-01T22:12:00.000","payment_medium_code":"Z290","amount":{"amount":56.58,"currency":"ZAR"},"transaction_id":"0200210000371EEB8D85128B1150D772","transaction_reference":"SBSANAEDO   00061101982 201202","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201202/0000","mandate_reference_no":"(BF)QQC00000B336800000055MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-11-29T22:11:00.000","effective_date":"2020-11-29T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":124.26,"currency":"ZAR"},"transaction_id":"0200210000371EEB8CD2C7F659C98CA2","transaction_reference":"SBSANAEDO   00061101664 201130","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201130/0000","mandate_reference_no":"(BF)QQC00000B334800000393JUNE","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-11-24T22:11:00.000","effective_date":"2020-11-24T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":28.92,"currency":"ZAR"},"transaction_id":"0200210000371EEB8BD5128FFA1126F9","transaction_reference":"SBSANAEDO   00061102237 201125","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201125/0000","mandate_reference_no":"(BF)QQC00000B329800000276MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-11-24T22:11:00.000","effective_date":"2020-11-24T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":56.58,"currency":"ZAR"},"transaction_id":"0200210000371EEB8BD5128FFA1106F9","transaction_reference":"SBSANAEDO   00061101982 201125","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201125/0000","mandate_reference_no":"(BF)QQC00000B329800000274MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-11-17T22:11:00.000","effective_date":"2020-11-17T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":28.92,"currency":"ZAR"},"transaction_id":"0200200000301EEB8AA50AB9E534A916","transaction_reference":"SBSANAEDO   00061102237 201118","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201118/0000","mandate_reference_no":"(BF)QQC00000B322800000054MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2020-11-17T22:11:00.000","effective_date":"2020-11-17T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":56.58,"currency":"ZAR"},"transaction_id":"0200200000301EEB8AA50AB9E5348916","transaction_reference":"SBSANAEDO   00061101982 201118","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201118/0000","mandate_reference_no":"(BF)QQC00000B322800000052MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":true},{"transaction_date":"2021-01-30T22:11:00.000","effective_date":"2021-01-30T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":56.58,"currency":"ZAR"},"transaction_id":"AEA8F41F00121EEB88F58BF3184A4C06","transaction_reference":"SBSANAEDO   00061101982 201111","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201111/0000","mandate_reference_no":"(BF)QQC00000B315800000045MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":false},{"transaction_date":"2021-02-10T22:11:00.000","effective_date":"2021-02-10T22:11:00.000","payment_medium_code":"Z290","amount":{"amount":28.92,"currency":"ZAR"},"transaction_id":"AEA8F41F00121EEB88F58BF3184A2C06","transaction_reference":"SBSANAEDO   00061102237 201111","transaction_type":"BOL NAEDO DEBIT","transaction_type_code":"00865","transaction_status":"Completed","can_reverse":true,"gpp_message_identifier":"5084/201111/0000","mandate_reference_no":"(BF)QQC00000B315800000047MAYON","debi_check":false,"stop_loaded":false,"reversed_already":false,"standard_bank_debit_order":false}],"stop_debit_order_reasons":[{"code":"167","description":"Account paid up cancelled"},{"code":"124","description":"Breach of contract"},{"code":"159","description":"Payment duplicated"},{"code":"122","description":"Policy cancelled discontinued"},{"code":"123","description":"Service unsatisfactory"}],"debi_check_reasons":[{"code":"AMOUNT","description":"Incorrect Amount"},{"code":"DATE","description":"Incorrect Date"}]}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}