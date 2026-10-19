/**
 * @description Test class of Flow invocable action
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/09
 */
@isTest
public class WI_FLOW_Deferral_TEST {
    /**
     * @description To check approval process
     */
    @isTest
    private static void processRecordTest() {
        Application__c ce = WI_DAL_DataFactory.createApplication(
            new Map<String, Object>{
                Schema.Application__c.WI_AttestationConfirmation__c.getDescribe().getName() => 'Yes',
                Schema.Application__c.WI_SubmitterManager__c.getDescribe().getName() => UserInfo.getUserId()
            }
        );
    
        insert ce;

        //Submit for Approval
        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(ce.Id);
        Approval.ProcessResult result1 = Approval.process(testapproval);
        Assert.isTrue(result1.isSuccess(), 'Submit for Approval Error');
    
        WI_FLOW_Deferral.DTO_DeferralRequest request = new WI_FLOW_Deferral.DTO_DeferralRequest();
        request.recordId = ce.Id;
        request.comment = 'Recall comment';
        request.action = 'Removed';
        

        Test.startTest();
        //exception
        List<WI_FLOW_Deferral.DTO_DeferralResponse> results = WI_FLOW_Deferral.processRecord(
            null
        );
        for (WI_FLOW_Deferral.DTO_DeferralResponse item : results) {
            Assert.isFalse(item.success, 'Submit for Recall Exception');
        }
        //positive
        results = WI_FLOW_Deferral.processRecord(
            new List<WI_FLOW_Deferral.DTO_DeferralRequest>{request}
        );
        for (WI_FLOW_Deferral.DTO_DeferralResponse item : results) {
            Assert.isTrue(item.success, 'Submit for Recall Error');
        }
        Test.stopTest();
    }
}