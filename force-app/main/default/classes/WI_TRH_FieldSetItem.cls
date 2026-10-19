/**
 * @description Trigger Handler framework handler class for FieldSetItem object
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/06
 */
public inherited sharing class WI_TRH_FieldSetItem extends CMN_TRH_BaseObject {
    private Map<String, Schema.SObjectType> gd;
    private String ERROR_OBJ_MSG = 'The object api name has invalid name.';
    private String ERROR_FIELD_MSG = 'The field api name has invalid name.';
    
    /**
     * @description This method is called prior to execution of a BEFORE Trigger. 
     * Use this to cache any data required into maps prior execution of the Trigger.
     */
    public override void bulkBefore() {
        this.gd = Schema.getGlobalDescribe();
    }

    /**
     * @description Before update handler
     *
     * @param oldSo - Old record
     * @param so - New record
     */
    public override void beforeUpdate(SObject oldSo, SObject so) {
        super.beforeUpdate(oldSo, so);

        this.validateApiName((FieldSetItem__c)so);
    }

    /**
     * @description Before insert handler
     *
     * @param so - New record
     */
    public override void beforeInsert(SObject so) {
        super.beforeInsert(so);

        this.validateApiName((FieldSetItem__c)so);
    }

    /**
     * @description Validate field changes on record
     * 
     * @param newRecord - New FieldSetItem__c record
     */
    private void validateApiName(FieldSetItem__c newRecord) {
        if (!this.gd.containsKey(newRecord.ObjectApiName__c)) {
            newRecord.addError('ObjectApiName__c', ERROR_OBJ_MSG);
        } else if (!this.gd.get(newRecord.ObjectApiName__c).getDescribe().fields.getMap().containsKey(newRecord.FieldApiName__c)) {
            newRecord.addError('FieldApiName__c', ERROR_FIELD_MSG);
        }
    }
}