/**
 * @description API and DTO to facilitate the integration between Salesforce instances using named credentials, this
 * class handles the outbound calls from the source to the destination
 *
 * @see SVC_API_CrossOrg_TEST
 *
 * @author Accenture
 *
 * @date July 2022
 *
 */

global with sharing class SVC_API_CrossOrgOutbound
{
    /**
     * @description Invocable Method called into the Flow Cross Org Case Creation V2 to sent the case to destination org
     *
     * @param dtoRequest The request payload
     *
     * @return The structured DTO response
     *
     * @see SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
     *
     */
    @InvocableMethod(Callout=true Label='Initiate Case Creation' Description='Triggers the creation of the case in the destination org' Category='Multi Org Case Transfer')
    public static List<DTO_Response> initiateNewCase(List<SVC_DTO_CrossOrgCaseCreateRequest> dtoRequests)
    {
        List<DTO_Response> dtoResponses = new List<DTO_Response>();
        for (SVC_DTO_CrossOrgCaseCreateRequest dtoRequest : dtoRequests)
        {
            String endpointString = SVC_UTIL_CrossOrg.PREFIX_CALLOUT + dtoRequest.namedCredential + SVC_UTIL_CrossOrg.SUFFIX_CALLOUT;
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
            SVC_API_CrossOrgOutbound.DTO_Response dtoResponse = (DTO_Response)JSON.deserialize(responseBody, DTO_Response.class);
            
            //Case created sucessfully check if it's an Angola Case
            if(dtoResponse.responseCode == 200 && dtoRequest.svcExternalCifCountry == 'AO'){
                dtoResponse.message = label.CrossOrg_Case_Created_Msg;
                
            }else if(dtoResponse.responseCode == 400 && dtoRequest.svcExternalCifCountry == 'AO'){
                dtoResponse.message = label.CrossOrg_Case_Creation_Error + ' ' + dtoResponse.message;
            }
            dtoResponses.add(dtoResponse);
        }
        return dtoResponses;
    }

    /**
     * @description Public DTO class to facilitate the API Request
     */
    global class SVC_DTO_CrossOrgCaseCreateRequest
    {
        @InvocableVariable
        global String sourceCaseId;
        @InvocableVariable
        global String sourceCaseNumber;
        @InvocableVariable
        global String caseSubject;
        @InvocableVariable
        global String caseDescription;
        @InvocableVariable
        global String caseSource;
        @InvocableVariable
        global String destinationTeam;
        @InvocableVariable
        global String federationId;
        @InvocableVariable
        global String namedCredential;
        @InvocableVariable
        global String amazonConnectContactId;
        @InvocableVariable
        global String recordTypeName;
        @InvocableVariable
        global String svcExternalCifCountry;
        @InvocableVariable
        global String webEmail;
        @InvocableVariable
        global String webName;
        @InvocableVariable
        global String webPhone;
    }

    /**
     * @description Public DTO class to facilitate the API Response
     */
    global class DTO_Response
    {
        @InvocableVariable
        public String caseId;
        @InvocableVariable
        public String caseNumber;
        @InvocableVariable
        public Integer responseCode;
        @InvocableVariable
        public String message;      
    }
}