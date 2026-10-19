/**
 * @description  Application Selector Class
 * @author November Sizwe
 * @date September 2022
 */

public with sharing class ICS_SEL_Application extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_Application class.
     */
    public ICS_SEL_Application() {
        super();
    }
    /**
     * @description Retrieves the SObjectType for Application__c.
     * @return The SObjectType for Application__c
     */
    public override Schema.SObjectType getSObjectType() {
        return Application__c.SObjectType;
    }
    /**
     * @description Retrieves the list of SObjectFields for Application__c.
     * @return The list of SObjectFields for Application__c
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return Application__c.SObjectType.getDescribe().fields.getMap().values();
    }

    /**
     * @description Retrieves a list of Application__c records associated with a given Opportunity ID.
     * @param oppID The ID of the Opportunity
     * @return List of Application__c objects associated with the Opportunity
     */
    public List<Application__c> getApplications(String oppID) {
        return (List<Application__c>) Database.query('SELECT ' + getFieldListString() + ' FROM Application__c WHERE Opportunity__c = :oppID');
    }
    
    
    /**
     * @description Retrieves a list of Application__c records associated with a given Opportunity ID, with converted currency.
     * @param oppID The ID of the Opportunity
     * @return List of Application__c objects associated with the Opportunity
     */
    public List<Application__c> getApplicationsConvertedCurrency(String oppID) {
        
        String soql = 'SELECT convertCurrency(First_Deposit_Amount__c), Frequency_Future_Deposits__c, ';  
               soql += 'Future_Deposits_Funded_From__c, Opportunity__c, Account__c ';
               soql += 'FROM Application__c WHERE Opportunity__c = :oppID';

        return (List<Application__c>) Database.query(soql);    
    }
}