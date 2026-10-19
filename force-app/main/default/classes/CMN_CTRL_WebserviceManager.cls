/**
 * @description A controller that supports performing webservice calls from components
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class CMN_CTRL_WebserviceManager
{
	/**
	 * @description Method will invoke a webservice handler synchronously and return the response as a string
	 *
	 * @param webServiceClassName The webservice handler class name (required parameter)
	 * @param triggerObjectId The object that triggered the call (can be set to null)
	 * @param parameters A list of comma separated name value pairs (can be set to null)
	 * @param transformToTable Indicates if the response should be transformed to a table structure (take precedence over transformClassName variable)
	 * @param transformClassName Set this to the name of a public CMN_DTO_Base class and response will be transformed using this
	 *
	 * @return The response of the call; will either contain raw response, a table structure response or errors in a list
	 *
	 * @see CMN_API_HttpBaseOutbound.DTO_BaseTable
	 */
	@AuraEnabled
	public static String invokeWebserviceCallSynchronously
			(
					String webServiceClassName,
					Id triggerObjectId,
					String parameters,
					Boolean transformToTable,
					String transformClassName
			)
	{
		CMN_FACTORY_WebserviceManager.DTO_Request dtoRequest = new CMN_FACTORY_WebserviceManager.DTO_Request();

		dtoRequest.webServiceClassName = webServiceClassName;
		dtoRequest.triggerObjectId = triggerObjectId;
		dtoRequest.parameters = parameters;
		dtoRequest.transformToTable = transformToTable == null ? false : transformToTable;
		dtoRequest.transformClassName = transformClassName;

		List<CMN_FACTORY_WebserviceManager.DTO_Response> dtoResponses = CMN_FACTORY_WebserviceManager.invokeWebserviceCallSynchronously(new List<CMN_FACTORY_WebserviceManager.DTO_Request> {dtoRequest});

		return dtoResponses.isEmpty() ? CMN_UTIL_String.EMPTY : JSON.serializePretty(dtoResponses.iterator().next(), true);
	}
}