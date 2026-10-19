/**
* @description Bean Class for dealing with Customer Risk Assessment api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/

public class AOB_CustomerRiskAssessmentBean { 
    /** @description attribute */
	public String CustomerEntityType{get;set;}
    /** @description attribute */
    public String ProductSchemeCode{get;set;}
    /** @description attribute */
    public String DistributionChannel{get;set;}
    /** @description attribute */
    public String NonResidentIndicator{get;set;}
    /** @description attribute */
    public String PEPIndicator{get;set;}
    /** @description attribute */
    public String ForeignCustomerIndicator{get;set;}
    /** @description attribute */
    public String CustomerEmploymentType{get;set;}
    /** @description attribute */
    public String HomeAddressCountryCode{get;set;}
    /** @description attribute */
    public String MailingAddressCountryCode{get;set;}
    /** @description attribute */
    public String NationalityOfCustomer{get;set;}
    /** @description attribute */
    public String CountryOfBirth{get;set;}
    /** @description attribute */
    public String SegmentOfCustomer{get;set;}
    /** @description attribute */
    public String SubSegmentOfCustomer{get;set;}
}