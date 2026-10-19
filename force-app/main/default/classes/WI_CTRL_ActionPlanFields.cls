/**
 * @description Controller for the LWC wi_comp_actionPlanFields
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/04
 */
public with sharing class WI_CTRL_ActionPlanFields {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(WI_CTRL_ActionPlanFields.class.getName());
    
    /**
     * @description Get init data for the component
     * @param recordId Id of the record
     * @return Wrapper class with init data
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse getData(Id recordId) {
        String objectName = Case.SObjectType.getDescribe().getName();
        Map<String, Schema.SObjectField> caseFields = getFields(objectName);
        Schema.SObjectField currentField;
        Schema.DescribeFieldResult field;
        DataResponse result;
        DataObject data = new DataObject();
        List<GroupMember> cscMembers = new List<GroupMember>();
        List<String> authGroups = new List<String>();
        
        try {
            
            User user = new SEL_User().selectUsersByIds(new Set<Id> {UserInfo.getUserId()}).get(0);
            
            Relationship_Management_Settings__mdt countrySetting = DMN_RelationshipManagementSettings.getCountrySettings(user.User_Country__c);
            
            if (countrySetting == null) {
                throw new AuraHandledException('SETUP ERROR: Cannot find Relationship Management Settings for user from '+user.User_Country__c);
            }
            
            List<String> fieldNames = new List<String>(Case.sObjectType.getDescribe().fields.getMap().keySet());
            String query = 'SELECT SVC_ServiceType__r.Name, ' + String.join(fieldNames, ',');
            query += ' FROM Case';
            query += ' WHERE Id = :recordId';
            Case caseRecord = Database.query(query);
            if (String.valueOf(caseRecord.OwnerId).startsWith('005')) {
                cscMembers = [
                    SELECT Id, GroupId, UserOrGroupId 
                    FROM GroupMember WHERE (Group.DeveloperName = 'WI_CSCTeam_PG' OR Group.DeveloperName = 'WI_AccountMaintenanceCSC_PG')
                    AND UserOrGroupId  = :UserInfo.getUserId()
                ];
            }
            Set<Id> userIds = new Set<Id>();
            
            if (String.isNotBlank(countrySetting.Client_Authenticator_Groups__c)) {
                authGroups = countrySetting.Client_Authenticator_Groups__c.trim().split('\\s*,\\s*');
            }
            
            for (GroupMember item : [
                    SELECT Id, GroupId, UserOrGroupId 
                    FROM GroupMember 
            WHERE Group.DeveloperName IN :authGroups AND Group.Type = 'Regular'
                ]) {
                if (item.UserOrGroupId.getSobjectType() != Schema.User.SObjectType) continue;
                userIds.add(item.UserOrGroupId);
            }
            Map<Id, String> managers = new Map<Id, String>();
            for (User item : [
                    SELECT Id, Name
                    FROM User 
                    WHERE Id IN :userIds
                    ORDER BY Name DESC
                ]) {
                managers.put(item.Id, item.Name);
            }
            data.relationshipManagers = managers;
            List<ServiceTeamActionPlanTemplate__c> links = [
                SELECT Id, ActionPlanTemplate__r.Name,
                    (SELECT Id, FieldApiName__c, Required__c, QueueDevName__c
                    FROM FieldSetItems__r
                    WHERE ObjectApiName__c = :objectName
                    ORDER BY Order__c ASC)
                FROM ServiceTeamActionPlanTemplate__c
                WHERE ServiceTeam__c = :caseRecord.SVC_ServiceTeam__c
                ORDER BY ActionPlanTemplate__c
            ];
            List<DataSection> sections = new List<DataSection>();
            for (ServiceTeamActionPlanTemplate__c link : links) {
                DataSection section = new DataSection(link.ActionPlanTemplate__r.Name);
                List<DataField> fields = new List<DataField>();
                for (FieldSetItem__c item : link.FieldSetItems__r) {
                    currentField = caseFields.containsKey(item.FieldApiName__c) 
                        ? caseFields.get(item.FieldApiName__c) : caseFields.get(item.FieldApiName__c.toLowerCase());
                    if (currentField == null) continue;
                    field = getFieldInfo(currentField);
                    fields.add(
                        new DataField(
                            caseRecord.get(field.getName()),
                            field.getName(),
                            field.getLabel(),
                            field.getType(),
                            item.Required__c && ((cscMembers.size() > 0 && !String.isBlank(item.QueueDevName__c)) || String.isBlank(item.QueueDevName__c)),
                            (field.isUpdateable() && field.isCreateable() && !field.isCalculated())
                        )
                    );
                }
                section.fields = fields;
                sections.add(section);
            }
            data.sections = sections;
            data.isValueTransfer = caseRecord.SVC_ServiceType__c != null && ((String)WI_Settings__c.getInstance().WI_ValueTransferServiceTypes__c).contains(caseRecord.SVC_ServiceType__r.Name) && String.isBlank(caseRecord.WI_AuthManager__c) && (caseRecord.WI_RiskRating__c == 'High');
            result = new DataResponse(data);
        } catch (Exception ex) {
            result = new DataResponse(ex);
            LOGGER.error(ex.getMessage(), new String[] {'WI_CTRL_ActionPlanFields',ex.getMessage()}, ex);          
        }
        return result;
    }

    /**
     * @description Get fields on object
     * 
     * @param objectTypeName API name of object
     * @return Map<String, Schema.SObjectField> - fields api names
     */
    private static Map<String, Schema.SObjectField> getFields(String objectTypeName) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectTypeName).getDescribe().fields.getMap();
        return fields;
    }

    /**
    * @description Get metadata info for field 
    * 
    * @param currentField field api name
    * @return Schema.DescribeFieldResult - metadata info about a field
    */
    private static Schema.DescribeFieldResult getFieldInfo(Schema.SObjectField currentField){
        Schema.DescribeFieldResult fieldResult = currentField.getDescribe();
        return fieldResult;
    }


    /**
     * @description Wrapper class with response to LWC component 
     */
    @Testvisible
    private class DataResponse {
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
    private class DataObject {
        public Boolean isValueTransfer;
        public Map<Id, String> relationshipManagers;
        public List<DataSection> sections;
    }

    /**
     * @description Wrapper class for section
     */
    private class DataSection {
        public String name;
        public Boolean hasFields {
            get {
                return fields != null && fields.size() > 0;
            }
            set;
        }
        public List<DataField> fields;

        public DataSection(String name) {
            this.name = name;
        }
    }

    /**
     * @description Wrapper class for fields
     */
private class DataField {
        public String name;
        public String label;
        public Schema.DisplayType type;
        public Boolean required;
        public Boolean editable;
        public Boolean hidden;
        public Object value;

        public DataField(Object value, String name, String label, Schema.DisplayType type, Boolean required, Boolean editable) {
            this.value = value;
            this.name = name;
            this.label = label;
            this.type = type;
            this.required = required;
            this.editable = editable;
        }
    }
}