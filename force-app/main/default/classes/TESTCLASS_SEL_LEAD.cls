public inherited sharing class TESTCLASS_SEL_LEAD extends sbgplatform.fflib_SObjectSelector {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SEL_Lead.class.getName());
    
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
            'stage__c'
            };
                
                public TESTCLASS_SEL_LEAD(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
                    super(includeFieldSetFields, enforceCRUD, enforceFLS);
                }
    
    public TESTCLASS_SEL_LEAD() {
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
                Lead.stage__c
                };
                    }
    
    
    
    /**
* @description Method to fetch list of Leads based on Lead Type/Product Family/Name/Email etc. This method runs **without enforce crud and fls** to allow full access to records, ignoring the user's access. 
* @param searchCriteria
* @return List<Lead>
**/ 
    
    public List<Lead> selectLeadsByDtoSearchCriteria(TEST_INS_DTO_LeadSearchCriteria c) {
        
        
        
        System.debug(
'SEL_Lead.selectLeads | Criteria -> ' +
'leadType=' + c.leadType +
', productFamily=' + c.productFamily +
', connexDate=' + c.connexDate +
', searchKey=' + c.searchKey +
', startDate=' + c.startDate +
', endDate=' + c.endDate +
', campaignName=' + c.campaignName +
', campaignSourceId=' + c.campaignSourceId +
', isReport=' + c.isReport
); 
        
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, false, false);
        
        List<String> conditions = new List<String>();
        if (String.isNotBlank(c.leadType)) {
            conditions.add(
                'Expressed_Interest_Product__r.Lead_type__c = \'' +
                String.escapeSingleQuotes(c.leadType) +
                '\''
            );
        }
        
        if (c.connexDate != null) {
            conditions.add(
                'CreatedDate >= ' +
                c.connexDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            );
        }
        
        conditions.add('IsConverted = false');
        
        if (String.isNotBlank(c.productFamily)) {
            conditions.add(
                'Expressed_Interest_Product__r.Leads_Product_Family__c = \'' +
                String.escapeSingleQuotes(c.productFamily) +
                '\''
            );
        }
        
        conditions.add('Referred_System_Reference_Number__c != null');
        conditions.add('Status != \'Unqualified\'');
        
        
        

        
        if (String.isNotBlank(c.searchKey)) {
            String safeSearch = String.escapeSingleQuotes(c.searchKey);
            
            conditions.add(
                '(' +
                'Name LIKE \'%' + safeSearch + '%\' ' +
                'OR Email LIKE \'%' + safeSearch + '%\' ' +
                'OR Phone LIKE \'%' + safeSearch + '%\' ' +
                'OR Id = \'' + safeSearch + '\'' +
                ')'
            );
        }
        
        
        
        if (c.startDate != null) {
            conditions.add(
                'CreatedDate >= ' +
                c.startDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            );
        }
        
        if (c.endDate != null) {
            conditions.add(
                'CreatedDate <= ' +
                c.endDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            );
        }
        
        if (String.isNotBlank(c.campaignName)) {
            String safeCampaignName = String.escapeSingleQuotes(c.campaignName);
            conditions.add(
                '(' +
				'Campaign_Source_ID__c LIKE \'%' + safeCampaignName + '%\' ' +
                'OR Campaign_Name__c LIKE \'%' + safeCampaignName + '%\'' +
                ')'
            );
        }
        

        // Status filter (exact match)
        if (String.isNotBlank(c.status)) {
            conditions.add(
                'Status = \'' + String.escapeSingleQuotes(c.status) + '\''
            );
        }
        
        // Stage filter (exact match)
        if (String.isNotBlank(c.stage)) {
            conditions.add(
                'Stage__c = \'' + String.escapeSingleQuotes(c.stage) + '\''
            );
        }
        
        
        
        qf.setCondition(String.join(conditions, ' AND '));
        qf.selectFields(fields);
        
        String finalQuery = qf.toSOQL();
        System.debug('FINAL LEAD QUERY ==> ' + finalQuery);
        return Database.query(qf.toSOQL());
    }
    
    
    
    public List<Lead> selectLeadsByRecIds(List<Id> leadIds) {
        if(leadIds == null || leadIds.isEmpty()) return new List<Lead>();
        
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, false, false);
        qf.setCondition('Id IN :leadIds');
        qf.selectFields(fields);
        String query = qf.toSOQL();
        LOGGER.trace('selectLeadsByRecIds: query: ' + query);
        return Database.query(query);
    }
    
    
}