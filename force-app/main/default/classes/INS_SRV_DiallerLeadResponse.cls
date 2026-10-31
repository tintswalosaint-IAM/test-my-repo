/**
 * @description Service class responsible for parsing Dialler Lead API responses
 *              and building Lead records to update.
 *              Handles both POST and PUT responses using generic methods to avoid duplication.
 *              Also handles JWT/auth errors via moreInformation field.
 * @author      Raja Arsalan
 * @date        Feb 2026
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-10-30   Raja Arsalan    Refactored - removed POST/PUT duplication,
 *                              removed dead code, generic methods for DTO-agnostic parsing
 * 2026-10-30   Raja Arsalan    Added try-catch to buildLeadFrom* and applyItem* methods
 * 2026-10-30   Raja Arsalan    Removed dead fallback methods and simplified error extraction
 * 2026-10-31   Raja Arsalan    Added moreInformation and message handling for JWT/auth errors
 *                              in both POST and PUT flows
 */
public with sharing class INS_SRV_DiallerLeadResponse {
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_SRV_DiallerLeadResponse');
    
    private static final String KEY_ERROR = 'error';
    private static final String KEY_ERROR_MESSAGE = 'errorMessage';
    private static final String KEY_ERROR_DESCRIPTION = 'errorDescription';
    private static final String KEY_DETAIL = 'detail';
    private static final String KEY_TITLE = 'title';
    
    // ============================================================
    // PUBLIC ENTRY POINTS
    // ============================================================
    
    /**
     * @description Parses Dialler POST API response and builds a list of Lead records.
     * @param responseBody Raw JSON response body
     * @return List<Lead> Leads to update
     */
    public static List<Lead> parsePostResponse(String responseBody) {
        try {
            return parsePostResponseInternal(responseBody);
        } catch (Exception e) {
            LOGGER.error('parsePostResponse | unexpected failure | ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Parses Dialler PUT API response and builds a single Lead record.
     * @param responseBody Raw JSON response body
     * @return Lead Lead to update, or null if unparseable
     */
    public static Lead parsePutResponse(String responseBody) {
        try {
            return parsePutResponseInternal(responseBody);
        } catch (Exception e) {
            LOGGER.error('parsePutResponse | unexpected failure | ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Checks if POST response contains global errors.
     *              Handles null DTO, error node, moreInformation (JWT/auth), and fatal status.
     * @param dto Parsed POST response DTO
     * @return Boolean True if global error exists
     */
    public static Boolean isPostResponseError(INS_DTO_DiallerLeadsResponse dto) {
        try {
            if (dto == null) {
                return true;
            }
            if (dto.error != null) {
                return true;
            }
            if (String.isNotBlank(dto.moreInformation)) {
                return true;
            }
            if (isFatalStatus(dto.status_code)) {
                return true;
            }
            return false;
        } catch (Exception e) {
            LOGGER.error('isPostResponseError | ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Checks if PUT response contains global errors.
     *              Handles null DTO, error node, moreInformation (JWT/auth), message, and fatal status.
     * @param dto Parsed PUT response DTO
     * @return Boolean True if global error exists
     */
    public static Boolean isPutResponseError(INS_DTO_UpdateDiallerLeadResponse dto) {
        try {
            if (dto == null) {
                return true;
            }
            if (dto.error != null) {
                return true;
            }
            if (String.isNotBlank(dto.moreInformation)) {
                return true;
            }
            if (dto.LeadGenerationResponse == null && String.isNotBlank(dto.message)) {
                return true;
            }
            if (isFatalStatus(dto.status_code)) {
                return true;
            }
            return false;
        } catch (Exception e) {
            LOGGER.error('isPutResponseError | ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Extracts human-readable error message from a response DTO.
     * @param responseDto Parsed DTO (POST or PUT)
     * @param defaultMsg Fallback message
     * @return String Error message
     */
    public static String extractErrorMessage(Object responseDto, String defaultMsg) {
        try {
            return extractErrorMessageInternal(responseDto, defaultMsg);
        } catch (Exception e) {
            LOGGER.error('extractErrorMessage | ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Checks if HTTP status code is fatal (500, 400, 401).
     * @param statusCode HTTP status code
     * @return Boolean True if fatal
     */
    public static Boolean isFatalStatus(Integer statusCode) {
        return statusCode == 500 || statusCode == 400 || statusCode == 401;
    }
    
    // ============================================================
    // POST PARSING
    // ============================================================
    
    /**
     * @description Internal implementation for parsing Dialler POST response.
     * @param responseBody Raw response body
     * @return List<Lead> Leads to update
     */
    private static List<Lead> parsePostResponseInternal(String responseBody) {
        List<Lead> leadsToUpdate = new List<Lead>();
        
        if (String.isBlank(responseBody)) {
            LOGGER.warn('parsePostResponse | blank responseBody');
            return leadsToUpdate;
        }
        
        INS_DTO_DiallerLeadsResponse dto = 
            (INS_DTO_DiallerLeadsResponse) parseDto(responseBody, INS_DTO_DiallerLeadsResponse.class);
        
        if (dto == null 
            || isGlobalError(dto, dto.error, dto.status_code)
            || String.isNotBlank(dto.moreInformation)) {
            return leadsToUpdate;
        }
        
        if (dto.LeadGenerationResponse == null || dto.LeadGenerationResponse.isEmpty()) {
            return leadsToUpdate;
        }
        
        for (INS_DTO_DiallerLeadsResponse.LeadGenerationResponse item : dto.LeadGenerationResponse) {
            Lead lead = buildLeadFromPostItem(item);
            if (lead != null) {
                leadsToUpdate.add(lead);
            }
        }
        
        return leadsToUpdate;
    }
    
    /**
     * @description Builds a Lead record from a POST response item.
     * @param item POST response item
     * @return Lead Lead to update, or null if invalid
     */
    private static Lead buildLeadFromPostItem(INS_DTO_DiallerLeadsResponse.LeadGenerationResponse item) {
        try {
            if (item == null || String.isBlank(item.leadId)) {
                return null;
            }
            
            Lead lead = new Lead(Id = item.leadId);
            
            if (String.isNotBlank(item.errorCode)) {
                applyItemFailure(lead, item.message, item.errorCode);
            } else {
                applyItemSuccess(lead, item.id);
            }
            
            return lead;
        } catch (Exception e) {
            LOGGER.error('buildLeadFromPostItem | ' + e.getMessage());
            return null;
        }
    }
    
    // ============================================================
    // PUT PARSING
    // ============================================================
    
    /**
     * @description Internal implementation for parsing Dialler PUT response.
     * @param responseBody Raw response body
     * @return Lead Lead to update, or null if unparseable
     */
    private static Lead parsePutResponseInternal(String responseBody) {
        if (String.isBlank(responseBody)) {
            return null;
        }
        
        INS_DTO_UpdateDiallerLeadResponse dto = 
            (INS_DTO_UpdateDiallerLeadResponse) parseDto(responseBody, INS_DTO_UpdateDiallerLeadResponse.class);
        
        if (dto == null || isGlobalError(dto, dto.error, dto.status_code)) {
            return null;
        }
        
        // PUT: moreInformation (JWT/auth) check
        if (String.isNotBlank(dto.moreInformation)) {
            return null;
        }
        
        // PUT: message check when no LeadGenerationResponse
        if (dto.LeadGenerationResponse == null && String.isNotBlank(dto.message)) {
            return null;
        }
        
        if (dto.LeadGenerationResponse == null || dto.LeadGenerationResponse.isEmpty()) {
            return null;
        }
        
        for (INS_DTO_UpdateDiallerLeadResponse.LeadGenerationResponse item : dto.LeadGenerationResponse) {
            Lead lead = buildLeadFromPutItem(item);
            if (lead != null) {
                return lead;
            }
        }
        
        return null;
    }
    
    /**
     * @description Builds a Lead record from a PUT response item.
     * @param item PUT response item
     * @return Lead Lead to update, or null if invalid
     */
    private static Lead buildLeadFromPutItem(INS_DTO_UpdateDiallerLeadResponse.LeadGenerationResponse item) {
        try {
            if (item == null) {
                return null;
            }
            
            String targetId = String.isNotBlank(item.leadId) ? item.leadId : item.id;
            if (String.isBlank(targetId)) {
                return null;
            }
            
            Lead lead = new Lead(Id = targetId);
            
            if (String.isNotBlank(item.errorCode)) {
                applyItemFailure(lead, item.message, item.errorCode);
            } else {
                applyItemSuccess(lead, item.id);
            }
            
            return lead;
        } catch (Exception e) {
            LOGGER.error('buildLeadFromPutItem | ' + e.getMessage());
            return null;
        }
    }
    
    // ============================================================
    // GENERIC PARSING HELPERS
    // ============================================================
    
    /**
     * @description Parses JSON response body into the specified DTO class.
     * @param responseBody Raw JSON string
     * @param dtoType DTO class type
     * @return Object Parsed DTO or null
     */
    private static Object parseDto(String responseBody, Type dtoType) {
        try {
            return JSON.deserialize(responseBody, dtoType);
        } catch (Exception e) {
            LOGGER.error('parseDto | parse failed | ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * @description Checks if DTO contains global error (null DTO, error node, or fatal status).
     * @param dto Parsed DTO
     * @param errorNode Error node from DTO
     * @param statusCode HTTP status code
     * @return Boolean True if global error exists
     */
    private static Boolean isGlobalError(Object dto, Object errorNode, Integer statusCode) {
        if (dto == null) {
            return true;
        }
        if (errorNode != null) {
            return true;
        }
        if (isFatalStatus(statusCode)) {
            return true;
        }
        return false;
    }
    
    // ============================================================
    // ITEM APPLICATION (SHARED BY POST & PUT)
    // ============================================================
    
    /**
     * @description Applies failure details to Lead when item contains errorCode.
     * @param lead Lead to update
     * @param message Error message
     * @param errorCode Error code (fallback)
     */
    private static void applyItemFailure(Lead lead, String message, String errorCode) {
        try {
            String failure = String.isNotBlank(message) ? message : errorCode;
            if (String.isBlank(failure)) {
                failure = 'Unknown error';
            }
            lead.Dialer_Failure_Reason__c = failure.left(255);
            LOGGER.error('applyItemFailure | leadId=' + lead.Id + ' | ' + failure);
        } catch (Exception e) {
            LOGGER.error('applyItemFailure | ' + e.getMessage());
        }
    }
    
    /**
     * @description Applies success details to Lead when item has no errorCode.
     * @param lead Lead to update
     * @param referenceId Dialler reference number
     */
    private static void applyItemSuccess(Lead lead, String referenceId) {
        try {
            lead.Referred_System_Reference_Number__c = referenceId;
            lead.Dialer_Failure_Reason__c = '';
        } catch (Exception e) {
            LOGGER.error('applyItemSuccess | ' + e.getMessage());
        }
    }
    
    // ============================================================
    // ERROR MESSAGE EXTRACTION
    // ============================================================
    
    /**
     * @description Internal logic for extracting error message.
     * @param responseDto Parsed DTO
     * @param defaultMsg Fallback message
     * @return String Error message
     */
    private static String extractErrorMessageInternal(Object responseDto, String defaultMsg) {
        if (responseDto == null) {
            return defaultMsg;
        }
        
        String rawText = getRawError(responseDto);
        if (String.isBlank(rawText)) {
            return defaultMsg;
        }
        
        try {
            Map<String, Object> topJson = (Map<String, Object>) JSON.deserializeUntyped(rawText);
            return extractFromTopJson(topJson, defaultMsg);
        } catch (Exception ex) {
            LOGGER.error('extractErrorMessageInternal | JSON parse failed | ' + ex.getMessage());
            return rawText.left(255);
        }
    }
    
    /**
     * @description Gets raw error text from a DTO (POST or PUT).
     *              Priority: moreInformation > error.errorDescription > httpMessage > message
     * @param dto Parsed DTO
     * @return String Raw error text
     */
/**
 * @description Gets raw error text from a DTO (POST or PUT).
 * @param dto Parsed DTO
 * @return String Raw error text, or null if none found
 */
private static String getRawError(Object dto) {
    if (dto == null) {
        return null;
    }
    
    return getFirstNonBlank(buildErrorValues(dto));
}

/**
 * @description Builds priority-ordered error values from DTO.
 * @param dto Parsed DTO
 * @return List<String> Priority-ordered error values
 */
private static List<String> buildErrorValues(Object dto) {
    List<String> errorValues = new List<String>();
    
    if (dto instanceof INS_DTO_DiallerLeadsResponse) {
        INS_DTO_DiallerLeadsResponse postDto = (INS_DTO_DiallerLeadsResponse) dto;
        errorValues.add(postDto.moreInformation);
        errorValues.add(postDto.errorDescription);
        errorValues.add(postDto.errorMessage);
        //errorValues.add(getErrorDescription(postDto.error));
        errorValues.add(postDto.httpMessage);
        errorValues.add(postDto.message);
        
    } else if (dto instanceof INS_DTO_UpdateDiallerLeadResponse) {
        INS_DTO_UpdateDiallerLeadResponse putDto = (INS_DTO_UpdateDiallerLeadResponse) dto;
        errorValues.add(putDto.moreInformation);
        errorValues.add(putDto.errorDescription);
        errorValues.add(putDto.errorMessage);
        //errorValues.add(getErrorDescription(putDto.error));
        errorValues.add(putDto.httpMessage);
        errorValues.add(putDto.message);
    }
    
    return errorValues;
}

/**
 * @description Returns first non-blank from list.
 * @param errorValues List of error values
 * @return String First non-blank, or null
 */
private static String getFirstNonBlank(List<String> errorValues) {
    for (String errorValue : errorValues) {
        if (String.isNotBlank(errorValue)) {
            return errorValue;
        }
    }
    return null;
}

/**
 * @description Safely extracts errorDescription from POST DiallerError.
 */
/*private static String getErrorDescription(INS_DTO_DiallerLeadsResponse.DiallerError error) {
    if (error == null) {
        return null;
    }
    return error.errorDescription;
} */

/**
 * @description Safely extracts errorDescription from PUT DiallerError.
 */
/*private static String getErrorDescription(INS_DTO_UpdateDiallerLeadResponse.DiallerError error) {
    if (error == null) {
        return null;
    }
    return error.errorDescription;
} */
    
    /**
     * @description Extracts error message from top-level JSON map.
     *              Handles both map-form and list-form error nodes.
     * @param topJson Parsed JSON
     * @param defaultMsg Fallback message
     * @return String Error message
     */
    private static String extractFromTopJson(Map<String, Object> topJson, String defaultMsg) {
        if (!topJson.containsKey(KEY_ERROR)) {
            return defaultMsg;
        }
        
        Object errorNode = topJson.get(KEY_ERROR);
        
        if (errorNode instanceof Map<String, Object>) {
            String msg = extractFromErrorMap((Map<String, Object>) errorNode);
            if (String.isNotBlank(msg)) {
                return msg.left(255);
            }
        }
        
        if (errorNode instanceof List<Object>) {
            List<Object> errorList = (List<Object>) errorNode;
            for (Object item : errorList) {
                if (item instanceof Map<String, Object>) {
                    String msg = extractFromErrorMap((Map<String, Object>) item);
                    if (String.isNotBlank(msg)) {
                        return msg.left(255);
                    }
                }
            }
        }
        
        return defaultMsg;
    }
    
    /**
     * @description Extracts error message from map-form error node.
     *              Priority: errorMessage > detail > title > nested errorDescription
     * @param errMap Error map
     * @return String Error message
     */
    private static String extractFromErrorMap(Map<String, Object> errMap) {
        if (errMap.containsKey(KEY_ERROR_MESSAGE)) {
            String msg = String.valueOf(errMap.get(KEY_ERROR_MESSAGE)).trim();
            if (String.isNotBlank(msg)) {
                return msg;
            }
        }
        
        if (errMap.containsKey(KEY_DETAIL)) {
            String msg = String.valueOf(errMap.get(KEY_DETAIL)).trim();
            if (String.isNotBlank(msg)) {
                return msg;
            }
        }
        
        if (errMap.containsKey(KEY_TITLE)) {
            String msg = String.valueOf(errMap.get(KEY_TITLE)).trim();
            if (String.isNotBlank(msg)) {
                return msg;
            }
        }
        
        if (errMap.containsKey(KEY_ERROR_DESCRIPTION)) {
            String nested = String.valueOf(errMap.get(KEY_ERROR_DESCRIPTION));
            return parseNestedError(nested);
        }
        
        return null;
    }
    
    /**
     * @description Parses nested error text (may be JSON) and extracts message.
     * @param nestedText Nested error text
     * @return String Error message
     */
    private static String parseNestedError(String nestedText) {
        if (String.isBlank(nestedText)) {
            return null;
        }
        
        try {
            Map<String, Object> nestedJson = (Map<String, Object>) JSON.deserializeUntyped(nestedText);
            return extractNestedErrorMsg(nestedJson);
        } catch (Exception ex) {
            return nestedText.trim().left(255);
        }
    }
    
    /**
     * @description Extracts message from nested JSON (error.errorMessage structure).
     * @param nestedJson Parsed nested JSON
     * @return String Error message
     */
    private static String extractNestedErrorMsg(Map<String, Object> nestedJson) {
        if (!nestedJson.containsKey(KEY_ERROR)) {
            return null;
        }
        
        Object errorNode = nestedJson.get(KEY_ERROR);
        if (!(errorNode instanceof Map<String, Object>)) {
            return null;
        }
        
        Map<String, Object> innerVal = (Map<String, Object>) errorNode;
        if (innerVal.containsKey(KEY_ERROR_MESSAGE)) {
            return String.valueOf(innerVal.get(KEY_ERROR_MESSAGE)).trim().left(255);
        }
        
        return null;
    }
}