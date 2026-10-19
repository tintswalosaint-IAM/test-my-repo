/**
 * @description The Base class for all API Web Service Calls (outbound/inbound, either SOAP or REST)
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual inherited sharing class CMN_API_HttpBase extends CMN_DAL_SObjectUnitOfWork
{
	//http status codes https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	public static final Integer HTTP_OK = 200;
	public static final Integer HTTP_CREATED = 201;
	public static final Integer HTTP_ACCEPTED = 202;
	public static final Integer HTTP_NON_AUTH_INFO = 203;
	public static final Integer HTTP_NO_CONTENT = 204;
	public static final Integer HTTP_RESET_CONTENT = 205;
	public static final Integer HTTP_BAD_REQUEST = 400;
	public static final Integer HTTP_UNAUTHORISED = 401;
	public static final Integer HTTP_INTERNAL_SERVER_ERROR = 500;

	public static final Set<Integer> HTTP_VALID_CODES = new Set<Integer>
	{
			HTTP_OK, HTTP_CREATED, HTTP_ACCEPTED, HTTP_NON_AUTH_INFO, HTTP_NO_CONTENT, HTTP_RESET_CONTENT
	};
	private static final String ERROR_API_DISABLED = 'API has been disabled';

	public final static String HTTP_ENCODING_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
	public static final String ERR_INTERNAL_SERVER = 'Internal Server Error';
	public static final String ERR_INTERNAL_UNAUTHORISED = 'Unauthorised';
	public static final String UTF8_ENCODING_SCHEME = 'UTF-8';
	public static final String HTTP_ACCEPT_JSON_WITH_CHARSET = 'application/json; charset=' + UTF8_ENCODING_SCHEME;
	public static final String HTTP_AUTH_TOKEN_BEARER = 'Bearer ';
	public static final String HTTP_CONTENT_TYPE = 'Content-Type';
	public static final String HTTP_ENCODING_JSON = 'application/json';
	public static final String HTTP_ENCODING_URL = 'application/x-www-form-urlencoded';
	public static final String HTTP_HEADER_ACCEPT = 'Accept';
	public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
	public static final String HTTP_HEADER_AUTH_BASIC = 'Basic ';
	public static final String HTTP_HEADER_CLIENT_ID = 'x-ibm-client-id';
	public static final String HTTP_HEADER_CLIENT_SECRET = 'x-ibm-client-secret';
	public static final String HTTP_HEADER_X_CLIENT_CERTIFICATE = 'x-client-certificate';
	public static final String HTTP_VERB_GET = 'GET';
	public static final String HTTP_VERB_POST = 'POST';
	public static final String HTTP_VERB_PUT = 'PUT';
	public static final String HTTP_ACCEPT = 'application/json';
	public static final String HTTP_HEADER_CERTIFICATE = 'x-client-certificate';
	public static final String HTTP_HEADER_INTERACTIONID = 'x-fapi-interaction-id';
	public static final String HTTP_HEADER_CLIENTID = 'x-ibm-client-id';
	public static final String HTTP_HEADER_CLIENTSECRET = 'x-ibm-client-secret';
	public static final String HTTP_HEADER_CLIENTID_WFR = 'client-id';
	public static final String HTTP_HEADER_CLIENTSECRET_WFR = 'client-secret';
	public static final String HTTP_HEADER_TRACEID = 'x-trace-id';
	public static final String HTTP_HEADER_CORRELATION = 'x-correlation';
	public static final String HTTP_HEADER_AUTH_BEARER = 'Bearer ';
	private static final String ERROR_NO_API_DISABLE = 'API has been disabled';
	public static final String HTTP_ACCEPT_WITH_CHARSET =
			'application/json; charset=' + UTF8_ENCODING_SCHEME;
	/**
	 * @description A stop watch that can be used by external class to measure time taken by handler to process request
	 */
	protected CMN_UTIL_StopWatch stopWatch
	{
		get
		{
			if(stopWatch == null)
			{
				stopWatch = new CMN_UTIL_StopWatch();
			}

			return stopWatch;
		}
		private set;
	}

	@TestVisible
	protected CMN_WebserviceCallQueue__c queueItem; //The WebService Queue Item that initiated service call

	/**
	 * @description Object to track the request, response and status of a web service call
	 */
	public CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = new CMN_DAL_WebserviceCallQueue.ServiceCallResult();

	public CMN_API_HttpBase()
	{
		initialise();
	}

	/**
	 * @description Ensure you override this on descendant classes if you need to initialise global variables
	 */
	protected virtual void initialise()
	{
		stopWatch.start();

		setUnitOfWorksObjectTypes();

		if(Test.isRunningTest() && queueItem == null)
		{
			setQueueItem(CMN_DAL_DataFactory.newWebserviceQueue());
		}
	}

	/**
	 * @description HTTP Character encoding, override if you want to define custom content encoding for service
	 *
	 * @return string
	 */
	protected virtual String getEncoding()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description The HTTP Verb that the service will use when making a request, override this if you want to change this for
	 * Descendant class
	 *
	 * @return string
	 */
	protected virtual String getVerb()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Will ensure that any changes to be made to Salesforce are registered here
	 */
	protected virtual void registerDatabaseChanges()
	{
	}

	/**
	 * @description This method will be called to get HTTP request Body
	 * Override this on descendant classes to provide relevant body
	 *
	 * @return string
	 */
	protected virtual String getBody()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description This method must be called after object is constructed otherwise it will lead to an assert being raised.
	 *
	 * @param queueItem Use this parameter to store CMN_WebserviceCallQueue__c
	 */
	protected virtual void setQueueItem(CMN_WebserviceCallQueue__c queueItem)
	{
		this.queueItem = queueItem;

		//Make sure we reset the time taken when given queue item as we are start
		this.queueItem.CMN_RequestTimeTaken__c = null;

		//Add the queue item to list of changes we want to commit
		registerChange(this.queueItem);
	}

	/**
	 * @description This method is used to get the queue items
	 *
	 * @return queueItem
	 */
	public virtual CMN_WebserviceCallQueue__c getQueueItem()
	{
		return queueItem;
	}

	/**
	 * @description Will shorten a response to the length given
	 *
	 * @param inputString The response
	 * @param maxLength The maximum length
	 *
	 * @return The abbreviated string
	 */
	private String abbreviate(String inputString, Integer maxLength)
	{
		return String.isNotBlank(inputString) && inputString.length() > maxLength ? CMN_UTIL_String.abbreviate(inputString, maxLength) : inputString;
	}

	/**
	 * @description Will update the Queue Item with the final results of the call made
	 */
	public virtual void setQueueItemDetails()
	{
		queueItem.CMN_Request__c = abbreviate(callResult.requestBody, CMN_DAL_WebserviceCallQueue.REQUEST_LEN);
		queueItem.CMN_Response__c = abbreviate(callResult.responseBody, CMN_DAL_WebserviceCallQueue.RESPONSE_LEN);
		queueItem.CMN_Status__c = callResult.statusText;
		queueItem.CMN_StatusCode__c = callResult.statusCode;
		queueItem.CMN_NextRetry__c = null;
		queueItem.CMN_Errors__c = CMN_UTIL_String.joinArray(callResult.errors, CMN_UTIL_String.CR + CMN_UTIL_String.LF);
		queueItem.CMN_URL__c = callResult.url;
		queueItem.CMN_MockedResponse__c = callResult.mocking == null ? false : callResult.mocking;

		//Only set this once, as we may be called to set queue item again during error handling and don't want to skew results
		if(queueItem.CMN_RequestTimeTaken__c == null)
		{
			queueItem.CMN_RequestTimeTaken__c = stopWatch.getTime();
		}
	}

	/**
	 * @description Define which objects are valid for data manipulation
	 */
	protected virtual void setUnitOfWorksObjectTypes()
	{
		addSObjectTypes(new List<Schema.SObjectType>
		{
				CMN_WebserviceCallQueue__c.SObjectType
		});
	}

	/**
	 * @description Override this in descendant classes if you want stack track to be added to error list if exception is being handled
	 *
	 * @return A boolean; true will add stack track to exceptions
	 */
	protected virtual Boolean addStackTraceToExceptions()
	{
		return false;
	}

	/**
	 * @description Method will check custom settings to determine if the API has been disabled for the current user
	 *
	 * @return True if disabled
	 */
	protected Boolean isDisabled()
	{
		CMN_FeatureSwitches__c featureSwitches = CMN_DAL_FeatureSwitches.getFeatureSwitch(null);

		String disabledAPIs = featureSwitches.CMN_APIsToDisableList1__c + featureSwitches.CMN_APIsToDisableList2__c + featureSwitches.CMN_APIsToDisableList3__c;

		return featureSwitches.CMN_DisableAllOutboundAPICalls__c || (String.isNotBlank(disabledAPIs) && disabledAPIs.containsIgnoreCase(getServiceName()));
	}

	/**
	 * @description Method will check custom settings to determine if the API is returning mock responses for the current user
	 *
	 * @return True if mocking
	 */
	protected Boolean isMocking()
	{
		CMN_FeatureSwitches__c featureSwitches = CMN_DAL_FeatureSwitches.getFeatureSwitch(null);

		String mockingAPIs = featureSwitches.CMN_APIsToMockList1__c + featureSwitches.CMN_APIsToMockList2__c + featureSwitches.CMN_APIsToMockList3__c;

		return featureSwitches.CMN_MockAllOutboundAPICalls__c || (String.isNotBlank(mockingAPIs) && mockingAPIs.containsIgnoreCase(getServiceName()));
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected virtual Boolean abortRequest()
	{
		Boolean abort = isDisabled();

		if(abort)
		{
			callResult.errors.add(ERROR_API_DISABLED);
		}

		return abort;
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected virtual Boolean canProcessRequest()
	{
		return !abortRequest();
	}

	/**
	 * @description Retrieves current Service Name, must be override by descendant classes
	 *
	 * @return The class name of the current service
	 */
	protected virtual String getServiceName()
	{
		return CMN_API_HttpBase.class.getName();
	}

	/**
	 * @description Used to process any errors that occurred
	 *
	 * @param error The exception that should be handled
	 */
	public virtual void handleError(Exception error)
	{
		if(error instanceof DmlException)
		{
			DmlException dmlException = (DmlException)error;
			for(Integer i = 0; i < dmlException.getNumDml(); i++)
			{
				callResult.errors.add(dmlException.getDmlMessage(i));
			}
		}
		else
		{
			callResult.errors.add(error.getMessage());
		}

		if(addStackTraceToExceptions())
		{
			callResult.errors.add(error.getStackTraceString());
		}

		callResult.failed = true;
	}

	/**
	 * @description the main processing loop for the webservice handler, must be implemented
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */
	public virtual void process(CMN_WebserviceCallQueue__c queueItem)
	{
		setQueueItem(queueItem);
	}
}