/**
 * @description Provides Query methods related to CMN_WebserviceCallQueue__c object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_WebserviceCallQueue
{
	//Status Messages
	public static final String STATUS_ABORTED = 'Aborted';
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String STATUS_FAILED = 'Failed';
	public static final String STATUS_QUEUED = 'Queued';
	public static final String STATUS_RETRY = 'Retry';
	public static final String STATUS_BATCHED = 'Batched';

	public static final String TYPE_INBOUND = 'Inbound';
	public static final String TYPE_OUTBOUND = 'Outbound';

	public static final Integer REQUEST_LEN = Schema.SObjectType.CMN_WebserviceCallQueue__c.fields.CMN_Request__c.getLength();
	public static final Integer RESPONSE_LEN = Schema.SObjectType.CMN_WebserviceCallQueue__c.fields.CMN_Response__c.getLength();

	public static final String EMPTY_JSON_RESPONSE = '{ }';

	public enum WebserviceStatus
	{
		COMPLETED, FAILED, ABORTED
	}

	/**
	 * @description Object to track the request, response and status of a web service call
	 */
	public virtual class ServiceCallResult
	{
		public transient List<String> errors = new List<String>();
		public transient String requestBody;
		public transient String responseBody;
		public transient String statusCode;
		public transient String url;
		public transient WebserviceStatus status;
		public transient Boolean mocking;
		public transient String statusText
		{
			get
			{
				String serviceStatusText = String.valueOf(status);
				return CMN_UTIL_String.upperCase(serviceStatusText.substring(0, 1)) + CMN_UTIL_String.lowerCase(serviceStatusText.substring(1));
			}
		}
		public transient Boolean failed
		{
			get
			{
				return status == WebserviceStatus.FAILED;
			}
			set
			{
				status = WebserviceStatus.FAILED;
			}
		}
		public transient Boolean completed
		{
			get
			{
				return status == WebserviceStatus.COMPLETED;
			}
			set
			{
				status = WebserviceStatus.COMPLETED;
			}
		}
		public transient Boolean aborted
		{
			get
			{
				return status == WebserviceStatus.ABORTED;
			}
			set
			{
				status = WebserviceStatus.ABORTED;
			}
		}
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @param queueItem as input
	 * @param nextRetryTime as input
	 */
	public static void updateNextRetryInfo(CMN_WebserviceCallQueue__c queueItem, Datetime nextRetryTime)
	{
		queueItem.CMN_NextRetry__c = nextRetryTime;
		queueItem.CMN_Status__c = STATUS_RETRY;
		queueItem.CMN_Retries__c++;
	}

	/**
	 * @description This method is use to List of of webservice call queue by Service name.
	 *
	 * @param serviceName as input
	 *
	 * @return list of webservice queues by service name
	 */
	@TestVisible
	private static List<CMN_WebserviceCallQueue__c> findByServiceName(String serviceName)
	{
		return
		[
				SELECT
						CMN_Errors__c,
						CMN_NextRetry__c,
						CMN_RequestTimeTaken__c,
						CMN_Request_Parameters__c,
						CMN_Request__c,
						CMN_Response__c,
						CMN_Retries__c,
						CMN_Service__c,
						CMN_StatusCode__c,
						CMN_Status__c,
						CMN_TriggeringObjectId__c,
						CMN_TriggeringObjectUrl__c,
						CMN_Type__c,
						CMN_URL__c,
						CreatedById,
						CreatedDate,
						Id,
						Name
				FROM CMN_WebserviceCallQueue__c
				WHERE CMN_Service__c = :serviceName
		];
	}

	/**
	 * @description Used by API unit tests to confirm that Service calls were logged as expected
	 *
	 * @param serviceName The name of the API class
	 */
	@TestVisible
	private static void checkServiceCompleted(String serviceName)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(serviceName);

		System.assertNotEquals(true, queueItems.isEmpty(), 'No QueueItems found for Service: "' + serviceName + '"');

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			Boolean statusCorrect = CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED.equalsIgnoreCase(queueItem.CMN_Status__c);
			System.assert(statusCorrect, 'Service did not complete. Queue Item JSON: ' + JSON.serialize(queueItem));
			System.assertEquals(true, String.isNotBlank(queueItem.CMN_Response__c), 'QueueItem response not set');
			System.assertNotEquals(EMPTY_JSON_RESPONSE, queueItem.CMN_Response__c, 'Response Empty JSON');
		}
	}

	/**
	 * @description Will check to see that web service failed
	 *
	 * @param serviceName The name of the API class
	 * @param errorMessageMatch Check to see if correct phrase or word is in the error string
	 *
	 * @return The found Queue Items for the service name given, can be used to check other aspects of the queueItems
	 */
	@TestVisible
	private static List<CMN_WebserviceCallQueue__c> checkServiceFailedCorrectly(String serviceName, String errorMessageMatch)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(serviceName);

		System.assertNotEquals(true, queueItems.isEmpty(), 'No QueueItems found for Service: "' + serviceName + '"');

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			Boolean statusCorrect = CMN_DAL_WebserviceCallQueue.STATUS_FAILED.equalsIgnoreCase(queueItem.CMN_Status__c);
			System.assert(statusCorrect, 'Service did not fail. Queue Item JSON: ' + JSON.serialize(queueItem));
			System.assert(CMN_UTIL_String.contains(queueItem.CMN_Errors__c, errorMessageMatch), 'Error Message Incorrect');
		}

		return queueItems;
	}

	/**
	 * @description Retrieve a list of CMN_WebserviceCallQueue__c records by status value
	 *
	 * @return List<CMN_WebserviceCallQueue__c> - The list of filtered CMN_WebserviceCallQueue__c's
	 */
	public static List<CMN_WebserviceCallQueue__c> getByBatchedStatus()
	{
		return
		[
				SELECT
						CMN_Errors__c,
						CMN_NextRetry__c,
						CMN_RequestTimeTaken__c,
						CMN_Request_Parameters__c,
						CMN_Request__c,
						CMN_Response__c,
						CMN_Retries__c,
						CMN_Service__c,
						CMN_StatusCode__c,
						CMN_Status__c,
						CMN_TriggeringObjectId__c,
						CMN_TriggeringObjectUrl__c,
						CMN_Type__c,
						CMN_URL__c,
						CreatedById,
						CreatedDate,
						Id,
						Name
				FROM
						CMN_WebserviceCallQueue__c
				WHERE
				CMN_Status__c = :STATUS_BATCHED
				AND
				CMN_Type__c = :TYPE_OUTBOUND
				LIMIT :CMN_DAL_SObjectDomain.LIMIT_NUMBER_OF_RECORDS
		];
	}
}