/**
 * @description Contains approval Recall action
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/08
 */
public with sharing class WI_FLOW_Deferral {
    /**
     * @description Make Approve, Reject, or Removed of approval process
     * @param requests request wrapper
     * @return response wrapper
     */
    @InvocableMethod(Label='Approve, Reject, or Removed Approval Process' Description='To do a Approve, Reject, or Removed of approval process')
    public static List<DTO_DeferralResponse> processRecord(List<DTO_DeferralRequest> requests) {
        DTO_DeferralResponse result = new DTO_DeferralResponse();
        Map<String, DTO_DeferralRequest> commentByRecordId = new Map<String, DTO_DeferralRequest>();
        try {
            for (DTO_DeferralRequest request : requests) {
                commentByRecordId.put(request.recordId, request);
            }
            List<ProcessInstanceWorkitem> piwi = [
                SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.TargetObjectId IN :commentByRecordId.keySet()
            ];
            List<CMN_ApprovalRecall__e> pEvents = new List<CMN_ApprovalRecall__e>();
            for (ProcessInstanceWorkitem item : piwi) {
                pEvents.add(
                    new CMN_ApprovalRecall__e(
                        CMN_RecordId__c = item.Id,
                        CMN_Action__c = commentByRecordId.get(item.ProcessInstance.TargetObjectId).action,
                        CMN_Params__c = commentByRecordId.get(item.ProcessInstance.TargetObjectId).params,
                        CMN_Comment__c = commentByRecordId.get(item.ProcessInstance.TargetObjectId).comment
                    )
                );
            }
            EventBus.publish(pEvents);
        } catch (Exception ex) {
            result = new DTO_DeferralResponse(ex);
        }
        return new List<DTO_DeferralResponse>{result};
    }

    /**
     * @description wrapper class with input parameters
     */
    public class DTO_DeferralRequest {

        @InvocableVariable(Label='Record Id' Description='The record Id of the object sent to approve' Required=true)
        public String recordId;
        @InvocableVariable(Label='Action' Description='Approve, Reject, or Removed' Required=true)
        public String action;
        @InvocableVariable(Label='Comment' Description='Recall comment' Required=false)
        public String comment;
        @InvocableVariable(Label='Params' Description='JSON string' Required=false)
        public String params;
    }

    /**
     * @description wrapper class with output parameters
     */
    public class DTO_DeferralResponse {
        @InvocableVariable(Label='Send Successful' Description='Indicates whether the Recall process was done successful' Required=true)
        public Boolean success;
        @InvocableVariable(Label='Errors' Description='An error encountered when attempting to do the recall' Required=false)
        public String error;

        /**
         * @description Wrapper constructor
         * @param ex exception record
         */
        public DTO_DeferralResponse(Exception ex) {
            this.success = false;
            this.error = ex.getMessage();
        }

        /**
         * @description Wrapper constructor
         */
        public DTO_DeferralResponse() {
            this.success = true;
        }
    }
}