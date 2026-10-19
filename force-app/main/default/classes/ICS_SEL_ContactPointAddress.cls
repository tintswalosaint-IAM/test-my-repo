/**
 * @description       Selector Class for ContactPointAddress
 * @author            Ofentse Sacha
 * @last modified on  01-07-2023
 * @last modified by  Ofentse Sacha
**/
public without sharing class ICS_SEL_ContactPointAddress extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{'Id',  
        'Name', 
        'ParentId', 
        'PostalCode', 
        'Postcode__c', 
        'Relationship__c', 
        'Sector_Code__c', 
        'Start_Date__c', 
        'RecordTypeId', 
        'State', 
        'The_Same_as_Current_Address__c', 
        'Street', 
        'City', 
        'Address_Line_1__c', 
        'Address_Line_2__c', 
        'Address_Line_3__c', 
        'Address_Line_4__c', 
        'AddressType',
        'OwnerId',
        'IsPrimary',
        'Start_Date__c',
        'End_Date__c',
        'Country__c',
        'Other_relationship__c'};
            
        /**
        * @description Implementation method for ContactPointAddress Object as part of fflib framweork
        * @author Ofentse Sacha 
        * @return Schema.SObjectType 
        **/
        public override Schema.SObjectType getSObjectType() {
        	return ContactPointAddress.sObjectType;
        }
    
    	/**
    	* @description Method to get list of fields to be part of response
    	* @author Ofentse Sacha 
    	* @return List<Schema.SObjectField> 
    	**/
    	public override List<Schema.SObjectField> getSObjectFieldList() {
        	return new List<Schema.SObjectField> {
                ContactPointAddress.Id,
                ContactPointAddress.Name, 
                ContactPointAddress.ParentId, 
                ContactPointAddress.PostalCode, 
                ContactPointAddress.Postcode__c, 
                ContactPointAddress.Relationship__c, 
                ContactPointAddress.Sector_Code__c, 
                ContactPointAddress.Start_Date__c, 
                ContactPointAddress.RecordTypeId, 
                ContactPointAddress.State, 
                ContactPointAddress.The_Same_as_Current_Address__c, 
                ContactPointAddress.Street, 
                ContactPointAddress.City, 
                ContactPointAddress.Address_Line_1__c, 
                ContactPointAddress.Address_Line_2__c, 
                ContactPointAddress.Address_Line_3__c, 
                ContactPointAddress.Address_Line_4__c, 
                ContactPointAddress.AddressType,
                ContactPointAddress.OwnerId,
                ContactPointAddress.IsPrimary,
                ContactPointAddress.Start_Date__c,
                ContactPointAddress.End_Date__c,
                ContactPointAddress.Country__c,
                ContactPointAddress.Other_relationship__c
                };
        }
    
    
		/**
		* @description Method to fetch list of ContactPointAddress based on accID
		* @author Ofentse Sacha
		* @param accID Id of Account
		* @return List<ContactPointAddress> 
		**/
		public List<ContactPointAddress> getContactPointAddresses(String accID) {
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('ParentId = :accID');
            fieldQueryFactory.selectFields(fields); 
            return Database.query(fieldQueryFactory.toSOQL());
    	}
}