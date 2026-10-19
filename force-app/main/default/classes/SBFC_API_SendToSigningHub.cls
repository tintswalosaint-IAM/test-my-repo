/**
 * @description       : SFP-54443 - API service class Handles the outbound SigningHub integration and updates the corresponding InfoAuthorizationRequest record.
 * @author            : Amlendu Bajpai
 * @group             : Standard Bank
 * @last modified on  : 30-06-2026
 * @last modified by  : Amlendu Bajpai
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   21-11-2025   Amlendu Bajpai   Initial Version
 * 2.0   30-06-2026   Amlendu Bajpai   Latest version
**/
public with sharing class SBFC_API_SendToSigningHub extends sbgplatform.ApiGatewayService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_API_SendToSigningHub.class.getName());

	private static Map<String, SBFC_DTO_DocumentManagement.DTO_ApplicationDocument> documentByDocumentCode = new Map<String, SBFC_DTO_DocumentManagement.DTO_ApplicationDocument>();
    public  static final String SERVICE_NAME = SBFC_API_SendToSigningHub.class.getName();
	private static List<SBFC_Internal_DTO_Signinghub.DTO_Signatory> signatories = new List<SBFC_Internal_DTO_Signinghub.DTO_Signatory>();
	public Account account;
	public static final String SBFC_SIGNING_HUB_CHANNEL_ID ='SALESFORCE_STAFF_ASSISTED_SBFC';
	public static final String DOCUMENT_TYPE ='1049';
	public InfoAuthorizationRequest infoAuthReq;
    public CMN_WebserviceCallQueue__c queueItem;
	/**
	 * @description Object to track the request, response and status of a web service call
	 */
	public static CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = new CMN_DAL_WebserviceCallQueue.ServiceCallResult();

	 //API specific
	public static final String HTTP_AUTH_TOKEN_BEARER = 'Bearer ';
	public static final String POST = 'POST';
	public static final String CALLOUT = 'callout:';
	public static final String CONTENT_TYPE = 'Content-Type';
	public static final String APPLICATION_X_WWW_FORM_URLENCODED = 'application/x-www-form-urlencoded';
	public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
    private static final String NAMED_CREDENTIAL = 'CHNW_PPB_SBFC_ESBN';
	private static final String API_CREDENTIALS = 'CHNW_PPB_SBFC_ESBAC';
	private static final String Token_CREDENTIALS = 'CHNW_PPB_SBFC_ESBTokenN';
	private static final String PATH_CALLOUT = '/signing-hub-service/packages';
	public static final String UNSUCCESSFUL_CALLOUT_ERROR = 'Something went wrong, please contact your administrator';
	public static final Integer HTTP_OK = 200;
    

	/**
     * @description Constructor for SBFC_API_SendToSigningHub.
     * Determines the Named Credential name.
     */
    public SBFC_API_SendToSigningHub() {
        super(NAMED_CREDENTIAL,API_CREDENTIALS); 
    }

	public override HttpRequest prepareHttpRequest (String path, String method, Object requestBody, String contentType){
        HttpRequest request = super.prepareHttpRequest(path,method,requestBody, ContentType);
		request.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_AUTH_TOKEN_BEARER + retrieveAccessToken());
        return request;
    }

	public static String retrieveAccessToken(){
        HttpRequest req = new HttpRequest();

        req.setEndpoint(CALLOUT+Token_CREDENTIALS);
        req.setMethod(POST);

        req.setHeader(CONTENT_TYPE, APPLICATION_X_WWW_FORM_URLENCODED);

        String body = 
            'grant_type=client_credentials' +
            '&client_id={!$Credential.CHNW_PPB_SBFC_ESBTokenE.client_id}' +
            '&client_secret={!$Credential.CHNW_PPB_SBFC_ESBTokenE.client_secret}';

        req.setBody(body);
        
        Http http = new Http();
        String accessToken;
        if(!Test.isRunningTest()){
			HttpResponse res = http.send(req);
			Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
			accessToken = (String) responseMap.get('access_token');
		}
		return accessToken;
    }


	/**
	 * @description A stop watch that can be used by external class to measure time taken by handler to process request
	 */
	public static CMN_UTIL_StopWatch stopWatch
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

	/**
	* @description Initializer
	* @param applicationDocuments
	* @param lead
	*/
	public void initialise(
    List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument> applicationDocuments,
    InfoAuthorizationRequest infoAuthReq,
    Account account
	)
	 {
		stopWatch.start();

		if (account == null) {
			throw new AuraHandledException('Account cannot be null.');
		}

		this.account = account;
		this.infoAuthReq = infoAuthReq;

		if (applicationDocuments != null) {
			for (SBFC_DTO_DocumentManagement.DTO_ApplicationDocument appDoc : applicationDocuments) {
				documentByDocumentCode.put(SBFC_Constants.DISCLOUSE, appDoc);
			}
		}

		SBFC_Internal_DTO_Signinghub.DTO_Signatory signatory = new SBFC_Internal_DTO_Signinghub.DTO_Signatory();

		signatory.bpId = account.CMN_CustomerBPID__pc;
		signatory.emailAddress = account.PersonEmail;
		signatory.name = account.Name;

		signatories.add(signatory);
	}

	/**
	 * @description Method generates the request body
	 *
	 * @return String request body json string
	 */
	public String getRequestBody() {

    String userEmail = UserInfo.getUserEmail();
    String username = String.isNotBlank(userEmail)
        ? userEmail.substringBefore('@')
        : UserInfo.getUserName();

    SBFC_DTO_Signinghub.DTO_Request request = new SBFC_DTO_Signinghub.DTO_Request();

    request.channelId = SBFC_SIGNING_HUB_CHANNEL_ID + '-' + username;
    request.shareDocument = true;

    SBFC_DTO_Signinghub.DTO_AddPackageRequest packageRequest = new SBFC_DTO_Signinghub.DTO_AddPackageRequest();

    packageRequest.packageName = SBFC_Constants.PACKAGE_NAME;
    packageRequest.workflowMode = SBFC_Constants.WORKFLOW_MODE;
    packageRequest.workflowType = SBFC_Constants.WORKFLOW_TYPE;

    request.addPackageRequest = packageRequest;
    request.addSignerToWorkflowRequest = getSignerWorkflowRequest();
    request.uploadDocumentRequests = getUploadDocumentRequest();

    return JSON.serialize(request, true);
}

	/**
	* @description get the directors that need to sign 
	* @author Amlendu bajpai | 01-12-2025 
	* @param addBankerAsSigner
	* @return SBFC_DTO_Signinghub.DTO_AddSignerToWorkflowRequest 
	**/
	private static SBFC_DTO_Signinghub.DTO_AddSignerToWorkflowRequest getSignerWorkflowRequest() {

    SBFC_DTO_Signinghub.DTO_AddSignerToWorkflowRequest request = new SBFC_DTO_Signinghub.DTO_AddSignerToWorkflowRequest();

    List<SBFC_DTO_Signinghub.DTO_SignerToWorkFlows> workflows = new List<SBFC_DTO_Signinghub.DTO_SignerToWorkFlows>();

    for (SBFC_Internal_DTO_Signinghub.DTO_Signatory signatory : signatories) {

        if (String.isBlank(signatory.emailAddress) || String.isBlank(signatory.name)) {
            LOGGER.error(SBFC_Constants.USER_EMAIL_MISSING,SBFC_Constants.AREA_STAFF,new String[] {SBFC_API_SendToSigningHub.class.getName(),SBFC_Constants.USER_EMAIL_MISSING}
            );
            throw new SBFC_SendToSendingHubException(SBFC_Constants.USER_EMAIL_MISSING);
        }

        SBFC_DTO_Signinghub.DTO_SignerToWorkFlows workflow = new SBFC_DTO_Signinghub.DTO_SignerToWorkFlows();

        workflow.emailNotification = 'true';
        workflow.role = SBFC_Constants.REVIEWER;
        workflow.username = signatory.name;
        workflow.userEmail = signatory.emailAddress;
        workflow.signingOrder = workflows.size() + 1;

        workflows.add(workflow);
    }

		request.signerToWorkFlows = workflows;

		return request;
}

    /**
    * @description populates the content streams 
    * @author Amlendu bajpai | 1-12-2025 
    * @return List<SBFC_DTO_Signinghub.DTO_UploadDocumentRequests>
    **/
    private List<SBFC_DTO_Signinghub.DTO_UploadDocumentRequests> getUploadDocumentRequest() {

    List<SBFC_DTO_Signinghub.DTO_UploadDocumentRequests> uploadDocuments = new List<SBFC_DTO_Signinghub.DTO_UploadDocumentRequests>();

    for (String documentCode : documentByDocumentCode.keySet()) {

        SBFC_DTO_DocumentManagement.DTO_ApplicationDocument applicationDocument = documentByDocumentCode.get(documentCode);

        SBFC_DTO_Signinghub.DTO_UploadDocumentRequests uploadDocument = new SBFC_DTO_Signinghub.DTO_UploadDocumentRequests();

        uploadDocument.fileName = documentCode + '.pdf';
        uploadDocument.convertDocument = 'false';
        uploadDocument.source = 'SALESFORCE';
        uploadDocument.contentStreams = applicationDocument.contentStream;
        uploadDocument.storeContext = true;

        SBFC_DTO_Signinghub.DTO_CustomerProperty customerProperty = new SBFC_DTO_Signinghub.DTO_CustomerProperty();

        customerProperty.bpid = this.account.CMN_CustomerBPID__pc;
        customerProperty.surnameOrCompanyName = this.account.FirstName;
        customerProperty.identityNumber = this.account.CMN_IdentityNumber__pc;

        SBFC_DTO_Signinghub.DTO_TaxonomyProperty taxonomyProperty = new SBFC_DTO_Signinghub.DTO_TaxonomyProperty();

        taxonomyProperty.documentType = DOCUMENT_TYPE;

        uploadDocument.documentPropertyBo = new SBFC_DTO_Signinghub.DTO_DocumentPropertyBo();

        uploadDocument.documentPropertyBo.customerProperty = customerProperty;
        uploadDocument.documentPropertyBo.taxonomyProperty = taxonomyProperty;

        uploadDocuments.add(uploadDocument);
    }

		return uploadDocuments;
}
	
	/**
	 * @description Will update the Queue Item with the final results of the call made
	 */
	public static void setQueueItemDetails(CMN_WebserviceCallQueue__c queueItem)
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
	 * @description Will shorten a response to the length given
	 *
	 * @param inputString The response
	 * @param maxLength The maximum length
	 *
	 * @return The abbreviated string
	 */
	public static String abbreviate(String inputString, Integer maxLength)
	{
		return String.isNotBlank(inputString) && inputString.length() > maxLength ? CMN_UTIL_String.abbreviate(inputString, maxLength) : inputString;
	}

	/**
	 * @description Main process loop which controls the processing of outbound request and ensure result of call is logged
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */
	public CMN_DAL_WebserviceCallQueue.ServiceCallResult process(CMN_WebserviceCallQueue__c queueItem) {

    callResult.url = NAMED_CREDENTIAL + PATH_CALLOUT;

    try {

        setExceptionOnError(false);

        String requestBody = getRequestBody();
        callResult.requestBody = requestBody;

        callResult.responseBody = (String) post(PATH_CALLOUT, requestBody);
        callResult.statusCode = String.valueOf(getStatusCode());
        callResult.completed = true;

        registerDatabaseChanges();

    } catch (Exception ex) {

        LOGGER.error('SBFC_API_SendToSigningHub: Unhandled Exception',new String[] {'SBFC_API_SendToSigningHub Outbound',infoAuthReq != null ? String.valueOf(infoAuthReq.Id) : '',ex.getMessage()},ex);

        callResult.failed = true;
        callResult.completed = false;
        callResult.status = CMN_DAL_WebserviceCallQueue.WebserviceStatus.FAILED;
        callResult.responseBody = ex.getMessage();
        callResult.errors = new List<String>{ ex.getMessage() };
    }

		setQueueItemDetails(queueItem);

		return callResult;
}

	/**
    * @description used to manipulate and store data 
    * @author Amlendu bajpai | 1-12-2025
    **/
    public void registerDatabaseChanges() {
        try{

    if (callResult.statusCode != String.valueOf(HTTP_OK)) {
        callResult.failed = true;
        callResult.completed = false;
        callResult.errors = new List<String>{ UNSUCCESSFUL_CALLOUT_ERROR };
        callResult.status = CMN_DAL_WebserviceCallQueue.WebserviceStatus.FAILED;
        return;
    }

    SBFC_DTO_Signinghub.DTO_Response response =
        (SBFC_DTO_Signinghub.DTO_Response)JSON.deserialize(
            callResult.responseBody,
            SBFC_DTO_Signinghub.DTO_Response.class
        );

    if (this.infoAuthReq == null) {
        this.infoAuthReq = SBFC_Utils.createDisclosureInfoAuthorizationRequest(this.account);
    }

    if (response != null &&
        response.uploadDocumentResponses != null &&
        !response.uploadDocumentResponses.isEmpty()) {

        this.infoAuthReq.SBFC_SigningHub_Document_Number__c = response.uploadDocumentResponses[0].documentId;
    }

		sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerDirty(this.infoAuthReq);
        uow.commitWork();
        }catch(exception ex){
            LOGGER.error('SBFC_API_SendToSigningHub: Unhandled Exception',new String[] {'SBFC_API_SendToSigningHub Outbound',infoAuthReq != null ? String.valueOf(infoAuthReq.Id) : '',ex.getMessage()},ex);
        }
}

	/**
    * @description DTO class for response
    * @author Amlendu bajpai | 1-12-2025
    **/
    public class DTO_Response extends CMN_DTO_JsonBase {
		public SBFC_Internal_DTO_Signinghub.DTO_Response response;
		
		/**
		* @description The Type of the DTO used when deserializing the class
		* @author Amlendu bajpai | 1-12-2025 
		* @return Type 
		**/
		protected override Type getObjectType() {
			return DTO_Response.class;
		}
	}

    

	public class SBFC_SendToSendingHubException extends Exception{}
	
}