/**
 * @description      : Wrapper Class for INS_Quick_Quote_Application Flow 
 * @author           : Shams Ul Arifeen
 * @date             : October 2023
 * @lastModified     : SFP-46847 - Added Variables into Benfeciary class.
 * 
 * @lastModified     : Jaco de Lange
 * @date             : 2026-03-21
 * @userStory        : SFP-57183 - Add insurance policy participants list to response class
 * @lastModifiedBy   : thirdPartyPolicy;// Added New by Irshad
 */
public class INS_Quick_Quote_Wrapper {
    /**
     * @description      : Quote API body Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class QuotePayload {
        public List < Member > members;
        public String quoteId;
        public String channel;
        public Integer annualBenefitIncrease;
        public String requestId;
        public Boolean cashBackOption;
        public ProductRules productRules;
        public String consultantCode;
    }
    /**
     * @description      : Quote API members Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class Member {
        public String firstName;
        public String lastName;
        public String contactNumber;
        public String email;
        public String gender;
        public String dateOfBirth;
        public List < Benefit > benefits;
        public String memberType;
        public Boolean terminalIllness;
        public Boolean recentHospitalisation;
        public Boolean hasCoverBeenRefused;
        public String idCountryOfIssue;
        public String identityDocumentType;
        public String identityNumber;
        public String maritalStatus;
        public String relationship;
        public String customerExternalId;
    }

    /**
     * @description      : Quote API benefits Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class Benefit {
        public String benefitType;
        public Double coverAmount;
        public String duration;
        public List < Beneficiaries > beneficiaries;

        public String benefitId;
        public Double benefitAmountValue;
        public Double benefitFee;
        public String benefitFrequencyValue;
        public String benefitKey;
        public String personId;
        public String memberId;
    }

    /**
     * @description      : Quote API Beneficiaries Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class Beneficiaries {
        public Integer allocationAmount;
        public String allocationType;
    }

    /**
     * @description      : Quote API ProductRules Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class ProductRules {
        public String productId;
        public Integer annualBenefitIncrease;
        public Boolean waiveWaitingPeriod;
    }

    /**
     * @description      : Quote Benefits Request Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class QuoteBenefitRequest {
        public String referenceNumber;
        public List < QuoteBenefit > benefits;
    }

    /**
     * @description      : Quote Benefits object Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class QuoteBenefit {
        public String benefitId;
        public String benefitType;
        public Double benefitAmountValue;
        public Double benefitFee;
        public String benefitFrequencyValue;
        public String benefitKey;
        public String personId;
        public String memberId;

    }

    /**
     * @description      : Quote Additional Members Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class MemberPayload {
        public List < AddMember > members;
        public String referenceNumber;
        public boolean thirdPartyPolicy;// Added New by Irshad
    }

    /**
     * @description      : Quote Additional Member object Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class AddMember {
        public String firstName;
        public String surname;
        public String identityDocumentType;
        public String idNumber;
        public String memberType;
        public String bpid;
        public String dateOfBirth;
        public String memberId;
        public String gender;
        public String staff;
        public String relationship;
        public String isStaff;
        public List < MemberBenefit > benefits;
    }

    /**
     * @description      : Quote Additional Member benefit object Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class MemberBenefit {
        public String premiumType;
        public String benefitType;
        public String prefix;
        public String benefitKey;
        public String benefitId;
        public String benefitFrequencyValue;
        public Double benefitFee;
        public Double benefitAmountValue;
    }

    /**
     * @description      : Quote Additional AddMember Delete Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class DeleteMemberPayload {
        /** @description referenceNumber */
        public String referenceNumber {
            get;
            set;
        }
         /** @description quote member ids List */
        public List < ItemKey > itemKeys {
            get;
            set;
        }
    }
    /**
     * @description      : Quote Additional AddMember Ids List
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class ItemKey {
        /** @description quote member id */
        public String id {
            get;
            set;
        }
    }

    /**
     * @description      : Quote Add Annual Benefit Increase Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class AnnualBenefitIncreasePayload {
        /** @description referenceNumber */
        public String referenceNumber {
            get;
            set;
        }
         /** @description annualBenefitIncrease percentage */
        public Decimal annualBenefitIncrease {
            get;
            set;
        }
    }

    /**
     * @description      : Create Quote Response wrapper to return
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    
    public class Response {        
        @InvocableVariable(label = 'totalBenefitAmount')
        public Decimal totalBenefitAmount;       
        @InvocableVariable(label = 'TotalPremium')
        public Decimal totalPremium;        
        @InvocableVariable(label = 'QuoteNumber')
        public String quoteNumber;        
        @InvocableVariable(label = 'QuoteId')
        public String quoteId;        
        @InvocableVariable(label = 'MainMemberId')
        public String memberId;        
        @InvocableVariable(label = 'MainFuneralId')
        public String mainFuneralId;        
        @InvocableVariable(label = 'Access Token')
        public String accessToken;         
       
        @InvocableVariable(label = 'Beneficiaries Json')
        public String beneficiariesJson;

        @InvocableVariable(label='Participants' description='List of existing Insurance Policy Participants')
        public List<InsurancePolicyParticipant> participants;
       
    }
    
    public class Beneficiary{
        @AuraEnabled
        @InvocableVariable(label = 'Beneficiary Name')
        public String beneficiaryFirstName;
        @AuraEnabled 
        @InvocableVariable(label = 'Beneficiary Id')
        public String beneficiaryId;
        @AuraEnabled 
        @InvocableVariable(label = 'Beneficiary Surname')
        public String beneficiarySurname;
        @AuraEnabled 
        @InvocableVariable(label = 'Beneficiary Relationship')
        public String beneficiaryRelationship;
        @AuraEnabled 
        @InvocableVariable(label = 'Allocation Amount')
        public Integer allocationAmount;
        @InvocableVariable(label = 'Date Of Birth')
        public String dateOfBirth;
        @InvocableVariable(label = 'Gender')
        public String gender;
    }

    /**
     * @description      : Quote Premium Benefit wrapper to return
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class PremiumBenefitResponse {
        @InvocableVariable(label = 'Funeral Premium')
        public Double funeralPremium;
        @InvocableVariable(label = 'Catering Premium')
        public Double cateringPremium;
        @InvocableVariable(label = 'Transport Premium')
        public Double transportPremium;
        @InvocableVariable(label = 'TombStone Premium')
        public Double tombStonePremium;
        @InvocableVariable(label = 'Shopping Premium')
        public Double shoppingPremium;
        @InvocableVariable(label = 'Radio Announcement Premium')
        public Double radioAnnouncementPremium;
        @InvocableVariable(label = 'Total Premium')
        public Double totalPremium;

        @InvocableVariable(label = 'Catering Benefit Id')
        public String cateringBenefitId;
        @InvocableVariable(label = 'Tombstone Benefit id')
        public String tombstoneBenefitId;
        @InvocableVariable(label = 'Transport Benefit Id')
        public String transportBenefittId;
        @InvocableVariable(label = 'Shopping benefit Id')
        public String shoppingBenefitId;
        @InvocableVariable(label = 'Radio Announcement Benefit id')
        public String radioAnnouncementBenefitId;
        @InvocableVariable(label = 'Funeral Benefit id')
        public String funeralBenefitId;
    }

        /**
     * @description      : Quote Add Cash Back Benefit Payload
     * @author           : Shams Ul Arifeen
     * @date             : October 2023
     */
    public class CashBackBenefitPayload {
        /** @description referenceNumber */
        public String referenceNumber {
            get;
            set;
        }
         /** @description cashBackBenefit boolean */
        public Boolean cashBackBenefit {
            get;
            set;
        }
    }
}