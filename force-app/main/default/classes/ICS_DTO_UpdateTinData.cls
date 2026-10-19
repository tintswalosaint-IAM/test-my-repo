/**
 * @description SFP-32986 Class used as wrapper for ICS_API_UpdateTinData.cls
 * @author Ramya Gurran
 * @date 13/10/2024
 ***************************************************** 
 * @last modified on  : 13/10/2024
 * @last modified by  : Ramya Gurram
 * @last modified description: Initial Version
 */
public class ICS_DTO_UpdateTinData {
    public String bpId {get;set;}
    public String contactId {get;set;}
    public List<TaxInfo> taxInfo {get;set;}

    public class TaxInfo {
        public String mainTaxResidency {get;set;}
        public String country {get;set;}
        public String tinNumber {get;set;}
        public String taxExemptReason {get;set;}
    }
}