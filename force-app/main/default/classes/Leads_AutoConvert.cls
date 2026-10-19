/**
 * @description Allows leads to autoconvert, it also allows the user to decide if an opportunity needs to be created or not
 * @param recieves a lead, an optional opportunity and an account to convert
 * @author Facu
 * @date March 2023
 * @last modified by Tintswalo Mushwana
 * @last modified date August 2026
 * @changelog
 *   - March 2023: Initial implementation. (Facundo Dhers)
 *   - July 2026: Tech Debt remediation. (Tintswalo Mushwana)
 *             
 */

public inherited sharing class Leads_AutoConvert {
    
    /**
     * @description Invocable class that can be used in a screen flow to mark a lead as converted
     * @return a boolean confirming if the convert process was successfull
     * @param recieves a lead, an optional opportunity and an account to convert
     */
    
    @InvocableMethod(label = 'AutoConvert Leads')
    public static List<Result> leadConvert(List<Request> requests) {
        List<Result> responseWrapper = new List<Result>();
        
        // Collect all status names
        Set<String> statusNames = new Set<String>();
        for (Request req : requests) {
            statusNames.add(req.status);
        }
        
        // Query once via Selector
        Map<String, LeadStatus> statusMap = CMN_SEL_LeadStatus.getConvertedStatusesByName(statusNames);
        
        // Build all LeadConvert records
        List<Database.LeadConvert> allConverts = new List<Database.LeadConvert>();
        Map<Integer, Integer> requestToConvertIndex = new Map<Integer, Integer>();
        
        for (Integer i = 0; i < requests.size(); i++) {
            Result response = new Result();
            response.isSuccess = false;
            
            Database.LeadConvert leadConversion = buildLeadConvert(requests[i], statusMap);
            if (leadConversion != null) {
                requestToConvertIndex.put(i, allConverts.size());
                allConverts.add(leadConversion); 
            } 
            
            responseWrapper.add(response);
        }
        
        // Execute DML once
        if (!allConverts.isEmpty()) {
            List<Database.LeadConvertResult> results = Database.convertLead(allConverts, false);
            
            for (Integer i = 0; i < requests.size(); i++) {
                if (requestToConvertIndex.containsKey(i)) {
                    Integer convertIndex = requestToConvertIndex.get(i);
                    responseWrapper[i].isSuccess = results[convertIndex].isSuccess();
                }
            }
        }
        
        return responseWrapper;
    }
    
    /**
     * @description Builds a Database.LeadConvert record from a request, returns null if data is invalid
     * @param req The request containing lead and conversion details
     * @param statusMap Map of valid converted statuses
     * @return A Database.LeadConvert record or null if status/account is missing
     */
    private static Database.LeadConvert buildLeadConvert(Request req, Map<String, LeadStatus> statusMap) {
        LeadStatus convertedStatus = statusMap.get(req.status);
        
        Id accountId;
        if (req.accountId == null) {
            accountId = req.leadToConvert.FinServ__RelatedAccount__c;
        } else {
            accountId = req.accountId;
        }
        
        if (convertedStatus == null || accountId == null) {
            return null;
        }
        
        // Build conversion request
        Database.LeadConvert leadConversion = new Database.LeadConvert();
        leadConversion.setLeadId(req.leadToConvert.Id);
        leadConversion.setConvertedStatus(convertedStatus.MasterLabel);
        leadConversion.setAccountId(accountId);
        
        if (req.opportunityToLink == null) {
            leadConversion.setDoNotCreateOpportunity(true);
        } else {
            leadConversion.setOpportunityId(req.opportunityToLink.Id);
            leadConversion.setDoNotCreateOpportunity(false);
        }
        
        return leadConversion;
    }
    
    /**
     * @description Allows results to be sent back to the flow
     * @date March 2023
     */
    public class Result{
        @InvocableVariable (label='Result' description='Will be true if all leads converted successfully')
        public Boolean isSuccess;
    }
    
    /**
     * @description Allows variables to be sent from the flow into the class
     * @date March 2023
     */
    public class Request{
        @InvocableVariable (label='Lead to be converted' required=true )
        public Lead leadToConvert;
        @InvocableVariable (label='Converted status Name' required=true)
        public String status;
        @InvocableVariable (label='Opportunity')
        public Opportunity  opportunityToLink;
        @InvocableVariable (label='AccountId')
        public Id accountId;
    }
}