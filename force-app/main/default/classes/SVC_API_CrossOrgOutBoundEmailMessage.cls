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

global with sharing class SVC_API_CrossOrgOutBoundEmailMessage 
{
    /**
     * @description Invocable Method called into the Flow Cross Org Case Creation V2 to sent Email Messages to the destination Org
     *
     * @param dtoRequest The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
     *
     */
    @InvocableMethod(Callout=true Label='Sent Email to Destination Case' Description='Sent Emails associated to the Case')
    public static List<SVC_DTO_CrossOrgSelectCaseonDestOrgResponse> sentCaseEmailsCrossOrg(List<SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow> dtoRequests){
        
        List<Id> casesIds = new List<Id>();
        Map<Id,SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow> caseMap = new Map<Id,SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow>();
        for(SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow dtoRequest : dtoRequests){
            casesIds.add(dtoRequest.sourceCaseId);
            caseMap.put(dtoRequest.sourceCaseId, dtoRequest);
        }
        
        List<EmailMessage> emailmessages = [SELECT id, fromAddress, fromName, toAddress, subject, textBody, isBounced, headers, htmlBody, ParentId FROM EmailMessage WHERE ParentId IN: casesIds];

                if(!emailmessages.isEmpty()){

                    List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgRequest> dtoEmailRequests = new List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgRequest>();

                    for(EmailMessage emailmessage : emailmessages){
                        SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgRequest dtoEmailRequest = new SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgRequest();
                        dtoEmailRequest.namedCredential = caseMap.get(emailmessage.parentId).namedCredential;
                        dtoEmailRequest.destinationCaseId = caseMap.get(emailmessage.parentId).destinationcaseId;
                        dtoEmailRequest.fromAddress = emailmessage.fromAddress;
                        dtoEmailRequest.ToAddress = emailmessage.ToAddress;
                        dtoEmailRequest.fromName = emailmessage.fromName;
                        dtoEmailRequest.subject = emailmessage.subject;
                        dtoEmailRequest.headers = emailmessage.headers;
                        dtoEmailRequest.htmlBody = emailmessage.htmlBody;
                        dtoEmailRequest.textBody = emailmessage.textBody;
                        dtoEmailRequest.isBounced = emailmessage.isBounced;

                        dtoEmailRequests.add(dtoEmailRequest);
                    }

                    //Send EmailMessages to the destination Org.
                    List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgResponse> dtoEmailResponses = sentEmailMessageCrossOrg(dtoEmailRequests);
                    return dtoEmailResponses;
                }
                return null;
    }

    /**
     * @description Internal method called by SVC_API_CrossOrgOutBoundEmailMessage.sentCaseEmailsCrossOrg to sent Email Message to destination Org
     *
     * @param dtoRequests The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
     *
     */
    public static List<SVC_DTO_CrossOrgSelectCaseonDestOrgResponse> sentEmailMessageCrossOrg(List<SVC_DTO_CrossOrgSelectCaseonDestOrgRequest> dtoRequests){
        List<SVC_DTO_CrossOrgSelectCaseonDestOrgResponse> dtoResponses = new List<SVC_DTO_CrossOrgSelectCaseonDestOrgResponse>();

        for (SVC_DTO_CrossOrgSelectCaseonDestOrgRequest dtoRequest : dtoRequests)
        { 
            String endpointString = SVC_UTIL_CrossOrg.PREFIX_CALLOUT + dtoRequest.namedCredential + '/services/apexrest/CrossOrgInBoundEmailMessage';
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
                SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgSelectCaseonDestOrgResponse dtoResponse = (SVC_DTO_CrossOrgSelectCaseonDestOrgResponse) JSON.deserialize(responseBody, SVC_DTO_CrossOrgSelectCaseonDestOrgResponse.class);
                
                if(dtoResponse.responseCode == 400 && dtoResponses.isEmpty()){
                    dtoResponses.add(dtoResponse);
                }
            }
            return dtoResponses;
    }

    /**
     * @description Public DTO class to facilitate the Flow call the Apex Action
     */
    global class SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow
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
    global class SVC_DTO_CrossOrgSelectCaseonDestOrgRequest
    {
        @InvocableVariable
        global String namedCredential;
        @InvocableVariable
        global String destinationCaseId;
        @InvocableVariable
        global String fromAddress;
        @InvocableVariable
        global String toAddress;
        @InvocableVariable
        global String fromName;
        @InvocableVariable
        global String subject;
        @InvocableVariable
        global String textBody;
        @InvocableVariable
        global String headers;
        @InvocableVariable
        global String htmlBody;
        @InvocableVariable
        global Boolean isBounced;
        }

    /**
     * @description Public DTO class to facilitate the API Response
     */
    global class SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
    {
        @InvocableVariable
        public Integer responseCode;
        @InvocableVariable
        public String message;

    }
}