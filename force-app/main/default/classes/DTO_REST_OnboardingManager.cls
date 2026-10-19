public class DTO_REST_OnboardingManager {
    public String SFAccountID;
    public String BPID;
    public String AccountType;
    public String FirstName;

    public String SurName;
    public String DateofBirth;
    Public String Nationality;
    Public String idNumber;
    Public String expiryDate;
    Public String validTo;
    Public String validfrom;
    public DTO_Address PrimaryAddress;
    public DTO_Address alternateCardDeliverAddress;
    public DTO_Address additionalAddress2;
    public String SigningMandate;
    public String EmailAddress;
    public List<RelatedParties> RelatedParties;
    
    
    public class RelatedParties { 
        public String SFAccountID;
        public String FirstName;
        public String SurName;
        public String DateofBirth;
        Public String Nationality;
        public String SFPartyProfileID;
        public String BPID;
        public DTO_Address PrimaryAddress;
        public DTO_Address alternateCardDeliverAddress;
        public DTO_Address additionalAddress2;
        public String AuthorisedSignatory;
        public String SigningMandate;
        public String EmailAddress;
        Public String idNumber;
        Public String expiryDate;
        Public String validTo;
        Public String validfrom;
    }
    
    public class DTO_Address{
        public String street;
        public String city;
        public String state;
        public String postalcode;
        public String country;
    }
  
    
}