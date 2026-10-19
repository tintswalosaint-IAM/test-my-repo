/**
* @description       : Selector Class for Application Participant Entity
* @author            : Nagendraprasad Mylavarapu
* @Name of the Class : BCB_CTRL_FormCreator
* @last modified on  : 05-04-2024
* @last modified by  : Ravi Myaka
* @Modification description : SFP-37302
**/
public inherited sharing class SEL_ApplicationParticipant extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{
        'Id', 
            'Name', 
            'CreatedDate', 
            'Application__c', 
            'RecordTypeId',
            'Inflight__c',
            'AOB_TECH_OTPATTEMS__c',
            'AOB_OTPAttempts__c',
            'CNGCU_Phone__c',
            'CNGCU_Email__c',
            'AOB_KeyContactPerson__c',
            'AOB_NotificationPreference__c',
            'AOB_Suburb__c',
            'AOB_Street__c',
            'AOB_PostalCode__c',
            'AOB_previously_held_office__c',
            'AOB_Family_Previously_held_Office__c',
            'AOB_resident_outside_of_Primary_Country__c',
            'AOB_Card_Number__c',
            'AOB_Outside_of_Primary_Country__c',
            'AOB_City__c',
            'AOB_UG_BCB_District__c',
            'AOB_Street__c',
            'AOB_US_Related_Parties__c',
            'AOB_Role__c',
            'AOB_State__c',
            'AOB_Stage__c',
            'AOB_Preferred_Name__c',
            'AOB_City__c',
            'AOB_PreviousScreens__c',
            'AOB_PreviousScreen__c',
            'AOB_TransactOnTheBusiness__c',
            'AOB_Source_of_Funds__c',
            'Application__r.AOB_Stage__c',
            'Application__r.Status__c',
            'Application__r.AOB_Product__c',
            'Application__r.AOB_BCCEntityType__c',
            'Application__r.AOB_BusinessLegalName__c',
            'Application__r.AOB_RegistrationNumber__c',
            'Application__r.AOB_GrossAnnualTurnover__c',
            'Application__r.AOB_BCCEntityType__c',
            'Application__r.AOB_Street__c',
            'Application__r.Inflight__c',
            'Application__r.AOB_City__c',
            'Application__r.AOB_PostalCode__c',
            'Application__r.AOB_Preferred_Branch__c',
            'Application__r.AOB_Suburb__c',
            'Application__r.AOB_State__c',
            'Application__r.CNGCU_Email_Alerts__c',
            'Application__r.AOB_Schema_Code__c',
            'Application__r.AOB_Selected_Currency__c',
            'Application__r.AOB_PresenceinCountry__c',
            'Application__r.AOB_SigningInstructions__c',
            'Application__r.AOB_Notes__c', 
            'Application__r.AOB_ListedonanApprovedExchange__c',
            'Application__r.AOB_IncorporationDate__c',
            'Application__r.AOB_BusinessProceeds__c',
            'Application__r.AOB_ReturnsClassificationCode__c',
            'Application__r.AOB_IndustryClassificationSARBCode__c',
            'Application__r.AOB_Sectorcode__c',
            'Application__r.AOB_AddressValidFrom__c',
            'Application__r.Tax_Identification_Number__c',
            'Application__r.AOB_Document_Number__c',
            'Application__r.CNGCU_CSEmail__c',
            'Application__r.AOB_Phone__c',
            'Application__r.AOB_Marital_Status__c',
            'Application__r.Name',
            'AOB_Retry_Count__c',
            'AOB_IDNumber__c',
            'AOB_Role__c',
            'CNGCU_Email__c',
            'AOB_FullName__c',
            'AOB_Signatory__c',
            'AOB_CIFID__c',
            'AOB_Director__c',
            'CNGCU_Role__c',
            'AOB_Gender__c',
            'AOB_MaritalStatus__c',
            'AOB_Title__c',
            'AOB_DateofBirth__c',
            'AOB_PrimaryNationality__c',
            'AOB_Occupation__c',
            'AOB_GrossAnnualIncome__c',
            'AOB_MonthlyNetIncome__c',
            'AOB_External_GUID__c',
            'AOB_PEPStaus__c',
            'CNGCU_First_Name__c',
            'CNGCU_Last_Name__c',
            'AOB_National_ID_expiry_date__c',
            'AOB_Rely_Comply_Status__c',
            'CurrencyIsoCode',
            'Application_Product_Code__c'
            
            };
                
                
                
                /**
* @description Method to get list of fields to be part of response
* @author Nagendraprasad Mylavarapu | 03-07-2023 
* @return List<Schema.SObjectField> 
**/
                public override List<Schema.SObjectField> getSObjectFieldList() {
                    return new List<Schema.SObjectField> {
                        Application_Participant__c.Id, 
                            Application_Participant__c.Name, 
                            
                            Application_Participant__c.AOB_previously_held_office__c, 
                            Application_Participant__c.AOB_Family_Previously_held_Office__c, 
                            Application_Participant__c.AOB_resident_outside_of_Primary_Country__c, 
                            Application_Participant__c.AOB_Outside_of_Primary_Country__c, 
                            Application_Participant__c.AOB_City__c, 
                            Application_Participant__c.AOB_UG_BCB_District__c, 
                            Application_Participant__c.AOB_Street__c, 
                            Application_Participant__c.AOB_US_Related_Parties__c, 
                            Application_Participant__c.AOB_National_ID_expiry_date__c, 
                            Application_Participant__c.CreatedDate, 
                            Application_Participant__c.Application__c, 
                            Application_Participant__c.AOB_Preferred_Name__c, 
                            Application_Participant__c.Inflight__c,
                            Application_Participant__c.AOB_TECH_OTPATTEMS__c,
                            Application_Participant__c.AOB_OTPAttempts__c,
                            Application_Participant__c.CNGCU_Phone__c,
                            Application_Participant__c.CNGCU_Last_Name__c,
                            Application_Participant__c.CNGCU_Email__c,
                            Application_Participant__c.RecordTypeId,
                            Application_Participant__c.Application__r.CreatedById, 
                            Application_Participant__c.Individual__r.Name,
                            Application_Participant__c.AOB_KeyContactPerson__c,
                            Application_Participant__c.AOB_Retry_Count__c,
                            Application_Participant__c.AOB_Role__c,
                            Application_Participant__c.AOB_Stage__c,
                            Application_Participant__c.CNGCU_Email__c,
                            Application_Participant__c.AOB_FullName__c,
                            Application_Participant__c.AOB_Signatory__c,
                            Application_Participant__c.CNGCU_First_Name__c,
                            Application_Participant__c.AOB_CIFID__c,
                            Application_Participant__c.AOB_IDNumber__c,
                            Application_Participant__c.AOB_PreviousScreens__c,
                            Application_Participant__c.AOB_PreviousScreen__c,
                            Application_Participant__c.AOB_Director__c,
                            Application_Participant__c.CNGCU_Role__c,
                            Application_Participant__c.AOB_Gender__c,
                            Application_Participant__c.AOB_MaritalStatus__c,
                            Application_Participant__c.AOB_Title__c,
                            Application_Participant__c.AOB_DateofBirth__c,
                            Application_Participant__c.AOB_PrimaryNationality__c, 
                            Application_Participant__c.AOB_Occupation__c,
                            Application_Participant__c.AOB_GrossAnnualIncome__c,
                            Application_Participant__c.AOB_MonthlyNetIncome__c,
                            Application_Participant__c.AOB_External_GUID__c,
                            Application_Participant__c.AOB_PEPStaus__c,
                            Application_Participant__c.AOB_Rely_Comply_Status__c,
                            Application_Participant__c.AOB_Card_Number__c,
                            Application_Participant__c.CurrencyIsoCode,
                            Application_Participant__c.Application_Product_Code__c
                            };
                                }
    
    
    /**
* @description Implementation method for Application Participant Object as part of fflib framweork
* @author Nagendraprasad Mylavarapu | 03-07-2023 
* @return Schema.SObjectType 
**/
    public override Schema.SObjectType getSObjectType() {
        return Application_Participant__c.sObjectType;
    }
    
    
    /**
* @description Method to fetch list of Application Participants based on List<Id>
* @param nationalIDNumber
* @param inProgress
* @param productCode
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> findParticipantByNIN(String nationalIDNumber, String inProgress, String productCode) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_IDNumber__c =:nationalIDNumber and Application__r.Status__c =:inProgress AND Application__r.AOB_Schema_Code__c = :productCode');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
* @description Method to fetch list of Application Participants based on List<Id>
* @param participantIds
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> selectApplicationParticipantById(List<Id> participantIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id in :participantIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch list of Application Participants based on String id
* @param participantIds
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> selectApplicationParticpantById(String participantIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =:participantIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch list of Application Participants based on Id
* @param participantId
* @return List<Application_Participant__c>
*/
    public Application_Participant__c selectApplicationParticipant(String participantId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =:participantId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch Application Participants based on Application Ids
* @param applicationIds
* @return Application_Participant__c
*/
    public Application_Participant__c selectApplicationParticpantByApplicationId(String applicationIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch list of Application Participants based on Application Name
* @param applicationName
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> selectApplicationParticpantByApplicationName(String applicationName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__r.Name = :applicationName');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch list of Application Participants based on Application Ids AND AOB_Signatory__c
* @param applicationId
* @param signatory
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> selectApplicationParticpantByApplicationIdSign(String applicationId, Boolean signatory) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationId and AOB_Signatory__c=: signatory');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
* @description Method to fetch list of Application Participants based on Application Ids AND AOB_Signatory__c
* @param applicationId
* @param phone
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> selectApplicationParticpantByAppAndPhone(String applicationId, String phone) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationId and CNGCU_Phone__c=: phone');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch list of Application Participants based on Application Ids AND AOB_KeyContactPerson__c
* @param applicationId
* @return List<Application_Participant__c>
*/
    public List<Application_Participant__c> selectApplicationParticpantByKeyContact(String applicationId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Method to fetch list of Application Participants based on Application Ids AND AOB_KeyContactPerson__c
* @param omangId
* @param applicationId
* @return List<Application_Participant__c>
*/
    public Application_Participant__c selectApplicationParticpantByOmangId(String omangId, String applicationId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationId and AOB_IDNumber__c=: omangId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    } 
}