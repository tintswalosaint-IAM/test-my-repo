/**
 * @description - Class used as Wrapper Class to construct maintaincustomer API request
 * 
 * <p>DBP-1108</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 13th 2020
 * SFP-19556 - Pradeep Kota - Add method setMarketingConsents 
 * SFP-19185 - Tatenda Muzondiona - 21-07-2023 - PMD Violations ApexDoc comments desciption and params
 * SFP-19556 - Gill Lumley - correct the action for main source of funds if it is new (used to default to 'UPDATE')
 */
public with sharing class AOB_DTO_MaintainCustomer {
    public static final String UPDATE_ACTION = 'UPDATE';
    public static final String CREATE_ACTION = 'CREATE';
    public static final String DELETE_ACTION = 'DELETE';
    public static final String ADDRESS_TYPE = '05';
    public static final String END_DATE = '9999-12-31';
    public static final String SOURCEOFFUND = '0017';
    public String customerType = '';
    public String residenceCountry = '';  
    
    /**
     * @description - This method is used to set information related to the current users personal details
     * @param fields map containing the fields that the user entered in the front end
     */
    private void setPersonalDetails(Map<String, Object> fields) {
        //Personal Information Attributes
        String idType = (String) fields.get(AOB_Constants.IDTYPE);
        String idNumber = (string) fields.get(AOB_Constants.IDNUMBER);
        //Contact Attributes
        String cellPhone = (String) fields.get(AOB_Constants.CELLPHONE);
        String email = (String) fields.get(AOB_Constants.EMAIL);
        //Address Attributes
        String streetNumber = (String) fields.get(AOB_Constants.STREETNUMBER);
        String unitNumber = (String) fields.get(AOB_Constants.UNITNUMBER);
        String buildingName = (String) fields.get(AOB_Constants.BUILDINGNAME);
        String suburb = (String) fields.get(AOB_Constants.SUBURB);
        String city = (String) fields.get(AOB_Constants.CITY);
        String province = (String) fields.get(AOB_Constants.PROVINCE);
        String postalCode = (String) fields.get(AOB_Constants.POSTALCODE);
        AOB_DTO_MaintainCustomer.PersonDetails pd = new AOB_DTO_MaintainCustomer.PersonDetails();
        pd.nationality=(String) fields.get(AOB_Constants.NATIONALITY);
        pd.citizenshipCountry=(String) fields.get(AOB_Constants.CITIZENSHIP);
        //Added two more fields in personal details screen ---- SFP-19987
        this.residenceCountry = (String) fields.get(AOB_Constants.RESIDENCE); // Residence country outside personal details structure
        pd.countryOfBirth = (String) fields.get(AOB_Constants.COUNTRYOFBIRTH);
        this.personDetails = pd;
        AOB_DTO_MaintainCustomer.Addresses addresses = new AOB_DTO_MaintainCustomer.Addresses();
        AOB_DTO_MaintainCustomer.Address address = new AOB_DTO_MaintainCustomer.Address();
        address.line1 = String.isBlank(unitNumber) ? '' : unitNumber;
        address.line2 = String.isBlank(buildingName) ? '' : buildingName;
        address.line3 = String.isBlank(streetNumber) ? '' : streetNumber;
        address.district = String.isBlank(suburb) ? '' : suburb;
        address.City = String.isBlank(City) ? '' : City;
        address.postalCode = String.isBlank(postalCode) ? '' : postalCode;
        address.province = String.isBlank(Province) ? '' : Province;
        AddressType typeX = new AddressType();
        typeX.startDate = String.valueOf(date.today());
        typeX.endDate = END_DATE;
        address.typeZ = new List<AddressType>{ typeX };
        addresses.address = address;
        addresses.actionCode = CREATE_ACTION;
        this.addresses = new List<AOB_DTO_MaintainCustomer.Addresses>{ addresses };    
            
    }

    /**
     * @description This method is used to set information related to the current users public official relations details
     * @param fields map containing the fields that the user entered in the front end
     */
    private void setPublicOff(Map<String, Object> fields) {
        String publicOff = (String) fields.get(AOB_Constants.PUBLICOFF);
        String publicOffRelated = (String) fields.get(AOB_Constants.PUBLICOFFREL);
        String applicationId = (String) fields.get(AOB_Constants.APPLICATIONID);
        String natureOfRelation = publicOffRelated == 'true' ? (String) fields.get(AOB_Constants.NATUREOFRELATION) : ' ';
        String nameOfRelation = publicOffRelated == 'true' ? (String) fields.get(AOB_Constants.NAMEOFRELATION) : ' ';
        AOB_DTO_MaintainCustomer.ProminentInfluential prominentInfluential = new AOB_DTO_MaintainCustomer.ProminentInfluential();
        prominentInfluential.pipInd = String.isBlank(publicOff) ? 'true' : publicOff;
        prominentInfluential.relatedInd = String.isBlank(publicOffRelated) ? 'false' : publicOffRelated;
        prominentInfluential.relationType = String.isBlank(natureOfRelation) ? '' : natureOfRelation;
        prominentInfluential.name = String.isBlank(nameOfRelation) ? '' : nameOfRelation;
        this.customerType = AOB_Constants.INDIVIDUAL;
        AOB_DTO_MaintainCustomer.ProminentInfluentialPerson prominentInfluentialPerson = new AOB_DTO_MaintainCustomer.ProminentInfluentialPerson();
        prominentInfluentialPerson.prominentInfluential = prominentInfluential;
        prominentInfluentialPerson.actionCode = UPDATE_ACTION;
        this.prominentInfluentialPerson = prominentInfluentialPerson;
    }

    /**
     * @description This method is used to set information related to the current users tax details
     * @param taxes List of entered taxes
     * @param oldtaxList List of previously entered taxes (from SAP)
     * @param fields List of filled fields
     */
    private void setTaxDetails(List<AOB_DTO_SelectOption> taxes, List<AOB_DTO_SelectOption> oldtaxList,Map<String, Object> fields) {
        Map<string, string> oldTaxes = new Map<string, string>();
        for (AOB_DTO_SelectOption tax : oldtaxList) {
            oldTaxes.put(tax.label, tax.value);
        }
        String taxNumber = (String) fields.get(AOB_Constants.TAXNUMBER);
        AOB_DTO_MaintainCustomer.TaxDetails taxeDetails = new AOB_DTO_MaintainCustomer.TaxDetails();
        if (!taxes.isEmpty()) {
            AOB_DTO_MaintainCustomer.TaxDetail taxDetWRP;
            for (AOB_DTO_SelectOption tax : taxes) {
                if (!oldTaxes.containsKey(tax.label)) {
                    taxeDetails = new AOB_DTO_MaintainCustomer.TaxDetails();
                    taxDetWRP = new AOB_DTO_MaintainCustomer.TaxDetail();
                    taxDetWRP.taxType = tax.label;
                    taxDetWRP.taxNumber = tax.value;
                    taxeDetails.taxDetail = taxDetWRP;
                    taxeDetails.actionCode = CREATE_ACTION;
                    if (this.taxDetails.isEmpty()) {
                        this.taxDetails = new List<AOB_DTO_MaintainCustomer.TaxDetails>{ taxeDetails };
                    } else {
                        this.taxDetails.add(taxeDetails);
                    }
                }
                else if(oldTaxes.containsKey(tax.label) && oldTaxes.get(tax.label) != tax.value) {
                    taxeDetails = new AOB_DTO_MaintainCustomer.TaxDetails();
                    taxDetWRP = new AOB_DTO_MaintainCustomer.TaxDetail();
                    taxDetWRP.taxType = tax.label;
                    taxDetWRP.taxNumber = tax.value;
                    taxeDetails.taxDetail = taxDetWRP;
                    taxeDetails.actionCode = UPDATE_ACTION;
                    if (this.taxDetails.isEmpty()) {
                        this.taxDetails = new List<AOB_DTO_MaintainCustomer.TaxDetails>{ taxeDetails };
                    } else {
                        this.taxDetails.add(taxeDetails);
                    } 
                }
            }
        }
    }

    /**
     * @description This method is used to set information related to the current users sources of Funds details SFP-19185
     * @param sourcesOfFunds List of entered sources of funds
     * @param fields List of filled fields
     * @param oldFundsList List of previously entered sources of funds (from SAP)
     */
    private void setFundsDetails(List<AOB_DTO_SelectOption> sourcesOfFunds, Map<String, Object> fields, List<AOB_DTO_SelectOption> oldFundsList) {
        Map<string, string> oldFunds = new Map<string, string>();
        for (AOB_DTO_SelectOption fund : oldFundsList) {
            oldFunds.put(fund.label, fund.value);
        }
        string incomeType = (String) fields.get(AOB_Constants.INCOMETYPE);
        string incomeAmount = (String) fields.get(AOB_Constants.FUNDAMOUNT);
        //Sources Of Funds
        AOB_DTO_MaintainCustomer.SourceOfFunds funds = new AOB_DTO_MaintainCustomer.SourceOfFunds();
        this.sourceOfFunds = new List<AOB_DTO_MaintainCustomer.SourceOfFunds>();
        AOB_DTO_MaintainCustomer.SourceOfFunds mainSourceOfFunds = new AOB_DTO_MaintainCustomer.SourceOfFunds();
        AOB_DTO_MaintainCustomer.SourceOfFund mainsourceofFundsWRP = new AOB_DTO_MaintainCustomer.SourceOfFund();
        mainsourceofFundsWRP.sourceFundType = SOURCEOFFUND;
        mainsourceofFundsWRP.sourceFundAmount = incomeAmount;
        mainSourceOfFunds.sourceOfFund = mainsourceofFundsWRP;
        if(oldFunds.containsKey(SOURCEOFFUND)){
            mainSourceOfFunds.actionCode = UPDATE_ACTION;
        }
        else{
            mainSourceOfFunds.actionCode = CREATE_ACTION;
        }
        
        this.sourceOfFunds = new List<AOB_DTO_MaintainCustomer.SourceOfFunds>{ mainSourceOfFunds };
        
        if (!sourcesOfFunds.isEmpty()) {
            AOB_DTO_MaintainCustomer.SourceOfFund sourceofFundsWRP;

            for (AOB_DTO_SelectOption fund : sourcesOfFunds) {
                funds = new AOB_DTO_MaintainCustomer.SourceOfFunds();
                sourceofFundsWRP = new AOB_DTO_MaintainCustomer.SourceOfFund();
                sourceofFundsWRP.sourceFundType = fund.label;
                sourceofFundsWRP.sourceFundAmount = fund.value;
                funds.sourceOfFund = sourceofFundsWRP;
                if(oldFunds.containsKey(fund.label)){
                    funds.actionCode = UPDATE_ACTION;
                }
                else{
                    funds.actionCode = CREATE_ACTION;
                }
                if (this.sourceOfFunds.isEmpty()) {
                    this.sourceOfFunds = new List<AOB_DTO_MaintainCustomer.SourceOfFunds>{ funds };
                }
                else {
                    this.sourceOfFunds.add(funds);
                }
            }
        }
    }

    /**
     * @description This method is used to set information related to the current user's Employment details
     * @param oldEmployments Json String of Employment details received from SAP
     * @param fields map containing the fields that the user entered in the front end
     */
    private void setEmploymentDetails(String oldEmployments, Map<String, Object> fields) {
        AOB_DTO_Employment oldEmployment = (AOB_DTO_Employment) JSON.deserialize(oldEmployments, AOB_DTO_Employment.class);
        //Employment Attributes
        string employmentType = (String) fields.get(AOB_Constants.EMPLOYMENTTYPE);
        string employerName = (String) fields.get(AOB_Constants.EMPLOYERNAME);
        string industry = (String) fields.get(AOB_Constants.INDUSTRY);
        string designation = (String) fields.get(AOB_Constants.DESIGNATION);
        string incomeType = (String) fields.get(AOB_Constants.INCOMETYPE);
        //string incomeAmount = (String) fields.get(AOB_Constants.FUNDAMOUNT); //Tatenda 09-11-2023 - PMD Violation - unused variable
        string startDate = (String) fields.get(AOB_Constants.STARTDATE);
        string endDate = (String) fields.get(AOB_Constants.ENDDATE);        
        //Added two more fields in employment screen ---- SFP-19987
        string employed = (String) fields.get(AOB_Constants.AREEMPLOYED);
        string permEmployed = (String) fields.get(AOB_Constants.PERMEMPLOYED);

        AOB_DTO_MaintainCustomer.EmploymentDetails employmentDetails = new AOB_DTO_MaintainCustomer.EmploymentDetails();
        //For Employment: Create an object to terminate the previous employment and send the new info
        //New Employment
        AOB_DTO_MaintainCustomer.Employment employment = new AOB_DTO_MaintainCustomer.Employment();
        employment.employmentType = String.isBlank(employmentType) ? '' : employmentType;
        employment.orgName = String.isBlank(employerName) ? '' : employerName;
        if (String.isNotBlank(industry)){
            employment.industrialSector = industry;
        }
        if (String.isNotBlank(designation)){
            employment.occupation = designation;
        }
        employment.startDate = String.isBlank(startDate) ? '' : startDate;
        employment.endDate = String.isBlank(endDate) ? END_DATE : endDate;
        //Added two more fields in employment screen ---- SFP-19987
        employment.employed = String.isBlank(employed) ? '' : employed;
        employment.permEmployed = String.isBlank(permEmployed) ? '' : permEmployed;
        employmentDetails.employment = employment;
        employmentDetails.actionCode = CREATE_ACTION;
        //Previous Employment
        //If the previous Employment is filled, delete it (only check employment type and start date in case previous was unemployed)
        if (
            String.isNotBlank(oldEmployment.employmentType) &&
            String.isNotBlank(oldEmployment.startDate)
        ) {
            AOB_DTO_MaintainCustomer.EmploymentDetails prevEmploymentDetails = new AOB_DTO_MaintainCustomer.EmploymentDetails();
            AOB_DTO_MaintainCustomer.Employment prevEmployment = new AOB_DTO_MaintainCustomer.Employment();
            prevEmployment.employmentType = oldEmployment.employmentType;
            prevEmployment.orgName = oldEmployment.orgName;
            if (String.isNotBlank(oldEmployment.industrialSector)){
                prevEmployment.industrialSector = oldEmployment.industrialSector;
            }
            if (String.isNotBlank(oldEmployment.occupation)){
                prevEmployment.occupation = oldEmployment.occupation;
            }
            prevEmployment.startDate = oldEmployment.startDate;
            prevEmployment.endDate = String.isBlank(startDate) ? '' : startDate;
            prevEmploymentDetails.employment = prevEmployment;
            prevEmploymentDetails.actionCode = DELETE_ACTION;
            this.employmentDetails = new List<AOB_DTO_MaintainCustomer.EmploymentDetails>{ employmentDetails, prevEmploymentDetails };
        } else {
            this.employmentDetails = new List<AOB_DTO_MaintainCustomer.EmploymentDetails>{ employmentDetails };
        }
    }

    // comment on User story SFP-19556 marketing consents
    private void setMarketingConsents(String market) {
        this.marketingConsents = new List<AOB_DTO_MaintainCustomer.Marketing>();
        this.marketingConsents =(List<AOB_DTO_MaintainCustomer.Marketing>)System.JSON.deserialize(market, List<AOB_DTO_MaintainCustomer.Marketing>.class);
    }

    /**
     * @description Constructor of the DTO - SFP-19185
     * @param customerInfo Customer Info, Json String of the entered data in Front End
     * @param oldTaxes List of previous entered taxes ( from SAP)
     * @param oldFunds List of previous entered sources of funds ( from SAP)
     * @param taxes  List of entered taxes
     * @param sourcesOfFunds List of entered sources of funds
     * @param oldEmployments Json String of previous entered Employment ( from SAP)
     * @param marketingConsents list of consents sent to SAP - SFP-19185
     */
    public AOB_DTO_MaintainCustomer(
        String customerInfo,
        List<AOB_DTO_SelectOption> oldTaxes,
        List<AOB_DTO_SelectOption> oldFunds,
        List<AOB_DTO_SelectOption> taxes,
        List<AOB_DTO_SelectOption> sourcesOfFunds,
        String oldEmployments,
        String marketingConsents
    ) {
        Map<String, Object> fields = (Map<String, object>) JSON.deserializeUntyped(customerInfo);
        //AOB_DTO_Employment oldEmployment = (AOB_DTO_Employment) JSON.deserialize(oldEmployments, AOB_DTO_Employment.class); //Tatenda 09-11-2023 - PMD Violation - unused variable
        this.setPersonalDetails(fields);
        this.setTaxDetails(taxes, oldTaxes,fields);
        this.setPublicOff(fields);
        this.setFundsDetails(sourcesOfFunds, fields, oldFunds);
        this.setEmploymentDetails(oldEmployments, fields);
        this.setMarketingConsents(marketingConsents); // SFP-19556
    }

    /**
     * @description wrapper for marketing consents
     *
     */
    public class MarketingConsents {
        public list<Marketing> markets;
    }

    /**
    * @description wrapper for marketing Consents
    *
    */
    public class Marketing {
        public String consentCode;
        public String consentCodeX;
        public String consentStatus;
    }

    /**
     * @description wrapper for Employment Details
     * 
     */
    public class EmploymentDetails {
        public String actionCode = '';
        public Employment employment;
    }

    /**
     * @description wrapper for Employment
     * 
     */
    public class Employment {
        public String orgName = '';
        public String startDate = '';
        public String endDate = '';
        public String industrialSector;
        public String occupation;
        public String employmentType = '';
        //Added two more fields in employment screen ---- SFP-19987
        public String employed='';
        public String permEmployed='';
    }

    /**
     * @description wrapper for AddressType
     * 
     */
    public class AddressType {
        public string addressType = '';
        public string startDate = '';
        public string endDate = '';

        /**
        * @description constructor for AddressType
        * 
        */
        public AddressType() {
            this.addressType = ADDRESS_TYPE;
            this.startDate = String.valueOf(date.today());
            this.endDate = END_DATE;
        }
    }

    /**
     * @description wrapper for Address
     * 
     */
    public class Address {
        public List<addressType> typeZ = new List<addressType>{ new AddressType() }; // in json: type
        public String line1 = '';
        public String line2 = '';
        public String line3 = '';
        public String line4 = '';
        public String district = '';
        public String city = '';
        public String province = '';
        public String postalCode = '';
        public String countryCode = '';
        public String plotNumber = '';
        public String pobox = '';
        public String startDate = '';
        public String endDate = '';
    }

    /**
     * @description wrapper for Addresses
     * 
     */
    public class Addresses {
        public string actionCode = '';
        public Address address;
    }

    /**
     * @description wrapper for PersonDetails
     * 
     */
    public class PersonDetails {
        public String nationality='';
        public String citizenshipCountry='';
        //Added country of birth in personal details screen ---- SFP-19987
        public String countryOfBirth='';
    }

    /**
     * @description wrapper for ProminentInfluentialPerson
     * 
     */
    public class ProminentInfluentialPerson {
        public String actionCode;
        public ProminentInfluential prominentInfluential;
    }

    /**
     * @description wrapper for ProminentInfluential
     * 
     */
    public class ProminentInfluential {
        public String pipInd;
        public String relatedInd;
        public String name;
        public String relationType;
    }

    /**
     * @description wrapper for TaxDetails
     * 
     */
    public class TaxDetails {
        public String actionCode;
        public TaxDetail taxDetail;
    }

    /**
     * @description wrapper for TaxDetail
     * 
     */
    public class TaxDetail {
        /** @description attribute **/  
        @auraEnabled
        public String taxType { get; set; }
        /** @description attribute **/  
        @auraEnabled
        public String taxNumber { get; set; }
    }

    /**
     * @description wrapper for SourceOfFunds
     * 
     */
    public class SourceOfFunds {
        public String actionCode;
        public SourceOfFund sourceOfFund;
    }

    /**
     * @description wrapper for SourceOfFund
     * 
     */
    public class SourceOfFund {
        public String sourceFundType;
        public String sourceFundAmount;
        public String currencyZ = 'ZAR';
    }
  
    /** @description attribute **/  //SFP-19185
    public PersonDetails personDetails { get; set; }
    /** @description attribute **/  
    public ProminentInfluentialPerson prominentInfluentialPerson { get; set; }
    /** @description attribute **/  
    public List<EmploymentDetails> employmentDetails { get; set; }
    /** @description attribute **/  
    public List<SourceOfFunds> sourceOfFunds { get; set; }
    /** @description attribute **/  
    public List<TaxDetails> taxDetails { get; set; }
    /** @description attribute **/  
    public List<Addresses> addresses { get; set; }
    /** @description attribute **/  
    public List<Marketing> marketingConsents { get; set; }
}