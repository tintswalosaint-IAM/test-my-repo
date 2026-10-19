/***************************************************************************************
@ Author            :Jagadish Thummala
@ Date              :March 2024
@ Name of the Class :AOB_SEL_CustomMetaDataType
@ Description       :Selector Class for CustomMetaDataType Entity
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :22-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/**
 * @description Selector Class for CustomMetaDataType Entity
 **/
public class AOB_SEL_CustomMetaDataType extends sbgplatform.fflib_SObjectSelector {
   //to hold the field values
     private static Set<String> fields = new Set<String>{
        'Label',
        'value__c',
        'Apex_class__c'
       };

       /**
        * @description Implementation method for PPB_Static_values__mdt Object as part of fflib framweork
        * @return Schema.SObjectType 
        **/
        public override Schema.SObjectType getSObjectType() {
              return PPB_Static_values__mdt.SObjectType;
           }

    	/**
    	* @description Method to get list of fields to be part of response
    	* @return List<Schema.SObjectField> 
    	**/
    	public override List<Schema.SObjectField> getSObjectFieldList() {
        	return new List<Schema.SObjectField> {
                PPB_Static_values__mdt.Label,
                PPB_Static_values__mdt.value__c,
                PPB_Static_values__mdt.Apex_class__c
            };
        }
        /**
		* @description Method to fetch list of Leads based on Lead Id
        * @param apexClass
		* @return  Map<String, Object>
		**/
        public Map<String, Object> getMetadataByType(String apexClass) {
            String apexClassValue = apexClass + '%';
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('Apex_class__c LIKE :apexClassValue');
            fieldQueryFactory.selectFields(fields);
            List<SObject> results = Database.query(fieldQueryFactory.toSOQL());
        
            Map<String, Object> resultMap = new Map<String, Object>();
                for (SObject result : results) {
                    resultMap.put((String)result.get('Label'), result.get('value__c'));
                }
            return resultMap;
        }
   
}