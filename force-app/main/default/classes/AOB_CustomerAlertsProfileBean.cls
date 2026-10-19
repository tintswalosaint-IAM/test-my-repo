/**
* @description BeanClass for dealing with CustomerAlert api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/
public class AOB_CustomerAlertsProfileBean {
    /** @description attribute **/
    public Gen general{get;set;}
    /** @description attribute **/
	public contactInfo contactInformation{get;set;}
    /** @description attribute **/
    public List<schemaRec> schemaRecords{get;set;}
    
    /** @description Gen is using for CustomerAlertsProfile API request body **/
    public class Gen {
        /** @description attribute **/
        public String customerInternalID{get;set;}
        /** @description attribute **/
        public String customerHostID{get;set;}
        /** @description attribute **/
        public String languageID{get;set;}
        /** @description attribute **/
        public String firstName{get;set;}
        /** @description attribute **/
        public String lastName{get;set;}      
    }
    /** @description ContactInfo is using for CustomerAlertsProfile API request body **/
    public class ContactInfo {
        /** @description attribute **/
        public String mobileNumber{get;set;}
        /** @description attribute **/
        public String emailID{get;set;}
        /** @description attribute **/
        public String addressLine1{get;set;}
        /** @description attribute **/
        public String addressLine2{get;set;}
        /** @description attribute **/
        public String city{get;set;}
        /** @description attribute **/
        public String state{get;set;}
        /** @description attribute **/
        public String countryCode{get;set;}
    }
    /** @description SchemaRec is using for CustomerAlertsProfile API request body **/
    public class SchemaRec {
        /** @description attribute **/
        public String schemeID{get;set;}
        /** @description attribute **/
		public BillingInformation billingInformation{get;set;}
        /** @description attribute **/
        public String startTimestamp{get;set;}
        /** @description attribute **/
        public String endDateTimestamp{get;set;}
    }
    /** @description BillingInformation is using for CustomerAlertsProfile API request body **/
    public class BillingInformation {
        /** @description attribute **/
        public String debitAccountNumber{get;set;}
    }
}