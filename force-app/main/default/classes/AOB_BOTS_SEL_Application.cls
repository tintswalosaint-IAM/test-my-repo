/**
 * @description       : Selector Class for Application Entity
 * @author            : Nagendraprasad Mylavarapu
 * @last modified on  : 09-10-2024
 * @last modified by  : Dayakar
 * @Modification Description :SFP-38350
**/

public inherited sharing class AOB_BOTS_SEL_Application extends sbgplatform.fflib_SObjectSelector {

    private static Set<String> fields = new Set<String>{
        'Id',
        'CreatedDate', 
        'Name', 
        'AOB_Notes__c', 
        'AOB_Lead_Owner__c', 
        'AOB_NIN__c', 
        'AOB_Title__c', 
        'AOB_LastName__c', 
        'AOB_Gender__c', 
        'Account__c', 
        'AOB_Employment_Type__c', 
        'AOB_Mode_Of_Payment__c', 
        'AOB_Nature_Of_Employment__c', 
        'AOB_Name_Of_Bank__c', 
        'AOB_Employer_Name__c', 
        'AOB_Employer_Address__c', 
        'AOB_Account_Number__c', 
        'AOB_Mobile_Money_Number__c', 
        'AOB_FirstName__c', 
        'AOB_Phone__c', 
        'AOB_Email__c', 
        'AOB_UTM_Campaign__c', 
        'AOB_UTM_Medium__c', 
        'AOB_UTM_Source__c', 
        'AOB_Lead__c', 
        'AOB_DOB__c', 
        'AOB_Current_Address_Street__c', 
        'Application_Stages__c', 
        'AOB_Institution__c', 
        'AOB_Study_Year__c', 
        'AOB_Course_Name__c', 
        'AOB_Customer_Id__c', 
        'AOB_Current_Address_PostalCode__c', 
        'Are_your_US_tax_affairs_up_to_date__c', 
        'Awareness_of_US_Tax_obligations__c', 
        'AOB_Street__c', 
        'Bank_Country__c', 
        'AOB_PostalCode__c', 
        'AOB_Marital_Status__c', 
        'AOB_PEP_Status__c', 
        'AOB_Sanction_Status__c', 
        'AOB_Risk_Score_Status__c', 
        'AOB_Risk_Score_Rating__c', 
        'AOB_Country__c', 
        'AOB_Current_Address_Country__c', 
        'AOB_City__c', 
        'AOB_Current_Address_City__c', 
        'Card_Delivery_Option__c', 
        'AOB_Nationality__c', 
        'AOB_IP_Address__c', 
        'AOB_Device_Details__c', 
        'AOB_Liveness_Matched__c', 
        'Code_Word__c', 
        'AOB_Liveness_Score__c', 
        'AOB_Monthly_Income_in_UGX__c', 
        'AOB_Preferred_Branch__c', 
        'AOB_State__c', 
        'AOB_Current_Address_State__c', 
        'AOB_Referal_Code__c', 
        'AOB_Selected_Currency__c', 
        'AOB_Product__c', 
        'AOB_Schema_Code__c', 
        'AOB_MNO_Customer_Name__c', 
        'AOB_Occupation__c', 
        'AOB_Accommodation_Type__c', 
        'AOB_Email_Type__c', 
        'AOB_Phone_Type__c', 
        'AOB_Pricing_Option__c', 
        'AOB_Consent_Status__c', 
        'AOB_County__c', 
        'AOB_Current_Address_County__c', 
        'AOB_Address_From_Date__c', 
        'AOB_Current_Address_From_Date__c', 
        'AOB_Operator_Name__c', 
        'AOB_Alternative_Account_Number__c', 
        'AOB_Alternative_Account_Name__c', 
        'AOB_Sector__c', 
        'AOB_Subsector__c', 
        'AOB_Sectorcode__c', 
        'AOB_Fund_Amount__c', 
        'AOB_Identifii_Expire_Date__c', 
        'AOB_Identifii_Issued_Date__c', 
        'AOB_Document_Number__c', 
        'AOB_Personal_Information_Consent__c', 
        'AOB_Services_Special_Offers_Consent__c', 
        'AOB_Research_Consent__c', 
        'AOB_Market_Your_Product_Consent__c', 
        'AOB_Address_Line3__c', 
        'AOB_Stage__c', 
        'AOB_Current_Address_Same_As_Address__c', 
        'AOB_Have_Referral_Code__c', 
        'AOB_Are_you_a_PEP__c', 
        'AOB_Current_Address_Line3__c', 
        'Customer_Data_Usage__c', 
        'Customer_Instruct_Declaration__c', 
        'Date_you_moved_to_this_address__c', 
        'Delivery_Address_Line_1__c', 
        'Delivery_Address_Line_2__c', 
        'Delivery_Address_Line_3__c', 
        'Delivery_Address_Line_4__c', 
        'Delivery_Country__c', 
        'Delivery_Postcode__c', 
        'Delivery_Province__c', 
        'Expected_Annual_Yearly_Turnover_From__c', 
        'Expected_Annual_Yearly_Turnover_To__c', 
        'Favorite_Sport_or_Colour__c', 
        'ICS_Is_main_Applicant__c', 
        'ICS_Is_the_applicant_a_refugee__c', 
        'Independent_tax_advice_received__c', 
        'Intention_for_Non_US_Resident_to_return__c', 
        'Keep_You_Informed_About_Product__c', 
        'Keep_You_Informed_About__c', 
        'National_Insurance__c', 
        'Opportunity__c', 
        'Other_Identification_Number__c', 
        'Status__c', 
        'The_Same_as_Current_Address__c', 
        'US_Resident_Confirmation__c', 
        'Currency_Test_Formula__c', 
        'Initial_Deposits__c', 
        'SOF_Future_Deposit__c', 
        'AOB_MNO_Name_Matched__c', 
        'AOB_Other_Name__c', 
        'AOB_Status__c', 
        'CNGCU_Email_Alerts__c', 
        'Inflight__c',
        'AOB_RegistrationNumber__c',
        'AOB_GroupName__c',
        'AOB_DateofRegistration__c',
        'AOB_Contribution__c',
        'AOB_SigningInstructions__c',
        'AOB_IntendeduseofAccount__c',
        'AOB_DateofResolutionMeeting__c',
        'AOB_BCCEntityType__c',
        'AOB_PresenceinCountry__c',
        'AOB_ListedonanApprovedExchange__c',
        'AOB_IncorporationDate__c',
         'AOB_BusinessProceeds__c',
         'AOB_ReturnsClassificationCode__c',
         'AOB_IndustryClassificationSARBCode__c',
         'AOB_AddressValidFrom__c',
         'Entity_Type_Sub_Category__c',
         'AOB_TertiarySICCode__c',
         'AOB_GUID__c',
          'AOB_Rely_Comply_Status__c',
          'AOB_CRAAssessment__c',
          'AOB_BusinessLegalName__c' ,
          'AOB_Signing_Arrangement__c',
          'AOB_GrossAnnualTurnover__c',
          'AOB_PortfolioNumber__c',
          'AOB_PrimaryRelationshipManagerID__c',
          'AOB_BotswanaCity__c',
          'AOB_CIFID__c'
    };
        
    /**
    * @description Implementation method for Application Object as part of fflib framweork
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return Application__c.sObjectType;
    }
    /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldListHelper() {
        return new List<Schema.SObjectField> {
            Application__c.Id, 
            Application__c.OwnerId, 
            Application__c.IsDeleted, 
            Application__c.Name, 
            Application__c.CurrencyIsoCode, 
            Application__c.RecordTypeId, 
            Application__c.CreatedDate, 
            Application__c.CreatedById, 
            Application__c.LastModifiedDate, 
            Application__c.LastModifiedById, 
            Application__c.SystemModstamp, 
            Application__c.LastActivityDate, 
            Application__c.LastViewedDate, 
            Application__c.LastReferencedDate, 
            Application__c.AOB_Notes__c, 
            Application__c.AOB_Lead_Owner__c, 
            Application__c.AOB_NIN__c, 
            Application__c.AOB_Title__c, 
            Application__c.AOB_LastName__c, 
            Application__c.AOB_Gender__c, 
            Application__c.Account__c, 
            Application__c.AOB_Employment_Type__c, 
            Application__c.AOB_Mode_Of_Payment__c, 
            Application__c.AOB_Nature_Of_Employment__c, 
            Application__c.AOB_Name_Of_Bank__c, 
            Application__c.AOB_Employer_Name__c, 
            Application__c.AOB_Employer_Address__c, 
            Application__c.AOB_Account_Number__c, 
            Application__c.AOB_Mobile_Money_Number__c, 
            Application__c.AOB_FirstName__c, 
            Application__c.AOB_Phone__c, 
            Application__c.AOB_Email__c, 
            Application__c.AOB_UTM_Campaign__c, 
            Application__c.AOB_UTM_Medium__c, 
            Application__c.AOB_UTM_Source__c, 
            Application__c.AOB_Lead__c, 
            Application__c.AOB_DOB__c, 
            Application__c.AOB_Current_Address_Street__c, 
            Application__c.Application_Stages__c, 
            Application__c.AOB_Institution__c, 
            Application__c.AOB_Study_Year__c, 
            Application__c.AOB_Course_Name__c, 
            Application__c.AOB_Customer_Id__c, 
            Application__c.AOB_Current_Address_PostalCode__c, 
            Application__c.Are_your_US_tax_affairs_up_to_date__c, 
            Application__c.Awareness_of_US_Tax_obligations__c, 
            Application__c.AOB_Street__c, 
            Application__c.Bank_Country__c, 
            Application__c.AOB_PostalCode__c, 
            Application__c.AOB_Marital_Status__c, 
            Application__c.AOB_PEP_Status__c, 
            Application__c.AOB_Sanction_Status__c, 
            Application__c.AOB_Risk_Score_Status__c, 
            Application__c.AOB_Risk_Score_Rating__c, 
            Application__c.AOB_Country__c, 
            Application__c.AOB_Current_Address_Country__c, 
            Application__c.AOB_City__c, 
            Application__c.AOB_Current_Address_City__c, 
            Application__c.Card_Delivery_Option__c, 
            Application__c.AOB_Nationality__c, 
            Application__c.AOB_IP_Address__c, 
            Application__c.AOB_Device_Details__c, 
            Application__c.AOB_Liveness_Matched__c,
            Application__c.AOB_Liveness_Matched__c, 
            Application__c.Code_Word__c, 
            Application__c.AOB_Liveness_Score__c, 
            Application__c.AOB_Monthly_Income_in_UGX__c, 
            Application__c.AOB_Preferred_Branch__c, 
            Application__c.AOB_State__c, 
            Application__c.AOB_Current_Address_State__c, 
            Application__c.AOB_Referal_Code__c, 
            Application__c.AOB_Selected_Currency__c, 
            Application__c.AOB_Product__c, 
            Application__c.AOB_Schema_Code__c, 
            Application__c.AOB_MNO_Customer_Name__c, 
            Application__c.AOB_Occupation__c
        };
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField>  returnList = new List<Schema.SObjectField> ();
        returnList.addAll(getSObjectFieldListHelper());
        returnList.addAll(new List<Schema.SObjectField> { 
            Application__c.AOB_Accommodation_Type__c, 
            Application__c.AOB_Email_Type__c, 
            Application__c.AOB_Phone_Type__c, 
            Application__c.AOB_Pricing_Option__c, 
            Application__c.AOB_Consent_Status__c, 
            Application__c.AOB_County__c, 
            Application__c.AOB_Current_Address_County__c, 
            Application__c.AOB_Address_From_Date__c, 
            Application__c.AOB_Current_Address_From_Date__c, 
            Application__c.AOB_Operator_Name__c, 
            Application__c.AOB_Alternative_Account_Number__c, 
            Application__c.AOB_Alternative_Account_Name__c, 
            Application__c.AOB_Sector__c, 
            Application__c.AOB_Subsector__c, 
            Application__c.AOB_Sectorcode__c, 
            Application__c.AOB_Fund_Amount__c, 
            Application__c.AOB_Identifii_Expire_Date__c, 
            Application__c.AOB_Identifii_Issued_Date__c, 
            Application__c.AOB_Document_Number__c, 
            Application__c.AOB_Personal_Information_Consent__c, 
            Application__c.AOB_Services_Special_Offers_Consent__c, 
            Application__c.AOB_Research_Consent__c, 
            Application__c.AOB_Market_Your_Product_Consent__c, 
            Application__c.AOB_Address_Line3__c, 
            Application__c.AOB_Stage__c, 
            Application__c.AOB_Current_Address_Same_As_Address__c, 
            Application__c.AOB_Have_Referral_Code__c, 
            Application__c.AOB_Are_you_a_PEP__c, 
            Application__c.AOB_Current_Address_Line3__c, 
            Application__c.Customer_Data_Usage__c, 
            Application__c.Customer_Instruct_Declaration__c, 
            Application__c.Date_you_moved_to_this_address__c, 
            Application__c.Delivery_Address_Line_1__c, 
            Application__c.Delivery_Address_Line_2__c, 
            Application__c.Delivery_Address_Line_3__c, 
            Application__c.Delivery_Address_Line_4__c, 
            Application__c.Delivery_Country__c, 
            Application__c.Delivery_Postcode__c, 
            Application__c.Delivery_Province__c, 
            Application__c.Expected_Annual_Yearly_Turnover_From__c, 
            Application__c.Expected_Annual_Yearly_Turnover_To__c, 
            Application__c.Favorite_Sport_or_Colour__c, 
            Application__c.ICS_Is_main_Applicant__c, 
            Application__c.ICS_Is_the_applicant_a_refugee__c, 
            Application__c.Independent_tax_advice_received__c, 
            Application__c.Intention_for_Non_US_Resident_to_return__c, 
            Application__c.Keep_You_Informed_About_Product__c, 
            Application__c.Keep_You_Informed_About__c, 
            Application__c.National_Insurance__c, 
            Application__c.Opportunity__c, 
            Application__c.Other_Identification_Number__c, 
            Application__c.Status__c, 
            Application__c.The_Same_as_Current_Address__c, 
            Application__c.US_Resident_Confirmation__c, 
            Application__c.Currency_Test_Formula__c, 
            Application__c.Initial_Deposits__c, 
            Application__c.SOF_Future_Deposit__c, 
            Application__c.AOB_MNO_Name_Matched__c, 
            Application__c.AOB_Other_Name__c, 
            Application__c.AOB_Status__c, 
            Application__c.CNGCU_Email_Alerts__c, 
            Application__c.Inflight__c,
            Application__c.AOB_RegistrationNumber__c,
            Application__c.AOB_GroupName__c,
            Application__c.AOB_DateofRegistration__c,
            Application__c.AOB_Contribution__c,
            Application__c.AOB_SigningInstructions__c,
            Application__c.AOB_IntendeduseofAccount__c,
            Application__c.AOB_DateofResolutionMeeting__c,
            Application__c.AOB_BCCEntityType__c,
            Application__c.AOB_PresenceinCountry__c,
            Application__c.AOB_ListedonanApprovedExchange__c,
            Application__c.AOB_IncorporationDate__c,
            Application__c.AOB_BusinessProceeds__c,
            Application__c.AOB_ReturnsClassificationCode__c,
            Application__c.AOB_IndustryClassificationSARBCode__c,
            Application__c.AOB_AddressValidFrom__c,
            Application__c.AOB_TertiarySICCode__c,
            Application__c.Entity_Type_Sub_Category__c,
            Application__c.AOB_GUID__c,
            Application__c.AOB_Rely_Comply_Status__c,
            Application__c.AOB_CRAAssessment__c,
            Application__c.AOB_BusinessLegalName__c,
            Application__c.AOB_Signing_Arrangement__c
        });
        return returnList;
    }

    /**
     * @description Select without conditions
     * @return List<Application__c>
     */
    public List<Application__c> selectWithoutCondition() {
        return (List<Application__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
    /**
    * @description Method to fetch list of Applications based on Application Id
    * @param  applicationIds 
    * @return List<Application__c> 
    **/
    public List<Application__c> selectApplicationById(List<Id> applicationIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id in :applicationIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Select by ApplicationId
     * @param appId
     * @return List<Application__c>
     */
    public List<Application__c> selectAppsById(String appId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('id=:appId');
        FieldQueryFactory.selectFields(fields);  
        return Database.query(FieldQueryFactory.toSOQL()); 
    }

    /**
     * @description Select by ApplicationId
     * @param appId
     * @return Application__c
     */
    public Application__c selectAppById(String appId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('id=:appId');
        FieldQueryFactory.selectFields(fields);  
        return Database.query(FieldQueryFactory.toSOQL());  
    }
   
    /**
     * @description Method to fetch list of Applications based on Lead Ids
     * @param leadIds
     * @return List<AOB_Application__c>
     */
    public List<Application__c> selectApplicationByLeadId(List<Id> leadIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_Lead__c in :leadIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Method to fetch list of Applications based on Status__c And AOB_Schema_Code__c
     * @param status
     * @param schemaCode
     * @return List<Application__c>
     */
    public List<Application__c> selectApplicationByStatusAndSchemaCode(String status, String schemaCode) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Status__c=:status AND AOB_Schema_Code__c=:schemaCode');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c And AOB_Schema_Code__c
     * @param registrationNumber
     * @param schemaCode 
     * @return Application__c
     */
    public Application__c selectApplicationByRegAndSchemaCode(String registrationNumber, String schemaCode) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_RegistrationNumber__c=:registrationNumber AND AOB_Schema_Code__c=:schemaCode');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c And AOB_Schema_Code__c
     * @param registrationNumber
     * @param schemaCode 
     * @return Application__c
     */
    public List<Application__c> selectApplicationByRegAndSchemaCodeList(String registrationNumber, String schemaCode) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_RegistrationNumber__c=:registrationNumber AND AOB_Schema_Code__c=:schemaCode');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c And AOB_Schema_Code__c
     * @param registrationNumber
     * @param stage 
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByRegAndStage(String registrationNumber,String stage) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_RegistrationNumber__c=:registrationNumber AND AOB_Stage__c=:stage');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

     /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c
     * @param registrationNumber
     * @param stage 
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByOnlyReg(String registrationNumber) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_RegistrationNumber__c=:registrationNumber');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c
     * @param registrationNumber
     * @param stage 
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByOnlyRegList(Set<String> registrationNumber) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_RegistrationNumber__c IN:registrationNumber');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c And AOB_Schema_Code__c
     * @param registrationNumber
     * @param stage 
     * @return List<Application__c>
     */
    public list<Application__c> selectByGroupNameAndStage(String groupName,String stage) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_GroupName__c=:groupName AND AOB_Stage__c=:stage');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Method to fetch list of Applications based on AOb_Group 
     * @param registrationNumber
     * @param stage 
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByOnlyGroup(Set<String> groupName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_GroupName__c=:groupName');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    
     /**
     * @description Method to fetch list of Applications based on AOB_GroupName__c And AOB_Schema_Code__c
     * @param groupName
     * @param schemaCode 
     * @return Application__c
     */

      public List<Application__c> selectApplicationByGroupAndSchemaCode(String groupName, String schemaCode) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_GroupName__c=:groupName AND AOB_Schema_Code__c=:schemaCode');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    public List<Application__c> getCorpDsxApllications(String applicationId) {
        return Database.query('select Id,AOB_PrimaryRelationshipManagerID__c,AOB_CIFID__c,(select Id,Document_Type__c,AOB_DateofExpiry__c,AOB_DSX__c from Application_Documents__r where AOB_DSX__c=true) from Application__c where id =:applicationId');
    }
    
    
     /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c
     * @param registrationNumber
     * @param stage 
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByregistrationNumber(Set<String> registrationNumber) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_RegistrationNumber__c IN:registrationNumber');
        fieldQueryFactory.selectFields(new List<String>{'Id','AOB_RegistrationNumber__c','AOB_Stage__c'});
        return Database.query(fieldQueryFactory.toSOQL());
    }
    

}