/**
 * @description  Validates that a client-supplied quote reference belongs to the
 *               account in context, before any callout is made against it.
 *
 *               Addresses the IDOR finding where a tampered quoteId allowed read
 *               and write access to other customers' quotes. Note this is
 *               hardening rather than a complete remediation: both the quote
 *               reference and the account id come from client-controlled
 *               OmniScript state, so an attacker who substitutes both would still
 *               pass this check. Closing that requires server-side session
 *               binding, which is tracked separately.
 *
 *               WITHOUT SHARING because the Experience Cloud guest user cannot
 *               see Quote records through sharing — the check would otherwise
 *               always fail.
 *
 * @author       Irshad
 * Test Class    INS_QuoteAccessValidator_TEST
 */
public without sharing class INS_CTRL_QuoteAccessValidator{

    /**
     * @description Throws unless the supplied Mobi quote reference is recorded
     *              against the supplied account.
     * @param quoteId   The Mobi quote reference supplied by the client
     * @param accountId The account the journey is operating on
     * @throws AuraHandledException when either is missing, or no matching Quote exists
     */
    public static void validate(String quoteId, String accountId) {
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Quote Id is required.');
        }
        if (String.isBlank(accountId)) {
            throw new AuraHandledException('Account Id is required.');
        }

        Id accountRecordId;
        try {
            accountRecordId = Id.valueOf(accountId);
        } catch (Exception e) {
            throw new AuraHandledException('Unauthorised request.');
        }

        List<Quote> quotes = [
            SELECT Id
            FROM   Quote
            WHERE  UnderwriterQuoteReferenceNumber__c = :quoteId
            AND    AccountId = :accountRecordId
            LIMIT  1
        ];

        if (quotes.isEmpty()) {
            throw new AuraHandledException('Unauthorised request.');
        }
    }

    /**
     * @description Convenience overload reading the account id from the action
     *              input, which carries it under one of several names depending
     *              on where in the journey the call originates.
     * @param quoteId The Mobi quote reference supplied by the client
     * @param input   The action input map
     */
    public static void validate(String quoteId, Map<String, Object> input) {
        validate(quoteId, resolveAccountId(input));
    }

    /**
     * @description Reads the account id from the action input.
     */
    private static String resolveAccountId(Map<String, Object> input) {
        if (input == null) {
            return null;
        }
        for (String key : new List<String>{ 'ProspectAccountId', 'accountId', 'existingAccountId' }) {
            Object value = input.get(key);
            if (value != null && String.isNotBlank(String.valueOf(value))) {
                return String.valueOf(value);
            }
        }
        return null;
    }
}