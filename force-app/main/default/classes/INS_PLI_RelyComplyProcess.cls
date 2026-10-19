/**
 * @description Helper class for rely comply process
 * @author Alexandr Goryachko
 * @since 18-11-2025 
 * @userStory SFP-54457
 */
public without sharing class INS_PLI_RelyComplyProcess {
    private static sbgplatform.fflib_SObjectUnitOfWork uow = (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_PLI_RelyComplyProcess');

    /**
     * @description Creates related to party profile records
     * @author Alexandr Goryachko
     * @param dto party profile wrapper
     * @param ppUpdates party profile fields
     * @param accUpdates account fields
     * @return `String` json string
     */
    @AuraEnabled(cacheable=false)
    public static String runRecordsCreation(String dto, Map<String, String> ppUpdates, Map<String, String> accUpdates, List<Map<String, String>> taxes) {
        String result;
        try {
            KYC_DTO_FlowCreatePartyProfile ppData = (KYC_DTO_FlowCreatePartyProfile)JSON.deserialize(
                dto, KYC_DTO_FlowCreatePartyProfile.class
            );
            INS_Products__mdt keProduct = INS_Products__mdt.getInstance('Flexi_Protect_Kenya');
            KYC_DTO_Assessment assessment = new KYC_DTO_Assessment();
            assessment.PEP_Screening = keProduct.KYC_RAAS__c;
            assessment.CRA = keProduct.KYC_RAAS__c;
            assessment.screening = keProduct.KYC_RAAS__c;
            KYC_DTO_IdChecks checks = new KYC_DTO_IdChecks();
            checks.idValidation = keProduct.KYC_IdValidation__c;
            checks.idv = keProduct.KYC_IDV__c;
            checks.assessment = assessment;
            ppData.checks = checks;
            KYC_CTRL_PartyProfile.IGNORE_SMS = true;
            KYC_DTO_ClientWrapper.Response response = KYC_CTRL_PartyProfile.processKycTest(JSON.serialize(ppData), true);
            result = JSON.serialize(response);
            List<TaxDetails__c> taxRecords = new List<TaxDetails__c>();
            for (Map<String, String> item : taxes) {
                TaxDetails__c tax = new TaxDetails__c();
                tax.Name = 'Tax Captured - Platinum Life Onboarding';
                tax.Account__c = accUpdates.get('id');
                tax.TaxNumber__c = item.get('tin');
                tax.Country__c = item.get('country');
                taxRecords.add(tax);
            }
            uow.registerNew(taxRecords);
            if (response.kycProfileId != null) {
                createRelyRecords(response, ppUpdates, accUpdates);
            }
            uow.commitWork();
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.runRecordsCreation'}, e);
            throw new AuraHandledException('Failed to create Party Profile: ' + e.getMessage() + result);
        }
        return result;
    }

    /**
     * @description Creates rely records
     * @author Alexandr Goryachko
     * @param response rely comply response
     * @param ppUpdates party profile fields
     * @param accUpdates account fields
     */
    private static void createRelyRecords(KYC_DTO_ClientWrapper.Response response, Map<String, String> ppUpdates, Map<String, String> accUpdates) {
        Map<String, Schema.sObjectField> fieldMapping = new Map<String, Schema.sObjectField>{
            'accountId' => PartyProfile.AccountId,
            'ppOpportunityId' => PartyProfile.Opportunity__c,
            'fundSource' => PartyProfile.FundSource,
            'countryOfCitizenshipSecond' => PartyProfile.Second_Country_of_Nationality__c,
            'id' => Account.Id,
            'currentEmployer' => Account.FinServ__CurrentEmployer__pc,
            'businessActivity' => Account.NatureofBusiness__c
        };
        PartyProfile pp = new PartyProfile(Id = response.kycProfileId);
        for (String fieldName : fieldMapping.keySet()) {
            if (ppUpdates.containsKey(fieldName) && String.isNotBlank(ppUpdates.get(fieldName))) {
                pp.put(fieldMapping.get(fieldName).getDescribe().getName(), ppUpdates.get(fieldName));
            }
        }
        uow.registerDirty(pp);

        Account acc = new Account();
        for (String fieldName : fieldMapping.keySet()) {
            if (accUpdates.containsKey(fieldName) && String.isNotBlank(accUpdates.get(fieldName))) {
                acc.put(fieldMapping.get(fieldName).getDescribe().getName(), accUpdates.get(fieldName));
            }
        }
        uow.registerDirty(acc);
        List<PartyScreeningSummary> partyScreeningSummaries = new SEL_PartyScreeningSummary().
            selectBysetpartyProfileIds(new Set<Id>{response.kycProfileId});
        for (PartyScreeningSummary item : partyScreeningSummaries) {
            if (item.Name == 'Assessment') {
                item.Status = 'In Progress';
            }
        }
        uow.registerDirty(partyScreeningSummaries);
    }

    /**
     * @description Call RAAS Customer service to auto-process RelyComply for a PartyProfile
     * @author Alexandr Goryachko
     * @param partyProfileId PartyProfile Id
     * @param quoteId Quote Id
     * @return KYC_DTO_Response response from RAAS service
     */
    @AuraEnabled(cacheable=false)
    public static KYC_DTO_Response autoProcessRelyComply(String partyProfileId, String quoteId) {
        try {
            return KYC_CTRL_RAASCustomer.callRAASCustomer(partyProfileId, quoteId);
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.autoProcessRelyComply'}, e);
            throw new AuraHandledException('Failed to run rely comply: ' + e.getMessage());
        }
    }

    /**
     * @description convert long url to short via API and get phone number
     * @author Alexandr Goryachko | 26-11-2025
     * @param longUrl String
     * @param accountId String
     * @return Map<String, String>
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getSmsData(String longUrl, String accountId) {
        Map<String, String> result;
        try {
            String url = INS_URL_ShorteningService.createShortUrl(longUrl);
            Account acc = new SEL_Account().selectById(accountId);
            result = new Map<String, String>{
                'link' => url,
                'phone' => acc.phone
            };
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.getSmsData'}, e);
            throw new AuraHandledException('Failed to get short link: ' + e.getMessage());
        }
        return result;
    }

    /**
     * @description updating quote
     * @author Alexandr Goryachko | 26-11-2025
     * @param quoteId String
     * @param salesEvent String
     */
    @AuraEnabled(cacheable=false)
    public static void updateSalesEvent(String quoteId, String salesEvent) {
        try {
            uow.registerDirty(
                new Quote(
                    Id = quoteId,
                    UnderwriterQuoteReferenceNumber__c = salesEvent
                )
            );
            uow.commitWork();
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.updateSalesEvent'}, e);
            throw new AuraHandledException('Failed to update quote: ' + e.getMessage());
        }
    }

    /**
     * @description check is quote signed
     * @author Alexandr Goryachko | 10-02-2025
     * @param quoteId String
     * @param status String
     */
    @AuraEnabled(cacheable=false)
    public static Boolean isQuoteSigned(String quoteId, String status) {
        try {
            List<Quote> quotes = new SEL_Quote().selectByIds(new List<Id>{quoteId});
            return !quotes.isEmpty() && quotes[0].INS_PolicyDocumentLatestStatus__c == status;
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.isQuoteSigned'}, e);
            throw new AuraHandledException('Failed to get quote: ' + e.getMessage());
        }
    }

    /**
     * @description get account data by quote id
     * @author Alexandr Goryachko | 03-12-2025
     * @param quoteId String
     * @return Map<String, String> account data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccountByQuoteId(String quoteId) {
        Map<String, Object> result;
        try {
            List<Quote> quotes = new SEL_Quote().selectByIds(new List<Id>{quoteId});
            SEL_Account selAcc = new SEL_Account();
            Account acc = selAcc.selectById(quotes[0].AccountId);
            result = new Map<String, Object>{
                'accountId' => acc.Id,
                'firstName' => acc.FirstName,
                'lastName' => acc.LastName,
                'email' => acc.PersonEmail,
                'phone' => acc.Phone,
                'gender' => acc.FinServ__Gender__pc,
                'birthDate' => acc.PersonBirthdate,
                'identityNumber' => acc.CMN_IdentityNumber__pc
            };
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.getAccountByQuoteId'}, e);
            throw new AuraHandledException('Failed to get account: ' + e.getMessage());
        }
        return result;
    }

    /**
     * @description Updates the SF records
     * @author Alexandr Goryachko | 05-12-2025
     * @param data fields
     **/
    @AuraEnabled(cacheable=false)
    public static void updateRecords(Map<String, String> data) {
        Map<String, Schema.sObjectField> fieldMapping = new Map<String, Schema.sObjectField>{
            'opportunityId' => Opportunity.Id,
            'opportunityStatus' => Opportunity.StageName
        };
        try {
            Opportunity opp = new Opportunity();
            for (String fieldName : fieldMapping.keySet()) {
                if (data.containsKey(fieldName) && String.isNotBlank(data.get(fieldName))) {
                    opp.put(fieldMapping.get(fieldName).getDescribe().getName(), data.get(fieldName));
                }
            }
            if (fieldMapping.containsKey('opportunityId')) {
                uow.registerDirty(opp);
            }
            uow.commitWork();
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.updateRecords'}, e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Updates the SF records after convert quote
     * @author Alexandr Goryachko | 15-12-2025
     * @param data fields
     **/
    @AuraEnabled(cacheable=false)
    public static void convertQuote(Map<String, String> data) {
        String accountId = data.get('accountId');
        try {
            Account acc = new Account(
                Id = accountId,
                RecordTypeId = Schema.SObjectType.Account
                    .getRecordTypeInfosByDeveloperName()
                    .get('PersonAccount').getRecordTypeId()
            );
            sbgplatform.fflib_SObjectUnitOfWork accountUow = new sbgplatform.fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Account.SObjectType }
            );
            accountUow.registerDirty(acc);
            accountUow.commitWork();
            convertQuotePolicyCreation(data);
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_RelyComplyProcess.convertQuote'}, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     /**
     * @description create insurance policy and related items
     * @author Ihtishaam Mohammoodally | 15-12-2025
     * @param data fields
     **/
    
    public static void convertQuotePolicyCreation(Map<String, String> data) {
        String quoteId = data.get('quoteId');
        String reference = data.get('reference');
        String policyNumber = data.get('policyNumber');
        String opportunityId = data.get('opportunityId');
        String status = data.get('status');

        // Use an explicit unit of work here. The deployed ORG_Application factory
        // does not currently expose InsurancePolicy, which causes registerNew()
        // to fail before the policy is inserted.
        sbgplatform.fflib_SObjectUnitOfWork uowPolicy = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Opportunity.SObjectType,
                Quote.SObjectType,
                InsurancePolicy.SObjectType
            }
        );
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(data.get('response'));
        Map<String, Object> policyData = response == null
            ? null
            : (Map<String, Object>) response.get('policyPayload');

        if (policyData == null) {
            throw new AuraHandledException('The conversion response did not contain policyPayload.');
        }

        String responsePolicyNumber = getResponseString(policyData, 'policyNumber');
        if (String.isBlank(responsePolicyNumber)) {
            throw new AuraHandledException('The conversion response did not contain policyNumber.');
        }
        policyNumber = responsePolicyNumber;
        String responseReference = getResponseString(policyData, 'externalPolicyNumber');
        if (String.isNotBlank(responseReference)) {
            reference = responseReference;
        }

        List<Object> insuranceCoverageList = getResponseList(policyData, 'benefitArray');
        List<Object> insurancePolicyParticipantList = getBenefitRoleplayers(insuranceCoverageList);
        User currentUserInfo = new SEL_User().selectUserById(UserInfo.getUserId());
        
        // Every policy must be associated with the producer for the logged-in user.
        // The producer lookup is based on InternalUserId; EmployeeNumber is not a
        // prerequisite for an existing producer or for creating the fallback record.
        data.put('producerId', createProducerRecord(currentUserInfo));
        List<Product2> productList = new SEL_Product2().selectByProductName('Platinum Life Insurance');
        if(productList != null && !productList.isEmpty()){
            data.put('productId',productList[0]?.Id);
        }
        
        Opportunity opp = new Opportunity(
            Id = opportunityId,
            Product_Key__c = policyNumber,
            StageName = status,
            Total_Cover_Amount__c = getResponseDecimal(policyData, 'sumAssured'),
            Total_Monthly_Premium__c  = getResponseDecimal(policyData, 'policyNettPremium')
        );
        
        if (status == 'Closed Won'){
            opp.CloseDate = Date.today();
        }
        uowPolicy.registerDirty(opp);
        
        Quote quote = new Quote(
            Id = quoteId,
            UnderwriterQuoteReferenceNumber__c = reference,
            INS_IndicativePremium__c   = getResponseDecimal(policyData, 'policyNettPremium'),
            INS_MonthlyPremium__c   = getResponseDecimal(policyData, 'policyNettPremium')
        );
        uowPolicy.registerDirty(quote);

        // The policy number is authoritative from the integration response.
        data.put('policyNumber', responsePolicyNumber);
        InsurancePolicy insurancePolicy = createInsurancePolicy(policyData,data);
        uowPolicy.registerNew(insurancePolicy);
        uowPolicy.commitWork();

        createInsurancePolicyParticipantList(insurancePolicyParticipantList,insurancePolicy);
        createInsurancePolicyCoverageList(insuranceCoverageList,insurancePolicy);

    }
    
    
    /**
     * @description create producer record or associating the policy to the existing producer record.
     * @author Ihtishaam Mohammoodally | 13-02-2025
     * @param currentUserInfo 
     **/
    
    public static String createProducerRecord(User currentUserInfo){
        Producer existingProducerRecord = new SEL_Producer().getProducersByInternalUserId(UserInfo.getUserId());
        
        if(String.isBlank(existingProducerRecord?.Id)){
            sbgplatform.fflib_SObjectUnitOfWork uowProducer = (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            existingProducerRecord = new Producer(
                Name = currentUserInfo.Name,
                InternalUserId = UserInfo.getUserId()
            );
            
            uowProducer.registerNew(existingProducerRecord);
            uowProducer.commitWork();
            
        }
        return existingProducerRecord.Id;
        
    }
        
    /**
     * @description create insurance policy record
     * @author Ihtishaam Mohammoodally | 15-12-2025
     * @param policyData,data 
     **/
    public static InsurancePolicy createInsurancePolicy(Map<String, Object> policyData,Map<String, String> data){
        String policyNumber = getResponseString(policyData, 'policyNumber');
        String externalPolicyNumber = getResponseString(policyData, 'externalPolicyNumber');
        return new InsurancePolicy(
            NameInsuredId = data.get('accountId'),
            Premium_Payer__c = data.get('accountId'),
            Name = String.isNotBlank(policyNumber) ? policyNumber : data.get('policyNumber'),
            ReferencePolicyNumber = String.isNotBlank(externalPolicyNumber) ? externalPolicyNumber : policyNumber,
            SourceOpportunityId = data.get('opportunityId'),
            CurrencyIsoCode = 'KES',
            ProductId = data.get('productId'),
            Inception_Date__c = getResponseDate(policyData, 'inceptionDate'),
            PolicyDescription = getResponseString(policyData, 'policyNote'),
            SalesChannel__c  = getResponseString(policyData, 'saleChannel'),
            PaymentMethod__c = String.isNotBlank(getResponseString(policyData, 'collectionMethod'))
                ? getResponseString(policyData, 'collectionMethod')
                : getResponseString(policyData, 'bankName'),
            Status  = String.isNotBlank(getResponseString(policyData, 'status'))
                ? getResponseString(policyData, 'status')
                : getResponseString(policyData, 'Status'),
            CollectionDay__c = getResponseString(policyData, 'debitDay'),
            PremiumPaymentAccountNumber__c  = getResponseString(policyData, 'bankAccountNo'),
            ActualRenewalDate = getResponseDate(policyData, 'anniversaryDate'),
            ExpirationDate = getResponseDate(policyData, 'policyEndDate'),
            RenewalChannel = getResponseString(policyData, 'servicingChannel'),
            TotalSumInsured = getResponseDecimal(policyData, 'sumAssured'),
           	PremiumAmount  = getResponseDecimal(policyData, 'policyNettPremium'),
            ProducerId  = data.get('producerId'),
           	RecordTypeId = Schema.SObjectType.InsurancePolicy
                            .getRecordTypeInfosByDeveloperName()
                            .get('Commercial_Long_Term_Insurance').getRecordTypeId()
        );
    }
    
    /**
     * @description create insurance policy participant record 
     * @author Ihtishaam Mohammoodally | 15-12-2025
     * @param insurancePolicyParticipantListRecords, insurancePolicy
     **/
    public static List<InsurancePolicyParticipant> createInsurancePolicyParticipantList( List<Object> insurancePolicyParticipantListRecords,InsurancePolicy insurancePolicy){
        sbgplatform.fflib_SObjectUnitOfWork uowPolicyParticipant = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ InsurancePolicyParticipant.SObjectType }
        );
        List<InsurancePolicyParticipant> insurancePolicyParticipantList = new List<InsurancePolicyParticipant>(); 
        for(Object insurancePolicyParticipantRecord : insurancePolicyParticipantListRecords == null ? new List<Object>() : insurancePolicyParticipantListRecords){
            Map<String,Object> insurancePolicyParticipantRecordMap = (Map<String,Object>) insurancePolicyParticipantRecord;

            if(getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerType') != 'Beneficiary'){
                continue;
            }

            insurancePolicyParticipantList.add(
                new InsurancePolicyParticipant(
                    FirstName__c  = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerFirstname'),
                    LastName__c = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerLastname'),
                    MobilePhone__c = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerCellphone'),
                    Email__c = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerEmailAddress'),
                    IdentityNumber__c = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerIdNumber'),
                    BirthDate__c = getResponseDate(insurancePolicyParticipantRecordMap, 'benefitRoleplayerDateOfBirth'),
                    Role = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerType'),
                    ExternalIdentifier__c = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerUniqueIdentifier'),
                    CurrencyIsoCode = 'KES',
                    RelationshipToInsured = getResponseString(insurancePolicyParticipantRecordMap, 'benefitRoleplayerRelationshipToOwner'),
                    Allocation__c = getResponseDecimal(insurancePolicyParticipantRecordMap, 'benefitRoleplayerPercentage',
                        getResponseDecimal(insurancePolicyParticipantRecordMap, 'policyRoleplayerPercentage')),
                    BeneficiarySharePercentage = getResponseDecimal(insurancePolicyParticipantRecordMap, 'benefitRoleplayerPercentage',
                        getResponseDecimal(insurancePolicyParticipantRecordMap, 'policyRoleplayerPercentage')),
                   	InsurancePolicyId = insurancePolicy.Id
                )
            );
        }
        if (!insurancePolicyParticipantList.isEmpty()) {
            uowPolicyParticipant.registerNew(insurancePolicyParticipantList);
            uowPolicyParticipant.commitWork();
        }

        return insurancePolicyParticipantList;
    }
    
     /**
     * @description create insurance policy coverage record 
     * @author Ihtishaam Mohammoodally | 15-12-2025
     * @param InsurancePolicyCoverageListRecords,insurancePolicy
     **/
    public static List<InsurancePolicyCoverage > createInsurancePolicyCoverageList( List<Object> InsurancePolicyCoverageListRecords,InsurancePolicy insurancePolicy){
        sbgplatform.fflib_SObjectUnitOfWork uowPolicyCoverage = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ InsurancePolicyCoverage.SObjectType }
        );
        List<InsurancePolicyCoverage> insurancePolicyCoverageList = new List<InsurancePolicyCoverage>(); 
        
        for(Object insurancePolicyCoverageRecord : InsurancePolicyCoverageListRecords == null ? new List<Object>() : InsurancePolicyCoverageListRecords){
            Map<String,Object> insurancePolicyCoverageRecordMap = (Map<String,Object>) insurancePolicyCoverageRecord;
            
            insurancePolicyCoverageList.add(
                new InsurancePolicyCoverage(
                    ExternalIdentifier__c = getResponseString(insurancePolicyCoverageRecordMap, 'benefitUniqueIdentifier'),
                    LimitAmount = getResponseDecimal(insurancePolicyCoverageRecordMap, 'benefitSumAssured'),
                    BenefitPaymentFrequency  = getResponseString(insurancePolicyCoverageRecordMap, 'benefitFrequency'),
                    PremiumAmount  = getResponseDecimal(insurancePolicyCoverageRecordMap, 'benefitPremium'),
                    TermFeeAmount = getResponseDecimal(insurancePolicyCoverageRecordMap, 'benefitAmount'),
                    InsurancePolicyId = insurancePolicy.Id,
                    CurrencyIsoCode = 'KES'
                )
            );            
        }        
        if (!insurancePolicyCoverageList.isEmpty()) {
            uowPolicyCoverage.registerNew(insurancePolicyCoverageList);
            uowPolicyCoverage.commitWork();
        }

        return insurancePolicyCoverageList;
    }

    private static List<Object> getResponseList(Map<String, Object> responseData, String key) {
        Object value = responseData == null ? null : responseData.get(key);
        return value instanceof List<Object> ? (List<Object>) value : new List<Object>();
    }

    private static List<Object> getBenefitRoleplayers(List<Object> benefits) {
        List<Object> result = new List<Object>();
        for (Object benefit : benefits) {
            if (benefit instanceof Map<String, Object>) {
                result.addAll(getResponseList((Map<String, Object>) benefit, 'benefitRoleplayerArray'));
            }
        }
        return result;
    }

    private static String getResponseString(Map<String, Object> responseData, String key) {
        Object value = responseData == null ? null : responseData.get(key);
        return value == null ? null : String.valueOf(value);
    }

    private static Decimal getResponseDecimal(Map<String, Object> responseData, String key) {
        return getResponseDecimal(responseData, key, null);
    }

    private static Decimal getResponseDecimal(Map<String, Object> responseData, String key, Decimal defaultValue) {
        String value = getResponseString(responseData, key);
        return String.isBlank(value) ? defaultValue : Decimal.valueOf(value);
    }

    private static Date getResponseDate(Map<String, Object> responseData, String key) {
        String value = getResponseString(responseData, key);
        return String.isBlank(value) ? null : Date.valueOf(value);
    }

}