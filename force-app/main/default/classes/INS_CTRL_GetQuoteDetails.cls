/**
 * @description       : Callable implementation for OmniStudio Remote Actions.
 *                      Retrieves the in-progress quote for an existing account
 *                      for the Flexi Protect journey.
 * @author            : Irshad
 * @user story        : SFP-55635
 * Test Class         : INS_CTRL_GetQuoteDetails_TEST
 */
public without sharing class INS_CTRL_GetQuoteDetails implements Callable {

    private static final String ACTION_QUERY_QUOTE = 'queryQuote';

    private static final String KEY_INPUT               = 'input';
    private static final String KEY_OUTPUT              = 'output';
    private static final String KEY_EXISTING_ACCOUNT_ID = 'existingAccountId';
    private static final String KEY_QUOTE_FOUND         = 'quoteFound';
    private static final String KEY_EXISTING_QUOTE_DETAILS = 'existingQuoteDetails';

    /**
     * Callable Entry Point
     */
    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get(KEY_INPUT) instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get(KEY_OUTPUT) instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get(KEY_INPUT);
        Map<String, Object> output = (Map<String, Object>) args.get(KEY_OUTPUT);

        if (actionType == ACTION_QUERY_QUOTE) {
            return queryQuote(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    /**
     * @description Retrieves the in-progress quote for the supplied account.
     *              Uses the without-sharing selector variant because this runs
     *              in a guest-user context where Quote records are not visible
     *              through sharing rules.
     * @param input  Must contain 'existingAccountId'
     * @param output Populated with quoteFound and QuoteDetails
     * @return       The populated output map
     */
    private static Object queryQuote(Map<String, Object> input, Map<String, Object> output) {
        Id accountId = resolveAccountId(input);

        List<Quote> quoteList;
        try {
            quoteList = new SEL_Quote().selectByAccIds(new List<Id>{ accountId });
        } catch (Exception e) {
           throw new AuraHandledException('Failed to retrieve quote details: ' + e.getMessage());
        }

        if (quoteList == null || quoteList.isEmpty()) {
            output.put(KEY_QUOTE_FOUND, false);
            output.put(KEY_EXISTING_QUOTE_DETAILS, new Map<String, Object>());
            return output;
        }

        output.put(KEY_QUOTE_FOUND, true);
        output.put(KEY_EXISTING_QUOTE_DETAILS, buildQuoteDetails(quoteList[0]));

        return output;
    }

    /**
     * @description Reads and validates the account id from the input map.
     * @param input Input map from the OmniScript
     * @return      Validated account Id
     */
    private static Id resolveAccountId(Map<String, Object> input) {
        Map<String, Object> existingAccount = (Map<String, Object>)input.get('existingAccount');
		Object rawAccountId = existingAccount.get(KEY_EXISTING_ACCOUNT_ID);
        String accountIdValue = rawAccountId == null ? null : String.valueOf(rawAccountId);

        if (String.isBlank(accountIdValue)) {
            throw new AuraHandledException('existingAccountId is required to query quotes.');
        }

        try {
            return Id.valueOf(accountIdValue);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid existingAccountId: ' + accountIdValue);
        }
    }

    /**
     * @description Maps a single quote onto an OmniScript-friendly map.
     * @param quoteRecord The quote returned by the selector
     * @return            Quote detail map
     */
    private static Map<String, Object> buildQuoteDetails(Quote quoteRecord) {
        return new Map<String, Object>{
            'quoteId'                => quoteRecord.Id,
            'quoteNumber'            => quoteRecord.QuoteNumber,
            'quoteName'              => quoteRecord.Name,
            'accountId'              => quoteRecord.AccountId,
            'opportunityId'          => quoteRecord.OpportunityId,
            'expirationDate'         => quoteRecord.ExpirationDate,
            'monthlyPremium'         => quoteRecord.INS_MonthlyPremium__c,
            'underwriterQuoteRefNum' => quoteRecord.UnderwriterQuoteReferenceNumber__c
        };
    }
}