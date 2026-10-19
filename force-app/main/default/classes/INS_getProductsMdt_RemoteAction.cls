/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : INS_getProductsMdt_RemoteAction
 * Author          : <YourName>
 * Created Date    : Mar 12, 2026
 * Last Modified By: <YourName>
 * Last Modified On:
 * Description     : OmniScript Remote Action to fetch records from INS_products__mdt
 *                   custom metadata type and return them to the calling OmniScript.
 *
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Mar 12, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

global without sharing class INS_getProductsMdt_RemoteAction implements Callable {

    private static final String ACTION_GET_PRODUCTS_MDT  = 'getProductsMdt';
    

    // ======================================================
    // MAIN CALLABLE ENTRY — Required for OmniScript
    // ======================================================

    global Object call(String actionType, Map<String, Object> args) {

        if (actionType == ACTION_GET_PRODUCTS_MDT) {
            Map<String, Object> input  = (Map<String, Object>) args.get('input');
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return getProductsMdt(input, output);
        }       

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // ======================================================
    // FETCH INS_products__mdt RECORDS
    // ======================================================

    /**
     * @description Queries records from INS_products__mdt and returns them in the
     *              output map under the key 'products'.
     *              Optionally filters by Country__c when 'country' is supplied in input.
     */
    @AuraEnabled(cacheable=false)
    public static Object getProductsMdt(Map<String, Object> input, Map<String, Object> output) {

        String country = (input != null) ? (String) input.get('Country') : null;
		String productId = (input != null) ? (String) input.get('Product_Id__c') : null;

        List<INS_products__mdt> records;

        if (String.isNotBlank(country)) {
            records = [
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
						CashBack_Benefit__c
                FROM    INS_products__mdt
                WHERE   Country__c = :country
				AND 	Product_Id__c=: productId
				AND 	MasterLabel = 'Flexi Protect New'
				LIMIT 	1
            ];
        }

        
		Map<String, Object> productMap = new Map<String, Object>();
        productMap.put('Id',                    records[0].Id);
		productMap.put('MasterLabel',           records[0].MasterLabel);
		productMap.put('DeveloperName',         records[0].DeveloperName);
		productMap.put('Country__c',            records[0].Country__c);
		productMap.put('Country_of_Issue__c',   records[0].Country_of_Issue__c);
		productMap.put('PriceBook__c',          records[0].PriceBook__c);
		productMap.put('Product__c',            records[0].Product__c);
		productMap.put('Product_Code__c',       records[0].Product_Code__c);
		productMap.put('Default_Cover_Amount__c', records[0].Default_Cover_Amount__c);
		productMap.put('Experience_Verification_Type__c', records[0].Experience_Verification_Type__c);
		productMap.put('FSC_Verification__c',   records[0].FSC_Verification__c);
		productMap.put('Bank_Name__c',          records[0].Bank_Name__c);
        productMap.put('MPESA_Branch_Code__c',  records[0].MPESA_Branch_Code__c);
		productMap.put('Currency__c',          records[0].Currency__c);
		productMap.put('CashBack_Benefit__c',  records[0].CashBack_Benefit__c);

        output.put('INS_Products__mdt', productMap);
        return output;
    }

    
}