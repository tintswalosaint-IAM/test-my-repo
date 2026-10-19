/**
* @description Wrapper Class for Account Details API response
*
* @author Gnitsevich Anton
*
* @date September 2021
*/
public with sharing class CMN_DTO_CustomerValidityInfoResponse {

    @AuraEnabled public GetCustomerValidityInfoResponse getCustomerValidityInfoResponse { get; set; }

/**
* @description Inner Class for Account Details API response Class
*/
    public class GetCustomerValidityInfoResponse {
        @AuraEnabled public List<ComplianceData> complianceData { get; set; }
    }
    
/**
* @description Inner Class for Account Details API response Class
*/
    public class ComplianceData {
        @AuraEnabled public ComplianceType complianceType { get; set; }
        @AuraEnabled public ComplianceStatus complianceStatus { get; set; }
        @AuraEnabled public String complianceInd { get; set; }
    }

/**
* @description Inner Class for Account Details API response Class
*/
    public class ComplianceType {
        @AuraEnabled public String description { get; set; }
    }
    
/**
* @description Inner Class for Account Details API response Class
*/
    public class ComplianceStatus {
        @AuraEnabled public String description { get; set; }
    }
}