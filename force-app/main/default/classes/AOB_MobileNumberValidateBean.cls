/**
*@description  BeanClass for dealing with Mobile Number Validate api and sending the result to the main container and storing the values in the wrapper
*
*
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/
public with sharing class AOB_MobileNumberValidateBean {
    
	   
    /** @description Attribute */
    public Body Body{get;set;}
	/** @description Attribute */
	public class ValidateCustomer{
		 /** @description Attribute */
		public RequestData requestData{get;set;}
	}
	 /** @description Attribute */
	public class RequestData {
		 /** @description Attribute */
		public PayLoad PayLoad{get;set;}
	}
	 /** @description Attribute */
    public class PayLoad{
		 /** @description Attribute */
        public String CustomerRef{get;set;}
		 /** @description Attribute */
        public String ServiceCode{get;set;}
		 /** @description Attribute */
        public String Area{get;set;} 
    }
	 /** @description Attribute */
	public class Body{
		 /** @description Attribute */
		public ValidateCustomer ValidateCustomer{get;set;}
		 
	}
}