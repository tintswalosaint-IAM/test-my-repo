/**
 * This class is used as a service class for the SetConditions API
 *
 * <p>DBP-2295</p>
 *
 * @author (mark.bailey2@standardbank.co.za)
 *
 * @date Feb 16th 2021
 */
public class DOC_SRV_SetConditions {
    public static final String SERVICE_NAME = DOC_SRV_SetConditions.class.getName();
    /**
     * @description Makes an api call to set the status of the Offer Conditions
     * @param    applicationId
     */
    @future(callout=true)
    public static Void setConditions(String applicationId) {
        try {
            DOC_API_SetConditions customerServiceCall;
            DOC_DTO_Conditions conditions = new DOC_DTO_Conditions();
            DOC_DTO_Conditions.input input = getConditions(applicationId);
            conditions.input.add(input);
            // Add to WebService Queue
            customerServiceCall = new DOC_API_SetConditions((Object) conditions, applicationId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(DOC_API_SetConditions.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, 'DOC_SRV_SetConditions.setConditions');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /**
     * @description prepares the input for set condition API
     * @param    applicationId
     */
    public static DOC_DTO_Conditions.Input getConditions(String applicationId) {
        DOC_DTO_Conditions.input result = new DOC_DTO_Conditions.input();
        //We need to read the Document Conditions and Condition Keys for this Application
        List<AOB_Application__c> applications = [SELECT id, AOB_Customer__c, AOB_OfferId__c FROM AOB_Application__c WHERE id = :applicationId];
        List<DOC_Document__c> documents = [SELECT Id, DOC_ConditionCode__c, DOC_Customer_BPGUID__c, DOC_DocumentGUID__c FROM DOC_Document__c WHERE AOB_Application__c = :applicationId];
        //Get Customer BP ID
        List<Account> accounts = [SELECT id, ExternalCIFUUID__c, ExternalCIFId__c FROM Account WHERE id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())];
        Map<Id, DOC_ConditionKey__c> mapConditionKeys = new Map<Id, DOC_ConditionKey__c>();
        if (!documents.isEmpty()) {
            for (DOC_ConditionKey__c conds : [
                SELECT DOC_Document__c, Name, DOC_itemGuid__c, DOC_PartnerFunction__c, DOC_recordId__c
                FROM DOC_ConditionKey__c
                WHERE DOC_Document__r.AOB_Application__c = :applicationId
            ]) {
                mapConditionKeys.put(conds.DOC_Document__c, conds);
            }
            for (DOC_Document__c docRec : documents) {
                // Condition Object
                DOC_DTO_Conditions.Conditions condition = new DOC_DTO_Conditions.Conditions();
                condition.conditionCode = docRec.DOC_ConditionCode__c;
                condition.documentGuid = docRec.DOC_DocumentGUID__c;
                condition.uploadedDate = DateTime.now().format('yyyy-MM-dd');
                // Condition Key Object
                DOC_DTO_Conditions.ConditionKey conditionKey = new DOC_DTO_Conditions.ConditionKey();
                if (mapConditionKeys.get(docRec.Id) != null) {
                    DOC_ConditionKey__c condKeyRec = mapConditionKeys.get(docRec.Id);
                    String partnerFunction = condKeyRec.DOC_PartnerFunction__c;
                    conditionKey.partnerFunction = partnerFunction;
                    String itemGuid = condKeyRec.DOC_itemGuid__c;
                    conditionKey.itemGuid = itemGuid;
                    String recordId = condKeyRec.DOC_recordId__c;
                    conditionKey.recordId = recordId;
                    if (condition.documentGuid != null && conditionKey.partnerFunction != null && conditionKey.itemGuid != null && conditionKey.recordId != null) {
                        condition.conditionKey.add(conditionKey);
                    }
                }
                // Bring it all together
                if (!condition.conditionKey.IsEmpty() && condition.documentGuid != null) {
                    result.partner = accounts[0].ExternalCIFId__c;
                    result.conditions.add(condition);
                }
            }
        }
        return result;
    }
}