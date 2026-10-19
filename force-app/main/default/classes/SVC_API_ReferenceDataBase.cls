/**
 * @description API and DTO to facilitate retrieval of Reference Data
 *
 * @author Accenture
 *
 * @date January 2021
 */
public virtual inherited sharing class SVC_API_ReferenceDataBase extends SVC_API_InsuranceBase
{
	/**
	 * @description Required parameter to be passed to the handler else call will be aborted
	 */
	@TestVisible
	private static final String PARAMETER_TABLE_NAME = 'tableName';
	private static final String PARAMETER_PAGE = 'page';
	private static final String PARAMETER_PAGE_SIZE = 'pageSize';

	/**
	 * @description Set this to not set the tableName parameter (which would be returned from getTableName() on descendant classes
	 */
	@TestVisible
	private static Boolean induceAbort = false;

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override virtual void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_BaseReferenceDataRequest();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Indicates whether a triggering object Id is required for the API
	 *
	 * @return A boolean indicating whether trigger object is required or not
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();

		parameters.addAll
				(
						new Set<String>
						{
								PARAMETER_TABLE_NAME
						}
				);

		return parameters;
	}

	/**
	 * @description Will insert the relevant table name into the request; to be implemented by descendant classes
	 *
	 * @return tableName to query
	 */
	protected virtual String getTableName()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Return the policy number for the policy current being processed
	 *
	 * @return Policy number
	 */
	protected override String getPolicyNumber()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Adds additional behaviour when item is set; in this case it will attempt to set the table parameter
	 *
	 * @param queueItem The queue item used by the service calls to initiate an outbound calls
	 */
	protected override virtual void setQueueItem(CMN_WebserviceCallQueue__c queueItem)
	{
		super.setQueueItem(queueItem);

		if(String.isNotBlank(getTableName()) && !induceAbort)
		{
			requestParameters.add(PARAMETER_TABLE_NAME, getTableName());
		}
	}

	/**
	 * @description Base Data Table type for reference data, has functionality to transpose result into something consumable in child classes
	 */
	public virtual class DTO_BaseReferenceDataTable extends CMN_API_HttpBaseOutbound.DTO_BaseTable
	{
		protected List<Map<String, String>> rowList = new List<Map<String, String>>();

		/**
		 * @description Will take the reference data response (which is in a table structure) and transform it so it
		 * can be transformed to the data table structure in child classes
		 *
		 * @param dtoResponse The webservice get reference data request response type
		 */
		private void transposeResponse(DTO_Response dtoResponse)
		{
			for(DTO_Row dtoRow : dtoResponse.rows)
			{
				Map<String, String> rowMap = new Map<String, String>();
				rowList.add(rowMap);

				if(dtoRow.active != null && dtoRow.active)
				{
					for(DTO_Column dtoColumn : dtoRow.columns)
					{
						rowMap.put(dtoColumn.column, dtoColumn.value);
					}
				}
			}
		}

		/**
		 * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
		 *
		 * @param dtoBase Input dto for transformation
		 */
		public override virtual void transform(CMN_DTO_Base dtoBase)
		{
			super.transform(dtoBase);

			//Transpose response so it's easy to convert into a data table response
			transposeResponse((DTO_Response)dtoBase);
		}
	}

	/**
	 * @description The Request DTO to be sent for retrieve Cards
	 */
	public virtual class DTO_BaseReferenceDataRequest extends CMN_DTO_JsonBase
	{
		public List<String> columns;
		public Integer page;
		public Integer pageSize;
		public String preferredSource;
		public String tableName;
		public List<DTO_Filter> queryColumns;

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override virtual void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			//We know this has to be provided so we don't have to check if it's null
			tableName = dtoRequestParameters.getFirst(PARAMETER_TABLE_NAME);

			String param = dtoRequestParameters.getFirst(PARAMETER_PAGE);
			page = String.isBlank(param) ? null : Integer.valueOf(param);

			param = dtoRequestParameters.getFirst(PARAMETER_PAGE_SIZE);
			pageSize = String.isBlank(param) ? null : Integer.valueOf(param);
		}
	}

	/**
	 * @description Use this to filter the results of reference data
	 */
	public class DTO_Filter
	{
		public String columnName;
		public String operation;
		public List<String> values;
	}

	/**
	 * @description DTO Structure to format the callout response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public Decimal total;
		public Integer currentPage;
		public Integer pageSize;
		public List<DTO_Row> rows;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	private class DTO_Row
	{
		public List<DTO_Column> columns;
		public Boolean active; //Assuming that if this row is false that the row should not be included during table transformation
	}

	private class DTO_Column
	{
		public String column;
		public String value;
	}
}