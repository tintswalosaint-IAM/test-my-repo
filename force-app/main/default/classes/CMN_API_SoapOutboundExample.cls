/**
 * @description This is an example Outbound SOAP API call; that hits a public soap service https://www.dataaccess.com/webservicesserver/NumberConversion.wso?op=NumberToWords
 *
 * @author Accenture
 *
 * @date April 2021
 */
public inherited sharing class CMN_API_SoapOutboundExample extends CMN_API_SoapBaseOutbound
{
	@TestVisible
	private final static String PARAMETER_UBI_NUM = 'ubiNum';
	private final static String ROOT_NODE_NAMESPACE = 'http://www.dataaccess.com/webservicesserver/';
	private final static String SOAP_METHOD_PREFIX = 'NumberToWords';
	@TestVisible
	private static final String SERVICE_NAME = CMN_API_SoapOutboundExample.class.getName();

	/**
	 * @description Set the request and response DTO's
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description The name of the SOAP method we are calling
	 *
	 * @return the name of the SOAP method
	 */
	protected override String getSoapAction()
	{
		//Call base method to ensure this code is coveredd in unit tests
		return super.getSoapAction() + SOAP_METHOD_PREFIX;
	}

	/**
	 * @description Defines the default SOAP body namespace, used when extracting SOAPAction out of the body
	 *
	 * @return Namespace
	 *
	 * @see CMN_API_SoapBaseOutbound.getBody
	 */
	protected override String getSoapBodyNamespace()
	{
		//Calling base code to cover in unit tests
		super.getSoapBodyNamespace();
		return 'soap';
	}

	/**
	 * @description Indicate if a triggering object id is required
	 *
	 * @return Boolean indicating requirement
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
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
	 * @description Return the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new CMN_API_SoapOutboundExample_Mock();
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

		parameters.add(PARAMETER_UBI_NUM);

		return parameters;
	}

	/**
	 * @description The request to to be sent for retrieval of words for a number
	 */
	private class DTO_Request extends CMN_DTO_XmlBase.DTO_XmlRootNode
	{
		public Long ubiNum;

		/**
		 * @description Register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			registerRootNode(SOAP_METHOD_PREFIX, ROOT_NODE_NAMESPACE, CMN_API_SoapBaseOutbound.ROOT_NODE_PREFIX);
			ubiNum = registerLongNode('ubiNum', null, null, ubiNum);
		}

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);
			ubiNum = Long.valueOf(dtoRequestParameters.getFirst(PARAMETER_UBI_NUM));
		}
	}

	/**
	 * @description The response received for retrieving words for a number
	 */
	@TestVisible
	private class DTO_Response extends CMN_DTO_XmlBase.DTO_XmlRootNode
	{
		public String NumberToWordsResult;

		/**
		 * @description Register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			registerRootNode(SOAP_METHOD_PREFIX + 'Response', ROOT_NODE_NAMESPACE, CMN_API_SoapBaseOutbound.ROOT_NODE_PREFIX);
			NumberToWordsResult = registerStringNode('NumberToWordsResult', ROOT_NODE_NAMESPACE, CMN_API_SoapBaseOutbound.ROOT_NODE_PREFIX, NumberToWordsResult);
		}
	}

	/**
	 * @description Mock class for returning test data
	 */
	private class CMN_API_SoapOutboundExample_Mock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><m:NumberToWordsResponse xmlns:m="http://www.dataaccess.com/webservicesserver/"><m:NumberToWordsResult>twelve thousand three hundred and forty five </m:NumberToWordsResult></m:NumberToWordsResponse></soap:Body></soap:Envelope>';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}