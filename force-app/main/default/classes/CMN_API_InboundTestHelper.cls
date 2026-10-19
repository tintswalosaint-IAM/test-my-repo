/**
 * @description Class has base methods that can be used to assist with testing inbound service calls
 *
 * @author Accenture
 *
 * @date December 2020
 */
public inherited sharing class CMN_API_InboundTestHelper
{
	/**
	 * @description Will setup the RestContext Objects of "request" and "response"
	 *
	 * @param dtoRequest The DTO that should be serialised and represents the JSON sent in a request
	 */
	@TestVisible
	private static void setupRestContext(CMN_DTO_Base dtoRequest)
	{
		setupRestContext();
		RestContext.request.requestBody = Blob.valueOf(dtoRequest.serialize());
	}

	/**
	 * @description Will setup the RestContext Objects of "request" and "response"
	 */
	@TestVisible
	private static void setupRestContext()
	{
		RestContext.request = new RestRequest();
		RestContext.request.headers.put(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		RestContext.response = new RestResponse();
	}
}