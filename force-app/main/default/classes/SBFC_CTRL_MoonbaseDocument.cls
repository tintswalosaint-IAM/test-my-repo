/**
 * @description       : SFP-55759 - Controller class for the Moonstone Disclosure feature.
 *                      Handles disclosure generation, document storage, Lead-Account linking, and retrieval of disclosure details.
 * author             : Gigyasu Jain
 * @group             : SBFC
 * @last modified on  : 08-07-2026
 * @last modified by  : Gigyasu Jain
**/


public with sharing class SBFC_CTRL_MoonbaseDocument {
    
    // Logger Constant
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_CTRL_MoonbaseDocument.class.getName());
    
    // Record Type Constant
    private static final String PERSON_ACCOUNT_RECORD_TYPE = 'Person Account - Prospect';
    
    // Valid Disclosure Stages
    private static final Set<String> VALID_DISCLOSURE_STAGES = new Set<String>{
        'In Progress – Awaiting Signed Disclosure',
        'In Progress - Appointment Set',
        'In Progress - Fact Finding',
        'In Progress - Putting a Plan Together'
    };


        /**
 * @description Returns the Record Type Id for the Person Account - Prospect
 *              Account Record Type.
 *
 * @author Gigyasu
 * @return Id Person Account Record Type Id.
 * @throws AuraHandledException if the Record Type cannot be found or an unexpected error occurs.
 */
@AuraEnabled(cacheable=true)
public static Id getAccountRecordType() {

    try {

        Schema.RecordTypeInfo recordTypeInfo =
            Schema.SObjectType.Account
                .getRecordTypeInfosByName()
                .get(PERSON_ACCOUNT_RECORD_TYPE);

        if (recordTypeInfo == null) {
            throw new AuraHandledException('Record Type "' + PERSON_ACCOUNT_RECORD_TYPE + '" was not found.');
        }

        return recordTypeInfo.getRecordTypeId();

    } catch (Exception e) {
         LOGGER.error(e.getMessage(),new String[] { SBFC_CTRL_MoonbaseDocument.class.getName(),e.getMessage()},e);
         throw new AuraHandledException(e.getMessage());
    }
}
        

        /**
 * @description Creates or reuses an existing InfoAuthorizationRequest for the
 *              Lead's related Account, uploads the generated Moonstone
 *              Disclosure PDF, links it to the InfoAuthorizationRequest,
 *              and creates a Chatter FeedItem.
 * @author Gigyasu
 * @param leadId Lead Id associated with the disclosure.
 * @param base64Pdf Base64 encoded PDF returned from Moonstone.
 */
