/**
* @description BeanClass for dealing with CustomerAlert api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa (lokesh.bothsa@standardbank.co.za)
* Story Number- SFP-26345
* @date june 2023
*/
public class BCB_CustomerAlertsProfileBean {
	/**@description attribute*/
    public class BillingInformation {
		/**@description attribute*/
		public String debitAccountNumber {get;set;}
	}
 		/**@description attribute*/
	public List<SchemaRecords> schemaRecords {get;set;}
			/**@description attribute*/
	public General general {get;set;}
			/**@description attribute*/
	public ContactInformation contactInformation {get;set;}
		/**@description attribute*/
	public class SchemaRecords {
		/**@description attribute*/
		public String startTimestamp {get;set;}
		/**@description attribute*/
		public String schemeID {get;set;}
		/**@description attribute*/
		public String endDateTimestamp {get;set;}
		/**@description attribute*/
		public BillingInformation billingInformation {get;set;}
	}
		/**@description attribute*/
	public class General {
		/**@description attribute*/
		public String lastName {get;set;}
		/**@description attribute*/
		public String languageID {get;set;}
		/**@description attribute*/
		public String firstName {get;set;}
		/**@description attribute*/
		public String customerInternalID {get;set;}
		/**@description attribute*/
		public String customerHostID {get;set;}
	}
		/**@description attribute*/
	public class ContactInformation {
		/**@description attribute*/
		public String state {get;set;}
		/**@description attribute*/
		public String mobileNumber {get;set;}
		/**@description attribute*/
		public String emailID {get;set;}
		/**@description attribute*/
		public String countryCode {get;set;}
		/**@description attribute*/
		public String city {get;set;}
		/**@description attribute*/
		public String addressLine2 {get;set;}
		/**@description attribute*/
		public String addressLine1 {get;set;}
	}
}