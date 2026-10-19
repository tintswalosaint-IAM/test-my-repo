/**
* @description BeanClass for dealing with SMS Alert api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/

public without sharing class AOB_SMSAlertBean {
    
    /** @description Cell Phone Number */
    public String cellphoneNumber {get;set;}
    /** @description Custom Message attribute */
    public String message {get;set;}
    /** @description Tracking Number/salesforce id */
    public String trackingNumber {get;set;}
    /** @description Country of the phone number */
    public String countryISO {get;set;}
    /** @description Source System to track external system */
    public String sourceSystem {get;set;}
}