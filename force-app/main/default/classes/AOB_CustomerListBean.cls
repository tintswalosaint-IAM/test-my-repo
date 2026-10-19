/**
* @description Bean  Class for dealing with signature api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date July 2022
*/
public inherited sharing class AOB_CustomerListBean {
     /** @description attribute **/
    public List<Customers> customers{get;set;}
    /** @description Customers is using for CustomerList API request body **/
    public class Customers {
         /** @description attribute **/
        public String uuid{get;set;}
    }
}