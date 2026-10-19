/**
* @description Class to handle generate investment proposal template using CSF integration 
*
* @author Wipro
*
* @date July 2022
*/
public with sharing class INVM_SigningHub_API_SendInvProposal {
    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final Integer HTTP_TIMEOUT = 120000;
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String INVM_SigningHub_API_ESB_Dev = 'INVM_SigningHub_API_ESB_Dev';
    private static final String INVM_SigningHub_API_ESB_Prod = 'INVM_SigningHub_API_ESB_Prod';
    public static final String HTTP_HEADER_CLIENT_ID = 'x-ibm-client-id';
    public static final String HTTP_HEADER_CLIENT_SECRET = 'x-ibm-client-secret';
    private static final String PARAM_COLON = ':';
    private static final String TEST_SETTING = 'SigningHub_API_RestOutboundExample';
    /**
* @description This method sends Investment Proposal document to client
*
* @param accessToken access token to call signingHub api
*
* @return HttpResponse responseObject
*/
    public static HttpResponse sendInvestmentProposal(String accessToken, Id recordId) {
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        String serviceName = getMetadataName();
        CMN_WebserviceSetting__mdt webServiceSetting = [SELECT Id, DeveloperName,  CMN_Path__c, CMN_NamedCredential__c,CMN_AdditionalKey__c,CMN_ClientID__c,CMN_Client_Secret__c,  INVM_CSFEndPoint__c, INVM_CSFRequestBody__c, INVM_ProposalTemplateBody__c,INVM_CSFSupportTeamEmails__c,INVM_SFSupportTeamEmails__c, INVM_SigningHubSupportTeamEmails__c, INVM_SigningHub_PingClientId__c, INVM_SigningHub_PingSecretId__c, INVM_LawtrustAuth__c FROM CMN_WebserviceSetting__mdt Where DeveloperName =: serviceName Limit 1];
        webServiceSetting = webServiceSetting == null && Test.isRunningTest() ? CMN_WebserviceSetting__mdt.getInstance(TEST_SETTING) : webServiceSetting;
		
        if(webServiceSetting != null) {
            NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
            if(namedCredential != null) {
                // set headers
                httpRequest.setMethod(HTTP_METHOD_POST);
                httpRequest.setTimeout(HTTP_TIMEOUT);
                httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
                if(Test.isRunningTest()){
                    httpRequest.setHeader(HTTP_HEADER_CLIENT_ID, 'sdbe4567588696969');
                	httpRequest.setHeader(HTTP_HEADER_CLIENT_SECRET, 'sdbe4567588696969');
                	httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
                }else{
                    httpRequest.setHeader(HTTP_HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
                	httpRequest.setHeader(HTTP_HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
                	httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
                }
                String fApiInteractionId = createGUID();
                httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
                httpRequest.setHeader('Connection','keep-alive');    
                httpRequest.setHeader('Content-Type', 'application/json'); 
                httpRequest.setHeader('x-law-auth', 'dummydfbdhuddhughudgdf29yZDEyMw=='); 
                httpRequest.setEndpoint(webServiceSetting.INVM_CSFEndPoint__c);
                
                if (Test.isRunningTest()) {
                    HttpResponse response = new HttpResponse();
                    response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
                    response.setBody('{"status": "success","statusDescription": null,"addPackageResponse": {"packageId": "1655","workflowMode": "ONLY_OTHERS","workflowType": "SERIAL"},"uploadDocumentResponses": [{"documentId": "1440","message": null,"addSignatureFieldResponse": []}],"addSignerToWorkFlowResponses": {"status": "success","statusDescription": "success"},"shareDocumentResponse": [{"packageId": "1655","documents": ["1440"]}],"updateWorkflowUserAuthenticationResponse": null,"integrationLinkResponse": null}');
                    return response;
                }
                Http http = new Http();
                httpRequest.setBody(getSigningHubRequestBody(recordId));
                httpResponse = http.Send(httpRequest);
            }
        }
        return httpResponse;
    }
    
    /**
* @description This method determines if the Metadata Name returned is for Development or Production Instance
*
* @return String Metadata Name
*/
    public static String getMetadataName() {
        if(isSandbox()) {
            return INVM_SigningHub_API_ESB_Dev;
        }
        return INVM_SigningHub_API_ESB_Prod;
    }
    
    /**
* @description This method determines if the Current Organization is a Sandbox or Production Instance
*
* @return Boolean isSandbox
*/
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    /**
* @description This method to get access token
*
* @param scope This is our HTTP Request Scope
*
* @return CMN_DTO_AuthenticationResponse responseObject
*/ 
    public static CMN_DTO_AuthenticationResponse getAccessToken(String scope) {
        
        try{
            String serviceName = getMetadataName();
            CMN_WebserviceSetting__mdt webServiceSetting = [SELECT Id, DeveloperName,  CMN_Path__c, CMN_NamedCredential__c,CMN_AdditionalKey__c,CMN_ClientID__c,CMN_Client_Secret__c,  INVM_CSFEndPoint__c, INVM_CSFRequestBody__c, INVM_ProposalTemplateBody__c,INVM_CSFSupportTeamEmails__c,INVM_SFSupportTeamEmails__c, INVM_SigningHubSupportTeamEmails__c, INVM_SigningHub_PingClientId__c, INVM_SigningHub_PingSecretId__c, INVM_LawtrustAuth__c FROM CMN_WebserviceSetting__mdt Where DeveloperName =: serviceName Limit 1];
        	webServiceSetting = webServiceSetting == null && Test.isRunningTest() ? CMN_WebserviceSetting__mdt.getInstance(TEST_SETTING) : webServiceSetting;
		
            if(webServiceSetting != null) {
                NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
                if(namedCredential != null) {
                    String start = 'client_id=' + webServiceSetting.INVM_SigningHub_PingClientId__c + '&client_secret=' + webServiceSetting.INVM_SigningHub_PingSecretId__c +'&grant_type=client_credentials';
                    HttpRequest httpRequest = new HttpRequest();
                    httpRequest.setEndpoint(namedCredential.Endpoint); 
                    httpRequest.setMethod('POST');
                    httpRequest.setBody(start);
                    httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    httpRequest.setTimeout(60000);
                    Http http = new Http();
                    //Make HTTP Request
					return sendRequest(httpRequest);
                }
            }
        }catch(Exception e){
            CMN_UTIL_Logger.error(e, 'INVM_SigningHub_API_SendInvProposal.getAccessToken');
            throw new AuraHandledException('Error Exception happend \r'+ 'Class: INVM_SigningHub_API_SendInvProposal \r Method:  getAccessToken\r'+ '\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + e.getMessage()); 
        }
        return null;
    }
    
    public static CMN_DTO_AuthenticationResponse sendRequest(HttpRequest httpRequest) {
        
        Http http = new Http();
        HttpResponse httpResponse = new HttpResponse();
        
        if(Test.isRunningTest()) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"token_type": "bearer","access_token": "201423083430380","expires_in": 33414050,"scope": "ojojiosa"}');
            CMN_DTO_AuthenticationResponse responseObject1 = (CMN_DTO_AuthenticationResponse)JSON.deserialize(response.getBody(), CMN_DTO_AuthenticationResponse.class);
            return responseObject1;
        }
        httpResponse = http.Send(httpRequest);
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            CMN_DTO_AuthenticationResponse responseObject = (CMN_DTO_AuthenticationResponse)JSON.deserialize(httpResponse.getBody(), CMN_DTO_AuthenticationResponse.class);
            if(responseObject != null) {
                return responseObject;
            }
        } else {
            //CMN_DAL_Logger.error('API response: ' + httpResponse.getStatusCode() + '; ' + httpResponse.getBody(), 'INVM_CSF_API_DocumentGeneration.getDocumentTemplate');
            CMN_UTIL_Logger.error('API response: ' + httpResponse.getStatusCode() + '; ' + httpResponse.getBody(), 'INVM_CSF_API_DocumentGeneration.getDocumentTemplate');
        }
        return null;
    }
    
    /**
* @description Method to get request body for signinghub API to send template

* @param recordId investment proposal id
* @return String RequestBody
*/
    public static String getSigningHubRequestBody(Id recordId){
        
        String strSigningHubRequestBody;
        ContentDocumentLink docLink = [SELECT ID,ContentDocument.CreatedDate,ContentDocumentId, LinkedEntityId , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =:recordId Order by  ContentDocument.CreatedDate Desc Limit 1];
        List<ContentVersion> cv = [SELECT ContentDocumentId,VersionData from ContentVersion
                                   where ContentDocumentId =: docLink.ContentDocumentId order by CreatedDate DESC];
        
        String bodyEncoded = EncodingUtil.base64Encode(cv[0].versiondata); 
        List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{recordID});
        if(lstInvProp!=null && lstInvProp.size()==1){
            String packageName = lstInvProp[0].INVM_ProposedMandate__c +'_' +lstInvProp[0].Lead__r.Name;
            String fileName = lstInvProp[0].INVM_ProposedMandate__c +'_' +lstInvProp[0].Lead__r.Name+'.pdf';  
            String strLeadName = lstInvProp[0].lead__r.Salutation == null ? INVM_CSF_API_DocumentGeneration.toTitleCase(lstInvProp[0].Lead__r.Name.escapeHtml4()):INVM_CSF_API_DocumentGeneration.toTitleCase(lstInvProp[0].lead__r.Salutation + '. ' + lstInvProp[0].Lead__r.Name.escapeHtml4());
            String strEmailAddress = lstInvProp[0].Lead__r.Email;
            strSigningHubRequestBody=  '{';
            strSigningHubRequestBody= strSigningHubRequestBody + '"channelId": "MELVILLE_DOUGLAS",';
            strSigningHubRequestBody= strSigningHubRequestBody + '"addPackageRequest": { ';
            strSigningHubRequestBody= strSigningHubRequestBody + '"packageName": "' + packageName + '",';
            strSigningHubRequestBody= strSigningHubRequestBody + ' "workflowMode": "ONLY_OTHERS",';
            strSigningHubRequestBody= strSigningHubRequestBody + '"workflowType": "PARALLEL"';
            strSigningHubRequestBody= strSigningHubRequestBody + '},';
            strSigningHubRequestBody= strSigningHubRequestBody + '"uploadDocumentRequests": [';
            strSigningHubRequestBody= strSigningHubRequestBody + '  {';
            strSigningHubRequestBody= strSigningHubRequestBody + '   "fileName": "' + fileName + '",';
            strSigningHubRequestBody= strSigningHubRequestBody + '   "convertDocument": "false",';
            strSigningHubRequestBody= strSigningHubRequestBody + '   "source": "API",';
            strSigningHubRequestBody= strSigningHubRequestBody + ' "contentStreams": "' + bodyEncoded + '"';
            strSigningHubRequestBody= strSigningHubRequestBody + '}';
            strSigningHubRequestBody= strSigningHubRequestBody + '],';
            strSigningHubRequestBody= strSigningHubRequestBody + '"shareDocument": true,';
            strSigningHubRequestBody= strSigningHubRequestBody + '"addSignerToWorkflowRequest": {';
            strSigningHubRequestBody= strSigningHubRequestBody + '"signerToWorkFlows": [';
            strSigningHubRequestBody= strSigningHubRequestBody + '{';
            strSigningHubRequestBody= strSigningHubRequestBody + '"userEmail": "' + strEmailAddress + '",';
            strSigningHubRequestBody= strSigningHubRequestBody + '"username": "' + strLeadName + '",';
            strSigningHubRequestBody= strSigningHubRequestBody + '"role": "REVIEWER",';
            strSigningHubRequestBody= strSigningHubRequestBody + '"emailNotification": "true"';
            strSigningHubRequestBody= strSigningHubRequestBody + '}';
            strSigningHubRequestBody= strSigningHubRequestBody + ']';
            strSigningHubRequestBody= strSigningHubRequestBody + '} ';
            strSigningHubRequestBody= strSigningHubRequestBody + '}';
        }
        return strSigningHubRequestBody;
    }

    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }
}