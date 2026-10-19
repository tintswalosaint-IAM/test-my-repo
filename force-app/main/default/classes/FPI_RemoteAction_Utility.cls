/**
 * @description       : Handles quote/Opportunity updates.
 * @author            : Irshad
 * @Created on        : 03-25-2026
 * User Story         : SFP-55708
 * @last modified by  : Irshad
 **/
public without sharing class FPI_RemoteAction_Utility implements Callable {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('FPI_RemoteAction_Utility');    
    private static final String PRODUCT_NAME =
        'Flexi Protect';
    private static final String PRICEBOOK_NAME =
        'C&HNW(Kenya)';
    private static final String ACCOUNT_RECORD_TYPE =
        'Person Account - Prospect';
    private static final String OPPORTUNITY_RECORD_TYPE =
        'General';
    private static final String QUOTE_RECORD_TYPE =
        'LookSee Quote';

    private static final String OPPORTUNITY_STAGE =
        'Quoting';
    private static final String QUOTE_STATUS =
        'Quote In-Progress';
    private static final String QUOTE_NAME =
        'Flexi Protect Quote';

    public Object call(String actionType, Map<String, Object> args) {
        Map<String, Object> input  = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');

        switch on actionType {
            when 'createAccount' {
                return createAccount(input, output);
            }
            when 'createOpportunity' {
                return createOpportunity(input, output);
            }
            
            when 'updateOpportunity' {
                return updateOpportunity(input, output);
            }
            when else {
                throw new AuraHandledException('Unsupported action: ' + actionType);
            }
        }
    }

    // =========================
    // CREATE ACCOUNT
    // =========================
	@AuraEnabled(cacheable=false)
    public static Object createAccount(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        try {
            if (output == null) {
                output = new Map<String, Object>();
            }

            if (input == null) {
                throw new IllegalArgumentException(
                    'Input is required.'
                );
            }

            Map<String, Object> personalInformation =
                (Map<String, Object>) input.get(
                    'PersonalInformation'
                );

            if (personalInformation == null) {
                throw new IllegalArgumentException(
                    'PersonalInformation is required.'
                );
            }

            Map<String, String> maritalStatusMap =
                new Map<String, String>{
                    'Single' => '1',
                    'Married' => '2',
                    'Divorced' => '4',
                    'Widowed' => '5'
                };

            Account accountRecord = new Account(
                FirstName =
                    (String) personalInformation.get('FirstName'),
                LastName =
                    (String) personalInformation.get('LastName'),
                PersonEmail =
                    (String) personalInformation.get('Email'),
                PersonMobilePhone =
                    (String) personalInformation.get('PhoneNumber'),
                PersonHomePhone =
                    (String) personalInformation.get('PhoneNumber'),
                PersonBirthdate =
                    safeDate(
                        personalInformation.get('OS_DateOfBirth')
                    ),
                PersonGender =
                    (String) personalInformation.get('Gender'),
                FinServ__MaritalStatus__pc =
                    maritalStatusMap.get(
                        (String) personalInformation.get(
                            'MaritalStatus'
                        )
                    ),
                CMN_IdentityNumber__pc =
                    (String) personalInformation.get('IdNumber'),
                RecordTypeId =
                    Schema.SObjectType.Account
                        .getRecordTypeInfosByName()
                        .get(ACCOUNT_RECORD_TYPE)
                        .getRecordTypeId()
            );

            sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                (sbgplatform.fflib_SObjectUnitOfWork)
                    ORG_Application.unitOfWork.newInstance();

            unitOfWork.registerNew(accountRecord);
            unitOfWork.commitWork();

            output.put(
                'ProspectAccountId',
                accountRecord.Id
            );

            return output;

        } catch (Exception exceptionValue) {
            LOGGER.error(
                'FPI_RemoteAction_Utility.createAccount',
                exceptionValue
            );

            throw new AuraHandledException(
                exceptionValue.getMessage()
            );
        }
    }

    // =========================
    // CREATE OPPORTUNITY
    // =========================
	@AuraEnabled(cacheable=false)
    public static Object createOpportunity(Map<String, Object> input, Map<String, Object> output) {
        try{
            String accountId = (String) input.get('accountId');
            Map<String,Object> quoteDetails = (Map<String,Object>) input.get('CreateQuoteResponse');
            Map<String,Object> insProduct   = (Map<String,Object>) input.get('INS_Products');
            if (accountId == null || quoteDetails == null || insProduct == null) {
                throw new AuraHandledException('Missing required inputs');
            }

            Date today = Date.today();

            String oppName =
                insProduct.get('Product__c') + ' ' +
                insProduct.get('Country__c') + ' - ' +
                today.format();

            Opportunity opp = new Opportunity(
                AccountId = accountId,
                Name = oppName,
                StageName = OPPORTUNITY_STAGE,
                CloseDate = today,
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
                    .get(OPPORTUNITY_RECORD_TYPE).getRecordTypeId(),
                Country__c = (String) insProduct.get('Country__c'),
                CurrencyIsoCode = (String) insProduct.get('Currency__c'),
                Total_Cover_Amount__c = safeDecimal(quoteDetails.get('coverAmount')),
                Total_Monthly_Premium__c = safeDecimal(quoteDetails.get('benefitAmountValue'))
            );
            sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                    (sbgplatform.fflib_SObjectUnitOfWork)
                        ORG_Application.unitOfWork.newInstance();

                unitOfWork.registerNew(opp);
                unitOfWork.commitWork();
            

            createOpportunityLineItem(opp.Id);

            output.put('OppId', opp.Id);

            Quote qt = createQuoteRecord(
                opp.Id,
                (String) quoteDetails.get('quoteId'),
                (String) insProduct.get('Currency__c')
            );

            output.put('QuoteNumber', qt.QuoteNumber);

            return output;
        }Catch(Exception exceptionValue){
            LOGGER.error(
                'FPI_RemoteAction_Utility.createOpportunity',
                exceptionValue
            );

            throw new AuraHandledException(
                exceptionValue.getMessage()
            );
        }
        
    }

    // =========================
    // UPDATE OPPORTUNITY SFP-56100: to update Opprotunity
    // =========================
	@AuraEnabled(cacheable=false)
    public static Object updateOpportunity(Map<String, Object> input, Map<String, Object> output) {
        try{
            Id oppId = (Id) input.get('OppId');

            if (oppId == null) {
                throw new AuraHandledException('OppId is required');
            }

            Opportunity opp = new Opportunity(
                Id = oppId,
                Total_Cover_Amount__c = safeDecimal(input.get('BenefitAmount')),
                Total_Monthly_Premium__c = safeDecimal(input.get('RecalculatedPremium'))
            );
            sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                    (sbgplatform.fflib_SObjectUnitOfWork)
                        ORG_Application.unitOfWork.newInstance();

                unitOfWork.registerDirty(opp);
                unitOfWork.commitWork();
            

            output.put('hasOppUpdated', 'true');
            return output;
        }Catch(Exception exceptionValue){
            LOGGER.error(
                'FPI_RemoteAction_Utility.updateOpportunity',
                exceptionValue
            );

            throw new AuraHandledException(
                exceptionValue.getMessage()
            );
        }
        
    }

    // =========================
    // HELPERS
    // =========================
    private static Decimal safeDecimal(Object val) {
        if (val == null) {
            return null;
        }
        return Decimal.valueOf(String.valueOf(val));
    }

    private static Date safeDate(Object val) {
        if (val == null) {
            return null;
        }
        return Date.valueOf(String.valueOf(val));
    }

    /**
    *   Method to create Opportunity line item
    */
    public static void createOpportunityLineItem(Id oppId) {

        Product2 prod = [SELECT Id FROM Product2 WHERE Name = :PRODUCT_NAME WITH USER_MODE LIMIT 1];
        Pricebook2 pb = [SELECT Id 
            FROM Pricebook2 
            WHERE Name = :PRICEBOOK_NAME  
            AND IsActive = true 
            WITH USER_MODE
            LIMIT 1
        ];
        PricebookEntry pbe = [
            SELECT Id 
            FROM PricebookEntry
            WHERE Product2Id = :prod.Id 
            AND Pricebook2Id = :pb.Id 
            WITH USER_MODE
            LIMIT 1
        ];

        OpportunityLineItem OppLiRecord = new OpportunityLineItem(
            OpportunityId = oppId,
            PricebookEntryId = pbe.Id,
            Quantity = 1
        );
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                    (sbgplatform.fflib_SObjectUnitOfWork)
                        ORG_Application.unitOfWork.newInstance();

        unitOfWork.registerNew(OppLiRecord);
        unitOfWork.commitWork();

    }

	@AuraEnabled(cacheable=false)
    public static Quote createQuoteRecord(Id oppId, String quoteId, String currencyI) {
        try{
            Quote quoteRecord = new Quote(
            OpportunityId = oppId,
            Name = QUOTE_NAME,
            Status = QUOTE_STATUS,
            CurrencyIsoCode = currencyI,
            UnderwriterQuoteReferenceNumber__c = quoteId,
            ExpirationDate = Date.today().addDays(30),
            RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName()
                .get(QUOTE_RECORD_TYPE).getRecordTypeId()
            );

            //insert qt;
            sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                    (sbgplatform.fflib_SObjectUnitOfWork)
                        ORG_Application.unitOfWork.newInstance();

            unitOfWork.registerNew(quoteRecord);
            unitOfWork.commitWork();

            return [SELECT QuoteNumber 
                FROM Quote 
                WHERE Id = :quoteRecord.Id
                WITH USER_MODE ];
        }Catch(Exception exceptionValue){
            LOGGER.error(
                'FPI_RemoteAction_Utility.createQuoteRecord',
                exceptionValue
            );

            throw new AuraHandledException(
                exceptionValue.getMessage()
            );    
        }
        
    }
}