/**
 * @description API to retrieve customer's account
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
public inherited sharing class SVC_API_GetAccounts extends SVC_API_PingOutboundBase
{
	private String externalCIFUUId;
	private static final String PREFIX_ACCOUNT = '001';
	private static final String PREFIX_CONTACT = '003';

	@TestVisible
	private static final Integer NUMBER_OF_CREDIT_AND_DEBIT_CARDS = 4;
	@TestVisible
	private static final String CREDIT_AND_DEBIT_CARDS_FILTER = '010';
	private static final String ERROR_CONTACT_HAS_NO_EXTERNAL_UUID = 'The ExternalCIFUUID__c is null';
	public static final String PARAMETER_FILTER = 'sourceSystemId';
	public static final String SERVICE_NAME = SVC_API_GetAccounts.class.getName();

	/**
	 * @description Set this static variable so the class knows not to perform an commits as its being run embedded in another service class request
	 */
	public static Boolean runAsEmbedded = false;

	/**
	 * @description Override to set request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseResponseDTO = new DTO_Response();
		baseTableDTOType = DTO_Table.class;
	}

	/**
	 * @description Override of base commit method which will check to see if this service is running embedded in another service, if so it won't commit it's queue item
	 */
	public override void commitWork()
	{
		if(!runAsEmbedded)
		{
			super.commitWork();
		}
	}

	/**
	 * @description Name of service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description The HTTP Verb that the service will use when making a request
	 *
	 * @return result
	 */
	protected override String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();

		if(!abort)
		{
			if(queueItem.CMN_TriggeringObjectId__c.startsWith(PREFIX_ACCOUNT))
			{
				Account foundAccount = CMN_DAL_Account.findById(queueItem.CMN_TriggeringObjectId__c);
				externalCIFUUId = foundAccount.ExternalCIFUUID__c;
			}
			else if(queueItem.CMN_TriggeringObjectId__c.startsWith(PREFIX_CONTACT))
			{
				Contact foundContact = SVC_DAL_Contact.findById(queueItem.CMN_TriggeringObjectId__c);
				externalCIFUUId = foundContact.Account?.ExternalCIFUUID__c;
			}

			if(String.isBlank(externalCIFUUId))
			{
				callResult.errors.add(ERROR_CONTACT_HAS_NO_EXTERNAL_UUID);
				abort = true;
			}
		}

		return abort;
	}

	/**
	 * @description Constructs the URL to use when call the service endpoint
	 *
	 * @return Service Endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		return String.format
				(
						super.getWebServiceEndPoint(),
						new List<String> {EncodingUtil.urlEncode(externalCIFUUId, UTF8_ENCODING_SCHEME)}
				);
	}

	/**
	 * @description The Endpoint mock to use when running unit tests
	 *
	 * @return An HTTP Mock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetCustomerAccountsMock();
	}

	/**
	 * @description DTO Structure to format the callout response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_AccountProductDetails> customerAccountListDetails;
		public DTO_PagingControl pageCtrlOut;

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
	 * @description DTO representing account details
	 */
	public class DTO_AccountProductDetails
	{
		@InvocableVariable(Label='productName')
		public String productName;
		@InvocableVariable(Label='productType')
		public String productType;
		@InvocableVariable(Label='productTypeDescription')
		public String productTypeDescription;
		@InvocableVariable(Label='accountNumber')
		public String accountNumber;
		@InvocableVariable(Label='sourceSystemId')
		public String sourceSystemId;
		@InvocableVariable(Label='accountStatusCode')
		public String accountStatusCode;
		@InvocableVariable(Label='accountStatusName')
		public String accountStatusName;
	}

	private class DTO_PagingControl
	{
		public Integer totalRecordsCount;
		public Integer pageSize;
		public Integer remainRecordsCount;
		public Boolean remainPageInd;
	}

	/**
	 * @description Will parse the response into a DTO and then filter list if required
	 */
	protected override void parseResponse()
	{
		super.parseResponse();

		String filterString = requestParameters.getFirst(PARAMETER_FILTER);
		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		if(String.isNotBlank(filterString))
		{
			for(Integer i = dtoResponse.customerAccountListDetails.size() - 1; i >= 0; i--)
			{
				DTO_AccountProductDetails dtoProductDetails = dtoResponse.customerAccountListDetails[i];
				if(!dtoProductDetails.sourceSystemId.equalsIgnoreCase(filterString))
				{
					dtoResponse.customerAccountListDetails.remove(i);
				}
			}
		}
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

			addColumn('Account Name', 'productName', 'text');
			addColumn('Account Number', 'accountNumber', 'text');
			addColumn('Account Status', 'accountStatusName', 'text');

			DTO_Response dtoResponse = (DTO_Response)dtoBase;

			for(DTO_AccountProductDetails dtoAccountDetails : dtoResponse.customerAccountListDetails)
			{
				addRow(dtoAccountDetails);
			}
		}
	}

	/**
	 * @description Outbound Mock class which allows API to be mocked or tested
	 */
	private class SVC_API_GetCustomerAccountsMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"customerAccountListDetails":[{"productName":"Private Banking Plus Current Account","productType":"001","productTypeDescription":"Transaction Accounts","accountNumber":"00000012632770001","sourceSystemId":"020","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Wealth And Investment Visa Cheque Card","productType":"003","productTypeDescription":"Generic Card","accountNumber":"4548581340301597","sourceSystemId":"010","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Sbsa Gold Cheque Card","productType":"003","productTypeDescription":"Generic Card","accountNumber":"5222502360048066","sourceSystemId":"010","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Private Banking Platinum M/c - Bundled","productType":"003","productTypeDescription":"Generic Card","accountNumber":"5520578340208821","sourceSystemId":"010","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Garage Linked To Mastercard","productType":"004","productTypeDescription":"Corporate Card","accountNumber":"2250504360683456","sourceSystemId":"010","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Managed Direct Response","productType":"009","productTypeDescription":"Accident And Health Insurance","accountNumber":"0000000000405583","sourceSystemId":"021","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Afl-per-sing. Prem. 5 Year","productType":"017","productTypeDescription":"Wealth","accountNumber":"0000000001091896","sourceSystemId":"022","accountStatusCode":"01","accountStatusName":"OPEN"},{"productName":"Afl-preservation Pension Sp","productType":"017","productTypeDescription":"Wealth","accountNumber":"0000000001593260","sourceSystemId":"022","accountStatusCode":"01","accountStatusName":"OPEN"}],"pageCtrlOut":{"totalRecordsCount":16,"pageSize":10,"remainRecordsCount":6,"remainPageInd":true}}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

}