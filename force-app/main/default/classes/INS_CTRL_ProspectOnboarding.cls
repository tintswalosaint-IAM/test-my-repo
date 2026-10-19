/**
 * @description             : Callable implementation for OmniStudio Remote Actions.
 *                            Handles prospect Account creation, Opportunity/Quote creation,
 *                            and product catalogue lookup for the Flexi Protect insurance journey.
 * 				              WITHOUT SHRAING as this will run for guest user.
 * @story                   : SFP-55288: for guest user this must run without sharing
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 2026-08-03
 * @last modified by        : Irshad
 * @modification details    : Updated Account creation with customerType
 *                          
 */
public without sharing class INS_CTRL_ProspectOnboarding implements Callable{
    private static final String ACTION_CREATE_ACCOUNT     = 'createAccount';
    private static final String ACTION_CREATE_OPPORTUNITY = 'createOpportunity';
    private static final String ACTION_UPDATE_OPPORTUNITY = 'updateOpportunity';

    private static final String RT_PERSON_PROSPECT        = 'Person Account - Prospect';
    private static final String RT_OPP_GENERAL            = 'General';
    private static final String RT_QUOTE_LOOKSEE          = 'LookSee Quote';

    private static final String PRODUCT_NAME              = 'Flexi Protect';   
    private static final String OPP_TYPE                  = 'Liberty Life';    
    private static final String OPP_STAGE                 = 'Quoting';
    private static final String QUOTE_STATUS              = 'Quote In-Progress';
    private static final String ICS_OPP_TYPE              = 'Single';
    private static final String LEAD_SOURCE               = 'Liberty';

    private static final Map<String, String> MARITAL_STATUS_MAP = new Map<String, String>{
        'Single'   => '1',
        'Married'  => '2',
        'Divorced' => '4',
        'Widowed'  => '5'
    };
    private static Map<String, Id> rtCache;

    /**Get Record Type Id */
    private static Id getRecordTypeId(String sObjectName, String rtName) {
        if (rtCache == null) {
            rtCache = new Map<String, Id>();
        }
        String cacheKey = sObjectName + ':' + rtName;
        if (!rtCache.containsKey(cacheKey)) {
            Map<String, Schema.RecordTypeInfo> rtMap;
            if (sObjectName == 'Account') {
                rtMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
            } else if (sObjectName == 'Opportunity') {
                rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
            } else if (sObjectName == 'Quote') {
                rtMap = Schema.SObjectType.Quote.getRecordTypeInfosByName();
            } else {
                throw new AuraHandledException('Unknown sObject for record type lookup: ' + sObjectName);
            }
            Schema.RecordTypeInfo info = rtMap.get(rtName);
            if (info == null) {
                throw new AuraHandledException('Record type not found: ' + rtName + ' on ' + sObjectName);
            }
            rtCache.put(cacheKey, info.getRecordTypeId());
        }
        return rtCache.get(cacheKey);
    }

    /**
     * Callable Entry Point
     * 
     */

    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get('input') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get('output') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');

        if (actionType == ACTION_CREATE_ACCOUNT) {
            return createAccount(input, output);
        }
        if (actionType == ACTION_CREATE_OPPORTUNITY) {
            return createOpportunity(input, output);
        }
        if (actionType == ACTION_UPDATE_OPPORTUNITY) {
            return updateOpportunity(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    /**
     * Create Account
     */

    private static Object createAccount(Map<String, Object> input, Map<String, Object> output) {
        Map<String, Object> pi = getRequiredMap(input, 'PersonalInformation');
        // get the products metadata
        Map<String, Object> insProduct   = getRequiredMap(input, 'INS_Products__mdt');
        
        String dobStr = getString(pi, 'OS_DateOfBirth');
        if (String.isBlank(dobStr)) {
            throw new AuraHandledException('DateOfBirth is required.');
        }

        Date dateOfBirth;
        try {
            dateOfBirth = Date.valueOf(dobStr);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid DateOfBirth format: ' + dobStr);
        }

        Account acc = new Account();
        acc.RecordTypeId          = getRecordTypeId('Account', RT_PERSON_PROSPECT);
        acc.FirstName             = getString(pi, 'FirstName');
        acc.LastName              = getString(pi, 'LastName');
        acc.PersonGender          = getString(pi, 'Gender');
        acc.FinServ__MaritalStatus__pc = MARITAL_STATUS_MAP.get(getString(pi, 'MaritalStatus'));
        acc.PersonEmail           = getString(pi, 'Email');
        acc.PersonBirthdate       = dateOfBirth;
        acc.CMN_IdentityNumber__pc = getString(pi, 'IdNumber');
        acc.PersonMobilePhone     = getString(pi, 'PhoneNumber');
        acc.PersonHomePhone       = getString(pi, 'PhoneNumber');
        acc.FinServ__CustomerType__c = getString(insProduct, 'Customer_type__c');
        acc.ExternalCIFCountry__c = 'KE';

        try {
            sbgplatform.fflib_SObjectUnitOfWork uow =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            uow.registerNew(acc);
            uow.commitWork();
        } catch (Exception e) {
            throw new AuraHandledException('Account creation failed: ' + e.getMessage());
        }

        output.put('ProspectAccountId', acc.Id);
        return output;
    }

    /**
     * Create Opportunity
     * 
    */   

    private static Object createOpportunity(Map<String, Object> input, Map<String, Object> output) {
        Object sourceValue = input.get('OpportunitySource');        
        String accountId  = getString(input, 'accountId');
        String userId     = (String) input.get('assistedUserId');
        String contactId  = (String) input.get('assistedContactId');
        String pbeId      = (String) input.get('PricebookEntryId');
        String product2Id      = (String) input.get('ProductId');
        String opportunitySource = sourceValue == null ? '' : String.valueOf(sourceValue);
        Decimal pbeUnitPrice = (Decimal) input.get('PricebookEntryUnitPrice');

        Map<String, Object> quoteDetails = getRequiredMap(input, 'CreateQuoteResponse');
        Map<String, Object> insProduct   = getRequiredMap(input, 'INS_Products');

        if (String.isBlank(accountId)) {
            throw new AuraHandledException('accountId is required to create an Opportunity.');
        }

        Date    today          = Date.today();
        Decimal coverAmount    = (Decimal) quoteDetails.get('coverAmount');
        String  benefitAmtStr  = quoteDetails.containsKey('benefitAmountValue')
            ? String.valueOf(quoteDetails.get('benefitAmountValue'))
            : '0';
        Decimal monthlyPremium = Decimal.valueOf(String.isBlank(benefitAmtStr) ? '0' : benefitAmtStr);

        String country  = getString(insProduct, 'Country__c');
        String currencyCode = getString(insProduct, 'Currency__c');
        String oppName  = getString(insProduct, 'Product__c') + ' ' + country
                            + ' - ' + today.year() + '-' + today.month() + '-' + today.day();

        Opportunity opp = new Opportunity(
            AccountId                 = accountId,
            Name                      = oppName,
            StageName                 = OPP_STAGE,
            Type                      = OPP_TYPE,
            ICS_Opportunity_Type__c   = ICS_OPP_TYPE,
            CloseDate                 = today+30,
            RecordTypeId              = getRecordTypeId('Opportunity', RT_OPP_GENERAL),
            Country__c                = country,
            CurrencyIsoCode           = currencyCode,
            LeadSource                = LEAD_SOURCE,
            Opportunity_Source__c     = opportunitySource,
            Proposal_Date__c          = today,
            Quote_Id__c               = (String) quoteDetails.get('quoteId'),
            Total_Cover_Amount__c     = coverAmount,
            Total_Monthly_Premium__c  = monthlyPremium,
            FinServ__ReferredByContact__c = contactId,
            FinServ__ReferredByUser__c    = userId
        );

        OpportunityLineItem oli = new OpportunityLineItem(
            PricebookEntryId = pbeId,
            Product2Id       = product2Id,
            Quantity         = 1,
            UnitPrice        = pbeUnitPrice
        );

        Quote qt = new Quote(
            Name                               = PRODUCT_NAME + ' Quote',
            RecordTypeId                       = getRecordTypeId('Quote', RT_QUOTE_LOOKSEE),
            Status                             = QUOTE_STATUS,
            UnderwriterQuoteReferenceNumber__c = (String) quoteDetails.get('quoteId'),
            ExpirationDate                     = today.addDays(30),
            CurrencyIsoCode                    = currencyCode
        );

        try {
            // Single UnitOfWork commits Opportunity, OLI and Quote atomically.
            // Relationship registration backfills opp.Id onto both children
            // after the parent insert, in one transaction, one commitWork() call.
            sbgplatform.fflib_SObjectUnitOfWork uowOpp =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();

            uowOpp.registerNew(opp);
            uowOpp.commitWork();
            
            oli.OpportunityId = opp.Id;
            qt.OpportunityId  = opp.Id;
            
            sbgplatform.fflib_SObjectUnitOfWork uowChildren =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            uowChildren.registerNew(oli);
            uowChildren.registerNew(qt);
            uowChildren.commitWork();
            // QuoteNumber is a system auto-number field - never populated on the
            // in-memory sObject after insert/commitWork, must be re-queried.
            String quoteNumber = [
                SELECT QuoteNumber FROM Quote WHERE Id = :qt.Id LIMIT 1
            ].QuoteNumber;//WITH USER_MODE

            output.put('OppId',   opp.Id);
            output.put('QuoteNumber', quoteNumber);
            output.put('QuoteId', qt.Id);
            return output;

        } catch (Exception e) {            
            throw new AuraHandledException('Opportunity creation failed: ' + e.getMessage());
        }
    }

    /**
     * Update Opportunity (ported from FPI_RemoteAction_Utility, SFP-56100)
     * Recalculated benefit/premium values are written back onto the
     * Opportunity created earlier in the journey.
     */

    private static Object updateOpportunity(Map<String, Object> input, Map<String, Object> output) {
        
        Id oppId;
        String oppIdValue = (String) input.get('OppId');

        if (String.isNotBlank(oppIdValue)) {
            oppId = Id.valueOf(oppIdValue);
        } else {
            Object existingQuoteDetailsObj = input.get('existingQuoteDetails');
            if (existingQuoteDetailsObj instanceof Map<String, Object>) {
                Map<String, Object> existingQuoteDetails = (Map<String, Object>) existingQuoteDetailsObj;
                String opportunityIdValue = (String) existingQuoteDetails.get('opportunityId');
                if (String.isNotBlank(opportunityIdValue)) {
                    oppId = Id.valueOf(opportunityIdValue);
                }
            }
        }

        if (oppId == null) {
            throw new AuraHandledException('OppId is required');
        }
        
        String benefitAmountValue = String.valueOf(input.get('BenefitAmount'));       
        
        Opportunity opp = new Opportunity(
            Id                       = oppId,
            CloseDate                = system.today()+30,
            Total_Cover_Amount__c    = safeDecimal(benefitAmountValue),
            Total_Monthly_Premium__c = safeDecimal(input.get('RecalculatedPremium'))
        );

        try {
            sbgplatform.fflib_SObjectUnitOfWork uow =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            uow.registerDirty(opp);
            uow.commitWork();
        } catch (Exception e) {
            throw new AuraHandledException('Opportunity update failed: ' + e.getMessage());
        }

        output.put('hasOppUpdated', 'true');
        return output;
    }

    /**
     * Shared Utilities
     */
    private static Map<String, Object> getRequiredMap(Map<String, Object> parent, String key) {
        Object val = parent.get(key);
        if (!(val instanceof Map<String, Object>)) {
            throw new AuraHandledException('Required map missing or invalid: ' + key);
        }
        return (Map<String, Object>) val;
    }

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val == null ? null : String.valueOf(val);
    }

    private static Decimal safeDecimal(Object val) {
        if (val == null) {
            return null;
        }
        return Decimal.valueOf(String.valueOf(val));
    }
}