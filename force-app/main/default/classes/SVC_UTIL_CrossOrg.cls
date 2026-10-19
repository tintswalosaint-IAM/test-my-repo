/**
 * @description A set of utility methods to facilitate the retrieval of metadata used in the cross org solution. This
 * class also contains the DAL class to facilitate the integration between Salesforce instances using named credentials
 *
 * @see SVC_API_CrossOrgInbound
 * @see SVC_API_CrossOrgOutbound
 *
 * @author Accenture
 *
 * @date July 2022
 *
 */

public inherited sharing class SVC_UTIL_CrossOrg
{
    // HTTP
    public static final Integer STATUS_CODE_400 = 400;
    public static final Integer STATUS_CODE_200 = 200;
    public static final String VERB_POST = 'POST';
    public static final String VERB_GET = 'GET';
    public static final String APPLICATION_JSON = 'application/json';
    public static final Integer MAX_READ_TIMEOUT = 120000;
    public static final String CONTENT_TYPE = 'Content-Type';
    // Named Credentials
    public static final String PREFIX_CALLOUT = 'callout:';
    public static final String SUFFIX_CALLOUT = '/services/apexrest/CrossOrgInbound';
    public static final String SUFFIX_CALLOUT_FILES = '/services/apexrest/CrossOrgInBoundContDoc';
    // Messages / Strings
    public static final String CASE_CREATED = 'The new case has successfully been created.';
    public static final String ERROR_UNKNOWN = 'Unknown';
    public static final String GROUP_TYPE_QUEUE = 'Queue';
    public static final String EMPTY_STRING = '';

    /**
     * @description Retrieve a list of available orgs for cross org integration.
     *
     * @note Utilized by (Flow) SVC_CrossOrgCaseCreation
     *
     * @return List<String> A list of the labels of the available mapped orgs
     */
    @InvocableMethod(Label='Get Integrated Orgs' Description='Retrieve a list of available orgs for cross org integration')
    public static List<String> retrieveDestinationOrgs()
    {
        List<String> availableOrgs = new List<String>();
        List<CMN_CrossOrgManagement__mdt> crossOrgConfig = CMN_CrossOrgManagement__mdt.getAll().values();
        for (CMN_CrossOrgManagement__mdt config : crossOrgConfig) {
            availableOrgs.add(config.Label);
        }
        return availableOrgs;
    }

    /**
     * @description Internal method called by SVC_API_CrossOrgInboundContDoc.doPost to create the case
     *
     * @param dtoRequest The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_API_CrossOrgInBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgResponse
     *
     */
    public static SVC_API_CrossOrgInBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgResponse createNewContDoc(SVC_API_CrossOrgInBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequest dtoRequest){
        SVC_API_CrossOrgInBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgResponse dtoResponse = new SVC_API_CrossOrgInBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgResponse();

        dtoResponse.message = 'The new File has successfully been created.';
        dtoResponse.responseCode = STATUS_CODE_200;

        try{
            ContentVersion contentVersion = new ContentVersion(
                Title = dtoRequest.title,
                pathOnClient = dtoRequest.pathOnClient,
                versionData = EncodingUtil.base64Decode(dtoRequest.versionNumber)
            );

            Database.insert(contentVersion);

            if(contentVersion.id != null){
                ContentVersion conDocument = [SELECT ContentDocumentID FROM ContentVersion WHERE id=:contentVersion.id LIMIT 1];

                ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                    LinkedEntityId = dtoRequest.destinationCaseId,
                    ContentDocumentId = conDocument.ContentDocumentID,
                    shareType = dtoRequest.shareType,
                    visibility = dtoRequest.visibility
                );

                Database.insert(contentDocumentLink);
            }

        }
        catch (Exception e)
        {
            dtoResponse.responseCode = STATUS_CODE_400;
            dtoResponse.message = e.getMessage();
        }

        return dtoResponse;

    }

    /**
     * @description Internal method called by SVC_API_CrossOrgInboundEmailMessage.doPostEmailMessage to create the case
     *
     * @param dtoRequest The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_API_CrossOrgInBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
     *
     */
    public static SVC_API_CrossOrgInBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgResponse createNewEmailMessage(SVC_API_CrossOrgInBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgRequest dtoRequest)
    {
        SVC_API_CrossOrgInBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgResponse dtoResponse = new SVC_API_CrossOrgInBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgResponse();
        dtoResponse.message = 'The new Email Message has successfully been created.';
        dtoResponse.responseCode = STATUS_CODE_200;

        // Criar o Email Message
        try
        {

           EmailMessage newEmailMessage = new EmailMessage(
                fromAddress = dtoRequest.fromAddress,
                fromName = dtoRequest.fromName,
                toAddress = dtoRequest.toAddress,
                subject = dtoRequest.subject,
                headers = dtoRequest.headers,
                htmlBody = dtoRequest.htmlBody,
                textBody = dtoRequest.textBody,
                isBounced = dtoRequest.isBounced,
                parentId = dtoRequest.destinationCaseId
           );
           
           Database.insert(newEmailMessage);
        }
        catch (Exception e)
        {
            dtoResponse.responseCode = STATUS_CODE_400;
            dtoResponse.message = e.getMessage();
        }

        return dtoResponse;
    }

    /**
     * @description Internal method called by SVC_API_CrossOrgInbound.doPost to create the case
     *
     * @param dtoRequest The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_API_CrossOrgInbound.DTO_Response
     *
     */
    public static SVC_API_CrossOrgInbound.DTO_Response createNewCase(SVC_API_CrossOrgInbound.SVC_DTO_CrossOrgCaseCreateRequest dtoRequest)
    {
        SVC_API_CrossOrgInbound.DTO_Response dtoResponse = new SVC_API_CrossOrgInbound.DTO_Response();
        dtoResponse.message = CASE_CREATED;
        dtoResponse.responseCode = STATUS_CODE_200;

        try
        {
            String userIdFromFederationId = getFederationUserId(dtoRequest.federationId);

            Case newCrossOrgCase = new Case();
            newCrossOrgCase.Subject = dtoRequest.caseSubject;
            newCrossOrgCase.Description = dtoRequest.caseDescription;
            newCrossOrgCase.amazonconnect__AC_Contact_Id__c = dtoRequest.amazonConnectContactId;
            newCrossOrgCase.SuppliedEmail = dtoRequest.webEmail;
            newCrossOrgCase.SuppliedName = dtoRequest.webName;
            newCrossOrgCase.SuppliedPhone = dtoRequest.webPhone;

            if(dtoRequest.svcExternalCifCountry == 'Angola'){
                CrossOrg_Case_Origin_Mapping__mdt caseMapping = null;
                try{
                    caseMapping = [SELECT DestinationCaseSource__c FROM CrossOrg_Case_Origin_Mapping__mdt WHERE MasterLabel =: dtoRequest.caseSource];
                } catch(Exception ex){
                    caseMapping = null;
                }

                if(caseMapping != null && caseMapping.DestinationCaseSource__c != null){

                    newCrossOrgCase.Origin = caseMapping.DestinationCaseSource__c;
                }
            }

            String ownerId = !String.isBlank(dtoRequest.destinationTeam) ? getQueueId(dtoRequest.destinationTeam) : userIdFromFederationId;

            if ((!String.isBlank(dtoRequest.sourceCaseId)) && (!String.isBlank(dtoRequest.sourceCaseNumber)))
            {
                newCrossOrgCase.SVC_ExternalLinkedId__c = dtoRequest.sourceCaseId;
                newCrossOrgCase.SVC_ExternalLinkedNumber__c = dtoRequest.sourceCaseNumber;
            }
            newCrossOrgCase.IsEscalated = true;
            newCrossOrgCase.OwnerId = ownerId;
            newCrossOrgCase.RecordTypeId = getRecordTypeByDeveloperName(dtoRequest.recordTypeName);

            Database.insert(newCrossOrgCase);

            dtoResponse.caseId = newCrossOrgCase.Id;
            dtoResponse.caseNumber = newCrossOrgCase.CaseNumber;

        }
        catch (Exception e)
        {
            dtoResponse.responseCode = STATUS_CODE_400;
            dtoResponse.message = e.getMessage();
        }
        return dtoResponse;
    }

    /**
     * @description Get the Record Type by the Developer Name
     * 
     * @param recordTypeName The developerName of the record type
     *
     * @return The Id of the record type based on the developer name
     *
     */
    private static Id getRecordTypeByDeveloperName(String recordTypeName)
    {
        return [
                SELECT
                    Id
                FROM
                    RecordType
                WHERE
                    DeveloperName = :recordTypeName
        ].Id;
    }

    /**
     * @description Get the federationId (email format) from the associated
     * User record by id.
     *
     * @param userId The user Id used to look up the federation id
     *
     * @return The federation Id for the input user
     */
    public static String getFederationUserId(String userId)
    {
        List<User> userRecords = [
                SELECT
                        Id
                FROM
                        User
                WHERE
                        FederationIdentifier = :userId
        ];
        return userRecords.isEmpty() ? EMPTY_STRING : userRecords[0].Id;
    }

    /**
     * @description Return the Queue id based on the relation to the team
     *
     * @param teamAPIName The API name of the team used to determine the appropriate queue
     *
     * @return String The Id of the queue associated to the team
     */
    public static String getQueueId(String teamAPIName)
    {
        List<Group> queues = [
                SELECT
                        Id,
                        Name,
                        DeveloperName
                FROM
                        Group
                WHERE
                        Type = :GROUP_TYPE_QUEUE AND DeveloperName = :teamAPIName
        ];
        return queues.isEmpty() ? EMPTY_STRING : queues[0].Id;
    }
}