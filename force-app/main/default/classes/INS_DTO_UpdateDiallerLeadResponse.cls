public class INS_DTO_UpdateDiallerLeadResponse extends CMN_DTO_JsonBase {
    public Integer status_code;
    public String status;
    public String message;
    public String httpCode;           
    public String httpMessage;       
    public String moreInformation;
    public String errorCode;
    public String errorMessage;
    public String errorDescription;
    
    public List<LeadGenerationResponse> LeadGenerationResponse;
    public DiallerError error;
    
    public class DiallerError {
        public String errorCode;
        public String errorDescription;
    }

    public class LeadGenerationResponse {
        public String id;
        public String message;
        public String leadId;   
        public String errorCode;
    }

    public static INS_DTO_UpdateDiallerLeadResponse parse(String jsonResponse) {
        return (INS_DTO_UpdateDiallerLeadResponse) JSON.deserialize(jsonResponse, INS_DTO_UpdateDiallerLeadResponse.class);
    }
    
    @testVisible
    protected override Type getObjectType() {
        return INS_DTO_UpdateDiallerLeadResponse.class;
    }
}