/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_DSX
@ Description       :Regular DSX implementation extending base (synchronous batch processing)
@ Last Modified By  :Optimization 
@ Last Modified On  :14-10-2025
@ Modification Description : Removed async; uses base for single PDF gen and batch callouts; email sent once
*****************************************************************************************
@ last Modified By  :Jagadish Thummala
@ last Modified On  :9/1/2026
@ user story : SFP-60131
@ Modification Description : Added Taxonomy for Admin Photos and Account Maintenance
***************************************************************************************/
public without sharing class AOB_DSX extends AOB_DSX_Base {

    // National ID Constants (same as AOB_Internal_DSX for consistency)
    private static final Set<String> NATIONAL_ID_FILES = new Set<String>{
        'National ID 01', 'National ID 02'
    };
    
    // Singleton Instance
    private static AOB_DSX instance;
    
    // Test Variables - Local to this class
    @TestVisible
    private static Integer mockHttpStatusCode;
    @TestVisible
    private static String mockHttpStatus;
    @TestVisible
    private static String mockHttpBody = '';
    
    public static List<ContentVersion> welcomePackDocList {
        get {
            if (instance == null) {
                instance = new AOB_DSX();
            }
            return instance.welcomePackDocList;
        }
        private set;
    }
    
    public static Map<String, Object> responseToReturnObject;
    
    /**************************************************************************************
     * CONSTRUCTOR
     **************************************************************************************/
    
    public AOB_DSX() {
        super();  // Calls base constructor to initialize logger
    }
    
    /**************************************************************************************
     * PUBLIC STATIC METHODS
     **************************************************************************************/
    
    /** 
     * @description Static entry point for DSX callout (regular flow; synchronous batching)
     * @param applicationList List of Application records
     * @param productList List of Product records
     * @return Serialized callout response
     */
    public static String invokeDsxCallout(List<Application__c> applicationList, List<Product2> productList) {
        if (instance == null) {
            instance = new AOB_DSX();
        }
        
        // Set mock values for testing (propagate to base)
        AOB_DSX_Base.mockHttpStatusCode = AOB_DSX.mockHttpStatusCode;
        AOB_DSX_Base.mockHttpStatus = AOB_DSX.mockHttpStatus;
        AOB_DSX_Base.mockHttpBody = AOB_DSX.mockHttpBody;
        
        return instance.invokeDsxCallout(applicationList, productList);
    }
    
    /**************************************************************************************
     * ABSTRACT METHOD IMPLEMENTATIONS
     **************************************************************************************/
    
    /** 
     * @description Gets logger name for AOB_DSX
     * @return Logger name string
     */
    protected override String getLoggerName() {
        return 'AOB_DSX';
    }
    
    /** 
     * @description Retrieves additional content documents from application (regular flow)
     * @param applicationRecord Application record
     * @return List of additional ContentVersions
     */
    protected override List<ContentVersion> getAdditionalContentDocuments(Application__c applicationRecord) {
        List<ContentVersion> additionalDocs = new List<ContentVersion>();
        List<ContentDocumentLink> cDocLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationRecord.Id);
        
        if (cDocLinks.isEmpty()) {
            return additionalDocs;
        }
        
        Set<Id> contentDocumentIds = extractContentDocumentIds(cDocLinks);
        List<ContentVersion> contentVersions = new SEL_ContentVersion().selectContentVersionByContentDocListLatest(contentDocumentIds);
        
        if (contentVersions != null && !contentVersions.isEmpty()) {
            additionalDocs.addAll(contentVersions);
            welcomePackDocList.addAll(contentVersions);
        }
        
        return additionalDocs;
    }
    
    /** 
     * @description Builds document type mapping for regular flow
     * @return Map of title/description to document type
     */
    protected override Map<String, String> buildDocumentTypeMapping() {
        Map<String, String> docMapping = new Map<String, String>{
            DESC_SIGNATURE_FILE => DOC_TYPE_MANDATES_SIGNATURE,
            DESC_MANDATES_SIGNATURE => DOC_TYPE_MANDATES_SIGNATURE,
            DESC_SELFIE_IMAGE => DOC_TYPE_ACCOUNT_ADMIN_PASSPORT,
            DESC_ID_FRONT => DOC_TYPE_KYC_IDENTITY,
            DESC_ID_BACK => DOC_TYPE_KYC_RESIDENCE,
            DESC_ADMISSION_LETTER => DOC_TYPE_KYC_EMPLOYMENT,
            DESC_KYC_IDENTITY => DOC_TYPE_KYC_IDENTITY,
            DESC_KYC_RESIDENCE => DOC_TYPE_KYC_RESIDENCE,
            DESC_FACE_IMAGE_IDV => DOC_TYPE_ACCOUNT_ADMIN_PASSPORT
        };

        // Add flexible National ID patterns with common extensions (exact + case-insensitive)
        List<String> commonExts = new List<String>{'', '.pdf', '.PDF', '.jpg', '.JPG', '.jpeg', '.JPEG', '.png', '.PNG'};
        
        for (String baseName : NATIONAL_ID_FILES) {
            String docType = (baseName.startsWith('National ID 01')) ? DOC_TYPE_KYC_IDENTITY : DOC_TYPE_KYC_RESIDENCE;
            
            for (String ext : commonExts) {
                docMapping.put(baseName + ext, docType);
                docMapping.put(baseName.toLowerCase() + ext.toLowerCase(), docType);
            }
        }

        return docMapping;
    }
    
    /** 
     * @description Creates verification record using regular flow controller
     * @param verificationInstance Verification record
     */
    protected override void createVerificationRecord(Verification__c verificationInstance) {
        // Use regular flow controller or direct insert
        UG_AOB_PPB_FlowController.createVerificationWithInstance(verificationInstance); 
    }
    
    /** 
     * @description Gets count of additional content documents without loading
     * @param applicationRecord Application record
     * @return Integer count
     */
    protected override Integer getAdditionalContentDocumentsCount(Application__c applicationRecord) {
        List<ContentDocumentLink> cDocLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationRecord.Id);
        if (cDocLinks.isEmpty()) {
            return 0;
        }
        
        Set<Id> contentDocumentIds = extractContentDocumentIds(cDocLinks);
        List<AggregateResult> counts = [SELECT COUNT(Id) total FROM ContentVersion 
                                        WHERE ContentDocumentId IN :contentDocumentIds 
                                        AND IsLatest = true 
                                        WITH USER_MODE];
        return (Integer) (counts.isEmpty() ? 0 : counts[0].get('total'));
    }
}