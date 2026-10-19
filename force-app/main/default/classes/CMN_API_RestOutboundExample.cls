/**
 * @description This is an example Outbound API call; that hits actual example service
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_API_RestOutboundExample extends CMN_API_RestBaseOutbound
{
	@TestVisible
	private static final String SERVICE_NAME = CMN_API_RestOutboundExample.class.getName();
	private static final String TITLE_VALUE = 'AAAAAAAAA';
	private static String validResponse = '{"body": "hwJIOOXHGxsWbuFZKgkcWetDVOITplDaNKjVUeoiqEpJNkHtzcGZbwVerPqgCAoUGdvTNRXNxPJzPqlZ","id": 101,"title": "' + TITLE_VALUE + '","userId": 9}';
	@TestVisible
	private static final String TITLE_FIELD_NAME = 'title';

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
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return The name of the service
	 */
	protected override String getServiceName()
	{
		super.getServiceName();/* NB: Running this to cover base code method. */
		return SERVICE_NAME;
	}

	/**
	 * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
	 */
	protected override void populateRequestDTO()
	{
		super.populateRequestDTO();
		//This line is to cover base class functionality for retrieving an additional key
		((DTO_Request)baseRequestDTO).body = getAdditionalKey();
	}

	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		/* Call the parent objects' method to ensure we get code coverage */
		super.getEndpointMock();
		return new CMN_API_RestOutboundExampleMock();
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		/* do Something here with the Response DTO */
		CMN_UTIL_Logger.info('Response Received for ' + getServiceName() + ':' + baseResponseDTO.serialize(), SERVICE_NAME + '/registerDatabaseChanges');
	}

	/**
	 * @description Implements the populate method to ensure that columns are correctly setup
	 */
	public class DTO_Table extends CMN_API_HttpBaseOutbound.DTO_BaseTable
	{
		/**
		 * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
		 *
		 * @param dtoBase Input dto for transformation
		 */
		public override void transform(CMN_DTO_Base dtoBase)
		{
			super.transform(dtoBase);

			addColumn('Row Id', 'id', 'number');
			addColumn('Body', 'body', 'text');
			addColumn('Title', TITLE_FIELD_NAME, 'text');
			addColumn('User Identifier', 'userId', 'number');

			addRow(dtoBase);
		}
	}

	/**
	 * @description Example request object that can serialize to Json
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String body;
		public String title;
		public Integer userId;

		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			userId = CMN_DAL_SObjectDomain.generateRandomInteger();
			body = CMN_DAL_SObjectDomain.generateRandomDescription();
		}

		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			title = !dtoRequestParameters.items.isEmpty() ? dtoRequestParameters.items.iterator().next().value : triggeringObjectId;

			//We are altering the response for the mock based on the title being set... used to test parameters are processed correctly
			if(Test.isRunningTest())
			{
				validResponse = CMN_UTIL_String.replace(validResponse, TITLE_VALUE, title);
			}
		}
	}

	/**
	 * @description Example Response which can serialize to Jsonz
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String body;
		public String title;
		public Integer userId;
		public Integer id;

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
	 * @description This is example of Mock Response object used both in unit tests and when runnin service in mock mode
	 */
	private class CMN_API_RestOutboundExampleMock extends CMN_API_HttpBaseOutboundMock
	{
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}