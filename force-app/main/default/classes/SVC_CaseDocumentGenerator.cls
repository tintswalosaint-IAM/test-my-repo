/**
 * @description SFP-5420 - Case Transcript Document Generator class
 *
 * @author Raman Bazyleu
 *
 * @date Sep 24th 2021
 */
public without sharing class SVC_CaseDocumentGenerator {

    private static final String DOCUMENT_GENERATED = 'Document was generated';
    private static final String DOCUMENT_NOT_GENERATED = 'Document was not generated';
    private static final String DOCUMENT_ALREADY_EXIST = 'Document already Exist';
    private static final String INCOME_PARAMS_INVALID = 'Incoming params are invalid';
    private static final String TRANSCRIPT_BODY_EMPTY = 'Conversation is Empty...';

    /**
     * Generate content document based on the transctipt record and case Id
     * @param caseId - based on that variable the actual file will be generated
     * @return resultMessage - shows the result of the operation
	*/    
    @AuraEnabled
    public static String createCaseDocumentBasedOnTranscript(String caseId) {
        
        if(String.isEmpty(caseId)) {
            return INCOME_PARAMS_INVALID;
        }
        
        String resultMessage = DOCUMENT_NOT_GENERATED;
        LiveChatTranscript relatedTranscript = getRelatedTranscript(caseId);

        if(relatedTranscript != null) {
            if(isDocumentAlreadyExist(getCaseNumberForCase(caseId) + '_' + relatedTranscript.Name, caseId)) {
                resultMessage = DOCUMENT_ALREADY_EXIST;
            } else {
                generateContentDocument(relatedTranscript, caseId);
                resultMessage = DOCUMENT_GENERATED;
            }
        }
        
        return resultMessage;
    }

    /**
     * return case number for the provided case Id
     * @param caseId
     * @return caseNumberResult - return case number related to the case
	*/     
    private static String getCaseNumberForCase(String caseId) {
        
        String caseNumberResult = '';

        List<Case> cases = [
            SELECT Id, CaseNumber 
            FROM Case 
            WHERE Id =: caseId
        ];

        if(!cases.isEmpty()) {
            caseNumberResult = cases[0].CaseNumber;
        }

        return caseNumberResult;
    }
    
    /**
     * generation of the content document based on the transcript record and case Id
     * @param transcript - related to the case latest transcript record
     * @param caseId - case to attach document to
	*/      
    private static void generateContentDocument(LiveChatTranscript transcript, String caseId) {
        try {

            String title = getCaseNumberForCase(caseId) + '_' + transcript.Name;
			String transcriptBody = String.isEmpty(transcript.Body) ? TRANSCRIPT_BODY_EMPTY : transcript.Body;
            
            ContentVersion contentVersion1 = new ContentVersion(
                Title = title,
                PathOnClient = title + '.pdf',
                VersionData = Blob.toPDF(transcriptBody), 
                origin = 'H',
                IsMajorVersion = true
            );

            insert contentVersion1;
    
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion1.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink(
                LinkedEntityId = caseId,
                ContentDocumentId = conDoc,
                shareType = 'V'
            );

            insert conDocLink;
        } catch (Exception ex) {
            system.debug(ex);
        }   
    }

    /**
     * Check if Document with the provided name is already exist
     * @param documentName - document name to check if it's exist
     * @param parentId - content document parent object id
     * @return result - result of the check if the document is exist already
	*/
    private static Boolean isDocumentAlreadyExist(String documentName, String parentId) {
        Boolean result = false;
        
        if(!String.isEmpty(documentName) && !String.isEmpty(parentId)) {
            Integer attachmentSize = [
                SELECT count()
                FROM ContentDocument 
                WHERE PublishStatus = 'P'
                    AND Title =: documentName
            ];
            
            if(attachmentSize > 0) {
                result = true;
            }
        }

        return result;
    }
    
    /**
	* return latest related LiveChatTranscript record based on the caseId 
	* @param caseId - case id
	* @return LiveChatTranscript - latest relevant transcript record related to the case
	*/
    private static LiveChatTranscript getRelatedTranscript(String caseId) {
        LiveChatTranscript resultTranscript = null;
        
        if(!String.isEmpty(caseId)) {
            List<LiveChatTranscript> relatedTranscripts = [
  				SELECT Id, Name, Body, Status 
             	FROM LiveChatTranscript
                WHERE Status = 'Completed'
                	AND CaseId = :caseId
                Order by CreatedDate desc
                LIMIT 1
            ];
            
            if(!relatedTranscripts.isEmpty()) {
               resultTranscript = relatedTranscripts[0];
            }
    	}
        
        return resultTranscript;
    }
}