/**
 * @description This implements the HTTPMock Callout interface and form the parent class of HTTPCalloutMocks
 * to allow us to test HTTP callouts
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual class CMN_API_HttpBaseOutboundMock implements HttpCalloutMock
{
	public static Boolean returnErrorResponse = false;
	public static Boolean failParse = false;

	public static final String PARSE_FAIL_RESPONSE = '****}{}{}{}{}{}{}********';

	/**
	 * @description This method is use to create a mock request based on the process.
	 *
	 * @param request as input
	 *
	 * @return response
	 */
	public HttpResponse respond(HttpRequest request)
	{
		HttpResponse response = new HttpResponse();

		if(returnErrorResponse)
		{
			setErrorResponse(response);
		}
		else if(failParse)
		{
			setParseFailResponse(request, response);
		}
		else
		{
			setResponse(request, response);
		}

		return response;
	}

	/**
	 * @description set mock response
	 *
	 * @param request as input
	 * @param response as input
	 */
	protected virtual void setResponse(HttpRequest request, HttpResponse response)
	{
		response.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
	}

	/**
	 * @description set mock failed response
	 *
	 * @param request as input
	 * @param response as input
	 */
	protected virtual void setParseFailResponse(HttpRequest request, HttpResponse response)
	{
		response.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
		response.setBody(PARSE_FAIL_RESPONSE);
	}

	/**
	 * @description set mock error response
	 *
	 * @param response as input
	 */
	protected virtual void setErrorResponse(HttpResponse response)
	{
		response.setStatusCode(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
		response.setStatus(CMN_API_HttpBase.ERR_INTERNAL_SERVER);
		response.setBody(CMN_API_HttpBase.ERR_INTERNAL_SERVER);
	}
}