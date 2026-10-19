public class INS_DTO_DotsureLead {
    public LeadGeneration LeadGeneration;

    public class LeadGeneration {
        public Reference Reference;
        public LeadandOpportunityProcedure LeadandOpportunityProcedure;
        public ProductDirectoryEntry ProductDirectoryEntry;
        public AdditionalData AdditionalData;
    }

    public class Reference {
        public String Salutation;
        public List<PartyName> PartyName;
        public PartyContactPoint PartyContactPoint;
    }

    public class PartyName {
        public String PartyNameType;
        public String PartyNameValue;
    }

    public class PartyContactPoint {
        public List<TelephonicAddress> TelephonicAddress;
        public ElectronicAddress ElectronicAddress;
    }

    public class TelephonicAddress {
        public String PhoneType;
        public String PhoneNumber;
    }

    public class ElectronicAddress {
        public String EmailAddress;
    }

    public class LeadandOpportunityProcedure {
        public List<CustomerCampaignReference> CustomerCampaignReference;
        public List<LeadIdentification> LeadIdentification;
    }

    public class CustomerCampaignReference {
        public Integer CampaignIdentifierValue;
        public String CampaignName;
    }

    public class LeadIdentification {
        public String LeadIdentifierValue;
        public String LeadIdentifcationType;
    }

    public class ProductDirectoryEntry {
        public List<ProductClassification> ProductClassification;
    }

    public class ProductClassification {
        public String ProductCategoryType;
        public Integer ProductCategory; 
    }

    public class AdditionalData {
        public CategoryInformation CategoryInformation;
    }

    public class CategoryInformation {
        public List<Category> Category;
    }

    public class Category {
        public List<CategoryDetails> CategoryDetails;
    }

    public class CategoryDetails {
        public String CategoryType;
        public Integer CategoryIdentifierValue; 
    }

    /**
     * @description 
     */
    public static String buildJsonPayload(Lead leadRecord, INS_Insurance_Lead_Settings__mdt settings) {
        INS_DTO_DotsureLead dto = new INS_DTO_DotsureLead();
        dto.LeadGeneration = new LeadGeneration();

        // Reference Section
        dto.LeadGeneration.Reference = new Reference();
        dto.LeadGeneration.Reference.Salutation = String.isNotBlank(leadRecord.Salutation) ? leadRecord.Salutation : 'Dear';
        
        dto.LeadGeneration.Reference.PartyName = new List<PartyName>();
        PartyName fn = new PartyName();
        fn.PartyNameType = 'FirstName';
        fn.PartyNameValue = leadRecord.FirstName;
        dto.LeadGeneration.Reference.PartyName.add(fn);

        PartyName ln = new PartyName();
        ln.PartyNameType = 'LastName';
        ln.PartyNameValue = leadRecord.LastName;
        dto.LeadGeneration.Reference.PartyName.add(ln);

        // Contact Points
        dto.LeadGeneration.Reference.PartyContactPoint = new PartyContactPoint();
        dto.LeadGeneration.Reference.PartyContactPoint.TelephonicAddress = new List<TelephonicAddress>();
        
        TelephonicAddress phone = new TelephonicAddress();
        phone.PhoneType = 'PrimaryPhone';
        phone.PhoneNumber = leadRecord.MobilePhone;
        dto.LeadGeneration.Reference.PartyContactPoint.TelephonicAddress.add(phone);

        dto.LeadGeneration.Reference.PartyContactPoint.ElectronicAddress = new ElectronicAddress();
        dto.LeadGeneration.Reference.PartyContactPoint.ElectronicAddress.EmailAddress = leadRecord.Email;

        // Procedures
        dto.LeadGeneration.LeadandOpportunityProcedure = new LeadandOpportunityProcedure();
        dto.LeadGeneration.LeadandOpportunityProcedure.CustomerCampaignReference = new List<CustomerCampaignReference>();
        
        CustomerCampaignReference camp = new CustomerCampaignReference();
        camp.CampaignIdentifierValue = Integer.valueOf(leadRecord.Campaign_Source_ID__c);
        camp.CampaignName = 'CampaignSourceID';
        dto.LeadGeneration.LeadandOpportunityProcedure.CustomerCampaignReference.add(camp);
        
        dto.LeadGeneration.LeadandOpportunityProcedure.LeadIdentification = new List<LeadIdentification>();

        LeadIdentification leadIdentification = new LeadIdentification();
        leadIdentification.LeadIdentifierValue = leadRecord.Id;
        leadIdentification.LeadIdentifcationType = 'LeadIdentifier';
        
        dto.LeadGeneration.LeadandOpportunityProcedure.LeadIdentification.add(leadIdentification);

        // Products
        dto.LeadGeneration.ProductDirectoryEntry = new ProductDirectoryEntry();
        dto.LeadGeneration.ProductDirectoryEntry.ProductClassification = new List<ProductClassification>();
        
        ProductClassification prod = new ProductClassification();
        prod.ProductCategoryType = 'PreferredProduct';
        prod.ProductCategory = (Integer) settings.INS_PreferredProduct__c;
        dto.LeadGeneration.ProductDirectoryEntry.ProductClassification.add(prod);

        // Additional Data
        dto.LeadGeneration.AdditionalData = new AdditionalData();
        dto.LeadGeneration.AdditionalData.CategoryInformation = new CategoryInformation();
        dto.LeadGeneration.AdditionalData.CategoryInformation.Category = new List<Category>();
        
        Category cat = new Category();
        cat.CategoryDetails = new List<CategoryDetails>();
        
        CategoryDetails catDetail = new CategoryDetails();
        catDetail.CategoryType = 'AgentId';
        catDetail.CategoryIdentifierValue = (Integer) settings.INS_Agentkey__c;
        cat.CategoryDetails.add(catDetail);
        dto.LeadGeneration.AdditionalData.CategoryInformation.Category.add(cat);

        return JSON.serialize(new List<INS_DTO_DotsureLead>{ dto });
    }
}