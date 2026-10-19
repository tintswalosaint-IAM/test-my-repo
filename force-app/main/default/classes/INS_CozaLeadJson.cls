/**
 * @description Class is responsible for creating the JSON data to send to SAP.
 * @author Raja Arsalan (raja.arsalan@standardbank.co.za)
 * @date Sept 2023
 */
public class INS_CozaLeadJson {

    public ClsLeadGeneration LeadGeneration;

    /**
 * @description Inner class for ClsLeadGeneration **/
    public class ClsLeadGeneration {
        public ClsReference Reference;
        public ClsLeadandOpportunityProcedure LeadandOpportunityProcedure;
        public ClsProductDirectoryEntry ProductDirectoryEntry;
    }

    /**
 * @description Inner class for ClsReference **/
    public class ClsReference {
        public String Salutation;
        public List<ClsPartyName> PartyName;
        public ClsPartyContactPoint PartyContactPoint;
    }

    /**
 * @description Inner class for ClsPartyName **/
    public class ClsPartyName {
        public String PartyNameType;
        public String PartyNameValue;
    }

    /**
 * @description Inner class for ClsPartyContactPoint **/
    public class ClsPartyContactPoint {
        public List<ClsTelephonicAddress> TelephonicAddress;
        public ClsElectronicAddress ElectronicAddress;
    }

    /**
 * @description Inner class for ClsTelephonicAddress **/
    public class ClsTelephonicAddress {
        public String PhoneType;
        public String PhoneNumber;
    }

    /**
 * @description Inner class for ClsElectronicAddress **/
    public class ClsElectronicAddress {
        public String EmailAddress;
    }

    /**
 * @description Inner class for ClsLeadandOpportunityProcedure **/
    public class ClsLeadandOpportunityProcedure {
        public ClsLeadIdentification LeadIdentification;
        public ClsCustomerReference CustomerReference;
        public List<ClsCustomerCampaignReference> CustomerCampaignReference;
        public List<ClsLeadOrigin> LeadOrigin;
    }

    /**
 * @description Inner class for ClsLeadIdentification **/
    public class ClsLeadIdentification {
        public String LeadIdentifcationType;
        public String LeadIdentifierValue;
    }

    /**
 * @description Inner class for ClsCustomerReference **/
    public class ClsCustomerReference {
        public String PartyIdentificationType;
        public String PartyIdentificationValue;
        public String CountryofIssue;
    }

    /**
 * @description Inner class for ClsCustomerCampaignReference **/
    public class ClsCustomerCampaignReference {
        public String CampaignIdentifierValue;
        public String CampaignName;
    }
    /**
 * @description Inner class for ClsLeadOrigin **/
    public class ClsLeadOrigin {
        public String LeadOriginType;
        public String LeadOriginChannel;
    }
    /**
 * @description Inner class for ClsProductDirectoryEntry **/
    public class ClsProductDirectoryEntry {
        public ClsProductIdentification ProductIdentification;
        public ClsProductClassification[] ProductClassification;
        public ClsProductSeller ProductSeller;
    }
    /**
 * @description Inner class for ClsProductIdentification **/
    public class ClsProductIdentification {
        public String ProductIdentifierValue;
        public String ProductType;
    }

    /**
 * @description Inner class for ClsProductClassification **/
    public class ClsProductClassification {
        public String ProductCategoryType;
        public String ProductCategory;
    }

    /**
 * @description Inner class for ClsProductSeller **/
    public class ClsProductSeller {
        public String Country;
    }

    /**
     * @description Static method for parsing JSON data and returning an instance of INS_CozaLeadJson.
     * @param json The JSON data to parse.
     * @return An instance of INS_CozaLeadJson.
     */
    public static INS_CozaLeadJson parse(String json){
        return (INS_CozaLeadJson) System.JSON.deserialize(json, INS_CozaLeadJson.class);
    }
}