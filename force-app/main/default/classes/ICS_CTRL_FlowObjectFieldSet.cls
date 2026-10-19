/**
 * @description Controller for custom flow components flowRecordRepeater and flowObjectFieldSet
 * @author Melnyk Oleg
 * @date Oсtober 2022
 */

public with sharing class ICS_CTRL_FlowObjectFieldSet {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_FlowObjectFieldSet');
    /**
     * @description This method is used to get a list of fields for edit/preview
     * @param objectName API Name of an object which has the fields
     * @param groupName name of fields group/section
     * @return an array of objects with details about the field
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getFieldGroup(String objectName, String groupName) {
        try {
            LOGGER.info('getFieldGroup({0}, {1})', new Object[] {objectName, groupName});
            List<Map<String, Object>> result = new List<Map<String, Object>>();
            Map<String, Schema.SObjectField> fieldsMap = getObjectFields(objectName);

            List<ICS_Application_Flow__mdt> fields = [SELECT Id,
                Label,
                Field_label__c,
                Field_API_Name__c,
                Regular_Expression__c,
                Visibility__c,
                Order__c,
                Show_in_preview__c,
                Show_in_edit__c,
                Required__c,
                Section_name__c,
                Min_date__c,
                Max_date__c,
                Error_message__c,
                Help_text__c,
                Picklist_with_changed_label__c
                FROM ICS_Application_Flow__mdt
                WHERE Section_name__c = :groupName
                LIMIT 100
            ];
            LOGGER.info('getFieldGroup fields size ' + fields.size());

            for (ICS_Application_Flow__mdt field : fields) {
                Schema.SObjectField fieldObj = fieldsMap.get(field.Field_API_Name__c);
                if (fieldObj != null) {
                    Schema.DescribeFieldResult fieldDesc = fieldObj.getDescribe();
                    Map<String, Object> payload = new Map<String, Object> {
                        'label' => field.Field_label__c,
                        'path' => field.Field_API_Name__c,
                        'regexp' => field.Regular_Expression__c,
                        'visibility' => field.Visibility__c,
                        'order' => field.Order__c,
                        'preview' => field.Show_in_preview__c,
                        'edit' => field.Show_in_edit__c,
                        'required' => field.Required__c,
                        'type' => String.valueOf(fieldDesc.getType()),
                        'minDate' => field.Min_date__c,
                        'maxDate' => field.Max_date__c,
                        'errorMessage' => field.Error_message__c,
                        'helpText' => field.Help_text__c
                    };
                    if (field.Picklist_with_changed_label__c) {
                        payload.put(
                            'picklistValues',
                            getPicklistValues(objectName, field.Field_API_Name__c)
                        );
                    }
                    result.add(payload);
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error on getFieldGroup', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description This method is used to get a map of fields of an object
     * @param objectName API Name of an object which has the fields
     * @return a map of fields related to the object
     */
    private static Map<String, Schema.SObjectField> getObjectFields(String objectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Map<String, Schema.SObjectField> objFields = DescribeSObjectResultObj.fields.getMap();
        return objFields;
    }

    /**
     * @description This method is used to get a list of picklist options
     * @param objectName API Name of an object which has the fields
     * @param fieldPath API Name of a field
     * @return a list of picklist options
     */
    public static List<Map<String, Object>> getPicklistValues(String objectName, String fieldPath) {
        Map<String, Schema.SObjectField> objFields = getObjectFields(objectName);
        Schema.SObjectField fieldObj = objFields.get(fieldPath);

        if (fieldObj == null) {
            return null;
        }

        Schema.DescribeFieldResult fieldDesc = fieldObj.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldDesc.getPicklistValues();
        List<Map<String, Object>> picklistValues = new List<Map<String, Object>>();

        for (Schema.PicklistEntry option: picklistEntries) {
            picklistValues.add(new Map<String, Object> {
                'label' => option.getLabel(),
                'value' => option.getValue()
            });
        }
        return picklistValues;
    }

    /**
     * @description The method is used to get a record of an object. The data is used for preview updates.
     * @param objectName API Name of an object
     * @param recordId an Id of a record
     * @param fields a string representing a list of fields separated by comma
     * @return an object record
     */
    @AuraEnabled(cacheable=false)
    public static Sobject getRecord(String objectName, String recordId, String fields){
        try {
            String objectNameEsc = String.escapeSingleQuotes(objectName);
            String recordIdEsc = String.escapeSingleQuotes(recordId);
            String fieldsEsc = String.escapeSingleQuotes(fields);
            Sobject result = Database.query('SELECT Id, '+fieldsEsc+' FROM '+objectNameEsc+' WHERE Id = \''+recordIdEsc+'\' LIMIT 1');
            return result;
        } catch (Exception e) {
            LOGGER.error('Error on getRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description The method is used to create a new record
     * @param objectName API Name of an object
     * @param recordName Name of a record
     * @param parentObjectId 	Id of a parent record
     * @param relationField 	API Name of the field which creates a relation
     * @param recordTypeId 		the Id of record type
     * @param typeField   		the field type
     * @param typeValue 		the value type
     * @return an object with Id of a new record
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> createNewRecord(
        String objectName,
        String recordName,
        String parentObjectId,
        String relationField,
        String recordTypeId,
        String typeField,
        String typeValue
    ) {
        try {
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
            Sobject instance = sObjectTypeObj.newSobject();
            
            instance.put(relationField, parentObjectId);
            if (!String.isBlank(recordTypeId)) {
                instance.put('RecordTypeId', recordTypeId);
            }
            if (
                !(String.isBlank(typeField) && String.isBlank(typeValue)) &&
                fieldExists(instance, typeField)
            ) {
                instance.put(typeField, typeValue);
            }
            if (!hasAutoNumberName(instance)) {
                instance.put('Name', recordName);
            }
            if (objectName == 'PartyProfile'){
                instance.put('FirstName', recordName);
            }
            
            insert instance;
            
            return new Map<String, Object> {
                'Id' => instance.get('Id')
            };
        } catch (Exception e) {
            LOGGER.error('Error on createNewRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description The method is used to check if object has auto number name
     * @param obj an instance of a record (sobject)
     * @return true if object has auto number name
     */
    private static Boolean hasAutoNumberName(Sobject obj) {
        return obj.getSobjectType().getDescribe().fields.getMap().get('Name').getDescribe().isAutoNumber();
    }

    /**
     * @description The method is used to check if field exists on a record
     * @param obj an instance of a record (sobject)
     * @param fieldName API name of the field
     * @return true if object has auto number name
     */
    private static Boolean fieldExists(Sobject obj, String fieldName) {
        return obj.getSobjectType().getDescribe().fields.getMap().get(fieldName) != null;
    }

    /**
     * @description The method is used to delete a record
     * @param objectName API Name of an object
     * @param recordId the Id of a record
     * @return success true if record was successfully deleted
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> removeRecord(String objectName, String recordId) {
        try {
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
            Sobject instance = sObjectTypeObj.newSobject();

            instance.put('Id', recordId);
            delete instance;
            return new Map<String, Object> {
                'success' => true
            };
        } catch (Exception e) {
            LOGGER.error('Error on removeRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}