/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_SignatureVerification
@ Description       :Class for dealing Signature Verification API and sending the response .
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :27-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/

public class AOB_SignatureVerification {

   	//HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/signature/verification';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SignatureVerification');
    private static Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_SignatureVerification');

    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    /**
    * @description Method to invoke Signature Verification from flow controller
    * @param applicationList
    * @param  documentList
    * @return Stringified Response from the callout
    */
    public static String invokeSvsCallout(List<Application__c> applicationList, List<ContentVersion> documentList)  {
        
        if(applicationList.isEmpty() == false) {
            Map<String, Object> responseObject = makeSignatureVerificationCallOut(applicationList, documentList);            
            AOB_FlowController.createVerificationRecord(applicationList[0], 'Signature Verification', 
            responseObject != null && (String) responseObject.get('status') == 'SUCCESS' ? 'Success' : 'Failed');

            return JSON.serialize(responseObject);
        }
        return null;
    }
    /** 
    * @description This method used for main callout signature verification API
    * @param applicationList
    * @param documentList
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> makeSignatureVerificationCallOut(List<Application__c> applicationList, List<ContentVersion> documentList) {
        
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(!(applicationList != null && documentList != null)) {
            return responseToReturnObject;
        }
        Application__c applicationRecord = applicationList[0];
        Application__c appRecord = new SEL_Application().selectAppById(applicationRecord.Id);
        AOB_SignatureVerificationBean.BodyInfo bodyRecord = new AOB_SignatureVerificationBean.BodyInfo();

     
        BodyRecord.signatureAddRequest = constructBeanBodyInternal(applicationList, documentList);

        AOB_SignatureVerificationBean signatureVerificationRecord = new AOB_SignatureVerificationBean();
        signatureVerificationRecord.Body = bodyRecord;

        // Get callout headers
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(signatureVerificationRecord));
        //Make HTTP Request
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }
            httpResponse = http.Send(httpRequest);
            responseToReturnObject = constructResponse(httpResponse, applicationRecord);
        } catch (Exception ex) {
            LOGGER.error('AOB_SignatureVerification', new String[] {'AOB_SignatureVerification.makeSignatureVerificationCallOut', applicationRecord.Id},ex);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
        }
        
        return responseToReturnObject;
    }

    /** 
    * @description Method to construct response map based on the callout response
    * @param httpResponse
    * @param applicationRecord
    * @return Returns a cosntructed callout response in map format for remaining processing
    */
    private static Map<String, Object> constructResponse(HttpResponse httpResponse, Application__c applicationRecord) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        String responseBody = httpResponse.getBody();
        if (String.isBlank(responseBody)) {
            responseToReturnObject = new Map<String, Object>{
                'status' => 'NO_CONTENT', 
                'statusCode' => 204, 
                'ErrorDescription' => 'No response body'
            };
         LOGGER.error('AOB_SignatureVerification', new String[] {'AOB_SignatureVerification.makeSignatureVerificationCallOut:No response body', applicationRecord.Id});
         return responseToReturnObject;
        }
        
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> signatureAddResponse = (Map<String, Object>) responseObject.get('signatureAddResponse');
        
            // Check if signatureAddResponse is not null
            if (signatureAddResponse != null) {
                String signatureAddStatusCode = (String) signatureAddResponse.get('signatureAddStatusCode');
        
                if (signatureAddStatusCode != null && signatureAddStatusCode.equals('true')) {
                    responseToReturnObject = new Map<String, Object>{
                        'status' => 'SUCCESS', 
                        'signatureAddStatusCode' => signatureAddStatusCode
                    };
                } else {
                    responseToReturnObject = new Map<String, Object>{
                        'status' => 'FAILED', 
                        'ErrorDescription' => 'Signature add failed'
                    };
                }
            } else {
                responseToReturnObject = new Map<String, Object>{
                    'status' => 'FAILED', 
                    'ErrorDescription' => 'Invalid response format'
                };
            }
        } else {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            responseToReturnObject = new Map<String, Object>{
                'status' => 'FAILED',
                 'statusCode' => httpResponse.getStatusCode(), 
                 'ErrorDescription' => responseObject.get('moreInformation')
                };
            LOGGER.error('AOB_SignatureVerification.makeSignatureVerificationCallOut', new String[] {'AOB_SignatureVerification.makeSignatureVerificationCallOut', applicationRecord.Id,(string)responseObject.get('moreInformation')});
        }
        return responseToReturnObject;
    }

    /** 
    * @description Method to construct Request Body for signature and picture
    * @param applicationList
    * @param documentList
    * @return Returns a prepared request for signature and picture file
    */
    private static AOB_SignatureVerificationBean.SignatureAddRequestInfo constructBeanBodyInternal(List<Application__c> applicationList, List<ContentVersion> documentList) {
        ContentVersion pictureDocument = new ContentVersion();
        List<ContentDocumentLink> cDocLinks=new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationList[0].Id);
        if (!cDocLinks.isEmpty()) {
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink cdl : cDocLinks) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> contentVersions= new SEL_ContentVersion().selectApplicationByIdandTitleAndlastModifiedDate(contentDocumentIds,new list<string>{'Selfie image'});
            if (contentVersions != null && !contentVersions.isEmpty()) {
              for (ContentVersion cv : contentVersions) {
                pictureDocument = cv;
              }
          }
        }
        AOB_SignatureVerificationBean.SignatureAddRequestInfo signatureAddRequestRecord = new AOB_SignatureVerificationBean.SignatureAddRequestInfo();
        signatureAddRequestRecord.customerNumber    = applicationList[0].AOB_Customer_Id__c??'';
        signatureAddRequestRecord.bankIdentifier    = applicationList[0].AOB_Nationality__c??'';
        signatureAddRequestRecord.imageAccessCode   = string.valueOf(mData.get('imageAccessCode'))??'';
        signatureAddRequestRecord.signatureFile		= String.valueOf(documentList[0].VersionData)??'';   
        signatureAddRequestRecord.pictureFile 		= String.valueOf(EncodingUtil.base64Encode(pictureDocument.VersionData))??''; 
        return signatureAddRequestRecord;
    }
}