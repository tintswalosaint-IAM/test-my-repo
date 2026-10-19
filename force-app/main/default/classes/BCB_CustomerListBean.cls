/**
* @description Bean  Class for dealing with CustomerList api and sending the result to the main container and storing the values in the wrapper
* @author Jagadish
* @date May 2023
* Story Number:SFP-24854
*/
public class BCB_CustomerListBean {
	/**
    * @description Addresses
    */
public class Addresses {
/**
    * @description line1
    */	
    public String line1 {get;set;}
/**
    * @description line1
    */	
    public String line2 {get;set;}
/**
    * @description line3
    */    
	public String line3 {get;set;}
    /**
    * @description addressTypes
    */ 
	public List<AddressTypes> addressTypes {get;set;}
/**
    * @description city
    */ 
    public String city {get;set;}
/**
    * @description countryCode
    */
    public String countryCode {get;set;}
/**
    * @description citizenshipCountry
    */
    public String citizenshipCountry {get;set;}
/**
    * @description comment
    */
    public String comment {get;set;}
/**
    * @description plotNumber
    */
    public String plotNumber {get;set;}
/**
    * @description preferredInd
    */
    public String preferredInd {get;set;}
/**
    * @description preferredFormat
    */
    public String preferredFormat {get;set;}
/**
    * @description province
    */
    public String province {get;set;}
/**
    * @description district
    */
    public String district {get;set;}
/**
    * @description postalCode
    */
    public String postalCode {get;set;}
}
/**
    * @description PersonDetails
    */
    public class PersonDetails {
/**
    * @description firstName
    */
        public String firstName {get;set;}
/**
    * @description lastName
    */
        public String lastName {get;set;}
/**
    * @description otherName
    */
        public String otherName {get;set;}
        /**
    * @description preferredName
    */
	public String preferredName {get;set;}
        /**
    * @description dob
    */
	public String dob {get;set;}
 /**
    * @description title
    */
        public String title {get;set;}
/**
    * @description citizenshipCountry
    */
        public RelationType citizenshipCountry {get;set;}
}
    /**
    * @description ProminentInfluentialPerson
    */
public class ProminentInfluentialPerson {
 /**
    * @description relationType
    */
    public RelationType relationType {get;set;}
}
     /**
    * @description customers
    */
public List<Customers> customers {get;set;}
/**
* @description Bean  Class for dealing with CustomerList
*/
    public class Customers {
        /**
    * @description uuid
    */
	public String uuid {get;set;}
         /**
    * @description accountNumber
    */
	public String accountNumber {get;set;}
        /**
    * @description prominentInfluentialPerson
    */
	public ProminentInfluentialPerson prominentInfluentialPerson {get;set;}
        /**
    * @description personDetails
    */
	public PersonDetails personDetails {get;set;}
          /**
    * @description addresses
    */
	public List<Addresses> addresses {get;set;}
        /**
    * @description identifications
    */
	public List<Identifications> identifications {get;set;}
    /**
    * @description contacts
    */
	public List<RelationType> contacts {get;set;}
}
     /**
    * @description AddressTypes
    */
public class AddressTypes {
     /**
    * @description addressType
    */
	public String addressType {get;set;}
    /**
    * @description startDate
    */
	public String startDate {get;set;}
/**
    * @description endDate
    */
    public String endDate {get;set;}
}
 
    
    
    /**
* @description RelationType
*/
public class RelationType {
}
/**
    * @description Identifications
    */
public class Identifications {
				/**
    * @description issuingCountry
    */
	public String issuingCountry {get;set;}
					/**
    * @description documentCode
    */
	public String documentCode {get;set;}
				/**
    * @description documentDescription
    */
	public String documentDescription {get;set;}
/**
    * @description issuedDate
    */
    public String issuedDate {get;set;}

    /**
    * @description documentTypeCode
    */
    public String documentTypeCode {get;set;}
 /**
    * @description documentTypeDescription
    */
    public String documentTypeDescription {get;set;}
/**
    * @description entityType
    */
    public String entityType {get;set;}
/**
    * @description identificationType
    */
    public String identificationType {get;set;}
/**
    * @description placeOfIssue
    */
    public String placeOfIssue {get;set;}
/**
    * @description identificationNumber
    */
    public String identificationNumber {get;set;}
/**
    * @description PreferredIdentificationIndicator
    */
    public String PreferredIdentificationIndicator {get;set;}
}
}