/**
 * @description This is Base call for all Outbound REST API calls
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual class CMN_API_RestBaseOutbound extends CMN_API_HttpBaseOutbound
{

	/**
	 * @description Sets relevant HTTP headers, override if you need to add service specific headers
	 */
	protected virtual override void setHeaders()
	{
		super.setHeaders();
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ACCEPT_JSON_WITH_CHARSET);
	}

	/**
	 * @description Check if the JSON Response is in the form of an array without key; Parsing this using a Salesforce DTO
	 * class is not possible so it needs to be manually added to the response
	 *
	 * @return Boolean - An indicator to show if the response is an array and is withing a key node.
	 */
	protected virtual Boolean hasArrayResponse()
	{
		return false;
	}

	/**
	 * @description use this method to retrieve current response body; override this method if you want to manipulate response body first
	 *
	 * @return the response that will be parsed
	 */
	protected virtual override String getResponseBody()
	{
		String responseBody = super.getResponseBody();

		responseBody = hasArrayResponse() ? '{ "responses" : ' + responseBody + '}' : responseBody;

		List<String> searchTokens = new List<String>();
		List<String> replaceTokens = new List<String>();

		getResponseReplacementTokens(searchTokens, replaceTokens);

		return CMN_UTIL_String.replaceEachRepeatedly(responseBody, searchTokens, replaceTokens, true);
	}

	/**
	 * @description Will generate the request body using the type of the baseRequestDTO
	 *
	 * @return result
	 *
	 * @see CMN_DTO_Base
	 * @see CMN_API_HttpBaseOutbound.initialise
	 */
	protected virtual override String getBody()
	{
		List<String> searchTokens = new List<String>();
		List<String> replaceTokens = new List<String>();

		getRequestReplacementTokens(searchTokens, replaceTokens);

		return CMN_UTIL_String.replaceEachRepeatedly(super.getBody(), searchTokens, replaceTokens, true);
	}

	/**
	 * @description If there are reserved words in a particular service handler response, indicate what it should be replace with prior to de-serialisation
	 *
	 * @param searchTokens The search tokens to be found
	 * @param replaceTokens The token to replace with if matching search token is found
	 */
	protected virtual void getResponseReplacementTokens(List<String> searchTokens, List<String> replaceTokens)
	{

	}

	/**
	 * @description If there are reserved words in a particular service handler rquest, indicate what it should be replace with prior to serialization
	 *
	 * @param searchTokens The search tokens to be found
	 * @param replaceTokens The token to replace with if matching search token is found
	 */
	protected virtual void getRequestReplacementTokens(List<String> searchTokens, List<String> replaceTokens)
	{

	}
}