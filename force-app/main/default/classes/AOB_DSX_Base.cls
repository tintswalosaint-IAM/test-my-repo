/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_DSX_Base
@ Description       :Abstract base class for DSX API integration with synchronous batch processing for heap optimization
@ Last Modified By  :Optimization
@ Last Modified On  :14-10-2025
@  User story : SFP-55436
*****************************************************************************************
@ last Modified By  :Jagadish Thummala
@ last Modified On  :9/1/2026
@ user story : SFP-60131
@ Modification Description : Added Taxonomy for Admin Photos and Account Maintenance
***************************************************************************************/
public without sharing abstract class AOB_DSX_Base {
    
    // HTTP Constants - Private (not needed by child classes)
    @TestVisible
    private static final String HTTP_METHOD = 'POST';
    @TestVisible
    private static final String PATH_CALLOUT = '/content/integration';
    @TestVisible
    private static final Integer HTTP_STATUS_OK = 200;
    @TestVisible
    private static final Integer HTTP_STATUS_NO_CONTENT = 204;
    public static final String ERROR_DESCR = 'ErrorDescription';

    // Document Type Constants - PUBLIC for child class access
    public static final String DOC_TYPE_ACCOUNT_ADMIN_APPLICATION = 'Account Administration\tApplication Form(s)';
    public static final String DOC_TYPE_ACCOUNT_ADMIN_PASSPORT = 'Account Administration\tPassport Sized Photos';
    public static final String DOC_TYPE_ACCOUNT_ADMIN_MAINTENANCE = 'Account Administration\tAccount Maintenance';
    public static final String DOC_TYPE_MANDATORY_KFD = 'Mandatory Central Bank Documents\tKey Facts Document';
    public static final String DOC_TYPE_MANDATES_SIGNATURE = 'Mandates\tSignature Card';
    public static final String DOC_TYPE_KYC_IDENTITY = 'KYC Documents\tProof of Identity';
    public static final String DOC_TYPE_KYC_RESIDENCE = 'KYC Documents\tProof of Residence';
    public static final String DOC_TYPE_KYC_EMPLOYMENT = 'KYC Documents\tProof of Employment';
    public static final String DOC_TYPE_KYC_INCOME = 'KYC Documents\tProof of Income';
    
    // Document Description Constants - PUBLIC for child class access
    public static final String DESC_SIGNATURE_FILE = 'Signature File';
    public static final String DESC_MANDATES_SIGNATURE = 'Mandates Signature Card';
    public static final String DESC_PROOF_OF_INCOME = 'Proof Of Income';
    public static final String DESC_SELFIE_IMAGE = 'Selfie image';
    public static final String DESC_FACE_IMAGE_IDV ='Account Administration Passport Sized Photos';
    public static final String DESC_DOC_IMAGE = 'DocImage';
    public static final String DESC_ID_FRONT = 'IdFront';
    public static final String DESC_ID_BACK = 'IdBack';
    public static final String DESC_ADMISSION_LETTER = 'AdmissionLetter';
    public static final String DESC_KYC_IDENTITY = 'KYC Documents Proof of Identity';
    public static final String DESC_KYC_RESIDENCE = 'KYC Documents Proof of Residence';
    
    // Static Resource Names - Private (not needed by child classes)
    @TestVisible
    private static final String SR_ACCOUNT_OPENING = 'AOB_Uganda_TC_AccountOpening';
    @TestVisible
    private static final String SR_ELECTRONIC_BANKING = 'AOB_Uganda_TC_ElectronicBanking';
    @TestVisible
    private static final String SR_ATM_CARD = 'AOB_Uganda_TC_ATM_Card';
    @TestVisible
    private static final String SR_DESC_TC_ACCOUNT_OPENING = 'TC_AccountOpening';
    @TestVisible
    private static final String SR_DESC_TC_ELECTRONIC_BANKING = 'TC_ElectronicBanking';
    @TestVisible
    private static final String SR_DESC_TC_ATM_CARD = 'TC_ATM_Card';
    
    // Response Status Constants - Private
    @TestVisible
    private static final String STATUS_SUCCESS = 'SUCCESS';
    @TestVisible
    private static final String STATUS_FAILED = 'FAILED';
    @TestVisible
    private static final String REASON_CODE_SUCCESS = 'success';
    
    // Verification Constants - Private
    @TestVisible
    private static final String VERIFICATION_SOURCE_DSX = 'DSX';
    @TestVisible
    private static final String VERIFICATION_STATUS_SUCCESS = 'Success';
    @TestVisible
    private static final String VERIFICATION_STATUS_FAILED = 'Failed';
    
    // Error Messages - Private
    @TestVisible
    private static final String ERROR_NO_RESPONSE_SERVER = 'No Response From Server';
    @TestVisible
    private static final String ERROR_NO_RESPONSE_BODY = 'No response body';
    @TestVisible
    private static final String ERROR_DOCUMENT_UPLOAD_FAILED = 'Your KYC documents could not be successfully uploaded!';
    
    // Metadata Constants - Private
    @TestVisible
    private static final String METADATA_TYPE_AOB_DSX = 'AOB_DSX';
    @TestVisible
    private static final String METADATA_AGENT = 'Agent';
    
    // Test Data Constants - Private
    @TestVisible
    private static final String TEST_DATA_BODY = 'Test';
    
    // Document Mapping - Private
    @TestVisible
    private static final Map<String, String> DOCUMENT_AND_KYC_NAME_MAP = new Map<String, String>{ 
        DESC_DOC_IMAGE => DOC_TYPE_ACCOUNT_ADMIN_PASSPORT,
        SR_ACCOUNT_OPENING => DOC_TYPE_ACCOUNT_ADMIN_MAINTENANCE,
        SR_ELECTRONIC_BANKING => DOC_TYPE_ACCOUNT_ADMIN_MAINTENANCE
    };
    
    @TestVisible
    private static final Map<String, Object> METADATA = new AOB_SEL_CustomMetaDataType().getMetadataByType(METADATA_TYPE_AOB_DSX);
    // Batch Size Constant for Heap Optimization
    @TestVisible
    private static final Integer DOC_BATCH_SIZE = integer.valueOf(METADATA.get('docBatchSize')); 
    // Instance Variables - Protected non-static
    protected List<ContentVersion> welcomePackDocList = new List<ContentVersion>();
    protected sbgplatform.rflib_Logger logger;
    protected ContentVersion generatedPdf;  // Holds in-memory PDF for post-callout insert
    
    // Test Variables - Protected non-static for test access
    public static Integer mockHttpStatusCode;
    public static String mockHttpStatus;
    public static String mockHttpBody = '';
    
    /**************************************************************************************
     * ABSTRACT METHODS - TO BE IMPLEMENTED BY CHILD CLASSES
     **************************************************************************************/
    
    /** 
     * @description Gets additional content documents specific to implementation
     * @param applicationRecord Application record
     * @return List of additional ContentVersions
     */
    protected abstract List<ContentVersion> getAdditionalContentDocuments(Application__c applicationRecord);
    
    /** 
     * @description Gets count of additional content documents without loading data (for logging/monitoring)
     * @param applicationRecord Application record
     * @return Integer count of additional docs
     */
    protected abstract Integer getAdditionalContentDocumentsCount(Application__c applicationRecord);
    
    /** 
     * @description Builds document type mapping specific to implementation
     * @return Map of title/description to document type
     */
    protected abstract Map<String, String> buildDocumentTypeMapping();
    
    /** 
     * @description Creates verification record using appropriate flow controller
     * @param verificationInstance Verification record to create
     */
    protected abstract void createVerificationRecord(Verification__c verificationInstance);
    
    /** 
     * @description Gets logger name for the specific implementation
     * @return Logger name string
     */
    protected abstract String getLoggerName();
    
    /**************************************************************************************
     * CONSTRUCTOR
     **************************************************************************************/
    
    protected AOB_DSX_Base() {
        this.logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(getLoggerName());
    }
    
    /**************************************************************************************
     * MAIN INVOKE METHOD (SYNCHRONOUS WITH BATCHING; CALLOUT BEFORE DML)
     **************************************************************************************/
    
    /** 
     * @description Main method to invoke the DSX callout process. Generates PDF in memory
     * @param applicationList List of Application records
     * @param productList List of Product records
     * @return Serialized callout response in JSON format
     */
    public String invokeDsxCallout(List<Application__c> applicationList, List<Product2> productList) { 
        if (applicationList.isEmpty() || productList.isEmpty()) {
            return null;
        }
        
        Application__c app = applicationList[0];
        Product2 prod = productList[0];
        
        welcomePackDocList.clear();
        generatedPdf = null;
        
        try {
            // Generate PDF in memory once (no DML; safe for callouts)
            generatedPdf = generateApplicationPDF(app);
            if (generatedPdf == null || generatedPdf.VersionData == null) {
                Map<String, Object> errorResponse = new Map<String, Object>{
                    'status' => STATUS_FAILED, 
                    ERROR_DESCR => 'PDF generation failed'
                };
                createVerification(app, errorResponse);
                return JSON.serialize(errorResponse);
            }
            
            // Add to welcome pack (in-memory for reuse across batches)
            welcomePackDocList.add(generatedPdf);
            
            // Execute batched callouts (no DML pending; PDF used via VersionData)
            Map<String, Object> responseObject = executeDSXCallout(applicationList, productList);
            
            // Always persist PDF (DML after callouts, if generated)
            persistPDF(app);
            
            // Always create verification (status based on response)
            createVerification(app, responseObject);
            
            // Reuse restored PDF in welcomePackDocList for email (no re-gen needed)
            sendWelcomePackIfNeeded(applicationList);
            
            return JSON.serialize(responseObject);
            
        } catch (Exception ex) {
            logger.error('invokeDsxCallout: Unhandled exception during DSX processing', ex);
            Map<String, Object> errorResponse = new Map<String, Object>{
                'status' => STATUS_FAILED, 
                ERROR_DESCR => ex.getMessage()
            };
            // Persist PDF if generated (even on exception)
            if (generatedPdf != null) {
                persistPDF(app);
            }
            createVerification(app, errorResponse);
            
            // Reuse restored PDF in welcomePackDocList for email (no re-gen needed)
            sendWelcomePackIfNeeded(applicationList);
            return JSON.serialize(errorResponse);
        }
    }
    
    /** 
     * @description Generates application PDF in memory (no insert; for callout use)
     * @param applicationRecord Application record
     * @return ContentVersion with PDF data or null
     */
    private ContentVersion generateApplicationPDF(Application__c applicationRecord) {
        PageReference pageOutput = new PageReference('/apex/AOB_Application_As_PDF');
        Blob pdfBody = Blob.valueOf(TEST_DATA_BODY);
        
        if (!Test.isRunningTest()) {
            pageOutput.getParameters().put('id', applicationRecord.Id);
            pdfBody = pageOutput.getContentAsPdf();
        }
        
        if (pdfBody == null || pdfBody.size() == 0) {
            logger.error('generateApplicationPDF: Empty PDF blob');
            return null;
        }
                
        ContentVersion applicationPdfVersion = new ContentVersion(
            Title = DOC_TYPE_ACCOUNT_ADMIN_APPLICATION ,
            Description = DOC_TYPE_ACCOUNT_ADMIN_APPLICATION,
            VersionData = pdfBody,
            PathOnClient = DOC_TYPE_ACCOUNT_ADMIN_APPLICATION + '.pdf'
        );
        
        logger.info('PDF generated in memory for app ' + applicationRecord.Id);
        return applicationPdfVersion;
    }
    
    /** 
     * @description Persists generated PDF as ContentVersion + link (called post-callouts, always if generated; regenerates blob if consumed in callout)
     * @param applicationRecord Application record
     */
    private void persistPDF(Application__c applicationRecord) {
        if (generatedPdf == null) {
            return;
        }
        
        try {
            // Regenerate blob if consumed during callout
            if (generatedPdf.VersionData == null) {
                logger.info('Regenerating PDF blob for persistence (was consumed in callout) for app ' + applicationRecord.Id);
                PageReference pageOutput = new PageReference('/apex/AOB_Application_As_PDF');
                
                Blob pdfBody = Blob.valueOf(TEST_DATA_BODY);
                if (!Test.isRunningTest()) {
                    pageOutput.getParameters().put('id', applicationRecord.Id);
                    pdfBody = pageOutput.getContentAsPdf();
                }
                
                if (pdfBody == null || pdfBody.size() == 0) {
                    throw new AuraHandledException('Regenerated PDF blob is empty');
                }
                generatedPdf.VersionData = pdfBody;
            }
            generatedPdf.FirstPublishLocationId = applicationRecord.Id;
            insert generatedPdf;

        } catch (Exception ex) {
            logger.error('persistPDF: Failed to persist PDF for app ' + applicationRecord.Id, ex);
            
        }
    }
    
    /**************************************************************************************
     * DOCUMENT PREPARATION METHODS (CALLED ONCE PER INVOCATION; USES IN-MEMORY PDF)
     **************************************************************************************/
    
    /** 
     * @description Prepares all documents once (PDF in memory; adds others)
     * @param applicationRecord Application record
     * @param productRecord Product record
     * @return List of all ContentVersions (in-memory for callout)
     */
    private List<ContentVersion> prepareDocuments(Application__c applicationRecord, Product2 productRecord) {
        List<ContentVersion> documentList = new List<ContentVersion>();
        
        // PDF already in welcomePackDocList (in-memory); add to documentList for batching
        documentList.addAll(welcomePackDocList);
        
        // Add other docs (KFD, static, additional) - no new DML
        documentList.addAll(getKeyFactsDocuments(applicationRecord, productRecord));
        documentList.addAll(getStaticResourceDocuments());
        documentList.addAll(getAdditionalContentDocuments(applicationRecord));
        
        logger.info('Prepared ' + documentList.size() + ' documents for batching (additional count: ' + getAdditionalContentDocumentsCount(applicationRecord) + ')');
        return documentList;
    }
    
    /** 
     * @description Retrieves Key Facts Documents (for callout only; excluded from welcome pack)
     * @param applicationRecord Application record
     * @param productRecord Product record
     * @return List of Key Facts Document ContentVersions
     */
    private List<ContentVersion> getKeyFactsDocuments(Application__c applicationRecord, Product2 productRecord) {
        List<ContentVersion> kfdFiles = new List<ContentVersion>();
        List<Id> contentDocumentIdList = new List<Id>();
        
        for (ContentDocumentLink cdl : new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationRecord.AOB_Product__c)) {
            contentDocumentIdList.add(cdl.ContentDocumentId);
        }
        
        if (contentDocumentIdList.isEmpty()) {
            return kfdFiles;
        }
        
        String recordsToFilter = productRecord.AOB_Account_Type__c + '_' + applicationRecord.AOB_Selected_Currency__c;
        
        for (ContentVersion cv : new SEL_ContentVersion().selectContentVersionByIds(contentDocumentIdList, recordsToFilter)) {
            cv.Title = DOC_TYPE_MANDATORY_KFD;
            cv.Description = DOC_TYPE_MANDATORY_KFD;
            kfdFiles.add(cv);
        }
        
        // KFDs excluded from welcome pack (callout only)
        return kfdFiles;
    }
    
    /** 
     * @description Retrieves static resource documents (T&Cs; not added to welcome pack)
     * @return List of static resource ContentVersions
     */
    private List<ContentVersion> getStaticResourceDocuments() {
        List<ContentVersion> staticResourceDocs = new List<ContentVersion>();  
        Map<String, Blob> staticResourceBodies = fetchStaticResources();
        Map<String, String> resourceDescriptions = buildResourceDescriptionMap();
        
        for (String resourceName : staticResourceBodies.keySet()) {
            String description = resourceDescriptions.get(resourceName);
            String title = DOC_TYPE_ACCOUNT_ADMIN_MAINTENANCE + ' - ' + description;
            
            ContentVersion tcVersion = new ContentVersion(
                Title = title,
                Description = description,
                VersionData = staticResourceBodies.get(resourceName)
            );
            staticResourceDocs.add(tcVersion);
        }
        
        return staticResourceDocs;
    }
    
    /** 
     * @description Fetches static resource bodies
     * @return Map of static resource names to their bodies
     */
    private Map<String, Blob> fetchStaticResources() {
        Map<String, Blob> staticResourceBodies = new Map<String, Blob>();
        List<String> staticResourceNames = new List<String>{SR_ACCOUNT_OPENING, SR_ELECTRONIC_BANKING, SR_ATM_CARD};
        
        List<StaticResource> staticResources = [
            SELECT Id, Name, Body 
            FROM StaticResource 
            WHERE Name IN :staticResourceNames 
        ];
        
        for (StaticResource sr : staticResources) {
            staticResourceBodies.put(sr.Name, sr.Body);
        }
        
        return staticResourceBodies;
    }
    
    /** 
     * @description Builds resource description map
     * @return Map of resource names to descriptions
     */
    private Map<String, String> buildResourceDescriptionMap() {
        return new Map<String, String>{
            SR_ACCOUNT_OPENING => SR_DESC_TC_ACCOUNT_OPENING,
            SR_ELECTRONIC_BANKING => SR_DESC_TC_ELECTRONIC_BANKING,
            SR_ATM_CARD => SR_DESC_TC_ATM_CARD
        };
    }
    
    /** 
     * @description Extracts content document IDs from links
     * @param cDocLinks List of ContentDocumentLinks
     * @return Set of content document IDs
     */
    protected Set<Id> extractContentDocumentIds(List<ContentDocumentLink> cDocLinks) {
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : cDocLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        return contentDocumentIds;
    }
    
    /**************************************************************************************
     * CALLOUT EXECUTION METHODS (BATCHED; NO DML BEFORE)
     **************************************************************************************/
    
    /** 
     * @description Executes the DSX callout with document batching (preps docs once, uses in-memory PDF)
     * @param applicationRecords List of Application records
     * @param productRecords List of Product records
     * @return Map containing aggregated callout responses from all batches
     */
    private Map<String, Object> executeDSXCallout(List<Application__c> applicationRecords, List<Product2> productRecords) {
        if (applicationRecords.isEmpty() || productRecords.isEmpty()) {
            return null;
        }
        
        Application__c applicationRecord = applicationRecords[0];
        Product2 productRecord = productRecords[0];
        
        // Single prep call (PDF in memory)
        List<ContentVersion> allDocuments = prepareDocuments(applicationRecord, productRecord);
        
        // Build batches iteratively
        List<List<ContentVersion>> documentBatches = new List<List<ContentVersion>>();
        List<ContentVersion> currentBatch = new List<ContentVersion>();

        for (ContentVersion doc : allDocuments) {
            currentBatch.add(doc);
            if (currentBatch.size() == DOC_BATCH_SIZE) {
                documentBatches.add(currentBatch.clone());
                currentBatch.clear();
            }
        }
        
        if (!currentBatch.isEmpty()) {
            documentBatches.add(currentBatch.clone());
        }
        
        // Aggregate responses
        Map<String, Object> aggregatedResponse = new Map<String, Object>{
            'aggStatus' => STATUS_SUCCESS,
            'batchResponses' => new List<Map<String, Object>>(),
            'totalBatches' => documentBatches.size(),
            'totalDocuments' => allDocuments.size()
        };
        
        for (List<ContentVersion> docBatch : documentBatches) {
            if (docBatch.isEmpty()) {
                continue;
            }
            
            AOB_DSXBean dsxBean = prepareDSXBeanForBatch(applicationRecord, docBatch);
            Map<String, Object> batchResponse = performHttpCallout(dsxBean, applicationRecord);
            
            if (batchResponse.get('status') == STATUS_FAILED) {
                aggregatedResponse.put('status', STATUS_FAILED);
            }
            ((List<Map<String, Object>>) aggregatedResponse.get('batchResponses')).add(batchResponse);
            
            docBatch.clear();  // Free memory
        }
        
        allDocuments.clear();
        currentBatch.clear();
        return aggregatedResponse;
    }
    
    /** 
     * @description Prepares DSX Bean for a batch (reuses prepared docs)
     * @param applicationRecord Application record
     * @param documentBatch Batch of ContentVersions
     * @return Populated DSX Bean
     */
    private AOB_DSXBean prepareDSXBeanForBatch(Application__c applicationRecord, List<ContentVersion> documentBatch) {
        AOB_DSXBean dsxBean = new AOB_DSXBean();
        dsxBean.agent = String.valueOf(METADATA.get(METADATA_AGENT));
        dsxBean.country = applicationRecord.AOB_Nationality__c;
        dsxBean.cif = applicationRecord.AOB_Customer_Id__c;
        dsxBean.Documents = transformDocumentsToDSXFormat(documentBatch, applicationRecord);
        
        documentBatch.clear();  // Free memory post-transform
        return dsxBean;
    }
    
    /** 
     * @description Transforms ContentVersions to DSX format
     * @param documentList List of ContentVersions
     * @param applicationRecord Application record
     * @return List of DSX Documents
     */
    private List<AOB_DSXBean.Documents> transformDocumentsToDSXFormat(List<ContentVersion> documentList, Application__c applicationRecord) {
        List<AOB_DSXBean.Documents> dsxDocsList = new List<AOB_DSXBean.Documents>();
        Map<String, String> docTypeMap = buildDocumentTypeMapping();
        for (ContentVersion document : documentList) {
            AOB_DSXBean.Documents dsxDocs = createDSXDocumentFromContentVersion(document, applicationRecord, docTypeMap);
            dsxDocsList.add(dsxDocs);
        }
        
        documentList.clear();  // Free memory
        return dsxDocsList;
    }
    
    /** 
     * @description Creates DSX document from ContentVersion
     * @param document ContentVersion
     * @param applicationRecord Application record
     * @param docTypeMap Document type map
     * @return DSX Document
     */
    private AOB_DSXBean.Documents createDSXDocumentFromContentVersion(ContentVersion document, Application__c applicationRecord, Map<String, String> docTypeMap) {
        AOB_DSXBean.Documents dsxDocs = new AOB_DSXBean.Documents();
        
        dsxDocs.documentType = DOCUMENT_AND_KYC_NAME_MAP.containsKey(document.Description) 
            ? DOCUMENT_AND_KYC_NAME_MAP.get(document.Description) 
            : document.Title;
        dsxDocs.name = dsxDocs.documentType;
        
        processDocumentMapping(dsxDocs, document, applicationRecord, docTypeMap);
        dsxDocs.content = EncodingUtil.base64Encode(document.VersionData);
        
        document.VersionData = null;  // Free memory
        return dsxDocs;
    }
    
    /** 
     * @description Processes mapping for DSX document
     * @param dsxDocs DSX Document
     * @param document ContentVersion
     * @param applicationRecord Application record
     * @param docTypeMap Map
     */
    private void processDocumentMapping(AOB_DSXBean.Documents dsxDocs, ContentVersion document, Application__c applicationRecord, Map<String, String> docTypeMap) {
        if (document.Description == DESC_PROOF_OF_INCOME) {
            return;
        }
        
        String docType = docTypeMap.get(document.Description) == null ? docTypeMap.get(document.Title) : docTypeMap.get(document.Description) ;
        
        if (docType != null) {
            dsxDocs.name = docType;
            dsxDocs.documentType = docType;
            document.Description = docType;
            
            if (docType == DOC_TYPE_KYC_IDENTITY) {
                dsxDocs.documentExpiryDate = String.valueOf(applicationRecord.AOB_Identifii_Expire_Date__c);
            }
        }
    }
    
    /** 
     * @description Performs single HTTP callout for a batch
     * @param dsxBean DSX Bean
     * @param applicationRecord Application record
     * @return Response map
     */
    private Map<String, Object> performHttpCallout(AOB_DSXBean dsxBean, Application__c applicationRecord) {
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(dsxBean));
        try {
            Http http = new Http();
            
            if (Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }
            
            HttpResponse httpResponse = http.send(httpRequest);
            return processResponse(applicationRecord, httpResponse);
            
        } catch (Exception ex) {
            return handleException(ex);
        }
    }
    
    /**************************************************************************************
     * ERROR HANDLING AND RESPONSE PROCESSING METHODS
     **************************************************************************************/
    
    /** 
     * @description Handles exceptions
     * @param ex Exception
     * @return Error response map
     */
    private Map<String, Object> handleException(Exception ex) {
        logger.error('performHttpCallout: Unhandled exception', ex);
        return new Map<String, Object>{
            'status' => STATUS_FAILED, 
            ERROR_DESCR => ex.getMessage()
        };
    }
    
    /** 
     * @description Processes HTTP response
     * @param applicationRecord Application record
     * @param httpResponse Response
     * @return Processed map
     */
    private Map<String, Object> processResponse(Application__c applicationRecord, HttpResponse httpResponse) {
        Map<String, Object> errorResponse = handleErrorResponse(httpResponse, applicationRecord);
        if (errorResponse != null) {
            return errorResponse;
        }
        
        return processSuccessResponse(httpResponse);
    }
    
    /** 
     * @description Handles error responses
     * @param httpResponse Response
     * @param applicationRecord Application record
     * @return Error map or null
     */
    private Map<String, Object> handleErrorResponse(HttpResponse httpResponse, Application__c applicationRecord) {
        if (httpResponse.getStatusCode() != HTTP_STATUS_OK) {
            return handleNonOKStatusCode(httpResponse, applicationRecord);
        }
        
        return null;
    }
    
    /** 
     * @description Handles non-OK status
     * @param httpResponse Response
     * @param applicationRecord Application record
     * @return Error map
     */
    private Map<String, Object> handleNonOKStatusCode(HttpResponse httpResponse, Application__c applicationRecord) {
        String errorMessage = ERROR_NO_RESPONSE_SERVER;
        if (String.isBlank(httpResponse.getBody())) {
            return handleEmptyResponseBody(applicationRecord);
        } else if (!String.isBlank(httpResponse.getBody())) {
            Map<String, Object> responseParser = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseParser.get('moreInformation');
        } 
        
        logger.error('performHttpCallout: Failed with status ' + httpResponse.getStatusCode() + ': ' + errorMessage, applicationRecord.Id);
        
        return new Map<String, Object>{
            'status' => STATUS_FAILED,
            'statusCode' => httpResponse.getStatusCode(),
            ERROR_DESCR => errorMessage
        };
    }
    
    /** 
     * @description Handles empty body
     * @param applicationRecord Application record
     * @return Error map
     */
    private Map<String, Object> handleEmptyResponseBody(Application__c applicationRecord) {
        logger.error('performHttpCallout: Empty response body', applicationRecord.Id);
        
        return new Map<String, Object>{
            'status' => STATUS_FAILED,
            'statusCode' => HTTP_STATUS_NO_CONTENT,
            ERROR_DESCR => ERROR_NO_RESPONSE_BODY
        };
    }
    
    /** 
     * @description Processes success response
     * @param httpResponse Response
     * @return Success map
     */
    private Map<String, Object> processSuccessResponse(HttpResponse httpResponse) {
        String responseBody = httpResponse.getBody();
        AOB_DSXBean.Response docsResponseWrapper = (AOB_DSXBean.Response) JSON.deserialize(responseBody, AOB_DSXBean.Response.class);
        
        if (docsResponseWrapper == null || docsResponseWrapper.documents.isEmpty()) {
            return new Map<String, Object>{
                'status' => STATUS_FAILED,
                ERROR_DESCR => ERROR_DOCUMENT_UPLOAD_FAILED
            };
        }
        
        return validateDocumentResponses(docsResponseWrapper);
    }
    
    /** 
     * @description Validates document responses
     * @param docsResponseWrapper Wrapper
     * @return Validation map
     */
    private Map<String, Object> validateDocumentResponses(AOB_DSXBean.Response docsResponseWrapper) {
        for (AOB_DSXBean.ResponseDocuments documentResponse : docsResponseWrapper.documents) {
            if (documentResponse.reasonCode == REASON_CODE_SUCCESS) {
                Map<String, Object> successResponse = new Map<String, Object>{'status' => STATUS_SUCCESS};
                
                if (Test.isRunningTest()) {
                    successResponse.put('statusCode', documentResponse.status);
                    successResponse.put('reasonDescription', documentResponse.reasonDescription);
                }
                
                return successResponse;
            }
        }
        
        return new Map<String, Object>{
            'status' => STATUS_FAILED,
            ERROR_DESCR => ERROR_DOCUMENT_UPLOAD_FAILED
        };
    }
    
    /**************************************************************************************
     * HELPER METHODS
     **************************************************************************************/
    
    /** 
     * @description Creates verification record
     * @param applicationRecord Application record
     * @param responseObject Response
     */
    private void createVerification(Application__c applicationRecord, Map<String, Object> responseObject) {
        Verification__c verificationInstance = new Verification__c(
            Application__c = applicationRecord.Id,
            Verification_Source__c = VERIFICATION_SOURCE_DSX,
            AOB_DSX_Response__c = JSON.serialize(responseObject)
        );
        
        verificationInstance.Verification_Status__c = (responseObject != null && responseObject.get('status') == STATUS_FAILED) 
            ? VERIFICATION_STATUS_FAILED 
            : VERIFICATION_STATUS_SUCCESS;
        
        createVerificationRecord(verificationInstance);
    }
    
    /** 
     * @description Sends welcome pack email always (if welcomePackDocList not empty; regardless of callout status)
     * @param applicationList Applications
     */
    private void sendWelcomePackIfNeeded(List<Application__c> applicationList) {
        if (!welcomePackDocList.isEmpty()) {
            AOB_Email_send.sendWelcomePack(applicationList, welcomePackDocList);
            welcomePackDocList.clear();  // Free memory
        }
    }
}