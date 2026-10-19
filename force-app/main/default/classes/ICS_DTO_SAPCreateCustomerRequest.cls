/***************************************************************************************
@Name of the Class :ICS_DTO_SAPCreateCustomerRequest
@Description : Class used to frame the data for ICS_DTO_SAPCreateCustomerRequest
@Author :Ruchi Agarwal
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Ruchi Agarwal
* Last Modified Date Oct 22 2024
* Last Modified Description: Initital Version
***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 22-05-2026
 * @Modification description : SFP-57389 added Addressee to Address send to SAP
 *****************************************************************************************
 * @Last Modified By      : Ridhima Saxena
 * @Last Modified On      : 18-06-2026
 * @Modification Description : SFP-54306 Added Nationality field to Person wrapper to
 * support sending nationality information in the SAP Create Customer request.
 *****************************************************************************************/
public class ICS_DTO_SAPCreateCustomerRequest {
     public ICS_DTO_SAPCreateCustomerRequest(){
        String productInfo = 'Optimum';
        if (productInfo != null) {
            productInfo = 'Optimum';
        }
    }
    public List<Party> Party;

    public class Party {
        public PartyReference PartyReference;
        public BankRelations BankRelations;
        public Reference Reference;
        public Person Person;
        public Associations Associations;
        public OrganisationInstance OrganisationInstance;
         public List<PartyRelationship> PartyRelationships;
        public AdditionalData AdditionalData;
    }
    public class PartyRelationship {
        public String RelationshipType; //AccountHolder
        public String RelationshipValue;    //BCA010
        public String RelationshipStartDate;    //2024-05-31
        public String RelationshipEndDate;  //9999-12-31
    }
    public class PartyReference {
        public String PartyType;
        public List<PartyName> PartyName;
        public List<PartyIdentification> PartyIdentification;
        public String PartyPreferredIdentifierFlag;
        public List<PartyIdentifierDateTime> PartyIdentifierDateTime;
    }

    public class PartyName {
        public String PartyNameValue;
        public String PartyNameType;
    }

    public class PartyIdentification {
        public String PartyIdentificationType;
        public IdentificationDetail PartyIdentification;
    }

    public class IdentificationDetail {
        public IdentifierValue IdentifierValue;
    }

    public class IdentifierValue {
        public String Value;
    }

    public class PartyIdentifierDateTime {
        public String IdentifierDateType;
        public String IdentifierDateTime;
    }

    public class BankRelations {
        public List<BankRelationReference> BankRelationReference;
    }

    public class BankRelationReference {
        public RelationshipType RelationshipType;
    }

    public class RelationshipType {
        public String Text;
        public String Value;
    }

    public class Reference {
        public List<PartyTax> PartyTax;
        public String PartyNameSalution;
        public List<PartyContactPoint> PartyContactPoint;
    }

    public class PartyTax {
        public String PartyTaxCountry;
        public String PartyTaxType;
        public String PartyTaxNumber;
    }

    public class PartyContactPoint {
        public ContactPoint ContactPoint;
    }

    public class ContactPoint {
        public String ContactPointType;
        public String PrefferedCommunicationMethod;
        public ElectronicAddress ElectronicAddress;
        public TelephonicAddress TelephonicAddress;
        public Language Language;
        public Address Address;
  
    }
    
    public class Language {
      public string LanguageCode;
   }

    public class ElectronicAddress {
        public String EmailAddress;
    }

    public class TelephonicAddress {
        public String PhoneType;
        public String PhoneValue;
    }

    public class Address {
        public String AddressType;
        public String Addressee;
        public List<PartyName> StreetName;
        public PostCode PostCode;
        public CountrySubDivision CountrySubDivision;
    }

    public class PostCode {
        public IdentifierValue IdentifierValue;
    }

    public class CountrySubDivision {
        public List<CountrySubDivisionDetail> CountrySubDivision;
    }

    public class CountrySubDivisionDetail {
        public String CountrySubDivisionValue;
        public String CountrySubDivisionType;
    }

    public class Person {
        public String BirthDate;
        public String Gender;
        public String Title;
        public String PlaceOfBirth;
        public String Citizenship;
        public String Nationality;
        public String Language;
        public PersonEmploymentProfile PersonEmploymentProfile;
    }
	
    public class PersonEmploymentProfile {
        public List<EmploymentDate> EmploymentDate;
        public String EmployerName;
        public List<Employment> Employment;
        public Marriage Marriage;
    }

    public class EmploymentDate {
        public String EmploymentDateType;
        public String EmploymentDateTime;
    }

    public class Employment {
        public String Type;
        public String Value;
    }

    public class Marriage {
        public String MaritalStatus;
    }

    public class Associations {
        public PartyGroupRelationship PartyGroupRelationship;
    }

    public class PartyGroupRelationship {
        public PartyGroupRelationshipDate PartyGroupRelationshipDate;
    }

    public class PartyGroupRelationshipDate {
        public String StartDate;
        public String EndDate;
    }

    public class OrganisationInstance {
        public Organisation Organisation;
    }

    public class Organisation {
        public List<IndustrySectorClassification> IndustrySectorClassification;
        public Status Status;
    }

    public class IndustrySectorClassification {
        public String SectorClassificationSystem;
        public String SectorClassificationType;
    }

    public class Status {
        public StatusReason StatusReason;
    }

    public class StatusReason {
        public String Text;
    }

    public class AdditionalData {
        public CategoryInformation CategoryInformation;
    }

    public class CategoryInformation {
        public List<Category> Category;
    }

    public class Category {
        public String CategoryItem;
        public List<CategoryDetail> CategoryDetails;
    }

    public class CategoryDetail {
        public String CategoryType;
        public String CategoryIdentifierValue;
    }

 }