/**
 * @description       : CMN_DTO_CustomerRMChangeResponse Apex class for Update Customer API
 * @author            : Muvhuso
 * @group             : PPB Maintain Customer
 * @last modified on  : February 2026
 * SFP :SFP-50270
**/

@SuppressWarnings('PMD') 
// DTO's violate many PMD rules such as public count and attribute naming conventions.
public with sharing class CMN_DTO_CustomerRMChangeResponse {

    public Customer customer { get; set; }
    public class Customer {
        public String uuid { get; set; }
        public String customer_type { get; set; }
        public String customer_typeX { get; set; }
        public String residenceCountry { get; set; }
        public String relManager { get; set; }

        public PersonDetails personDetails { get; set; }

        public List<ComplianceItem> compliance { get; set; }
    }

    public class PersonDetails {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String initials { get; set; }
        public String dob { get; set; } // Keep as String ("YYYY-MM-DD")
        public String gender { get; set; }
        public String genderX { get; set; }
        public String title { get; set; }
        public String titleX { get; set; }
        public String maritalStatus { get; set; }
        public String maritalStatusX { get; set; }
        public String citizenshipCountry { get; set; }
        public String nationality { get; set; }
        public String countryOfBirth { get; set; }
        public String homeOwnership { get; set; }
        public String homeOwnershipX { get; set; }
        public String qualification { get; set; }
        public String qualificationX { get; set; }
        public String maritalPropertyRegime { get; set; }
        public String maritalPropertyRegimeX { get; set; }

    }

    // compliance array items
    public class ComplianceItem {
        public String compRole { get; set; }
        public String compRoleX { get; set; }
        public String complianceStatus { get; set; }
        public String complianceStatusX { get; set; }
        public String verifiedBy { get; set; }
    }


}