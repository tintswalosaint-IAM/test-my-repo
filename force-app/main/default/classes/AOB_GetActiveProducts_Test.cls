/**
* @description Test Class for getting product list and returning the uganda specific list
*
*
@author amarnathreddy@standardbank.co.za
* @date July 2022
*/
@isTest
public class AOB_GetActiveProducts_Test 
{
    @isTest  static void getActiveProdList()
    {
        List<Product2> lstprod = AOB_TestDataFactory.createProduct();
        insert lstprod;     

        Test.startTest();
        List<Product2> lst = AOB_GetActiveProducts.getActiveUgandaProduct();
        Test.stopTest();
        
        System.assertequals(lst.size(), 1,'List of products count should be 1');
    }
    
}