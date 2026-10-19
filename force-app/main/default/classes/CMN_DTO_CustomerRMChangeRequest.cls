/**
 * @description       : CMN_DTO_CustomerRMChangeRequest Apex class for Update Customer API
 * @author            : Muvhuso
 * @group             : PPB Maintain Customer
 * @last modified on  : February 2026
 * SFP :SFP-50270
**/
public class CMN_DTO_CustomerRMChangeRequest {  
    public String customerType {get;set;}
    @AuraEnabled public String sbsaGroup {get;set;}
    @AuraEnabled public String relManager {get;set;}

}