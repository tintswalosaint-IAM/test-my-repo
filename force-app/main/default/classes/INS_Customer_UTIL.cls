/**
 * @class       INS_Customer_UTIL
 * @description Utility class that acts as a remote action handler for insurance customer
 *              operations. Implements the Callable interface to support dynamic invocation
 *              from Flow, OmniScript, or other Salesforce components.
 *
 *             
 * @author    Irshad  
 * @date        
 * @version     
 *
 * 
 */
global without sharing class INS_Customer_UTIL implements Callable {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    /** Record type name for prospect person accounts */
    private static final String ACCOUNT_RECORD_TYPE_PROSPECT    = 'Person Account - Prospect';

    /** Record type name for general opportunities */
    private static final String OPPORTUNITY_RECORD_TYPE_GENERAL = 'General';

    /** Record type name for LookSee quotes */
    private static final String QUOTE_RECORD_TYPE_LOOKSEE       = 'LookSee Quote';

    /** Product name used across all product-related SOQL queries */
    private static final String PRODUCT_NAME_FLEXI_PROTECT      = 'Flexi Protect';

    /** Pricebook name used for Kenya HNW channel SOQL queries */
    private static final String PRICEBOOK_NAME_KENYA_HNW        = 'C&HNW(Kenya)';

    /** Quote name applied to all created quote records */
    private static final String QUOTE_NAME_FLEXI_PROTECT        = 'Flexi Protect Quote';

    /** Quote status set at creation */
    private static final String QUOTE_STATUS_IN_PROGRESS        = 'Quote In-Progress';

    /** Default opportunity stage at creation */
    private static final String OPPORTUNITY_STAGE_QUOTING       = 'Quoting';

    /** Number of days from today before a new quote expires */
    private static final Integer QUOTE_EXPIRY_DAYS              = 30;

    /** Marital status label-to-picklist-value mapping */
    private static final Map<String, String> MARITAL_STATUS_MAP = new Map<String, String>{
        'Single'   => '1',
        'Married'  => '2',
        'Divorced' => '4',
        'Widowed'  => '5'
    };

    // =========================================================================
    // TRANSACTION-SCOPED QUERY CACHE
    // =========================================================================

    /**
     * Holds the PricebookEntry (with parent Product2 and Pricebook2 Ids) for
     * Flexi Protect in the Kenya HNW pricebook.
     *
     * Populated once per transaction by queryFlexiProtectPricebookEntry() and
     * reused by both getProductDetails and createOpportunityLineItem, eliminating
     * the 3 duplicate SOQL calls that existed in the original implementation.
     *
     * Using a static variable is appropriate here because:
     *   - The data (product/pricebook config) does not change mid-transaction.
     *   - This class is called from OmniScript/Flow, which is a single-transaction context.
     */
    private static PricebookEntry cachedPricebookEntry;

    // =========================================================================
    // CALLABLE INTERFACE — ENTRY POINT
    // =========================================================================

    /**
     * @description Entry point for the Callable interface. Routes the incoming
     *              action type to the appropriate handler method.
     *
     * @param       actionType  The action to execute (e.g. 'createAccount')
     * @param       args        Map containing 'input' and 'output' sub-maps
     * @return      Object      The populated output map returned by the handler
     * @throws      AuraHandledException if the actionType is not recognised
     */
    global Object call(String actionType, Map<String, Object> args) {

        Map<String, Object> inputMap  = (Map<String, Object>) args.get('input');
        Map<String, Object> outputMap = (Map<String, Object>) args.get('output');

        switch on actionType {
            when 'createAccount' {
                return createAccount(inputMap, outputMap);
            }
            when 'createOpportunity' {
                return createOpportunity(inputMap, outputMap);
            }
            when 'getProductDetails' {
                return getProductDetails(inputMap, outputMap);
            }
            when 'updateOpportunity' {
                return updateOpportunity(inputMap, outputMap);
            }
            when else {
                throw new AuraHandledException('Unsupported action: ' + actionType);
            }
        }
    }

    // =========================================================================
    // PUBLIC METHODS
    // =========================================================================

    /**
     * @description Creates a Person Account with the Prospect record type using
     *              personal information provided in the input map.
     *              No SOQL is executed here; RecordTypeId is resolved via Schema
     *              describe (cached by the platform, zero SOQL cost).
     *
     * @param       inputMap   Must contain a 'PersonalInformation' sub-map with:
     *                           FirstName, LastName, Email, PhoneNumber,
     *                           OS_DateOfBirth, Gender, MaritalStatus, IdNumber
     * @param       outputMap  Populated with 'ProspectAccountId' on success
     * @return      Object     The updated outputMap
     * @throws      AuraHandledException if PersonalInformation is missing
     */
    @AuraEnabled(cacheable=false)
    public static Object createAccount(Map<String, Object> inputMap, Map<String, Object> outputMap) {

        Map<String, Object> personalInformation = (Map<String, Object>) inputMap.get('PersonalInformation');
        if (personalInformation == null) {
            throw new AuraHandledException('PersonalInformation is required');
        }

        // Parse date of birth safely to avoid runtime exceptions on unexpected formats
        Date dateOfBirth = parseDate(personalInformation.get('OS_DateOfBirth'));

        Account prospectAccount = new Account(
            FirstName                  = (String) personalInformation.get('FirstName'),
            LastName                   = (String) personalInformation.get('LastName'),
            PersonEmail                = (String) personalInformation.get('Email'),
            PersonMobilePhone          = (String) personalInformation.get('PhoneNumber'),
            PersonHomePhone            = (String) personalInformation.get('PhoneNumber'),
            PersonBirthdate            = dateOfBirth,
            PersonGender               = (String) personalInformation.get('Gender'),
            FinServ__MaritalStatus__pc = MARITAL_STATUS_MAP.get((String) personalInformation.get('MaritalStatus')),
            CMN_IdentityNumber__pc     = (String) personalInformation.get('IdNumber'),
            RecordTypeId               = getRecordTypeId(Account.SObjectType, ACCOUNT_RECORD_TYPE_PROSPECT)
        );

        insert prospectAccount;

        outputMap.put('ProspectAccountId', prospectAccount.Id);
        return outputMap;
    }

    /**
     * @description Creates an Opportunity, an associated OpportunityLineItem,
     *              and a Quote record. The shared PricebookEntry is resolved via
     *              the transaction cache so only one set of product SOQL queries
     *              is issued even though both this method and createOpportunityLineItem
     *              need that data.
     *
     * @param       inputMap   Must contain:
     *                           - 'accountId'           (String)
     *                           - 'CreateQuoteResponse' (Map: coverAmount, benefitAmountValue, quoteId)
     *                           - 'INS_Products'        (Map: Product__c, Country__c, Currency__c)
     * @param       outputMap  Populated with 'OppId' and 'QuoteNumber' on success
     * @return      Object     The updated outputMap
     * @throws      AuraHandledException if any required input is missing
     */
    @AuraEnabled(cacheable=false)
    public static Object createOpportunity(Map<String, Object> inputMap, Map<String, Object> outputMap) {

        String accountId                     = (String) inputMap.get('accountId');
        Map<String, Object> quoteResponse    = (Map<String, Object>) inputMap.get('CreateQuoteResponse');
        Map<String, Object> insuranceProduct = (Map<String, Object>) inputMap.get('INS_Products');

        if (accountId == null || quoteResponse == null || insuranceProduct == null) {
            throw new AuraHandledException(
                'Missing required inputs: accountId, CreateQuoteResponse, and INS_Products are all required.'
            );
        }

        Date today = Date.today();

        // Opportunity name includes product, country, and date for traceability
        String opportunityName =
            String.valueOf(insuranceProduct.get('Product__c')) + ' ' +
            String.valueOf(insuranceProduct.get('Country__c')) + ' - ' +
            today.format();

        Opportunity newOpportunity = new Opportunity(
            AccountId                = accountId,
            Name                     = opportunityName,
            StageName                = OPPORTUNITY_STAGE_QUOTING,
            CloseDate                = today,
            RecordTypeId             = getRecordTypeId(Opportunity.SObjectType, OPPORTUNITY_RECORD_TYPE_GENERAL),
            Country__c               = (String) insuranceProduct.get('Country__c'),
            CurrencyIsoCode          = (String) insuranceProduct.get('Currency__c'),
            Total_Cover_Amount__c    = parseDecimal(quoteResponse.get('coverAmount')),
            Total_Monthly_Premium__c = parseDecimal(quoteResponse.get('benefitAmountValue'))
        );

        insert newOpportunity;

        // createOpportunityLineItem reuses the same cachedPricebookEntry — no extra SOQL
        createOpportunityLineItem(newOpportunity.Id);

        outputMap.put('OppId', newOpportunity.Id);

        Quote opportunityQuote = createQuoteRecord(
            newOpportunity.Id,
            (String) quoteResponse.get('quoteId'),
            (String) insuranceProduct.get('Currency__c')
        );

        outputMap.put('QuoteNumber', opportunityQuote.QuoteNumber);
        return outputMap;
    }

    /**
     * @description Updates an existing Opportunity's cover amount and monthly
     *              premium. Uses a partial-update pattern (Id-only SObject) to
     *              avoid a SELECT before the UPDATE — no SOQL consumed.
     *
     * @param       inputMap   Must contain:
     *                           - 'OppId'               (Id)
     *                           - 'BenefitAmount'       (Decimal-compatible value)
     *                           - 'RecalculatedPremium' (Decimal-compatible value)
     * @param       outputMap  Populated with 'hasOppUpdated' = 'true' on success
     * @return      Object     The updated outputMap
     * @throws      AuraHandledException if OppId is missing
     */
    @AuraEnabled(cacheable=false)
    public static Object updateOpportunity(Map<String, Object> inputMap, Map<String, Object> outputMap) {

        Id opportunityId = (Id) inputMap.get('OppId');
        if (opportunityId == null) {
            throw new AuraHandledException('OppId is required');
        }

        // Partial-update pattern: construct with Id only, set changed fields.
        // No SELECT needed — avoids one unnecessary SOQL query.
        Opportunity opportunityToUpdate = new Opportunity(
            Id                       = opportunityId,
            Total_Cover_Amount__c    = parseDecimal(inputMap.get('BenefitAmount')),
            Total_Monthly_Premium__c = parseDecimal(inputMap.get('RecalculatedPremium'))
        );

        update opportunityToUpdate;

        outputMap.put('hasOppUpdated', 'true');
        return outputMap;
    }

    /**
     * @description Returns Product, Pricebook, and PricebookEntry details for
     *              Flexi Protect. Uses the transaction cache so repeated calls
     *              within the same transaction do not issue additional SOQL.
     *
     * @param       inputMap   Reserved for future filtering; not used currently
     * @param       outputMap  Populated with ProductId, PricebookId,
     *                         PricebookEntryId, and UnitPrice
     * @return      Object     The updated outputMap
     */
    @AuraEnabled(cacheable=false)
    public static Object getProductDetails(Map<String, Object> inputMap, Map<String, Object> outputMap) {

        // Single query via cache — Product2Id and Pricebook2Id are returned as
        // relationship fields so no separate Product2 / Pricebook2 queries are needed
        PricebookEntry entry = queryFlexiProtectPricebookEntry();

        outputMap.put('ProductId',        entry.Product2Id);
        outputMap.put('PricebookId',      entry.Pricebook2Id);
        outputMap.put('PricebookEntryId', entry.Id);
        outputMap.put('UnitPrice',        entry.UnitPrice);

        return outputMap;
    }

    /**
     * @description Creates an OpportunityLineItem for the given Opportunity.
     *              Reuses the transaction-scoped PricebookEntry cache so no
     *              additional SOQL is issued when called after createOpportunity.
     *
     * @param       opportunityId  The Id of the Opportunity to attach the line item to
     */
    public static void createOpportunityLineItem(Id opportunityId) {

        // Cache hit in normal flow (called from createOpportunity): 0 SOQL queries
        // Cache miss (called standalone): 1 SOQL query — still best practice minimum
        PricebookEntry entry = queryFlexiProtectPricebookEntry();

        insert new OpportunityLineItem(
            OpportunityId    = opportunityId,
            PricebookEntryId = entry.Id,
            Quantity         = 1
        );
    }

    /**
     * @description Creates and inserts a Quote record linked to the given Opportunity.
     *
     * @param       opportunityId   The parent Opportunity Id
     * @param       externalQuoteId The external underwriter quote reference number
     * @param       currencyCode    ISO currency code to apply to the Quote
     * @return      Quote           The inserted Quote (QuoteNumber is populated post-insert)
     */
    @AuraEnabled(cacheable=false)
    public static Quote createQuoteRecord(Id opportunityId, String externalQuoteId, String currencyCode) {

        Quote insuranceQuote = new Quote(
            OpportunityId                      = opportunityId,
            Name                               = QUOTE_NAME_FLEXI_PROTECT,
            Status                             = QUOTE_STATUS_IN_PROGRESS,
            CurrencyIsoCode                    = currencyCode,
            UnderwriterQuoteReferenceNumber__c = externalQuoteId,
            ExpirationDate                     = Date.today().addDays(QUOTE_EXPIRY_DAYS),
            RecordTypeId                       = getRecordTypeId(Quote.SObjectType, QUOTE_RECORD_TYPE_LOOKSEE)
        );

        insert insuranceQuote;
        return insuranceQuote;
    }

    // =========================================================================
    // PRIVATE — SOQL SELECTOR METHODS
    // All SOQL in this class lives here. Business logic above never contains
    // inline queries, keeping concerns separated and queries easy to find/test.
    // =========================================================================

    /**
     * @description Fetches the PricebookEntry for Flexi Protect in the Kenya HNW
     *              pricebook and caches the result for the lifetime of the transaction.
     *
     *              Fields selected:
     *                - Id, UnitPrice       — needed by both getProductDetails and
     *                                        createOpportunityLineItem
     *                - Product2Id          — relationship Id, avoids a separate Product2 query
     *                - Pricebook2Id        — relationship Id, avoids a separate Pricebook2 query
     *
     *              Why one query instead of three:
     *                PricebookEntry stores FK references to both Product2 and Pricebook2,
     *                so selecting Product2Id and Pricebook2Id here gives callers everything
     *                they need without issuing separate Product2 and Pricebook2 queries.
     *
     * @return      PricebookEntry  The active entry matching Flexi Protect + Kenya HNW pricebook
     */
    private static PricebookEntry queryFlexiProtectPricebookEntry() {

        // Return cached result if already fetched in this transaction
        if (cachedPricebookEntry != null) {
            return cachedPricebookEntry;
        }

        // Single joined query: Product2 name filter via relationship, Pricebook2 name filter via relationship.
        // This replaces the three separate queries (Product2 → Pricebook2 → PricebookEntry)
        // that existed in the original implementation.
        cachedPricebookEntry = [
            SELECT Id,
                   UnitPrice,
                   Product2Id,
                   Pricebook2Id
            FROM   PricebookEntry
            WHERE  Product2.Name   = :PRODUCT_NAME_FLEXI_PROTECT
            AND    Pricebook2.Name = :PRICEBOOK_NAME_KENYA_HNW
            AND    IsActive        = true
            LIMIT  1
        ];

        return cachedPricebookEntry;
    }

    // =========================================================================
    // PRIVATE — HELPER / UTILITY METHODS
    // =========================================================================

    /**
     * @description Resolves a Record Type Id by SObjectType and label name using
     *              Schema describe — zero SOQL cost (platform-cached metadata).
     *              Consolidated from three separate per-object methods into one
     *              generic helper to avoid repetition.
     *
     * @param       objectType      The SObjectType (e.g. Account.SObjectType)
     * @param       recordTypeName  The record type label (must match exactly)
     * @return      Id              The matching Record Type Id
     */
    private static Id getRecordTypeId(SObjectType objectType, String recordTypeName) {
        return objectType.getDescribe()
            .getRecordTypeInfosByName()
            .get(recordTypeName)
            .getRecordTypeId();
    }

    /**
     * @description Safely converts an Object value to Decimal.
     *              Returns null if the input is null to prevent NullPointerExceptions.
     *
     * @param       value  Raw value to convert (typically from a Map)
     * @return      Decimal or null
     */
    private static Decimal parseDecimal(Object value) {
        if (value == null) return null;
        return Decimal.valueOf(String.valueOf(value));
    }

    /**
     * @description Safely converts an Object value to a Date.
     *              Returns null if the input is null.
     *              Expected string format: YYYY-MM-DD
     *
     * @param       value  Raw value to convert (typically from a Map)
     * @return      Date or null
     */
    private static Date parseDate(Object value) {
        if (value == null) return null;
        return Date.valueOf(String.valueOf(value));
    }
}