/*************************************************************
 * @description SFP-32986 Wrapper Class used to frame data for create relation
 *
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima
 * Last Modified Date 21/10/2024
 * Last Modified Description: Initial Version
 */
public class ICS_DTO_SAP_CreateRelationRequest {
    public List<Party> Party;

    public class Party {
        public PartyReference PartyReference;
        public Associations Associations;
        public AdditionalData AdditionalData;
    }

    public class PartyReference {
        public List<PartyIdentification> PartyIdentification;
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

    public class Associations {
        public List<PartyRelationship> PartyRelationship;
    }

    public class PartyRelationship {
        public String PartyPartyRelationshipType;
        public String PartyPartyRelationshipValues;
        public String PartyRelationshipStartDate;
        public String PartyRelationshipEndDate;
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
        public ICS_DTO_SAP_CreateRelationRequest(){
        String productInfo = 'Optimum';
        if (productInfo != null) {
            productInfo = 'Optimum';
        }
    }
}