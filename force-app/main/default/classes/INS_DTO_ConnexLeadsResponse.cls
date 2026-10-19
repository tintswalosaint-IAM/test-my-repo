public class INS_DTO_ConnexLeadsResponse extends CMN_DTO_JsonBase {
    public Integer status_code;
    public String status;
    public String message;
    public String httpCode;
    public String httpMessage;
    public String moreInformation;
    public LeadGenerationResponse LeadGenerationResponse;
    public ConnexError error;
    
    public class ConnexError {
        public String errorCode;
        public String errorDescription;
    } 

    // Inner classes for nested structure
    public class LeadGenerationResponse {
        public String id;
        public String message;
    }

    public class LeadGenerationResponseItem {
        public Integer index;
        public Boolean success;
        public String contact_data_id;
        public String source_reference;
        public List<ResponseItemError> errors;
    }

    public class ResponseItemError {
        public Map<String, Object> params;
        public String keyword;
        public String message;
        public String dataPath;
        public String schemaPath;
    }

    public static INS_DTO_ConnexLeadsResponse parse(String jsonResponse) {
        return (INS_DTO_ConnexLeadsResponse) JSON.deserialize(jsonResponse, INS_DTO_ConnexLeadsResponse.class);
    }

    public static List<LeadGenerationResponseItem> parseResponseItems(String jsonContent) {
        List<LeadGenerationResponseItem> result = new List<LeadGenerationResponseItem>();
        Object parsed = JSON.deserializeUntyped(jsonContent);

        if (parsed instanceof List<Object>) {
            for (Object item : (List<Object>) parsed) {
                result.add(parseSingleItem(JSON.serialize(item)));
            }
        } else {
            result.add(parseSingleItem(jsonContent));
        }
        return result;
    }

    private static LeadGenerationResponseItem parseSingleItem(String itemJson) {
        Map<String, Object> itemMap = (Map<String, Object>) JSON.deserializeUntyped(itemJson);
        LeadGenerationResponseItem item = new LeadGenerationResponseItem();

        item.index = (Integer) itemMap.get('index');
        item.success = (Boolean) itemMap.get('success');
        item.contact_data_id = (String) itemMap.get('contact_data_id');
        item.source_reference = (String) itemMap.get('source_reference');

        if (itemMap.containsKey('errors')) {
            item.errors = new List<ResponseItemError>();
            for (Object errObj : (List<Object>) itemMap.get('errors')) {
                Map<String, Object> errMap = (Map<String, Object>) errObj;
                ResponseItemError err = new ResponseItemError();
                err.params = (Map<String, Object>) errMap.get('params');
                err.keyword = (String) errMap.get('keyword');
                err.message = (String) errMap.get('message');
                err.dataPath = (String) errMap.get('dataPath');
                err.schemaPath = (String) errMap.get('schemaPath');
                item.errors.add(err);
            }
        }
        return item;
    }

    // Override from CMN_DTO_JsonBase (if needed)
    protected override Type getObjectType() {
        return INS_DTO_ConnexLeadsResponse.class;
    }
}