/**
 * @description Selector class for Account object.
 * This class provides methods to retrieve Account records.
 * @author Ofentse Sacha
 * @date May 2023
 */
public with sharing class ICS_SEL_Account extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_Account class.
     */
    public ICS_SEL_Account() {
        super();
    }

    /**
     * @description Retrieves an Account record based on the provided Account ID.
     * @param accID The ID of the Account
     * @return The Account object associated with the ID
     */
    public Account getAccount(String accID) {
        List<Schema.SObjectField> fields = getSObjectFieldList();
        String fieldNames = getFieldNames(fields);
        Account acc = Database.query('SELECT ' + fieldNames + ' FROM Account WHERE Id = :accID');
        return acc;
    }

    /**
     * @description Retrieves a list of Account fields dynamically.
     * @return List of Schema.SObjectField objects representing the fields of the Account object
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        Set<String> fieldNames = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet();
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        for (String fieldName : fieldNames) {
            fieldList.add(Account.SObjectType.getDescribe().fields.getMap().get(fieldName));
        }

        return fieldList;
    }

    /**
     * @description Converts a list of Schema.SObjectField objects to a comma-separated string of field names.
     * @param fields List of Schema.SObjectField objects
     * @return String of comma-separated field names
     */
    public String getFieldNames(List<Schema.SObjectField> fields) {
        String fieldNames = '';
        for (Schema.SObjectField field : fields) {
            if (fieldNames != '') {
                fieldNames += ', ';
            }
            fieldNames += field.getDescribe().getName();
        }
        return fieldNames;
    }

    /**
     * @description Retrieves a list of Account records associated with a given Application ID in the context of Other Business Interests.
     * @param appID The ID of the Application
     * @return List of Account objects associated with the Application
     */
    public List<Account> getOtherBusinessList(String appID) {
        return (List<Account>)Database.query('SELECT ' + getFieldNames(getSObjectFieldList()) + ' FROM Account WHERE Application_Other_Business_Interests__c = :appID');
    }
    
    /**
     * @description Returns the SObjectType of the Account object.
     * @return The SObjectType of the Account object
     */
    public override Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }
}