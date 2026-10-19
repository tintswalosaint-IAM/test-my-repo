/**
*  @description Class for getting product list and returning the uganda specific list
*
@author vamshi.marripelly@standardbank.co.za*
* @date July 2022
*/
public without sharing class AOB_GetActiveProducts {
    
    @AuraEnabled(cacheable =True)
     /**
     * @description fetches products
     * @return List<Product2>
     */
    public static List<Product2> getActiveUgandaProduct()
    {
        return  [SELECT Id, Name, AOB_Account_Type__c, ProductCode, Product_Image__c, 
        Description, AOB_Product_Details__c, AOB_Memo_Code__c, AOB_Scheme_Type__c 
        FROM PRODUCT2 
        WHERE (AOB_Account_Type__c='Karibu salary account' OR AOB_Account_Type__c='Everyday Banking Account') AND IsActive = True AND Country__c = 'UG'
        ];
    }
    
}