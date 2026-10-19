/**
* @description Bean Class for dealing with CreateRetailCif api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* Story Number - SFP-24866
* @date june 2023
*/
public class BCB_CreateRetailCifBean {
    /**@description attribute*/
    public String seniorIndicator;
    /**@description attribute*/
    public String portFolioNum; 
    /**@description attribute*/
    public String enableCrmAlerts;
    /**@description attribute*/
    public String segmentCategory;
    /**@description attribute*/
    public String responsibleBranch;
    /**@description attribute*/
    public String residenceCountry;
    /**@description attribute*/
    public String relManagerLink;
    /**@description attribute*/
    public String prefLanguage;
    /**@description attribute*/
    public String mktgSegment;
    /**@description attribute*/
    public String minorIndicator;
    /**@description attribute*/
    public String EASIndicator;
    /**@description attribute*/
    public String customerType;
    /**@description attribute*/
    public String authorizationGroup;
    /**@description attribute*/
    public String accessOwnerSegment;
    /**@description attribute*/
    public String gIIN;
    /**@description attribute*/
    public PersonDetails personDetails;
    /**@description attribute*/
    public OrgDetails orgDetails;
    /**@description attribute*/
    public ProminentInfluentialPerson prominentInfluentialPerson;
    /**@description attribute*/
    public TaxClassification taxClassification;
    /**@description attribute*/
    public EmploymentDetails employmentDetails;
    /**@description attribute*/
    public List<Addresses> addresses;
    /**@description attribute*/
    public List<CustomerRoles> customerRoles;
    /**@description attribute*/
    public List<Contacts> contacts;
    /**@description attribute*/
    public List<ComplianceRoles> complianceRoles;
    /**@description attribute*/
    public List<IndustrialSectors> industrialSectors;
    /**@description attribute*/
    public List<Identification> identification;
    /**@description attribute*/
    public List<MktgConsents> mktgConsents;
    /**@description attribute*/
    public List<Misc> misc;
    /**@description attribute*/
    public List<Permits> permits;
    /**@description attribute*/
    public List<SourceOfFunds> sourceOfFunds;
    /**@description attribute*/
    public List<TaxDetails> taxDetails;
    
    
    /**@description inner class to parse*/
    public class EmploymentDetails {
        /**@description attribute*/
        public String startDate;
        /**@description attribute*/
        public String staffIndicator;
        /**@description attribute*/
        public String orgName;
        /**@description attribute*/
        public String occupation;
        /**@description attribute*/
        public String industrialSector;
        /**@description attribute*/
        public String endDate;
        /**@description attribute*/
        public String employmentType;
    }
    /**@description inner class to parse*/
    public class ProminentInfluentialPerson {
        /**@description attribute*/
        public String relationType;
        /**@description attribute*/
        public String relatedInd;
        /**@description attribute*/
        public String pipInd;
        /**@description attribute*/
        public String name;
    }
    /**@description inner class to parse*/
    public class IndustrialSectors {
        /**@description attribute*/
        public String industrialSector;
        /**@description attribute*/
        public String industrialClassificationSystem;
    }
    /**@description inner class to parse*/
    public class Misc {
        /**@description attribute*/
        public String value;
        /**@description attribute*/
        public String miscDate;
        /**@description attribute*/
        public String key;
        /**@description attribute*/
        public String distributionChannel;
        /**@description attribute*/
        public String counterPartyInfo;
    }
    /**@description inner class to parse*/
    public class SourceOfFunds {
        /**description attribute*/
        public String tradeFinanceIndicator;
        /**description attribute*/
        public String sourceFundType;
        /**description attribute*/
        public String sourceFundAmount;
        /**description attribute*/
        public String currencyCode;
    }
    /**@description inner class to parse*/
    public class Identification {
        /**description attribute*/
        public String PreferredIdentificationIndicator;
        /**description attribute*/
        public String issuingCountry;
        /**description attribute*/
        public String issuedOrganisation;
        /**description attribute*/
        public String issuedDate;
        /**description attribute*/
        public String identificationType;
        /**description attribute*/
        public String identificationNumber;
        /**description attribute*/
        public String expirationDate;
        /**description attribute*/
        public String documentTypeDescription;
        /**description attribute*/
        public String documentTypeCode;
        /**description attribute*/
        public String documentDescription;
        /**description attribute*/
        public String documentCode;
    }
    /**@description inner class to parse*/
    public class StudentDetails {
        /**description attribute*/
        public String studyYear;
        /**description attribute*/
        public String renewalDate;
        /**description attribute*/
        public String Institution;
        /**description attribute*/
        public String expectedCompletionDate;
        /**description attribute*/
        public String enrollmentType;
        /**description attribute*/
        public String courseName;
        /**description attribute*/
        public String commencedDate;
    }
    /**@description inner class to parse*/
    public class Addresses {
        /**description attribute*/
        public String uuid;
        /**description attribute*/
        public String startDate;
        /**description attribute*/
        public String province;
        /**description attribute*/
        public String preferredInd;
        /**description attribute*/
        public String preferredFormat;
        /**description attribute*/
        public String postalCode;
        /**description attribute*/
        public String line3;
        /**description attribute*/
        public String line2;
        /**description attribute*/
        public String line1;
        /**description attribute*/
        public String countryCode;
        /**description attribute*/
        public String comment;
        /**description attribute*/
        public String city;
        /**description attribute*/
        public List<AddressTypes> addressTypes;
    }
    /**@description inner class to parse*/
    public class PersonDetails {
        /**description attribute*/
        public String title;
        /**description attribute*/
        public Boolean studentIndicator;
        /**description attribute*/
        public StudentDetails studentDetails;
        /**description attribute*/
        public String qualification;
        /**description attribute*/
        public String purgeAllowedIndicator;
        /**description attribute*/
        public String preferredName;
        /**description attribute*/
        public Object otherName;
        /**description attribute*/
        public String nationality;
        /**description attribute*/
        public String maritalStatus;
        /**description attribute*/
        public String maritalPropertyRegime;
        /**description attribute*/
        public String lastName;
        /**description attribute*/
        public String initials;
        /**description attribute*/
        public String homeOwnership;
        /**description attribute*/
        public String gender;
        /**description attribute*/
        public String foreignNationalStatus;
        /**description attribute*/
        public String foreignNationalReport;
        /**description attribute*/
        public String foreignNationalIndicator;
        /**description attribute*/
        public String firstName;
        /**description attribute*/
        public String ethnicity;
        /**description attribute*/
        public String dob;
        /**description attribute*/
        public String digitalBankingIndicator;
        /**description attribute*/
        public Integer dependantsMinor;
        /**description attribute*/
        public Integer dependants;
        /**description attribute*/
        public String countryOfBirth;
        /**description attribute*/
        public String clientType;
        /**description attribute*/
        public String citizenshipCountry;
        /**description attribute*/
        public String birthName;
        /**description attribute*/
        public String assetClassification;
    }
    /**@description inner class to parse*/
    public class TaxDetails {
        /**description attribute*/
        public String taxType;
        /**description attribute*/
        public String taxNumber;
        /**description attribute*/
        public String provisionalTaxPayerInd;
    }
    /**@description inner class to parse*/
    public class OrgDetails {
        /**description attribute*/
        public String ownership;
        /**description attribute*/
        public String orgEstablishDt;
        /**description attribute*/
        public Integer numEmployees;
        /**description attribute*/
        public String legalName;
        /**description attribute*/
        public String legalForm;
        /**description attribute*/
        public String fiscalYearEnd;
        /**description attribute*/
        public String companyName;
    }
    /**@description inner class to parse*/
    public class Contacts {
        /**description attribute*/
        public String value;
        /**description attribute*/
        public Object startDate;
        /**description attribute*/
        public String preferredInd;
        /**description attribute*/
        public Object preferredFormat;
        /**description attribute*/
        public String phoneType;
        /**description attribute*/
        public Object obsoleteInd;
        /**description attribute*/
        public String localCode;
        /**description attribute*/
        public Object extension;
        /**description attribute*/
        public Object endDate;
        /**description attribute*/
        public String countryCode;
        /**description attribute*/
        public String contactType;
        /**description attribute*/
        public Object contactPeriod;
        /**description attribute*/
        public String cityCode;
    }
    /**@description inner class to parse*/
    public class AddressTypes {
        /**description attribute*/
        public String addressType;
        /**@description inner class to parse
*@param addressType
*/
        public AddressTypes(String addressType) {
            this.addressType = addressType;
        }
    }
    /**@description inner class to parse*/
    public class MktgConsents {
        /**description attribute*/
        public Boolean consentStatus;
        /**description attribute*/
        public String consentCode;
    }
    /**@description inner class to parse*/
    public class TaxClassification {
        /**description attribute*/
        public String taxType;
        /**description attribute*/
        public String taxRegion;
        /**description attribute*/
        public String taxGroup;
        /**description attribute*/
        public String taxExemptReason;
        /**description attribute*/
        public String taxCountry;
    }
    /**@description inner class to parse*/
    public class Permits {
        /**description attribute*/
        public String permitType;
        /**description attribute*/
        public String permitNumber;
        /**description attribute*/
        public String expDt;
        /**description attribute*/
        public String effDt;
    }
    /**@description inner class to parse*/
    public class CustomerRoles {
        public String startDate;
        /**description attribute*/
        public String role;
        /**description attribute*/
        public String endDate;
    }
    /**@description inner class to parse*/
    public class ComplianceRoles {
        public String verifiedBy;
        /**description attribute*/
        public String statusReason;
        /**description attribute*/
        public String compRole;
        /**description attribute*/
        public String complianceStatus;
        /**description attribute*/
        public String complianceGrade;
    }
    
}