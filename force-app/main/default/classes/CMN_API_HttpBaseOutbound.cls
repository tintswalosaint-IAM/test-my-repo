/**
 * @description The Base class for all API Web Service Calls (outbound, either SOAP or REST)
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual inherited sharing class CMN_API_HttpBaseOutbound extends CMN_API_HttpBase
{
	private static final Integer DEFAULT_TIMEOUT = 120000;//120 seconds
	private static final String DEBUG_ENDPOINT = 'Endpoint: {0}';
	private static final String DEBUG_REQUEST_BODY = 'Request: {0}.';
	private static final String DEBUG_REQUEST_TIME = 'Request took: {0} milliseconds.';
	private static final String DEBUG_RESPONSE_BODY = 'Response: {0}.';
	@TestVisible
	private static final String ERROR_INVALID_TYPE = 'Invalid Class Type provided';
	private static final String ERROR_NO_TRIGGERING_OBJECT = 'A Valid Triggering Object Id is Required.';
	private static final String ERROR_PARAMETERS_NOT_PROVIDED = 'All required parameters {0} were not provided';
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';

	protected Type baseTableDTOType;
	public CMN_DTO_Base baseRequestDTO;
	public CMN_DTO_Base baseResponseDTO;

	protected transient CMN_DTO_NameValues requestParameters; // HTTP Request parameters
	@TestVisible
	protected transient HttpRequest request; // HTTP Request object used by Service Class
	@TestVisible
	protected transient HttpResponse response; // HTTP Response object used by Service Class
	protected transient Http httpObject;

	// Object stores settings for each webservice, like base endpoint, backoff period, max number of calls allowed etc.
	protected CMN_WebserviceSetting__mdt settings;
    

	/*
 	 * @description Ensure you override this on descendant classes if you need to initialise global variables
	 */
	protected override virtual void initialise()
	{
		super.initialise();

		request = new HttpRequest();
		response = new HttpResponse();
		httpObject = new Http();

		baseRequestDTO = new CMN_DTO_Base();
		baseResponseDTO = new CMN_DTO_Base();
		baseTableDTOType = DTO_BaseTable.class;

		setServiceSettings();
	}

	/**
	 * @description Will return token type as well as token
	 * @return Authorisation Header value
	 */
	protected virtual String getAuthorisationToken()
	{
		String userName = getUserName();

		return String.isBlank(userName) ?
				CMN_UTIL_String.EMPTY :
				HTTP_HEADER_AUTH_BASIC + EncodingUtil.base64Encode(Blob.valueOf(userName + ':' + getPassword()));
	}

	/**
	 * @description Method is use to get the base URL of a webservice, resolves named credential based URL's
	 *
	 * @return A URL without named credential details for query params etc.
	 */
	public String getBaseUrl()
	{
		String endPoint;

		if(settings != null && String.isNotBlank(settings.CMN_NamedCredential__c))
		{
			NamedCredential credential = CMN_DAL_NamedCredential.findByName(getServiceName());
			endPoint = credential == null ? endPoint : credential.Endpoint;
		}

		return endPoint;
	}

	/**
	 * @description Retrieves current Service Client Id
	 *
	 * @return The client id
	 */
	protected virtual String getClientId()
        
	{
      
		return settings != null ? settings.CMN_ClientID__c : null;
         
	}

	/**
	 * @description Retrieves current Service Client Secret
	 *
	 * @return The client id
	 */
	protected virtual String getClientSecret()
	{
		return settings != null ? settings.CMN_Client_Secret__c : null;
        
	}

	/**
	 * @description Retrieves current Service Additional Key; this service will require a client certificate stored in this field
	 *
	 * @return The Additional Key
	 */
	protected String getAdditionalKey()
	{
		return settings != null ? settings.CMN_AdditionalKey__c : null;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
	protected virtual String getWebServiceEndPoint()
	{
		String endPoint;

		if(settings != null && String.isNotBlank(settings.CMN_NamedCredential__c))
		{
			endPoint = String.format(NAMED_CREDENTIAL_URL_FORMAT, new List<String> {settings.CMN_NamedCredential__c, String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY});
		}

		return endPoint;
	}

	/**
	 * @description Override this method to inject relevant query parameters
	 *
	 * @return A list of query parameters
	 */
	protected virtual String getQueryParameters()
	{
		return null;
	}

	/**
	 * @description Adds additional behaviour when item is set; specifically parsing the parameters
	 *
	 * @param queueItem The queue item used by the service calls to initiate an outbound calls
	 */
	protected override virtual void setQueueItem(CMN_WebserviceCallQueue__c queueItem)
	{
		super.setQueueItem(queueItem);
		requestParameters = String.isBlank(queueItem.CMN_Request_Parameters__c) ? new CMN_DTO_NameValues() : (CMN_DTO_NameValues)JSON.deserialize(queueItem.CMN_Request_Parameters__c, CMN_DTO_NameValues.class);
	}

	/**
	 * @description HTTP Character encoding, override if you want to define custom content encoding for service
	 *
	 * @return result
	 */
	public override virtual String getEncoding()
	{
		return HTTP_ENCODING_JSON;
	}

	/**
	 * @description The HTTP Service Timeout, override if you want to set a longer or short timeout
	 *
	 * @return result
	 */
	protected virtual Integer getTimeout()
	{
		return DEFAULT_TIMEOUT;
	}

	/**
	 * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
	 */
	protected virtual void populateRequestDTO()
	{
		baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c, requestParameters);
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
		super.getBody();

		populateRequestDTO();

		return baseRequestDTO.serialize();
	}

	/**
	 * @description use this method to retrieve current response body; override this method if you want to manipulate response body first
	 *
	 * @return the response that will be parsed
	 */
	protected virtual String getResponseBody()
	{
		return response.getBody();
	}

	/**
	 * @description This method will be called if request is successful, ensure you override
	 * This method on descendant classes to consume response.
	 */
	protected virtual void parseResponse()
	{
		String responseBody = getResponseBody();

		if(CMN_UTIL_String.isNotBlank(responseBody))
		{
			baseResponseDTO = baseResponseDTO.deserialize(responseBody);
		}
	}

	/**
	 * @description Implement this method to provide a the service response in a table structure
	 *
	 * @return A table structure DTO with columns and rows
	 */
	public DTO_BaseTable getResponseAsTable()
	{
		return (DTO_BaseTable)transformResponse(baseTableDTOType);
	}

	/**
	 * @description Will transform response into alternative structure
	 *
	 * @param dtoBase the object that will be populated with the transformed version of the responseDTo
	 *
	 * @see CMN_API_HttpBaseOutbound.baseResponseDTO
	 * @see CMN_DTO_Base.populate
	 */
	public virtual void transformResponse(CMN_DTO_Base dtoBase)
	{
		dtoBase.transform(baseResponseDTO);
	}

	/**
	 * @description Retrieves current Service username
	 *
	 * @return result
	 */
	protected String getUserName()
	{
		return settings != null ? settings.CMN_Username__c : null;
	}

	/**
	 * @description Retrieves current Service password
	 *
	 * @return result
	 */
	protected String getPassword()
	{
		String password = settings != null ? settings.CMN_Password__c : null;
		return String.isNotBlank(password) ? password : CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description The HTTP Verb that the service will use when making a request, override this if you want to change this for
	 * Descendant class
	 *
	 * @return result
	 */
	protected override virtual String getVerb()
	{
		String verb = super.getVerb();

		return String.isNotBlank(verb) ? verb : HTTP_VERB_POST;
	}

	protected virtual String getSettingsServiceName()
	{
		return getServiceName();
	}

	/**
	 * @description Will transform response into alternative structure
	 *
	 * @param dtoType The type of the class to which the response should be transformed
	 *
	 * @return The transformed response object
	 */
	public CMN_DTO_Base transformResponse(Type dtoType)
	{
		Object dto = dtoType.newInstance();

		if(dto instanceof CMN_DTO_Base)
		{
			CMN_DTO_Base dtoBase = (CMN_DTO_Base)dto;
			transformResponse(dtoBase);
			return dtoBase;
		}
		else
		{
			throw new TypeException(ERROR_INVALID_TYPE);
		}

	}

	/**
	 * @description Will transform response into alternative structure
	 *
	 * @param dtoClassName A CMN_DTO_Base class name
	 *
	 * @return The transformed response object
	 */
	public CMN_DTO_Base transformResponse(String dtoClassName)
	{
		Type dtoType = Type.forName(dtoClassName);

		if(dtoType == null)
		{
			throw new IllegalArgumentException(ERROR_INVALID_TYPE);
		}

		return transformResponse(dtoType);
	}

	/**
	 * @description Method will return relevant webservice custom setting for the current Service  Name
	 * Ensure you have override getServiceName on descendant classes for this to retrieve custom setting
	 * If NO Custom Metadata found then a empty one will be created
	 */
	protected void setServiceSettings()
	{
		settings = CMN_DAL_WebserviceSetting.getMetadata(getSettingsServiceName());
	}

	/**
	 * @description Will read web service settings to determine if stack track should be added to exceptions
	 *
	 * @return A boolean; true will add stack track to exceptions
	 */
	protected override Boolean addStackTraceToExceptions()
	{
		Boolean addTrace = super.addStackTraceToExceptions();
		return settings != null ? settings.CMN_AddStackTraceToExceptions__c : addTrace;
	}

	/**
	 * @description Sets relevant HTTP headers, override if you need to add service specific headers
	 */
	protected virtual void setHeaders()
	{
		request.setMethod(getVerb());

		if(!HTTP_VERB_GET.equalsIgnoreCase(request.getMethod()))
		{
			request.setHeader(HTTP_CONTENT_TYPE, getEncoding());
		}
		request.setTimeout(getTimeout());

		String authorisationToken = getAuthorisationToken();

		if(String.isNotEmpty(authorisationToken))
		{
			CMN_UTIL_Logger.info(HTTP_HEADER_AUTHORIZATION + ':' + authorisationToken, getServiceName() + '/setHeaders');
			request.setHeader(HTTP_HEADER_AUTHORIZATION, authorisationToken);
		}

		String clientId = getClientId();

		if(String.isNotBlank(clientId))
		{
			CMN_UTIL_Logger.info(HTTP_HEADER_CLIENT_ID + ':' + clientId, getServiceName() + '/setHeaders');
			request.setHeader(HTTP_HEADER_CLIENT_ID, clientId);
		}

		String clientSecret = getClientSecret();
		if(String.isNotBlank(clientSecret))
		{
			CMN_UTIL_Logger.info(HTTP_HEADER_CLIENT_SECRET + ':' + clientSecret, getServiceName() + '/setHeaders');
			request.setHeader(HTTP_HEADER_CLIENT_SECRET, clientSecret);
		}
	}

	/**
	 * @description Method will set headers, body and endpoint, override this method on descendant
	 * if you need to change how this is done. Rarely necessary.
	 *
	 * @param body as input
	 *
	 * @return request
	 */
	protected virtual HttpRequest createRequest(String body)
	{
		setHeaders();

		if(String.isNotBlank(body) && !HTTP_VERB_GET.equalsIgnoreCase(request.getMethod()))
		{
			request.setBody(body);
		}

		String endPoint = getWebServiceEndPoint();
		String queryParams = getQueryParameters();

		endPoint = String.isNotBlank(queryParams) ? endPoint + '?' + queryParams : endPoint;

		callResult.url = endPoint;

		request.setEndpoint(endPoint);

		callResult.requestBody = request.getBody();

		return request;
	}

	/**
	 * @description To get the endpoint from mock request
	 * param getEndpointMock()
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected virtual CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new CMN_API_HttpBaseOutboundMock();
	}

	/**
	 * @description Indicate if a triggering object id is required
	 *
	 * @return Boolean indicating requirement
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected virtual Boolean triggeringObjectRequired()
	{
		return true;
	}

	/**
	 * @description If the service call requires parameters to be provided, then implement this virtual method to indicate this
	 * This will then be used to determine whether service can run
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected virtual Set<String> getRequiredParameters()
	{
		return new Set<String>();
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected override virtual Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();

		if(triggeringObjectRequired() && CMN_UTIL_String.validateId(queueItem.CMN_TriggeringObjectId__c) == null)
		{
			callResult.errors.add(ERROR_NO_TRIGGERING_OBJECT);
			abort = true;
		}

		Set<String> parameters = getRequiredParameters();

		if(!requestParameters.allExists(parameters))
		{
			callResult.errors.add(String.format(ERROR_PARAMETERS_NOT_PROVIDED, new List<String> {JSON.serialize(parameters)}));
			abort = true;
		}

		return abort;
	}

	/**
	 * @description Method will send request to endpoint, and record whether successful or not
	 *
	 * @param request The HttpRequest object contain body and headers
	 *
	 * @see HttpRequest
	 */
	protected virtual void sendRequest(HttpRequest request)
	{
		if(Test.isRunningTest())
		{
			Test.setMock(HttpCalloutMock.class, getEndpointMock());
		}

		callResult.mocking = isMocking();

		response = callResult.mocking ? getEndpointMock().respond(request) : httpObject.send(request);

		String methodName = getServiceName() + '/sendRequest';

		CMN_UTIL_Logger.debug(String.format(DEBUG_ENDPOINT, new List<String> {request.getEndpoint()}), methodName);
		CMN_UTIL_Logger.debug(String.format(DEBUG_REQUEST_BODY, new List<String> {request.getBody()}), methodName);
		CMN_UTIL_Logger.debug(String.format(DEBUG_REQUEST_TIME, new List<String> {String.valueOf(stopWatch.getTime())}), methodName);
		CMN_UTIL_Logger.debug(String.format(DEBUG_RESPONSE_BODY, new List<String> {response.getBody()}), methodName);

		callResult.statusCode = String.valueOf(response.getStatusCode());
		callResult.responseBody = response.getBody();

		if(HTTP_VALID_CODES.contains(response.getStatusCode()))
		{
			callResult.completed = true;
		}
		else
		{
			callResult.failed = true;
		}
	}

	/**
	 * @description Once a call is completed this method is called to persist call results back to Queue Item
	 * Override this on descendant classes if you want to update other data in the system
	 * This method will also initiate retry if necessary
	 */
	public override virtual void setQueueItemDetails()
	{
		super.setQueueItemDetails();

		// if callResult was successful, determine do we need to make another call in chain
		// else retry current call

		if(callResult.failed)
		{
			retry();
		}
	}

	/**
	 * @description This method will also initiate retry if necessary
	 */
	private void retry()
	{
		Decimal maxRetryCount = settings != null && settings.CMN_MaxRetriesNo__c != null ? settings.CMN_MaxRetriesNo__c : 0;

		if(queueItem.CMN_Retries__c < maxRetryCount)
		{
			Decimal backoffSecs = settings != null && settings.CMN_BackoffPeriod__c != null ? settings.CMN_BackoffPeriod__c : 0;
			backoffSecs = queueItem.CMN_Retries__c <= 0 ? backoffSecs : backoffSecs * queueItem.CMN_Retries__c;
			Datetime nextRetry = backoffSecs > 0 ? Datetime.now().addSeconds(backoffSecs.intValue()) : null;

			if(nextRetry != null)
			{
				CMN_DAL_WebserviceCallQueue.updateNextRetryInfo(queueItem, nextRetry);
			}
		}
	}

	/**
	 * @description Main process loop which controls the processing of outbound request and ensure result of call is logged
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */
	public override void process(CMN_WebserviceCallQueue__c queueItem)
	{
		super.process(queueItem);

		callResult.aborted = true;

		if(abortRequest())
		{
			callResult.aborted = true;
		}
		else
		{
			//Make the service call
			sendRequest(createRequest(getBody()));

			//Save the results of the service call

			if(callResult.completed)
			{
				parseResponse();
				registerDatabaseChanges();
			}
		}

		// Update the QueueItem
		setQueueItemDetails();
	}

	/**
	 * @description A DTO used to transform the native response of a webservice handler into a common table structure
	 */
	public virtual class DTO_BaseTable extends CMN_DTO_JsonBase
	{
		transient protected List<DTO_Column> tableColumns;
		transient protected List<Object> tableRows = new List<Object>();

		/**
		 * @description List of the defined columns in the table
		 */
		public List<DTO_Column> columns
		{
			get
			{
				return tableColumns;
			}
		}

		/**
		 * @description All the data rows for the table
		 */
		public List<Object> rows
		{
			get
			{
				return tableRows;
			}
		}

		/**
		 * @description
		 *
		 * @param label The text to render for a column
		 * @param fieldName The name of the field to match row data to column
		 * @param type The type contained in the column, see documentation for types here: https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation
		 */
		public virtual void addColumn(String label, String fieldName, String type)
		{
			if(tableColumns == null)
			{
				tableColumns = new List<DTO_Column>();
			}

			DTO_Column column = new DTO_Column();

			column.label = label;
			column.fieldName = fieldName;
			column.type = type;

			tableColumns.add(column);
		}

		/**
		 * @description Override this if you want to do specific handling of a data
		 *
		 * @param anObject The object to be used as source of data for the row
		 */
		public virtual void addRow(Object anObject)
		{
			tableRows.add(anObject);
		}
	}

	/**
	 * @description Defines a column
	 */
	public class DTO_Column
	{
		String label;
		String fieldName;
		String type;
	}

}