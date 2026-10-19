/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :March 2022
@ Name of the Class :AOB_IdentityApplicant
@ Description       :Class for dealing with identity api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :10-09-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_IdentityApplicant {
    private AOB_IdentityApplicant(){}
	private static final String API_Key = '{!$Credential.UG_BCB_PBB_IDV_INTEGRATION_CREDENTIALS_EC.APIKey}';
	private static final String secret = '{!$Credential.UG_BCB_PBB_IDV_INTEGRATION_CREDENTIALS_EC.secret}';
	private static final String URL = '{!$Credential.UG_BCB_PBB_IDV_INTEGRATION_CREDENTIALS_EC.URL}';
	private static final String endPoint = 'callout:UG_BCB_PBB_IDV_INTEGRATION_CREDENTIALS';
	private static final String HTTP_METHOD_POST = 'POST';
	private static final String HTTP_METHOD_GET = 'GET';
	private static final String endpoint_AMX = 'callout:UG_BCB_PBB_IDV_AMX_INTEGRATION_CREDENTIALS';
	private static Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_IdentityApplicant');
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_IdentifiiApplicant');
    
	 /**
     * @description Fetches applicationlist 
	 * @param applicationIdList
     * @return String
     */
	public static String invokeIdv(List<String> applicationIdList)  {
        
        if(applicationIdList != null && !applicationIdList.isEmpty()) {
			List<Application__c> applicationList = new SEL_Application().selectAppsById(applicationIdList[0]);
			if(!applicationList.isEmpty() && (applicationList[0].AOB_Liveness_Matched__c == false || applicationList[0].AOB_Liveness_Matched__c == null)) {
				Map<String, Object> responseMap =  getTokenForIdentifiiCallout(applicationList[0]);
				if(responseMap != null && responseMap.containsKey('status') && responseMap.get('status') == 'Success') {
					String verificationRecordId = AOB_FlowController.createVerificationRecord(applicationList[0], 'Identifii', 'In Progress');
					responseMap.put('identifiiVerificationId', verificationRecordId);
				} else {
					AOB_FlowController.createVerificationRecord(applicationList[0], 'Identifii', 'Failed');
				}
				return JSON.serialize(responseMap);
			}
        }
        return null;
    }    
   /**
   * @description gets the token from the identifii 
   * @param application
   * @return responseMap
   */
	public static Map<String, Object> getTokenForIdentifiiCallout(Application__c application) {
		try{
		mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_IdentityApplicant');
		AOB_Identify_BodyBean.Body identifyBodyBean  = new AOB_Identify_BodyBean.Body();
		identifyBodyBean.ApplicationId				 = string.valueOf(mData.get('defaultIDVAppId'))??'';
		identifyBodyBean.IdNumber					 = application.AOB_NIN__c;
		identifyBodyBean.ClientReference			 = application.Id + String.valueOf(System.now().getTime());
		identifyBodyBean.DHACheckDisabled			 = 1;
		identifyBodyBean.IDValidationDisabled		 = 1;
        identifyBodyBean.LivenessMethod              = 1;


		AOB_Identify_BodyBean identifyBean  = new AOB_Identify_BodyBean();
		identifyBean.ApiKey      			= API_Key;
		identifyBean.Secret      			= secret;
		identifyBean.Url         			= URL;
		identifyBean.Method      			= HTTP_METHOD_POST;
		identifyBean.Body        			= identifyBodyBean;
            
		HttpResponse response = AOB_Iidentifii_Integration_Utilities.sendRequest(HTTP_METHOD_POST, endPoint, JSON.serialize(identifyBean)); 
		string authorizationToken = response.getBody();
		HttpResponse amxresponse = AOB_Iidentifii_Integration_Utilities.sendRequest1(endpoint_AMX, HTTP_METHOD_POST, JSON.serialize(identifyBodyBean), authorizationToken); 
		Map<String, Object> responseMap = new Map<String, Object>();
		responseMap.put('status', 'Success');
		responseMap.put('client_token', amxresponse.getBody());
		
		return responseMap;       
        }catch (Exception ex) {
            LOGGER.error('Error getting token for Identifii callout: ' + ex.getMessage());
            return null;
        } 
	}
    /**
     * @description Gets the token from the Identifii service
     * @param applicationList List of Application__c records
     * @param requestId The request identifier
     * @return JSON String response from Identifii callout
     */
    public static String invocableGETMethod(List<Application__c> applicationList, String requestId) {
        // Validate inputs
        if (applicationList == null || applicationList.isEmpty() || String.isBlank(requestId)) {
            return null;
        }

        AOB_Identify_BodyBean.Response responseMap = makeGETCalloutForUploadedDocuments(applicationList[0], requestId);
        Verification__c verificationInstance = initializeVerification(applicationList[0], responseMap);
        verificationInstance = processResponse(responseMap, verificationInstance);
        AOB_FlowController.createVerificationWithInstance(verificationInstance);
        return JSON.serialize(responseMap);
    }

    /**
     * @description Initializes a Verification__c record based on the response
     * @param application The application record
     * @param responseMap The response from Identifii
     * @return Initialized Verification__c record
     */
    private static Verification__c initializeVerification(Application__c application, AOB_Identify_BodyBean.Response responseMap) {
        Verification__c verificationInstance = new Verification__c(
            Application__c = application.Id,
            Verification_Source__c = 'Identifii Documents'
        );
        
        // Set liveness scores if available
        if (responseMap?.IdentityImages != null && !responseMap.IdentityImages.isEmpty()) {
            verificationInstance.AOB_Liveness_Matched__c = ((responseMap.LivenessFRMatch != null && responseMap.LivenessFRMatch) ? true: false);
            verificationInstance.AOB_Liveness_Score__c = responseMap.LivenessFRScore == null ? 0: responseMap.LivenessFRScore;
        }
        
        return verificationInstance;
    }

    /**
     * @description Processes the response and updates verification instance status
     * @param responseMap The response from Identifii
     * @param verificationInstance The Verification__c record being updated
     * @return The updated Verification__c record
     */
    private static Verification__c processResponse(AOB_Identify_BodyBean.Response responseMap, Verification__c verificationInstance) {
        Verification__c updatedVerificationInstance = verificationInstance;
        
        if (!isValidResponse(responseMap)) {
            updatedVerificationInstance.Verification_Status__c = 'Failed';
             return updatedVerificationInstance;
            
        } 
        updatedVerificationInstance.Verification_Status__c=((responseMap.LivenessFRMatch != null && responseMap.LivenessFRMatch) ? 'Success': 'Failed');

        if (Test.isRunningTest()) {
            processTestEnvironment(responseMap, updatedVerificationInstance);
        }
        return updatedVerificationInstance;
    }

    /**
     * @description Validates if the response is valid
     * @param responseMap The response from Identifii
     * @return True if the response is valid, otherwise false
     */
    private static Boolean isValidResponse(AOB_Identify_BodyBean.Response responseMap) {
        return responseMap?.IdentityImages != null && !responseMap.IdentityImages.isEmpty();
    }

    /**
     * @description Processes test environment-specific logic
     * @param responseMap The response from Identifii
     * @param verificationInstance The Verification__c record being updated
     */
    private static void processTestEnvironment(AOB_Identify_BodyBean.Response responseMap, Verification__c verificationInstance) {
        // Validate image fields before processing
        if (responseMap.IdentityImages[0]?.ImageType?.Description != null && 
            responseMap.IdentityImages[0]?.IdentityID != null && 
            responseMap.IdentityImages[0]?.Image != null) {
            verificationInstance.AOB_Identifii_Document_Id__c = responseMap.IdentityImages[0].ImageType.Id;
        }
    }
 
/**
   * @description Retrieves uploaded documents and OCR fields for a given application and request ID.
   * @param application
   * @param requestId
   * @return AOB_Identify_BodyBean
   */
	public static AOB_Identify_BodyBean.Response makeGETCalloutForUploadedDocuments(Application__c application, String requestId) {
		
        iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('AuthorizationAPI');
		iiDENTiFii_API_Setting__mdt documentsAPI = iiDENTiFii_API_Setting__mdt.getInstance('GETDocumentsAPI');
		
		String endpointURL = documentsAPI.End_Point__c + '/identities(' + requestId + ')';
		HttpResponse documentsResponse= AOB_Iidentifii_Integration_Utilities.getRequest(endpointURL, HTTP_METHOD_GET, string.valueOf(mData.get('idvImage')), mc); 		
		if(documentsResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
			Map<String, Object> returnFromOCR = makeGETCalloutForOCRFields( application,  requestId);
			String responseBody = documentsResponse.getBody();
			if (responseBody != null) {
				AOB_Identify_BodyBean.Response responseObject = (AOB_Identify_BodyBean.Response) JSON.deserialize(responseBody, AOB_Identify_BodyBean.Response.class);		
					responseObject.DateOfExpiry    =(string)returnFromOCR.get('DateOfExpiry')??'';
					responseObject.PersonalNumber= (string)returnFromOCR.get('PersonalNumber')??'';
                return responseObject;
			}
		}
		
		return null;
	}  
	 /**
   * @description make callout to upload documents
   * @param application
   * @param requestId
   * @return AOB_Identify_OCRBean
   */
  public static Map<String, Object> makeGETCalloutForOCRFields(Application__c application, String requestId) {
    // Ensure that mData is valid and contains the necessary idvDoc key
    if (!isValidMData()) {
        return createErrorResponse('Invalid or missing idvDoc in mData', 400);
    }

    // Fetch API settings and make the callout
    iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('AuthorizationAPI'); 
    iiDENTiFii_API_Setting__mdt documentsAPI = iiDENTiFii_API_Setting__mdt.getInstance('GETDocumentsAPI'); 
    String endpointURL = documentsAPI.End_Point__c + '/identities(' + requestId + ')';
    
    HttpResponse documentsResponse = AOB_Iidentifii_Integration_Utilities.getRequest(endpointURL, HTTP_METHOD_GET, String.valueOf(mData.get('idvDoc')), mc); 
    
    // Handle the callout response
    return handleResponse(documentsResponse);
    }

    private static Boolean isValidMData() {
        return mData != null && mData.containsKey('idvDoc');
    }

    private static Map<String, Object> handleResponse(HttpResponse documentsResponse) {
        if (documentsResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = documentsResponse.getBody();

            // Check if response body is blank
            if (String.isBlank(responseBody)) {
                return createErrorResponse('No Response body', 204);
            }

            // Deserialize response and extract the required data
            return processResponseBody(responseBody);
        } else {
            // Handle non-200 responses
            return createErrorResponse('Internal server error', 500);
        }
    }

    private static Map<String, Object> processResponseBody(String responseBody) {
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> identityDocumentMetadatas = (List<Object>) responseObject.get('IdentityDocumentMetadatas');

        // Check if identityDocumentMetadatas is valid
        if (identityDocumentMetadatas != null && !identityDocumentMetadatas.isEmpty()) {
            Map<String, Object> frontVIZFields = extractFrontVIZFields(identityDocumentMetadatas);

            if (frontVIZFields != null) {
                String dateOfExpiry = (String) frontVIZFields.get('DateOfExpiry') ?? '';
                String personalNumber = (String) frontVIZFields.get('PersonalNumber') ?? '';

                // If we find relevant data, return success response
                if (!String.isBlank(dateOfExpiry) || !String.isBlank(personalNumber)) {
                    return createSuccessResponse(dateOfExpiry, personalNumber);
                }
            }
        }

        // No relevant data found
        return createErrorResponse('No relevant data found in response', 204);
    }

    private static Map<String, Object> extractFrontVIZFields(List<Object> identityDocumentMetadatas) {
        Map<String, Object> identityDocument = (Map<String, Object>) identityDocumentMetadatas[0];
        return (Map<String, Object>) identityDocument.get('FrontVIZFields');
    }

    private static Map<String, Object> createSuccessResponse(String dateOfExpiry, String personalNumber) {
        return new Map<String, Object>{
            'DateOfExpiry' => dateOfExpiry,
            'PersonalNumber' => personalNumber,
            'status' => 'SUCCESS',
            'statusCode' => 200
        };
    }

    private static Map<String, Object> createErrorResponse(String errorDescription, Integer statusCode) {
        return new Map<String, Object>{
            'status' => 'ERROR',
            'statusCode' => statusCode,
            'ErrorDescription' => errorDescription
        };
    }

}