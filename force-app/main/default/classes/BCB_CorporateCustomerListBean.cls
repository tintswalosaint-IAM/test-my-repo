/**
* @description Bean Class for dealing with CreateRetailCif api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* @date june 2023
* Story Number : SFP-27033
*/
public  class BCB_CorporateCustomerListBean {
	/** @description method to parse the response*/
    public class Addresses {
		/** @description Attribute */
		public String uuid{get;set;}
		/** @description Attribute */
		public List<AddressTypes> addressTypes;
		/** @description Attribute */
		public String startDate;
	    /** @description Attribute */
		public String line1;
		 /** @description Attribute */
		public String city;
		 /** @description Attribute */
		public String province;
		 /** @description Attribute */
		public String postalCode;
		 /** @description Attribute */
		public String countryCode;
		 /** @description Attribute */
		public String plotNumber;
		 /** @description Attribute */
		public String preferredInd;
	}
 	/** @description method OrgDetails**/
	public class OrgDetails {
		 /** @description Attribute */
		public String legalName;
		 /** @description Attribute */
		public String companyName;
		 /** @description Attribute */
		public String orgEstablishDt;
		 /** @description Attribute */
		public String numEmployees;
		 /** @description Attribute */
		public String fiscalYearEnd;
		 /** @description Attribute */
		public String ownership;
	}
	/** @description method customers**/
	public List<Customers> customers;
	/** @description method Contacts**/
	public class Contacts {
		 /** @description Attribute */
		public String value;
		 /** @description Attribute */
		public String contactType;
		 /** @description Attribute */
		public String preferredInd;
		 /** @description Attribute */
		public String phoneType;
	}
/** @description method Customers**/
	public class Customers {
		 /** @description Attribute */
		public String uuid;
		 /** @description Attribute */
		public String customerType;
		 /** @description Attribute */
		public Identifications identifications;
		 /** @description Attribute */
		public OrgDetails orgDetails;
		 /** @description Attribute */
		public List<Contacts> contacts;
		 /** @description Attribute */
		public List<Addresses> addresses;
	}
/** @description method AddressTypes**/
	public class AddressTypes {
		 /** @description Attribute */
		public String addressTypes;
	}
/** @description method Identifications**/
	public class Identifications {
		 /** @description Attribute */
		public String expirationDate;
		 /** @description Attribute */
		public String PreferredIdentificationIndicator;
	}
}