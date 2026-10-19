/***********************************************************
* @description SFP-34727 data framing for customer api
* @author Ikyatha Naidu
* @date 10/10/2024
******************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 10/10/2024
* Last Modified Description: Initial Version
*/
public class ICS_DTO_CustomerAPI {

    public String SFAccountID;
    public String CustomerBPID;
    public String AccountType;
    public String FirstName;
    public string bothtosign;
    public String SurName;
    public String DateofBirth;
    Public String Nationality;
    Public String idNumber;
    Public String expiryDate;
    Public String validTo;
    Public String validfrom;
    public DTO_Address PrimaryAddress;
    public DTO_Address AdditionalAddress1;
    public DTO_Address AdditionalAddress2;
    public String SigngingMandate;
    public String EmailAddresss;
    public List<RelatedParties> RelatedParties;


    public class RelatedParties {
        public String SFAccountID;
        public String AccountType;
        public String FirstName;
        public String Surname;
        public String DateofBirth;
        Public String Nationality;
        public String SFPartyProfileID;
        public String BPID;
        public DTO_Address PrimaryAddress;
        public DTO_Address AdditionalAddress1;
        public DTO_Address AdditionalAddress2;
        public String AutorisedSignatory;
        public String SigngingMandate;
        public String EmailAddresss;
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
     public ICS_DTO_CustomerAPI(){
          String productInfo = 'Optimum';
        if (productInfo != null) {
            productInfo = 'Optimum';
        }
    }


}