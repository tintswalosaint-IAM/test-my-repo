/**
 * @name of the class: SEL_ContactPointPhone
 * @description Selector Class for ContactPointPhone Entity
 * Story:SFP-30128
 * @author Ikyatha Naidu
 * @date 09/11/2023
 ***************************************************************
 * @last modified on  : 04-06-2024
 * @last modified by  : Ikyatha Naidu
 * @ Modification Description : updated to latest version
 */
public inherited sharing class SEL_ContactPointPhone extends sbgplatform.fflib_SObjectSelector {
    //Adding Fields
    private static Set<String> fields = new Set<String>{'Id','Areacode', 'UsageType', 'IsPrimary','TelephoneNumber','ParentId'};
    
    /**
     * @description Implementation method for ContactPointPhone Object as part of fflib framweork
     * @author Ikyatha Naidu
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return ContactPointPhone.sObjectType;
    }
    
    /**
     * @description Method to get list of fields to be part of response
     * @author Ikyatha Naidu
     * @return List<Schema.SObjectField>
     **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContactPointPhone.Id,
            ContactPointPhone.PhoneType,
            ContactPointPhone.ParentId,
            ContactPointPhone.TelephoneNumber
        };
    }
    
    /**
     * @description Method to fetch list of ContactPointPhone based on Parameters
     * @param recordID
     * @return List<ContactPointPhone>
     **/
    public List<ContactPointPhone> selectByParentId(String recordID) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false,false,false);
        if(recordID == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('ParentId = :recordID');
        }
        fieldQueryFactory.selectFields(fields);   
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Method to fetch list of ContactPointPhone based on Parameters
     * @param ids
     * @return List<ContactPointPhone>
     **/
    public List<ContactPointPhone> selectByParentIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false,false,false); 
        if(ids == null){
            return null;
        } else{
           fieldQueryFactory.setCondition('ParentId IN :ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Method to fetch list of ContactPointPhone based on Parameters
     * @param phone
     * @return List<ContactPointPhone>
     **/
    public List<ContactPointPhone> selectByTelephoneNumber(String phone) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false,false,false);
        if(phone == null){
            return null;
        }else{
           fieldQueryFactory.setCondition('TelephoneNumber = :phone');
        }
        fieldQueryFactory.selectFields(fields);  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}