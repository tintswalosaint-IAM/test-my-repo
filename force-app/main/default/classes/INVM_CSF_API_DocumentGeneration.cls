/**
* @description Class to handle generate investment proposal template using CSF integration 
*
* @author Wipro
*
* @date July 2022
*/
public with sharing class INVM_CSF_API_DocumentGeneration {
    //Metadata Records
    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String AUTHORIZATION_TYPE_BASIC = 'Basic ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final Integer HTTP_TIMEOUT = 120000;
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String CMN_API_ESB_ACCESS_TOKEN_DEV = 'CSF_API_ESB_ACCESS_TOKEN_DEV'; 
    private static final String CMN_API_ESB_ACCESS_TOKEN_PROD = 'CSF_API_ESB_ACCESS_TOKEN_PROD';
    //Generic Constants
    private static final String PARAM_COLON = ':';
    
    // web service setting, query once per transaction
    private static final String TEST_SETTING = 'CSF_API_RestOutboundExample';
    public static CMN_WebserviceSetting__mdt webServiceSetting {
        get {
            if (webServiceSetting == null) {
                if (isSandbox) {
                    webServiceSetting = getMetadataByServiceName(CMN_API_ESB_ACCESS_TOKEN_DEV);
                }
                else {
                    webServiceSetting = getMetadataByServiceName(CMN_API_ESB_ACCESS_TOKEN_PROD);
                }
            }
            return webServiceSetting;
        }
        private set;
    }
    
    // is current instance a Sandbox, query once per transaction
    public static Boolean isSandbox {
        get {
            if (isSandbox == null) {
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }
    
    /**
* @description This method to get access token
*
* @param scope This is our HTTP Request Scope
*
* @return INVM_DTO_AuthenticationResponse responseObject
*/
    public static CMN_DTO_AuthenticationResponse getAccessToken(String scope) {
        try{
            String serviceName = getMetadataName();
            CMN_WebserviceSetting__mdt webServiceSetting = [SELECT Id, DeveloperName,  CMN_Path__c, CMN_NamedCredential__c,CMN_AdditionalKey__c,CMN_ClientID__c,CMN_Client_Secret__c,  INVM_CSFEndPoint__c, INVM_CSFRequestBody__c, INVM_ProposalTemplateBody__c,INVM_CSFSupportTeamEmails__c,INVM_SFSupportTeamEmails__c, INVM_SigningHubSupportTeamEmails__c, INVM_SigningHub_PingClientId__c, INVM_SigningHub_PingSecretId__c, INVM_LawtrustAuth__c FROM CMN_WebserviceSetting__mdt Where DeveloperName =: serviceName Limit 1];
        	webServiceSetting = webServiceSetting == null && Test.isRunningTest() ? CMN_WebserviceSetting__mdt.getInstance(CMN_API_ESB_ACCESS_TOKEN_DEV) : webServiceSetting;
            if(webServiceSetting != null) {
                NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
                if(namedCredential != null) {
                    Blob clientToken = Blob.valueOf(webServiceSetting.CMN_ClientID__c + PARAM_COLON + webServiceSetting.CMN_Client_Secret__c);
                    HttpRequest httpRequest = new HttpRequest();
                    //Set Request Headers
                    httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
                    httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
                    httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BASIC + EncodingUtil.base64Encode(clientToken));
                    //Set Request Details
                    httpRequest.setBody(String.format(webServiceSetting.CMN_Path__c, new List<String> {scope}));
                    httpRequest.setEndpoint(namedCredential.Endpoint);
                    httpRequest.setMethod(HTTP_METHOD_POST);
                    httpRequest.setTimeout(120000);
                    return sendRequest(httpRequest);
                    }
            }
        }catch(Exception e){
            String errMess;
            CMN_UTIL_Logger.error(e, 'INVM_CSF_API_DocumentGeneration.getAccessToken');
            throw new AuraHandledException('Error Exception happend \r'+ 'Class: INVM_CSF_API_DocumentGeneration \r Method:  getAccessToken\r'+ '\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + errMess); 
        }
        return null;
    }
    
    /**
* @description This method determines if the Metadata Name returned is for Development or Production Instance
*
* @return String Metadata Name
*/
    public static String getMetadataName() {
       if(isSandbox) {
            return CMN_API_ESB_ACCESS_TOKEN_DEV;
        }
        
        return CMN_API_ESB_ACCESS_TOKEN_PROD;
    }
    
    
    
    /**
* @description This method sends an HTTP Request to ESB Endpoint
*
* @param httpRequest This is our HTTP Request Object
*
* @return CMN_DTO_AuthenticationResponse responseObject
*/
    public static CMN_DTO_AuthenticationResponse sendRequest(HttpRequest httpRequest) {
        
        Http http = new Http();
        HttpResponse httpResponse = new HttpResponse();
        
        if(System.Test.isRunningTest()) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"token_type": "bearer","access_token": "201423083430380","expires_in": 33414050,"scope": "ojojiosa"}');
            CMN_DTO_AuthenticationResponse responseObject1 = (CMN_DTO_AuthenticationResponse)JSON.deserialize(response.getBody(), CMN_DTO_AuthenticationResponse.class);
            return responseObject1;
        }
        
        httpResponse = http.Send(httpRequest);
        if (httpResponse.getStatus()!='Error' && httpResponse.getStatusCode()!=500){
            CMN_DTO_AuthenticationResponse responseObject = (CMN_DTO_AuthenticationResponse)JSON.deserialize(httpResponse.getBody(), CMN_DTO_AuthenticationResponse.class);
            return responseObject;
        }else{
            return null;
        }
            
    }
    
    
    /**
* @description Method to get CSF template from CSF API
* @param accessToken API Access Token
* @param List<Investment_Proposal__c> investment proposal id
* @return HttpResponse responseObject
*/
    public static HttpResponse getDocumentTemplate(String accessToken,List<Investment_Proposal__c> lstInvProp) {
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        // set headers
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(HTTP_TIMEOUT);
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader('Connection','keep-alive');    
        httpRequest.setHeader('Content-Type', 'application/atom+xml'); 
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        String fApiInteractionId = createGUID();
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        httpRequest.setEndpoint(webServiceSetting.INVM_CSFEndPoint__c);
        String requestBody = getRequestBodyForDocumentGeneration(lstInvProp);
       system.debug('requestBody' + requestBody);
        Http http = new Http();
        if(System.Test.isRunningTest()) {
            HttpResponse response = new HttpResponse(); 
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('<xml><GenerateDocumentResponse><ErrCde>0</ErrCde><Name>sample</Name><DocStreamArray><Path></Path><DataType>pdf</DataType><PageCount>8</PageCount><Data>wecome</Data></DocStreamArray></GenerateDocumentResponse></xml>');
            return response;
        }       
        try {
            httpRequest.setBody(requestBody);
            httpResponse = http.Send(httpRequest);
 			return httpResponse;
           
        } catch (Exception e) {
            CMN_UTIL_Logger.error(e, 'INVM_CSF_API_DocumentGeneration.getDocumentTemplate');
            throw new AuraHandledException('Error Exception happend'+e.getMessage());           
        }
        
      
    }
    
    /**
* @description Method to get request body for CSF API to generate template

* @param List<Investment_Proposal__c> investment proposal id
* @return String RequestBody
*/
    public static String getRequestBodyForDocumentGeneration(List<Investment_Proposal__c> lstInvP){
        String requestBody;
        String strLeadName;
        
        try{
            strLeadName = lstInvP[0].lead__r.Salutation == null ? INVM_CSF_API_DocumentGeneration.toTitleCase(lstInvP[0].Lead__r.Name.escapeHtml4()):INVM_CSF_API_DocumentGeneration.toTitleCase(lstInvP[0].lead__r.Salutation + '. ' + lstInvP[0].Lead__r.Name.escapeHtml4());
            String strProposalXml = String.format(
                webServiceSetting.INVM_ProposalTemplateBody__c,
                new List<String>{
                    	strLeadName,
                    	strLeadName,
                        getMonthYear(),
                        lstInvP[0].owner.Name.escapeHtml4(),
                        lstInvP[0].INVM_PreparedByTitle__c.escapeHtml4(),
                        lstInvP[0].INVM_SummaryOfQualifications__c.escapeHtml4(),
                        lstInvP[0].Owner.Phone,
                        lstInvP[0].Owner.Email,
                        lstInvP[0].INVM_ReferralRole__c.escapeHtml4(),
                        lstInvP[0].INVM_ReferralName__c.escapeHtml4(),
                        lstInvP[0].INVM_ReferralSurname__c.escapeHtml4(),
                        lstInvP[0].INVM_Background__c.escapeHtml4(),
                        'R' + ' ' + String.valueOf(lstInvP[0].INVM_InvestmentAmount__c.format().replace(',',' ')),
                        lstInvP[0].INVM_InvestmentObjective__c.escapeHtml4(),
                        lstInvP[0].INVM_RiskProfile__c,
                        lstInvP[0].INVM_IncomeRequirements__c.escapeHtml4(),
                        lstInvP[0].INVM_InvestmentHorizon__c.escapeHtml4(),
                        lstInvP[0].INVM_TypeOfPortfolio__c,
                        lstInvP[0].INVM_AdditionalConsiderations__c.escapeHtml4(),
                        lstInvP[0].INVM_ProposedRiskMandate__c.escapeHtml4(),
                        lstInvP[0].INVM_MarketDrawdowns__c.escapeHtml4(),
                        String.valueOf(lstInvP[0].INVM_ManagementFees__c),
                        String.valueOf(lstInvP[0].INVM_TotalExpenseRatio__c)
                        }
            );
            String strBase64 = EncodingUtil.Base64Encode(Blob.valueOf(strProposalXml));  
            requestBody = String.format(webServiceSetting.INVM_CSFRequestBody__c, new List<String>{strBase64});
            return requestBody;
        }catch(Exception e){
            CMN_UTIL_Logger.error(e, 'INVM_CSF_API_DocumentGeneration.getRequestBodyForDocumentGeneration');
        }
        return requestBody;
    }
    
    /**
* @description Method to get Month and Year of current date
*
* @return String dt
*
*/
     
    public static String getMonthYear(){
        DateTime dt = Datetime.now();
        return dt.format('MMMM') + ' ' + dt.format('YYYY');   
    }
    
    
    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }
    
    public static CMN_WebserviceSetting__mdt getMetadataByServiceName(String serviceName)
	{
        CMN_WebserviceSetting__mdt webServiceSetting = [SELECT Id, DeveloperName,  CMN_Path__c, CMN_NamedCredential__c,CMN_AdditionalKey__c,CMN_ClientID__c,CMN_Client_Secret__c,  INVM_CSFEndPoint__c, INVM_CSFRequestBody__c, INVM_ProposalTemplateBody__c,INVM_CSFSupportTeamEmails__c,INVM_SFSupportTeamEmails__c, INVM_SigningHubSupportTeamEmails__c, INVM_SigningHub_PingClientId__c, INVM_SigningHub_PingSecretId__c, INVM_LawtrustAuth__c FROM CMN_WebserviceSetting__mdt Where DeveloperName =: serviceName Limit 1];
        webServiceSetting = webServiceSetting == null && Test.isRunningTest() ? CMN_WebserviceSetting__mdt.getInstance(TEST_SETTING) : webServiceSetting;
		return webServiceSetting;
	}
    
    public static String toTitleCase(String phrase){
    String titlePhrase = '';
    //a set of words that should always (or at least, almost always) be in lower case when in Title Case    
    Set<String> forceLower = new Set<String>{'is', 'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};        
        if(phrase != null && phrase.length() > 0){
            String[] splitPhrase = phrase.trim().split(' ');            
            for(integer i = 0; i < splitPhrase.size(); i++){
                if(!forceLower.contains(splitPhrase[i].toLowerCase()) || i == 0 || i == (splitPhrase.size()-1) ){
                    titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase())+(splitPhrase[i].substring(1).toLowerCase())+' ';
                }
                else{
                    titlePhrase += splitPhrase[i].toLowerCase()+' ';
                }
            }
        }
    return titlePhrase.trim();
 }
}