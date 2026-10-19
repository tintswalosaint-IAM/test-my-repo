/**
 * @description Class is responsible for creating the JSON data for beneficiaries.
 * @author Raja Arsalan (raja.arsalan@standardbank.co.za)
 * @date Sept 2023
 */

public class INS_Create_Quote_Beneficiaries_Json {
    public String referenceNumber;
    public List<Beneficiary> beneficiaries;
/**
 * @description Inner class for INS_Create_Quote_Beneficiaries_Json 
**/
    public INS_Create_Quote_Beneficiaries_Json() {
        beneficiaries = new List<Beneficiary>();
    }
/**
 * @description Inner class for Beneficiary 
*/    
    public class Beneficiary {
        public Integer AllocationAmount;
        public String AllocationType;
        public String BenefitId;
        public String PersonId;
        public String BeneficiaryId;
        public String Initials;
        public String Title;
        public String FirstName;
        public String Surname;
        public String Gender;
        public String IdentityType;
        public String IdCountryOfIssue;
        public String IdentityNumber;
        public String DateOfBirth;
        public String Relationship;
    }
/**
 * @description Inner class for Contact 
*/  
    
    public class Contact {
        public String contactKey;
        public String contactType;
        public String text;
    }

/**
 * @description Inner class for DeleteBeneficiaryPayload 
*/   
    public class DeleteBeneficiaryPayload {
        /**
 * @description getter setter referenceNumber 
*/ 
        public String referenceNumber { get; set; }
/**
 *@description getter setter itemkeys
*/ 
        public List<ItemKey> itemKeys { get; set; }
    }
    
/**
 * @description Inner class for ItemKey 
*/
        public class ItemKey {
/**
 * @description getter setter id
*/ 
            public String id { get; set; }
/**
 * @description getter setter key
*/ 
            public String key { get; set; }
        }
}