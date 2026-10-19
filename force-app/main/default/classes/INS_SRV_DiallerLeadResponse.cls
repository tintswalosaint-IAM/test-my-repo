/**
 * @description Service class responsible for parsing Dialler Lead API responses
 *              and building Lead records to update.
 *              Follows the same pattern as INS_SRV_DotsureLeadResponse.
 * @author      Raja Arsalan
 * @date        Feb 2026
 */
public with sharing class INS_SRV_DiallerLeadResponse {
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_SRV_DiallerLeadResponse');
    
    private static final String KEY_ERROR = 'error';
    private static final String KEY_ERROR_MESSAGE = 'errorMessage';
    
    // ============================================================
    // POST RESPONSE HANDLING
    // ============================================================
    
    /**
     * @description Parses Dialler POST response and builds list of Lead records to update.
     * @param responseBody Raw JSON response from Dialler POST API
     * @return List<Lead> Leads to update based on success/failure
     */
    public static List<Lead> parsePostResponse(String responseBody) {
        List<Lead> leadsToUpdate = new List<Lead>();
        
        if (String.isBlank(responseBody)) {
            LOGGER.warn('parsePostResponse | blank responseBody');
            return leadsToUpdate;
        }
        
        INS_DTO_ConnexLeadsResponse dto;
        try {
            dto = INS_DTO_ConnexLeadsResponse.parse(responseBody);
        } catch (Exception e) {
            LOGGER.error('parsePostResponse | parse failed | ' + e.getMessage());
            return leadsToUpdate;
        }
        
        if (dto == null) {
            LOGGER.error('parsePostResponse | dto is null');
            return leadsToUpdate;
        }
        
        // Global error: explicit error node ya HTTP status
        if (dto.error != null || isFatalStatus(dto.status_code)) {
            String errorMsg = extractErrorMessage(dto, 'Unknown error from Dialler POST API');
            LOGGER.error('parsePostResponse | global error | ' + errorMsg);
            return leadsToUpdate;
        }
        
        if (dto.LeadGenerationResponse == null || dto.LeadGenerationResponse.isEmpty()) {
            LOGGER.warn('parsePostResponse | empty LeadGenerationResponse');
            return leadsToUpdate;
        }
        
        // Per-item loop
        for (INS_DTO_ConnexLeadsResponse.LeadGenerationResponse item : dto.LeadGenerationResponse) {
            if (item == null) continue;
            
            if (String.isNotBlank(item.errorCode)) {
                LOGGER.error('parsePostResponse | item errorCode=' + item.errorCode + ' | ' + item.message + ' | ' + item.leadId);
                continue;
            }
            
            if (String.isBlank(item.message)) continue;
            
            String messageContent = cleanJsonString(item.message);
            if (String.isBlank(messageContent) || !messageContent.trim().startsWith('{')) {
                LOGGER.warn('parsePostResponse | item message is not nested JSON | ' + item.message);
                continue;
            }
            
            List<INS_DTO_ConnexLeadsResponse.LeadGenerationResponseItem> responseItems =
                INS_DTO_ConnexLeadsResponse.parseResponseItems(messageContent);
            
            if (responseItems != null && !responseItems.isEmpty()) {
                leadsToUpdate.addAll(buildLeadsFromItems(responseItems));
            }
        }
        
        return leadsToUpdate;
    }
    
    // ============================================================
    // PUT RESPONSE HANDLING
    // ============================================================
    
    /**
     * @description Parses Dialler PUT response and builds a Lead record to update.
     * @param responseBody Raw JSON response from Dialler PUT API
     * @return Lead Updated lead or null
     */
    public static Lead parsePutResponse(String responseBody) {
        if (String.isBlank(responseBody)) {
            LOGGER.warn('parsePutResponse | blank responseBody');
            return null;
        }
        
        INS_DTO_UpdateConnexLeadResponse dto;
        try {
            dto = INS_DTO_UpdateConnexLeadResponse.parse(responseBody);
        } catch (Exception e) {
            LOGGER.error('parsePutResponse | parse failed | ' + e.getMessage());
            return null;
        }
        
        if (dto == null) {
            LOGGER.error('parsePutResponse | dto is null');
            return null;
        }
        
        if (dto.error != null || isFatalStatus(dto.status_code)) {
            LOGGER.error('parsePutResponse | global error');
            return null;
        }
        
        if (dto.LeadGenerationResponse == null || dto.LeadGenerationResponse.isEmpty()) {
            LOGGER.warn('parsePutResponse | empty LeadGenerationResponse');
            return null;
        }
        
        Lead resultLead;
        for (INS_DTO_UpdateConnexLeadResponse.LeadGenerationResponse item : dto.LeadGenerationResponse) {
            if (item == null) continue;
            
            if (String.isBlank(item.id)) {
                LOGGER.warn('parsePutResponse | item missing id');
                continue;
            }
            
            Lead lead = new Lead(Referred_System_Reference_Number__c = item.id);
            
            if (String.isBlank(item.errorCode)) {
                lead.Dialer_Failure_Reason__c = '';
            } else {
                String failure = String.isNotBlank(item.message) ? item.message : item.errorCode;
                lead.Dialer_Failure_Reason__c = failure.left(255);
                LOGGER.error('parsePutResponse | failure | ' + failure);
            }
            
            resultLead = lead;
            break;
        }
        
        return resultLead;
    }
    
    // ============================================================
    // ERROR DETECTION
    // ============================================================
    
public static Boolean isPostResponseError(INS_DTO_ConnexLeadsResponse dto) {
    if (dto == null) return true;
    if (dto.error != null) return true;
    if (isFatalStatus(dto.status_code)) return true;
    
    if (dto.LeadGenerationResponse != null) {
        for (INS_DTO_ConnexLeadsResponse.LeadGenerationResponse item : dto.LeadGenerationResponse) {
            if (item != null && String.isNotBlank(item.errorCode)) {
                return true;
            }
        }
    }
    
    return false;
}
    
public static Boolean isPutResponseError(INS_DTO_UpdateConnexLeadResponse dto) {
    if (dto == null) return true;
    if (dto.error != null) return true;
    if (isFatalStatus(dto.status_code)) return true;
    

    if (dto.LeadGenerationResponse != null) {
        for (INS_DTO_UpdateConnexLeadResponse.LeadGenerationResponse item : dto.LeadGenerationResponse) {
            if (item != null && String.isNotBlank(item.errorCode)) {
                return true;
            }
        }
    }
    
    return false;
}
    
    public static String extractErrorMessage(Object responseDto, String defaultMsg) {
        if (responseDto == null) return defaultMsg;
        
        String rawText = getRawError(responseDto);
        if (String.isBlank(rawText)) return defaultMsg;
        
        try {
            Map<String, Object> topJson = (Map<String, Object>) JSON.deserializeUntyped(rawText);
            if (topJson.containsKey(KEY_ERROR)) {
                Object errorNode = topJson.get(KEY_ERROR);
                
                if (errorNode instanceof Map<String, Object>) {
                    Map<String, Object> errMap = (Map<String, Object>) errorNode;
                    
                    if (errMap.containsKey(KEY_ERROR_MESSAGE)) {
                        String msg = String.valueOf(errMap.get(KEY_ERROR_MESSAGE)).trim();
                        if (String.isNotBlank(msg)) return msg.left(255);
                    }
                    
                    if (errMap.containsKey('errorDescription')) {
                        String nested = String.valueOf(errMap.get('errorDescription'));
                        String msg = parseNestedError(nested);
                        if (String.isNotBlank(msg)) return msg.left(255);
                    }
                }
                
                if (errorNode instanceof List<Object>) {
                    String msg = extractFromErrorsArray((List<Object>) errorNode);
                    if (String.isNotBlank(msg)) return msg.left(255);
                }
            }
        } catch (Exception ex) {
            String msg = extractFromRawString(rawText);
            if (String.isNotBlank(msg)) return msg.left(255);
        }
        
        return defaultMsg;
    }
    
    // ============================================================
    // PRIVATE HELPERS
    // ============================================================
    
    private static Boolean isFatalStatus(Integer statusCode) {
        return statusCode == 500 || statusCode == 400 || statusCode == 401;
    }
    
    private static String getRawError(Object dto) {
        if (dto == null) return null;
        
        if (dto instanceof INS_DTO_ConnexLeadsResponse) {
            INS_DTO_ConnexLeadsResponse d = (INS_DTO_ConnexLeadsResponse) dto;
            
            if (d.error != null && String.isNotBlank(d.error.errorDescription)) {
                return d.error.errorDescription;
            }
            
            if (d.LeadGenerationResponse != null) {
                for (INS_DTO_ConnexLeadsResponse.LeadGenerationResponse item : d.LeadGenerationResponse) {
                    if (item != null && String.isNotBlank(item.errorCode)) {
                        return JSON.serialize(new Map<String, Object>{
                            'error' => new Map<String, Object>{ 'errorMessage' => item.message }
                        });
                    }
                }
            }
        }
        
        if (dto instanceof INS_DTO_UpdateConnexLeadResponse) {
            INS_DTO_UpdateConnexLeadResponse d = (INS_DTO_UpdateConnexLeadResponse) dto;
            
            if (d.error != null && String.isNotBlank(d.error.errorDescription)) {
                return d.error.errorDescription;
            }
            
            if (d.LeadGenerationResponse != null) {
                for (INS_DTO_UpdateConnexLeadResponse.LeadGenerationResponse item : d.LeadGenerationResponse) {
                    if (item != null && String.isNotBlank(item.errorCode)) {
                        return JSON.serialize(new Map<String, Object>{
                            'error' => new Map<String, Object>{ 'errorMessage' => item.message }
                        });
                    }
                }
            }
        }
        
        return null;
    }
    
    private static String parseNestedError(String nestedText) {
        if (String.isBlank(nestedText)) return null;
        try {
            Map<String, Object> nestedJson = (Map<String, Object>) JSON.deserializeUntyped(nestedText);
            
            if (nestedJson.containsKey('errors') && nestedJson.get('errors') instanceof List<Object>) {
                String msg = extractFromErrorsArray((List<Object>) nestedJson.get('errors'));
                if (String.isNotBlank(msg)) return msg.left(255);
            }
            
            if (nestedJson.containsKey(KEY_ERROR) && nestedJson.get(KEY_ERROR) instanceof Map<String, Object>) {
                Map<String, Object> innerVal = (Map<String, Object>) nestedJson.get(KEY_ERROR);
                if (innerVal.containsKey(KEY_ERROR_MESSAGE)) {
                    return String.valueOf(innerVal.get(KEY_ERROR_MESSAGE)).trim().left(255);
                }
            }
        } catch (Exception ex) {
            return nestedText.trim().left(255);
        }
        return null;
    }
    
    private static String extractFromErrorsArray(List<Object> errorsList) {
        if (errorsList == null || errorsList.isEmpty()) return null;
        
        if (errorsList[0] instanceof Map<String, Object>) {
            Map<String, Object> first = (Map<String, Object>) errorsList[0];
            if (first.containsKey('detail')) return String.valueOf(first.get('detail')).trim();
            if (first.containsKey('title')) return String.valueOf(first.get('title')).trim();
        }
        return null;
    }
    
    private static String extractFromRawString(String rawText) {
        if (String.isBlank(rawText)) return null;
        
        List<String> keys = new List<String>{KEY_ERROR_MESSAGE, 'detail', 'errorDescription'};
        for (String key : keys) {
            Integer idx = rawText.indexOf(key + '":"');
            if (idx >= 0) {
                Integer start = idx + key.length() + 3;
                Integer endVal = rawText.indexOf('"', start);
                if (endVal > start) {
                    return rawText.substring(start, endVal).trim();
                }
            }
        }
        
        if (rawText.contains('Provided credentials are invalid')) return 'Provided credentials are invalid';
        if (rawText.contains('Connection error')) return 'Connection error';
        
        return null;
    }
    
    private static String cleanJsonString(String jsonStr) {
        if (String.isBlank(jsonStr)) return '';
        String out = jsonStr;
        if (out.startsWith('"') && out.endsWith('"') && out.length() >= 2) {
            out = out.substring(1, out.length() - 1);
        }
        return out.replace('\\"', '"').replace('\\\\', '\\').trim();
    }
    
    private static List<Lead> buildLeadsFromItems(
        List<INS_DTO_ConnexLeadsResponse.LeadGenerationResponseItem> items
    ) {
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (INS_DTO_ConnexLeadsResponse.LeadGenerationResponseItem item : items) {
            if (item == null || String.isBlank(item.source_reference)) continue;
            
            Lead lead = new Lead(Id = item.source_reference);
            
            if (item.success && (item.errors == null || item.errors.isEmpty())) {
                lead.Referred_System_Reference_Number__c = item.contact_data_id;
                lead.Dialer_Failure_Reason__c = '';
            } else {
                String failureReason = 'Unknown error';
                if (item.errors != null && !item.errors.isEmpty()) {
                    failureReason = item.errors[0].message;
                }
                lead.Dialer_Failure_Reason__c = failureReason;
                LOGGER.error('buildLeadsFromItems | failure | ' + failureReason);
            }
            
            leadsToUpdate.add(lead);
        }
        
        return leadsToUpdate;
    }
    
    

}