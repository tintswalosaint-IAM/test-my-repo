/**
 * @description             : Test class for INS_CTRL_productsMdt_DTO
 * @story                   : SFP-55651
 * @author                  : Irshad
 * @created date            : 30/10/2026
 *
 * NOTE: INS_products__mdt records cannot be inserted in tests, so the success
 *       path asserts against a record deployed in the org.
 */
@IsTest
private class INS_CTRL_productsMdt_DTO_TEST {

    private static final String ACTION_GET_PRODUCTS_MDT = 'getProductsMdt';
    private static final String KEY_COUNTRY             = 'Country';
    private static final String KEY_PRODUCT_ID          = 'Product_Id__c';
    private static final String KEY_PRODUCTS            = 'INS_Products__mdt';
    private static final String MASTER_LABEL            = 'Flexi Protect New';

    /**
     * @description Returns the deployed metadata record the class queries for, or
     *              null when it is not present in this org.
     */
    private static INS_products__mdt deployedProduct() {
        List<INS_products__mdt> records = [
            SELECT Country__c, Product_Id__c, Product_Code__c, PriceBook__c
            FROM   INS_products__mdt
            WHERE  MasterLabel = :MASTER_LABEL
            LIMIT  1
        ];
        return records.isEmpty() ? null : records[0];
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_productsMdt_DTO().call(ACTION_GET_PRODUCTS_MDT,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    /**
     * @description Invokes the action and reports whether it threw, so assertions
     *              stay in the @IsTest methods (see sf:NonUnitTestContainsAsserts).
     */
    private static String captureFailure(Map<String, Object> input) {
        try {
            invokeAction(input);
            return '';
        } catch (AuraHandledException ex) {
            return 'THREW';
        }
    }

    @IsTest
    static void getProductsMdt_matchingRecord_returnsProduct() {
        INS_products__mdt expected = deployedProduct();
        Assert.isNotNull(expected,
            'An INS_products__mdt record labelled "' + MASTER_LABEL + '" must be deployed');

        Test.startTest();
        Map<String, Object> output = invokeAction(new Map<String, Object>{
            KEY_COUNTRY    => expected.Country__c,
            KEY_PRODUCT_ID => expected.Product_Id__c
        });
        Test.stopTest();

        Map<String, Object> product = (Map<String, Object>) output.get(KEY_PRODUCTS);
        Assert.isNotNull(product, 'The product map should be present in the output');
        Assert.areEqual(expected.Country__c, product.get('Country__c'),
            'The country should be carried through');
        Assert.areEqual(expected.Product_Code__c, product.get('Product_Code__c'),
            'The product code should be mapped');
        Assert.areEqual(expected.PriceBook__c, product.get('PriceBook__c'),
            'The pricebook should be mapped');
        Assert.areEqual(MASTER_LABEL, product.get('MasterLabel'),
            'Only the Flexi Protect New record should be returned');
    }

    @IsTest
    static void getProductsMdt_invalidInput_throws() {
        INS_products__mdt deployed = deployedProduct();
        String validCountry = deployed == null ? 'KE' : deployed.Country__c;

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'missing country'   => new Map<String, Object>{ KEY_PRODUCT_ID => 'some-product-id' },
            'blank country'     => new Map<String, Object>{
                KEY_COUNTRY => '', KEY_PRODUCT_ID => 'some-product-id' },
            'missing productId' => new Map<String, Object>{ KEY_COUNTRY => validCountry },
            'no matching record' => new Map<String, Object>{
                KEY_COUNTRY => 'ZZ', KEY_PRODUCT_ID => 'NO_SUCH_PRODUCT' }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Assert.areEqual('THREW', captureFailure(scenarios.get(scenario)),
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }

    @IsTest
    static void call_invalidInvocations_throw() {
        Map<String, Object> validInput = new Map<String, Object>{
            KEY_COUNTRY => 'KE', KEY_PRODUCT_ID => 'some-product-id'
        };

        Boolean unsupportedThrown = false;
        try {
            new INS_CTRL_productsMdt_DTO().call('wrongAction',
                new Map<String, Object>{
                    'input'  => validInput,
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedThrown = true;
        }
        Assert.isTrue(unsupportedThrown, 'Unsupported action should throw');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_productsMdt_DTO().call(ACTION_GET_PRODUCTS_MDT,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown, 'Missing input map should throw');
    }
}