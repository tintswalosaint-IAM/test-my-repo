public class INS_DTO_UpdateConnexLeadResponse extends CMN_DTO_JsonBase {
    public Integer status_code;
    public String status;
    public String message;
    
    public List<LeadGenerationResponse> LeadGenerationResponse;
    public ConnexError error;
    
    public class ConnexError {
        public String errorCode;
        public String errorDescription;
    }

    public class LeadGenerationResponse {
        public String id;
        public String message;
        public String leadId;   
        public String errorCode;
    }

    public static INS_DTO_UpdateConnexLeadResponse parse(String jsonResponse) {
        return (INS_DTO_UpdateConnexLeadResponse) JSON.deserialize(jsonResponse, INS_DTO_UpdateConnexLeadResponse.class);
    }
    
    @testVisible
    protected override Type getObjectType() {
        return INS_DTO_UpdateConnexLeadResponse.class;
    }
}