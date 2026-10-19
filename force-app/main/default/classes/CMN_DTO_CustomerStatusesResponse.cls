/**
* @description Wrapper Class for Account Customers Statuses API response
* @author Kojzar Lukasz
* @date April 2022
*/
public with sharing class CMN_DTO_CustomerStatusesResponse {

    @AuraEnabled public List<CustomerStatus> customerStatuses { get; set; }
    
    /**
    * @description Inner Class for Account Customers Statuses API response
    */
    public class CustomerStatus {
        @AuraEnabled public String description { get; set; }
    }
}