/**
 * @description                 : helper for Flow ICS_Flow_QueryHelper
 * @story 		                : SFP-34725 Flow helper to query related records
 * @author                      : Ofentse sacha
 * @date                        : 2024-03-20
 * @last modified on            : 2024-03-20
 * @last modified by            : Ikyatha Naidu
 * @modification description    : Created
 */
public without sharing class ICS_Flow_QueryHelper extends sbgplatform.fflib_SObjectSelector {
    public  String sObjectName;

    public ICS_Flow_QueryHelper(String sObjectName) {
        this.sObjectName = sObjectName;
    }
    /**
     * @description Retrieves the SObjectType dynamically.
     * @return The SObjectType based on the dynamic object name.
     */
    public override Schema.SObjectType getSObjectType() {
        return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getSObjectType();
    }

    /**
     * @description Retrieves the list of SObjectFields dynamically.
     * @return The list of SObjectFields for the dynamic SObject.
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>(Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values());
    }
    @InvocableMethod(label = 'Fetch Records for IDs')
    public static List<Output> fetchRecords(List<Input> params) {
        Map<String, List<String>> objectToIdsMap = groupIdsByObject(params);
        Map<String, String> objectToRelationshipMap = getRelationshipMap(params);
        
        List<Output> outputs = new List<Output>();
        for (String objectName : objectToIdsMap.keySet()) {
            outputs.add(processObjectRecords(objectName, objectToIdsMap.get(objectName), objectToRelationshipMap.get(objectName)));
        }
        
        return outputs;
    }
    
    private static Map<String, List<String>> groupIdsByObject(List<Input> params) {
        Map<String, List<String>> objectToIdsMap = new Map<String, List<String>>();
        for (Input param : params) {
            if (param.ids != null && !param.ids.isEmpty()) {
                String objectName = getObjectName(param.ids[0]);
                if (!objectToIdsMap.containsKey(objectName)) {
                    objectToIdsMap.put(objectName, new List<String>());
                }
                objectToIdsMap.get(objectName).addAll(param.ids);
            }
        }
        return objectToIdsMap;
    }
    
    private static Map<String, String> getRelationshipMap(List<Input> params) {
        Map<String, String> objectToRelationshipMap = new Map<String, String>();
        for (Input param : params) {
            if (param.ids != null && !param.ids.isEmpty()) {
                String objectName = getObjectName(param.ids[0]);
                objectToRelationshipMap.put(objectName, param.relationshipName);
            }
        }
        return objectToRelationshipMap;
    }
    
    private static Output processObjectRecords(String objectName, List<String> ids, String relationshipName) {
        sbgplatform.fflib_QueryFactory mainQueryFactory = buildMainQuery(objectName, ids);
        addRelatedQuery(mainQueryFactory, objectName, relationshipName);
        
        List<SObject> parentRecords = Database.query(mainQueryFactory.toSOQL());
        List<SObject> relatedRecords = getRelatedRecords(parentRecords, relationshipName);
        
        Output output = new Output();
        output.parentRecords = parentRecords;
        output.relatedRecords = relatedRecords;
        return output;
    }
    
    private static sbgplatform.fflib_QueryFactory buildMainQuery(String objectName, List<String> ids) {
       
        sbgplatform.fflib_QueryFactory mainQueryFactory = new sbgplatform.fflib_QueryFactory(Schema.getGlobalDescribe().get(objectName));
        if(ids.isEmpty()==false){
        mainQueryFactory.setCondition('Id IN :ids');
        }
        mainQueryFactory.selectFields(getObjectFields(objectName));
        return mainQueryFactory;
    }
    
    private static void addRelatedQuery(sbgplatform.fflib_QueryFactory mainQueryFactory, String objectName, String relationshipName) {
        if (relationshipName != null) {
            String relatedObjectName = getRelatedObjectName(objectName, relationshipName);
            if (relatedObjectName != null) {
                sbgplatform.fflib_QueryFactory relatedQueryFactory = mainQueryFactory.subselectQuery(relationshipName);
                relatedQueryFactory.selectFields(getObjectFields(relatedObjectName));
            }
        }
    }
    
    private static List<SObject> getRelatedRecords(List<SObject> parentRecords, String relationshipName) {
        List<SObject> relatedRecords = new List<SObject>();
        if (relationshipName != null) {
            for (SObject parentRecord : parentRecords) {
                List<SObject> related = (List<SObject>) parentRecord.getSObjects(relationshipName);
                if (related != null) {
                    relatedRecords.addAll(related);
                }
            }
        }
        return relatedRecords;
    }

    private static String getObjectName(String objId) {
        return ((Id)objId).getSObjectType().getDescribe().getName();
    }

    private static String getRelatedObjectName(String objectName, String relationshipName) {
        DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(objectName).getDescribe();
        for (Schema.ChildRelationship rel : dsr.getChildRelationships()) {
            if (rel.getRelationshipName() != null && rel.getRelationshipName().equalsIgnoreCase(relationshipName)) {
                return rel.getChildSObject().getDescribe().getName();
            }
        }
        return null;
    }

    private static List<String> getObjectFields(String objectName) {
        List<String> fields = new List<String>();
        for (Schema.SObjectField field : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()) {
            fields.add(field.getDescribe().getName());
        }
        return fields;
    }

    public class Input {
        @InvocableVariable(label = 'List of IDs')
        public List<String> ids;

        @InvocableVariable(label = 'Relationship Name')
        public String relationshipName;
    }

    public class Output {
        @InvocableVariable(label = 'Parent Records')
        public List<sObject> parentRecords;

        @InvocableVariable(label = 'Related Records')
        public List<sObject> relatedRecords;
    }
}