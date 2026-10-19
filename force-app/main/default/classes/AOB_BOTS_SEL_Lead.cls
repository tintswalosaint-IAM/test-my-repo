/**
 * @description       : Selector Class for Lead Entity
 * @author            : Nagendraprasad Mylavarapu
 * @last modified on  : 01-07-2023
 * @last modified by  : Nagendraprasad Mylavarapu
**/
public without sharing class AOB_BOTS_SEL_Lead extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{'Id', 
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
        'UTM_Medium__c'};
            
        /**
        * @description Implementation method for Lead Object as part of fflib framweork
        * @author Nagendraprasad Mylavarapu | 01-07-2023 
        * @return Schema.SObjectType 
        **/
        public override Schema.SObjectType getSObjectType() {
        	return Lead.sObjectType;
        }
    
    	/**
    	* @description Method to get list of fields to be part of response
    	* @author Nagendraprasad Mylavarapu | 01-07-2023 
    	* @return List<Schema.SObjectField> 
    	**/
    	public override List<Schema.SObjectField> getSObjectFieldList() {
        	return new List<Schema.SObjectField> {
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
                Lead.UTM_Medium__c
                };
        }
    
    
		/**
		* @description Method to fetch list of Leads based on Lead Id
		* @author Nagendraprasad Mylavarapu | 01-07-2023 
		* @param String leadId 
		* @return List<Lead> 
		**/
		public List<Lead> selectLeadById(String leadId) {
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('Id = :leadId');
            fieldQueryFactory.selectFields(fields); 
            return Database.query(fieldQueryFactory.toSOQL());
    	}
}