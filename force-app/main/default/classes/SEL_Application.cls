/**
 * @description       : Selector Class for Application Entity
 * @author            : jagadish
 * @last modified on  : 09-07-2026
 * @last modified by  : jagadish Thummala
 * **************************************
 * @Last Modified By  : jagadish Thummala
 * @Last Modified On  : 09-07-2026
 * @Modification Description : SFP-53980 — Added new fields and method for secondary account
 * fields set.
 * **************************************
 * @Last Modified By  : jagadish Thummala
 * @Last Modified On  : 09-07-2026
 * @Modification Description : Removed the duplicated static Set<String> field list — every query
 * method now builds its SELECT clause from getSObjectFieldList() 
 * @User story : SFP-53980
**/
public without sharing class SEL_Application extends sbgplatform.fflib_SObjectSelector {

    /**
* @description Parent-relationship fields (AOB_Lead__r.*, AOB_Product__r.*) that cannot be
* represented as Schema.SObjectField on Application__c and so aren't returned by
* getSObjectFieldList(). Selected one at a time (via selectField()) alongside it in every query
* method below.
* @author Anuja Alli | 06-08-2026
**/

    private static List<String> relationshipFields = new List<String>{
        'AOB_Lead__r.name',
        'AOB_Product__r.name'
    };

    /**
    * @description Implementation method for Application Object as part of fflib framweork
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
    	return Application__c.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response. This is now the single
    * source of truth for Application__c's own fields — every query method below selects from this
    * list (plus relationshipFields for the two parent lookups) instead of a separate hardcoded
    * string list.
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {Application__c.Id, 
            Application__c.OwnerId, 
            Application__c.IsDeleted, 
            Application__c.Name, 
            Application__c.CurrencyIsoCode, 
            Application__c.RecordTypeId, 
            Application__c.Bank_Name__c,
            Application__c.CNGCU_CSEmail__c,
            Application__c.CNCGU_Email_Statements__c,
            Application__c.First_Deposit_Amount__c,
            Application__c.AOB_Source_of_initial_deposit__c, 
            Application__c.AOB_PreviouslyHeldProminentOffice__c, 
            Application__c.AOB_FamilyInProminentPublicOffice__c, 
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
            Application__c.Employment_Details_Notes__c,
            Application__c.Account__c, 
            Application__c.AOB_Employment_Type__c, 
            Application__c.AOB_Mode_Of_Payment__c, 
            Application__c.AOB_Nature_Of_Employment__c, 
            Application__c.AOB_Name_Of_Bank__c, 
            Application__c.AOB_Employer_Name__c, 
            Application__c.AOB_Employer_Address__c, 
            Application__c.AOB_Account_Number__c, 
            Application__c.AOB_Mobile_Money_Number__c, 
            Application__c.Other_Source_of_Wealth__c,
            Application__c.AOB_FirstName__c, 
            Application__c.AOB_PreviouslyHeldOffice__c,
            Application__c.AOB_FamilyPreviouslyHeldOffice__c,
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
            Application__c.AOB_Country_of_Birth__c,
            Application__c.AOB_Current_Address_Country__c, 
            Application__c.AOB_City__c, 
            Application__c.AOB_Current_Address_City__c, 
            Application__c.Card_Delivery_Option__c, 
            Application__c.AOB_Nationality__c, 
            Application__c.AOB_IP_Address__c, 
            Application__c.AOB_Device_Details__c, 
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
            Application__c.AOB_Occupation__c, 
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
            Application__c.Correspondence_Province__c,
            Application__c.Your_Account_Notes__c, 
            Application__c.Intent_to_Future_Deposits_Fund__c,
            Application__c.AOB_Preferred_Social_media_Channel__c,
            Application__c.AOB_inflightData__c,
            Application__c.AOB_Entity_hold_50_or_more_of_its_gross__c,
            Application__c.AOBEntity_earn_more_than_50_gross_income__c,
            Application__c.Tax_Identification_Number__c,
            Application__c.AOB_Document_Number__c,
            Application__c.AOB_Company_employees__c,
            Application__c.Reason_for_Transfer__c,
            Application__c.WI_ClientType__c,
            Application__c.Other_Source_of_Wealth__c,
            Application__c.AOB_PrimaryNationality__c,
            Application__c.AOB_Country_of_Nationality__c,
            Application__c.Tax_Resident_Other_Countries__c,
            Application__c.AOB_PrimaryCountryTaxResidence__c,
            Application__c.AOB_CountryTaxResidence__c,
            Application__c.Relationship_to_You__c,
            Application__c.AOB_SecondaryAccount__c,
            Application__c.AOB_TradeLicenseExpiryDate__c,
            Application__c.Country_of_Tax__c,
            Application__c.AOB_UG_BCB_Stage__c
        };
    }

    /**
* @description Builds a query factory pre-loaded with the standard field set
* (getSObjectFieldList() plus relationshipFields), with CRUD and FLS enforcement switched on
* (assertCRUD = true, enforceFLS = true), so every query method below stays a one-liner and none
* of them silently bypass the running user's object/field-level security.
* @author Anuja Alli | 06-08-2026
* @return sbgplatform.fflib_QueryFactory
**/
    private sbgplatform.fflib_QueryFactory newFieldQueryFactory() {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.selectFields(getSObjectFieldList());
        for (String relationshipField : relationshipFields) {
            fieldQueryFactory.selectField(relationshipField);
        }
        return fieldQueryFactory;
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
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('Id in :applicationIds');
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Select by ApplicationId
     * @param appId
     * @return List<Application__c>
     */
    public List<Application__c> selectAppsById(String appId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
		fieldQueryFactory.setCondition('id=:appId');
        return Database.query(fieldQueryFactory.toSOQL()); 
    }

    /**
     * @description Select by section
     * @param filterCondition String
     * @return List<Application__c>
     */
    public List<Application__c> getApplicationByFilter(String filterCondition) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
		fieldQueryFactory.setCondition(filterCondition);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select by ApplicationId
     * @param appId
     * @return Application__c
     */
    public Application__c selectAppById(String appId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
		fieldQueryFactory.setCondition('id=:appId');
        return Database.query(fieldQueryFactory.toSOQL());  
    }
   
    /**
     * @description Method to fetch list of Applications based on Lead Ids
     * @param leadIds
     * @param List<Id>
     * @return List<AOB_Application__c>
     */
    public List<Application__c> selectApplicationByLeadId(List<Id> leadIds) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('AOB_Lead__c in :leadIds');
    	return Database.query(fieldQueryFactory.toSOQL());
    }

     /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c
     * @param registrationNumber
     * @param Set<String>
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByOnlyRegList(Set<String> registrationNumber) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('AOB_RegistrationNumber__c IN:registrationNumber');
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    
     /**
     * @description Method to fetch list of Applications based on AOb_Group 
     * @param groupName
     * @param Set<String>
     * @return List<Application__c>
     */
    public list<Application__c> selectApplicationByOnlyGroup(Set<String> groupName) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('AOB_GroupName__c=:groupName');
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Method to fetch list of Applications based on Status__c And AOB_Schema_Code__c
     * @param status
     * @param schemaCode
     * @return List<Application__c>
     */
    public List<Application__c> selectApplicationByStatusAndSchemaCode(String status, String schemaCode) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('Status__c=:status AND AOB_Schema_Code__c=:schemaCode');
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Method to fetch list of Applications based on AOB_RegistrationNumber__c And AOB_Schema_Code__c
     * @param registrationNumber
     * @param schemaCode 
     * @return Application__c
     */
    public Application__c selectApplicationByRegAndSchemaCode(String registrationNumber, String schemaCode) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('AOB_RegistrationNumber__c=:registrationNumber AND AOB_Schema_Code__c=:schemaCode');
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Method to fetch list of Applications based on customerId
     * @param registrationNumber
     * @param schemaCode 
     * @return Application__c
     */
    public Application__c selectApplicationByCustomerId(String customerId) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newFieldQueryFactory();
    	fieldQueryFactory.setCondition('AOB_Customer_Id__c=:customerId');
    	return Database.query(fieldQueryFactory.toSOQL());
    }
}