public static void savePdfToLead(Id leadId, String base64Pdf,String responseJson) {

    try {

        if (String.isBlank(base64Pdf)) {
            return;
        }

        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Lead.');
        }
        
        Lead lead = new SEL_Lead().selectLeadByLeadId(leadId);
        
        Account account = getRelatedAccount(lead);
        
        if (account == null) {
            return;
        }

        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();

        ContentVersion insertedCv = createContentVersion(account, base64Pdf);
        
        uow = ORG_Application.unitOfWork.newInstance();

        if (!Schema.sObjectType.InfoAuthorizationRequest.isAccessible()) {
            throw new AuraHandledException('Insufficient access to InfoAuthorizationRequest.');
        }

        InfoAuthorizationRequest infoAuthReq = new SEL_InfoAuthorizationRequest().selectBySourceRecordId(account.Id);
        Boolean isNewInfoAuthReq = (infoAuthReq == null);

        if (isNewInfoAuthReq) {

            if (!Schema.sObjectType.InfoAuthorizationRequest.isCreateable()) {
                throw new AuraHandledException('Insufficient access to create InfoAuthorizationRequest.');
            }
        
            infoAuthReq = SBFC_Utils.createDisclosureInfoAuthorizationRequest(account);
        
            Integer maxLength =
                InfoAuthorizationRequest.SBFC_Moonstone_Response__c
                    .getDescribe()
                    .getLength();
        
            infoAuthReq.SBFC_Moonstone_Response__c = SBFC_API_MoonbaseDocument.abbreviate(responseJson,maxLength);
        
            uow.registerNew(infoAuthReq);
        
        } else {

            if (!Schema.sObjectType.InfoAuthorizationRequest.isUpdateable()) {
                throw new AuraHandledException('Insufficient access to update InfoAuthorizationRequest.');
            }

            infoAuthReq.Name = account.Name + ' Moonstone Disclosure';
            infoAuthReq.RequesterId = UserInfo.getUserId();

            uow.registerDirty(infoAuthReq);
        }

        createDisclosureArtifacts(insertedCv,infoAuthReq,isNewInfoAuthReq,account,uow);
        uow.commitWork();

    }catch (AuraHandledException ex) {
        throw ex;
    } catch (Exception e) {
        LOGGER.error(e.getMessage(),new String[] { SBFC_CTRL_MoonbaseDocument.class.getName(),e.getMessage()},e);
        throw new AuraHandledException(e.getMessage());
    }
}
    
   /**
 * @description Validates whether the Lead is eligible for Moonstone
 *              Disclosure generation based on Owner, Stage and Status.
 *
 * @author Gigyasu
 * @param lead Lead record to validate.
 * @throws AuraHandledException if the Lead is assigned to a queue,
 *                              has an invalid Stage, or has an
 *                              invalid Status.
 */
    public static void validateDisclosureEligibility(Lead lead) {
       
    // Queue Owner Validation
    if (String.valueOf(lead.OwnerId).startsWith('00G')) {
        throw new AuraHandledException( 'Generate Disclosure is only available when the Lead is assigned to a user. Please assign the Lead from the queue to a user first.');
    }

    Boolean isValidStage = VALID_DISCLOSURE_STAGES.contains(lead.Stage__c);
    Boolean isValidStatus = lead.Status == 'Nurturing';

    if (!isValidStage && !isValidStatus) {
        throw new AuraHandledException(
            'Disclosure generation is only available when the Lead Stage is In Progress and the Lead Status is Nurturing. Please update both fields to proceed.'
        );
    }

    if (!isValidStatus) {
        throw new AuraHandledException(
            'Disclosure generation requires the Lead Status to be Nurturing. Please update the Lead Stage to Completed to move the lead to the Nurturing Stage.'
        );
    }

    if (!isValidStage) {
        throw new AuraHandledException(
            'Disclosure generation requires the Lead Stage to be In Progress. Please update the Lead Stage to continue.'
        );
    }
    
}

    /**
 * @description Retrieves the prefill data required for Moonstone Disclosure
 *              generation after validating the Lead eligibility.
 *
 * @author Gigyasu
 * @param leadId Lead Id.
 * @return Map<String, String> containing customerName, identityNumber,
 *         cCode and accountId.
 * @throws AuraHandledException if the Lead is invalid or required data
 *                              cannot be retrieved.
 */
@AuraEnabled
public static Map<String, String> getPrefillData(String leadId) {

    try {

        if (String.isBlank(leadId)) {
            throw new AuraHandledException('Lead Id not received from UI.');
        }

        Lead lead = getValidatedLead(leadId);

        validateDisclosureEligibility(lead);

        Account account = getRelatedAccount(lead);

        User user = getLeadOwner(lead);

        if (user != null && String.isBlank(user.RM_AE_Code__c)) {
            throw new AuraHandledException(
                'Disclosure cannot be generated because the Lead Owner profile is incomplete.'
            );
        }

        return new Map<String, String>{
            'customerName'   => account != null ? account.Name : null,
            'identityNumber' => account != null ? account.CMN_IdentityNumber__pc : null,
            'cCode'          => user != null ? user.RM_AE_Code__c : null,
            'accountId'      => lead.FinServ__RelatedAccount__c,
            'ownerName'      => user != null ? user.Name : null
        };

    } catch (AuraHandledException ex) {
        throw ex;
    } catch (Exception e) {
        LOGGER.error(e.getMessage(),new String[]{SBFC_CTRL_MoonbaseDocument.class.getName(),e.getMessage()},e);
        throw new AuraHandledException(e.getMessage());
    }
}


        /**
 * @description Links the specified Account to the Lead by updating
 *              the FinServ__RelatedAccount__c lookup field.
 *
 * @author Gigyasu
 * @param leadId Lead Id to update.
 * @param accountId Account Id to associate with the Lead.
 * @throws AuraHandledException if either parameter is null, the user
 *                              does not have update access to Lead,
 *                              or the update fails.
 */
