/**
 * @description       : Apex class for Customer Quotes retrieval - recent quotes
 * @author            : Madito Tsilo
 * @modified          : Moukeswar M (Keshav) | 20-11-2025
 * @UserStory         : SFP-52960
 * @date              : 31-10-2025
 ***************************************************
 * Last Modified By Shams
 * Last Modified Date 24/07/2026
 * Last Modified Description: Added functionilty to retrieve opportunity close dates for the opportunities related to the quotes
 * User Story : SFP-59435
**/
public with sharing class INS_PLI_CustomerQuotes {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PLI_CustomerQuotes'); 
 @AuraEnabled(cacheable=true)
    public static List<QuoteWrapper> getCustomerQuotes() {
        try{                         
            User usr = new SEL_User().selectUserById(UserInfo.getUserId());
            if (hasNoAccount(usr)) {
                return createErrorResult('No Account found for the logged-in user.');
            }

            List<Quote> quoteList = new SEL_Quote().selectByAccIdsWoSharing(
                new List<Id>{usr.Contact.AccountId}
            );
            Map<Id, Opportunity> opportunitiesById = getOpportunities(quoteList);
            List<Quote> availableQuotes = filterAvailableQuotes(quoteList, opportunitiesById);
            Map<Id, Date> opportunityCloseDates = getOpportunityCloseDates(opportunitiesById);
            List<QuoteWrapper> wrapperList = createQuoteWrappers(quoteList, opportunityCloseDates);
            return addEmptyResultMessage(wrapperList);
        }catch(Exception e){
          LOGGER.error(e.getMessage(),new String[]{'INS_PLI_CustomerQuotes.getCustomerQuotes',e.getMessage()},e);          
          throw new AuraHandledException('Failed to get customer quotes ' + e.getMessage()); 
        }
    }    

    /**
     * @description Determines whether the logged-in user is linked to an account.
     * @param usr User record for the logged-in user.
     * @return Boolean indicating whether no account is available.
     */
    private static Boolean hasNoAccount(User usr) {
        return usr == null || usr.Contact == null || usr.Contact.AccountId == null;
    }

    /**
     * @description Retrieves opportunities related to the quotes.
     * @param quoteList Quotes returned for the logged-in user's account.
     * @return Map of opportunity IDs to opportunities.
     */
    private static Map<Id, Opportunity> getOpportunities(List<Quote> quoteList) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Quote quoteRecord : quoteList) {
            if (quoteRecord.OpportunityId != null) {
                opportunityIds.add(quoteRecord.OpportunityId);
            }
        }

        Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>();
        if (opportunityIds.isEmpty()) {
            return opportunitiesById;
        }

        for (Opportunity opportunityRecord : new SEL_Opportunity().selectCloseDateByIdsWoSharing(opportunityIds)) {
            opportunitiesById.put(opportunityRecord.Id, opportunityRecord);
        }
        return opportunitiesById;
    }

    /**
     * @description Excludes quotes related to closed-won or closed-lost opportunities.
     * @param quoteList Quotes returned for the logged-in user's account.
     * @param opportunitiesById Opportunities keyed by opportunity ID.
     * @return Quotes linked to opportunities that are not closed won or closed lost.
     */
    private static List<Quote> filterAvailableQuotes(
        List<Quote> quoteList,
        Map<Id, Opportunity> opportunitiesById
    ) {
        List<Quote> availableQuotes = new List<Quote>();
        for (Quote quoteRecord : quoteList) {
            Opportunity opportunityRecord;
            if (quoteRecord.OpportunityId != null) {
                opportunityRecord = opportunitiesById.get(quoteRecord.OpportunityId);
            }
            if (opportunityRecord == null ||
                (opportunityRecord.StageName != 'Closed Won' && opportunityRecord.StageName != 'Closed Lost')) {
                availableQuotes.add(quoteRecord);
            }
        }
        return availableQuotes;
    }

    /**
     * @description Retrieves opportunity close dates from the opportunity records.
     * @param opportunitiesById Opportunities keyed by opportunity ID.
     * @return Map of opportunity IDs to close dates.
     */
    private static Map<Id, Date> getOpportunityCloseDates(Map<Id, Opportunity> opportunitiesById) {
        Map<Id, Date> closeDatesByOpportunity = new Map<Id, Date>();
        for (Opportunity opportunityRecord : opportunitiesById.values()) {
            closeDatesByOpportunity.put(opportunityRecord.Id, opportunityRecord.CloseDate);
        }
        return closeDatesByOpportunity;
    }

    /**
     * @description Converts quote records into quote wrapper records for the client.
     * @param quoteList Quotes returned for the logged-in user's account.
     * @param opportunityCloseDates Opportunity close dates keyed by opportunity ID.
     * @return List of quote wrappers.
     */
    private static List<QuoteWrapper> createQuoteWrappers(
        List<Quote> quoteList,
        Map<Id, Date> opportunityCloseDates
    ) {
        List<QuoteWrapper> wrapperList = new List<QuoteWrapper>();
        for (Quote quoteRecord : quoteList) {
            QuoteWrapper wrapper = new QuoteWrapper();
            wrapper.Id = quoteRecord.Id;
            wrapper.name = quoteRecord.Name;
            wrapper.policyNumber = quoteRecord.QuoteNumber;
            wrapper.estimatedPayment = getEstimatedPayment(quoteRecord);
            wrapper.expires = getExpiryDate(quoteRecord, opportunityCloseDates);
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }

    /**
     * @description Formats the monthly premium for a quote.
     * @param quoteRecord Quote record containing the monthly premium.
     * @return Monthly premium as a string, or an empty string when unavailable.
     */
    private static String getEstimatedPayment(Quote quoteRecord) {
        if (quoteRecord.INS_MonthlyPremium__c == null) {
            return '';
        }
        return String.valueOf(quoteRecord.INS_MonthlyPremium__c);
    }

    /**
     * @description Determines the quote expiry date using the opportunity close date first.
     * @param quoteRecord Quote record being formatted.
     * @param opportunityCloseDates Opportunity close dates keyed by opportunity ID.
     * @return Expiry date as a string, or an empty string when unavailable.
     */
    @TestVisible
    private static String getExpiryDate(Quote quoteRecord, Map<Id, Date> opportunityCloseDates) {
        Date closeDate;
        if (quoteRecord.OpportunityId != null) {
            closeDate = opportunityCloseDates.get(quoteRecord.OpportunityId);
        }
        if (closeDate != null) {
            return String.valueOf(closeDate);
        }
        if (quoteRecord.ExpirationDate != null) {
            return String.valueOf(quoteRecord.ExpirationDate);
        }
        return '';
    }

    /**
     * @description Adds the standard empty-result message when no quotes are available.
     * @param wrapperList Quote wrappers to update.
     * @return The supplied list, including an empty-result wrapper when required.
     */
    private static List<QuoteWrapper> addEmptyResultMessage(List<QuoteWrapper> wrapperList) {
        if (wrapperList.isEmpty()) {
            wrapperList.add(createErrorWrapper('No quotes found for your account.'));
        }
        return wrapperList;
    }

    /**
     * @description Creates a single-item result containing an error message.
     * @param message Error message to expose to the client.
     * @return List containing an error wrapper.
     */
    private static List<QuoteWrapper> createErrorResult(String message) {
        return new List<QuoteWrapper>{createErrorWrapper(message)};
    }

    /**
     * @description Creates a quote wrapper containing an error message.
     * @param message Error message to expose to the client.
     * @return Quote wrapper containing the supplied error message.
     */
    private static QuoteWrapper createErrorWrapper(String message) {
        QuoteWrapper wrapper = new QuoteWrapper();
        wrapper.errorMessage = message;
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<QuoteWrapper> getCustomerQuoteById(String quoteId) {
        try {
            User usr = new SEL_User().selectUserById(UserInfo.getUserId());

            if (hasNoAccount(usr)) {
                return createErrorResult('No Account found for the logged-in user.');
            }

            if (String.isBlank(quoteId)) {
                return createErrorResult('Quote Id is required.');
            }

            List<Quote> quoteList = new SEL_Quote().selectByIdsWoSharing(
                new List<Id>{ (Id) quoteId }
            );

            if (quoteList.isEmpty()) {
                return createErrorResult('Quote not found.');
            }

            Quote quoteRecord = quoteList[0];

            // Get Opportunity
            Opportunity opportunity;
            if (quoteRecord.OpportunityId != null) {
                opportunity = getOpportunitiesByQuote(quoteRecord.OpportunityId);
            }

            // Get Account
            Account account;
            if (quoteRecord.AccountId != null) {
                List<Account> accountList = new SEL_Account().selectByIdsWoSharing(
                    new Set<Id>{ quoteRecord.Opportunity.AccountId }
                );

                if (!accountList.isEmpty()) {
                    account = accountList[0];
                }
            }

            // Create Quote Wrapper
            QuoteWrapper wrapper = new QuoteWrapper();

            wrapper.Id = quoteRecord.Id;
            wrapper.name = quoteRecord.Name;
            wrapper.policyNumber = quoteRecord.QuoteNumber;
           // wrapper.estimatedPayment = getEstimatedPayment(quoteRecord);
            wrapper.expires = String.valueOf(quoteRecord.ExpirationDate);

            // Opportunity Details
            if (opportunity != null) {
                OpportunityWrapper opportunityDetails = new OpportunityWrapper();

                opportunityDetails.Id = opportunity.Id;
                opportunityDetails.coverAmount =
                    String.valueOf(opportunity.Total_Cover_Amount__c);
                opportunityDetails.monthlyPremium =
                    String.valueOf(opportunity.Total_Monthly_Premium__c);

                wrapper.opportunityDetails = opportunityDetails;
            }

            // Account Details
            if (account != null) {
                AccountWrapper accountDetails = new AccountWrapper();

                accountDetails.Id = account.Id;
                accountDetails.firstName = account.FirstName;
                accountDetails.lastName = account.LastName;
                accountDetails.email = account.PersonEmail;
                accountDetails.phone = account.Phone;
                accountDetails.dateofBirth = String.valueOf(account.Date_of_Birth__c);
                accountDetails.identityNumber = String.valueOf(account.AOB_IdentityNumber__c);

                wrapper.accountDetails = accountDetails;
            }

            List<QuoteWrapper> wrapperList = new List<QuoteWrapper>();
            wrapperList.add(wrapper);

            return addEmptyResultMessage(wrapperList);

        } catch (Exception e) {
            LOGGER.error(
                e.getMessage(),
                new String[]{
                    'INS_PLI_CustomerQuotes.getCustomerQuoteById',
                    e.getMessage()
                },
                e
            );

            throw new AuraHandledException(
                'Failed to get customer quote ' + e.getMessage()
            );
        }
    }

    public static Opportunity getOpportunitiesByQuote(Id opportunityId) {

        if (opportunityId == null) {
            return null;
        }

        List<Opportunity> opportunityList = new SEL_Opportunity().selectByIdsWoSharing(
            new Set<Id>{ opportunityId }
        );           

        if (opportunityList.isEmpty()) {
            return null;
        }

        return opportunityList[0];
    }
    

    public class QuoteWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String name;
        @AuraEnabled public String policyNumber;
        @AuraEnabled public String estimatedPayment;
        @AuraEnabled public String expires;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public OpportunityWrapper opportunityDetails;
        @AuraEnabled public AccountWrapper accountDetails;
    }
    public class OpportunityWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String coverAmount;
        @AuraEnabled public String monthlyPremium;
    }
    public class AccountWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String dateofBirth;
        @AuraEnabled public String identityNumber;
    }
}