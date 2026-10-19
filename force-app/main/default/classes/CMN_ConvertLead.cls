/**
 * @description       : Converts a lead into an opportunity and if required create a new account
 *                      This was based on a similar class (WIS_CTRL_ConvertLead or WI_FLOW_LeadConverter) that was too complex 
 *                      for the A&E (and other use cases).  This version is similar to the standard lead convert process
 * @author            : Sancia Jularr
 * @group             : 
 * @last modified on  : 27-05-2024
 * @last modified by  : Derek Hughes
**/
public with sharing class CMN_ConvertLead {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_ConvertLead.class.getName());
    
    private static final Id PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final Id PROSPECT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();
        
    /**
    * @description Invocable method to be called from Flows.
    * @author Sancia Jularr | 02-04-2024 
    * @param requests 
    * @return List<LeadConversionResult> 
    **/
    @InvocableMethod(label='Convert Lead to Opportunity' category='Lead' description='Convert Lead to an Opportunity and link it to existing or new Account')
    public static List<LeadConversionResult> convertLead(List<LeadConversionRequest> requests) {

        LOGGER.info('convertLead: START(Queries='+Limits.getQueries()+'): requests: '+requests.size());

        try {
            // Validate that only 1 request is present as leads cannot be bulk converted
            if (requests.size() != 1) {
                throw new LeadConvertException('INTERNAL SYSTEM ERROR: Lead Convert only supports 1 Lead at a time and was called with '+requests.size()+' Lead(s).');
            } 

            final Id leadId = requests[0].leadId;

            // Validate lead Id parameter
            if (String.isBlank(leadId)) {
                throw new LeadConvertException('INTERNAL SYSTEM ERROR: Lead Convert called without a Lead Id.');
            } 

            final SEL_Lead leadSelector = new SEL_Lead(false, false, false);
            final List<Lead> leads = leadSelector.selectLeadByRecId(leadId);

            // Validate that only 1 request is present as leads cannot be bulk converted
            if (leads.size() != 1) {
                throw new LeadConvertException('INTERNAL SYSTEM ERROR: Lead Convert called with an invalid/deleted Lead: '+leadId);
            } 

            final Lead leadToConvert = leads[0];

            List<LeadConversionResult> results = new List<LeadConversionResult>();
            LeadConversionResult result = new LeadConversionResult();

            Database.LeadConvert lc = new Database.LeadConvert();

            Id convertedAccountId = determineAccount(leadToConvert);
            LOGGER.trace('convertLead: convertedAccountId='+convertedAccountId);

            lc.setLeadId(leadToConvert.Id);
            lc.setAccountId(convertedAccountId);
            lc.setConvertedStatus('Qualified');

            Database.LeadConvertResult lcr = Database.convertLead(lc);

            if (lcr.isSuccess()) {
                result = new LeadConversionResult(lcr.getLeadId(), lcr.getAccountId(), lcr.getOpportunityId());
            } 
            else {
                Database.Error[] errors = lcr.getErrors();
                // Handle lead conversion failure if needed
                result.success = false;
                result.errorMessage = 'Lead conversion failed for lead Id: ' + leadId + ' with '+errors.size()+' error(s)';
                LOGGER.error('convertLead: ' + result.errorMessage);
            }
        
            LOGGER.info('convertLead: DONE(Queries='+Limits.getQueries()+'): result: '+result);

            results.add(result);
            return results;
        }
        catch (Exception ex) {
            LOGGER.error('convertLead: Unhandled Exception', ex);
            throw ex;
        }

    }
    
    /**
    * @description Determined the converted account - creating a new one if necessary
    * @author Derek Hughes | 04-04-2024 
    * @param leadToConvert 
    * @return Id 
    **/
    private static Id determineAccount (Lead leadToConvert) {
        Id convertedAccountId;
        
        // is the lead already linked to a related account
        if (String.isBlank(leadToConvert.FinServ__RelatedAccount__c)) {
            Account newAccount = new Account(
                FirstName = leadToConvert.FirstName,
                LastName = leadToConvert.LastName
            );

            // determine if the lead is for a client or prospect and set the account record type accordingly
            if (String.isBlank(leadToConvert.External_Client_Identifier__c)) {
                newAccount.RecordTypeId = PROSPECT_PERSON_ACCOUNT_RT_ID;
                insert newAccount;
            }
            else {
                newAccount.RecordTypeId = PERSON_ACCOUNT_RT_ID;

                newAccount.ExternalIdentifier__c = leadToConvert.External_Client_Identifier__c;
                newAccount.ExternalCIFCountry__c = leadToConvert.External_Client_Identifier__c.substring(0, 2);
                newAccount.ExternalSystemId__c = leadToConvert.External_Client_Identifier__c.substring(2, 4);
                newAccount.ExternalCIFId__c = leadToConvert.External_Client_Identifier__c.substring(4, leadToConvert.External_Client_Identifier__c.length());
    
                upsert newAccount ExternalIdentifier__c;
            }
            convertedAccountId = newAccount.Id;
        }
        else {
            convertedAccountId = leadToConvert.FinServ__RelatedAccount__c;
        }
        return convertedAccountId;
    }


    /**
    * @description Incovable request
    * @author Derek Hughes | 04-04-2024 
    **/
    public class LeadConversionRequest {
        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;
    }

     /**
    * @description Incovable response
    * @author Derek Hughes | 04-04-2024 
    **/ 
    public class LeadConversionResult {
        @InvocableVariable(label='Success' required=false)
        public Boolean success;

        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;

        @InvocableVariable(label='Account ID' required=false)
        public Id accountId;

        @InvocableVariable(label='Opportunity ID' required=false)
        public Id opportunityId;

        @InvocableVariable(label='Error Message' required=false)
        public String errorMessage;

        /**
        * @description Default constructor
        * @author Derek Hughes | 19-04-2024 
        **/
        public LeadConversionResult() {
            this.success = false;
        }

        /**
        * @description Constructore with parameters
        * @author Derek Hughes | 19-04-2024 
        * @param leadId 
        * @param accountId 
        * @param opportunityId 
        **/
        public LeadConversionResult(Id leadId, Id accountId, Id opportunityId) {
            this.success = true;
            this.leadId = leadId;
            this.accountId = accountId;
            this.opportunityId = opportunityId;
        }
    }


    private class LeadConvertException extends Exception {}
}