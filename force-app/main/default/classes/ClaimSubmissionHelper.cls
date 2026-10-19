/**
 * @description :
 * @author : Dhiraj Prajapati (CloudSmiths)
 *
 * @last modified on  : 06-18-2024
 * @last modified by  : Dhiraj Prajapati (CloudSmiths)
**/
public with sharing class ClaimSubmissionHelper {

    /**
    * @description - InvocableMethod to be called in Flow
    *
    * @author Dhiraj Prajapati (CloudSmiths) | 03-28-2024
    * @param insurancePolicies - InsurancePolicy Ids
    *
    * @return List<Id> - Claim Ids
    **/
    @InvocableMethod(label='Fetch Claim')
    public static List<Id> getClaims(List<Id> insurancePolicies) {
        List<Id> claims = new List<Id>();
        List<ClaimParticipant> participants = new  List<ClaimParticipant>();
        participants = new SEL_ClaimParticipant().selectClaimParticipants(
            new Set<Id>(insurancePolicies),
            new Set<Id>{UserInfo.getUserId()},
            new Set<String>{'Deceased'},
            new Set<String>{'New'}
        );
        if (participants != null && !participants.isEmpty()) {
            // Storing one Claim Id only as there will only ever be one `New` and `Deceased` Claim per policy
            // when executing a claim submission
            claims.add(participants?.get(0).Claim.Id);
        }
        return claims;
    }
}