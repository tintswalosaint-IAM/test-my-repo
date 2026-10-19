/**
 * @description       : Apex class for retrieving servicing policy records for logged-in user
 * @author            : Madito Tsilo
 * @UserStory         : SFP-53079
 * @date              : 25-10-2025
 ***************************************************
 * Last Modified By Alexandr Goryachko
 * Last Modified Date 07/04/2026
 * Last Modified Description: get beneficiaries logic is using SF database
 * User Story : SFP-57247
 **/
public without sharing class INS_PLI_GetServicePolicyRecords {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PLI_GetServicePolicyRecords');
	/**
     * @description Retrieves Policies for logged in user
     * @author            : Madito Tsilo
 	 * @UserStory         : SFP-53079
 	 * @date              : 25-10-2025
     */
    @AuraEnabled(cacheable=true)
    public static PolicyWrapper getPoliciesForUser() {

        PolicyWrapper wrapper = new PolicyWrapper();

        try {
            Id userId = UserInfo.getUserId();
            User usr = new SEL_User().selectUserById(userId);

            if (usr == null || usr.Contact == null || usr.Contact.AccountId == null) {
                wrapper.errorMessage = 'No Account found for the logged-in user.';
                return wrapper;
            }

            List<InsurancePolicy> polList = new SEL_InsurancePolicy().selectByNameInsuredId(String.valueOf(usr.Contact.AccountId));
            System.debug('Policies retrieved: ' + polList);
			if (polList == null || polList.isEmpty() ) {
                wrapper.errorMessage = 'No Insurance Policy found for the logged-in user.';
                return wrapper;
            }
            InsurancePolicy pol = polList[0]; // Assuming we want the first policy for the user
            // Base policy data
            wrapper.productName = pol.ProductNameFormula__c;
            wrapper.policyNumber = pol.Name;
            wrapper.member = getMemberWrapper(pol);
            wrapper.cover = getCoverWrapper(pol);
            wrapper.payment = getPaymentWrapper(pol);
            wrapper.beneficiaries = getBeneficiariesWrapper(pol);
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_GetServicePolicyRecords.getPoliciesForUser', e.getMessage()},e);            
			throw new AuraHandledException('Failed to get policy records ' + e.getMessage());            
        }

        return wrapper;
    }

    /**
     * @description Retrieves member details
     * @author            : Madito Tsilo
 	 * @UserStory         : SFP-53079
 	 * @date              : 25-10-2025
     */
    private static MemberWrapper getMemberWrapper(InsurancePolicy pol) {
        MemberWrapper member = new MemberWrapper();

        if (pol.Premium_Payer__r != null) {
            member.firstName = pol.Premium_Payer__r.FirstName;
            member.lastName = pol.Premium_Payer__r.LastName;
            member.email = pol.Premium_Payer__r.PersonEmail;
            member.phone = pol.Premium_Payer__r.Phone;
            member.idNumber = pol.Premium_Payer__r.CMN_IdentityNumber__pc;
            member.dob = String.valueOf(pol.Premium_Payer__r.PersonBirthdate);
        }

        return member;
    }

    /**
     * @description Retrieves cover details
     * @author            : Madito Tsilo
 	 * @UserStory         : SFP-53079
 	 * @date              : 25-10-2025
     */
    private static CoverWrapper getCoverWrapper(InsurancePolicy pol) {
        CoverWrapper cover = new CoverWrapper();
        cover.amount = pol.TotalSumInsured != null ? String.valueOf(pol.TotalSumInsured) : '';
        cover.premium = pol.PremiumAmount != null? String.valueOf(pol.PremiumAmount) : '';
        return cover;
    }
    /**
     * @description Retrieves payment details
     * @author            : Madito Tsilo
 	 * @UserStory         : SFP-53079
 	 * @date              : 25-10-2025
     */
    private static PaymentWrapper getPaymentWrapper(InsurancePolicy pol) {
        PaymentWrapper payment = new PaymentWrapper();
        payment.method = pol.PaymentMethod__c;
        payment.frequency = 'Monthly';        
        payment.mobile = pol.PremiumPaymentAccountNumber__c;
        payment.collectionDay = pol.CollectionDay__c;
        return payment;
    }

    /**
     * @description Retrieves beneficiary details
     * @author            : Alexandr Goryachko
     * @UserStory         : SFP-53079
     * @date              : 30-03-2026
     */
    private static List<BeneficiaryWrapper> getBeneficiariesWrapper(InsurancePolicy pol) {
        List<BeneficiaryWrapper> beneficiaries = new List<BeneficiaryWrapper>();
        List<InsurancePolicyParticipant> participants = new SEL_InsurancePolicyParticipant().selectByInsurancePolicyIds(new List<Id>{pol.Id});
        for (InsurancePolicyParticipant item : participants) {
            beneficiaries.add(
                new BeneficiaryWrapper(item)
            );
        }
        return beneficiaries;
    }

    public class PolicyWrapper {
        @AuraEnabled public String productName;
        @AuraEnabled public String policyNumber;
        @AuraEnabled public MemberWrapper member;
        @AuraEnabled public CoverWrapper cover;
        @AuraEnabled public List<BeneficiaryWrapper> beneficiaries;
        @AuraEnabled public PaymentWrapper payment;
        @AuraEnabled public Decimal totalPremium;   
        @AuraEnabled public String debitDay;        
        @AuraEnabled public String errorMessage;
    }

    public class MemberWrapper {
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String idNumber;
        @AuraEnabled public String dob;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
    }

    public class CoverWrapper {
        @AuraEnabled public String amount;
        @AuraEnabled public String premium;
    }

    public class BeneficiaryWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String relationship;
        @AuraEnabled public Decimal allocation;

        public BeneficiaryWrapper(InsurancePolicyParticipant participant) {
            this.id = participant.Id;
            this.name = (String.isNotBlank(participant.FirstName__c) ? participant.FirstName__c : '') 
                + ' ' + (String.isNotBlank(participant.LastName__c) ? participant.LastName__c : '');
            this.relationship = participant.RelationshipToInsured;
            this.allocation = participant.BeneficiarySharePercentage;    
        }
    }

    public class PaymentWrapper {
        @AuraEnabled public String method;
        @AuraEnabled public String mobile;
        @AuraEnabled public String frequency;
        @AuraEnabled public String collectionDay;
    }
}