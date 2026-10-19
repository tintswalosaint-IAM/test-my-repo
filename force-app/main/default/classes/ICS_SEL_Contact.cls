/**
 * @description       Selector Class for Contact
 * @author            Ofentse Sacha
 * @last modified on  01-07-2023
 * @last modified by  Ofentse Sacha
**/
public without sharing class ICS_SEL_Contact extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{'Id',  
        'Name', 
        'Email',
        'ICS_TPI_Code__c',
        'AccountId'};
            
        /**
        * @description Implementation method for Contact Object as part of fflib framweork
        * @author Ofentse Sacha 
        * @return Schema.SObjectType 
        **/
        public override Schema.SObjectType getSObjectType() {
        	return Contact.sObjectType;
        }
    
    	/**
    	* @description Method to get list of fields to be part of response
    	* @author Ofentse Sacha 
    	* @return List<Schema.SObjectField> 
    	**/
    	public override List<Schema.SObjectField> getSObjectFieldList() {
        	return new List<Schema.SObjectField> {
                Contact.Id,
                Contact.AccountId,
                Contact.Name,
                Contact.ICS_TPI_Code__c,
                Contact.Email 
                };
        }
      
		/**
		* @description Method to fetch list of Contact based on contactId
		* @author Ofentse Sacha
		* @param contactId 
		* @return List<Contact> 
		**/
		public List<Contact> buildBrokerContactsQuery(String contactId) {
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('Id = :contactId');
            fieldQueryFactory.selectFields(fields); 
            return Database.query(fieldQueryFactory.toSOQL());
    	}
}