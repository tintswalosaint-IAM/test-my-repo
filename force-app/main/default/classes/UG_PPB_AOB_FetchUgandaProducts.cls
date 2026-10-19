/***************************************************************************************
@ Author            :Jagadish
@ Date              :june 2025
@ Name of the Class :ug_ppb_aob_fetchUgandaProducts
@ Description       :Used to fetch the names of active Uganda products excluding specific memo codes.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :11th SEP
@ Modification Description : SFP-49192
***************************************************************************************/
public with sharing class UG_PPB_AOB_FetchUgandaProducts {
    @InvocableVariable(label='Product Names' description='The names of the products')
    public List<String> productName; 
    @TestVisible 
    private static Boolean throwTestException = false;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('UG_PPB_AOB_FetchUgandaProducts');

    @InvocableMethod(label='Fetch Uganda Products' description='Fetches names of active Uganda products excluding specific memo codes')
    public static List<ProductRecords> getActiveUgandaProductAgent() {
        // Initialize the result list
        List<ProductRecords> results = new List<ProductRecords>();
        

        try {
            if (throwTestException) {
       			 throw new AuraHandledException('Throw new exception');
    		}
            // Query active Uganda products
            List<String> productCodeList = new List<String>{'OD005', 'CTRAD'};
            string country = 'UG';
            List<Product2> products = new SEL_Product2().fetchPPBProductList(productCodeList,country);

            // Create a single ProductRecords instance with all product names
            ProductRecords record = new ProductRecords();
            record.productName = new List<String>();
            for (Product2 product : products) {
                record.productName.add(product.Name);
            }
            results.add(record);
            
            return results;
        } catch (Exception e) {
            // Log the error for debugging
            LOGGER.error('UG_PPB_AOB_FetchUgandaProducts:Failed to fetch active Uganda products:', e.getMessage());
            throw new AuraHandledException('UG_PPB_AOB_FetchUgandaProducts:Failed to fetch active Uganda products: ' + e.getMessage());
        }
    }
    // Define a class to hold the output structure
    public class ProductRecords {
        @InvocableVariable(label='Product Names' description='List of product names')
        public List<String> productName;
    }
}