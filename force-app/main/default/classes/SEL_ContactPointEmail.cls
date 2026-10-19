/**
 * @description       : Selector Class for ContactPointPhone Entity
 * story 		  : SFP-30128
 * @author            : Ikyatha Naidu
 * @date May 2022
 * @last modified on  : 06-04-2024
 * @Modification Description : used new field signing arrangement
**/
public inherited sharing class SEL_ContactPointEmail extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{'Id', 'EmailAddress','ParentId'};

        /**
        * @description Implementation method for ContactPointEmail Object as part of fflib framweork
        * @return Schema.SObjectType
        **/
        public override Schema.SObjectType getSObjectType() {
        	return ContactPointEmail.sObjectType;
        }

    	/**
    	* @description Method to get list of fields to be part of response
    	* @author Ikyatha Naidu| 05-31-2023
    	* @return List<Schema.SObjectField>
    	**/
    	public override List<Schema.SObjectField> getSObjectFieldList() {
        	return new List<Schema.SObjectField> {
                ContactPointEmail.Id,
                ContactPointEmail.EmailAddress,
               ContactPointEmail.ParentId


                };
        }

        /**
		* @description Method to fetch list of ContactPointPhone based on Parameters
		* @param recordID
		* @return ContactPointEmail
		**/
		public ContactPointEmail selectByParentId(string recordID) {

            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('ParentId =:recordID');
            fieldQueryFactory.selectFields(fields);
            String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
            return Database.query(query);
    	}

		 /**
		* @description Method to fetch list of ContactPointPhone based on Parameters
		* @param ids
		* @return List<ContactPointEmail>
		**/
		public List<ContactPointEmail> selectByAccountIds(set<id> ids) {
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('ParentId IN:ids ' );
            fieldQueryFactory.selectFields(fields);
            String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
            return Database.query(query);
    	}
        /**
		* @description Method to fetch list of ContactPointEmails based on Parameters
		* @param email
		* @return List<ContactPointEmail>
		**/
		public List<ContactPointEmail> selectByEmail(string email) {

            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('EmailAddress =:email ' );
            fieldQueryFactory.selectFields(fields);
            String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
            return Database.query(query);
    	}
}