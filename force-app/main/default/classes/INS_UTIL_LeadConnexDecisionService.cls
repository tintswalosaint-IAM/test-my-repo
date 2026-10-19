/**
* @description Decision rules for Connex insurance lead processing.
* Handles Connex insert eligibility, product-change evaluation,
* and lead-information-change evaluation.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains Connex decision logic extracted from the
* Connex service to reduce method count and improve maintainability.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_UTIL_LeadConnexDecisionService {

    private INS_UTIL_LeadConnexDecisionService() {
    }

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadConnexDecisionService.class.getName());

    private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';


/**
* @description Check whether a lead is eligible for initial Connex insert handling.
* Evaluates insert/update context, unqualified status rules,
* and preferred contact time conditions.
* @param lead Lead record to evaluate
* @param oldLeadMap Map of old Lead records before update
* @return Boolean True if the lead is eligible for Connex insert handling
*/
    public static Boolean eligibleForConnexInsert(Lead lead, Map<Id, Lead> oldLeadMap) {
        Boolean eligibleForInsert = false;
        try {
            if (Trigger.isInsert) {
                eligibleForInsert = true;
            } else if (
                lead.Referred_System_Reference_Number__c == null &&
                lead.Status != LEAD_STATUS_UNQUALIFIED &&
                oldLeadMap != null &&
                oldLeadMap.get(lead.Id) != null &&
                oldLeadMap.get(lead.Id).Status != LEAD_STATUS_UNQUALIFIED
            ) {
                eligibleForInsert = true;
            }

            if (!eligibleForInsert) {
                return eligibleForInsert;
            }

            eligibleForInsert = INS_UTIL_LeadConnexSupport.isPreferredContactTimeNullOrPast(lead);
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadConnexDecisionService | eligibleForConnexInsert | exception | ' + ex);
            eligibleForInsert = false;
        }
        return eligibleForInsert;
    }
/**
* @description Check whether a lead's product changed in a way that requires Connex resubmission.
* Applies status rules, product comparison, and preferred contact time validation.
* @param lead Lead record to evaluate
* @param oldLeadMap Map of old Lead records before update
* @return Boolean True if the lead product changed and requires Connex processing
*/
    public static Boolean hasProductChanged(Lead lead, Map<Id, Lead> oldLeadMap) {
        try {
            if (Trigger.isInsert || oldLeadMap == null) {
                return false;
            }

            Lead oldLead = oldLeadMap.get(lead.Id);
            if (oldLead == null ||
                lead.Status == LEAD_STATUS_UNQUALIFIED ||
                oldLead.Status == LEAD_STATUS_UNQUALIFIED) {
                return false;
            }

            if (lead.Expressed_Interest_Product__c == oldLead.Expressed_Interest_Product__c) {
                return false;
            }

            if (lead.Referred_System_Reference_Number__c == null) {
                return INS_UTIL_LeadConnexSupport.isPreferredContactTimeNullOrPast(lead);
            }

            return true;
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadConnexDecisionService | hasProductChanged | exception | ' + ex);
            return false;
        }
    }
/**
* @description Check whether lead information changed after Connex reference assignment.
* Compares the current lead against the old lead to determine whether a Connex update is needed.
* @param newLead Current Lead record
* @param oldLead Previous Lead record
* @return Boolean True if lead information changed in a way that requires Connex update handling
*/
    public static Boolean leadInfoChanged(Lead newLead, Lead oldLead) {
        try {
            if (oldLead == null ||
                oldLead.Status == LEAD_STATUS_UNQUALIFIED ||
                String.isBlank(oldLead.Referred_System_Reference_Number__c)) {
                return false;
            }

            return newLead.FirstName != oldLead.FirstName ||
                newLead.LastName != oldLead.LastName ||
                newLead.Title != oldLead.Title ||
                newLead.MobilePhone != oldLead.MobilePhone ||
                newLead.Phone != oldLead.Phone ||
                newLead.Email != oldLead.Email ||
                newLead.Loan_Account_Number__c != oldLead.Loan_Account_Number__c ||
                newLead.Description != oldLead.Description ||
                newLead.Preferred_Contact_Date_Time__c != oldLead.Preferred_Contact_Date_Time__c ||
                newLead.Preferred_Contact_Date_Time_End__c != oldLead.Preferred_Contact_Date_Time_End__c ||
                newLead.SA_ID_or_Passport__c != oldLead.SA_ID_or_Passport__c ||
                newLead.Status == LEAD_STATUS_UNQUALIFIED;
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadConnexDecisionService | leadInfoChanged | exception | ' + ex);
            return false;
        }
    }
}