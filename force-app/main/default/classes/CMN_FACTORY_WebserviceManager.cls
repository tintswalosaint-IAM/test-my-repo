/**
 * @description Factory class to handle all trigger functions (uses underlying bulk functions)
 *               Used to instantiate and execute Trigger Handlers associated with SObjects.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ExcessiveParameterList')
public inherited sharing class CMN_FACTORY_WebserviceManager
{
	private static final String ERROR_NO_REGISTERED_SERVICE = 'No Webservice Handler registered for Name: {0}';
	private static final String ERROR_INVALID_TYPE = 'Invalid Object Type Registered for Name: {0}';

	private class WebserviceFactoryException extends Exception
	{
	}

	/**
	 * @description This method is use to process the Inbound service
	 *
	 * @param serviceName the web service class name
	 */
	public static void processInboundService(String serviceName)
	{
		execute(new List<CMN_WebserviceCallQueue__c>
		{
				CMN_DAL_DataFactory.newInboundWebserviceQueue(serviceName)
		});
	}

	/**
	 * @description Will return an API handler based on their class name
	 *
	 * @param handlerName The class name of the handler
	 *
	 * @return an Instance of an handler
	 */
	public static CMN_API_HttpBase getHandler(String handlerName)
	{
		System.Type handlerType = Type.forName(handlerName);

		if(handlerType == null)
		{
			throw new WebserviceFactoryException(String.format(ERROR_NO_REGISTERED_SERVICE, new List<String>
			{
					handlerName
			}));
		}
		else
		{
			Object handler = handlerType.newInstance();
			if(handler instanceof CMN_API_HttpBase)
			{
				return (CMN_API_HttpBase)handler;
			}
			else
			{
				throw new WebserviceFactoryException(String.format(ERROR_INVALID_TYPE, new List<String>
				{
						handlerName
				}));
			}
		}
	}

	/**
	 * @description Common error handling for processing errors when executing API calls
	 *
	 * @param handler API Handler
	 * @param error The error encountered
	 * @param queueItemIds A list of queueItemId we shouldn't reset
	 * @param queueItemUnitOfWork Unit of Work for updating queue items
	 */
	private static void handleError(CMN_API_HttpBase handler, Exception error, Set<Id> queueItemIds, CMN_DAL_SObjectUnitOfWork queueItemUnitOfWork)
	{
		CMN_WebserviceCallQueue__c handlerQueueItem = handler.getQueueItem();
		CMN_UTIL_Logger.error(error, handlerQueueItem.CMN_Service__c);

		handler.handleError(error);

		//Make sure we update the QueueItem with the error encountered during the commit process
		handler.setQueueItemDetails();

		//Make sure that we do not retry due to DML error on commit
		if(!queueItemIds.contains(handlerQueueItem.Id))
		{
			handlerQueueItem.Id = null;
		} //If the commit above has failed; there is a chance the queueItem has an ID

		handlerQueueItem.CMN_NextRetry__c = null;
		handlerQueueItem.CMN_Retries__c = 0;

		queueItemUnitOfWork.registerChange(handlerQueueItem);
	}

	/**
	 * @description Method will ask each of the API handlers to execute API call requested, changes made by API and responses received will be committed here as well.
	 *
	 * @param queueItems as input
	 *
	 * @return A List of API Handlers that can be interrogated outside  of the factor
	 */
	public static List<CMN_API_HttpBase> execute(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		List<CMN_API_HttpBase> apiHandlers = new List<CMN_API_HttpBase>();
		List<CMN_API_HttpBase> handlerToCommit = new List<CMN_API_HttpBase>();
		Set<Id> queueItemIds = new Set<Id>();

		//Use this to manage updates to the queue items  in a separate transaction from the changes as a result of API calls
		//The reason for this is to ensure that we can record what happened on an API call even if the committing changes as a result of API call fails
		CMN_DAL_SObjectUnitOfWork queueItemUnitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>
		{
				CMN_WebserviceCallQueue__c.SObjectType
		});

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			CMN_WebserviceCallQueue__c clonedQueueItem = queueItem.clone(true, true, false, false);

			if(queueItem.Id != null)
			{
				queueItemIds.add(queueItem.Id);
			}

			CMN_API_HttpBase apiHandler;

			// Get the handler requested on queueItem, if the handler could not be found; make sure we log the  error
			try
			{
				apiHandler = getHandler(clonedQueueItem.CMN_Service__c);
				apiHandlers.add(apiHandler);
			}
			catch(Exception error)
			{
				CMN_UTIL_Logger.error(error, clonedQueueItem.CMN_Service__c);

				clonedQueueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_ABORTED;
				clonedQueueItem.CMN_Errors__c = error.getMessage();

				queueItemUnitOfWork.registerChange(clonedQueueItem);

				//Skip this queue item and move onto the next one
				continue;
			}

			try
			{
				apiHandler.process(clonedQueueItem);
				handlerToCommit.add(apiHandler);

			}
			catch(Exception error)
			{
				handleError(apiHandler, error, queueItemIds, queueItemUnitOfWork);
			}
		}

		//Commits MUST happen after the callouts are completed, hence the second LOOP
		for(CMN_API_HttpBase apiHandler : handlerToCommit)
		{
			try
			{
				apiHandler.commitWork();
			}
			catch(Exception error)
			{
				handleError(apiHandler, error, queueItemIds, queueItemUnitOfWork);
			}
		}

		//Commit all changes in status etc to unit of work unsuccessful calls.
		queueItemUnitOfWork.commitWork();

		return apiHandlers;
	}

	/**
	 * @description Will invoke webservice calls synchronously from lightning flow or process builder
	 *
	 * @param dtoRequests The webservices to execute
	 *
	 * @return Will return the results of the call; the results will take the form of a table
	 */
	@InvocableMethod(Callout=true Label='Invoke Callout Synchronously' Description='This method can be called to an invoke a webservice call Synchronously')
	public static List<DTO_Response> invokeWebserviceCallSynchronously(List<DTO_Request> dtoRequests)
	{
		List<DTO_Response> dtoResponses = new List<DTO_Response>();

		List<CMN_API_HttpBase> handlers = invokeWebserviceCallSynchronouslyWithHandlers(dtoRequests);

		for(Integer i = 0; i < handlers.size(); i++)
		{
			DTO_Response dtoResponse = new DTO_Response();
			dtoResponses.add(dtoResponse);
			try
			{
				CMN_API_HttpBaseOutbound outboundHandler = (CMN_API_HttpBaseOutbound)handlers[i];
				CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = outboundHandler.callResult;

				dtoResponse.success = callResult.completed;
				dtoResponse.queueItemId = outboundHandler.getQueueItem().Id;

				if(!dtoResponse.success)
				{
					dtoResponse.payload = callResult.errors.isEmpty() ? callResult.responseBody : JSON.serializePretty(callResult.errors, true);
				}
				else if(dtoRequests[i]?.transformToTable != null && dtoRequests[i].transformToTable)
				{
					CMN_API_HttpBaseOutbound.DTO_BaseTable responseAsTable = outboundHandler.getResponseAsTable();
					dtoResponse.payload = responseAsTable.serialize();
					dtoResponse.tableRowCount = responseAsTable.rows.size();
				}
				else if(String.isNotBlank(dtoRequests[i]?.transformClassName))
				{

					dtoResponse.payload = outboundHandler.transformResponse(dtoRequests[i]?.transformClassName).serialize();
				}
				else
				{
					dtoResponse.payload = callResult.responseBody;
				}

				//Extract top level element from the response if required and no error has been encountered
				if(dtoResponse.success && String.isNotBlank(dtoRequests[i].elementName))
				{
					Map<String, Object> attributeMap = (Map<String, Object>)JSON.deserializeUntyped(dtoResponse.payload);
					dtoResponse.elementValue = String.valueOf(attributeMap.get(dtoRequests[i].elementName));
				}
			}
			catch(Exception error)
			{
				dtoResponse.payload = error.getMessage();
				dtoResponse.success = false;

				CMN_UTIL_Logger.error(error, 'CMN_FACTORY_WebserviceManager/invokeWebserviceCallSynchronously');
			}
		}

		return dtoResponses;
	}

	/**
	 * @description Will invoke webservice calls synchronously from lightning flow or process builder
	 *
	 * @param dtoRequests The webservices to execute
	 *
	 * @return Will return all the handlers that were executing requests
	 */
	private static List<CMN_API_HttpBase> invokeWebserviceCallSynchronouslyWithHandlers(List<DTO_Request> dtoRequests)
	{
		List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();

		for(DTO_Request dtoRequest : dtoRequests)
		{
			Map<String, String> parameterMap = new Map<String, String>();

			//Expecting a string that looks as follows "paramName=paramValue,paramName2=paramValue2"
			List<String> parameterList = CMN_UTIL_System.convertStringToList(dtoRequest.parameters, ',');

			for(String parameter : parameterList)
			{
				List<String> singleParameterList = CMN_UTIL_System.convertStringToList(parameter, '=');

				if(singleParameterList.size() == 2)
				{
					parameterMap.put(CMN_UTIL_String.trim(singleParameterList[0]), CMN_UTIL_String.trim(singleParameterList[1]));
				}
				else
				{
					CMN_UTIL_Logger.warn('Invalid Parameter "' + parameter + '" provided', 'CMN_FACTORY_WebserviceManager/invokeWebserviceCallSynchronouslyWithHandlers');
				}
			}

			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(dtoRequest.webServiceClassName, CMN_UTIL_String.validateId(dtoRequest.triggerObjectId), parameterMap);
			queueItems.add(queueItem);
		}

		return execute(queueItems);
	}

	/**
	 * @description Request variable representing the webservice call to execute
	 */
	public class DTO_Request
	{
		@InvocableVariable(Label='Web Service Class Name' Required=true)
		public String webServiceClassName;
		@InvocableVariable(Label='Trigger Object Id' Required=false)
		public String triggerObjectId;
		@InvocableVariable(Label='Parameters' Description='A list of parameters; must take the form paramName=paramValue,paramName2=paramValue2' Required=false)
		public String parameters;
		@InvocableVariable(Label='Transform response into a Table format' Description='If set, then the response will be transformed to a table structure' Required=false)
		public Boolean transformToTable;
		@InvocableVariable(Label='Class Name to Transform response into another format (Descendant of CMN_DTO_Json)' Description='Will use the type to transform class, must be of type CMN_DTO_Json' Required=false)
		public String transformClassName;
		@InvocableVariable(Label='Extract Element Name' Description='Element to extract from the JSON response' Required=false)
		public String elementName;
	}

	/**
	 * @description Response variable representing the webservice response or errors and a success indicator
	 */
	public class DTO_Response
	{
		@InvocableVariable(Label='API Response Success Indicator' Description='A boolean representation of the success or failure of the callout')
		public Boolean success;
		@InvocableVariable(Label='API Response or Error Payload' Description='The container for the actual JSON payload containing the response of the callout or failure message if applicable')
		public String payload;
		@InvocableVariable(Label='QueueItem Id' Description='Id of the QueueItem for the callout')
		public String queueItemId;
		@InvocableVariable(Label='Table row count' Description='The number of transactional rows in the table')
		public Integer tableRowCount;
		@InvocableVariable(Label='Extracted Element Value' Description='The extracted element from the JSON response')
		public String elementValue;
	}
}