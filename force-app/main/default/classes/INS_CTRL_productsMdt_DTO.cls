/**
 * @description  : OmniScript Remote Action returning a single INS_products__mdt
 *                 record to the calling OmniScript, keyed by country and product.
 *
 * @story        : SFP-55651
 * @author       : Irshad
 * @created date : Mar 12, 2026
 * Test Class    : INS_CTRL_productsMdt_DTO_TEST
 */
public without sharing class INS_CTRL_productsMdt_DTO implements Callable {

    private static final String ACTION_GET_PRODUCTS_MDT = 'getProductsMdt';

    private static final String KEY_INPUT       = 'input';
    private static final String KEY_OUTPUT      = 'output';
    private static final String KEY_COUNTRY     = 'Country';
    private static final String KEY_PRODUCT_ID  = 'Product_Id__c';
    private static final String KEY_PRODUCTS    = 'INS_Products__mdt';

    private static final String MASTER_LABEL_FLEXI_PROTECT = 'Flexi Protect New';

    // =========================================================================
    // CALLABLE ENTRY POINT
    // =========================================================================

    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get(KEY_INPUT) instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get(KEY_OUTPUT) instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get(KEY_INPUT);
        Map<String, Object> output = (Map<String, Object>) args.get(KEY_OUTPUT);

        if (actionType == ACTION_GET_PRODUCTS_MDT) {
            return getProductsMdt(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // =========================================================================
    // FETCH PRODUCT METADATA
    // =========================================================================

    /**
     * @description Returns the product metadata record matching the supplied
     *              country and product id, under the key INS_Products__mdt.
     * @param input  Must contain Country and Product_Id__c
     * @param output Populated with the product metadata
     * @return       The populated output map
     */
    @AuraEnabled(cacheable=false)
    public static Object getProductsMdt(Map<String, Object> input, Map<String, Object> output) {
        if (output == null) {
            output = new Map<String, Object>();
        }

        String country   = getString(input, KEY_COUNTRY);
        String productId = getString(input, KEY_PRODUCT_ID);

        if (String.isBlank(country)) {
            throw new AuraHandledException('Country is required to retrieve product metadata.');
        }
        if (String.isBlank(productId)) {
            throw new AuraHandledException('Product_Id__c is required to retrieve product metadata.');
        }

        List<INS_products__mdt> records = [
            SELECT  Id,
                    MasterLabel,
                    DeveloperName,
                    Country__c,
                    Country_of_Issue__c,
                    PriceBook__c,
                    Product__c,
                    Product_Code__c,
                    Payment_Method__c,
                    Default_Cover_Amount__c,
                    Experience_Verification_Type__c,
                    FSC_Verification__c,
                    Bank_Name__c,
                    Currency__c,
                    MPESA_Branch_Code__c,
                    CashBack_Benefit__c,
					INS_Common_KYC__c,
					INS_Customer_Brand__c
            FROM    INS_products__mdt
            WHERE   Country__c    = :country
            AND     Product_Id__c = :productId
            AND     MasterLabel   = :MASTER_LABEL_FLEXI_PROTECT
            LIMIT   1
        ];

        if (records.isEmpty()) {
            AuraHandledException e = new AuraHandledException(
                'No product metadata found for country ' + country + ' and product ' + productId);
            e.setMessage(
                'No product metadata found for country ' + country + ' and product ' + productId);
            throw e;
        }

        output.put(KEY_PRODUCTS, buildProductMap(records[0]));
        return output;
    }

    /**
     * @description Maps the metadata record onto the shape the OmniScript consumes.
     * @param product The metadata record
     * @return        Product detail map
     */
    private static Map<String, Object> buildProductMap(INS_products__mdt product) {
        return new Map<String, Object>{
            'Id'                             => product.Id,
            'MasterLabel'                    => product.MasterLabel,
            'DeveloperName'                  => product.DeveloperName,
            'Country__c'                     => product.Country__c,
            'Country_of_Issue__c'            => product.Country_of_Issue__c,
            'PriceBook__c'                   => product.PriceBook__c,
            'Product__c'                     => product.Product__c,
            'Product_Code__c'                => product.Product_Code__c,
            'Payment_Method__c'              => product.Payment_Method__c,
            'Default_Cover_Amount__c'        => product.Default_Cover_Amount__c,
            'Experience_Verification_Type__c' => product.Experience_Verification_Type__c,
            'FSC_Verification__c'            => product.FSC_Verification__c,
            'Bank_Name__c'                   => product.Bank_Name__c,
            'MPESA_Branch_Code__c'           => product.MPESA_Branch_Code__c,
            'Currency__c'                    => product.Currency__c,
            'CashBack_Benefit__c'            => product.CashBack_Benefit__c,
			'Customer_type__c'               => product.INS_Customer_Brand__c,
			'INS_Common_KYC__c'				 => product.INS_Common_KYC__c
        };
    }

    private static String getString(Map<String, Object> source, String key) {
        Object value = source == null ? null : source.get(key);
        return value == null ? null : String.valueOf(value);
    }
}