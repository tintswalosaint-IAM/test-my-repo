/**
 * @description  Resolves the Mobi quote reference from a supplied identifier.
 *
 *               When the supplied value is a Salesforce Quote record Id, the
 *               underwriter reference is read from the record server-side, so a
 *               tampered Mobi reference cannot be used. When it is already a Mobi
 *               reference (new-quote path, before the Salesforce Quote record
 *               exists), it is returned as supplied.
 *
 *               Addresses the IDOR finding where a tampered quoteId allowed read
 *               and write access to other customers' quotes. Coverage is the
 *               resume-quote path only; ownership enforcement on the new-quote
 *               path is being addressed API-side.
 *
 * @author       Irshad
 */
public with sharing class INS_CTRL_QuoteReferenceResolver {

    /**
     * @description Resolves the Mobi quote reference from the supplied identifier.
     * @param suppliedQuoteId A Salesforce Quote record Id, or a Mobi quote reference
     * @return                The Mobi quote reference to use for the callout
     */
    public static String resolve(String suppliedAccId) {
        if (String.isBlank(suppliedAccId)) {
            throw new AuraHandledException('Account Id is required.');
        }

        if (!isSalesforceQuoteId(suppliedAccId)) {
            // New-quote path — Mobi reference supplied directly
            return suppliedAccId;
        }
		List<Quote> quotes = new SEL_Quote().selectInProgressByAccIdsWoSharing(new List<Id>{ suppliedAccId });
        

        if (quotes.isEmpty() || String.isBlank(quotes[0].UnderwriterQuoteReferenceNumber__c)) {
            throw new AuraHandledException('No quote reference found for this quote.');
        }

        return quotes[0].UnderwriterQuoteReferenceNumber__c;
    }

    /**
     * @description Determines whether the supplied value is a Salesforce Quote
     *              record Id, as opposed to a Mobi quote reference GUID.
     * @param value The identifier to test
     * @return      True when the value is a Quote record Id
     */
    private static Boolean isSalesforceQuoteId(String value) {
        try {
            Id recordId = Id.valueOf(value);
            return recordId.getSObjectType() == Account.SObjectType;
        } catch (Exception e) {
            return false;
        }
    }
}