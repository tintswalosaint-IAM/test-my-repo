/**
 * @description             : Test class for FPI_RemoteAction_Utility
 * @story                   : SFP-55708
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class FPI_RemoteAction_Utility_TEST {

    private static final String CURRENCY_KES = 'KES';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setupData() {
        Product2 prod = new Product2(
            Name = 'Flexi Protect',
            IsActive = true
        );
        insert prod;

        // Standard pricebook entry must exist before a custom one can be added
        insert new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = CURRENCY_KES
        );

        Pricebook2 pb = new Pricebook2(
            Name = 'C&HNW(Kenya)',
            IsActive = true
        );
        insert pb;

        insert new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = CURRENCY_KES
        );
    }

    // =========================================================================
    // TEST HELPERS
    // =========================================================================

    private static Map<String, Object> invokeAction(String action, Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new FPI_RemoteAction_Utility().call(action,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    private static Map<String, Object> personalInformation() {
        return new Map<String, Object>{
            'FirstName'       => 'Amina',
            'LastName'        => 'Otieno',
            'Email'           => 'amina.otieno@example.com',
            'PhoneNumber'     => '254712345678',
            'OS_DateOfBirth'  => '1990-05-15',
            'Gender'          => 'Female',
            'MaritalStatus'   => 'Married',
            'IdNumber'        => '12345678'
        };
    }

    private static Id createTestAccount() {
        Map<String, Object> output = invokeAction('createAccount',
            new Map<String, Object>{ 'PersonalInformation' => personalInformation() });
        return (Id) output.get('ProspectAccountId');
    }

    private static Map<String, Object> opportunityInput(Id accountId) {
        return new Map<String, Object>{
            'accountId' => String.valueOf(accountId),
            'CreateQuoteResponse' => new Map<String, Object>{
                'quoteId'            => 'fb79d641-5a9c-4a72-b03f-46589af93a33',
                'coverAmount'        => '500000',
                'benefitAmountValue' => '250.50'
            },
            'INS_Products' => new Map<String, Object>{
                'Product__c'  => 'Flexi Protect',
                'Country__c'  => 'KE',
                'Currency__c' => CURRENCY_KES
            }
        };
    }

    // =========================================================================
    // CREATE ACCOUNT
    // =========================================================================

    @IsTest
    static void createAccount_success() {
        Test.startTest();
        Map<String, Object> output = invokeAction('createAccount',
            new Map<String, Object>{ 'PersonalInformation' => personalInformation() });
        Test.stopTest();

        Id accId = (Id) output.get('ProspectAccountId');
        Assert.isNotNull(accId, 'ProspectAccountId should be returned');

        Account acc = [
            SELECT FirstName, LastName, PersonEmail, PersonBirthdate,
                   FinServ__MaritalStatus__pc, CMN_IdentityNumber__pc
            FROM Account WHERE Id = :accId
        ];
        Assert.areEqual('Amina', acc.FirstName, 'FirstName should be mapped');
        Assert.areEqual(Date.newInstance(1990, 5, 15), acc.PersonBirthdate,
            'DOB should be parsed');
        Assert.areEqual('2', acc.FinServ__MaritalStatus__pc,
            'Married should map to picklist value 2');
        Assert.areEqual('12345678', acc.CMN_IdentityNumber__pc, 'IdNumber should be mapped');
    }

    @IsTest
    static void createAccount_missingPersonalInformation_throws() {
        Boolean thrown = false;
        try {
            invokeAction('createAccount', new Map<String, Object>());
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Missing PersonalInformation should throw');
    }

    // =========================================================================
    // CREATE OPPORTUNITY
    // =========================================================================

    @IsTest
    static void createOpportunity_success() {
        Id accId = createTestAccount();
        Map<String, Object> input =
            opportunityInput(accId);
        Test.startTest();
        Assert.isTrue(
        input.containsKey('CreateQuoteResponse'),
        'Test input must contain CreateQuoteResponse.'
        );
        Map<String, Object> output = invokeAction('createOpportunity', input);
        Test.stopTest();

        Id oppId = (Id) output.get('OppId');
        Assert.isNotNull(oppId, 'OppId should be returned');

        Opportunity opp = [
            SELECT Name, StageName, Country__c, CurrencyIsoCode,
                   Total_Cover_Amount__c, Total_Monthly_Premium__c
            FROM Opportunity WHERE Id = :oppId
        ];
        Assert.areEqual('Quoting', opp.StageName, 'Stage should be Quoting');
        Assert.areEqual('KE', opp.Country__c, 'Country should be mapped');
        Assert.areEqual(500000, opp.Total_Cover_Amount__c, 'Cover amount should be parsed');
        Assert.areEqual(250.50, opp.Total_Monthly_Premium__c, 'Premium should be parsed');

        List<OpportunityLineItem> lineItems = [
            SELECT Quantity FROM OpportunityLineItem WHERE OpportunityId = :oppId
        ];
        Assert.areEqual(1, lineItems.size(), 'One line item should be created');

        List<Quote> quotes = [
            SELECT QuoteNumber, Status, UnderwriterQuoteReferenceNumber__c, ExpirationDate
            FROM Quote WHERE OpportunityId = :oppId
        ];
        Assert.areEqual(1, quotes.size(), 'One quote should be created');
        Assert.areEqual('fb79d641-5a9c-4a72-b03f-46589af93a33',
            quotes[0].UnderwriterQuoteReferenceNumber__c, 'quoteId should be stored');
        Assert.areEqual(Date.today().addDays(30), quotes[0].ExpirationDate,
            'Expiration should be 30 days out');

        Assert.isNotNull(output.get('QuoteNumber'),
            'QuoteNumber should be returned to the OmniScript');
    }

    @IsTest
    static void createOpportunity_missingInputs_throws() {
        Boolean thrown = false;
        try {
            invokeAction('createOpportunity',
                new Map<String, Object>{ 'accountId' => 'someId' });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Missing quote/product inputs should throw');
    }

    // =========================================================================
    // UPDATE OPPORTUNITY
    // =========================================================================

    @IsTest
    static void updateOpportunity_success() {
        Id accId = createTestAccount();
        Id oppId = (Id) invokeAction('createOpportunity', opportunityInput(accId)).get('OppId');

        Test.startTest();
        Map<String, Object> output = invokeAction('updateOpportunity',
            new Map<String, Object>{
                'OppId'               => oppId,
                'BenefitAmount'       => '750000',
                'RecalculatedPremium' => '375.25'
            });
        Test.stopTest();

        Assert.areEqual('true', output.get('hasOppUpdated'), 'Update flag should be set');

        Opportunity opp = [
            SELECT Total_Cover_Amount__c, Total_Monthly_Premium__c
            FROM Opportunity WHERE Id = :oppId
        ];
        Assert.areEqual(750000, opp.Total_Cover_Amount__c, 'Cover amount should be updated');
        Assert.areEqual(375.25, opp.Total_Monthly_Premium__c, 'Premium should be updated');
    }

    @IsTest
    static void updateOpportunity_missingOppId_throws() {
        Boolean thrown = false;
        try {
            invokeAction('updateOpportunity', new Map<String, Object>());
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Missing OppId should throw');
    }

    // =========================================================================
    // PRODUCT DETAILS
    // =========================================================================

    @IsTest
    static void getProductDetails_success() {
        Test.startTest();
        Map<String, Object> output = invokeAction('getProductDetails', new Map<String, Object>());
        Test.stopTest();

        Assert.isNotNull(output.get('ProductId'), 'ProductId should be returned');
        Assert.isNotNull(output.get('PricebookId'), 'PricebookId should be returned');
        Assert.isNotNull(output.get('PricebookEntryId'), 'PricebookEntryId should be returned');
        Assert.areEqual(100, output.get('UnitPrice'), 'UnitPrice should be returned');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_unsupportedAction_throws() {
        Boolean thrown = false;
        try {
            invokeAction('wrongAction', new Map<String, Object>());
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }
}