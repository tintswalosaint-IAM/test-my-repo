/**
 *
 * Class Name      : INS_CTRL_ProspectOnboarding_TEST
 * Author          : Irshad
 * Created Date    : Jun 08, 2026
 * Description     : Test class for INS_CTRL_ProspectOnboarding.
 *                   Covers createAccount and createOpportunity actions
 *                   with positive and negative scenarios.
 */
@isTest
private class INS_CTRL_ProspectOnboarding_TEST {

    private static final String ACTION_CREATE_ACCOUNT     = 'createAccount';
    private static final String ACTION_CREATE_OPPORTUNITY = 'createOpportunity';
    private static final String KEY_PERSONAL_INFORMATION  = 'PersonalInformation';
    private static final String KEY_PROSPECT_ACCOUNT_ID   = 'ProspectAccountId';
    private static final String KEY_PRODUCT_ID            = 'ProductId';
    private static final String KEY_CREATE_QUOTE_RESPONSE = 'CreateQuoteResponse';
    private static final String STATUS_MARRIED            = 'Married';
    private static final String GENDER_FEMALE             = 'Female';
    private static final String QUOTEID                   = 'quoteId';
    private static final String ACTION_UPDATE_OPPORTUNITY = 'updateOpportunity';
    private static final String KEY_HAS_OPP_UPDATED       = 'hasOppUpdated';

    // =========================================================================
    // TEST DATA FACTORY
    // =========================================================================

    private static Map<String, Object> buildPersonalInfo(
        String firstName, String lastName, String dob,
        String email, String phone, String idNumber,
        String gender, String maritalStatus
    ) {
        return new Map<String, Object>{
            'FirstName'      => firstName,
            'LastName'       => lastName,
            'OS_DateOfBirth' => dob,
            'Email'          => email,
            'PhoneNumber'    => phone,
            'IdNumber'       => idNumber,
            'Gender'         => gender,
            'MaritalStatus'  => maritalStatus
        };
    }

    private static Map<String, Object> buildArgs(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        return new Map<String, Object>{
            'input'  => input,
            'output' => output
        };
    }

    private static Map<String, Object> buildAccountInput(
    Map<String, Object> personalInfo
    ) {
        return new Map<String, Object>{
            KEY_PERSONAL_INFORMATION => personalInfo,
            'INS_Products__mdt' => new Map<String, Object>{
            'Customer_type__c' => 'IAM Liberty'
            }
        };
    }

    /**
     * Creates Product2/PricebookEntry/prospect Account and builds the
     * matching createOpportunity input map in one call. Returns a context
     * map with 'input' and 'pbData' so callers can both invoke the action
     * and assert against the underlying test data.
     */
    private static Map<String, Object> buildOpportunityContext() {
        Product2 prod = new Product2(Name = 'Flexi Protect', IsActive = true);
        insert prod;

        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = prod.Id,
            UnitPrice    = 100.00,
            IsActive     = true,
            CurrencyIsoCode = 'KES'
        );
        insert stdPbe;

        Id rtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account - Prospect')
            .getRecordTypeId();

        Account acc = new Account(FirstName = 'Test', LastName = 'Prospect', RecordTypeId = rtId);
        insert acc;

        Map<String, Object> pbData = new Map<String, Object>{
            'pbeId'     => stdPbe.Id,
            KEY_PRODUCT_ID.toLowerCase() => prod.Id, // kept lowercase key to avoid confusion with map literal below
            'productId' => prod.Id,
            'unitPrice' => 100.00
        };

        Map<String, Object> quoteDetails = new Map<String, Object>{
            QUOTEID            => 'QT-TEST-001',
            'coverAmount'        => 500000,
            'benefitAmountValue' => '1500'
        };

        Map<String, Object> insProduct = new Map<String, Object>{
            'Product__c'  => 'Flexi Protect',
            'Country__c'  => 'KE',
            'Currency__c' => 'KES'
        };

