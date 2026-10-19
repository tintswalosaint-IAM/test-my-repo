/**
 * @description API and DTO to facilitate the integration between Salesforce instances using named credentials, this
 * class handles the outbound calls from the source to the destination
 *
 * @see SVC_API_CrossOrgEmail_TEST
 *
 * @author Angola Team
 *
 * @date September 2022
 *
 */

global with sharing class SVC_API_CrossOrgOutBoundContDoc {

    /**
     * @description Invocable Method called into the Flow Cross Org Case Creation V2 to sent the Contact Documents to destination Org 
     *
     * @param dtoRequest The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
     *
     */
    @InvocableMethod(Callout=true Label='Sent Files' Description='Sent files associated to the Case')
    public static List<SVC_DTO_CrossOrgCaseContDocDestOrgResponse> sentCaseContDocCrossOrg(List<SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow> dtoRequests){
        
        List<SVC_DTO_CrossOrgCaseContDocDestOrgResponse> dtoContDocResponses = new List<SVC_DTO_CrossOrgCaseContDocDestOrgResponse>();
        Map<Id,SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow> caseMessageMap = new Map<Id,SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow>();
        List<Id> casesIds = new List<Id>();

        for(SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow dtoRequest : dtoRequests){
            casesIds.add(dtoRequest.sourceCaseId);
            caseMessageMap.put(dtoRequest.sourceCaseId, dtoRequest);
        }

        List<EmailMessage> emailmessages = [SELECT id, ParentId FROM EmailMessage WHERE ParentId IN: casesIds];
        List<Id> emailMessagesIds = new List<Id>();
        Map<Id, SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow> emailMessageMap = new Map<Id, SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow>();
        
        for(EmailMessage emailmessage : emailMessages){
            casesIds.add(emailmessage.id);
            emailMessagesIds.add(emailmessage.id);
            emailMessageMap.put(emailmessage.id, caseMessageMap.get(emailmessage.parentId));
            caseMessageMap.put(emailmessage.id, caseMessageMap.get(emailmessage.parentId));
        }

        List<ContentDocumentLink> contentdocumentLinks = [SELECT ContentDocumentId, LinkedEntityId, shareType, Visibility  FROM ContentDocumentLink WHERE id != null AND /*(LinkedEntityId IN: emailmessagesIds OR*/ LinkedEntityId IN: casesIds/*)*/];

        List<String> contentdocumentids = new List<String>();
            for(ContentDocumentLink cdl : contentDocumentLinks){
                contentdocumentids.add(cdl.ContentDocumentId);
            }

        List<ContentVersion> contentversions = [SELECT id, ContentDocumentId, VersionData, Title, pathOnClient FROM ContentVersion WHERE ContentDocumentId IN: contentdocumentids]; 

                if(!contentdocumentLinks.isEmpty()){

                    List<SVC_DTO_CrossOrgCaseContDocDestOrgRequest> dtoContDocRequests = new List<SVC_DTO_CrossOrgCaseContDocDestOrgRequest>();

                    for(ContentDocumentLink contentdocumentlink : contentDocumentLinks){

                            for(ContentVersion contentV : contentversions){
                                if(contentV.ContentDocumentId == contentdocumentlink.ContentDocumentId){

                                    SVC_DTO_CrossOrgCaseContDocDestOrgRequest dtoContDocRequest = new SVC_DTO_CrossOrgCaseContDocDestOrgRequest();
                                    dtoContDocRequest.namedCredential = caseMessageMap.get(contentdocumentlink.linkedEntityId).namedCredential;
                                    dtoContDocRequest.destinationCaseId = caseMessageMap.get(contentdocumentlink.linkedEntityId).destinationCaseId;
                                    dtoContDocRequest.contentDocumentId = contentdocumentlink.contentDocumentId;
                                    dtoContDocRequest.linkedEntityId = contentdocumentlink.LinkedEntityId;
                                    dtoContDocRequest.shareType = contentdocumentlink.shareType;
                                    dtoContDocRequest.visibility = contentdocumentlink.Visibility;
                                    dtoContDocRequest.title = contentV.title;
                                    dtoContDocRequest.pathOnClient = contentV.pathOnClient;
                                    dtoContDocRequest.versionNumber = EncodingUtil.base64Encode(contentV.versionData);

                                    dtoContDocRequests.add(dtoContDocRequest);

                                }
                            }
                        }
                        
                        dtoContDocResponses = sendCaseContDocCrossOrg(dtoContDocRequests);
                    }
        return dtoContDocResponses;
    }

    
    /**
     * @description Internal method called by SVC_API_CrossOrgOutBoundContDoc.sentCaseContDocCrossOrg to sent Content Documents to destination Org
     *
     * @param dtoRequests The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_DTO_CrossOrgCaseContDocDestOrgResponse
     *
     */
    public static List<SVC_DTO_CrossOrgCaseContDocDestOrgResponse> sendCaseContDocCrossOrg(List<SVC_DTO_CrossOrgCaseContDocDestOrgRequest> dtoRequests){
        List<SVC_DTO_CrossOrgCaseContDocDestOrgResponse> dtoResponses = new List<SVC_DTO_CrossOrgCaseContDocDestOrgResponse>();

        for (SVC_DTO_CrossOrgCaseContDocDestOrgRequest dtoRequest : dtoRequests)
        { 
            String endpointString = SVC_UTIL_CrossOrg.PREFIX_CALLOUT + dtoRequest.namedCredential + SVC_UTIL_CrossOrg.SUFFIX_CALLOUT_FILES;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointString);
            req.setTimeout(SVC_UTIL_CrossOrg.MAX_READ_TIMEOUT);
            req.setHeader(SVC_UTIL_CrossOrg.CONTENT_TYPE, SVC_UTIL_CrossOrg.APPLICATION_JSON);
            req.setMethod(SVC_UTIL_CrossOrg.VERB_POST);
            req.setBody(JSON.serializePretty(dtoRequest));

            Http http = new Http();
            HttpResponse resp = http.send(req);

            while (resp.getStatusCode() == 302)
                {
                    req.setEndpoint(resp.getHeader('Location'));
                    resp = new Http().send(req);
                }

                String responseBody = resp.getBody();
                SVC_DTO_CrossOrgCaseContDocDestOrgResponse dtoResponse = (SVC_DTO_CrossOrgCaseContDocDestOrgResponse) JSON.deserialize(responseBody, SVC_DTO_CrossOrgCaseContDocDestOrgResponse.class);

                if(dtoResponse.responseCode == 400 && dtoResponses.isEmpty()){
                    dtoResponses.add(dtoResponse);
                }
            }
            return dtoResponses;
    }

    /**
     * @description Public DTO class to facilitate the Flow call the Apex Action
     */
    global class SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow
    {
        @InvocableVariable
        global String namedCredential;
        @InvocableVariable
        global String sourceCaseId;
        @InvocableVariable
        global String destinationCaseId;
    }

    /**
     * @description Public DTO class to facilitate the API Request
     */
    global class SVC_DTO_CrossOrgCaseContDocDestOrgRequest
    {
        @InvocableVariable
        global String namedCredential;
        @InvocableVariable
        global String destinationCaseId;
        @InvocableVariable
        global String linkedEntityId;
        @InvocableVariable
        global String contentDocumentId;
        @InvocableVariable
        global String shareType;
        @InvocableVariable
        global String visibility;
        @InvocableVariable
        global String title;
        @InvocableVariable
        global String pathOnClient;
        @InvocableVariable
        global String versionNumber;
        }

    /**
     * @description Public DTO class to facilitate the API Response
     */
    global class SVC_DTO_CrossOrgCaseContDocDestOrgResponse
    {
        //Receber o id do caso 
        @InvocableVariable
        public Integer responseCode;
        @InvocableVariable
        public String message;

    }
}