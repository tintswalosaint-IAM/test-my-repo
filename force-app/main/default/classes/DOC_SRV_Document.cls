/**
* This class is used as a service class for all operations related with Open Application
*
* <p>DBP-1874</p>
*
* @author Maryem Bourhi (mbourhi@salesforce.com)
*
* @date Jan 11th 2021
*/
public without sharing class DOC_SRV_Document {
    /**
* @description Updates Custom Object Document with master content doc link
*/ 
    public static void updateDocuments(Map<id, id> contentDocMap) {
        List<DOC_Document__c> docs = [
            SELECT id, DOC_MasterContentId__c
            FROM DOC_Document__c
            WHERE id IN :contentDocMap.keySet()
        ];
        for (DOC_Document__c doc : docs) {
            doc.DOC_MasterContentId__c = contentDocMap.get(doc.id);
        }
        update docs;
    }
    
    /**
* @description calls an api with document information
*/
    public static void syncFileNet(Id document) {
        DOC_API_FilenetNotification customerServiceCall = new DOC_API_FilenetNotification(
            document
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(DOC_API_FilenetNotification.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        DOC_API_FilenetNotification.DTO_Response result = (DOC_API_FilenetNotification.DTO_Response) customerServiceCall.baseResponseDTO;
    }
    
    /**
* @description calls a queue to sync files
*/
    @InvocableMethod(
        Label='FileNet Notification API'
        Description='call SBG API to notify of document'
    )
    public static void notifyFileNet(List<id> documents) {
        ID jobID;
        try {
            CMN_UTIL_Logger.error('notifyFileNet','DOC_API_FilenetNotification');

            jobId = Database.executeBatch(new DOC_BATCH_SyncDocuments(documents), 1);
        } catch (Exception error) {
            CMN_UTIL_Logger.error(
                error,
                'DOC_SRV_Document.notifyFileNet Queuable ' + jobID
            );
        }
    }
    
    /**
* @description This Methods Uploads documennts
* @return   the list of the documents created (DOC_Document__c)
*/
    public static List<DOC_Document__c> uploadDocuments(
        String documentsString,
        Id applicationId
    ) {
        Map<id,id> contentDocMap = new Map<id,id>();//Map to create 1:1 relation between DOC_Document__c and ContentDocumentLink
        List < Object > documents = (List < Object > ) System.JSON.deserializeUntyped(documentsString);
        ContentVersion cv;
        ContentDocumentLink cdl;
        Map < String, DOC_Document__c > codeToDocumentMap = new Map < String, DOC_Document__c > ();
        Map < String, ContentVersion > codeToContentVersionMap = new Map < String, ContentVersion > ();
        List < ContentDocumentLink > documentLinksToInsert = new List < ContentDocumentLink > ();
        List < DOC_ConditionKey__c > conditionsToInsert = new List < DOC_ConditionKey__c > ();
        Map < Id, Id > contentVersionIdToDocumentIdMap = new Map < Id, Id > ();
        DOC_Document__c doc;
        Map < String, Object > currentFileDetails;
        if (documents == null || documents.isEmpty()) {
            AuraHandledException customException = new AuraHandledException('Documents string is empty or bad json');
            throw customException;
        } else {
            for (Object eachDocInfo: documents) {
                currentFileDetails = (Map < String, Object > ) eachDocInfo;
                doc = new DOC_Document__c();
                doc.DOC_FileExtension__c = (String) currentFileDetails.get('fileExtension');
                doc.AOB_Application__c = applicationId;
                doc.DOC_ConditionDescription__c = (String) currentFileDetails.get('conditionDescription');
                doc.DOC_ConditionCode__c = (String) currentFileDetails.get('conditionCode');
                doc.Name = (String) currentFileDetails.get('conditionDescription');
                codeToDocumentMap.put(doc.DOC_ConditionCode__c, doc);
            }
            //Insert AOB_Document__c records
            insert codeToDocumentMap.values();
            String fullFileName;
            DOC_ConditionKey__c condition;
            for (Object eachDocInfo: documents) {
                currentFileDetails = (Map < String, Object > ) eachDocInfo;
                Map < String, Object >  conditionDetails = (Map < String, Object > ) currentFileDetails.get('conditionKey');
                if(conditionDetails != null){
                    condition = new DOC_ConditionKey__c();
                    condition.DOC_Document__c = codeToDocumentMap.get((String) currentFileDetails.get('conditionCode')).Id;
                    condition.DOC_itemGuid__c = (String)conditionDetails.get('itemGuid');
                    condition.DOC_PartnerFunction__c = (String)conditionDetails.get('partnerFunction');
                    condition.DOC_recordId__c = (String)conditionDetails.get('recordId');
                    conditionsToInsert.add(condition);
                }
                cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode((String) currentFileDetails.get('fileData'));
                fullFileName = (String) currentFileDetails.get('fileName');
                cv.Title = fullFileName.substring(0, fullFileName.lastIndexOf('.'));
                cv.PathOnClient = fullFileName;
                codeToContentVersionMap.put((String) currentFileDetails.get('conditionCode'), cv);
            }
            //Insert condition key records
            if(!conditionsToInsert.isEmpty()){
                insert conditionsToInsert;
            }
            //Insert ContentVersion records
            insert codeToContentVersionMap.values();
            for (String eachCode: codeToContentVersionMap.keySet()) {
                contentVersionIdToDocumentIdMap.put(codeToContentVersionMap.get(eachCode).Id, codeToDocumentMap.get(eachCode).Id);
            }
            for (ContentVersion eachContentVersion: [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionIdToDocumentIdMap.keySet()]) {
                cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = eachContentVersion.ContentDocumentId;
                cdl.LinkedEntityId = contentVersionIdToDocumentIdMap.get(eachContentVersion.Id);
                cdl.ShareType = 'I';
                documentLinksToInsert.add(cdl);
                contentDocMap.put(cdl.LinkedEntityId,eachContentVersion.id); // Ayoub added this
            }
            //Insert ContentDocumentLink records
            if(!documentLinksToInsert.isEmpty()){
                insert documentLinksToInsert;
            }
            updateDocuments(contentDocMap);
            return codeToDocumentMap.values();
        }
    }
    /**
* @description Create documents case
* @return   the new created case
*/
    public static Case createDocumentsCase(Id applicationId) {
        return AOB_Utils.createCase('DOCUMENT', applicationId, true);
    }
    /**
* @description Create documents case
* @return   the new created case
*/
    public static void assignCaseToQueue(
        String context,
        Id caseId,
        Id applicationId
    ) {
        AOB_Utils.assignCaseToQueue(context, caseId, applicationId);
    }
    /**
* @description Add documents to the parent case
* @return   the new documents records (DOC_Document__c)
*/
    public static List<DOC_Document__c> addDocumentsToCase(
        Id caseId,
        List<DOC_Document__c> createdDocuments
    ) {
        for (DOC_Document__c eachDoc : createdDocuments) {
            eachDoc.DOC_Case__c = caseId;
        }
        update createdDocuments;
        return createdDocuments;
    }
    /**
* @description Create legal options case if condition is met
* @return   the new created case
*/
    public static Case createLegalOptionsCase(Id applicationId) {
        Case createdCase;
        List<Account> accounts = [
            SELECT AOB_ProminentInfluentialPerson__c
            FROM Account
            WHERE
            Id IN (
                SELECT AOB_Customer__c
                FROM AOB_Application__c
                WHERE Id = :applicationId
            )
        ];
        if (!accounts.isEmpty()) {
            if (accounts.get(0).AOB_ProminentInfluentialPerson__c) {
                createdCase = AOB_Utils.createCase(
                    'ComplianceCondition',
                    applicationId,
                    true
                );
            }
        }
        return createdCase;
    }
}