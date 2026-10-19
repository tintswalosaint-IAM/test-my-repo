/**
* @description CMN_IdentifiiApplicant
* Class for dealing with identifi api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh
* Story No:SFP-24640
* @date May 2023
*/
public without sharing class CMN_IdentifiiApplicant {
	private static final String URL_PARAMS = '$expand=IdentityImages($expand=ImageType)';
	private static final String URL_PARAMS1='$select=ID,FirstName,Surname&$expand=DocumentTypeDetected,DocumentTypeSelected,IdentityDocumentMetadatas($expand=DocumentTypeFront,DocumentTypeBack)';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_IdentifiiApplicant');
	 /**
     * @description Fetches appParticipantList 
	 * @param applicationParticipantIdList
     * @return String
     */
	public static String invocableMethod( List<Application_Participant__c> applicationParticipantIdList)  {
        if(applicationParticipantIdList != null && applicationParticipantIdList.isEmpty() == false) {	
			List<Application__c> applicationList = [SELECT Id, Name,AOB_Stage__c	 FROM Application__c WHERE Id=:applicationParticipantIdList[0].Application__c];
			if(applicationList.isEmpty() == false ) {
				Map<String, Object> responseMap =  getTokenForIdentifiiCallout(applicationList[0], applicationParticipantIdList[0]);
				if(responseMap != null && responseMap.containsKey('status') && responseMap.get('status') == 'Success') {
					String verificationRecordId = BCB_FlowController.createVerificationRecordForParticipant(applicationParticipantIdList[0], 'Identifii', 'In Progress');
					responseMap.put('identifiiVerificationId', verificationRecordId);
				} else {
					BCB_FlowController.createVerificationRecordForParticipant(applicationParticipantIdList[0], 'Identifii', 'Failed');
				}
				return JSON.serialize(responseMap);
			} 
        }
        return null;
    }    
   /**
   * @description gets the token from the identifii 
   * @param application
   * @param applicationParticipant
   * @return responseMap
   */
	public static Map<String, Object> getTokenForIdentifiiCallout(Application__c application, Application_Participant__c applicationParticipant) {
		
        iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('AuthorizationAPI');
		iiDENTiFii_API_Setting__mdt mcAMXToken = iiDENTiFii_API_Setting__mdt.getInstance('AmxTokenAPI');

		BCB_Identify_BodyBean.Body identifyBodyBean  = new BCB_Identify_BodyBean.Body();
		identifyBodyBean.ApplicationId				 = Label.DEFAULT_IDENTIFI_APPLICATIONID;
		identifyBodyBean.IdNumber					 = applicationParticipant.AOB_IDNumber__c;
		identifyBodyBean.ClientReference			 = application.Id + String.valueOf(System.now().getTime());
		identifyBodyBean.DHACheckDisabled			 = 1;
		identifyBodyBean.IDValidationDisabled		 = 1;

		BCB_Identify_BodyBean identifyBean  = new BCB_Identify_BodyBean();
		identifyBean.ApiKey      			= mc.ApiKey__c;
		identifyBean.Secret      			= mc.Secret__c;
		identifyBean.Url         			= mc.Url__c;
		identifyBean.Method      			= mc.HTTP_Method__c;
		identifyBean.Body        			= identifyBodyBean;
            
		HttpResponse response = CMN_Iidentifii_Integration_Utilities.sendRequest(mc.HTTP_Method__c, mc.End_Point__c, JSON.serialize(identifyBean)); 
		string authorizationToken = response.getBody();
		HttpResponse amxresponse = CMN_Iidentifii_Integration_Utilities.sendRequest1(mcAMXToken.End_Point__c, mcAMXToken.HTTP_Method__c, JSON.serialize(identifyBodyBean), authorizationToken); 
		Map<String, Object> responseMap = new Map<String, Object>();
		responseMap.put('status', 'Success');
		responseMap.put('client_token', amxresponse.getBody());
		
		return responseMap;         
	}
   /**
   * @description gets CMN_IdentifiiApplicant
   * @param applicationList
   * @param requestId
   * @return String
   * Main
   */
	public static String invocableGETMethod(List<Application__c> applicationList, String requestId)  {
		if(applicationList != null && applicationList.isEmpty() == false && requestId != null) {
			BCB_Identify_BodyBean.Response responseMap =  makeGETCalloutForUploadedDocuments1( applicationList,requestId);
			Verification__c verificationInstance = new Verification__c(
				Application__c = applicationList[0].Id,
				Verification_Source__c = 'Identifii Documents'
			);

			if(responseMap != null && responseMap.IdentityImages != null && responseMap.IdentityImages.isEmpty() == false && responseMap.DateOfExpiry !=null ) {
				String verificationStatus = 'Failed';
				
				verificationInstance.AOB_Liveness_Matched__c = responseMap.LivenessFRMatch;
				if(verificationInstance.AOB_Liveness_Matched__c) {
					verificationStatus = 'Success';
				}
				verificationInstance.AOB_Liveness_Score__c = (responseMap.LivenessFRScore != null ? responseMap.LivenessFRScore : 0);
				verificationInstance.Verification_Status__c = verificationStatus;
				if(Test.isRunningTest() == true) {
					if(responseMap.IdentityImages[0].ImageType != null && responseMap.IdentityImages[0].ImageType.Description != null &&
					responseMap.IdentityImages[0].IdentityID != null && responseMap.IdentityImages[0].Image != null) {
						verificationInstance.AOB_Identifii_Document_Id__c = responseMap.IdentityImages[0].ImageType.Id;
					}
				}
			} else {
				verificationInstance.Verification_Status__c = 'Failed';
			}
			BCB_FlowController.createVerificationWithInstance(verificationInstance);
			return JSON.serialize(responseMap);
		}
        
        return null;
    }    
    /**
   * @description make callout to upload documents
   * @param applicationList
   * @param requestId
   * @return BCB_Identify_BodyBean
   */
	public static BCB_Identify_BodyBean.Response makeGETCalloutForUploadedDocuments1(List<Application__c> applicationList, String requestId) {
        iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('AuthorizationAPI');
		iiDENTiFii_API_Setting__mdt documentsAPI = iiDENTiFii_API_Setting__mdt.getInstance('GETDocumentsAPI');

		String endpointURL = documentsAPI.End_Point__c + '/identities(' + requestId + ')';
		
		HttpResponse documentsResponse = CMN_Iidentifii_Integration_Utilities.getRequest(endpointURL, documentsAPI.HTTP_Method__c, URL_PARAMS, mc);
		if(documentsResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
			Map<String, Object> returnFromOCR = makeGETCalloutForOCRFields( applicationList[0],  requestId);
			String responseBody = documentsResponse.getBody();
			if (responseBody != null) {
				BCB_Identify_BodyBean.Response responseObject = (BCB_Identify_BodyBean.Response) JSON.deserialize(responseBody, BCB_Identify_BodyBean.Response.class);
				if((integer)returnFromOCR.get('statusCode')!=400){			
					responseObject.DateOfExpiry    =(string)returnFromOCR.get('DateOfExpiry');
					responseObject.PersonalNumber= (string)returnFromOCR.get('PersonalNumber');
		   }
                return responseObject;
			}
		}
		
		return null;
	}
	 /**
   * @description make callout to upload documents
   * @param application
   * @param requestId
   * @return BCB_Identify_OCRBean
   */
	 public static Map<String, Object>  makeGETCalloutForOCRFields(Application__c application, String requestId) {
		try{
        iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('AuthorizationAPI');
		iiDENTiFii_API_Setting__mdt documentsAPI = iiDENTiFii_API_Setting__mdt.getInstance('GETDocumentsAPI');
		String endpointURL = documentsAPI.End_Point__c + '/identities(' + requestId + ')';
		Map<String, Object> responseToReturnObject = new Map<String, Object>();
		HttpResponse documentsResponse = CMN_Iidentifii_Integration_Utilities.getRequest(endpointURL, documentsAPI.HTTP_Method__c, URL_PARAMS1, mc); 
	         if(documentsResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
			String responseBody = documentsResponse.getBody();
			string dateOfExpiry;
			string personalNumber;
			if (responseBody != null) {
						Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
						List<Object> identityDocumentMetadatas = (List<Object>) responseObject.get('IdentityDocumentMetadatas');
						Map<String, Object> identityDocument = identityDocumentMetadatas.isEmpty() ? new Map<String, Object>() : (Map<String, Object>) identityDocumentMetadatas[0];
						Map<String, Object> frontVIZFields = (Map<String, Object>) identityDocument.get('FrontVIZFields');
					    dateOfExpiry = (String) frontVIZFields.get('DateOfExpiry');
						personalNumber = (String) frontVIZFields.get('PersonalNumber');
						if (String.isBlank(dateOfExpiry) || String.isBlank(personalNumber)) {
							responseToReturnObject.put('status', 'ERROR');
							responseToReturnObject.put('statusCode', 400);
							responseToReturnObject.put('ErrorDescription', 'DateOfExpiry or PersonalNumber is missing or invalid');
							LOGGER.error('CMN_IdentifiiApplicant.makeGETCalloutForOCRFields:Response status:FAILED',new String[] {'CMN_IdentifiiApplicant.makeGETCalloutForOCRFields', JSON.serialize(responseToReturnObject)});
						} else {
							responseToReturnObject.put('DateOfExpiry', dateOfExpiry);
							responseToReturnObject.put('PersonalNumber', personalNumber);
							responseToReturnObject.put('status', 'SUCCESS');
							responseToReturnObject.put('statusCode', 200);
						}
					} else {
						responseToReturnObject.put('status', 'ERROR');
						responseToReturnObject.put('statusCode', 400);
						responseToReturnObject.put('ErrorDescription', 'No response body');
						LOGGER.error('CMN_IdentifiiApplicant.makeGETCalloutForOCRFields:Response status:FAILED',new String[] {'CMN_IdentifiiApplicant.makeGETCalloutForOCRFields', JSON.serialize(responseToReturnObject)});
					}
					
				return responseToReturnObject;
			}
		} catch (Exception ex) {
			LOGGER.error('CMN_IdentifiiApplicant.makeGETCalloutForOCRFields:Some Un-Handled Exception Occurred', new String[] { 'CMN_IdentifiiApplicant.makeGETCalloutForOCRFields', application.Id, JSON.serialize(ex.getMessage()) });
		}
		return null;
	}
}