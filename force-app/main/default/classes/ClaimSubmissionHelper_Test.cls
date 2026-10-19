/**
 * @description : Test for ClaimSubmissionHelper
 * @author : Dhiraj Prajapati (CloudSmiths)
 *
 * @last modified on : 03-28-2024
 * @last modified by : Dhiraj Prajapati (CloudSmiths)
**/
@isTest
public class ClaimSubmissionHelper_Test {

    @isTest
    private static void testGetClaims() {
        InsuranceClaim_TestFactory factory = new InsuranceClaim_TestFactory();

        Account account = factory.createAccount();
        insert account;

        InsurancePolicy policy = factory.createPolicy(account.Id);
        insert policy;

        Claim claim = factory.createClaim(policy.Id);
        insert claim;

        List<ClaimParticipant> participants = new List<ClaimParticipant>();
        participants.add(
            factory.createParticipant(
                claim.Id, 'Deceased'
            )
        );
        participants.add(
            factory.createParticipant(
                claim.Id, 'Claimant'
            )
        );
        insert participants;

        Test.startTest();
        List<Id> claims = ClaimSubmissionHelper.getClaims(new List<Id>{policy.Id});
        Test.stopTest();

        Assert.areEqual(claim.Id, claims.get(0), 'No Claims Found');
    }
}