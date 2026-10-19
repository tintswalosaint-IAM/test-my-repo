/**
 * @description : Helper class to prepare record data for processing
 * @author : Jaco de Lange
 * @last modified on  : 11-11-2024
**/
public with sharing class INS_UTIL_DocumentManagementHelper {

     /**
     * This method will prepare the relevant object info
     * @actions - query sobject type with recordId
     * @param - recordId
     * @return - Map of claim, case and policy number
     */
    public RecordInfo getRecord(Id recordId) {
        SObjectType objectType = recordId.getSObjectType();
        RecordInfo info;
        switch on objectType.newSObject() {
            when Claim claimType {
                Claim claim = new SEL_Claim().selectClaimById(recordId)?.get(0);
                info = new RecordInfo('ClaimNumber', claim.Name, claim.Account.CMN_CustomerBPID__pc);
                info.setIdNumber(claim.Account.CMN_IdentityNumber__pc);
                info.setSurname(claim.Account.LastName);
                info.setInitials(claim.Account.Initials__c);
                info.setRecordType(claim.Account.RecordTypeId);
            }
            when Case caseType {
                Case currentCase = new SEL_Case().selectCaseById(recordId)?.get(0);
                info = new RecordInfo('CaseNumber', currentCase.CaseNumber, currentCase.Account.CMN_CustomerBPID__pc);
                info.setIdNumber(currentCase.Account.CMN_IdentityNumber__pc);
                info.setSurname(currentCase.Account.LastName);
                info.setInitials(currentCase.Account.Initials__c);
                info.setRecordType(currentCase.Account.RecordTypeId);
            }
            when InsurancePolicy policyType {
                InsurancePolicy insuranePolicy = new SEL_InsurancePolicy().selectInsurancePolicyById(recordId)?.get(0);
                info = new RecordInfo('PolicyNumber', insuranePolicy.Name, insuranePolicy.NameInsured.CMN_CustomerBPID__pc);
                info.setIdNumber(insuranePolicy.NameInsured.CMN_IdentityNumber__pc);
                info.setSurname(insuranePolicy.NameInsured.LastName);
                info.setInitials(insuranePolicy.NameInsured.Initials__c);
                info.setRecordType(insuranePolicy.NameInsured.RecordTypeId);
            }
        }
        return info;
    }

     /**
     * This method will prepare the relevant taxonomy record info
     * @actions - fetch taxonomy record
     * @param - taxonomy id
     * @return - taxonomy record
     */
    public INS_UTIL_Taxonomy getTaxonomy(Id taxonomyId) {
        Document_Upload_Configuration__mdt config = Document_Upload_Configuration__mdt.getInstance(taxonomyId);
        if (config == null) {
            return null;
        }
        INS_UTIL_Taxonomy tax = new INS_UTIL_Taxonomy(
            config.Claim_Document_Name__c,
            config.Entity_Type__c,
            config.BPID__c,
            config.Document_Type_Id__c
        );
        if (config?.Params_to_Exclude__c != null && String.isNotBlank(config?.Params_to_Exclude__c)) {
            tax.setParamsToExclude(config?.Params_to_Exclude__c);
        }
        return tax;
    }

    /**
     * This method will get the file upload attributes
     * @actions - fetch taxonomy record
     * @param - file
     * @param - taxonomy
     * @return - payload structure
     */
    public String getPayLoad(INS_UTIL_File file, INS_UTIL_Taxonomy taxonomy) {

        //Get the content version data from doc id
        List<ContentVersion> versions = new SEL_CMN_ContentVersion().selectCVByIds(
            new List<String>{file.getContentVersionId()}
        );

        Map<Id, ContentVersion> contentVersionData = new Map<Id, ContentVersion>(versions);
        Blob fileData = contentVersionData.get(file.getContentVersionId())?.VersionData;

        return this.preparePayload(file, taxonomy, fileData);
    }

     /**
     * This method will prepare the final api payload
     * @actions - fetch taxonomy record
     * @param - file
     * @param - taxonomy
     * @param - file data
     * @return - serialised api payload structure
     */
    public String preparePayload(INS_UTIL_File file, INS_UTIL_Taxonomy taxonomy, Blob fileData) {
        if (file == null || file.getContentVersionId() == null || taxonomy == null) {
            return null;
        }
        RecordInfo info = this.getRecord(file.getRecordId());

        INS_UTIL_DocumentRequest request = new INS_UTIL_DocumentRequest();
        request.setDocumentInfo(file, fileData);
        request.setDocumentIdentification(taxonomy);

        if ( String.isNotBlank(taxonomy.getParamsToExclude()) &&
            !taxonomy.getParamsToExclude().containsIgnoreCase(info.key)) 
        {
            request.setDocumentIdentification(info.key, info.value);
        }
        else if (String.isBlank(taxonomy.getParamsToExclude())) 
        {
            request.setDocumentIdentification(info.key, info.value);
        }
            request.setDocumentIdentification('Initials', info.initials);

        if (String.isNotBlank(info.surname)) {
            request.setDocumentIdentification('Surname', info.surname.toUpperCase());
        }
        request.setDocumentIdentification('BPID', info.bpid);
        request.setDocumentIdentification('IDNUM', info.idNumber);

        return request.serializeDocument(request.info);
    }

    @TestVisible
    private class RecordInfo {

        private final String key;
        private final String value;
        private final String bpid;
        private String idNumber;
        private String surname;
        private String initials;
        private Id recordTypeId;

        public RecordInfo(String key, String value, String bpid) {
            this.key = key;
            this.value = value;
            this.bpid = bpid;
        }

        public RecordInfo setIdNumber(String idNumber) {
            this.idNumber = idNumber;
            return this;
        }

        public RecordInfo setSurname(String surname) {
            this.surname = surname;
            return this;
        }

        public RecordInfo setInitials(String initials) {
            this.initials = initials;
            return this;
        }

        public Void setRecordType(Id recordTypeId) {
            this.recordTypeId = recordTypeId;
        }

    }
}