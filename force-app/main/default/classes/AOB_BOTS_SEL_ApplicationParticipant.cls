/**
 * @description       : Selector Class for Application Participant Entity
 * @author            : Nagendraprasad Mylavarapu
 * @last modified on  : 03-08-2023
* @last modified by  : Ramya Gurram
* @ Modification Description : used new field AOB_Signing_Arrangement__c and remove nin number method
**/
@SuppressWarnings('PMD.SOQLInjection') 
public inherited sharing  class AOB_BOTS_SEL_ApplicationParticipant extends sbgplatform.fflib_SObjectSelector {

    private static Set<String> fields = new Set<String>{
        'AOB_AddressValidFrom__c',
        'Id', 
        'Name', 
        'CreatedDate', 
        'Application__c', 
        'Inflight__c',
        'AOB_TECH_OTPATTEMS__c',
        'CNGCU_Phone__c',
        'CNGCU_Email__c',
        'AOB_KeyContactPerson__c',
        'AOB_NotificationPreference__c',
        'AOB_Suburb__c',
        'AOB_Street__c',
        'AOB_PostalCode__c',
        'AOB_Role__c',
        'AOB_State__c',
        'AOB_City__c',
        'AOB_PreviousScreens__c',
        'AOB_PreviousScreen__c',
        'AOB_TransactOnTheBusiness__c',
        'Application__r.AOB_BCCEntityType__c',
        'Application__r.AOB_PortfolioNumber__c',
        'Application__r.AOB_BusinessLegalName__c',
        'Application__r.AOB_RegistrationNumber__c',
        'Application__r.AOB_GrossAnnualTurnover__c',
        
        'Application__r.AOB_Street__c',
        'Application__r.AOB_Signing_Arrangement__c',
        'Application__r.Inflight__c',
        'Application__r.AOB_Mode_Of_Payment__c',
        'Application__r.AOB_City__c',
        'Application__r.AOB_PostalCode__c',
        'Application__r.AOB_Preferred_Branch__c',
        'Application__r.AOB_Suburb__c',
        'Application__r.AOB_State__c',
        'Application__r.CNGCU_Email_Alerts__c',
        'Application__r.AOB_Schema_Code__c',
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
            'Application__r.AOB_GroupName__c',
           'Application__r.AOB_DateofRegistration__c',  
           'Application__r.AOB_EntityTypeCategory__c',
            'Application__r.AOB_Contribution__c',
            'Application__r.AOB_BotswanaCity__c',
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
            'AOB_Rely_Comply_Status__c',
            'AOB_DebitCard__c',
            'Botswana_City__c',
            'application__r.AOB_PrimaryRelationshipManagerID__c',
            'AOB_AddressValidFrom__c',
            'Application__r.AOB_IDIssuedOrganization__c'
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
            Application_Participant__c.CreatedDate, 
            Application_Participant__c.AOB_DebitCard__c,     
            Application_Participant__c.Application__c, 
            Application_Participant__c.Inflight__c,
            Application_Participant__c.AOB_TECH_OTPATTEMS__c,
            Application_Participant__c.CNGCU_Phone__c,
            Application_Participant__c.CNGCU_Email__c,
            Application_Participant__c.Application__r.CreatedById, 
            Application_Participant__c.Individual__r.Name,
            Application_Participant__c.AOB_KeyContactPerson__c,
            Application_Participant__c.AOB_Retry_Count__c,
            Application_Participant__c.AOB_Role__c,
            Application_Participant__c.CNGCU_Email__c,
            Application_Participant__c.AOB_FullName__c,
            Application_Participant__c.AOB_Signatory__c,
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
             Application_Participant__c.Botswana_City__c
            
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
     * @description Method to fetch list of Application Participants based on Application Ids
     * @param applicationIds
     * @return List<Application_Participant__c>
     */
    public List<Application_Participant__c> selectApplicationParticpantByApplicationId(String applicationIds) {
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
      * @param keyContact
     * @return List<Application_Participant__c>
     */
    public List<Application_Participant__c> selectApplicationParticpantByKeyContact(String applicationId, Boolean keyContact) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationId and AOB_KeyContactPerson__c=: keyContact');
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

        /**
     * @description Method to fetch list of Application Participants based on Application Ids
     * @param applicationId
     * @return List<Application_Participant__c>
     */
    public List<Application_Participant__c> selectApplicationParticpantByapplicationIdandsignatory(String applicationId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationId and (AOB_Signatory__c=true OR AOB_Director__c=true)');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    public List<Application_Participant__c> getCustomerDsxApllications(String applicationId) {
        return Database.query('select Id,AOB_MaritalStatus__c,AOB_IDNumber__c,AOB_CIFID__c,Application__c,Application__r.AOB_PrimaryRelationshipManagerID__c,AOB_Role__c,CNGCU_Email__c,AOB_FullName__c,AOB_External_GUID__c,(select Id,Document_Type__c,AOB_DateofExpiry__c,AOB_DSX__c from Application_Documents__r where AOB_DSX__c=true) from Application_Participant__c where Application__c =:applicationId');
    }

    public List<Application_Participant__c> getSvsSignatureApllications(String applicationId) {
        return Database.query('select Id,CreatedDate,AOB_MaritalStatus__c,AOB_IDNumber__c,AOB_CIFID__c,Application__c,AOB_Role__c,CNGCU_Email__c,AOB_FullName__c,AOB_External_GUID__c,(select Id,Document_Type__c from Application_Documents__r where Document_Type__c='+'upload signature'+') from Application_Participant__c where Application__c =:applicationId');
    }


}