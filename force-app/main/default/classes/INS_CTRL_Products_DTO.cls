/**
 * @description             : Remote class for getting products details
 * @story                   : SFP-55635: for guest user this must run without sharing
 * 							  Selector class not working for Guest user
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 *                          
 */
public without sharing class INS_CTRL_Products_DTO implements Callable{
    private static final String ACTION_GET_PRODUCT = 'getProductDetails';

    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get('input') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get('output') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');

        if (actionType == ACTION_GET_PRODUCT) {
            return getProductDetails(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    private static Object getProductDetails(Map<String, Object> input, Map<String, Object> output) {
        String productName   = (String) input.get('Product__c');
        String pricebookName = (String) input.get('PriceBook__c');

        if (String.isBlank(productName) || String.isBlank(pricebookName)) {
            throw new AuraHandledException('Product__c and PriceBook__c are required.');
        }

        PricebookEntry pbe;
        try {

            SEL_PriceBookEntry selPbe = new SEL_PriceBookEntry();
            pbe = new PricebookEntry();
            pbe = selPbe.selectByProdNameAndPBNameWOSharing(productName, pricebookName);           
        } catch (QueryException e) {
            throw new AuraHandledException(
                'Product/Pricebook configuration not found for: ' + productName + ' / ' + pricebookName
            );
        }

        output.put('ProductId',                pbe.Product2Id);
        output.put('PricebookId',              pbe.Pricebook2Id);
        output.put('PricebookEntryId',         pbe.Id);
        output.put('PricebookEntryUnitPrice',  pbe.UnitPrice);
        return output;
    }
}