        Map<String, Object> input = new Map<String, Object>{
            'accountId'               => String.valueOf(acc.Id),
            'assistedUserId'          => null,
            'assistedContactId'       => null,
            'PricebookEntryId'        => stdPbe.Id,
            KEY_PRODUCT_ID            => prod.Id,
            'PricebookEntryUnitPrice' => 100.00,
            KEY_CREATE_QUOTE_RESPONSE => quoteDetails,
            'INS_Products'            => insProduct
        };

        return new Map<String, Object>{
            'input'  => input,
            'pbData' => pbData
        };
    }

    // =========================================================================
    // createAccount
    // =========================================================================

    @IsTest
    static void testCreateAccount_success() {
        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Map<String, Object> pi = buildPersonalInfo(
            'John', 'Doe', '1990-06-15',
            'john.doe@test.com', '+254700000001', 'ID12345678',
            'Male', 'Single'
        );
        Map<String, Object> input = buildAccountInput(pi);
        Map<String, Object> output = new Map<String, Object>();

        // Additional marital statuses. Only the action call happens inside the
        // loop — the verifying SOQL runs once, after the loop, to satisfy
        // sf:AvoidSoqlInLoops.
        Map<String, String> otherStatusesExpected = new Map<String, String>{
            'Married'  => '2',
            'Divorced' => '4',
            'Widowed'  => '5'
        };
        List<Id> otherAccountIds = new List<Id>();
        List<String> otherExpectedCodes = new List<String>();

        Test.startTest();

        Map<String, Object> result = (Map<String, Object>) sut.call(
            ACTION_CREATE_ACCOUNT, buildArgs(input, output)
        );

        Integer idx = 0;
        for (String status : otherStatusesExpected.keySet()) {
            Map<String, Object> otherPi = buildPersonalInfo(
                'Test', 'User' + idx, '1985-01-01',
                'test' + idx + '@test.com', '+254700000002', 'IDMS' + idx,
                GENDER_FEMALE, status
            );
            Map<String, Object> otherResult = (Map<String, Object>) sut.call(
                ACTION_CREATE_ACCOUNT,
                    buildArgs(
                        buildAccountInput(otherPi),
                        new Map<String, Object>()
                    )
            );
            otherAccountIds.add((Id) otherResult.get(KEY_PROSPECT_ACCOUNT_ID));
            otherExpectedCodes.add(otherStatusesExpected.get(status));
            idx++;
        }

        Test.stopTest();

        // Primary scenario — full field assertions
        Assert.isNotNull(result.get(KEY_PROSPECT_ACCOUNT_ID),
            'ProspectAccountId should be populated on success');

        Id accountId = (Id) result.get(KEY_PROSPECT_ACCOUNT_ID);
        Account created = [
            SELECT FirstName, LastName, PersonEmail,
                   PersonBirthdate, CMN_IdentityNumber__pc,
                   PersonMobilePhone, FinServ__MaritalStatus__pc
            FROM   Account
            WHERE  Id = :accountId
            LIMIT  1
        ];

        Assert.areEqual('John', created.FirstName, 'FirstName mismatch');
        Assert.areEqual('Doe', created.LastName, 'LastName mismatch');
        Assert.areEqual('john.doe@test.com', created.PersonEmail, 'Email mismatch');
        Assert.areEqual(Date.newInstance(1990, 6, 15), created.PersonBirthdate, 'DOB mismatch');
        Assert.areEqual('ID12345678', created.CMN_IdentityNumber__pc, 'IdNumber mismatch');
        Assert.areEqual('+254700000001', created.PersonMobilePhone, 'Phone mismatch');
        Assert.areEqual('1', created.FinServ__MaritalStatus__pc,
            'MaritalStatus mismatch — Single should map to 1');

        // Other marital statuses — single bulk query outside the loop
        Map<Id, Account> otherAccounts = new Map<Id, Account>(
            [SELECT FinServ__MaritalStatus__pc FROM Account WHERE Id IN :otherAccountIds]
        );
        for (Integer i = 0; i < otherAccountIds.size(); i++) {
            Assert.areEqual(
                otherExpectedCodes[i],
                otherAccounts.get(otherAccountIds[i]).FinServ__MaritalStatus__pc,
                'Marital status mapping mismatch for account ' + otherAccountIds[i]
            );
        }
    }

    @IsTest
    static void testCreateAccount_negativeScenarios() {
        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'blank DOB' => new Map<String, Object>{
                KEY_PERSONAL_INFORMATION => buildPersonalInfo(
                    'Jane', 'Smith', '', 'jane@test.com', '+254700000003',
                    'IDXYZ', GENDER_FEMALE, STATUS_MARRIED)
            },
            'invalid DOB format' => new Map<String, Object>{
                KEY_PERSONAL_INFORMATION => buildPersonalInfo(
                    'Jane', 'Smith', 'not-a-date', 'jane@test.com', '+254700000004',
                    'IDXYZ', GENDER_FEMALE, STATUS_MARRIED)
            },
            'missing PersonalInformation map' => new Map<String, Object>()
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Boolean exceptionThrown = false;
            try {
                sut.call(ACTION_CREATE_ACCOUNT,
                    buildArgs(scenarios.get(scenario), new Map<String, Object>()));
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Assert.isTrue(exceptionThrown,
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }

    // =========================================================================
    // createOpportunity
    // =========================================================================

    @IsTest
    static void testCreateOpportunity_success() {
        Map<String, Object> ctx    = buildOpportunityContext();
        Map<String, Object> input  = (Map<String, Object>) ctx.get('input');
        Map<String, Object> pbData = (Map<String, Object>) ctx.get('pbData');
        Map<String, Object> output = new Map<String, Object>();

        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Test.startTest();

        Map<String, Object> result = (Map<String, Object>) sut.call(
            ACTION_CREATE_OPPORTUNITY, buildArgs(input, output)
        );

        // Second scenario — benefitAmountValue absent, should default to 0
        Map<String, Object> zeroBenefitCtx   = buildOpportunityContext();
        Map<String, Object> zeroBenefitInput = (Map<String, Object>) zeroBenefitCtx.get('input');
        Map<String, Object> qd = (Map<String, Object>) zeroBenefitInput.get(KEY_CREATE_QUOTE_RESPONSE);
        qd.put(QUOTEID, 'QT-TEST-002');
        qd.remove('benefitAmountValue');
        zeroBenefitInput.put(KEY_CREATE_QUOTE_RESPONSE, qd);

        Map<String, Object> zeroBenefitResult = (Map<String, Object>) sut.call(
            ACTION_CREATE_OPPORTUNITY, buildArgs(zeroBenefitInput, new Map<String, Object>())
        );

        Test.stopTest();

        // Primary scenario assertions
        Assert.isNotNull(result.get('OppId'), 'OppId should be returned on success');
        Assert.isNotNull(result.get('QuoteId'), 'QuoteId should be returned on success');

        Id oppId   = (Id) result.get('OppId');
        Id quoteId = (Id) result.get('QuoteId');

        Opportunity opp = [
            SELECT Name, StageName, Type, CloseDate,
                   Total_Cover_Amount__c, Total_Monthly_Premium__c,
                   Quote_Id__c, Country__c, CurrencyIsoCode,
                   LeadSource, Opportunity_Source__c
            FROM   Opportunity
            WHERE  Id = :oppId
            LIMIT  1
        ];
        Assert.areEqual('Quoting', opp.StageName, 'StageName mismatch');
        Assert.areEqual('Liberty Life', opp.Type, 'Type mismatch');
        Assert.areEqual('QT-TEST-001', opp.Quote_Id__c, 'Quote_Id__c mismatch');
        Assert.areEqual(500000, opp.Total_Cover_Amount__c, 'CoverAmount mismatch');
        Assert.areEqual(1500, opp.Total_Monthly_Premium__c, 'MonthlyPremium mismatch');
        Assert.areEqual('KE', opp.Country__c, 'Country mismatch');
        Assert.areEqual('KES', opp.CurrencyIsoCode, 'Currency mismatch');
        Assert.areEqual('Liberty', opp.LeadSource, 'LeadSource mismatch');
        

        Quote qt = [
            SELECT Status, UnderwriterQuoteReferenceNumber__c, ExpirationDate, CurrencyIsoCode
            FROM   Quote
            WHERE  Id = :quoteId
            LIMIT  1
        ];
        Assert.areEqual('Quote In-Progress', qt.Status, 'Quote status mismatch');
        Assert.areEqual('QT-TEST-001', qt.UnderwriterQuoteReferenceNumber__c, 'Quote ref number mismatch');
        Assert.areEqual(Date.today().addDays(30), qt.ExpirationDate, 'Quote expiry mismatch');
        Assert.areEqual('KES', qt.CurrencyIsoCode, 'Quote currency mismatch');

        OpportunityLineItem oli = [
            SELECT Quantity, UnitPrice, Product2Id, PricebookEntryId
            FROM   OpportunityLineItem
            WHERE  OpportunityId = :oppId
            LIMIT  1
        ];
        Assert.areEqual(1, oli.Quantity, 'OLI quantity mismatch');
        Assert.areEqual(100.00, oli.UnitPrice, 'OLI unit price mismatch');
        Assert.areEqual((Id) pbData.get('productId'), oli.Product2Id, 'OLI product mismatch');
        Assert.areEqual((Id) pbData.get('pbeId'), oli.PricebookEntryId, 'OLI PBE mismatch');

        // Zero-benefit scenario assertion
        Id zeroOppId = (Id) zeroBenefitResult.get('OppId');
        Opportunity zeroOpp = [
            SELECT Total_Monthly_Premium__c FROM Opportunity WHERE Id = :zeroOppId
        ];
        Assert.areEqual(0, zeroOpp.Total_Monthly_Premium__c,
            'Monthly premium should default to 0 when benefitAmountValue is absent');
    }

    @IsTest
    static void testCreateOpportunity_negativeScenarios() {
        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Map<String, Object> missingAccountId =
            (Map<String, Object>) buildOpportunityContext().get('input');
        missingAccountId.put('accountId', null);

        Map<String, Object> missingQuoteResponse =
            (Map<String, Object>) buildOpportunityContext().get('input');
        missingQuoteResponse.remove(KEY_CREATE_QUOTE_RESPONSE);

        Map<String, Object> missingInsProducts =
            (Map<String, Object>) buildOpportunityContext().get('input');
        missingInsProducts.remove('INS_Products');

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'missing accountId'           => missingAccountId,
            'missing CreateQuoteResponse' => missingQuoteResponse,
            'missing INS_Products'        => missingInsProducts
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Boolean exceptionThrown = false;
            try {
                sut.call(ACTION_CREATE_OPPORTUNITY,
                    buildArgs(scenarios.get(scenario), new Map<String, Object>()));
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Assert.isTrue(exceptionThrown,
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }

    // =========================================================================
    // call() contract
    // =========================================================================

    @IsTest
    static void testCall_negativeScenarios() {
        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Test.startTest();

        Boolean unsupportedThrown = false;
        try {
            sut.call('nonExistentAction',
                buildArgs(new Map<String, Object>(), new Map<String, Object>()));
        } catch (AuraHandledException e) {
            unsupportedThrown = true;
        }

        Boolean invalidInputThrown = false;
        try {
            sut.call(ACTION_CREATE_ACCOUNT, new Map<String, Object>{
                'input'  => 'not-a-map',
                'output' => new Map<String, Object>()
            });
        } catch (AuraHandledException e) {
            invalidInputThrown = true;
        }

        Boolean invalidOutputThrown = false;
        try {
            sut.call(ACTION_CREATE_ACCOUNT, new Map<String, Object>{
                'input'  => new Map<String, Object>(),
                'output' => 'not-a-map'
            });
        } catch (AuraHandledException e) {
            invalidOutputThrown = true;
        }

        Test.stopTest();

        Assert.isTrue(unsupportedThrown, 'AuraHandledException should be thrown for unsupported action');
        Assert.isTrue(invalidInputThrown, 'AuraHandledException should be thrown for invalid input type');
        Assert.isTrue(invalidOutputThrown, 'AuraHandledException should be thrown for invalid output type');
    }

    // =========================================================================
    // Record type cache
    // =========================================================================

    @IsTest
    static void testRecordTypeCache_reuseAcrossCalls() {
        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Map<String, Object> pi1 = buildPersonalInfo(
            'Alice', 'One', '1991-03-10', 'alice@test.com',
            '+254700000010', 'ID-CACHE-1', GENDER_FEMALE, 'Single'
        );
        Map<String, Object> pi2 = buildPersonalInfo(
            'Bob', 'Two', '1985-07-22', 'bob@test.com',
            '+254700000011', 'ID-CACHE-2', 'Male', STATUS_MARRIED
        );

        Test.startTest();

        Map<String, Object> r1 = (Map<String, Object>) sut.call(
            ACTION_CREATE_ACCOUNT,
            buildArgs(
                buildAccountInput(pi1),
                new Map<String, Object>()
            )
        );

        Map<String, Object> r2 = (Map<String, Object>) sut.call(
            ACTION_CREATE_ACCOUNT,
            buildArgs(
                buildAccountInput(pi2),
                new Map<String, Object>()
            )
        );

        Test.stopTest();

        Assert.isNotNull(r1.get(KEY_PROSPECT_ACCOUNT_ID), 'First account should be created');
        Assert.isNotNull(r2.get(KEY_PROSPECT_ACCOUNT_ID), 'Second account should be created');
        Assert.areNotEqual(
            r1.get(KEY_PROSPECT_ACCOUNT_ID),
            r2.get(KEY_PROSPECT_ACCOUNT_ID),
            'Two distinct accounts should have been created'
        );
    }
    
    // =========================================================================
    // updateOpportunity
    // =========================================================================

    @IsTest
    static void testUpdateOpportunity_success() {
        Map<String, Object> ctx    = buildOpportunityContext();
        Map<String, Object> input  = (Map<String, Object>) ctx.get('input');
        Map<String, Object> output = new Map<String, Object>();

        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        // Create the Opportunity first so there's a real record to update
        Map<String, Object> createResult = (Map<String, Object>) sut.call(
            ACTION_CREATE_OPPORTUNITY, buildArgs(input, output)
        );
        Id oppId = (Id) createResult.get('OppId');

        Map<String, Object> updateInput = new Map<String, Object>{
            'OppId'               => oppId,
            'BenefitAmount'       => '750000',
            'RecalculatedPremium' => '375.25'
        };

        Test.startTest();
        Map<String, Object> result = (Map<String, Object>) sut.call(
            ACTION_UPDATE_OPPORTUNITY, buildArgs(updateInput, new Map<String, Object>())
        );
        Test.stopTest();

        Assert.areEqual('true', result.get(KEY_HAS_OPP_UPDATED),
            'hasOppUpdated flag should be set to true on success');

        Opportunity updated = [
            SELECT Total_Cover_Amount__c, Total_Monthly_Premium__c
            FROM   Opportunity
            WHERE  Id = :oppId
            LIMIT  1
        ];
        Assert.areEqual(750000, updated.Total_Cover_Amount__c,
            'Cover amount should be updated to the new BenefitAmount');
        Assert.areEqual(375.25, updated.Total_Monthly_Premium__c,
            'Monthly premium should be updated to the new RecalculatedPremium');
    }

    @IsTest
    static void testUpdateOpportunity_negativeScenarios() {
        INS_CTRL_ProspectOnboarding sut = new INS_CTRL_ProspectOnboarding();

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'missing OppId' => new Map<String, Object>{
                'BenefitAmount'       => '750000',
                'RecalculatedPremium' => '375.25'
            },
            'null OppId' => new Map<String, Object>{
                'OppId'               => null,
                'BenefitAmount'       => '750000',
                'RecalculatedPremium' => '375.25'
            }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Boolean exceptionThrown = false;
            try {
                sut.call(ACTION_UPDATE_OPPORTUNITY,
                    buildArgs(scenarios.get(scenario), new Map<String, Object>()));
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Assert.isTrue(exceptionThrown,
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }
}