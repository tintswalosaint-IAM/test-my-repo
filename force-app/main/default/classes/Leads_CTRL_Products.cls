/**
* @description       : SFP-54443 - Controller class for the Product picklist values in the Leads flow.
* @author            : Release Manager
* @group             : Standard Bank
* @last modified on  : 20-07-2026
* @last modified by  : Raja Arsalan
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   01-12-2022   Release Manager  Initial Version
* 2.0   20-07-2026   Raja Arsalan     Removed the logic from the class and moved to the service class INS_SRV_Products.
**/
public inherited sharing class Leads_CTRL_Products {
    
    public static final String SERVICE_NAME = Leads_CTRL_Products.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    
    
    /**
* @description Retrieves the available values for the specified pic field.
*
* @param       fieldName 
* @return      A list of INS_DTO_ProductResponse objects
*/        
    
    @AuraEnabled
    public static List<INS_SRV_Products.INS_DTO_ProductResponse> getAvailableValuesinPickList(String fieldName) {
        try {
            return INS_SRV_Products.getAvailableValuesinPickList(fieldName);
        } catch (Exception ex) {
            LOGGER.error('Leads_CTRL_Products | getAvailableValuesinPickList',
                         ex);     
            return new List<INS_SRV_Products.INS_DTO_ProductResponse>();
        }
        
    }
    
    /**
* @description Retrieves the list of available products based on the provided jurisdiction and segment.
*
* @param Jurisdiction
* @param Segment
* @return A list of INS_DTO_ProductResponse objects
*/    
    @AuraEnabled
    public static List<INS_SRV_Products.INS_DTO_ProductResponse> getAvailableProducts(
        String Jurisdiction,
        String Segment
    ) {
        try {
            if (String.isBlank(Jurisdiction) && String.isBlank(Segment)) {
                LOGGER.debug('Leads_CTRL_Products | getAvailableProducts | Jurisdiction '
                             + Jurisdiction + ' | Segment | ' + Segment );
                return new List<INS_SRV_Products.INS_DTO_ProductResponse>();
            }
            
            return INS_SRV_Products.getAvailableProducts(Jurisdiction, Segment);
        } catch (Exception ex) {
            LOGGER.error('Leads_CTRL_Products | getAvailableProducts', ex);  
            return new List<INS_SRV_Products.INS_DTO_ProductResponse>();
        }
    }
}