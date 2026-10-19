/**
 * @description       : Selector for Contact object
 * @author            : JogaRao Bevara
 * @group             : Selector
 * @last modified on  : 05-06-2025
 * @last modified by  : Ridhima Saxena
 * @Last Modified Reason  : Updated fields with AccountId
 * 
 * @last modified on  : 10-20-2025
 * @last modified by  : Jaco de Lange
 * @Modification Description : SFP-54086 - Updated fields with AccountId and Account.RecordType.DeveloperName
 ***************************************************
 * Last Modified By Madito Tsilo
 * Last Modified Date 07/04/2026
 * Last Modified Description: Added INS_SalesAgentANumber__c field to query
 * User Story : SFP-38441
**/
public inherited sharing class SEL_Contact extends sbgplatform.fflib_SObjectSelector {
     /**
    * @description declaration of fields| 30032026 Added field: INS_SalesAgentANumber__c
    * */
    private static Set<String> fields = new Set<String>{
    'Id','RecordTypeId','Ping_Id__c','AccountId','Name','WI_DualCitizenship__c','FinServ__PrimaryCitizenship__c', 'External_CIF_Country__c',
    'Title','LastName','FirstName','WI_ResidentialAddress__c','Email','Birthdate','FinServ__CountryOfBirth__c', 'INS_SalesAgentPortalLicenseType__c',
    'WI_Nationality__c','MailingAddress','FinServ__CountryOfResidence__c','MiddleName','WI_CountryOfCitizenship__c','FinServ__SecondaryCitizenship__c',
    'WI_NatureOfPublicOfficeRelationship__c','Description','WI_TelephoneNumberWork__c', 'CreatedBy.Email', 'CreatedBy.Name','WI_RelativeFirstName__c', 
        'Account.RecordType.Name','Account.RecordType.DeveloperName', 'RecordType.Name', 'Account.Name','INS_SalesAgentANumber__c','IsPersonAccount'};

    /**
    * @description Implementation method for Contact Object as part of fflib framework
    * @return Schema.SObjectType
    */
    public override Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }
       /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Id
        };
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param ids
    * @return List<Contact>
    **/
    public List<Contact> selectByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Accountid IN :accountIds');

        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param accountId and set of NatureOfPublicOfficeRelationship
    * @return List<Contact>
    **/
    public List<Contact> selectByRoleAndAccountId(String accountId,Set<String> roleName)  {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AccountId =:accountId AND WI_NatureOfPublicOfficeRelationship__c =: roleName');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param accountId and set of NatureOfPublicOfficeRelationship
    * @return List<Contact>
    **/
    public List<Contact> selectByAccountIdandRelativeName(String accountId,Set<String> roleName)  {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AccountId =:accountId AND  WI_RelativeFirstName__c=: roleName');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param contactId
    * @return List<Contact>
    **/
    public Contact selectById(String contactId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: contactId');

        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param email
    * @return List<Contact>
    **/
    public List<Contact> selectByEmail(String email) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Email =: email');

        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param email
    * @param recordtype
    * @return List<Contact>
    **/
    public List<Contact> selectByEmailandRecordTypeName(String email, string recordTypeName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Email =: email AND RecordType.Name=: recordTypeName');

        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of Contact based on Parameters
    * @param pingId
    * @return List<Contact>
    **/
    public List<Contact> selectByPingId(String pingId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Ping_Id__c =: pingId');

        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    public List<Contact> selectPersonContactByEmail(String personEmail){
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Email =: personEmail AND IsPersonAccount = true');

        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}