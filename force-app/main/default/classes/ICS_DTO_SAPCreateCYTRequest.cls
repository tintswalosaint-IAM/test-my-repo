/**
 * @description SFP-32986 Class used  to frame data for create CYT
 * @author Rukesh
 * @date 21/10/2024
 *****************************************************
 * @last modified on  : 21/10/2024
 * @last modified by  : Rukesh
 * @last modified description: updated to align with the latest version of ICS_DTO_SAPCreateCYTRequest
   ***************************************************************
 * Last Modified By  Ridhima Saxena
 * Last Modified Date 07/10/2025
 * Last Modified Description: SFP-52878 updated missing CYT fields in JSON
  ***************************************************************
 * Last Modified By  Ridhima Saxena
 * Last Modified Date 31/10/2025
 * Last Modified Description: SFP-52878 updated JSON with missing CYT fields
 */

public with sharing class ICS_DTO_SAPCreateCYTRequest {

    public List<Party> Party;

    public class Party {
        public PartyReference PartyReference;
        public Reference Reference;
        public AdditionalData AdditionalData;
        public Person Person;
        
         // Newly added fields
        public String instructingBank;        // Instructing the bank
        public String cytId;                 // CYT ID
        public Date ValidTo;                 // Valid To Date (GBIDA)
        public Boolean doNotCalculateTax;    // NOCYT
        public String taxStatementType;      // SDART
        public String taxIdIndicator;        // TIN
        public String cytIndicator;          // DB_IND
    }
    
    public class Person {
        public String PlaceOfBirth;
        public String Citizenship;
    }

    public class PartyReference {
        public List<PartyIdentification> PartyIdentification;
        public PartyIdentifierDateTime PartyIdentifierDateTime;
    }

    public class PartyIdentification {
        public String PartyIdentificationType;
        public PartyIdentificationDetail PartyIdentification;
    }

    public class PartyIdentificationDetail {
        public IdentifierValue IdentifierValue;
    }

    public class IdentifierValue {
        public String Value;
    }

    public class PartyIdentifierDateTime {
        public String IdentifierDateType;
        public String IdentifierDateTime;
    }

    public class Reference {
        public List<PartyTax> PartyTax;
        public PartyContactPoint PartyContactPoint;
        public PartyCountryClassification PartyCountryClassification;
        public PartyChoices PartyChoices; 
    }
    
    public class PartyTax {
        public String PartyTaxCountry;
        public String PartyTaxType;
        public String PartyTaxNumber;
        public String PartyTaxJurisdiction;
        public PartyTaxDateTime PartyTaxDateTime;
        public String PartyTaxExemptFlag;
        public PartyTaxStatement PartyTaxStatement;
    }
     public class PartyCountryClassification {
        public String EUResidentFlag;
    }
     public class PartyTaxStatement {
        public String TaxStatementType;
        public String TaxStatementValue;
    }
    public class PartyContactPoint {
        public ContactPoint ContactPoint;
    }
    public class PartyChoices {
        public List<PartyConsent> PartyConsent;
    }
    public class PartyTaxDateTime {
        public String TaxDateType;
        public String TaxDateTime;
    }

    public class PartyConsent {
        public String ConsentType;
        public String ConsentConfirmationFlag;
    }


    public class ContactPoint {
        public String ContactPointType;
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

    public ICS_DTO_SAPCreateCYTRequest() {
        String productInfo = 'Optimum';
        if (productInfo != null) {
            productInfo = 'Optimum';
        }
    }
}