/**
* @description Bean Class for dealing with identity api and sending the result to the main flow and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date may 2022
*/
public class AOB_CustomerVerifyBean {
    /** @description attribute **/
    public List<Customers> customers{get;set;}
    /** @description Customers is using for CustomerVerify API request body **/
    public class Customers {
        /** @description attribute **/
        public String uuid{get;set;}
    }
}