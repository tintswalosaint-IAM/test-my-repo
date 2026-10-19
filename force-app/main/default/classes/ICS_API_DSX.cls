/**
 * @description DSX API controller
 * @author Gnitsevich Anton
 * @date January 2023
 */
public with sharing class ICS_API_DSX {

    /**
    * @description  Logging framework
    */     
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS Document Storage - ICS_API_DSX');
    /**
    * @description  Content-Type multipart form-data boundary
    */     
    private static final  string MULTIPARTFORM_BOUNDARY = '--icssbdsx12A3GF';
     /**
    * @description  Salesforce ID text
    */     
    private static final  string SALESFORCE_ID = 'salesforceid';
      /**
    * @description  Callout text
    */     
    private static final  string CALLOUT = 'callout:';
    /**
    * @description  Environment instance for web service settings
    */     
    private static final String ENVIRONMENT = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ? 'ICS_API_DSX_DEV' : 'ICS_API_DSX_PROD';
    /**
    * @description  User email based on the environment
    */     
    private static final String USER_EMAIL = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ?'SAUAZRDSX@standardbank.com':'SAPAZRDSX@standardbank.com';
    /**
    * @description  User email text
    */     
    private static final String USER_DSX_ACCOUNT ='X-Account-ID';

    /**
    * @description  Path to store a new document using a multipart request
    */     
    private static final String PATH_STORE = '/store';	
    /**
    * @description  Path to return a list of documents by providing a filter criteria
    */     
    private static final String PATH_SEARCH = '/search'; 	
    /**
    * @description  Path to update document metadata
    */     
    private static final String PATH_UPDATE = '/update';	
    /**
    * @description  Path to update document retention date
    */     
    private static final String PATH_UPDATERETENTION = PATH_UPDATE + '/retention';			
    /**
    * @description  Mutual TLS Certificate
    */     
    private static final String AZURE_CERTIFICATE = 'chnw_sbo_uk_onboardingazurec';		
    /**
 	* @description ICS_API_DSX constructor
 	*/
     private ICS_API_DSX() {

    }

     /**
     * @description This method sends the client number to DSX for update
     * @param accountId Account Id
     * @param clientNumber BP Id from Account record
     * @param sectorCode RM sector code based on the client Country of Residence
     * @return Integer HTTP Status Code
     */
    public static Integer updateClientNumber (Id accountId, String clientNumber, String sectorCode) {
        
        JSONGenerator updateClientBody = JSON.createGenerator(true);
        updateClientBody.writeStartObject();
            updateClientBody.writeStringField(SALESFORCE_ID, accountId );
                updateClientBody.writeStringField('clientNo',Test.isRunningTest()?'00996639':clientNumber);
            	updateClientBody.writeStringField('sectorCode', Test.isRunningTest()?'1002':sectorCode);
		updateClientBody.writeEndObject();
		
        Integer statusCode;        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setBodY(updateClientBody.getAsString());
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE,CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(USER_DSX_ACCOUNT, USER_EMAIL);
        httpRequest.setClientCertificateName(AZURE_CERTIFICATE);
		CMN_WebserviceSetting__mdt webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(ENVIRONMENT);
        String endpoint = CALLOUT + webServiceSetting.CMN_NamedCredential__c + PATH_UPDATE;
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
        httpRequest.setTimeout(10000);
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                statusCode = httpResponse.getStatusCode();
            }
            else {
                String message = String.format(
                    'Update Client No request unsuccessful - [Account ID:] {0} [Response Status Code:] {1} [Response Body:] {2}',
                    new List<Object> { accountId, httpResponse.getStatusCode(), httpResponse.getBody() }
                );
                LOGGER.error(message);
                statusCode = httpResponse.getStatusCode();
            }
        } catch(Exception ex) {
            String message = String.format(
                'Update Client No exception - [Account ID:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);
        }
        return statusCode;
    }

    /**
     * @description This method sends the document to DSX for storage
     * @param accountId Account Id
     * @param documentVersion Content Version record
     * @return Integer HTTP Status Code
     */
    public static Integer storeDocument(Id accountId, ContentVersion documentVersion) {

        
        Integer statusCode;
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, 'multipart/form-data; boundary=' + MULTIPARTFORM_BOUNDARY);
        httpRequest.setHeader(USER_DSX_ACCOUNT, USER_EMAIL);
        httpRequest.setClientCertificateName(AZURE_CERTIFICATE);
		CMN_WebserviceSetting__mdt webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(ENVIRONMENT);
        String endpoint = CALLOUT + webServiceSetting.CMN_NamedCredential__c + PATH_STORE;
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
        httpRequest.setTimeout(10000);
        String documentName = documentVersion.Title + '.' + documentVersion.FileExtension;
        Blob formData = ICS_UTIL_HttpMultipartForm.build(MULTIPARTFORM_BOUNDARY)
            .writeParam(SALESFORCE_ID, accountId)
            .writeParam('documentType', documentVersion.DocumentType__c)
            .writeParam('documentDate', String.valueOf(documentVersion.DocumentDate__c))
            .writeParam('documentName', documentName)
            .writeFile('file', documentName, documentVersion.VersionData)
            .getFormAsBlob();
        httpRequest.setBodyAsBlob(formData);
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
               statusCode = httpResponse.getStatusCode();
            }
            else {
                String message = String.format(
                    'Store Document request unsuccessful - [Account ID:] {0} [Response Status Code:] {1} [Response Body:] {2}',
                    new List<Object> { accountId, httpResponse.getStatusCode(), httpResponse.getBody() }
                );
                LOGGER.error(message);
  				statusCode = httpResponse.getStatusCode(); 
            }
        } catch(Exception ex) {

            String message = String.format(
                'Store Document exception - [Account ID:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);

        }
        return statusCode;
    }

    /**
     * @description This method updates the retention date in DSX for specified client's documents
     * @param accountId Account Id
     * @param retentionDate Retention Date
     * @return Integer HTTP Status Code
     */
    public static Integer updateRetention(String accountId, String retentionDate) {
        
		JSONGenerator updateRetentionBody = JSON.createGenerator(true);
        updateRetentionBody.writeStartObject();
            updateRetentionBody.writeStringField(SALESFORCE_ID, accountId );
			updateRetentionBody.writeStringField('retentionDate',retentionDate);
		updateRetentionBody.writeEndObject();
        Integer statusCode; 
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(USER_DSX_ACCOUNT, USER_EMAIL);
        httpRequest.setClientCertificateName(AZURE_CERTIFICATE);
		CMN_WebserviceSetting__mdt webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(ENVIRONMENT);
        String endpoint = CALLOUT + webServiceSetting.CMN_NamedCredential__c + PATH_UPDATERETENTION;
        httpRequest.setEndpoint(endpoint);

        httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
        httpRequest.setTimeout(10000);
        httpRequest.setBody(updateRetentionBody.getAsString());
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                statusCode = httpResponse.getStatusCode();
            }
            else {
                String message = String.format(
                    'Update Retention request unsuccessful - [Account ID:] {0} [Response Status Code:] {1} [Response Body:] {2}',
                    new List<Object> { accountId, httpResponse.getStatusCode(), httpResponse.getBody() }
                );
                LOGGER.error(message);
                statusCode = httpResponse.getStatusCode();
            }
        } catch(Exception ex) {
            String message = String.format(
                'Update Retention exception - [Account ID:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);
        }
        return statusCode;
    }
    
    /**
     * @description This method returns documents stored in DSX for specified client, recursive
     * @param accountId Account Id
     * @param clientNumber BP Id from Account record
     * @param page Page number of the results to fetch from DSX.
     * @return List<ICS_CTRL_Documents.DocumentData> List of documents
     */
    public static List<ICS_CTRL_Documents.DocumentData> searchDocuments(String accountId, String clientNumber, String sectorCode, Integer page) {
      
        String searchBody = ICS_CTRL_Documents.searchPayload(accountId,clientNumber, sectorCode,page);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setBody(searchBody);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(USER_DSX_ACCOUNT, USER_EMAIL);
        httpRequest.setClientCertificateName(AZURE_CERTIFICATE);
		CMN_WebserviceSetting__mdt webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(ENVIRONMENT);
        String endpoint =  CALLOUT +webServiceSetting.CMN_NamedCredential__c + PATH_SEARCH;
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
        httpRequest.setTimeout(10000);
        List<ICS_CTRL_Documents.DocumentData> documents = new List<ICS_CTRL_Documents.DocumentData>();
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                if (String.isNotBlank(responseBody)) {
                    ICS_DTO_DSXResponse.Search responseObject =
                        (ICS_DTO_DSXResponse.Search) JSON.deserialize(responseBody, ICS_DTO_DSXResponse.Search.class);
                    if (responseObject.documents != null) {
                        for (ICS_DTO_DSXResponse.DocumentInfo documentInfo : responseObject.documents) {
                            ICS_CTRL_Documents.DocumentData document = new ICS_CTRL_Documents.DocumentData();
                            document.documentId = documentInfo.documentId;
                            document.documentName = documentInfo.documentName;
                            document.documentType = documentInfo.documentType;
                            document.documentDate = String.IsBlank(documentInfo.documentDate) ? null: Date.valueOf(documentInfo.documentDate);
                            document.retentionDate = String.IsBlank(documentInfo.retentionDate) ? Date.valueOf('9999-12-31'):  Date.valueOf(documentInfo.retentionDate);
                            document.clientNo = documentInfo.clientNo;
                            document.clientName = documentInfo.clientName;
                            document.salesForceId = documentInfo.salesForceId;
                            documents.add(document);
                        }
                        Boolean doGetNextPage =
                                responseObject.pageInfo.currentPage < responseObject.pageInfo.totalPages &&
                                responseObject.pageInfo.currentPage < 100; 
                        if (doGetNextPage) {
                            List<ICS_CTRL_Documents.DocumentData> nextPageDocuments =
                            searchDocuments(accountId, clientNumber, sectorCode, responseObject.pageInfo.currentPage + 1);
                            documents.addAll(nextPageDocuments);
                        }
                    }
                    if (clientNumber != null){
                       updateClientNumber(accountId, clientNumber, sectorCode);
                    } 
                }
            }else{
                String message = String.format(
                'Search Documents request unsuccessful or response body is empty/incorrect - [Account ID:] {0} [Response Status Code:] {1} [Response Body:] {2}',
                new List<Object> { accountId, httpResponse.getStatusCode(), httpResponse.getBody() }
            	);
            	LOGGER.error(message);
            }

        } catch(Exception ex) {
            String message = String.format(
                'Search Documents exception - [Account ID:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);
        }
        return documents;
    }
    
    /**
     * @description This method returns documents stored in DSX for specified client
     * @param documentId Document Id as assigned by DSX
     * @return ICS_CTRL_Documents.DocumentData Document including it's base64 data
     */
    public static ICS_CTRL_Documents.DocumentData downloadDocument(String documentId) {
       
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(USER_DSX_ACCOUNT, USER_EMAIL);
        httpRequest.setClientCertificateName(AZURE_CERTIFICATE);
		CMN_WebserviceSetting__mdt webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(ENVIRONMENT);
        String endpoint = CALLOUT + webServiceSetting.CMN_NamedCredential__c + '/' + documentId;
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_GET);
        httpRequest.setTimeout(120000);
        ICS_CTRL_Documents.DocumentData documentData = new ICS_CTRL_Documents.DocumentData();

        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                Blob responseBody = httpResponse.getBodyAsBlob();
                if (responseBody.size() > 0) {
                    List<String> headerKeys = httpResponse.getHeaderKeys();
                    for (String headerKey : headerKeys) {
                        if (headerKey == 'Content-Disposition') {
                            List<String> parts = httpResponse.getHeader(headerKey).split(';');
                            for (String part : parts) {
                                if (part.contains('filename=')) {
                                    documentData.filename = part.substringAfter('filename=').replace('"','').replace('jpg..jpe','jpg').replace('pdf..txt','pdf');
                                    documentData.mimeType = ICS_UTIL_DSXMimeType.getMimeType(documentData.filename.substringAfterLast('.'));
                                    break;
                                }
                            }
                        }
                    }
                    documentData.base64 = EncodingUtil.base64Encode(responseBody);
                }
            }else{
				String message = String.format(
                'Download Document request unsuccessful or response body is empty/incorrect - [Document DSX ID:] {0} [Response Status Code:] {1} [Response Body:] {2}',
                new List<Object> { documentId, httpResponse.getStatusCode(), httpResponse.getBodyAsBlob() }
            );
            LOGGER.error(message);
  
            }
        } catch(Exception ex) {
            String message = String.format(
                'Download Document exception - [Document DSX ID:] {0} [Exception Message:] {1}',
                new List<Object> { documentId, ex.getMessage() }
            );
            LOGGER.error(message);
        }
        return documentData;
    }
    
  
}