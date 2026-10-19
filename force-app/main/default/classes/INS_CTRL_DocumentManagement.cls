/**
 * @description :
 * @author : Dhiraj Prajapti
 *
 * @group : Common
 * @last modified on : 11-18-2024
 * @last modified by : Jaco de Lange
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|

 THIS CODE IS CONTROLLED BY THE INSURANCE TEAM
 For any changes requied please contact the Insurance team.
**/
public with sharing class INS_CTRL_DocumentManagement {

    @AuraEnabled(cacheable=true)
    public static Boolean hasAccessToDocumentManagment() {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        try {
            assignments = [
                SELECT
                    Id
                FROM
                    PermissionSetAssignment
                WHERE
                    AssigneeId =: UserInfo.getUserId()
                AND
                    PermissionSet.Name = 'Custom_Document_Upload_Access'
            ];
            // Return true if the list is not empty, meaning the user has the permission set
        }
        catch (Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
        return !assignments?.isEmpty();
    }

    /** 
     * Get all ContentVersion related to recordId
     *
     * @param recordId
     *
     * @return List<File> - wrapper class list
     */
    @AuraEnabled
    public static List<INS_UTIL_File> getRelatedDocuments(Id recordId) {
        List<INS_UTIL_File> files = new List<INS_UTIL_File>();
        Map<Id, Document_Upload_Configuration__mdt> allTaxonomies = new Map<Id, Document_Upload_Configuration__mdt>(
            Document_Upload_Configuration__mdt.getAll().values()
        );
        try {
            // to get document guid/link to document in external system
            Set<Id> documents = new Set<Id>();
            //Find links between record & document
            for (
                ContentDocumentLink cdl :
                new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntity(new List<Id>{recordId})
            ) {
                documents.add(cdl.ContentDocumentId);
            }
            //Use links to get attachments
            for(ContentVersion cv : new SEL_CMN_ContentVersion().getContentVersions(documents)) {
                String documentName = '';
                if (allTaxonomies.containsKey(cv.Document_Type_Id__c)) {
                    documentName = allTaxonomies.get(cv.Document_Type_Id__c)?.MasterLabel;
                }
                files.add(new INS_UTIL_File(cv).setRecordId(recordId).setDocumentName(documentName));
            }
        }
        catch(Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
        return files;
    }

    /**
     * Delete ContentVersion
     *
     * @param recordId
     *
     * @return Void
     */
    @AuraEnabled
    public static Void deleteDocument(Id recordId) {
        try {
            if (Schema.sObjectType.ContentDocument.isDeletable()){
                delete new ContentDocument(Id = recordId);
            }
        }
        catch(Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * Update Title, DocumentType__c and, Document_Type_Id__c on ContentVersion
     * based on user selection
     *
     * @param File - wrapper class
     *
     * @return ContentVersion
     */
    @AuraEnabled
    public static ContentVersion updateContentVersion(INS_UTIL_File file) {
        ContentVersion contentVersion;
        Map<Id, Document_Upload_Configuration__mdt> allTaxonomies = new Map<Id, Document_Upload_Configuration__mdt>(
            Document_Upload_Configuration__mdt.getAll().values());
        try {
            contentVersion = new ContentVersion(
            Title = file.getTitle(),
            Id = file.getContentVersionId(),
            Document_Type_Id__c = file.getDocumentTypeId(),
            Document_Name__c = allTaxonomies.get(file.getDocumentTypeId())?.MasterLabel);
            if (Schema.sObjectType.ContentVersion.isUpdateable()){
                update contentVersion;
            }
        }
        catch(Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
        return contentVersion;
    }

    /**
     * Uploads the current `File` to an external document repository.
     *
     * This method locates the class that implements the `DocumentManagement` class
     * and invokes its `send` method to perform the upload.
     *
     * @param recordId - current Record Id
     * @param uniqueId - Unique Identifier to locate the implementation record
     * @param file - wrapper class
     *
     * @return DocumentInfo
     */
    @AuraEnabled
    public static INS_UTIL_DocumentInfo upload(Id recordId, String uniqueId, INS_UTIL_File file) {
        INS_UTIL_DocumentInfo info;
        try {
            String objectAPIName = recordId.getSObjectType().getDescribe().getName();
            Document_Management_Implementation__mdt mdt = new Document_Management_Implementation__mdt();
            mdt = new SEL_DocumentImplementation().getImplementation(objectAPIName, uniqueId);

            Type instanceType = Type.forName(mdt?.Class_Name__c);
            Object classInstance = instanceType.newInstance();

            INS_UTIL_DocumentManagement documentManager = (INS_UTIL_DocumentManagement) classInstance;
            documentManager.setFile(file);
            info = documentManager.send();
        }
        catch (Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
        return info;
    }
    /**
     * Uploads the current `File` to an external document repository.
     *
     * This method locates the class that implements the `DocumentManagement` class
     * and invokes its `send` method to perform the upload.
     *
     * @param objectAPIName
     * @param file
     *
     * @return DocumentInfo
     */
    @AuraEnabled
    public static INS_UTIL_DocumentInfo uploadRelatedDoc(String objectAPIName, INS_UTIL_File file) {
        INS_UTIL_DocumentInfo info;
        try {
            Document_Management_Related_Object__mdt mdt = new Document_Management_Related_Object__mdt();
            mdt = new SEL_DocumentImplementation().getRelatedObjImplementation(objectAPIName);

            Type instanceType = Type.forName(mdt?.Class_Name__c);
            Object classInstance = instanceType.newInstance();

            INS_UTIL_DocumentManagement documentManager = (INS_UTIL_DocumentManagement) classInstance;
            documentManager.setFile(file);
            info = documentManager.send();

        }
        catch (Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
        return info;
    }

     /**
     * Get all ContentVersion from related object for recordId
     *
     * @param claimInsuranceId
     * @param sObjectName
     *
     * @return ContentVersions
     */
    @AuraEnabled
    public static List<ContentVersion> relatedObjectFiles(Id claimInsuranceId, string sObjectName) {
        List<Id> cIds = new List<Id>();
        Set<Id> documents = new Set<Id>();
        Map<Id, String> cdlMap = new Map<Id, String>();
        List<ContentVersion> cvUpdate = New List<ContentVersion>();

        try {
            SObjectType objectType = claimInsuranceId.getSObjectType();
            String stringObjectName = String.valueOf(ObjectType);

           switch on stringObjectName{
                when 'Claim' {
                    for (Case c : new SEL_Case().selectCasesByClaimId(claimInsuranceId)){
                        cIds.add(c.Id); 
                   }
                }
                when 'InsurancePolicy' {
                    for (Case c : new SEL_Case().selectCasesByPolicyId(claimInsuranceId)){
                        cIds.add(c.Id); 
                    }
                }
            }

            if (cIds.isEmpty()){
                throw new IllegalArgumentException('There are no linked cases for this record.');
            }
           
            for (ContentDocumentLink cdl :
                    new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntity(cIds)) {
                    documents.add(cdl.ContentDocumentId);
                    cdlMap.put(cdl.ContentDocumentId, cdl.LinkedEntity.Name);
            }

            for (ContentVersion cv : new SEL_CMN_ContentVersion().getContentVersions(documents)) {
                if (cdlMap.containsKey(cv.ContentDocumentId)) {
                    cvUpdate.add(
                    new ContentVersion(Id=cv.Id, Linked_Entity_Identifier__c=cdlMap.get(cv.ContentDocumentId)));
                }
            }
            update cvUpdate;
        }
        catch (Exception ex) {
            Throw new AuraHandledException(ex.getMessage());
        }
        return new SEL_CMN_ContentVersion().getContentVersions(documents); 
    }
}