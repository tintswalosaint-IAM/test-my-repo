/***************************************************************************************
@Name of the Class :KYC_DTO_ClientDetails
@Description : SFP-38773 This is wrapper class for converting input into Salesforce Object
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public class KYC_DTO_ClientDetails {
    
    @Auraenabled
    @InvocableVariable(label = 'Country of Citizenship')
    public String countryOfCitizenship;
    
    @Auraenabled
    @InvocableVariable(label = 'Country of Residence')
    public String countryOfResidence;
    
    @Auraenabled
    @InvocableVariable(label = 'Passport Issuing Country')
    public String passportIssuingCountry;
    
    @Auraenabled
    @InvocableVariable(label = 'Employment Type')
    public String employmentType;
    
    @Auraenabled
    @InvocableVariable(label = 'FIC PIP')
    public Boolean ficPip;
    
    @Auraenabled
    @InvocableVariable(label = 'FIC PIP REL')
    public Boolean ficPipRel;
    
    @Auraenabled
    @InvocableVariable(label = 'FIC PIP REL FIRST NAME')
    public String ficPipRelFirstName;
    
    @Auraenabled
    @InvocableVariable(label = 'FIC PIP REL LAST NAME')
    public String ficPipRelLastName;

    @Auraenabled
    @InvocableVariable(label = 'Title')
    public String title;
    
    @Auraenabled
    @InvocableVariable(label = 'First Name')
    public String firstName;
    
    @Auraenabled
    @InvocableVariable(label = 'Middle Name')
    public String middleName;
    
    @Auraenabled
    @InvocableVariable(label = 'Last Name')
    public String lastName;
    
    @Auraenabled
    @InvocableVariable(label = 'Gender')
    public String gender;
    
    @Auraenabled
    @InvocableVariable(label = 'Channel')
    public String channel;
    
    @Auraenabled
    @InvocableVariable(label = 'ID Document Issuing Country')
    public String idDocIssuingCountry;
    
    @Auraenabled
    @InvocableVariable(label = 'ID Number')
    public String idNumber;
    
    @Auraenabled
    @InvocableVariable(label = 'Primary ID Type')
    public String primaryIdType;
    
    @Auraenabled
    @InvocableVariable(label = 'Primary Phone')
    public String primaryPhone;
    
    @Auraenabled
    @InvocableVariable(label = 'Primary Email')
    public String primaryEmail;
    
    @Auraenabled
    @InvocableVariable(label = 'Related ID')
    public String relatedId;
    
    @Auraenabled
    @InvocableVariable(label = 'Nationality')
    public String nationality;
    
    @Auraenabled
    @InvocableVariable(label = 'Date of Birth')
    public String dob;
    
    @Auraenabled
    @InvocableVariable(label = 'Is Employed')
    public Boolean isEmployed;
    
    @Auraenabled
    @InvocableVariable(label = 'Occupation Level')
    public String occupationLevel;
    
    @Auraenabled
    @InvocableVariable(label = 'Card Number')
    public String cardNumber;
    
    @Auraenabled
    @InvocableVariable(label = 'KYC Profile ID')
    public String kycProfileId;
    
    @Auraenabled
    @InvocableVariable(label = 'Addresses')
    public List<KYC_DTO_Address> addresses;

    @Auraenabled
    @InvocableVariable(label = 'Doc Add')
    public String docAdd;

    /**
    * @description This is constrctor
    * @author Nagendra Mylavarapu | 23-04-2024 
    **/
    public KYC_DTO_ClientDetails(){
        addresses = new List<KYC_DTO_Address>();
    }
}