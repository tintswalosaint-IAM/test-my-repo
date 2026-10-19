public class INS_DTO_DotsureLeadResponse {
    
    public Integer status_code;
    public String status;
    public String message;
    public LeadGenerationResponse LeadGenerationResponse;
    
    public class LeadGenerationResponse {
        public String id;
        public String message;
    }
    
    public class InnerResponse {
        public List<Integer> leadIds;
        public Integer statusCode;
        public Boolean filteringApplied;
        public String filteringSkippedReason;
        public String id;
        public Integer status;
        public String message;
    }
    
    /**
     * @description Parses JSON string into InnerResponse object
     * @param jsonString JSON string to parse
     * @return InnerResponse or null if parsing fails
     **/
    public static InnerResponse parseInnerResponse(String jsonString) {
        if (String.isBlank(jsonString)) {
            return null;
        }
        try {
            return (InnerResponse) JSON.deserialize(jsonString, InnerResponse.class);
        } catch (Exception ex) {
            return null;
        }
    }
    
    /**
     * @description Checks if InnerResponse represents a successful lead creation
     * @param inner InnerResponse to check
     * @return true if statusCode is 201 and leadIds is not empty
     **/
    public static Boolean isInnerSuccess(InnerResponse innerRes) {
        return innerRes != null 
            && innerRes.statusCode == 201 
            && innerRes.leadIds != null 
            && !innerRes.leadIds.isEmpty();
    }
    
    /**
     * @description Extracts the first lead ID from InnerResponse
     * @param inner InnerResponse to extract from
     * @return First lead ID or null if not available
     **/
    public static String extractLeadId(InnerResponse innerRes) {
        if (innerRes == null || innerRes.leadIds == null || innerRes.leadIds.isEmpty()) {
            return null;
        }
        return String.valueOf(innerRes.leadIds[0]);
    }
}