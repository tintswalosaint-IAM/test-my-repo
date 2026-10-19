/**
 * @description Class used by flow to filter the response of the getAccounts API
 *
 * @author Accenture
 *
 * @date 2021 April
 */
@SuppressWarnings('PMD.ExcessivePublicCount') // public attributes required for DTO payload as Apex-defined data type in flow
public inherited sharing class SVC_FLOW_GetVehicleAccountDetails
{
	private static final String STATUS_FILED = 'Filed';
	private static final String STATUS_DISPATCHED = 'Dispatched';
	private static final String RETURN_YES = 'Yes';
	private static final String RETURN_NO = 'No';

	private static final Integer LENGTH_OF_ACCOUNT_NUMBER = 12;

	/**
	 * @description Will invoke the getAccount API synchronously and filter it by the product type (if provided)
	 *
	 * @param dtoRequests A list of requests
	 *
	 * @return A list of Account
	 *
	 * @see SVC_API_GetAccounts
	 * @see SVC_API_GetVehicleDocumentation
	 */
	@InvocableMethod(Callout=true Label='Get Filtered Vehicle Details' Description='This Method will invoke the getAccount API, filter the results and then perform a callout to retrieve the vehicle details for each account.')
	public static List<DTO_Response> getFilteredVehicleDetails(List<DTO_Request> dtoRequests)
	{
		List<DTO_Response> dtoResponses = new List<DTO_Response>();

		List<CMN_API_HttpBase> allHandlers = new List<CMN_API_HttpBase>();

		for(DTO_Request dtoRequest : dtoRequests)
		{
			DTO_Response dtoResponse = new DTO_Response();
			dtoResponses.add(dtoResponse);

			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue
					(
							SVC_API_GetAccounts.SERVICE_NAME,
							dtoRequest.contactId,
							SVC_API_GetAccounts.PARAMETER_FILTER,
							dtoRequest.sourceSystemId
					);

			SVC_API_GetAccounts.runAsEmbedded = true;

			SVC_API_GetAccounts accountHandler = (SVC_API_GetAccounts)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

			CMN_DAL_WebserviceCallQueue.ServiceCallResult accountCallResult = accountHandler.callResult;

			dtoResponse.success = accountCallResult.completed;
			dtoResponse.queueItemId = queueItem.Id;

			if(accountCallResult.completed)
			{
				allHandlers.add(accountHandler);

				SVC_API_GetAccounts.DTO_Response dtoAccountResponse = (SVC_API_GetAccounts.DTO_Response)accountHandler.baseResponseDTO;

				CMN_API_HttpBaseOutbound.DTO_BaseTable dtoTable = new CMN_API_HttpBaseOutbound.DTO_BaseTable();

				// Columns from the getAccounts API
				dtoTable.addColumn('Account Number', 'accountNumber', 'text');
				dtoTable.addColumn('Account Status', 'accountStatusName', 'text');

				/*
				 * Columns commented out pending clarification of requirements
				 */
				dtoTable.addColumn('Copy Of Natis Available', 'copyOfNatisAvailable', 'text');
				dtoTable.addColumn('Model', 'model', 'text');
				dtoTable.addColumn('Vehicle Description', 'description', 'text'); // Description
				dtoTable.addColumn('Engine Number', 'engineNumber', 'text');
				dtoTable.addColumn('Chassis Number / VIN Number', 'vin', 'text'); // VIN
				dtoTable.addColumn('Date Account Opened', 'dateOpen', 'date');

				/*
				 * Columns commented out pending clarification of requirements
				 */
				
				for(SVC_API_GetAccounts.DTO_AccountProductDetails dtoAccount : dtoAccountResponse.customerAccountListDetails)
				{
					/* The account number is padded with zero's in the beginning, the Account number is to be trimmed to the right for 12 characters */
					String trimmedAccountNumber = dtoAccount.accountNumber.right(LENGTH_OF_ACCOUNT_NUMBER);

					SVC_API_GetVehicleDocumentation.runAsEmbedded = true;

					CMN_WebserviceCallQueue__c vehicleDocumentationQueueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue (SVC_API_GetVehicleDocumentation.SERVICE_NAME, null, SVC_API_GetVehicleDocumentation.PARAMETER_ACCOUNT_NUMBER, trimmedAccountNumber);

					SVC_API_GetVehicleDocumentation documentationHandler = (SVC_API_GetVehicleDocumentation)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {vehicleDocumentationQueueItem}).iterator().next();
					CMN_DAL_WebserviceCallQueue.ServiceCallResult documentationCallResult = documentationHandler.callResult;

					//Don't process the result if the call was failed
					if(documentationCallResult.completed)
					{
						allHandlers.add(documentationHandler);

						SVC_API_GetVehicleDocumentation.DTO_Response dtoVehicle = (SVC_API_GetVehicleDocumentation.DTO_Response)documentationHandler.baseResponseDTO;

						DTO_TransformedRow dtoRow = new DTO_TransformedRow();

						String documentStatus = CMN_UTIL_Boolean.toString(
								STATUS_FILED.equalsIgnoreCase(dtoVehicle.Success.certificateStatus) ||
										STATUS_DISPATCHED.equalsIgnoreCase(dtoVehicle.Success.certificateStatus
										), RETURN_YES, RETURN_NO);

						// Columns from the getAccounts API
						dtoRow.accountNumber = trimmedAccountNumber;
						dtoRow.accountStatusName = dtoAccount.accountStatusName;
						dtoRow.productName = dtoAccount.productName;
						dtoRow.productType = dtoAccount.productType;

						dtoRow.copyOfNatisAvailable = documentStatus;

						// Columns from getVehicleDocumentation
						dtoRow.certificateInFiling = dtoVehicle.Success.certificateInFiling;
						dtoRow.certificateStatus = dtoVehicle.Success.certificateStatus;
						dtoRow.certificateStatusDate = dtoVehicle.Success.certificateStatusDate;
						dtoRow.dateOfLiabilityForLicensing = dtoVehicle.Success.dateOfLiabilityForLicensing;
						dtoRow.dateOpen = dtoVehicle.Success.dateOpen;
						dtoRow.description = dtoVehicle.Success.description;
						dtoRow.documentIssueDate = CMN_UTIL_Date.iso8601StringToDate(dtoVehicle.Success.documentIssueDate);
						dtoRow.engineNumber = dtoVehicle.Success.engineNumber;
						dtoRow.make = dtoVehicle.Success.make;
						dtoRow.model = dtoVehicle.Success.model;
						dtoRow.natisRegisterNumber = dtoVehicle.Success.natisRegisterNumber;
						dtoRow.ownerIdNumber = dtoVehicle.Success.ownerIdNumber;
						dtoRow.ownerName = dtoVehicle.Success.ownerName;
						dtoRow.titleholderIdNumber = dtoVehicle.Success.titleholderIdNumber;
						dtoRow.titleholderName = dtoVehicle.Success.titleholderName;
						dtoRow.vin = dtoVehicle.Success.vin;

						dtoTable.addRow(dtoRow);
					}
					else
					{
						//Since we got an error, we must set the error response and stop looping accounts
						dtoResponse.payload = documentationCallResult.errors.isEmpty() ? documentationCallResult.responseBody : JSON.serializePretty(documentationCallResult.errors, true);
						break;
					}
				}

				dtoResponse.payload = dtoTable.serialize();
				dtoResponse.tableRowCount = dtoTable.rows.size();
			}
			else
			{
				dtoResponse.payload = accountCallResult.errors.isEmpty() ? accountCallResult.responseBody : JSON.serializePretty(accountCallResult.errors, true);
			}
		}

		SVC_API_GetAccounts.runAsEmbedded = false;
		SVC_API_GetVehicleDocumentation.runAsEmbedded = false;

		//Since we are managing the orchestration of the API handlers, we need to make sure that any changes they want to commit are made after all calls are made
		for(CMN_API_HttpBase handler : allHandlers)
		{
			handler.commitWork();
		}

		return dtoResponses;
	}

	/**
	 * @description DTO representing an account row that contains vehicle details
	 */
	@SuppressWarnings('PMD.TooManyFields') // Fields required as DTO is a request object
	private class DTO_TransformedRow
	{
		public String accountNumber;
		public String accountStatusName;
		public String productName;
		public String productType;
		public String certificateInFiling;
		public String certificateStatus;
		public Date certificateStatusDate;
		public Date dateOfLiabilityForLicensing;
		public Date dateOpen;
		public String description;
		public Date documentIssueDate;
		public String engineNumber;
		public String make;
		public String model;
		public String natisRegisterNumber;
		public String ownerIdNumber;
		public String ownerName;
		public String titleholderIdNumber;
		public String titleholderName;
		public String vin;

		/* This column is dynamically populated to show a Yes/No response based on the certificateFiled field */
		public String copyOfNatisAvailable;
	}

	/**
	 * @description Request variable indicating against which contact to retrieve vehicle account details
	 */
	public class DTO_Request
	{
		@InvocableVariable(Label='contactId' Description='The contact for which to retrieve accounts' Required=true)
		public String contactId;

		//This parameter is required to filter out not applicable rows as the API is used both for insurance and vehicle asset finance
		@InvocableVariable(Label='sourceSystemId' Description='The source system ID with which to filter the list of accounts' Required=false)
		public String sourceSystemId;
	}

	/**
	 * @description Response containing the response of the API calls, transformed into a table
	 */
	public class DTO_Response
	{
		@InvocableVariable(Label='Method Successful' Description='A boolean representation of the success or failure of the callouts')
		public Boolean success;

		@InvocableVariable(Label='Table JSON Response or Error Payload' Description='The container for the actual JSON payload containing the response of the callout or failure message if applicable')
		public String payload;

		@InvocableVariable(Label='QueueItem Id' Description='Id of the QueueItem for the callout')
		public String queueItemId;

		@InvocableVariable(Label='Table row count' Description='The number of transactional rows in the table')
		public Integer tableRowCount;
	}
}