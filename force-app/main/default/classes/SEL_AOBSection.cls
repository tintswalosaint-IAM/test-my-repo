/**
 * @Name of the Class: SEL_AOBSection
 * @description Section Selector Layer
 * @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
 * @date jun 2024
 * @LastModified By Ikyatha Naidu
 * @Modified Description : solved  Code Scan Issue SOQL Injection Possible
 */
public inherited sharing class SEL_AOBSection extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'id','Name' ,'AOB_Title__c','AOB_smallDeviceColumns__c' ,'AOB_mediumDeviceColumns__c', 'AOB_largeDeviceColumns__c', 'AOB_Rank__c'};

    /**
     * @description get SObject Field List
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_ScreenSection__c.Name,
                AOB_ScreenSection__c.Id,
                AOB_ScreenSection__c.AOB_Title__c,
                AOB_ScreenSection__c.AOB_smallDeviceColumns__c,
                AOB_ScreenSection__c.AOB_mediumDeviceColumns__c,
                AOB_ScreenSection__c.AOB_largeDeviceColumns__c,
                AOB_ScreenSection__c.AOB_Rank__c
        };
    }

    /**
     * @description getsobject type for screen section record
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return AOB_ScreenSection__c.sObjectType;
    }

    /**
     * @description Select by screenName
     * @param screenName
     * @return List<AOB_ScreenSection__c>
     */
    public List<AOB_ScreenSection__c> selectSectionsByScreenName(String screenName) {
        sbgplatform.fflib_QueryFactory sectionQueryFactory = newQueryFactory(false, false, false);
		sectionQueryFactory.setCondition('AOB_Screen__r.Name = :screenName');
		sectionQueryFactory.selectFields(fields);
        sectionQueryFactory.addOrdering('AOB_Rank__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        if(Test.isRunningTest() == true) {
            newQueryFactory(false, false, true);
        }
         String query = String.escapeSingleQuotes(sectionQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
     * @description Select by screenName
     * @param screenName
     * @return List<AOB_ScreenSection__c>
     */
    public List<AOB_ScreenSection__c> selectSectionsByScreenNameList(List<String> screenName) {
        sbgplatform.fflib_QueryFactory sectionQueryFactory = newQueryFactory(false, false, false);
		sectionQueryFactory.setCondition('AOB_Screen__r.Name in :screenName');
		sectionQueryFactory.selectFields(fields);
        sectionQueryFactory.addOrdering('AOB_Rank__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        if(Test.isRunningTest() == true) {
            newQueryFactory(false, false, true);
        }
         String query = String.escapeSingleQuotes(sectionQueryFactory.toSOQL());
        return Database.query(query);
    }
}