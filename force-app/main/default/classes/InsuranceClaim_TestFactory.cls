/**
 * @description : Insurance stream specific factory class
 * @author : Dhiraj Prajapati (CloudSmiths)
 *
 * @last modified on  : 03-28-2024
 * @last modified by  : Dhiraj Prajapati (CloudSmiths)
**/
@isTest
public class InsuranceClaim_TestFactory {

    /**
    * @description
    * @author Dhiraj Prajapati (CloudSmiths) | 03-28-2024
    * @return Account
    **/
    public Account createAccount() {
        return new Account(Name = 'ABC Account');
    }

    /**
    * @description - Create a InsurancePolicy for an Account
    * @author Dhiraj Prajapati (CloudSmiths) | 03-28-2024
    * @param accountId
    * @return InsurancePolicy
    **/
    public InsurancePolicy createPolicy(Id accountId) {
        return new InsurancePolicy(
            NameInsuredId = accountId,
            Name = 'Insurance ABC - Term'
        );
    }

    /**
    * @description - Create a Claim for an InsurancePolicy policy
    * @author Dhiraj Prajapati (CloudSmiths) | 03-28-2024
    * @param policyId
    * @return Claim
    **/
    public Claim createClaim(Id policyId) {
        return new Claim(
            PolicyNumberId = policyId,
            Name = 'Dummy Claim',
            Status = 'New'
        );
    }

    /**
    * @description - Create a ClaimParticipant linked to a Claim
    * @author Dhiraj Prajapati (CloudSmiths) | 03-28-2024
    *
    * @param claimId
    * @param role
    * @return ClaimParticipant
    **/
    public ClaimParticipant createParticipant(Id claimId, String role) {
        return new ClaimParticipant(
            ClaimId = claimId,
            Roles = role
        );
    }
}