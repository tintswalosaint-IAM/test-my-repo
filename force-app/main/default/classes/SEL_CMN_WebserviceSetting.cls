/***************************************************************************************
@ Author            : Rahul.Mamidala@standardbank.co.za
@ Date              : 28-04-2025
@ Name of the Class : Sel_domain_Info
@ Description       : This class is responsible for retrieving CMN_WebserviceSetting__mdt records 
                      using the fflib_SObjectSelector framework.
@ Jira Ticket       :SPF-47031
* @Last Modified On : April 28, 2025
* @Modification Log :
*==============================================================================
* Ver | Date           | Author                              | Modification
*==============================================================================
* 1.0 | April 28, 2025 |  Rahul.Mamidala@standardbank.co.za  | Initial Version
***************************************************************************************/
public inherited sharing class SEL_CMN_WebserviceSetting extends sbgplatform.fflib_SObjectSelector {
     private static Set<String> fields = new Set<String>{
        'Id',
		'AOB_ClientCertificate__c',
		'DeveloperName'

    };
    /**
* @description Implementation method for CMN_WebserviceSetting__mdt Object as part of fflib framweork
* @author Rahul.Mamidala@standardbank.co.za | 05-31-2023 
* @return Schema.SObjectType 
**/
public override Schema.SObjectType getSObjectType() {
        return CMN_WebserviceSetting__mdt.sObjectType;
    }
    /**
* @description Method to get list of fields to be part of response
* @author Rahul.Mamidala@standardbank.co.za | 05-31-2023 
* @return List<Schema.SObjectField> 
**/
public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CMN_WebserviceSetting__mdt.Id,
			CMN_WebserviceSetting__mdt.AOB_ClientCertificate__c,
			CMN_WebserviceSetting__mdt.DeveloperName
};
 }
/**
* @description Method to fetch WebserviceSetting metadata by developer name
* @author Rahul.Mamidala@standardbank.co.za
* @param developerName The developer name to search for
* @return List<CMN_WebserviceSetting__mdt> The matching metadata records
**/
public List<CMN_WebserviceSetting__mdt> selectByDeveloperName(String developerName) {
    sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory();
    queryFactory.setCondition('DeveloperName = :developerName');
    queryFactory.selectFields(fields);
	queryFactory.setLimit(1);
    return Database.query(queryFactory.toSOQL());
}

    

}