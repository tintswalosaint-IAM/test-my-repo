/**
 * @description This class is used as an API class for the Get Document API
 * <p/>
 * <p>DBP-2296</p>
 *
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 *
 * @date Feb 8th 2021
 */
public class DOC_API_GetDocument extends AOB_API_RestBaseOutbound
{
	public static final String SERVICE_NAME = DOC_API_GetDocument.class.getName();
	public String documentGUID;
	public String bpId;

	/**
	 * @description constructor to make sure a token is passed before making the API call
	 *
	 * @param token ping token
	 * @param documentId filenet document Id
	 */
	public DOC_API_GetDocument(String token, String documentId)
	{
		List<DOC_Document__c> docs =
		[
				SELECT DOC_DocumentGUID__c,
						DOC_Customer_BPID__c
				FROM DOC_Document__c
				WHERE Id = :documentId
		];
		this.accessToken = token;
		if(!docs.isEmpty())
		{
			this.documentGUID = docs[0].DOC_DocumentGUID__c;
			this.bpId = docs[0].DOC_Customer_BPID__c;
		}
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description Used to parse response
	 */
	protected virtual override void parseResponse()
	{
		String responseBody = getResponseBody();
		DOC_API_GetDocument_DTO docAPIGetDocumentDTO = DOC_API_GetDocument_DTO.parse(responseBody);
		responseBody = docAPIGetDocumentDTO?.data?.data?.getDocumentDetailsOutput?.contentStream?.content;
		String fileName = docAPIGetDocumentDTO?.data?.data?.getDocumentDetailsOutput?.contentStream?.fileName;
		String mimeType = docAPIGetDocumentDTO?.data?.data?.getDocumentDetailsOutput?.contentStream?.mimeType;
		if(CMN_UTIL_String.isNotBlank(responseBody))
		{
			Blob tempBlob = Blob.valueOf(responseBody);
			DTO_Response resp = new DTO_Response(tempBlob, fileName, mimeType);
			baseResponseDTO = (CMN_DTO_JsonBase)resp;
		}
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return
	 */
	@testVisible
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected override String getServiceName()
	{
		super.getServiceName(); /* NB: Running this to cover base code method. */
		return SERVICE_NAME;
	}

	/**
	 * @description Calls the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new DOC_API_GetDocumentMock();
	}

	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
		}
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();
		populateRequestDTO();

		return JSON.serialize(new DTO_Body(new DTO_DocumentDetailsInput(this.documentGUID, this.bpId)));
	}

	/**
	 * @description DTO class to parse API response
	 */
	private class DTO_Body
	{
		public DTO_DocumentDetailsInput getDocumentDetailsInput;

		public DTO_Body(DTO_DocumentDetailsInput getDocumentDetailsInput)
		{
			this.getDocumentDetailsInput = getDocumentDetailsInput;
		}
	}

	/**
	 * @description DTO class to parse API response
	 */
	private class DTO_DocumentDetailsInput
	{
		public String documentGUID;
		public String bpId;
		public DTO_DocumentDetailsInput(String documentId, String customerBPId)
		{
			this.documentGUID = documentId;
			this.bpId = customerBPId;
		}
	}

	/**
	 * @description class to populate response DTO
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		@auraEnabled
		public String file;
		@auraEnabled
		public String fileName;
		@auraEnabled
		public String fileType;
		@auraEnabled
		public Blob response;

		public DTO_Response(Blob file, String fileName, String fileType)
		{
			this.file = EncodingUtil.base64Encode(file);
			this.fileName = fileName;
			this.fileType = fileType;
		}
		public DTO_Response()
		{
		}

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

	/**
	 * @description Used to get response Body
	 *
	 * @return
	 */
	public override string getResponseBody()
	{
		return response.getBody();
	}

	/**
	 * @description class to mock api response for test classes
	 */
	public class DOC_API_GetDocumentMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"success":""}';

		/**
		 * @description method to mock api response
		 *
		 * @param request httprequest
		 * @param response httpresponse
		 */
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}

}