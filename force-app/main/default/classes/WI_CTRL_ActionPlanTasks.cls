/**
 * @description Controller for the LWC wi_comp_actionPlanTasks
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/05
 */
public with sharing class WI_CTRL_ActionPlanTasks {
    /**
     * @description Get related list records
     * @param recordId Id of the parent record
     * @return Wrapper class with init data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse getRelatedListData(Id recordId) {
        DataResponse result;
        List<DataRelatedResponse> tasks = new List<DataRelatedResponse>();
        try {
            if (recordId == null) {
                throw new IllegalArgumentException('Record Id is null.');
            }
            List<ActionPlanItem> items = [
                SELECT ActionPlanId, ActionPlan.Name, ItemId, Item.Subject, Item.Status,
                    Item.OwnerId, Item.Owner.Name, Item.ActivityDate, IsRequired
                FROM ActionPlanItem
                WHERE ActionPlan.TargetId = :recordId
                ORDER BY ActionPlanTemplateItemId
            ];
            //List<ActionPlanItem> items = new WI_SEL_ActionPlanItem().getActionPlanItemsByTargetId(recordId);
            for (ActionPlanItem item : items) {
                tasks.add(
                    new DataRelatedResponse(item)
                );
            }
            result = new DataResponse(tasks);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Complete Task
     * @param taskId Id of the task record
     * @return Wrapper class with data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse completeTask(Id taskId) {
        DataResponse result;
        try {
            if (taskId == null) {
                throw new IllegalArgumentException('Task Id is null.');
            }
            Task t = new Task(Id = taskId, Status = 'Completed');
            update t;
            result = new DataResponse(true);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Wrapper class with response to LWC component 
     */
    public class DataResponse {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String stack;
        @AuraEnabled
        public String result;

        /**
         * @description Wrapper constructor
         * @param ex exception record
         */
        public DataResponse(Exception ex) {
            this.isSuccess = false;
            this.message = ex.getMessage();
            this.stack = ex.getStackTraceString();
        }

        /**
         * @description Wrapper constructor
         * @param result output object
         */
        public DataResponse(Object result) {
            this.isSuccess = true;
            this.result = JSON.serialize(result);
        }
    }

    /**
     * @description Wrapper class with Related response
     */
    public class DataRelatedResponse {
        public Id actionPlanId;
        public String actionPlanLink;
        public String actionPlanName;
        public Id itemTaskId;
        public String itemTaskLink;
        public String subject;
        public String status;
        public Id ownerId; 
        public String ownerLink; 
        public String ownerName;
        public Date activityDate;
        public Boolean required;

        /**
         * @description Wrapper constructor
         * @param result output object
         */
        public DataRelatedResponse(ActionPlanItem item) {
            this.actionPlanId = item.ActionPlanId;
            this.actionPlanLink = '/' + item.ActionPlanId;
            this.actionPlanName = item.ActionPlan.Name;
            this.itemTaskId = item.ItemId;
            this.itemTaskLink = '/' + item.ItemId;
            this.subject = item.Item.Subject;
            this.status = item.Item.Status;
            this.ownerId = item.Item.OwnerId;
            this.ownerLink = '/' + item.Item.OwnerId;
            this.ownerName = item.Item.Owner.Name;
            this.activityDate = item.Item.ActivityDate;
            this.required = item.IsRequired;
        }
    }
}