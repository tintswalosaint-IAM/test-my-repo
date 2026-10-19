/**
 * @description       : SFP-58317 - API class used to upload files to file net
 * @author            : Amlendu Bajpai
 * @group             : 
 * @last modified on  : 09-05-2026
 * @last modified by  : Amlendu Bajpai
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   04-15-2024   Amlendu Bajpai   Initial Version
**/
public with sharing class SBFC_API_UploadToFileNet extends sbgplatform.ApiGatewayService {
    
    public static final String SERVICE_NAME = SBFC_API_UploadToFileNet.class.getName();
    public static Map<String, String> identifierByType; 
    public static String CHANNEL_ID ='SALESFORCE_SBFC_AO';
    public static Integer documentType;
    public static String contentStream; 
    public static String fileName;
    public static Id infoAuthReqId;
    public static Account account;
    private static final String PDF_MIME_TYPE='application/pdf';
    private static final String DISCLOSURE_DOCUMENT = 'Statutory Disclosure in Terms of FAIS';
    private static final String EVIDENCE_REPORT = 'Workflow Evidence Report';
     //API specific
	public static final String HTTP_AUTH_TOKEN_BEARER = 'Bearer ';
    public static final String POST_METHOD = 'POST';
    public static final String APPLICATION_X_WWW_FORM_URLENCODED = 'application/x-www-form-urlencoded';
    public static final String CONTENT_TYPE = 'Content-Type';
	public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
    private static final String NAMED_CREDENTIAL = 'CHNW_PPB_SBFC_ESBN';
	private static final String API_CREDENTIALS = 'CHNW_PPB_SBFC_ESBAC';
	private static final String PATH_CALLOUT = '/repository-service-cm/repository-service-cm/document';
    private static final String Token_CREDENTIALS = 'CHNW_PPB_SBFC_ESBTokenN';
	public static final String UNSUCCESSFUL_CALLOUT_ERROR = 'Something went wrong, please contact your administrator';
	public static final Integer HTTP_OK = 200;

    public static CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = new CMN_DAL_WebserviceCallQueue.ServiceCallResult();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_API_UploadToFileNet.class.getName());

    /**
    * @description Prepares an authenticated HTTP request by adding a Bearer access token.
    * @param path Endpoint path.
    * @param method HTTP method.
    * @param requestBody Request payload.
    * @param contentType Request content type.
    * @return Authenticated HttpRequest instance.
    */
    public override HttpRequest prepareHttpRequest (String path, String method, Object requestBody, String contentType){
        HttpRequest request = super.prepareHttpRequest(path,method,requestBody, contentType); 
        request.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_AUTH_TOKEN_BEARER + retrieveAccessToken());
        return request;
    }
    
    /**
     * @description Constructor for SBFC_API_UploadToFileNet.
     * Determines the Named Credential name and API Credentials name.
     */
    public SBFC_API_UploadToFileNet() {
        super(NAMED_CREDENTIAL,API_CREDENTIALS); 
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
    * @description Retrieves an OAuth access token using the client credentials grant type.
    *              The token is obtained from the configured Named Credential and is used
    *              to authenticate subsequent API requests.
    * @return Access token returned by the authorization service.
    */
    public static String retrieveAccessToken(){
        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:'+Token_CREDENTIALS);
        req.setMethod(POST_METHOD);

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
    * @description Initializes document-related attributes required for processing
    *              and uploading a document.
    * @param customerIdentifierByType Map containing customer identifiers keyed by identifier type.
    * @param docName Name of the document.
    * @param docType Type identifier of the document.
    * @param cStream Base64 encoded content stream of the document.
    */
    public void initialise(Map<String, String> customerIdentifierByType, String docName, Integer docType, String cStream) {
		identifierByType = customerIdentifierByType;
        documentType = docType;
        contentStream = cStream;	
        fileName = docName;	
        
	}

     /**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
    public String getRequestBody()  {
        SBFC_DTO_UploadToFileNet.DTO_Request request = new SBFC_DTO_UploadToFileNet.DTO_Request();

        request.channelID = CHANNEL_ID;
        request.sourceRequestId = AOB_Utils.generateGUID();

        request.documents = getDocument();
        return JSON.serialize(request, true);
    }
    /**
	 * @description Main process loop which controls the processing of outbound request and ensure result of call is logged
	 *
	 * @param queueItem The queueItem which will ultimately saved to record activity of webservice object
	 */
	public CMN_DAL_WebserviceCallQueue.ServiceCallResult process(CMN_WebserviceCallQueue__c queueItem,Account account,InfoAuthorizationRequest infoAuthReq)
	{		
		try{
            SBFC_API_UploadToFileNet.account = account;
            if(infoAuthReq!=NULL){
                infoAuthReqId = infoAuthReq.Id;
            }
			callResult.url = NAMED_CREDENTIAL+PATH_CALLOUT;
			
			SBFC_API_UploadToFileNet service = new SBFC_API_UploadToFileNet();
			//Make the service call
			String requestBody = getRequestBody();
			callResult.requestBody = requestBody;
			service.setExceptionOnError(false);
			String responseBody; 
			responseBody = (String) service.post(PATH_CALLOUT, requestBody);
			callResult.statusCode = String.valueOf(service.getStatusCode());
            callResult.status = CMN_DAL_WebserviceCallQueue.WebserviceStatus.COMPLETED;
			callResult.responseBody = responseBody;
			callResult.completed = true;

            registerDatabaseChanges();
		

		// Update the QueueItem
		setQueueItemDetails(queueItem);
			
		}catch (Exception ex) {
                LOGGER.error('SBFC_API_UploadToFileNet:Some Un-Handled Exception Occurred', new String[] {'SBFC_API_UploadToFileNet Outbound',JSON.serialize( ex.getMessage())});
				callResult.failed = true;
				callResult.completed = false;
				callResult.responseBody = ex.getMessage();
				callResult.errors = new List<String>{ex.getMessage()};
				callResult.status = CMN_DAL_WebserviceCallQueue.WebserviceStatus.FAILED;				
         }
		 

		return callResult;
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
		queueItem.CMN_MockedResponse__c = callResult.mocking == true;

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
	private static String abbreviate(String inputString, Integer maxLength)
	{
		return String.isNotBlank(inputString) && inputString.length() > maxLength ? CMN_UTIL_String.abbreviate(inputString, maxLength) : inputString;
	}

    /**
    * @description get document object for the request
    * @author Amlendu Bajpai | 04-06-2026
    * @return SBFC_DTO_UploadToFileNet.DTO_Documents 
    **/
    public static SBFC_DTO_UploadToFileNet.DTO_Documents getDocument() {
        SBFC_DTO_UploadToFileNet.DTO_Documents document = new SBFC_DTO_UploadToFileNet.DTO_Documents();

        document.contentStream = contentStream;
        document.mimeType = PDF_MIME_TYPE;
        document.fileName = fileName + '.pdf';
        document.documentTitle = fileName;

        document.createDocumentPropertyBo = getDocumentProperty();

        return document;
    }

    /**
    * @description used to manipulate and store data 
    * @author Amlendu Bajpai | 04-06-2026 
    **/
   public static void registerDatabaseChanges() {

    if (callResult == null ||!callResult.completed ||String.valueOf(HTTP_OK) != callResult.statusCode ||String.isBlank(callResult.responseBody)) {
        return;
    }

    SBFC_DTO_UploadToFileNet.DTO_Response response =(SBFC_DTO_UploadToFileNet.DTO_Response) JSON.deserialize(callResult.responseBody,SBFC_DTO_UploadToFileNet.DTO_Response.class);

    InfoAuthorizationRequest infoAuthRequest = populateInfoAuthReq(response);

    if (infoAuthRequest != null) {
        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
		uow.registerDirty(infoAuthRequest);
		uow.commitWork();
    }
}

    /**
   * @description used to manipulate and store data
   *
   * @param identificationByType identification by type mao
   * @param docName document inflight data
   *
   * @return InfoAuthorizationRequest
   *
   * @author Amlendu bajpai | 04-06-2026
   */
    @TestVisible
    private static InfoAuthorizationRequest populateInfoAuthReq(
        SBFC_DTO_UploadToFileNet.DTO_Response response
    ) {
        InfoAuthorizationRequest infoAuthReq;
        if(infoAuthReqId != null){
            infoAuthReq = new InfoAuthorizationRequest(Id = infoAuthReqId);
        }else{
            infoAuthReq = SBFC_Utils.createDisclosureInfoAuthorizationRequest(account);
        }

        if (DISCLOSURE_DOCUMENT.equals(fileName)) {
            infoAuthReq.SBFC_FileNet_Signed_Disclosure_GUID__c = response.documents.fnGuide;
        } else if (EVIDENCE_REPORT.equals(fileName)) {
            infoAuthReq.SBFC_FileNet_Evidence_Report_GUID__c = response.documents.fnGuide;
        }

        return infoAuthReq;
    }

    /**
    * @description get the DTO_CreateDocumentPropertyBo for the request 
    * @author Amlendu Bajpai | 04-06-2026
    * @return SBFC_DTO_UploadToFileNet.DTO_CreateDocumentPropertyBo 
    **/
    public static SBFC_DTO_UploadToFileNet.DTO_CreateDocumentPropertyBo getDocumentProperty() {
        SBFC_DTO_UploadToFileNet.DTO_CreateDocumentPropertyBo documentProperty = new SBFC_DTO_UploadToFileNet.DTO_CreateDocumentPropertyBo(); 
        documentProperty.customerProperty = (SBFC_DTO_UploadToFileNet.DTO_CustomerProperty) JSON.deserialize(JSON.serialize(identifierByType), SBFC_DTO_UploadToFileNet.DTO_CustomerProperty.class); 

        documentProperty.taxonomyProperty = new SBFC_DTO_UploadToFileNet.DTO_TaxonomyProperty();
        documentProperty.taxonomyProperty.documentType = documentType;

        return documentProperty;
    }
    
    /**
	 * @description DTO class for http response
	 */
    public class DTO_Response extends CMN_DTO_JsonBase  {
		
        public SBFC_DTO_UploadToFileNet.DTO_Response response;        

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		public override Type getObjectType() {
			return DTO_Response.class;
		}
	}


}