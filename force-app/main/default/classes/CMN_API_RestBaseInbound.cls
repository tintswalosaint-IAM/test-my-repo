/**
 * @description This is Base calls for all Inbound  REST API calls
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual inherited sharing class CMN_API_RestBaseInbound extends CMN_API_HttpBaseInbound
{
	/**
	 * @description The DTO which will be populated from the inbound requestBody
	 */
	protected CMN_DTO_JsonBase baseRequestDTO;
	/**
	 * @description The DTO which will be serialised to populate the responseBody
	 */
	protected CMN_DTO_JsonBase baseResponseDTO;

	/**
	 * @description Initialise additional object members relating to parsing request and serializing response
	 */
	protected virtual override void initialise()
	{
		super.initialise();

		baseRequestDTO = new CMN_DTO_JsonBase();

		response.addHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
	}

	/**
	 * @description An override of base method which adds parsing of the inbound requestBody into baseRequestDTO
	 */
	protected virtual override void processRequest()
	{
		super.processRequest();

		String requestBody = requestBody;

		if(CMN_UTIL_String.isNotBlank(requestBody) && HTTP_ENCODING_JSON.equalsIgnoreCase(getEncoding()))
		{
			baseRequestDTO = (CMN_DTO_JsonBase)baseRequestDTO.deserialize(requestBody);
		}
	}

	/**
	 * @description method which is used to update the results of the call, such as status and responseBody
	 */
	protected override virtual void updateCallResult()
	{
		super.updateCallResult();
		callResult.responseBody = baseResponseDTO != null ? baseResponseDTO.serialize() : callResult.responseBody;
	}

	/**
	 * @description Any actions to take after a commit is completed
	 */
	public override void onCommitWorkFinishing()
	{
		//Ensure that if our response object needs committed data info, it can be updated here
		updateResponseDTO();

		super.onCommitWorkFinishing();
	}

	/**
	 * @description Override this method to update response DTO with relevant information
	 */
	protected virtual void updateResponseDTO()
	{

	}
}