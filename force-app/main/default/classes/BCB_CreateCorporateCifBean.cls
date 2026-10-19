/***************************************************************************************
@Name of the Class : BCB_CreateCorporateCifBean
@description       : Class for dealing with CreateCorporateCif api and sending the result to the main container and storing the values in the wrapper.
@Author            : Lokesh Bothsa(lokesh.bothsa@standardbank.co.za) 
@Date              : June 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 03-04-2024
@Modification Description : SFP-37302
***************************************************************************************/
public class BCB_CreateCorporateCifBean {
    /**description attribute*/
    public String EASIndicator;
    /**description attribute*/
    public String taxIdentificationNumber;
    /**description attribute*/
    public String businessRegistrationNumber;
    /**description attribute*/
    public String portFolioNum;
    /**description attribute*/
    public String customerType;
    /**description attribute*/
    public String residenceCountry;
    /**description attribute*/
    public String relManagerLink;
    /**description attribute*/
    public String prefLanguage;
    /**description attribute*/
    public String responsibleBranch;
    /**description attribute*/
    public String authorizationGroup;
    /**description attribute*/
    public String mktgSegment;
    /**description attribute*/
    public String accessOwnerSegment;
    /**description attribute*/
    public String segmentCategory;
    /**description attribute*/
    public String minorIndicator;
    /**description attribute*/
    public String seniorIndicator;
    /**description attribute*/
    public String depositAccountIndicator;
    /**description orgDetails*/
    public OrgDetails orgDetails;
    /**description prominentInfluentialPerson*/
    public ProminentInfluentialPerson prominentInfluentialPerson;
    /**description routingInformation*/
    public List<RoutingInformation> routingInformation;
    /**description contacts*/
    public List<Contacts> contacts;
    /**description identification*/
    public List<Identification> identification;
    /**description sourceOfFunds*/
    public List<SourceOfFunds> sourceOfFunds;
    /**description addresses*/
    public List<Addresses> addresses;
    /**description mktgConsents*/
    public List<MktgConsents> mktgConsents;
    /**description industrialSectors*/
    public List<IndustrialSectors> industrialSectors;
     /**description industrialSectors*/
     public List<finacleSectors> finacleSectors;
    /**description misc*/
    public List<Misc> misc;
    /**description relatedParties*/
    public List<RelatedParties> relatedParties;
     /**@description inner class to parse*/
    public class ProminentInfluentialPerson {
        /**description attribute*/
        public String pipInd;
        /**description attribute*/
        public String relatedInd;
        /**description attribute*/
        public String name;
        /**description attribute*/
        public String relationType;
    }
     /**@description inner class to parse*/
    public class IndustrialSectors {
        /**description attribute*/
        public String industrialClassificationSystem;
        /**description attribute*/
        public String industrialSector;
    }
     /**@description inner class to parse*/
    public class finacleSectors{
		/** @description classificationCode */
        public String classificationCode;
		/** @description primaryClassificationCode */
        public String primaryClassificationCode;
		/** @description secondaryClassificationCode */
        public String secondaryClassificationCode;
        /**description tertiaryClassificationCode*/
        public string tertiaryClassificationCode;
    }
     /**@description inner class to parse*/
    public class Misc {
        /**description attribute*/
        public String key;
        /**description attribute*/
        public String value;
        /**description attribute*/
        public String miscDate;
        /**description attribute*/
        public String counterPartyInfo;
        /**description attribute*/
        public String distributionChannel;
    }
     /**@description inner class to parse*/
    public class SourceOfFunds {
        /**description attribute*/
        public String sourceFundType;
        /**description attribute*/
        public String sourceFundAmount;
        /**description attribute*/
        public String currencyCode;
        /**description attribute*/
        public String tradeFinanceIndicator;
    }
     /**@description inner class to parse*/
    public class Identification {
        /**description attribute*/
        public String identificationType;
        /**description attribute*/
        public String identificationNumber;
        /**description attribute*/
        public String issuingCountry;
        /**description attribute*/
        public String issuedOrganisation;
        /**description attribute*/
        public String issuedDate;
        /**description attribute*/
        public String expirationDate;
        /**description attribute*/
        public String PreferredIdentificationIndicator;
        /**description attribute*/
        public String documentCode;
        /**description attribute*/
        public String documentDescription;
        /**description attribute*/
        public String documentTypeCode;
        /**description attribute*/
        public String documentTypeDescription;
    }
     /**@description inner class to parse*/
    public class RoutingInformation {
        /**description attribute*/
        public String cifCountry;
        /**description attribute*/
        public String systemIdentificationNumber;
        /**description attribute*/
        public String applicationIdentificationNumber;
    }
     /**@description inner class to parse*/
    public class Addresses {
        /**description attribute*/
        public String uuid;
        /**description addressTypes*/
        public List<AddressTypes> addressTypes;
        /**description attribute*/
        public String startDate;
        /**description attribute*/
        public String line1;
        /**description attribute*/
        public String line2;
        /**description attribute*/
        public String line3;
        /**description attribute*/
        public String city;
        /**description attribute*/
        public String province;
        /**description attribute*/
        public String postalCode;
        /**description attribute*/
        public String countryCode;
        /**description attribute*/
        public String plotNumber;
        /**description attribute*/
        public String preferredInd;
    }
     /**@description inner class to parse*/
    public class OrgDetails {
        /**description attribute*/
        public String legalName;
        /**description attribute*/
        public String companyName;
        /**description attribute*/
        public String legalForm;
        /**description attribute*/
        public String orgEstablishDt;
        /**description attribute*/
        public String numEmployees;
        /**description attribute*/
        public String fiscalYearEnd;
        /**description attribute*/
        public String ownership;
        /**description attribute*/
        public String description;
        /**description attribute*/
        public String turnover;
    }
     /**@description inner class to parse*/
    public class Contacts {
        /**description attribute*/
        public String contactType;
        /**description attribute*/
        public String value;
        /**description attribute*/
        public String countryCode;
        /**description attribute*/
        public String preferredInd;
        /**description attribute*/
        public String phoneType;
        /**description attribute*/
        public String localCode;
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
        public String consentCode;
        /**description attribute*/
        public String consentStatus;
    }
     /**@description inner class to parse*/
    public class RelatedParties {
        /**description attribute*/
        public String firstName;
        /**description attribute*/
        public String lastName;
        /**description attribute*/
        public String partyId;
        /**description attribute*/
        public String relatedTitle;
        /**description attribute*/
        public String signatoryIndicator;
    }
    
}