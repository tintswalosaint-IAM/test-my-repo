/*************************************************************************************
 * @description Field Selector Layer
 * @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
 * @date Oct 29th 2021
/***************************************************************************************selectFieldsBySection
* @last Modified By : Ikyatha Naidu
* @last Modified On :  06-06-2024
* @modification description: SFP-30128 updated  to latest version and added method to fetch child fieds
***************************************************************************************/
 
public inherited sharing class SEL_AOBField extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{
        'id', 
        'AOB_Placeholder__c', 
        'AOB_section__c',
        'AOB_ParentControllingValue__c', 
        'AOB_SFField__c' ,
        'AOB_pattern__c', 
        'AOB_ErrorMessage__c',
        'AOB_sequence__c' , 
        'Name', 
        'AOB_Label__c', 
        'AOB_Type__c', 
        'AOB_Required__c', 
        'AOB_Parent__c', 
        'AOB_Parent__r.AOB_Label__c',
        'AOB_Parent__r.SectionExternalID__c',
        'AOB_Parent__r.AOB_HelpText__c',
        'AOB_HelpText__c',
        'AOB_SFObject__c',
        'AOB_Values__c',
        'Default_Value__c',
        'AOB_Max_Length__c',
        'AOB_MinLength__c',
        'AOB_MRITable__c',
        'SectionExternalID__c',
        'AOB_Controlling_Field__c',
            'AOB_Parent__r.Name',
            'AOB_Parent__r.AOB_Parent__r.Name',
            'AOB_Parent__r.AOB_Parent__c',
            'AOB_Section__r.Name',
            ''
    };
    
    /**
     * @description get SObject Field List
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_Field__c.Name,
                AOB_Field__c.Id,
                AOB_Field__c.AOB_Placeholder__c,
                AOB_Field__c.AOB_section__c,
                AOB_Field__c.AOB_SFField__c,
                AOB_Field__c.AOB_pattern__c,
                AOB_Field__c.AOB_ErrorMessage__c,
                AOB_Field__c.AOB_Label__c,
                AOB_Field__c.AOB_Type__c,
                AOB_Field__c.AOB_Required__c,
                AOB_Field__c.AOB_Parent__c,
                AOB_Field__c.AOB_HelpText__c,
                AOB_Field__c.AOB_SFObject__c,
               AOB_Field__c.AOB_Values__c,
                AOB_Field__c.AOB_ParentControllingValue__c,
                AOB_Field__c.Default_Value__c,
                AOB_Field__c.AOB_Max_Length__c,
                AOB_Field__c.AOB_sequence__c,
                AOB_Field__c.AOB_MRITable__c,
                AOB_Field__c.AOB_Controlling_Field__c,
                AOB_Field__c.AOB_MinLength__c,
                AOB_Field__c.SectionExternalID__c

        };
    }

    /**
     * @description  selectById
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return AOB_Field__c.sObjectType;
    }

    /**
     * @description Select by sectionIds
     * @param ids 
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectFieldsBySection(Set<Id> ids ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_section__c in :ids');
        fieldQueryFactory.selectFields(fields);  
        fieldQueryFactory.setOrdering('AOB_sequence__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);  
    }

     /**
     * @description Select by sectionIds
     * @param ids 
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectFieldsByParentIds(Set<Id> ids ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_Parent__c in :ids');
        fieldQueryFactory.selectFields(fields);  
        fieldQueryFactory.setOrdering('AOB_sequence__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);  
    }

    /**
     * @description Select MRI Tables by language
     * @param  ids
     * @param language
     * @return List<AOB_Field__c>
     */
    public List<AOB_Field__c> selectMRITablesByLanguage(Set<Id> ids, String language) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_section__c in :ids AND AOB_Section__r.AOB_Screen__r.AOB_Language__c = :language');
        fieldQueryFactory.selectField('AOB_MRITable__c');  
          String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
     * @description Select MRI Tables by language
     * @param  ids
     * @param language
     * @return List<AOB_Field__c> 
     */
    public List<AOB_Field__c> selectMRITablesByParentNames(List<string> parentNameList, String sectionName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_section__r.Name = :sectionName AND AOB_Parent__r.Name=:parentNameList');
        fieldQueryFactory.selectField('AOB_MRITable__c'); 
        
                fieldQueryFactory.selectFields(fields);  
  String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}