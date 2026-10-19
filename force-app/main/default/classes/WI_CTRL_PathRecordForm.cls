/**
 * @description Controller for the LWC wi_comp_pathRecordForm
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/06
 */
public with sharing class WI_CTRL_PathRecordForm {
    /**
     * @description Get init data for the component
     * @param objectName API name of object
     * @param parentFieldApi Parent Field API name that uses to find current stages
     * @param stageFieldApi Picklist Field API name that contains all child stages
     * @param recordId Id of the record
     * @return Wrapper class with init data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse getData(String objectApi, String parentFieldApi, String stageFieldApi, Id recordId) {
        DataResponse result;
        DataObject data = new DataObject();
        try {
            List<String> fields = new List<String>(Schema.getGlobalDescribe().get(objectApi).getDescribe().fields.getMap().keySet());
            String query = 'SELECT ' + String.join(fields, ',');
            query += ' FROM ' + String.escapeSingleQuotes(objectApi);
            query += ' WHERE Id = :recordId';
            data.record = Database.query(query);
            data.fields = getFieldSetMembers(
                objectApi,
                (String)data.record.get(parentFieldApi),
                (String)data.record.get(stageFieldApi)
            );
            //populates fields with values
            for (DataField item : data.fields) {
                item.value = data.record.get((String)item.name);
            }
            result = new DataResponse(data);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Update data in the record
     * @param record SObject record
     * @return Wrapper class with init data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse updateData(SObject record) {
        DataResponse result;
        try {
            update record;
            result = new DataResponse(true);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Get editable fields on object
     * 
     * @param objectTypeName API name of object
     * @return List<String> - editable fields api names
     */
    private static Set<String> getEditableFields(String objectTypeName) {
        Set<String> result = new Set<String>();
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap();
        for (Schema.SObjectField item : fields.values()) {
            Schema.DescribeFieldResult field = item.getDescribe();
            if (field.isUpdateable() && field.isCreateable() && !field.isCalculated()) {
                result.add(field.getName());
            }
        }
        return result;
    }

    /**
     * @description Get init data for the component
     * @param objectTypeName API name of object
     * @param fieldSetName Name of the fieldset
     * @return List of fieldset fields
     */
    private static List<DataField> getFieldSetMembers(String objectTypeName,
        String fsPartOne, String fsPartTwo) {
        
        List<DataField> result = new List<DataField>();
        Set<String> editableFields = getEditableFields(objectTypeName);
        List<DescribeSObjectResult> describes = Schema.describeSObjects(new List<String>{
            objectTypeName
        });
        List<FieldSetMember> fields = new List<FieldSetMember>();
        if (describes != null && describes.size() > 0) {
            for (Schema.FieldSet item : describes[0].fieldSets.getMap().values()) {
                if (item.getLabel().toLowerCase() == fsPartOne.toLowerCase()) {
                    fields = item.getFields();
                }
                if (item.getLabel().toLowerCase() == (fsPartOne+'-'+fsPartTwo).toLowerCase()) {
                    fields = item.getFields();
                    break;
                }
            }
        }
        for (FieldSetMember item : fields) {
            result.add(
                new DataField(
                    item.getFieldPath(),
                    item.getLabel(),
                    item.getType(),
                    item.getRequired(),
                    editableFields.contains(item.getFieldPath())
                )
            );
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
     * @description Wrapper class with Object data
     */
    public class DataObject {
        public SObject record;
        public List<DataField> fields;
    }

    /**
     * @description Wrapper class for fields
     */
    public class DataField {
        public String name;
        public String label;
        public Schema.DisplayType type;
        public Boolean required;
        public Boolean editable;
        public Object value;

        public DataField(String name, String label, Schema.DisplayType type, Boolean required, Boolean editable) {
            this.name = name;
            this.label = label;
            this.type = type;
            this.required = required;
            this.editable = editable;
        }
    }
    
}