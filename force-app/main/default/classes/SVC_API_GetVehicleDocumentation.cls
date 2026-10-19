/**
 * @description API to retrieve vehicle information
 *
 * @author Accenture
 *
 * @date September 2021
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.ExcessivePublicCount') // Required in non standard format for external API
public inherited sharing class SVC_API_GetVehicleDocumentation extends CMN_API_SoapBaseOutbound
{
	public static final String SERVICE_NAME = SVC_API_GetVehicleDocumentation.class.getName();
	private Case foundCase;

	public static final String PARAMETER_ACCOUNT_NUMBER = 'accountNumber';
	@TestVisible
	private final static String PARAMETER_SAVE_ATTACHMENT = 'saveAttachment';
	private static final String ERROR_CASE_NOT_FOUND = 'No Case found for the given triggering object id.';

	private final static String ROOT_NODE_NAMESPACE = 'http://www.ubiquitech.co.za/schemas/certrack-core/20101102';
	private final static String SOAP_METHOD_PREFIX = 'CopyOfNatis';

	/**
	 * @description Set this static variable so the class knows not to perform an commits as its being run embedded in another service class request
	 */
	public static Boolean runAsEmbedded = false;

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
		baseTableDTOType = DTO_Table.class;
	}

	/**
	 * @description Override of base commit method which will check to see if this service is running embedded in another service, if so it won't commit it's queue item
	 */
	public override void commitWork()
	{
		if(!runAsEmbedded)
		{
			super.commitWork();
		}
	}

	/**
	 * @description Does this API call require a triggering object id. Although this API does require a triggeringObjectId,
	 *    when running in embeddedMode it retrieves information from the API and excludes the attachment of the eNatis
	 *    documentation and would subsequently fail as in embedded mode the attachment is not required.
	 *
	 * @return False, no triggering object required.
	 *
	 * @see SVC_FLOW_GetVehicleAccountDetails
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Defines the default SOAP body namespace, used when extracting SOAPAction out of the body
	 *
	 * @return Namespace
	 *
	 * @see CMN_API_SoapBaseOutbound.getBody
	 */
	protected override String getSoapBodyNamespace()
	{
		return 'soap-env';
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

		parameters.add(PARAMETER_ACCOUNT_NUMBER);

		return parameters;
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected override virtual Boolean abortRequest()
	{
		Boolean mustAbort = super.abortRequest();

		if(!mustAbort)
		{
			foundCase = SVC_DAL_Case.findById(queueItem.CMN_TriggeringObjectId__c);

			if(foundCase == null && requestParameters.exists(PARAMETER_SAVE_ATTACHMENT))
			{
				callResult.errors.add(ERROR_CASE_NOT_FOUND);
				mustAbort = true;
			}
		}

		if(mustAbort)
		{
			callResult.responseBody = '{"error" : "' + callResult.errors[0] + '"}';
		}

		return mustAbort;
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();

		addSObjectTypes(new List<Schema.SObjectType> {ContentVersion.SObjectType});
	}

	/**
	 * @description Ensure that we add the certificate image to given case as a content document
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		// Sometimes, it is not required to save the attachment but only show the vehicle registration information
		Boolean mustSaveAttachment = CMN_UTIL_Boolean.stringToBoolean(requestParameters.getFirst(PARAMETER_SAVE_ATTACHMENT));

		if(mustSaveAttachment)
		{
			String documentContent = dtoResponse.Success?.CertificateImage?.documentContent;

			if(String.isNotBlank(documentContent))
			{
				String documentFilename = dtoResponse.Success.accountNumber + '_' + dtoResponse.Success.CertificateImage.originalFilename;
				registerChange(CMN_DAL_DataFactory.newContentVersion(foundCase.Id, documentFilename, EncodingUtil.base64Decode(documentContent)));
			}
		}
	}

	/**
	 * @description Name of your service to be used when looking up custom settings for you service
	 *
	 * @return the service name
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Returns the webservice response as a table
	 */
	private class DTO_Table extends CMN_API_HttpBaseOutbound.DTO_BaseTable
	{
		/**
		 * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
		 *
		 * @param dtoBase Input dto for transformation
		 */
		public override void transform(CMN_DTO_Base dtoBase)
		{
			super.transform(dtoBase);

			addColumn('Account Number', 'accountNumber', 'text');
			addColumn('In Filing', 'certificateInFiling', 'text');
			addColumn('Status', 'certificateStatus', 'text');
			addColumn('Status Date', 'certificateStatusDate', 'text');
			addColumn('Liability Date', 'dateOfLiabilityForLicensing', 'text');
			addColumn('Date Open', 'dateOpen', 'text');
			addColumn('Description', 'description', 'text');
			addColumn('Issue Date', 'documentIssueDate', 'text');
			addColumn('Engine Number', 'engineNumber', 'text');
			addColumn('Make', 'make', 'text');
			addColumn('Model', 'model', 'text');
			addColumn('Natis Number', 'natisRegisterNumber', 'text');
			addColumn('Owner Id Number', 'ownerIdNumber', 'text');
			addColumn('Owner Name', 'ownerName', 'text');
			addColumn('Title Holder Id', 'titleholderIdNumber', 'text');
			addColumn('Title Holder Name', 'titleholderName', 'text');
			addColumn('VIN', 'vin', 'text');

			DTO_Response dtoResponse = (DTO_Response)dtoBase;
			addRow(dtoResponse.Success);
		}
	}

	/**
	 * @description The request to to be sent for retrieve vehicle documentation
	 */
	private class DTO_Request extends CMN_DTO_XmlBase.DTO_XmlRootNode
	{
		public String accountNumber;
		public String requesterName;

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			accountNumber = dtoRequestParameters.getFirst(PARAMETER_ACCOUNT_NUMBER);
			requesterName = CMN_DAL_User.getCurrentUser().Name;
		}

		/**
		 * @description Register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			registerRootNode(SOAP_METHOD_PREFIX + 'Request', ROOT_NODE_NAMESPACE, CMN_API_SoapBaseOutbound.ROOT_NODE_PREFIX);

			accountNumber = registerStringNode('accountNumber', null, null, accountNumber);
			requesterName = registerStringNode('requesterName', null, null, requesterName);
		}
	}

	/**
	 * @description Override this method to register all text nodes and child nodes under current node.
	 */
	public class DTO_Response extends CMN_DTO_XmlBase.DTO_XmlRootNode
	{
		public DTO_Success Success = new DTO_Success();

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			registerRootNode(SOAP_METHOD_PREFIX + 'Response', ROOT_NODE_NAMESPACE, CMN_API_SoapBaseOutbound.ROOT_NODE_PREFIX);
			registerChild(Success, 'Success');
		}
	}

	/**
	 * @description The DTO representing the success node in the response
	 */
	public class DTO_Success extends CMN_DTO_XmlBase
	{
		public String accountNumber;
		public String certificateInFiling;
		public String certificateStatus;
		public Date certificateStatusDate;
		public Date dateOfLiabilityForLicensing;
		public Date dateOpen;
		public String description;
		public String documentIssueDate;
		public String engineNumber;
		public String make;
		public String model;
		public String natisRegisterNumber;
		public String ownerIdNumber;
		public String ownerName;
		public String titleholderIdNumber;
		public String titleholderName;
		public String vin;

		public DTO_CertificateImage CertificateImage = new DTO_CertificateImage();
		public DTO_NatisInformation NatisInformation = new DTO_NatisInformation();

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			accountNumber = registerStringAttribute('accountNumber', accountNumber);
			certificateInFiling = registerStringAttribute('certificateInFiling', certificateInFiling);
			certificateStatus = registerStringAttribute('certificateStatus', certificateStatus);
			certificateStatusDate = registerDateAttribute('certificateStatusDate', certificateStatusDate);
			dateOfLiabilityForLicensing = registerDateAttribute('dateOfLiabilityForLicensing', dateOfLiabilityForLicensing);
			dateOpen = registerDateAttribute('dateOpen', dateOpen);
			description = registerStringAttribute('description', description);
			documentIssueDate = registerStringAttribute('documentIssueDate', documentIssueDate);
			engineNumber = registerStringAttribute('engineNumber', engineNumber);
			make = registerStringAttribute('make', make);
			model = registerStringAttribute('model', model);
			natisRegisterNumber = registerStringAttribute('natisRegisterNumber', natisRegisterNumber);
			ownerIdNumber = registerStringAttribute('ownerIdNumber', ownerIdNumber);
			ownerName = registerStringAttribute('ownerName', ownerName);
			titleholderIdNumber = registerStringAttribute('titleholderIdNumber', titleholderIdNumber);
			titleholderName = registerStringAttribute('titleholderName', titleholderName);
			vin = registerStringAttribute('vin', vin);

			registerChild(CertificateImage, 'CertificateImage');
			registerChild(NatisInformation, 'NatisInformation');
		}
	}

	/**
	 * @description The DTO representing the success node in the response
	 */
	private class DTO_CertificateImage extends CMN_DTO_XmlBase
	{
		public String documentContent;
		public String mimeType;
		public String originalFilename;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			documentContent = registerStringAttribute('documentContent', documentContent);
			mimeType = registerStringAttribute('mimeType', mimeType);
			originalFilename = registerStringAttribute('originalFilename', originalFilename);
		}
	}

	/**
	 * @description The DTO representing the Natis information node in the response
	 */
	private class DTO_NatisInformation extends CMN_DTO_XmlBase
	{
		public Date licenceExpiryDate;
		public Datetime whenQueried;
		public DTO_CodeDescription vehicleState = new DTO_CodeDescription();
		public DTO_CodeDescription sapMark = new DTO_CodeDescription();

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			licenceExpiryDate = registerDateAttribute('licenceExpiryDate', licenceExpiryDate);
			whenQueried = registerDatetimeAttribute('originalFilename', whenQueried);
			registerChild(vehicleState, 'vehicleState');
			registerChild(sapMark, 'vehicleState');
		}
	}

	/**
	 * @description The DTO representing the code and description elements in the response
	 */

	private class DTO_CodeDescription extends CMN_DTO_XmlBase
	{
		public String code;
		public String description;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			code = registerStringAttribute('code', code);
			description = registerStringAttribute('description', description);
		}
	}

	/**
	 * @description Return the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetVehicleDocumentationMock();
	}

	/**
	 * @description Mock class for returning test data
	 */
	@TestVisible
	private class SVC_API_GetVehicleDocumentationMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><ns:CopyOfNatisResponse xmlns:ns="http://www.ubiquitech.co.za/schemas/certrack-core/20101102" xmlns:ns4="http://www.ubiquitech.co.za/schemas/lcms" xmlns:ns5="http://www.ubiquitech.co.za/schemas/certrack-ivid/" xmlns:ns6="http://jis.syntell.co.za/jis/notification" xmlns:ns7="http://jis.syntell.co.za/" xmlns:ns8="http://www.ubiquitech.co.za/schemas/doclink" xmlns:ns9="http://www.ubiquitech.co.za/schemas/ccentral/"><Success accountNumber="0000200327542000" certificateInFiling="true" certificateStatus="Filed" certificateStatusDate="2021-04-02" dateOfLiabilityForLicensing="1966-01-01" dateOpen="2021-01-13" description="SEDAN (CLOSED TOP) / SEDAN (TOE-KAP)" documentIssueDate="2021-02-04" engineNumber="18094520012010" make="MERCEDES-BENZ" model="ANDER / OTHER" natisRegisterNumber="SDJ090A" ownerIdNumber="ID_146213312" ownerName="NAME_4105004835" titleholderIdNumber="6200738061794" titleholderName="STANDARD BANK VEHICLE ASSET SERV" vin="11001160014773"><CertificateImage documentContent="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" mimeType="image/jpeg" originalFilename="someimagefilename.jpg"/><NatisInformation licenceExpiryDate="2022-01-31" whenQueried="2021-02-12T12:52:39.000"><vehicleState code="12" description="Licensed"/><sapMark code="99" description="None"/></NatisInformation></Success></ns:CopyOfNatisResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

}