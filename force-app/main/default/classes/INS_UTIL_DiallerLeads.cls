/*
 * @author      Raja Arsalan   
 * @date        June 2025
 * @last modified on  : 06-02-2026
 * @last modified by  : Raja Arsalan
 *
 * Change log
 * 2026-01-28   Raja Arsalan    SFP-52529 - Updated the logic for error handling.
 * 2026-02-06   Raja Arsalan    Refactored - parsing moved to INS_SRV_DiallerLeadResponse
 * 2026-10-19   Tintswalo       Added processExpressedInterestChangedLeads() for the
 *                              expressed-interest-changed two-step PUT+POST flow.
 *                              Fixed inverted condition in processSuccessfulPutResponse().
 */
public without sharing class INS_UTIL_DiallerLeads {

    private static sbgplatform.fflib_SObjectUnitOfWork uow = 
        new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType>{Lead.SObjectType});
    
    private static final String STATUS_UNQUALIFIED = 'Unqualified';

    // ============================================================
    // PAYLOAD PREPARATION
    // ============================================================

    public Map<String, String> prepareLeadPayloadsByCampaign(List<Lead> leads) {
        Map<String, String> campaignJsonMap = new Map<String, String>();
        try {
            if (leads == null || leads.isEmpty()) {
                return campaignJsonMap;
            }
            
            Map<Id, String> userIdToEmployeeEmailMap = getuserIdToEmployeeEmailMap(leads);
            Map<String, List<Lead>> campaignLeadMap = new Map<String, List<Lead>>();
            
            for (Lead l : leads) {
                String campaignKey = String.isBlank(l.Campaign_Name__c) ? 'NO_CAMPAIGN' : l.Campaign_Name__c.trim();
                if (!campaignLeadMap.containsKey(campaignKey)) {
                    campaignLeadMap.put(campaignKey, new List<Lead>());
                }
                campaignLeadMap.get(campaignKey).add(l);
            }
            
            for (String campaignName : campaignLeadMap.keySet()) {
                List<INS_DTO_DiallerLeads.LeadWrapper> wrappers = new List<INS_DTO_DiallerLeads.LeadWrapper>();
                List<Lead> leadGroup = campaignLeadMap.get(campaignName);
                for (Lead lead : leadGroup) {
                    String employeeId = userIdToEmployeeEmailMap.get(lead.OwnerId);
                    String processedEmpId = employeeId != null ? employeeId.toUpperCase() : null;
                    wrappers.add(INS_DTO_DiallerLeads.createWrapperFromLead(lead, processedEmpId, null));
                }
                String requestBody = INS_DTO_DiallerLeads.generateRequestBody(wrappers);
                campaignJsonMap.put(campaignName, requestBody);
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_DiallerLeads - prepareLeadPayloadsByCampaign');
        }
        return campaignJsonMap;
    }

    // ============================================================
    // USER / VALIDATION HELPERS
    // ============================================================

    public static Map<Id, String> getuserIdToEmployeeEmailMap(List<Lead> leads) {
        Map<Id, String> userIdToEmployeeEmailMap = new Map<Id, String>();
        try {
            Set<Id> userIds = new Set<Id>();
            for (Lead l : leads) {
                if (l.OwnerId != null && String.valueOf(l.OwnerId).startsWith('005')) {
                    userIds.add(l.OwnerId);
                }
            }
            if (!userIds.isEmpty()) {
                SEL_User selUser = new SEL_User();
                List<User> users = selUser.getUsersByIds(userIds);
                for (User u : users) {
                    userIdToEmployeeEmailMap.put(u.Id, u.Email);
                }
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_DiallerLeads - getuserIdToEmployeeEmailMap');
        }
        return userIdToEmployeeEmailMap;
    }

    private static Boolean validateNumber(Lead lead) {
        try {
            Boolean hasValidMobile = !String.isBlank(lead.MobilePhone) && lead.MobilePhone.length() > 6;
            Boolean hasValidPhone = String.isBlank(lead.Phone) || lead.Phone.length() > 6;
            return hasValidMobile && hasValidPhone;
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_DiallerLeads - validateNumber');
            return false;
        }
    }

    private static void validateAndClassifyLead(Lead l, List<Lead> qualifiedLeads, List<Lead> unqualifiedLeads) {
        Lead modifiableLead = l.clone(true, true, true, true);
        modifiableLead.Id = l.Id;
        
        if (String.isBlank(l.Dialler_Queue_ID__c)) {
            modifiableLead.Dialer_Failure_Reason__c = 'Dialler Queue ID is missing on the lead record.';
            unqualifiedLeads.add(modifiableLead);
            return;
        }
        
        Boolean validMobile = validateNumber(l);
        if (!validMobile) {
            modifiableLead.Dialer_Failure_Reason__c = 'Invalid format detected for Mobile Phone or Phone.';
            unqualifiedLeads.add(modifiableLead);
            return;
        }
        
        qualifiedLeads.add(modifiableLead);
    }


    private static Lead validateProductChangedLead(Lead lead) {
    if (String.isBlank(lead.Referred_System_Reference_Number__c)) {
        return buildErrorLead(
            lead.Id,
            'Cannot expire the existing Dialler lead because its reference number is missing.'
        );
    }

    if (lead.Referred_System_Reference_Number__c == 'Duplicate') {
        return buildErrorLead(
            lead.Id,
            'Cannot expire a duplicate lead in Dialler.'
        );
    }

    if (String.isBlank(lead.Dialler_Queue_ID__c)) {
        return buildErrorLead(
            lead.Id,
            'Dialler Queue ID is missing on the lead record.'
        );
    }

    if (!validateNumber(lead)) {
        return buildErrorLead(
            lead.Id,
            'Invalid format detected for Mobile Phone or Phone.'
        );
    }

    return null;
}
    // ============================================================
    // MAIN ORCHESTRATION
    // ============================================================

    /**
     * @description Entry point for the normal lead processing path (PATH A).
     * Called by INS_BATCH_DiallerLead.execute() when isExpressedInterestChanged=false.
     *
     * Splits leads into:
     *   newLeads    → no Referred_System_Reference_Number__c → POST to create in dialler
     *   updateLeads → has Referred_System_Reference_Number__c → PUT to update/expire
     */
    public static void processLeadscallout(List<Lead> newLeads, List<Lead> updateLeads, Boolean expireLeads) {
        try {
            uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType>{Lead.SObjectType});
            
            if (newLeads != null && !newLeads.isEmpty()) {
                processLeadsForConnex(newLeads, 'POST', expireLeads);
            }
            if (updateLeads != null && !updateLeads.isEmpty()) {
                processLeadsForConnex(updateLeads, 'PUT', expireLeads);
            }
            uow.commitWork();
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_DiallerLeads - processLeadscallout');
        }
    }
    
    /**
     * @description Handles the two-step dialler flow when a lead's expressed interest product changes.
     *
     * Why two steps?
     *   The lead already exists in the dialler under a specific campaign/queue tied to the OLD product.
     *   Simply updating it (PUT) would leave it under the wrong queue.
     *   We must:
     *     1. PUT with the expiry status code → removes the lead from the old dialler queue.
     *     2. POST → re-creates the lead under the queue that matches the NEW expressed interest product.
     *
     * If the PUT fails, the POST is intentionally blocked — we must not create a duplicate
     * in the dialler before the old record has been successfully removed.
     *
     * @param leads  List of Lead records whose Expressed_Interest_Product__c changed
     */
    public static void processExpressedInterestChangedLeads(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return;
        }

        try {
            uow = new sbgplatform.fflib_SObjectUnitOfWork(
                new List<SObjectType>{ Lead.SObjectType }
            );

            // ── 1. Validate each lead before making any callouts ─────────────────
            // We validate upfront so we never waste API calls on leads that will
            // fail validation (missing reference number, missing queue ID, etc.).
            List<Lead> qualifiedLeads   = new List<Lead>();

            for (Lead lead : leads) {
                Lead validationError = validateProductChangedLead(lead);
                if (validationError != null) {
                    // Persist the validation failure reason back to the lead record.
                    uow.registerDirty(validationError);
                } else {
                    qualifiedLeads.add(lead);
                }
            }

            if (qualifiedLeads.isEmpty()) {
                uow.commitWork();
                return;
            }

            // ── 2. Shared setup (token + settings + user map) ────────────────────
            // Retrieve auth token and metadata once; reuse across all leads.
           // String accessToken = CMN_Generate_Token_Helper.getAccessToken();
            String accessToken = getAccessTokenSafely();
            INS_Insurance_Lead_Settings__mdt leadSettings =
                INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
            Map<Id, String> userEmailMap = getuserIdToEmployeeEmailMap(leads);

            List<Lead> leadsToPost = new List<Lead>();

            // ── 3. PUT each lead with the expiry status code ─────────────────────
            // Each PUT targets a different endpoint (/<refNum>/LeadEnhancement),
            // so we loop individually rather than batching them into one request.
            for (Lead lead : qualifiedLeads) {
                try {
                    // passing expireLeads=true so buildPutPayload uses the
                    // INS_LeadExpireCode__c value from metadata (e.g. "EXP").
                    String payload = buildPutPayload(lead, userEmailMap, leadSettings, true);

                    INS_Leads_API api = new INS_Leads_API(
                        payload,
                        accessToken,
                        'PUT',
                        lead.Referred_System_Reference_Number__c
                    );

                    String putResponse = performLeadOutboundCall(api);

                    // handlePutResponse parses the JSON and returns a Lead with
                    // either a cleared Dialer_Failure_Reason__c (success) or a
                    // populated one (failure). null = parse error.
                    Lead putResult = handlePutResponse(lead, putResponse, true);

                    if (putResult == null || String.isNotBlank(putResult.Dialer_Failure_Reason__c)) {
                        // PUT failed or response was unparseable — do NOT POST.
                        System.debug('>>> processExpressedInterestChangedLeads | PUT FAILED for leadId=' + lead.Id
                            + ' | putResult=' + (putResult != null ? 'not null' : 'NULL')
                            + ' | Dialer_Failure_Reason__c=' + (putResult != null ? putResult.Dialer_Failure_Reason__c : 'N/A')
                            + ' | POST BLOCKED');
                        Lead errorLead = (putResult != null)
                            ? putResult
                            : buildErrorLead(lead.Id, 'Unable to confirm successful Dialler expiry.');
                        uow.registerDirty(errorLead);
                    } else {
                        // PUT confirmed success — add to POST list
                        System.debug('>>> processExpressedInterestChangedLeads | PUT SUCCEEDED for leadId=' + lead.Id
                            + ' | clearing old ref# and adding to POST list');
                        putResult.Referred_System_Reference_Number__c = null;
                        uow.registerDirty(putResult);
                        leadsToPost.add(lead);
                    }

                } catch (Exception ex) {
                    CMN_UTIL_Logger.error(
                        ex, 'INS_UTIL_DiallerLeads - processExpressedInterestChangedLeads - PUT'
                    );
                    uow.registerDirty(handlePutFailure(lead));
                }
            }

            // ── 4. POST each lead that passed the PUT ────────────────────────────
            System.debug('>>> processExpressedInterestChangedLeads | leadsToPost count=' + leadsToPost.size());
            if (!leadsToPost.isEmpty()) {
                System.debug('>>> processExpressedInterestChangedLeads | FIRING POST for ' + leadsToPost.size() + ' leads');
                List<Lead> postResults = processQualifiedLeadsPost(leadsToPost, accessToken);
                System.debug('>>> processExpressedInterestChangedLeads | POST complete | postResults count=' + postResults.size());
                for (Lead r : postResults) {
                    if (r != null) {
                        System.debug('>>> processExpressedInterestChangedLeads | POST result | leadId=' + r.Id
                            + ' | Referred_System_Reference_Number__c=' + r.Referred_System_Reference_Number__c
                            + ' | Dialer_Failure_Reason__c=' + r.Dialer_Failure_Reason__c);
                        uow.registerDirty(r);
                    }
                }
            } else {
                System.debug('>>> processExpressedInterestChangedLeads | leadsToPost is EMPTY — POST did not fire');
            }

            uow.commitWork();

        } catch (Exception ex) {
            CMN_UTIL_Logger.error(
                ex, 'INS_UTIL_DiallerLeads - processExpressedInterestChangedLeads'
            );
        }
    }

    /**
     * @description Normal callout dispatcher. Routes to PUT or POST based on methodType.
     * Not used by the expressed-interest-changed flow — that has its own method above.
     */
    public static void processLeadsForConnex(List<Lead> leads, String methodType, Boolean expireLeads) {
        try {
            List<Lead> qualifiedLeads = new List<Lead>();
            List<Lead> unqualifiedLeads = new List<Lead>();
            
            Map<Id, String> userIdToEmployeeEmailMap = getuserIdToEmployeeEmailMap(leads);
            
            for (Lead l : leads) {
                validateAndClassifyLead(l, qualifiedLeads, unqualifiedLeads);
            }
            
            if (!qualifiedLeads.isEmpty()) {
                //String accessToken = CMN_Generate_Token_Helper.getAccessToken();
                String accessToken = getAccessTokenSafely();
                if (methodType.equalsIgnoreCase('PUT')) {
                    List<Lead> updatedLeads = processQualifiedLeadsPut(
                        qualifiedLeads, userIdToEmployeeEmailMap, accessToken, expireLeads
                    );
                    for (Lead updatedLead : updatedLeads) {
                        if (updatedLead != null) {
                            uow.registerDirty(updatedLead);
                        }
                    }
                } else {
                    List<Lead> updatedLeads = processQualifiedLeadsPost(qualifiedLeads, accessToken);
                    for (Lead updatedLead : updatedLeads) {
                        if (updatedLead != null) {
                            uow.registerDirty(updatedLead);
                        }
                    }
                }
            }
            
            if (!unqualifiedLeads.isEmpty()) {
                for (Lead unqualifiedLead : unqualifiedLeads) {
                    uow.registerDirty(unqualifiedLead);
                }
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_DiallerLeads - processLeadsForConnex');
        }
    }

    // ============================================================
    // PUT FLOW
    // ============================================================

    private static List<Lead> processQualifiedLeadsPut(
        List<Lead> qualifiedLeads,
        Map<Id, String> userIdToEmployeeIdMap,
        String accessToken,
        Boolean expireLeads
    ) {
        List<Lead> leadsToUpdate = new List<Lead>();
        INS_Insurance_Lead_Settings__mdt leadSettings = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
        
        for (Lead lead : qualifiedLeads) {
            try {
                String payload = buildPutPayload(lead, userIdToEmployeeIdMap, leadSettings, expireLeads);
                INS_Leads_API api = new INS_Leads_API(payload, accessToken, 'PUT', lead.Referred_System_Reference_Number__c);
                String response = performLeadOutboundCall(api);
                Lead updatedLead = handlePutResponse(lead, response, expireLeads);
                
                if (updatedLead != null) {
                    leadsToUpdate.add(updatedLead);
                }
            } catch (Exception ex) {
                CMN_UTIL_Logger.error(ex, 'INS_UTIL_DiallerLeads - processQualifiedLeadsPut');
                leadsToUpdate.add(handlePutFailure(lead));
            }
        }
        return leadsToUpdate;
    }

    private static String buildPutPayload(
        Lead lead,
        Map<Id, String> userIdToEmployeeIdMap,
        INS_Insurance_Lead_Settings__mdt leadSettings,
        Boolean expireLeads
    ) {
        String empEmail = userIdToEmployeeIdMap.get(lead.OwnerId);
        return (lead.Status == STATUS_UNQUALIFIED || expireLeads)
            ? INS_DTO_DiallerLeads.generatePutRequestBody(lead, empEmail, leadSettings.INS_LeadExpireCode__c)
            : INS_DTO_DiallerLeads.generatePutRequestBody(lead, empEmail, null);
    }

    /**
     * @description Handles PUT response for a lead.
     * Parses the dialler API response and returns a Lead with fields set for success or failure.
     * @param lead          Original lead being updated
     * @param responseBody  Raw JSON from the dialler PUT endpoint
     * @param expireLeads   Whether this PUT was an expiry call
     * @return Lead         Updated lead record, or an error lead if the response was a failure
     */
    private static Lead handlePutResponse(Lead lead, String responseBody, Boolean expireLeads) {
        INS_DTO_UpdateDiallerLeadResponse dto;
        try {
            dto = INS_DTO_UpdateDiallerLeadResponse.parse(responseBody);
        } catch (Exception e) {
            dto = null;
        }
        
        if (INS_SRV_DiallerLeadResponse.isPutResponseError(dto)) {
            String errorMsg = INS_SRV_DiallerLeadResponse.extractErrorMessage(
                dto, 'Unknown error from Dialler PUT API'
            );
            return buildErrorLead(lead.Id, errorMsg);
        }

        Lead updatedLead = INS_SRV_DiallerLeadResponse.parsePutResponse(responseBody);
        if (updatedLead == null) {
            return buildErrorLead(lead.Id, 'Unable to parse Dialler PUT response');
        }
        
        return processSuccessfulPutResponse(updatedLead, lead, expireLeads);
    }



    private static Lead processSuccessfulPutResponse(Lead updatedLead, Lead originalLead, Boolean expireLeads) {
        if (updatedLead == null) {
            return null;
        }
        updatedLead.Id = originalLead.Id;

        if (String.isNotBlank(updatedLead.Dialer_Failure_Reason__c)) {
            return updatedLead;
        }
        if (shouldExpireLead(originalLead, expireLeads)) {
            updatedLead.Status = STATUS_UNQUALIFIED;
            updatedLead.Stage__c = 'Closed Lost';
        }
        return updatedLead;
    }

    private static Boolean shouldExpireLead(Lead lead, Boolean expireLeads) {
        return (lead.Status != STATUS_UNQUALIFIED && expireLeads) || lead.Status == STATUS_UNQUALIFIED;
    }

    private static Lead handlePutFailure(Lead lead) {
        return new Lead(
            Id = lead.Id,
            Dialer_Failure_Reason__c = 'Unable to complete the request due to an unidentified issue.'
        );
    }



    private static List<Lead> processQualifiedLeadsPost(List<Lead> qualifiedLeads, String accessToken) {
        List<Lead> leadsToUpdate = new List<Lead>();
        Map<String, String> leadPayloadsByCampaign = new INS_UTIL_DiallerLeads().prepareLeadPayloadsByCampaign(qualifiedLeads);
        
        for (String campaignName : leadPayloadsByCampaign.keySet()) {
            String jsonPayload = leadPayloadsByCampaign.get(campaignName);
            List<Lead> campaignLeads = filterLeadsByCampaign(qualifiedLeads, campaignName);
            
            String responseBody = performLeadOutboundCall(new INS_Leads_API(jsonPayload, accessToken, 'POST'));
            leadsToUpdate.addAll(handlePostResponse(campaignLeads, responseBody));
        }
        return leadsToUpdate;
    }

    private static List<Lead> filterLeadsByCampaign(List<Lead> leads, String campaignName) {
        List<Lead> result = new List<Lead>();
        for (Lead l : leads) {
            String key = String.isBlank(l.Campaign_Name__c) ? 'NO_CAMPAIGN' : l.Campaign_Name__c.trim();
            if (key == campaignName) {
                result.add(l);
            }
        }
        return result;
    }

    /**
     * @description Handles the POST response from the dialler API.
     * Parsing and error detection are delegated to INS_SRV_DiallerLeadResponse
     * so this class stays focused on orchestration, not response interpretation.
     */
    private static List<Lead> handlePostResponse(List<Lead> campaignLeads, String responseBody) {
        List<Lead> leadsToUpdate = new List<Lead>();
        
        INS_DTO_DiallerLeadsResponse dto;
        try {
            dto = INS_DTO_DiallerLeadsResponse.parse(responseBody);
        } catch (Exception e) {
            dto = null;
        }
        
        if (INS_SRV_DiallerLeadResponse.isPostResponseError(dto)) {
            String errorMsg = INS_SRV_DiallerLeadResponse.extractErrorMessage(
                dto, 'Unknown error from Dialler POST API'
            );
            for (Lead l : campaignLeads) {
                leadsToUpdate.add(buildErrorLead(l.Id, errorMsg));
            }
            return leadsToUpdate;
        }
        
        List<Lead> updated = INS_SRV_DiallerLeadResponse.parsePostResponse(responseBody);
        if (updated != null && !updated.isEmpty()) {
            leadsToUpdate.addAll(updated);
        }

        Set<Id> respondedLeadIds = new Set<Id>();
        for (Lead l : leadsToUpdate) {
            if (l.Id != null) respondedLeadIds.add(l.Id);
        }
        for (Lead originalLead : campaignLeads) {
            if (!respondedLeadIds.contains(originalLead.Id)) {
                leadsToUpdate.add(buildErrorLead(originalLead.Id, 'No response from Dialler API for this lead'));
            }
        }
        
        return leadsToUpdate;
    }

    // ============================================================
    // HELPERS
    // ============================================================

    private static Lead buildErrorLead(Id leadId, String message) {
        return new Lead(
            Id = leadId,
            Dialer_Failure_Reason__c = String.isBlank(message) ? 'Unknown error from Dialler API' : message.left(255)
        );
    }

    private static String performLeadOutboundCall(INS_Leads_API leadsAPI) {
        CMN_WebserviceCallQueue__c queue = CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_Leads_API.SERVICE_NAME);
        leadsAPI.process(queue);
        return leadsAPI.getResponseBody();
    }
    
    
    /**
* @description Gets access token safely — bypasses real callout in test context
* @return String Access token
**/
    private static String getAccessTokenSafely() {
        if (Test.isRunningTest()) {
            return 'mock-access-token';
        }
        return CMN_Generate_Token_Helper.getAccessToken();
    }
}