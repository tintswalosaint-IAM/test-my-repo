/**
 * @description Class for API call get Branches
 * <p/>
 * <p></p>
 *
 * @author Maryem BOURHI(mbourhi @salesforce.com)
 *
 * @date Dec 4th 2020
 */
public class AOB_API_GetBranches extends AOB_API_RestBaseOutbound
{
	public static final String SERVICE_NAME = AOB_API_GetBranches.class.getName();

	/**
	 * @description constructor used to make sure a token will be provided to authenticate to the API call
	 *
	 * @param token
	 */
	public AOB_API_GetBranches(string token)
	{
		accessToken = token;
	}

	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_GetBranchesMock();
	}

	/**
	 * @description method used to initialise the api call
	 */
	protected override void initialise()
	{
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
		}
	}

	/**
	 * @description method used to set API call Method
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description method used to indicate that there is no need for a triggering object
	 *
	 * @return
	 */
	@testVisible
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}

	@TestVisible
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public ETdata8_Detail_Record ETdata8_Detail_Record;
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

	public static DTO_Response parse(String json)
	{
		return (DTO_Response)System.JSON.deserialize(json, DTO_Response.class);
	}

	public class ETdata8_Detail_Record
	{
		public Integer ETdata8_Number_Of_Occurences;
		public List<ETdata8_Multi> ETdata8_Multi;
	}
	public class ETdata8_Multi
	{
		public String ETdata8_Code;
		public String ETdata8_Description;
	}

	public class AOB_API_GetBranchesMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String VALID_RESPONSE = '{"ETdata8_Detail_Record":{"ETdata8_Number_Of_Occurences":707,"ETdata8_Multi":[{"ETdata8_Code":"223","ETdata8_Description":"LIBRARY GARDENS"},{"ETdata8_Code":"250","ETdata8_Description":"MIDRAND"},{"ETdata8_Code":"276","ETdata8_Description":"WOODMEAD"}]}}';

		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}