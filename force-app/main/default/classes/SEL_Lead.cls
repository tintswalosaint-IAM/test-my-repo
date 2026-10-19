/**
* @Description         : Selector Class for Lead Entity
* @LastModified        : Raja Arsalan
* @Author              : Ruchi Agrawal
* @LastModifiedReason  : SFP-56183 Updated the 'SelectLeadsByTypeAndDateFilters'
*               method to not fetch the lead having no mobilenumber,
*               if method is called via batch class. Added a new 
*               method to fetch the leads (selectDialerLeadsByRecIds).
*               		 Added a selector method by the name selectLeadsForManualExpiry.

*changelog:

*2026-05-13    Preetham        PPBSF-341 -  added method 'selectByIdNumberWithoutSystemReference'
@2026-07-17    Raja Arsalan    SFP-59337 - Modified the selectLeadsForManualExpiry method
							   to enforce security and fetch required fields only and added 
							   validation checks 
*@LastModifiedReason : SFP-55759 - Added The following Lead fields in method(selectLeadByLeadId) to support the Moonstone
* Disclosure implementation:Status,Stage__c,OwnerId,Owner.Name 
*@LastModified by : Gigyasu Jain
*Group : SBFC
*@LastModified Date : 08-07-2026
*
								
**/


public inherited sharing class SEL_Lead extends sbgplatform.fflib_SObjectSelector {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SEL_Lead.class.getName());
    private static final String AND_CONDITION = ' AND ';
    private static Set<String> fields = new Set<String>{
        'Id',
            'IsDeleted',
            'MasterRecordId',
            'LastName',
            'FirstName',
            'Salutation',
            'MiddleName',
            'Suffix',
            'Name',
            'RecordTypeId',
            'Title',
            'Company',
            'Street',
            'City',
            'State',
            'PostalCode',
            'Country',
            'Latitude',
            'Longitude',
            'GeocodeAccuracy',
            'Address',
            'Phone',
            'MobilePhone',
            'Fax',
            'Email',
            'Website',
            'PhotoUrl',
            'Description',
            'LeadSource',
            'Status',
            'Industry',
            'Rating',
            'CurrencyIsoCode',
            'AnnualRevenue',
            'NumberOfEmployees',
            'OwnerId',
            'HasOptedOutOfEmail',
            'IsConverted',
            'ConvertedDate',
            'ConvertedAccountId',
            'ConvertedContactId',
            'ConvertedOpportunityId',
            'IsUnreadByOwner',
            'CreatedDate',
            'CreatedById',
            'LastModifiedDate',
            'LastModifiedById',
            'SystemModstamp',
            'LastActivityDate',
            'DoNotCall',
            'HasOptedOutOfFax',
            'LastViewedDate',
            'LastReferencedDate',
            'LastTransferDate',
            'Jigsaw',
            'JigsawContactId',
            'EmailBouncedReason',
            'EmailBouncedDate',
            'IndividualId',
            'FinServ__ConversionDateTime__c',
            'FinServ__CreatedByMe__c',
            'FinServ__CreatedFromLead__c',
            'FinServ__Employer__c',
            'FinServ__ExpressedInterest__c',
            'FinServ__Household__c',
            'FinServ__PotentialValue__c',
            'FinServ__ReferredByContact__c',
            'FinServ__ReferredByUser__c',
            'FinServ__ReferrerScore__c',
            'FinServ__RelatedAccount__c',
            'DB_Created_Date_without_Time__c',
            'DB_Lead_Age__c',
            'AOB_Status__c',
            'Nationality__c',
            'ID_Number__c',
            'AOB_Date_of_Birth__c',
            'Gender__c',
            'UTM_Campaign__c',
            'UTM_Source__c',
            'UTM_Medium__c',
            'Expressed_Interest_Product__c',
            'Campaign_Name__c',
            'Campaign_Source_ID__c',
            'External_Client_Identifier__c',
            'Loan_Account_Number__c',
            'Preferred_Contact_Date_Time__c',
            'Preferred_Contact_Date_Time_End__c',
            'Expressed_Interest_Detail__c',
            'Dialler_Queue_ID__c',
            'Dialer_Failure_Reason__c',
            'SA_ID_or_Passport__c',
            'Referred_System_Reference_Number__c',
            'Mobile_Phone_With_Country_Code__c',
            'Source_System_Reference__c',
            'Was_FHQ_Completed__c',
            'stage__c',
            'Lead_Closing_Comment__c'
            };

                public SEL_Lead(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
                    super(includeFieldSetFields, enforceCRUD, enforceFLS);
                }

    public SEL_Lead() {
        super();
    }

    /**
* @description Implementation method for Lead Object as part of fflib framweork
* @author Ruchi Agrawal | 05-31-2023
* @return Schema.SObjectType
**/

    public override Schema.SObjectType getSObjectType() {
        return Lead.sObjectType;
    }

    /**
* @description Method to get list of fields to be part of response
* @author Ruchi Agrawal | 05-31-2023
* @return List<Schema.SObjectField>
**/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Lead.Id,
                Lead.IsDeleted,
                Lead.MasterRecordId,
                Lead.LastName,
                Lead.FirstName,
                Lead.Salutation,
                Lead.MiddleName,
                Lead.Suffix,
                Lead.Name,
                Lead.RecordTypeId,
                Lead.Title,
                Lead.Company,
                Lead.Street,
                Lead.City,
                Lead.State,
                Lead.PostalCode,
                Lead.Country,
                Lead.Latitude,
                Lead.Longitude,
                Lead.GeocodeAccuracy,
                Lead.Address,
                Lead.Phone,
                Lead.MobilePhone,
                Lead.Fax,
                Lead.Email,
                Lead.Website,
                Lead.PhotoUrl,
                Lead.Description,
                Lead.LeadSource,
                Lead.Status,
                Lead.Industry,
                Lead.Rating,
                Lead.CurrencyIsoCode,
                Lead.AnnualRevenue,
                Lead.NumberOfEmployees,
                Lead.OwnerId,
                Lead.HasOptedOutOfEmail,
                Lead.IsConverted,
                Lead.ConvertedDate,
                Lead.ConvertedAccountId,
                Lead.ConvertedContactId,
                Lead.ConvertedOpportunityId,
                Lead.IsUnreadByOwner,
                Lead.CreatedDate,
                Lead.CreatedById,
                Lead.LastModifiedDate,
                Lead.LastModifiedById,
                Lead.SystemModstamp,
                Lead.LastActivityDate,
                Lead.DoNotCall,
                Lead.HasOptedOutOfFax,
                Lead.LastViewedDate,
                Lead.LastReferencedDate,
                Lead.LastTransferDate,
                Lead.Jigsaw,
                Lead.JigsawContactId,
                Lead.EmailBouncedReason,
                Lead.EmailBouncedDate,
                Lead.IndividualId,
                Lead.FinServ__ConversionDateTime__c,
                Lead.FinServ__CreatedByMe__c,
                Lead.FinServ__CreatedFromLead__c,
                Lead.FinServ__Employer__c,
                Lead.FinServ__ExpressedInterest__c,
                Lead.FinServ__Household__c,
                Lead.FinServ__PotentialValue__c,
                Lead.FinServ__ReferredByContact__c,
                Lead.FinServ__ReferredByUser__c,
                Lead.FinServ__ReferrerScore__c,
                Lead.FinServ__RelatedAccount__c,
                Lead.DB_Created_Date_without_Time__c,
                Lead.DB_Lead_Age__c,
                Lead.AOB_Status__c,
                Lead.Nationality__c,
                Lead.ID_Number__c,
                Lead.AOB_Date_of_Birth__c,
                Lead.Gender__c,
                Lead.UTM_Campaign__c,
                Lead.UTM_Source__c,
                Lead.UTM_Medium__c,
                Lead.Expressed_Interest_Product__c,
                Lead.Campaign_Name__c,
                Lead.Campaign_Source_ID__c,
                Lead.External_Client_Identifier__c,
                Lead.Loan_Account_Number__c,
                Lead.Preferred_Contact_Date_Time__c,
                Lead.Preferred_Contact_Date_Time_End__c,
                Lead.Expressed_Interest_Detail__c,
                Lead.Dialler_Queue_ID__c,
                Lead.Dialer_Failure_Reason__c,
                Lead.SA_ID_or_Passport__c,
                Lead.Referred_System_Reference_Number__c,
                Lead.Mobile_Phone_With_Country_Code__c,
                Lead.stage__c,
                Lead.Lead_Closing_Comment__c 
                };
                    }

    /**
* @description Method to fetch list of Leads based on Lead Id
* @param applicationId
* @return List<Lead>
**/
    public List<Lead> selectLeadById(String applicationId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Application__c =:applicationIds');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }



    /**
* @description Method to fetch list of Leads based on Lead Id
* @param leadId
* @return List<Lead>
**/
    public List<Lead> selectLeadByRecId(String leadId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =:leadId');
        fieldQueryFactory.selectFields(fields);
        String query = fieldQueryFactory.toSOQL();
        LOGGER.trace('selectLeadByRecId: query: ' + query);
        return Database.query(query);
    }

    /**
* @description Method to fetch list of Leads based on Email Address
* @param Email
* @Author Krishna Ranjan
* @return List<Lead>
**/
    public List<Lead> selectByEmail(string Email) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Email =:Email');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
* @description Select by LeadId
* @param leadId
* @Author Krishna Ranjan
* @return Lead
*/
    public Lead selectById(String leadId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        FieldQueryFactory.setCondition('id=:leadId');
        FieldQueryFactory.selectFields(fields);
        return Database.query(FieldQueryFactory.toSOQL());
    }

    /**
* @description Specialist method to select Leads If Corresponding Source System Reference Field is not Null
* @author Krishna Ranjan | 19-06-2024
* @param recordId
* @return List<Lead>
**/
    public List<Lead> selectByIdHavingSystemReference(String recordId) {
        List<Lead> leads = [
            SELECT Id, Source_System_Reference__c, Was_FHQ_Completed__c
            FROM Lead
            WHERE Id = :recordId AND Source_System_Reference__c != NULL
        ];

        return leads;
    }

    /**
* @description Specialist method to select Leads for a set of specific External Client Identifiers that are NOT linked to the corresponding Account
* @author Derek Hughes | 12-05-2024
* @param clientExternalIds
* @return List<Lead>
**/
    public List<Lead> selectByIdWithNoRelatedAccount(Set<String> clientExternalIds) {
        List<Lead> leads = [
            SELECT Id, Name, External_Client_Identifier__c, FinServ__RelatedAccount__c
            FROM Lead
            WHERE FinServ__RelatedAccount__c = NULL AND External_Client_Identifier__c IN :clientExternalIds
        ];

        return leads;
    }

    /**
* @author : Dhriven Hamlall
* @description Fetches a Lead associated with a given Account ID.
* @param accountId The ID of the Account related to the Lead.
* @return Lead The Lead associated with the provided Account ID.
*/
    public List<Lead> selectLeadByAccountId(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('FinServ__RelatedAccount__c = :accountId');
        fieldQueryFactory.selectFields(
            new Set<String>{
                'Id',
                    'IsConverted',
                    'Title',
                    'FirstName',
                    'LastName',
                    'Email',
                    'MobilePhone',
                    'ID_Number__c',
                    'Description',
                    'CurrencyIsoCode',
                    'FinServ__RelatedAccount__c',
                    'AOB_Date_of_Birth__c',
                    'Marital_Status__c',
                    'GenderIdentity',
                    'FinServ__RelatedAccount__r.Id',
                    'FinServ__RelatedAccount__r.FirstName',
                    'FinServ__RelatedAccount__r.MiddleName',
                    'FinServ__RelatedAccount__r.LastName',
                    'FinServ__RelatedAccount__r.Phone',
                    'FinServ__RelatedAccount__r.PersonEmail',
                    'FinServ__RelatedAccount__r.PersonBirthdate',
                    'FinServ__RelatedAccount__r.FinServ__Gender__pc',
                    'FinServ__RelatedAccount__r.Nationality__c',
                    'FinServ__RelatedAccount__r.PersonTitle',
                    'FinServ__RelatedAccount__r.Identification_Number__c',
                    'Street',
                    'City',
                    'State',
                    'PostalCode',
                    'Country'
                    }
        );
        return (List<Lead>) Database.query(fieldQueryFactory.toSOQL() + ' LIMIT 1');
    }

    /**
* @author : Dhriven Hamlall
* @description Fetches a Lead associated with a given lead ID.
* @param leadId The ID of the Lead
* @return Lead The Lead associated with the provided Lead ID.
*/

    public Lead selectLeadByLeadId(String leadId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id = :leadId');
        fieldQueryFactory.selectFields(
            new Set<String>{
                'Id',
                    'IsConverted',
                    'Title',
                    'FirstName',
                    'LastName',
                    'Email',
                    'MobilePhone',
                    'ID_Number__c',
                    'Description',
                    'CurrencyIsoCode',
                    'FinServ__RelatedAccount__c',
                    'AOB_Date_of_Birth__c',
                    'Marital_Status__c',
                    'GenderIdentity',
                    'FinServ__RelatedAccount__r.Id',
                    'FinServ__RelatedAccount__r.FirstName',
                    'FinServ__RelatedAccount__r.MiddleName',
                    'FinServ__RelatedAccount__r.LastName',
                    'FinServ__RelatedAccount__r.Phone',
                    'FinServ__RelatedAccount__r.PersonEmail',
                    'FinServ__RelatedAccount__r.PersonBirthdate',
                    'FinServ__RelatedAccount__r.FinServ__Gender__pc',
                    'FinServ__RelatedAccount__r.Nationality__c',
                    'FinServ__RelatedAccount__r.PersonTitle',
                    'FinServ__RelatedAccount__r.Identification_Number__c',
                    'Street',
                    'City',
                    'State',
                    'PostalCode',
                    'Country',
                    'Stage__c',
                    'Status',
                    'OwnerId',
                    'Owner.Name'
                    }
        );
        fieldQueryFactory.setlimit(1);
        return (Lead) Database.query(fieldQueryFactory.toSOQL());
    }


    /**
* @description Method to fetch list of Leads based on Lead Type/Product Family/Name/Email etc.
This method runs **without enforce crud and fls** to allow full access to records,
ignoring the user's access. 
* @param searchCriteria
* @return List<Lead>
**/ 

    public List<Lead> selectLeadsByDtoSearchCriteria(INS_DTO_LeadSearchCriteria searchCriteria) {

        if (searchCriteria == null) { 
            return new List<Lead>();
        }
        Datetime connexDate = searchCriteria.connexDate;
        Datetime startDate = searchCriteria.startDate;
        Datetime endDate = searchCriteria.endDate;
        
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, false, false);

        List<String> conditions = new List<String>();
        conditions.add('IsConverted = false');
        conditions.add('Referred_System_Reference_Number__c = null');
        conditions.add('Status != \'Unqualified\'');
        conditions.add('CreatedDate >= :connexDate');

        conditions.add('Expressed_Interest_Product__r.Lead_type__c = \'' +
                       String.escapeSingleQuotes(searchCriteria.leadType) +'\'');


        conditions.add('Expressed_Interest_Product__r.Leads_Product_Family__c = \'' +
                       String.escapeSingleQuotes(searchCriteria.productFamily) +'\'');




        if (searchCriteria.isReport == false) {

            String dialerCondition = 
                '(' + '(MobilePhone != null AND Dialler_Queue_ID__c != null)' +
                ' OR ' + 
                '(' + '(MobilePhone = null OR Dialler_Queue_ID__c = null)' +
                ' AND Dialer_Failure_Reason__c = null' + ')' + ')';

            conditions.add(dialerCondition);
        }

        String nowStr = DateTime.now()
            .addHours(2)
            .formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        conditions.add(
            '(Preferred_Contact_Date_Time__c = null ' +
            'OR Preferred_Contact_Date_Time__c < ' + nowStr + ')'
        );

        if (String.isNotBlank(searchCriteria.searchKey)) {
            String safeSearch = String.escapeSingleQuotes(searchCriteria.searchKey);
            conditions.add(
                '(Name LIKE \'%' + safeSearch + '%\'' +
                'OR Email LIKE \'%' + safeSearch + '%\'' +
                'OR Phone LIKE \'%' + safeSearch + '%\')'
            );
        }


        if (searchCriteria.startDate != null) {
            conditions.add('CreatedDate >= :startDate');
        }

        if (searchCriteria.endDate != null) {
            conditions.add('CreatedDate <= :endDate');
        }

        if (String.isNotBlank(searchCriteria.campaignName)) {
            String safeCampaignName = String.escapeSingleQuotes(searchCriteria.campaignName);
            conditions.add(
                'Campaign_Name__c LIKE \'%' + safeCampaignName + '%\''
            );
        }
        if (searchCriteria.campaignSourceId != null) {
            conditions.add(
                'Campaign_Source_ID__c = \'' + searchCriteria.campaignSourceId + '\''
            );
        }


        qf.setCondition(String.join(conditions, ' AND '));
        qf.selectFields(fields);
        return Database.query(qf.toSOQL());
    }



    /**
* @description Method to fetch list of Leads based on LeadId, LeadSource, CreatedDateBy, RecordType, Expressed Interest 
* @param leadIds
* @return Map<Id, Lead>
**/ 

    public Map<Id, Lead> selectLeadsEligibleForCourtesySMS(Set<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return new Map<Id, Lead>();
        }

        sbgplatform.fflib_QueryFactory leadQueryFactory = newQueryFactory(true, true, false);

        List<String> conditions = new List<String>();
        conditions.add('Id IN :leadIds');
        conditions.add('CreatedBy.Name = \'SBG DATA User\'');
        conditions.add('LeadSource != \'Retro\'');
        conditions.add('RecordType.DeveloperName = \'General\'');
        conditions.add('Expressed_Interest_Product__r.Leads_Jurisdiction__c = \'South Africa\'');

        String fullCondition = String.join(conditions, ' AND ');
        leadQueryFactory.setCondition(fullCondition);

        leadQueryFactory.selectFields(
            new Set<String>{
                'Id',
                    'CreatedBy.Name',
                    'Expressed_Interest_Product__r.Leads_Jurisdiction__c',
                    'RecordType.DeveloperName',
                    'Mobile_Phone_With_Country_Code__c'
                    }
        );

        String generatedSOQL = leadQueryFactory.toSOQL();        
        return new Map<Id, Lead>((List<Lead>) Database.query(generatedSOQL));
    }


    /**
* @description Method to fetch list of Leads eligible to expire
* @return List<Lead>
**/

    public List<Lead> selectLeadsToExpire(List<String> statusesToExpire, String leadSource, String leadType, String productFamily) {

        if (statusesToExpire == null || statusesToExpire.isEmpty() || 
            String.isBlank(leadSource) || String.isBlank(leadType) || String.isBlank(productFamily)) {
                return new List<Lead>();
            }

        sbgplatform.fflib_QueryFactory leadQueryFactory = newQueryFactory(true, true, false);

        String combinedConditions = 
            'Status IN :statusesToExpire' +
            ' AND LeadSource = :leadSource' +
            ' AND Expressed_Interest_Product__r.Lead_Type__c = :leadType' +
            ' AND Expressed_Interest_Product__r.Leads_Product_Family__c = :productFamily' +
            ' AND Referred_System_Reference_Number__c != null' +
            ' AND CreatedDate < LAST_N_DAYS:29';

        leadQueryFactory.setCondition(combinedConditions);

        leadQueryFactory.selectFields(new Set<String>{
            'Id',
                'FirstName',
                'LastName',
                'MobilePhone',
                'Phone',
                'Email',
                'Loan_Account_Number__c',
                'Expressed_Interest_Detail__c',
                'SA_ID_or_Passport__c',
                'Campaign_Source_ID__c',
                'Description',
                'Preferred_Contact_Date_Time__c',
                'Preferred_Contact_Date_Time_End__c',
                'Dialler_Queue_ID__c',
                'Referred_System_Reference_Number__c',
                'Status',
                'OwnerId'
                });

        String generatedSOQL = leadQueryFactory.toSOQL();        
        return (List<Lead>) Database.query(generatedSOQL);
    }



    /**
* @description   Method to fetch list of Leads based on list of Lead Ids.
This method runs **without enforce crud and fls** to allow full access to records,
ignoring the user's access. 
* @param leadIds List of Lead Record IDs
* @return        List<Lead>
*/

    public List<Lead> selectLeadsByRecIds(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return new List<Lead>();
        }       
        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(false, false, false);

        fieldQueryFactory.setCondition('Id IN :leadIds');
        fieldQueryFactory.selectFields(fields);

        String query = fieldQueryFactory.toSOQL();
        return Database.query(query);
    }



    /**

* @description Selects leads by bulk duplicate criteria (multiple LastNames, Campaign_Source_ID__c, MobilePhones)
* @param lastNames Set of last names to match
* @param campaignSourceIds Set of Campaign Source IDs to match
* @param mobilePhones Set of mobile numbers to match
* @return List<Lead> Matching leads
*/
    public List<Lead> selectByBulkDuplicateCriteria(Set<String> lastNames, Set<String> campaignSourceIds, Set<String> mobilePhones) {
        if (lastNames == null || lastNames.isEmpty() || campaignSourceIds == null || campaignSourceIds.isEmpty() || mobilePhones == null || mobilePhones.isEmpty()) {
            return new List<Lead>();
        }

        sbgplatform.fflib_QueryFactory leadQueryFactory = newQueryFactory(false, false, false);

        List<String> conditions = new List<String>();

        String lastNamesStr = String.join(new List<String>(lastNames), '\',\'');
        String campaignSourceIdsStr = String.join(new List<String>(campaignSourceIds), '\',\'');
        String mobilePhonesStr = String.join(new List<String>(mobilePhones), '\',\'');

        conditions.add('LastName IN (\'' + lastNamesStr + '\')');
        conditions.add('Campaign_Source_ID__c IN (\'' + campaignSourceIdsStr + '\')');
        conditions.add('MobilePhone IN (\'' + mobilePhonesStr + '\')');
        conditions.add('Status IN (\'New\', \'Working\', \'Waiting for Customer\')');

        String fullCondition = String.join(conditions, AND_CONDITION);
        leadQueryFactory.setCondition(fullCondition);

        leadQueryFactory.selectFields(
            new Set<String>{
                'Id',
                    'LastName',
                    'Campaign_Source_ID__c',
                    'MobilePhone',
                    'LeadSource',
                    'CreatedDate',
                    'Status',
                    'OwnerId'
                    }
        );
        leadQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);

        String generatedSOQL = leadQueryFactory.toSOQL();   
        return (List<Lead>) Database.query(generatedSOQL);
    }



    /**
* @description Retrieves Lead records by their Ids for dialer processing.
*              Only returns leads that either have no dialer failure reason
*              or have a failure reason but contain the required MobilePhone
*              and Dialler Queue Id values.
*              This method runs **without enforce crud and fls** to allow full access to records, ignoring the user's access. 
* @param leadIds List of Lead Record IDs
* @return List<Lead>
*/    

    public List<Lead> selectDialerLeadsByRecIds(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return new List<Lead>();
        }       

        sbgplatform.fflib_QueryFactory fieldQueryFactory =
            newQueryFactory(false, false, false);

        fieldQueryFactory.setCondition(
            'Id IN :leadIds ' +
            'AND ( ' +
            'Dialer_Failure_Reason__c = null ' +
            'OR (Dialer_Failure_Reason__c != null ' +
            'AND MobilePhone != null ' +
            'AND Dialler_Queue_ID__c != null' +
            ')' +
            ')'
        );

        fieldQueryFactory.selectFields(fields);
        String generatedSOQL = fieldQueryFactory.toSOQL(); 
        return (List<Lead>) Database.query(generatedSOQL);
    }

    /**
* @Description Method to fetch list of Leads based on Lead Type/Product Family/Name/Email
* 			   and other filters pass through an LWC component 
* @Param 	   searchCriteria
* @Return      List<Lead>
**/ 
    
    public List<Lead> selectLeadsForManualExpiry(INS_DTO_LeadSearchCriteria criteria) {
        
        Datetime eligibilityDateTime = criteria.connexDate;
        Datetime filterStartDateTime = criteria.startDate;
        Datetime filterEndDateTime = criteria.endDate;
        
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(true, true, false);
        List<String> conditions = new List<String>();
        
        conditions.add('IsConverted = false');
        conditions.add('Status NOT IN (\'Unqualified\', \'Qualified\', \'Onboarding\')');
        conditions.add('CreatedDate >= :eligibilityDateTime');
        if(String.isNotBlank(criteria.leadType)){
        conditions.add('Expressed_Interest_Product__r.Lead_type__c = \'' +
                       String.escapeSingleQuotes(criteria.leadType) +'\'');
        }
        if(String.isNotBlank(criteria.productFamily)){
        conditions.add('Expressed_Interest_Product__r.Leads_Product_Family__c = \'' +
                       String.escapeSingleQuotes(criteria.productFamily) +'\'');
        }
        
        if(String.isNotBlank(criteria.status)){
            conditions.add('Status = \'' +
                           String.escapeSingleQuotes(criteria.status) +'\'');
        }
        
        if(String.isNotBlank(criteria.stage)){
            conditions.add('Stage__c = \'' +
                           String.escapeSingleQuotes(criteria.stage) +'\'');
        }
        
        if (String.isNotBlank(criteria.campaignName)) {
            String safeCampaign = String.escapeSingleQuotes(criteria.campaignName);
            conditions.add(
                '(' +
                'Campaign_Name__c LIKE \'%' + safeCampaign + '%\' ' +
                'OR Campaign_Source_ID__c LIKE \'%' + safeCampaign + '%\' ' +
                ')'
            );
        }
        
        if (criteria.startDate != null) {
            conditions.add('CreatedDate >= :filterStartDateTime');
        }
        
        if (criteria.endDate != null) {
            conditions.add('CreatedDate <= :filterEndDateTime');
        }
        
        if (String.isNotBlank(criteria.searchKey)) {
            String safeSearch = String.escapeSingleQuotes(criteria.searchKey);
            
            List<String> searchConditions = new List<String>{
                'Name LIKE \'%' + safeSearch + '%\'',
                    'Email LIKE \'%' + safeSearch + '%\'',
                    'Phone LIKE \'%' + safeSearch + '%\''
                    };
                        
                        try {
                            Id searchId = Id.valueOf(criteria.searchKey);
                            if (searchId != null) {
                                searchConditions.add('Id = \'' + searchId + '\'');
                            }
                        } catch (Exception ex) {
                            LOGGER.error('SEL_Lead | ManualExpiry | Exception', ex);
                        }
            
            conditions.add('(' + String.join(searchConditions, ' OR ') + ')');
        }
        
        qf.setCondition(String.join(conditions, AND_CONDITION));
        qf.selectFields(
            new Set<String>{
                'Id',
                    'Name',
                    'Email',
                    'Campaign_Source_ID__c',
                    'MobilePhone',
                    'LeadSource',
                    'CreatedDate',
                    'Status',
                    'OwnerId',
                    'Stage__c',
                    'Campaign_Name__c',
                    'CreatedDate'
                    }
        );
        
        return Database.query(qf.toSOQL());
    }
    

    /* @description Specialist method to select Lead with an Id Number If Corresponding Source System Reference Field is Null

* @author Preetham | 13-05-2026
* @param recordId
* @return List<Lead>
**/
    public List<Lead> selectByIdNumberWithoutSystemReference(String idNumber) {
        List<Lead> leads = [
            SELECT Id, Source_System_Reference__c, ID_Number__c
            FROM Lead
            WHERE ID_Number__c = :idNumber AND Source_System_Reference__c = NULL
        ];
        
        return leads;
    } 
    
    
    /**
 * @description Selects leads eligible for retry based on failure reason 
 *              and system reference number
 * @param leadIds List of Lead IDs to filter
 * @return List of Leads matching retry criteria
 **/
public List<Lead> selectByIdsForRetry() {
    
    sbgplatform.fflib_QueryFactory fieldQueryFactory =
        newQueryFactory(false, false, false);
    
    fieldQueryFactory.setCondition(
        'Dialer_Failure_Reason__c LIKE \'500%\' ' +
        'AND Referred_System_Reference_Number__c LIKE \'%Failed%\''
    );
    
    fieldQueryFactory.selectFields(fields);
    String generatedSOQL = fieldQueryFactory.toSOQL();
    return (List<Lead>) Database.query(generatedSOQL);
}

}