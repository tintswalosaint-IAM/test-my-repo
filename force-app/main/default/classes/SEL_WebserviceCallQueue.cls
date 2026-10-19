/**
 * @ Description       : Class for Selector Class for SEL_WebserviceCallQueue 
 * @ Author            : Ridhima Saxena
 * @ Date              : 11-06-2025
 * @Story:SFP-50149
 */
public inherited sharing class SEL_WebserviceCallQueue extends sbgplatform.fflib_SObjectSelector {
    
    /**
    * @description declaration of fields
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'CMN_StatusCode__c',
        'CMN_Service__c',
        'CreatedById',
        'CreatedDate',
        'CMN_TriggeringObjectId__c'
    };

    /**
    * @description Implementation method for CMN_WebserviceCallQueue__c Object as part of fflib framework
    * @return Schema.SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return CMN_WebserviceCallQueue__c.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CMN_WebserviceCallQueue__c.Id,
            CMN_WebserviceCallQueue__c.CMN_StatusCode__c,
            CMN_WebserviceCallQueue__c.CMN_Service__c,
            CMN_WebserviceCallQueue__c.CreatedById
        };
    }

    /**
    * @description Method to fetch existing successful calls by service and user - matches your specific query
    * @param serviceName
    * @param userId
    * @return List<CMN_WebserviceCallQueue__c>
    */
    public List<CMN_WebserviceCallQueue__c> selectbyServiceUserandStatus(String status,String serviceName, String userId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        
       
        if(serviceName != null && userId != null) {
            fieldQueryFactory.setCondition('CMN_StatusCode__c = :status AND CMN_Service__c = :serviceName AND CreatedById = :userId');
        }
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);
        
        String query = fieldQueryFactory.toSOQL();
        return Database.query(query);
    }

   
}