@AuraEnabled
public static void linkedAccountToLead(Id leadId, Id accountId) {

    if (leadId == null || accountId == null) {
        throw new AuraHandledException('Lead Id and Account Id are required.');
    }

    try {

        if (!Schema.sObjectType.Lead.isUpdateable()) {
            throw new AuraHandledException('Insufficient access to update Lead.');
        }

        Lead leadToUpdate = new Lead(
            Id = leadId,
            FinServ__RelatedAccount__c = accountId
        );

         sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
         uow.registerDirty(leadToUpdate);
         uow.commitWork();

    }catch (AuraHandledException ex) {
        throw ex;
    } catch (Exception ex) {
        LOGGER.error(ex.getMessage(),new String[] {SBFC_CTRL_MoonbaseDocument.class.getName(),ex.getMessage()},ex);
        throw new AuraHandledException('Failed to link Account to Lead. ' + ex.getMessage());
    }
}
    

    /**
 * @description Generates a Moonstone Disclosure document by invoking the
 *              Moonstone API, logging the web service call, storing the
 *              API response on the related InfoAuthorizationRequest and
 *              saving the generated disclosure PDF.
 *
 * @author Gigyasu
 * @param leadId Lead Id.
 * @param chkOne First disclosure checkbox value.
 * @param chkTwo Second disclosure checkbox value.
 * @param policyType Selected policy type.
 * @return SBFC_DTO_MoonstoneResponse containing the Moonstone API response.
 * @throws AuraHandledException if disclosure generation fails.
 */
@AuraEnabled
public static SBFC_DTO_MoonstoneResponse sendDocument(String leadId,Integer chkOne,Integer chkTwo,String policyType) {
    sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
    SBFC_DTO_MoonstoneResponse responseDto = new SBFC_DTO_MoonstoneResponse();

    try {

        if (String.isBlank(leadId)) {
            throw new AuraHandledException('Lead Id is required.');
        }

        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Lead.');
        }

        Lead lead = new SEL_Lead().selectLeadByLeadId(leadId);

        Account account = getRelatedAccount(lead);

        if (account == null) {
            throw new AuraHandledException('No related Account found for this Lead.');
        }

        User user = getLeadOwner(lead);

        SBFC_API_MoonbaseDocument sbfcApi = new SBFC_API_MoonbaseDocument();

        sbfcApi.initialise(lead,account,user,chkOne,chkTwo,policyType);

        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SBFC_API_MoonbaseDocument.SERVICE_NAME);

        queueItem.CMN_TriggeringObjectId__c = leadId;

        sbfcApi.process(queueItem);

        sbgplatform.fflib_ISObjectUnitOfWork uowqueueitem = ORG_Application.unitOfWork.newInstance();
        uowqueueitem.registerNew(queueItem);
        uowqueueitem.commitWork();

        String responseJson = SBFC_API_MoonbaseDocument.responseBody;

        return processMoonstoneResponse(leadId,responseJson,account,uow);

    }catch (AuraHandledException ex) {
        throw ex;
    } catch (Exception e) {
         LOGGER.error(e.getMessage(),new String[] {SBFC_CTRL_MoonbaseDocument.class.getName(),e.getMessage()},e);
         throw new AuraHandledException('Disclosure generation failed: ' + e.getMessage());
    }
}

 

    /**
 * @description Checks whether a generated Moonstone Disclosure already
 *              exists for the Lead's related Account.
 *
 *              A disclosure is considered available only when an
 *              InfoAuthorizationRequest exists and a generated
 *              ContentDocument is attached to it.
 *
 * @author Gigyasu
 * @param leadId Lead Id.
 * @return SBFC_DTO_ExistingDisclosure containing the disclosure details
 *         if a generated disclosure exists.
 * @throws AuraHandledException if the Lead is invalid or an unexpected
 *                              error occurs.
 */
@AuraEnabled(cacheable=true)
public static SBFC_DTO_ExistingDisclosure hasExistingDisclosure(String leadId) {

    try {
        if (String.isBlank(leadId)) {
            throw new AuraHandledException('Lead Id is required.');
        }

        Lead lead = getValidatedLead(leadId);

        SBFC_DTO_ExistingDisclosure response = new SBFC_DTO_ExistingDisclosure();

        // Lead is not linked to an Account
        if (lead.FinServ__RelatedAccount__c == null) {
            return response;
        }

        if (!Schema.sObjectType.InfoAuthorizationRequest.isAccessible()) {
            throw new AuraHandledException('Insufficient access to InfoAuthorizationRequest.');
        }

        // Retrieve InfoAuthorizationRequest
        InfoAuthorizationRequest disclosure =
            new SEL_InfoAuthorizationRequest()
                .selectBySourceRecordId(
                    lead.FinServ__RelatedAccount__c
                );

        if (disclosure == null) {
            return response;
        }

        if (!Schema.sObjectType.ContentDocumentLink.isAccessible()) {
            throw new AuraHandledException('Insufficient access to ContentDocumentLink.');
        }

        // Check whether a generated disclosure document is attached
        List<ContentDocumentLink> documentLinks =new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityIdWithLimit(disclosure.Id);

        // No document attached yet
        if (documentLinks.isEmpty()) {
            return response;
        }

        // Disclosure document exists
        response.hasDisclosure = true;
        response.plannerName = lead.Owner.Name;
        response.documentName = disclosure.Name;
        response.createdDate = disclosure.CreatedDate;
        response.infoAuthorizationRequestId = disclosure.Id;
        response.contentDocumentId = documentLinks[0].ContentDocumentId;

        return response;

    } catch (AuraHandledException ex) {
        throw ex;
    }catch (Exception e) {
        LOGGER.error(e.getMessage(),new String[]{SBFC_CTRL_MoonbaseDocument.class.getName(),e.getMessage()},e);
        throw new AuraHandledException(e.getMessage());
    }
}
    
