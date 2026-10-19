/**
* Class for dealing with identifi api and sending the result to the main container and storing the values in the wrapper
*
*
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date Jan 2023
*/
public without sharing class AOB_IdentifiiApplicant {
    private static final String URL_PARAMS = '$expand=IdentityImages($expand=ImageType)';
    /**
* @description method used to get AuthToken identifill
* @param applicationParticipantList
* @return String
*/   
    @AuraEnabled 
	public static String getAuthToken(List<Application_Participant__c> applicationParticipantList)  {
        if(applicationParticipantList != null && applicationParticipantList.isEmpty() == false) {

			Map<String, Object> responseMap =  getTokenForIdentifiiCallout(applicationParticipantList[0]);

			Verification__c verifyInstance = new Verification__c(
				Application_Participant__c = applicationParticipantList[0].Id,
				Verification_Source__c = 'Identifii'
			);

			if(responseMap != null && responseMap.containsKey('status') && responseMap.get('status') == 'Success') {
				verifyInstance.Verification_Status__c = 'In Progress';
			} else {
				verifyInstance.Verification_Status__c = 'Failed';
			}

			sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Verification__c.SObjectType });
			AOB_BOTS_SRV_Verification.newInstance().saveVerification(new List<Verification__c> {verifyInstance}, uow);
			uow.commitWork();

			responseMap.put('identifiiVerificationId', verifyInstance.Id);

			return JSON.serialize(responseMap);
        }
        return null;
    }    
    
    /**
* @description This method used for get access token
* @param applicationParticipantList
* @return String
*/
    
	public static Map<String, Object> getTokenForIdentifiiCallout(Application_Participant__c applicationParticipant) {
		
        iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('BOTS_AuthorizationAPI');
		iiDENTiFii_API_Setting__mdt mcAMXToken = iiDENTiFii_API_Setting__mdt.getInstance('BOTS_AmxTokenAPI');
		AOB_Identify_BodyBean.Body identifyBodyBean  = new AOB_Identify_BodyBean.Body();
		identifyBodyBean.ApplicationId				 = mc.ApplicationId__c;
		identifyBodyBean.IdNumber					 = (String) AOB_BOTS_SRV_ApplicationParticipant.newInstance().getValueByFieldLabel(applicationParticipant, 'OmangId');
		identifyBodyBean.ClientReference			 = applicationParticipant.Id + String.valueOf(System.now().getTime());
		identifyBodyBean.DHACheckDisabled			 = 1;
		identifyBodyBean.IDValidationDisabled		 = 1;
        //Added by Ikyatha SFP-58509 to enable liveness 
		identifyBodyBean.LivenessMethod              = 1;
        
		AOB_Identify_BodyBean identifyBean  = new AOB_Identify_BodyBean();
		identifyBean.ApiKey      			= mc.ApiKey__c;
		identifyBean.Secret      			= mc.Secret__c;
		identifyBean.Url         			= mc.Url__c;
		identifyBean.Method      			= mc.HTTP_Method__c;
		identifyBean.Body        			= identifyBodyBean;
            
		HttpResponse response = AOB_Iidentifii_Integration_Utilities.sendRequest(mc.HTTP_Method__c, mc.End_Point__c, JSON.serialize(identifyBean)); 
		string authorizationToken = response.getBody();
		String bodystr = JSON.serialize(identifyBean);
		HttpResponse amxresponse = AOB_Iidentifii_Integration_Utilities.sendRequest1(mcAMXToken.End_Point__c, mcAMXToken.HTTP_Method__c, JSON.serialize(identifyBodyBean), authorizationToken); 
		Map<String, Object> responseMap = new Map<String, Object>();
		responseMap.put('status', 'Success');
		responseMap.put('wfrURL', mcAMXToken.WFR_URL__c + amxresponse.getBody());

		return responseMap;         
	}
 
    /**
* @description This method used for call API
* @param applicationParticipantList
* @param requestId
* @return String
*/
	@AuraEnabled
	public static String getUploadedDocuments(List<Application_Participant__c> applicationParticipantList, String requestId)  {
        
       	if(applicationParticipantList != null && applicationParticipantList.isEmpty() == false && requestId != null) {
			AOB_Identify_BodyBean.Response responseMap =  makeGETCalloutForUploadedDocuments(requestId);
			Verification__c verificationInstance = new Verification__c(
				Application_Participant__c = applicationParticipantList[0].Id,
				Verification_Source__c = 'Identifii Documents'
			);

			if(responseMap != null && responseMap.IdentityImages != null && responseMap.IdentityImages.isEmpty() == false) {
				String verificationStatus = 'Not Completed by Customer';
				verificationInstance.AOB_Liveness_Matched__c = responseMap.LivenessFRMatch;
				if(verificationInstance.AOB_Liveness_Matched__c) {
					verificationStatus = 'Completed by Customer';
				}
				verificationInstance.AOB_Liveness_Score__c = (responseMap.LivenessFRScore != null ? responseMap.LivenessFRScore : 0);
				verificationInstance.Verification_Status__c = verificationStatus;
				if(Test.isRunningTest() == true) {
					if(responseMap.IdentityImages[0].ImageType != null && responseMap.IdentityImages[0].ImageType.Description != null &&
					responseMap.IdentityImages[0].IdentityID != null && responseMap.IdentityImages[0].Image != null) {
						verificationInstance.AOB_Identifii_Document_Id__c = responseMap.IdentityImages[0].ImageType.Id;
					}
				}
				Map<String, ContentVersion> imageAndDocumentTypeMap = new Map<String, ContentVersion>();
				List<Application_Document__c> applicationDocuments = new List<Application_Document__c>();

				for(AOB_Identify_BodyBean.IdentityImages image : responseMap.IdentityImages) {
					applicationDocuments.add(
						new Application_Document__c(
							Document_Type__c = image.ImageType.Description, 
							External_Id__c = image.ImageType.Id
						)
					);
					imageAndDocumentTypeMap.put(
						image.ImageType.Description,
						new ContentVersion(
							Title = image.ImageType.Description,
							VersionData = image.Image,
							Description = image.ImageType.Description,
							pathOnClient = image.ImageType.Description +'.png'
						)
					);
				}
				sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { 
					Application__c.SObjectType, 
					Application_Participant__c.sObjectType,
					Application_Document__c.sObjectType,
					ContentVersion.sObjectType
				});
				AOB_BOTS_SRV_Application.newInstance().saveApplnDocuments(null,applicationParticipantList[0].Id, applicationDocuments, uow);
				uow.commitWork();

				uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { 
					Application__c.SObjectType,
					Application_Participant__c.sObjectType,
					Application_Document__c.sObjectType,
					ContentVersion.sObjectType,
					ContentDocumentLink.sObjectType
				});

				for(Application_Document__c document : applicationDocuments) {
					AOB_BOTS_SRV_Application.newInstance().saveDocuments(
						document.Id, 
						new List<ContentVersion>{imageAndDocumentTypeMap.get(document.Document_Type__c)}, 
						uow
					);
				}
				uow.commitWork();
			} else {
				verificationInstance.Verification_Status__c = 'Not Completed by Customer';	
			}
			updateVerificationStatus(verificationInstance);
			return JSON.serialize(responseMap);
		}
        return null;
    }    

  /**
* @description This method used for upload documents to API
* @param requestId
* @return Response
*/
	public static AOB_Identify_BodyBean.Response makeGETCalloutForUploadedDocuments(String requestId) {
        iiDENTiFii_API_Setting__mdt mc = iiDENTiFii_API_Setting__mdt.getInstance('BOTS_AuthorizationAPI');
		iiDENTiFii_API_Setting__mdt documentsAPI = iiDENTiFii_API_Setting__mdt.getInstance('BOTS_GETDocumentsAPI');
		String endpointURL = documentsAPI.End_Point__c + '/identities(' + requestId + ')';
		HttpResponse documentsResponse = AOB_Iidentifii_Integration_Utilities.getRequest(endpointURL, documentsAPI.HTTP_Method__c, URL_PARAMS, mc); 
		Map<String, Object> responseMap = new Map<String, Object>();
		if(documentsResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
			String responseBody = documentsResponse.getBody();
			if (responseBody != null) {
				AOB_Identify_BodyBean.Response responseObject = (AOB_Identify_BodyBean.Response) JSON.deserialize(responseBody, AOB_Identify_BodyBean.Response.class);
				return responseObject;
			}
		}
		return null;
	}

	/**
    * @description Method to update verification record status for identifii invoked from aob_comp_formCreator 
    * @param verificationRecordId
    * @param status
    */
    @AuraEnabled
    public static void updateVerificationStatus(Verification__c verificationRecord){
        try {
            sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Verification__c.SObjectType });
			AOB_BOTS_SRV_Verification.newInstance().saveVerification(new List<Verification__c> {verificationRecord}, uow);
			uow.commitWork();  
        } catch (Exception ex) {
            throw new AOB_CustomException(ex.getMessage());
        }
    }
    /**
    * @description Method to update verification record 
    * @param partipateid
    */
    @AuraEnabled
    public static void updateVerificationRecord(String partipateid){
        List<Verification__c> updateVerification= new List<Verification__c>();
        List<Verification__c> verlist= [select id,Application_Participant__c,Verification_Status__c,Verification_Source__c from Verification__c where Application_Participant__c=:partipateid and Verification_Status__c!='In Progress' and Verification_Status__c!='Success'];
        ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_CMB' Limit 1].Queue.Id;
        for(Verification__c vc:verlist){
            if(vc.Verification_Source__c=='Identifii' || vc.Verification_Source__c=='Identifii Documents'){
                vc.OwnerId = queueId;
                updateVerification.add(vc);
                
            }
        }
        update updateVerification;
        
    }
}