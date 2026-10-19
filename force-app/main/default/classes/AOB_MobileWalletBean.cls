/**
* @description BeanClass for dealing with Mobile Fund api and sending the result to the main container and storing the values in the wrapper
*
*
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date Aug 2022
*/
public class AOB_MobileWalletBean {
    /** @description function parameter */
    public String function{get;set;}
    /** @description payload parameter */
    public Payload payload{get;set;}
    /** @description transfer parameter */
    public List<Transfer> transfer{get;set;}
    /**
    * @description Class for dealing with Mobile Fund api 
    */
    public class Payload {
        /** @description requestTime parameter */
        public String requestTime{get;set;}
        /** @description transactionReference parameter */
        public String transactionReference{get;set;}
        /** @description name parameter */
        public String name{get;set;}
        /** @description amount parameter */
        public String amount{get;set;}
        /** @description sessionNumber parameter */
        public String sessionNumber{get;set;}
        /** @description mobileNumber parameter */
        public String mobileNumber{get;set;}
    }
     /**
    * @description Class for dealing with account details
    */
    public class Transfer {
        /** @description accountNo parameter */
        public String accountNo{get;set;}
        /** @description amount parameter */
        public String amount{get;set;}
        /** @description name parameter */
        public String name{get;set;}
    }
}