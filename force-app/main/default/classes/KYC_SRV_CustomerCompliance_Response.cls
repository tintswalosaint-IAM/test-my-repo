/** 
 * Created by: Irshad as part of US:SFP-51839
 * Purpose: This class is used to parse the JSON response from the Customer Compliance API.
 * 
 */

public with sharing class KYC_SRV_CustomerCompliance_Response {
    public String customerId;
    public cls_assessmentResult assessmentResult;

    public class cls_assessmentResult {
        public String assessmentId;
        public String status;
        public String result;
        public List<cls_screeningResults> screeningResults;
        public List<cls_additionalDetails> additionalDetails;
    }

    public class cls_screeningResults {
        public String screeningId;
        public String screeningType;
        public String screeningName;
        public String result;
    }

    public class cls_additionalDetails {
        public String Pep_Type;
        public Double TotalScore;
        public String CRA_Category;
    }

    public static KYC_SRV_CustomerCompliance_Response parse(String json){
        return (KYC_SRV_CustomerCompliance_Response)
            System.JSON.deserialize(json, KYC_SRV_CustomerCompliance_Response.class);
    }
}