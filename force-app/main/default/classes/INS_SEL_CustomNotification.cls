/**
 * @description       : Selector Class for Lead Entity
 * @author            : Raja Arsalan 
 * @last modified on  : 10-31-2023

**/
public inherited sharing class INS_SEL_CustomNotification extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{'Id', 
        'DeveloperName'
    };
            
/**
 * @description       : Selector override method for CustomNotification Entity
**/        
        public override Schema.SObjectType getSObjectType() {
        	return CustomNotificationType.sObjectType;
        }
    
    	/**
    	* @description Method to get list of fields to be part of response
    	* @author Raja Arsalan 
    	* @return List<Schema.SObjectField> 
    	**/
    	public override List<Schema.SObjectField> getSObjectFieldList() {
        	return new List<Schema.SObjectField> {
                CustomNotificationType.Id, 
                CustomNotificationType.DeveloperName 
                };
        } 
    
    
		/**
		* @description Method to fetch list of Leads based on Lead Id
		* @param name
		* @return List<Lead> 
		**/
		public List<CustomNotificationType> selectNotificationTypeById(String name) {
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('DeveloperName =:name');
            fieldQueryFactory.selectFields(fields); 
            return Database.query(fieldQueryFactory.toSOQL());
    	}


        
}