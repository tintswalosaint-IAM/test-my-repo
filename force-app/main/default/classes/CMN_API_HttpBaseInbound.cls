/**
 * @description The Base class for all API Web Service Calls (inbound, either SOAP or REST)
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual inherited sharing class CMN_API_HttpBaseInbound extends CMN_API_HttpBase
{
	/**
	 * @description Use on base level to allow any inbound api call to add stack track information in the event of an exception
	 */
	@TestVisible
	private static final String QUERY_PARAM_ADD_STACK_TRACE = 'addStackTraceToExceptions';
	@TestVisible
	private static final String ERROR_TEST_EXCEPTION_HANDLING = 'This is an error to test exception handling';
	/**
	 * @description Set this static variable to true to generate an exception during unit test exception to test exception handling behaviour for inbound API's
	 */
	@TestVisible
	private static Boolean returnErrorResponse = false;

	protected RestRequest request;
	/**
	 * @description Returns the restBody in the current Inbound HTTP Request
	 */
	protected String requestBody
	{
		get
		{
			return request.requestBody == null || request.requestBody.size() == 0 ? CMN_UTIL_String.EMPTY : request.requestBody.toString();
		}
	}

	/**
	 * @description reference to rest response
	 */
	protected RestResponse response;

	/**
	 * @description Property to wrap the responseBody
	 */
	protected String responseBody
	{
		get
		{
			return response.responseBody == null || response.responseBody.size() == 0 ? CMN_UTIL_String.EMPTY : response.responseBody.toString();
		}
		set
		{
			response.responseBody = Blob.valueOf(value);
		}
	}

	/**
	 * @description Initialises various class variables, override these in descendant classes to initialise additional class
	 */
	protected override virtual void initialise()
	{
		super.initialise();

		request = RestContext.request;
		response = RestContext.response;

		callResult.url = request.requestURI;

		String queryString = CMN_UTIL_String.EMPTY;

		Set<String> queryParams = new Set<String>();

		for(String key : request.params.keySet())
		{
			queryParams.add(queryString + key + '=' + request.params.get(key));
		}

		queryString = CMN_UTIL_String.joinSet(queryParams, '&');

		callResult.url = String.isNotBlank(queryString) ? callResult.url + '?' + queryString : callResult.url;

		callResult.requestBody = requestBody;
	}

	/**
	 * @description Will read web query params to determine if stack track should be added to exceptions
	 *
	 * @return A boolean; true will add stack track to exceptions
	 */
	protected override Boolean addStackTraceToExceptions()
	{
		Boolean addTrace = super.addStackTraceToExceptions();

		if(!addTrace)
		{
			String paramValue = request.params.get(QUERY_PARAM_ADD_STACK_TRACE);
			addTrace = String.isNotBlank(paramValue) && Boolean.valueOf(paramValue);
		}

		return addTrace;
	}

	/**
	 * @description HTTP Character encoding, override if you want to define custom content encoding for service
	 *
	 * @return string Get the request
	 */
	protected override virtual String getEncoding()
	{
		String encoding = super.getEncoding();
		return String.isNotBlank(encoding) ? encoding : request.headers.get(HTTP_CONTENT_TYPE);
	}

	/**
	 * @description Method is use to display exceptions if error occurs
	 *
	 * @param error the exception that needs to be managed
	 */
	public override virtual void handleError(Exception error)
	{
		super.handleError(error);

		Boolean isDMLException = error instanceof DmlException;

		//If Database error was thrown, must be some unhandled exception
		Integer statusCode = isDMLException ? CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR : CMN_API_HttpBase.HTTP_BAD_REQUEST;

		callResult.statusCode = String.valueOf(statusCode);

		writeResponse();
	}

	/**
	 * @description Method to should be implemented on descendant class to act on the request received
	 */
	protected virtual void processRequest()
	{
	}

	/**
	 * @description method which is used to update the results of the call, such as status and responseBody
	 */
	protected virtual void updateCallResult()
	{
		callResult.completed = true;
	}

	/**
	 * @description This method will be called if request is successful, ensure you override
	 * this method if you want to change the response written, by default values are taken from callResult
	 */
	protected virtual void writeResponse()
	{
		if(callResult.completed && String.isNotBlank(callResult.responseBody))
		{
			responseBody = callResult.responseBody;
		}
		else if(!callResult.errors.isEmpty())
		{
			responseBody = JSON.serializePretty(callResult.errors, true);
			callResult.responseBody = responseBody;
		}

		//Make sure we set the status code, so this finds it way back on the queueItem
		if(callResult.completed && String.isBlank(callResult.statusCode))
		{
			callResult.statusCode = String.valueOf(CMN_API_HttpBase.HTTP_OK);
		}

		response.statusCode = Integer.valueOf(callResult.statusCode);
	}

	/**
	 * @description Will ensure that any changes to be made to Salesforce are registered here
	 */
	protected override virtual void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		if(returnErrorResponse)
		{
			NullPointerException error = new NullPointerException();
			error.setMessage(ERROR_TEST_EXCEPTION_HANDLING);
			throw error;
		}
	}

	/**
	 * @description Main process loop which controls the processing of inbound request and ensure result of call is logged
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */
	public override void process(CMN_WebserviceCallQueue__c queueItem)
	{
		super.process(queueItem);

		//Process request by reading URL, Params, RequestBody and do relevant processing, queries
		processRequest();

		//If the service call is making changes to data, register these changes here
		registerDatabaseChanges();
	}

	/**
	 * @description Any actions to take after a commit is completed, like setting response, updating queue item
	 */
	public override virtual void onCommitWorkFinishing()
	{
		super.onCommitWorkFinishing();

		//set the response object with outcome of the call
		updateCallResult();

		//Ensure we update the Http response appropriately based on call result
		writeResponse();

		//Update the webservice queue object with result of the call so this can be logged.
		setQueueItemDetails();

		//Update queue Item with response information that may have changed
		update queueItem;
	}
}