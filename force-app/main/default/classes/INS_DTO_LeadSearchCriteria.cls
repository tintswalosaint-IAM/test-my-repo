/**
 * @description        : DTO class used to hold lead search and filtering criteria.
 * @author             : Raja Arsalan
 * @date               : Jan 2026
 * @LastModified       : Raja Arsalan
 * @LastModifiedReason : Modified the class to add 
 * 						 status and stage varaiables.
 */

 public class INS_DTO_LeadSearchCriteria {
    public String leadType;
    public Datetime connexDate;
    public String productFamily;
    public String searchKey;
    public Datetime startDate;
    public Datetime endDate;
    public Boolean isReport;
    public String campaignName;
    public String campaignSourceId;
    public String status;
    public String stage;
}