/**
 * @description Retrieves and validates the specified Lead record.
 *
 *              Verifies Lead object access and ensures the Lead exists
 *              before continuing the Moonstone Disclosure process.
 *
 * @author Gigyasu
 * @param leadId Lead Id.
 * @return Lead record corresponding to the supplied Lead Id.
 * @throws AuraHandledException if the Lead is inaccessible or does not exist.
 */    
private static Lead getValidatedLead(String leadId) {

    if (!Schema.sObjectType.Lead.isAccessible()) {
        throw new AuraHandledException('Insufficient access to Lead.');
    }

    Lead lead = new SEL_Lead().selectLeadByLeadId(leadId);

    if (lead == null) {
        throw new AuraHandledException('Lead not found.');
    }

    return lead;
}
    
/**
 * @description Retrieves the Account related to the specified Lead.
 *
 *              Returns the related Account when available after validating
 *              Account object access.
 *
 * @author Gigyasu
 * @param lead Lead record.
 * @return Related Account record, or null if no related Account exists.
 * @throws AuraHandledException if the Account object is inaccessible.
 */
    
 private static Account getRelatedAccount(Lead lead) {

    if (lead.FinServ__RelatedAccount__c == null) {
        return null;
    }

    if (!Schema.sObjectType.Account.isAccessible()) {
        throw new AuraHandledException('Insufficient access to Account.');
    }

    return new SEL_Account().selectById(lead.FinServ__RelatedAccount__c);
}

/**
 * @description Retrieves the owner of the specified Lead.
 *
 *              Validates User object access before returning the
 *              Lead owner's User record.
 *
 * @author Gigyasu
 * @param lead Lead record.
 * @return User record representing the Lead owner.
 * @throws AuraHandledException if the User object is inaccessible.
 */
        
   private static User getLeadOwner(Lead lead) {

    if (lead == null) {
        return null;
    }

    if (!Schema.sObjectType.User.isAccessible()) {
        throw new AuraHandledException('Insufficient access to User.');
    }

    return new SEL_User().selectUserById(lead.OwnerId);
} 
    
 /**
 * @description Updates the existing InfoAuthorizationRequest with the
 *              Moonstone API response.
 *
 *              Stores the abbreviated Moonstone response in the
 *              SBFC_Moonstone_Response__c field when an existing
 *              InfoAuthorizationRequest is available.
 *
 * @author Gigyasu
 * @param account Account associated with the disclosure.
 * @param responseJson Moonstone API response in JSON format.
 * @param uow Unit of Work used to register the record update.
 * @throws AuraHandledException if the InfoAuthorizationRequest object
 *                              is inaccessible or not updateable.
 */
    
 private static void updateMoonstoneResponse(Account account,String responseJson,sbgplatform.fflib_ISObjectUnitOfWork uow) {

    if (!Schema.sObjectType.InfoAuthorizationRequest.isAccessible()) {
        throw new AuraHandledException(
            'Insufficient access to InfoAuthorizationRequest.'
        );
    }

    InfoAuthorizationRequest infoAuthReq =
        new SEL_InfoAuthorizationRequest()
            .selectBySourceRecordId(account.Id);

    if (infoAuthReq == null) {
        return;
    }

    if (!Schema.sObjectType.InfoAuthorizationRequest.isUpdateable()) {
        throw new AuraHandledException(
            'Insufficient access to update InfoAuthorizationRequest.'
        );
    }

    Integer maxLength =
        InfoAuthorizationRequest.SBFC_Moonstone_Response__c
            .getDescribe()
            .getLength();

    infoAuthReq.SBFC_Moonstone_Response__c =
        SBFC_API_MoonbaseDocument.abbreviate(
            responseJson,
            maxLength
        );

    uow.registerDirty(infoAuthReq);
}
    
