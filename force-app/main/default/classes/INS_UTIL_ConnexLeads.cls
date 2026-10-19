/**
 * @description Utility class to process leads for Dialler Integration.
 * @author      Raja Arsalan
 * @date        June 2025
 * @last modified on  : 06-02-2026
 * @last modified by  : Raja Arsalan
 *
 * Change log
 * 2026-01-28   Raja Arsalan    SFP-52529 - Updated the logic for error handling.
 * 2026-02-06   Raja Arsalan    Refactored - parsing moved to INS_SRV_DiallerLeadResponse
 */
public without sharing class INS_UTIL_ConnexLeads {

    private static sbgplatform.fflib_SObjectUnitOfWork uow = 
        new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType>{Lead.SObjectType});
    
    private static final String STATUS_UNQUALIFIED = 'Unqualified';

    // ============================================================
    // PAYLOAD PREPARATION
    // ============================================================

    public Map<String, String> prepareLeadPayloadsByCampaign(List<Lead> leads) {
        Map<String, String> campaignJsonMap = new Map<String, String>();
        try {
            if (leads == null || leads.isEmpty()) return campaignJsonMap;
            
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
                List<INS_DTO_ConnexLeads.LeadWrapper> wrappers = new List<INS_DTO_ConnexLeads.LeadWrapper>();
                List<Lead> leadGroup = campaignLeadMap.get(campaignName);
                for (Lead lead : leadGroup) {
                    String employeeId = userIdToEmployeeEmailMap.get(lead.OwnerId);
                    String processedEmpId = employeeId != null ? employeeId.toUpperCase() : null;
                    wrappers.add(INS_DTO_ConnexLeads.createWrapperFromLead(lead, processedEmpId, null));
                }
                String requestBody = INS_DTO_ConnexLeads.generateRequestBody(wrappers);
                campaignJsonMap.put(campaignName, requestBody);
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_ConnexLeads - prepareLeadPayloadsByCampaign');
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
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_ConnexLeads - getuserIdToEmployeeEmailMap');
        }
        return userIdToEmployeeEmailMap;
    }

    private static Boolean validateNumber(Lead lead) {
        try {
            Boolean hasValidMobile = !String.isBlank(lead.MobilePhone) && lead.MobilePhone.length() > 6;
            Boolean hasValidPhone = String.isBlank(lead.Phone) || lead.Phone.length() > 6;
            return hasValidMobile && hasValidPhone;
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_ConnexLeads - validateNumber');
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
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_ConnexLeads - processLeadscallout');
        }
    }
    
    // TODO: Note to self check this please
    // Placeholder, I was just trying something new   
   public static void processExpressedInterestChangedLeads(List<Lead> leads) {
    if (leads == null || leads.isEmpty()) return;

    try {
        uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Lead.SObjectType }
        );

        // ── 1. Validation ────────────────────────────────────────────
        // We validate BEFORE the callout so we don't waste API calls
        // on leads that will fail anyway.
        List<Lead> qualifiedLeads  = new List<Lead>();
        List<Lead> unqualifiedLeads = new List<Lead>();

        for (Lead lead : leads) {
            // validateProductChangedLead checks: reference number present,
            // not 'Duplicate', queue ID present, phone valid.
            Lead validationError = validateProductChangedLead(lead);
            if (validationError != null) {
                uow.registerDirty(validationError); // persist the failure reason
            } else {
                qualifiedLeads.add(lead);
            }
        }

        if (qualifiedLeads.isEmpty()) {
            uow.commitWork();
            return;
        }

        // ── 2. Shared setup ──────────────────────────────────────────
        String accessToken = CMN_Generate_Token_Helper.getAccessToken();
        INS_Insurance_Lead_Settings__mdt leadSettings =
            INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
        Map<Id, String> userEmailMap = getuserIdToEmployeeEmailMap(leads);

        List<Lead> leadsToPost = new List<Lead>();

        // ── 3. PUT: expire the existing dialler record ────────────────
        // We loop individually (not in bulk) because each PUT targets a
        // different reference number endpoint: /<refNum>/LeadEnhancement
        for (Lead lead : qualifiedLeads) {
            try {
                // true = send the expire status code in the payload
                String payload = buildPutPayload(
                    lead, userEmailMap, leadSettings, true
                );

                INS_Leads_API api = new INS_Leads_API(
                    payload,
                    accessToken,
                    'PUT',
                    lead.Referred_System_Reference_Number__c
                );

                String putResponse = performLeadOutboundCall(api);

                // handlePutResponse parses the response and returns
                // a Lead with either success fields or Dialer_Failure_Reason__c set.
                Lead putResult = handlePutResponse(lead, putResponse, true);

                if (putResult == null || putResult.Dialer_Failure_Reason__c != null) {
                    // PUT failed or uncertain — do NOT POST, record the error
                    Lead errorLead = putResult != null
                        ? putResult
                        : buildErrorLead(lead.Id, 'Unable to confirm successful Dialler expiry.');
                    uow.registerDirty(errorLead);
                } else {
                    // PUT succeeded — this lead is cleared to be re-created via POST
                    uow.registerDirty(putResult);
                    leadsToPost.add(lead);
                }

            } catch (Exception ex) {
                CMN_UTIL_Logger.error(
                    ex, 'INS_UTIL_ConnexLeads - processExpressedInterestChangedLeads - PUT'
                );
                uow.registerDirty(handlePutFailure(lead));
            }
        }

        // ── 4. POST: re-create leads under the correct queue ─────────
        // Only leads that passed the PUT get here.
        // processQualifiedLeadsPost groups by Campaign_Name__c and sends
        // one POST per campaign — same as the normal new-lead flow.
        if (!leadsToPost.isEmpty()) {
            List<Lead> postResults = processQualifiedLeadsPost(leadsToPost, accessToken);
            for (Lead r : postResults) {
                if (r != null) uow.registerDirty(r);
            }
        }

        uow.commitWork();

    } catch (Exception ex) {
        CMN_UTIL_Logger.error(
            ex, 'INS_UTIL_ConnexLeads - processExpressedInterestChangedLeads'
        );
    }
}

    // PUT existing Dialler lead with expiry
    // Verify PUT success
    // POST the same Lead again using current Dialler_Queue_ID__c

    public static void processLeadsForConnex(List<Lead> leads, String methodType, Boolean expireLeads) {
        try {
            List<Lead> qualifiedLeads = new List<Lead>();
            List<Lead> unqualifiedLeads = new List<Lead>();
            
            Map<Id, String> userIdToEmployeeEmailMap = getuserIdToEmployeeEmailMap(leads);
            
            for (Lead l : leads) {
                validateAndClassifyLead(l, qualifiedLeads, unqualifiedLeads);
            }
            
            if (!qualifiedLeads.isEmpty()) {
                String accessToken = CMN_Generate_Token_Helper.getAccessToken();
                
                if (methodType.equalsIgnoreCase('PUT')) {
                    List<Lead> updatedLeads = processQualifiedLeadsPut(
                        qualifiedLeads, userIdToEmployeeEmailMap, accessToken, expireLeads
                    );
                    for (Lead updatedLead : updatedLeads) {
                        if (updatedLead != null) uow.registerDirty(updatedLead);
                    }
                } else {
                    List<Lead> updatedLeads = processQualifiedLeadsPost(qualifiedLeads, accessToken);
                    for (Lead updatedLead : updatedLeads) {
                        if (updatedLead != null) uow.registerDirty(updatedLead);
                    }
                }
            }
            
            if (!unqualifiedLeads.isEmpty()) {
                for (Lead unqualifiedLead : unqualifiedLeads) {
                    uow.registerDirty(unqualifiedLead);
                }
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'INS_UTIL_ConnexLeads - processLeadsForConnex');
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
                
                if (updatedLead != null) leadsToUpdate.add(updatedLead);
            } catch (Exception ex) {
                CMN_UTIL_Logger.error(ex, 'INS_UTIL_ConnexLeads - processQualifiedLeadsPut');
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
            ? INS_DTO_ConnexLeads.generatePutRequestBody(lead, empEmail, leadSettings.INS_LeadExpireCode__c)
            : INS_DTO_ConnexLeads.generatePutRequestBody(lead, empEmail, null);
    }

    /**
     * @description Handles PUT response — parsing ab INS_SRV_DiallerLeadResponse mein hai.
     */
    // TODO: Note to self check this please
    private static Lead handlePutResponse(Lead lead, String responseBody, Boolean expireLeads, Boolean isExpressedInterestChanged ) {
        INS_DTO_UpdateConnexLeadResponse dto;
        try {
            dto = INS_DTO_UpdateConnexLeadResponse.parse(responseBody);
        } catch (Exception e) {
            dto = null;
        }
        
        //  Service class se error check
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


    // caller has been treating null as a successful PUT?
    // If the PUT result is uncertain, the POST must not happen.
    private static Lead processSuccessfulPutResponse(Lead updatedLead, Lead originalLead, Boolean expireLeads) {
        if (updatedLead == null || updatedLead.Dialer_Failure_Reason__c == null) {
            return null;
        }
        updatedLead.Id = originalLead.Id;
        
        if (shouldExpireLead(originalLead, expireLeads)) {
            updatedLead.Status = STATUS_UNQUALIFIED;
            updatedLead.Stage__c = 'Closed Lost';
        }
        return updatedLead;
    }

    private static Boolean shouldExpireLead(Lead lead, Boolean expireLeads) {
        return (lead.Status != STATUS_UNQUALIFIED && expireLeads) || lead.Status == STATUS_UNQUALIFIED;
    }
    // this still returns a lead with the failure reason set, 
    // but does not update the status or stage. 
    //The caller should handle that if needed.
    // Ask Raja
    private static Lead handlePutFailure(Lead lead) {
        return new Lead(
            Id = lead.Id,
            Dialer_Failure_Reason__c = 'Unable to complete the request due to an unidentified issue.'
        );
    }

    // ============================================================
    // POST FLOW
    // ============================================================

    private static List<Lead> processQualifiedLeadsPost(List<Lead> qualifiedLeads, String accessToken) {
        List<Lead> leadsToUpdate = new List<Lead>();
        Map<String, String> leadPayloadsByCampaign = new INS_UTIL_ConnexLeads().prepareLeadPayloadsByCampaign(qualifiedLeads);
        
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
            if (key == campaignName) result.add(l);
        }
        return result;
    }

    /**
     * @description Handles POST response — parsing ab INS_SRV_DiallerLeadResponse mein hai.
     */
    private static List<Lead> handlePostResponse(List<Lead> campaignLeads, String responseBody) {
        List<Lead> leadsToUpdate = new List<Lead>();
        
        INS_DTO_ConnexLeadsResponse dto;
        try {
            dto = INS_DTO_ConnexLeadsResponse.parse(responseBody);
        } catch (Exception e) {
            dto = null;
        }
        
        // ✅ Service class se error check
        if (INS_SRV_DiallerLeadResponse.isPostResponseError(dto)) {
            String errorMsg = INS_SRV_DiallerLeadResponse.extractErrorMessage(
                dto, 'Unknown error from Dialler POST API'
            );
            for (Lead l : campaignLeads) {
                leadsToUpdate.add(buildErrorLead(l.Id, errorMsg));
            }
            return leadsToUpdate;
        }
        
        // ✅ Service class se parsing
        List<Lead> updated = INS_SRV_DiallerLeadResponse.parsePostResponse(responseBody);
        if (updated != null && !updated.isEmpty()) {
            leadsToUpdate.addAll(updated);
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
}