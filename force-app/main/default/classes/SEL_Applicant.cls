/**
* @Name of the Class : SEL_Applicant
* @description       : SFP-37439 Selector Class for Applicant Entity
* @author            : Ikyatha Naidu
* @date 10-09-2023
* @last modified on  : 07-03-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* @Modification Description : updated to latest version
**/
public inherited sharing class SEL_Applicant extends sbgplatform.fflib_SObjectSelector {
    // declaration of fields
    
    private static Set<String> fields = new Set<String>{
        'Id',
        'Other_Surname__c',
        'Other_Names__c',
        'Other_First_Name__c',
        'Other__c',
        'Other_Middle_Name__c',
        'role',
        'Relationship_with_Applicants__c',
        'AccountId',
        'ApplicationFormId',
        'ApplicationForm.OpportunityId',
        'PartyProfile.CountryofBirth',
        'PartyProfileId',
        'PartyProfile.DateOfBirth',
        'PartyProfile.FirstName',
        'PartyProfile.LastName',
        'PartyProfile.MiddleName',
        'Account.PersonBirthdate',
        'Account.FirstName',
        'Account.LastName',
        'Account.MiddleName',
        'Account.FinServ__Gender__pc',
        'PartyProfile.Gender',
        'Account.Name',
        'Account.PersonEmail',
        'Account.PersonContactId',
        'PartyProfile.BirthDate__c',
        'PartyProfile.Country_of_Residence__c',
        'PartyProfile.Country_of_Nationality__c',
        'PartyProfile.WI_CountryOfCitizenship__c',
        'PartyProfile.Second_Country_of_Nationality__c',
        'PartyProfile.AccountId'
    };

    /**
    * @description Implementation method for Account Object as part of fflib framweork
    * @author Ikyatha Naidu | 30-10-2023
    * @return Schema.SObjectType
    **/
    public override Schema.SObjectType getSObjectType() {
        return Applicant.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @author Ikyatha Naidu| 05-31-2023
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Applicant.Account.FirstName,
            Applicant.Account.LastName,
            Applicant.Account.MiddleName,
            Applicant.Account.Name,
            Applicant.AccountId,
            Applicant.ApplicationFormId,
            Applicant.ApplicationForm.Opportunity.Id,
            Applicant.Id,
            Applicant.Other_Surname__c,
            Applicant.Other_Names__c,
            Applicant.Other_First_Name__c,
            Applicant.Other_Middle_Name__c,
            Applicant.PartyProfileId,
            Applicant.PartyProfile.FirstName,
            Applicant.PartyProfile.LastName,
            Applicant.PartyProfile.MiddleName,
            Applicant.Id,
            Applicant.Account.FirstName,
            Applicant.Account.LastName,
            Applicant.Account.MiddleName,
            Applicant.Account.Name,
            Applicant.role
        };
    }

    /**
    * @description Method to fetch list of applicants based on Parameters
    * @param accountId
    * @return Applicant
    **/
    public Applicant selectByAccountId(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountId == null){
            return null;
        }
         fieldQueryFactory.setCondition('accountId = :accountId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch Applicant based on id
    * @param applicantId
    * @return Applicant
    **/
    public Applicant selectById(String applicantId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(applicantId == null){
            return null;
        }
        fieldQueryFactory.setCondition('Id = :applicantId');
        fieldQueryFactory.selectFields(fields);
		String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch list of Applicant based on Parameters
    * @param partyProfileId
    * @return Applicant
    **/
    public Applicant selectByPartyProfileId(String partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(partyProfileId == null){
            return null;
        }
        fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch list of Applicant based on Opportunity
    * @param opportunityIds
    * @return Applicant list
    **/
    public List<Applicant> selectPrimaryApplicantByOppIds(List<Id> opportunityIds) {
        String primaryApplicant = 'Primary Applicant';
        String primaryRole = '';

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(primaryApplicant != null && primaryRole != null){
            fieldQueryFactory.setCondition('(role = :primaryApplicant or role = :primaryRole) and ApplicationForm.OpportunityId IN :opportunityIds');
        }
        fieldQueryFactory.selectFields(fields);

        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch list of Applicant based on Parameters
    * @param applicationFormIds
    * @return Applicant List
    **/
    public List<Applicant> selectByApplicationFormIds(Set<Id> applicationFormIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(applicationFormIds == null){
            return null;
        }
       	fieldQueryFactory.setCondition('ApplicationFormId IN :applicationFormIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch list of Applicant based on Parameters
    * @param accountIds
    * @return Applicant List
    **/
    public List<Applicant> selectByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountIds == null){
            return null;
        }

        fieldQueryFactory.setCondition('AccountId IN :accountIds AND Account.PersonEmail != NULL');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
     }

    /**
    * @description Method to fetch list of Applicant based on Parameters
    * @param accountIds
    * @return Applicant List
    **/
    public List<Applicant> selectPrimaryApplicantByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String primaryRole='Primary Applicant';
        if(primaryRole != null){
            fieldQueryFactory.setCondition('AccountId IN :accountIds AND Account.PersonEmail != NULL AND (role = null or role = :primaryRole)');
        }
        fieldQueryFactory.selectFields(fields);
		String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
     }
}