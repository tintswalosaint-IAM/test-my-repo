/***************************************************************************************
@name of the Class : ICS_CTRL_ApplicationFormCancel.cls
@Story:SFP-34733
@description :Controller class for cancelling application forms.
             Handles updating opportunity fields and sending emails.
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Tushar Walse
@last Modified On : 29-01-2025
@modification description: Updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_ApplicationFormCancel {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_ApplicationFormCancel');

    /**
     * @description Retrieves value from JSON string.
     * @param data JSON string
     * @param key Key whose value is to be retrieved
     * @return String result
     */
    private static String getJsonValue(String data, String key) {
        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(data);
        return (String) jsonData.get(key);
    }

    /**
     * @description Sets the value of a field of SObject with the given data.
     * @param obj SObject whose data is to be updated
     * @param field Field of the object whose data is to be updated
     * @param data Given data
     */
    private static void setField(SObject obj, String field, String data) {
        if (data != null) {
            obj.put(field, data);
        }
    }

    /**
     * @description Saves application cancel feedback data to SF opportunity.
     * @param accId Account related
     * @param data DocumentData object containing document's base64 data and details
     */
    @AuraEnabled
    public static void saveCancelFeedback(String accId, String data) {
        try {
            SEL_Opportunity selectorOpportunity = new SEL_Opportunity();
            List<Opportunity> opportunityToUpdate = selectorOpportunity.selectByAccountId(accId);
            if(!opportunityToUpdate.isEmpty()) {
                setField(opportunityToUpdate[0], 'Loss_Reason__c', getJsonValue(data, 'Please let us know why you are leaving us?'));
                setField(opportunityToUpdate[0], 'Other_Loss_Reason__c', getJsonValue(data, 'Please provide details'));
                Map<String, String> valuesMap = new Map<String, String>();
                for(PicklistEntry value : Opportunity.ICS_Competitors__c.getDescribe().getPicklistValues()) {
                    valuesMap.put(value.getValue(), value.getLabel());
                }
                String competitor = getJsonValue(data, 'Competitor name');
                if(competitor == 'Other') {
                    competitor = 'Other competitor';
                }

                if(valuesMap.containsKey(competitor)) {
                    setField(opportunityToUpdate[0], 'ICS_Competitors__c', competitor);
                    setField(opportunityToUpdate[0], 'ICS_Other_Competitor__c', '');    
                } else if(competitor != null) {
                    setField(opportunityToUpdate[0], 'ICS_Competitors__c', 'Other');
                    setField(opportunityToUpdate[0], 'ICS_Other_Competitor__c', competitor);    
                }
                opportunityToUpdate[0].StageName = 'Closed Lost';

                ProcessInstanceWorkItem[] processInstanceWorkItems = new SEL_ProcessInstanceWorkItem().selectByTargetObjectId(opportunityToUpdate[0].Id);
                if(!processInstanceWorkItems.isEmpty()) {
                    Approval.ProcessWorkitemRequest processWorkitemRequest = new Approval.ProcessWorkitemRequest();
                    processWorkitemRequest.setAction('Reject');
                    processWorkitemRequest.setWorkitemId(processInstanceWorkItems[0].Id);
                    List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
                    requests.add(processWorkitemRequest);
                    Approval.process(requests, true);    
                }
                update opportunityToUpdate[0];
            }
        } catch (Exception e) {
            LOGGER.error('Error in checkAndLoadData: {0}\nline: {1}\naccId: {2}', new Object[]{e.getMessage(), e.getLineNumber(), accId});
            throw new AuraHandledException(e.getMessage());
        }
    }
}