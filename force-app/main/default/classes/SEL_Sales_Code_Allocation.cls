/**
 * @description Selector class for Sales_Code_Allocation__c object.
 * This class provides methods to retrieve Sales_Code_Allocation__c records.
 * @author Ofentse Sacha
 * @date 07 November 2023
  * Modification Description : SFP-30363, This class provides methods to retrieve Sales_Code_Allocation__c records SBO UK
 */
public with sharing class SEL_Sales_Code_Allocation extends sbgplatform.fflib_SObjectSelector {
    

    /**
     * @description Retrieves the SObjectType for Sales_Code_Allocation__c.
     * @return The SObjectType for Sales_Code_Allocation__c
     */
    public override Schema.SObjectType getSObjectType() {
        return Sales_Code_Allocation__c.SObjectType;
    }

    /**
     * @description Retrieves the list of SObjectFields for Sales_Code_Allocation__c.
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return Sales_Code_Allocation__c.SObjectType.getDescribe().fields.getMap().values();
    }
    
	
    /**
     * @description Retrieves a list of Sales_Code_Allocation__c records associated with a given sales allocation.
     * @param salesCodeid
     * @return List<Sales_Code_Allocation__c>
     */
    public List<Sales_Code_Allocation__c> getAllocationbyIds(set<String> salesCodeid) {
        List<Sales_Code_Allocation__c> allocationList = new List<Sales_Code_Allocation__c>();
        allocationList = Database.query('SELECT ' + getFieldListString() + ' ,Sales_Codes__r.id,Sales_Codes__r.Name FROM Sales_Code_Allocation__c WHERE Sales_Codes__c in :salesCodeid');
        return allocationList;
    }
    /**
     * @description Retrieves a list of Sales_Code_Allocation__c records associated with a given Opportunity ID.
     * @param userID
     * @return List of Sales_Code_Allocation__c objects associated with the Opportunity
     */
    public List<Sales_Code_Allocation__c> getAllocatedCodesByUserId(String userID) {
        return (List<Sales_Code_Allocation__c>) Database.query('SELECT ' + getFieldListString() + ' FROM Sales_Code_Allocation__c WHERE User__c = :userID');
    }
    /**
     * @description Retrieves a list of Sales_Code_Allocation__c records associated with a given Opportunity ID.
     * @param userID
     * @return List of Sales_Code_Allocation__c objects associated with the Opportunity
     */
    public List<Sales_Code_Allocation__c> selectByUserIds(List<id> userIDs) {
        return (List<Sales_Code_Allocation__c>) Database.query('SELECT ' + getFieldListString() + ' FROM Sales_Code_Allocation__c WHERE User__c In :userIDs');
    }
    
}