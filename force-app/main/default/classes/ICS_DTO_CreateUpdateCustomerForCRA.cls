/**
* @description class Used as DTO class for sending POA request to Relycomply
*
* Story:SFP-36390 
*
* @author Ikyatha Naidu 
*
* @date  23/03/2024
 ***************************************************************************************
* @last modified on  : 29-02-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description :SFP-36390, class Used to create Data, mostly for unit tests for SBO-UK
 ***************************************************************************************
 * @Last Modified By        : Ridhima Saxena
 * @Last Modified On         : 12-12-2025
 * @Modification description : SFP-53899: Updated populateMexicoDocuments send proper json for mexico.
 ***************************************************************************************
  * @Last Modified By        : Ridhima Saxena
 * @Last Modified On         : 12-12-2025
 * @Modification description : SFP-53338: Updated NZDrivingLicence
*/
public with sharing class ICS_DTO_CreateUpdateCustomerForCRA { 
    
    
    /**
    * Inner class representing Address details.
    */
    public class Address {
        /** Building details. */
        public String Building {get;set;}

        public String City {get;set;}
        /** SubCity details. */
        public String SubCity {get;set;}
        /** Country details. */
        public String Country {get;set;}
        /** Street details. */
        
        /** Street details. */
        public String Street {get;set;}
        /** SubStreet details. */
        public String SubStreet {get;set;}
        /** Zip or Postcode details. */
        public String ZipPostcode {get;set;}
        /** State or District details. */
        public String StateDistrict {get;set;}
        /** PO Box details. */
        public String POBox {get;set;}
        /** Region details. */
        public String Region {get;set;}
        /** Principality details. */
        public String Principality {get;set;}
        /** Dps Zip Plus details. */
        public String DpsZipPlus {get;set;}
        /** Cedex Mailsort details. */
        public String CedexMailsort {get;set;}
        /** Department details. */
        public String Department {get;set;}
        /** Company details. */
        public String Company {get;set;}
        /** SubBuilding details. */
        public String SubBuilding {get;set;}
        /** Premise details. */
        public String Premise {get;set;}
        /** Address Line 1 details. */
        public String AddressLine1 {get;set;}
        /** Address Line 2 details. */
        public String AddressLine2 {get;set;}
        /** Address Line 3 details. */
        public String AddressLine3 {get;set;}
        /** Address Line 4 details. */
        public String AddressLine4 {get;set;}
        /** Address Line 5 details. */
        public String AddressLine5 {get;set;}
        /** Address Line 6 details. */
        public String AddressLine6 {get;set;}
        /** Address Line 7 details. */
        public String AddressLine7 {get;set;}
        /** Address Line 8 details. */
        public String AddressLine8 {get;set;}
        /** First Year of Residence details. */
        public Integer FirstYearOfResidence {get;set;}
        /** Last Year of Residence details. */
        public Integer LastYearOfResidence {get;set;}
        /** First Month of Residence details. */
        public Integer FirstMonthOfResidence {get;set;}
        /** Last Month of Residence details. */
        public Integer LastMonthOfResidence {get;set;}
    }
    
    /**
    * Inner class representing DNINumber details.
    */
    public class DNINumber {
        /** in json: Number. */
        public Integer Number_Z {get;set;}
    }
    
   /**
    * Inner class representing DrivingLicence details.
    */
    public class DrivingLicence {
        /** in json: Number. */
        public String Number_Z {get;set;}
        /** State details. */
        public String State {get;set;}
        /** Expiry Day details. */
        public Integer ExpiryDay {get;set;}
        /** Expiry Month details. */
        public Integer ExpiryMonth {get;set;}
        /** Expiry Year details. */
        public Integer ExpiryYear {get;set;}
        /** Issue Day details. */
        public Integer IssueDay {get;set;}
        /** Issue Month details. */
        public Integer IssueMonth {get;set;}
        /** Issue Number details. */
        public Integer IssueNumber {get;set;}
        /** Issue Year details. */
        public Integer IssueYear {get;set;}
        /** Mail Sort details. */
        public String MailSort {get;set;}
        /** Microfiche details. */
        public String Microfiche {get;set;}
        /** Postcode details. */
        public String Postcode {get;set;}
        /** Vehicle Registration details. */
        public String VehicleRegistration {get;set;}
        /** Version details. */
        public String Version {get;set;}
        /** Card Number details. */
        public String CardNumber {get;set;}
    }
    /**
    * Properties for main class
    */
    
    /** Address object. */
    public Address Address {get;set;}
    /** Contact Details object. */
    public ContactDetails ContactDetails {get;set;}
    /** Country Profile Id. */
    public String CountryProfileId {get;set;}
    /** Customer Id. */
    public String CustomerId {get;set;}
    /** Identity Documents object. */
    public IdentityDocuments IdentityDocuments {get;set;}
    /** Is Existing Customer flag. */
    public Boolean IsExistingCustomer {get;set;}
    /** Personal Details object. */
    public PersonalDetails  personalDetails{get;set;}
   
    /** Middle Name details. */
   
    /** Nationality details. */
   
      /**
    * Inner class representing Passport details.
    **/
    public class Passport {
        /** Expiry Day details. */
        public Integer ExpiryDay {get;set;}
        /** Expiry Month details. */
        public Integer ExpiryMonth {get;set;}
        /** Expiry Year details. */
        public Integer ExpiryYear {get;set;}
        /** in json: Number. */
        public String Number_Z {get;set;}
    }
    /**
    * Inner class representing ContactDetails details.
    **/
    public class ContactDetails {
        /** Email details. */
        public String Email {get;set;}
        /** Land Telephone details. */
        public LandTelephone LandTelephone {get;set;}
        /** Mobile Telephone details. */
        public MobileTelephone MobileTelephone {get;set;}
        /** Work Telephone details. */
        public MobileTelephone WorkTelephone {get;set;}
    }
    
   /** Card Type details. */
    public Integer CardType {get;set;}
     /**
    * Inner class representing UK details.
    **/
    public class UK {
        /** Driving Licence details. */
        public DrivingLicence DrivingLicence {get;set;}
        /** National Insurance Number details. */
        public CPFNumber NationalInsuranceNumber {get;set;}
        /** Passport details. */
        public Passport Passport {get;set;}
    }
   /**
    * Inner class representing Brazil details.
    **/
    public class Brazil {
        /** CPF Number details. */
        public CPFNumber CPFNumber {get;set;}
    }
   /**
    * Inner class representing EuropeanIdentityCard details.
    **/
    public class EuropeanIdentityCard {
        /** Country of Issue details. */
        public String CountryOfIssue {get;set;}
        /** Country of Nationality details. */
        public String CountryOfNationality {get;set;}
        /** Expiry Day details. */
        public Integer ExpiryDay {get;set;}
        /** Expiry Month details. */
        public Integer ExpiryMonth {get;set;}
        /** Expiry Year details. */
        public Integer ExpiryYear {get;set;}
        /** Line 1 details. */
        public String Line1 {get;set;}
        /** Line 2 details. */
        public String Line2 {get;set;}
        /** Line 3 details. */
        public String Line3 {get;set;}
    }
    /**
    * Inner class representing CPFNumber details.
    **/
    public class CPFNumber {
        /** in json: Number. */
        public String Number_Z {get;set;}
    }
    /**
    * Inner class representing InternationalPassport details.
    **/
    public class InternationalPassport {
        /** Country of Origin details. */
        public String CountryOfOrigin {get;set;}
        /** Expiry Day details. */
        public Integer ExpiryDay {get;set;}
        /** Expiry Month details. */
        public Integer ExpiryMonth {get;set;}
        /** Expiry Year details. */
        public Integer ExpiryYear {get;set;}
        /** Issue Day details. */
        public Integer IssueDay {get;set;}
        /** Issue Month details. */
        public Integer IssueMonth {get;set;}
        /** Issue Year details. */
        public Integer IssueYear {get;set;}
        /** in json: Number. */
        public String Number_Z {get;set;}
        /** Short Passport Number details. */
        public String ShortPassportNumber {get;set;}
    }
    /**
    * Inner class representing US details.
    **/
    public class US {
        /** Driving Licence details. */
        public DrivingLicence DrivingLicense {get;set;}
        /** Social Security details. */
        public CPFNumber SocialSecurity {get;set;}
    }
   /**
    * Inner class representing IdentityCard details.
    **/
    public class IdentityCard {
        /** Country details. */
        public String Country {get;set;}
        /** in json: Number. */
        public String Number_Z {get;set;}
    }
    /**
    * Inner class representing Argentina details.
    **/
    public class Argentina {
        /** DNI Number details. */
        public DNINumber DNINumber {get;set;}
        /** Tax Identification Number details. */
        public MobileTelephone TaxIdentificationNumber {get;set;}
    }
    
   /**
    * Inner class representing Medicare details.
    */
    public class Medicare {
        /** Holds the color of the Medicare card. */
        public String CardColour {get;set;}
        /** Holds the number of the Medicare card. */
        public String CardNumber {get;set;}
        /** Holds the day of expiry for the Medicare card. */
        public Integer ExpiryDay {get;set;}
        /** Holds the month of expiry for the Medicare card. */
        public Integer ExpiryMonth {get;set;}
        /** Holds the year of expiry for the Medicare card. */
        public Integer ExpiryYear {get;set;}
        /** Holds the middle name on the Medicare card. */
        public String MiddleNameOnCard {get;set;}
        /** Holds the reference number related to Medicare details. */
        public String ReferenceNumber {get;set;}
        /** Holds the surname at citizenship associated with the Medicare card. */
        public String SurnameAtCitizenship {get;set;}
    }

	public class NZDrivingLicence {
        public String Number_Z {get;set;}
        public String VehicleRegistration {get;set;}
        public String Version {get;set;}
    }
    /**
    * Inner class representing MobileTelephone details.
    **/
    public class MobileTelephone {
        /** Mobile Number details. */
        public String Number_Z {get;set;}
    }
    /**
    * Inner class representing China_Z details.
    */
    public class China_Z {
        /** Resident Identity Card details */
        public CPFNumber ResidentIdentityCard {get;set;}
    }

    /**
    * Inner class representing ShortPassport details.
    */
    public class ShortPassport {
        /** Country of Origin details */
        public String CountryOfOrigin {get;set;}
        
        /** Number details (in JSON: Number) */
        public String Number_Z {get;set;}
    }

    /**
    * Inner class representing PersonalDetails details.
    **/
    public class PersonalDetails {
        /** Date of Birth details. */
        public String DateOfBirth {get;set;}
        /** Forename details. */
        public String Forename {get;set;}
        /** Gender details. */
        public Integer Gender {get;set;}
        public String MiddleName {get;set;}
        /** Surname details. */
    	public String Surname {get;set;}
    	/** Title details. */
    	public String Title {get;set;}
        /** Nationality details. */
        public String Nationality {get;set;}
    }

    /**
    * Inner class representing India details.
    */
    public class India {
        /** Driving Licence details */
        public CPFNumber DrivingLicence {get;set;}
        
        /** Epic details */
        public CPFNumber Epic {get;set;}
        
        /** PAN details */
        public CPFNumber PAN {get;set;}
    }

    /**
    * Inner class representing Spain details.
    */
    public class Spain {
        /** Tax ID Number details */
        public CPFNumber TaxIDNumber {get;set;}
    }

   /**
    * Inner class representing Canada details.
    */
    public class Canada {
        /** Social Insurance Number details */
        public CPFNumber SocialInsuranceNumber {get;set;}
    }

    
    /**
    * Inner class representing IdentityDocuments details.
    */
    public class IdentityDocuments {
        /** Argentina details */
        public Argentina Argentina {get;set;}
        /** Australia details */
        public Australia Australia {get;set;}
        /** Brazil details */
        public Brazil Brazil {get;set;}
        /** Canada details */
        public Canada Canada {get;set;}
        /** China details */
        public China_Z China {get;set;}
        /** European Identity Card details */
        public EuropeanIdentityCard EuropeanIdentityCard {get;set;}
        /** Identity Card details */
        public IdentityCard IdentityCard {get;set;}
        /** India details */
        public India India {get;set;}
        /** International Passport details */
        public InternationalPassport InternationalPassport {get;set;}
        /** Mexico details */
        public Mexico Mexico {get;set;}
        /** New Zealand details */
        public NewZealand NewZealand {get;set;}
        /** Spain details */
        public Spain Spain {get;set;}
        /** UK details */
        public UK UK {get;set;}
        /** US details */
        public US US {get;set;}
    }

    
    /**
    * Inner class representing LandTelephone details
    **/
    
    public class LandTelephone {
        /** Ex Directory details **/
        public Boolean ExDirectory {get;set;} 
        /** Number **/
        public String Number_Z {get;set;} 
    }
    
     /**
    * Inner class representing Mexico details.
    */
    public class Mexico {
        /** Tax Identification Number details */
        public CPFNumber IdentityCard {get;set;}
    }

    
     /**
    * Inner class representing Australia details.
    */
    public class Australia {
        /** Driving Licence details */
        public DrivingLicence DrivingLicence {get;set;}
        
        /** Medicare details */
        public Medicare Medicare {get;set;}
        
        /** Short Passport details */
        public ShortPassport ShortPassport {get;set;}
    }

    /**
    * Inner class representing NewZealand details.
    */
    public class NewZealand {
        /** Driving Licence details */
        public NZDrivingLicence DrivingLicence {get;set;}
    }

}