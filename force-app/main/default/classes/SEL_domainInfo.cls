/***************************************************************************************
@ Author            : Rahul.Mamidala@standardbank.co.za
@ Date              : 28-04-2025
@ Name of the Class : Sel_domain_Info
@ Description       : This class is responsible for retrieving PRX_domain_Info__mdt records 
                      using the fflib_SObjectSelector framework.
@ Jira Ticket       :SPF-47031
* @Last Modified On : April 28, 2025
* @Modification Log :
*==============================================================================
* Ver | Date           | Author                              | Modification
*==============================================================================
* 1.0 | April 28, 2025 |  Rahul.Mamidala@standardbank.co.za  | Initial Version
***************************************************************************************/
public inherited sharing class SEL_domainInfo extends sbgplatform.fflib_SObjectSelector {
     private static Set<String> fields = new Set<String>{
        'Id',
		'Prx_URL_info__c',
		'DeveloperName',
        'AES_SecretKey__c'
    };
    /**
* @description Implementation method for PRX_domain_Info__mdt Object as part of fflib framweork
* @author Rahul.Mamidala@standardbank.co.za | 05-31-2023 
* @return Schema.SObjectType 
**/
public override Schema.SObjectType getSObjectType() {
        return PRX_domain_Info__mdt.sObjectType;
    }
    /**
* @description Method to get list of fields to be part of response
* @author Rahul.Mamidala@standardbank.co.za | 05-31-2023 
* @return List<Schema.SObjectField> 
**/
public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PRX_domain_Info__mdt.Id,
            PRX_domain_Info__mdt.Prx_URL_info__c,
            PRX_domain_Info__mdt.DeveloperName,
            PRX_domain_Info__mdt.AES_SecretKey__c
};
 }

/**
    * @description Method to fetch list of PRX_domain_Info__mdt based on PRX_domain_Info__mdt name
    * @author mamidalar@stanbic.com | AUG 16th 2023 
    * @param name  
    * @return Network 
 **/
    public list<PRX_domain_Info__mdt> domainInfoByDeveloperName(string DeveloperName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('DeveloperName = :DeveloperName');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}