/**
 * @description Creates and saves a ContentVersion record for the
 *              generated Moonstone Disclosure PDF.
 *
 *              Decodes the Base64 encoded PDF, creates the ContentVersion,
 *              commits the record, and returns the inserted record with its
 *              associated ContentDocument information.
 *
 * @author Gigyasu
 * @param account Account associated with the disclosure.
 * @param base64Pdf Base64 encoded PDF returned from Moonstone.
 * @return Inserted ContentVersion record.
 * @throws AuraHandledException if the ContentVersion object is
 *                              inaccessible or cannot be created.
 */
    
 private static ContentVersion createContentVersion(
    Account account,
    String base64Pdf
) {

    Blob pdfBlob = EncodingUtil.base64Decode(base64Pdf);

    if (!Schema.sObjectType.ContentVersion.isCreateable()) {
        throw new AuraHandledException(
            'Insufficient access to create ContentVersion.'
        );
    }

    sbgplatform.fflib_ISObjectUnitOfWork uow =
        ORG_Application.unitOfWork.newInstance();

    ContentVersion cv = new ContentVersion();

    cv.Title = account.Name + ' Moonstone Disclosure';
    cv.PathOnClient = 'Disclosure.pdf';
    cv.VersionData = pdfBlob;
    cv.IsMajorVersion = true;

    uow.registerNew(cv);
    uow.commitWork();

    return new SEL_ContentVersion()
        .selectContentVersionById(cv.Id);
}
    
    /**
 * @description Creates and registers the ContentDocumentLink and FeedItem
 *              records for the generated Moonstone Disclosure.
 *
 * @author Gigyasu
 * @param insertedCv Generated ContentVersion.
 * @param infoAuthReq Related InfoAuthorizationRequest.
 * @param isNewInfoAuthReq Indicates whether the disclosure record is new.
 * @param account Related Account.
 * @param uow Unit Of Work instance.
 * @throws AuraHandledException if the required objects are not accessible.
 */
    private static void createDisclosureArtifacts(
        ContentVersion insertedCv,
        InfoAuthorizationRequest infoAuthReq,
        Boolean isNewInfoAuthReq,
        Account account,
        sbgplatform.fflib_ISObjectUnitOfWork uow
    ){
              if (!Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            throw new AuraHandledException('Insufficient access to create ContentDocumentLink.');
        }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedCv.ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'InternalUsers';
        
        if (isNewInfoAuthReq) {
            uow.registerRelationship(cdl, ContentDocumentLink.LinkedEntityId, infoAuthReq);
        } else {
            cdl.LinkedEntityId = infoAuthReq.Id;
        }
        
        uow.registerNew(cdl);
        
        if (!Schema.sObjectType.FeedItem.isCreateable()) {
            throw new AuraHandledException('Insufficient access to create FeedItem.');
        }
        
        FeedItem post = new FeedItem();
        post.Body = account.Name + ' 📄 Moonstone Disclosure';
        post.RelatedRecordId = insertedCv.Id;
        post.Type = 'ContentPost';
        
        if (isNewInfoAuthReq) {
            uow.registerRelationship(post, FeedItem.ParentId, infoAuthReq);
        } else {
            post.ParentId = infoAuthReq.Id;
        }
        
        uow.registerNew(post);
          }
    


/**
 * @description Processes the Moonstone API response, updates the disclosure
 *              record, and saves the generated PDF when successful.
 *
 * @author Gigyasu
 * @param leadId Lead Id.
 * @param responseJson Moonstone API response.
 * @param account Related Account.
 * @param uow Unit Of Work instance.
 * @return Moonstone response DTO.
 * @throws AuraHandledException if response processing fails.
 */    
    private static SBFC_DTO_MoonstoneResponse processMoonstoneResponse(
    String leadId,
    String responseJson,
    Account account,
    sbgplatform.fflib_ISObjectUnitOfWork uow
    ) {

    SBFC_DTO_MoonstoneResponse responseDto =
        new SBFC_DTO_MoonstoneResponse();

    if (String.isBlank(responseJson)) {
        responseDto.status = 'FAILED';
        return responseDto;
    }

    responseDto =
        (SBFC_DTO_MoonstoneResponse)
        JSON.deserialize(
            responseJson,
            SBFC_DTO_MoonstoneResponse.class
        );

    updateMoonstoneResponse(
        account,
        responseJson,
        uow
    );

    uow.commitWork();

    if (responseDto != null
        && responseDto.status == 'success'
        && responseDto.data != null
        && String.isNotBlank(responseDto.data.base64pdf)) {

        savePdfToLead(
            leadId,
            responseDto.data.base64pdf,
            responseJson
        );
    }

    return responseDto;
}
            
}