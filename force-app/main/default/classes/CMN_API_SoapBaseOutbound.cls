/**
 * @description This is Base call for all Outbound SOAP API calls
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date April 2021
 */
public virtual class CMN_API_SoapBaseOutbound extends CMN_API_HttpBaseOutbound
{
	private static final String DEFAULT_SOAP_BODY_NAMESPACE = 'soapenv';
	private static final String END_BODY_ELEMENT = '</{0}Body>';
	private static final String HTTP_ACCEPT_XML_WITH_CHARSET = 'text/xml; charset=' + CMN_API_HttpBase.UTF8_ENCODING_SCHEME;
	private static final String HTTP_ENCODING_XML = 'text/xml; charset=' + CMN_API_HttpBase.UTF8_ENCODING_SCHEME;
	private static final String HTTP_HEADER_SOAP_ACTION = 'SOAPAction';
	private static final String START_BODY_ELEMENT = '<{0}Body>';
	private static final String XML_PROCESSING_INSTRUCTIONS = '<?xml version="1.0" encoding="UTF-8"?>';
	public static final String ROOT_NODE_PREFIX = 'ns';

	/**
	 * @description This constant will be used to construct SOAP request
	 */
	private static final String SOAP_PAYLOAD_FORMAT = XML_PROCESSING_INSTRUCTIONS + '\n' +
			'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">\n' +
			'   <soapenv:Body>\n' +
			'         {0}\n' +
			'   </soapenv:Body>\n' +
			'</soapenv:Envelope>';

	/**
	 * @description The name of the SOAP method we are calling, must be set by child classes if they are using SOAP 1.1
	 *
	 * @return the name of the SOAP method
	 */
	protected virtual String getSoapAction()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Defines the default SOAP body namespace, used when extracting SOAPAction out of the body
	 *
	 * @return Namespace
	 *
	 * @see CMN_API_SoapBaseOutbound.getBody
	 */
	protected virtual String getSoapBodyNamespace()
	{
		return DEFAULT_SOAP_BODY_NAMESPACE;
	}

	/**
	 * @description Sets relevant headers required for SOAP API calls
	 */
	protected virtual override void setHeaders()
	{
		super.setHeaders();

		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ACCEPT_XML_WITH_CHARSET);
		request.setHeader(HTTP_HEADER_SOAP_ACTION, getSoapAction());
	}

	/**
	 * @description HTTP Character encoding required for SOAP payloads
	 *
	 * @return the HTTP encoding
	 */
	public override virtual String getEncoding()
	{
		return HTTP_ENCODING_XML;
	}

	/**
	 * @description Will generate the request body using the type of the baseRequestDTO
	 *
	 * @return A SOAP strutured request
	 *
	 * @see CMN_DTO_Base
	 * @see CMN_API_HttpBaseOutbound.initialise
	 */
	protected virtual override String getBody()
	{
		String body = CMN_UTIL_String.remove(super.getBody(), XML_PROCESSING_INSTRUCTIONS);
		return String.format(SOAP_PAYLOAD_FORMAT, new List<String> {body});
	}

	/**
	 * @description Parse the XML response (we're expecting SOAP protocol envelope), strip out envelop and only leave the Action node
	 *
	 * @return The response body that will be parsed
	 */
	protected override String getResponseBody()
	{
		String soapBodyNamespace = getSoapBodyNamespace();
		soapBodyNamespace = String.isNotBlank(soapBodyNamespace) ? soapBodyNamespace + ':' : soapBodyNamespace;
		String soapBodyStart = String.format(START_BODY_ELEMENT, new List<String> {soapBodyNamespace});
		String soapBodyEnd = String.format(END_BODY_ELEMENT, new List<String> {soapBodyNamespace});

		String responseBody = CMN_UTIL_String.substringBetweenIgnoreCase(super.getResponseBody(), soapBodyStart, soapBodyEnd);
		return String.isBlank(responseBody) ? super.getResponseBody() : responseBody;
	}
}