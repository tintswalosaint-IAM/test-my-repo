/**
 * @description       : Selector Class for Application Entity
 * @author            : Nagendraprasad Mylavarapu
 * @last modified on  : 01-07-2023
 * @last modified by  : Nagendraprasad Mylavarapu
**/
public without sharing class AOB_BOTS_SEL_NamedCredential extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{'Id',
        'Language',
        'DeveloperName',
        'MasterLabel',
        'NamespacePrefix',
        'Endpoint',
        'PrincipalType',
        'CalloutOptionsGenerateAuthorizationHeader',
        'CalloutOptionsAllowMergeFieldsInHeader',
        'CalloutOptionsAllowMergeFieldsInBody',
        'AuthProviderId',
        'JwtIssuer',
        'JwtFormulaSubject',
        'JwtTextSubject',
        'JwtValidityPeriodSeconds',
        'JwtAudience',
        'AuthTokenEndpointUrl'};
        
    /**
    * @description Implementation method for Named Credentials Object as part of fflib framweork
    * @author Nagendraprasad Mylavarapu | 02-16-2023 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
    	return NamedCredential.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {NamedCredential.Id,
            NamedCredential.Language,
            NamedCredential.DeveloperName,
            NamedCredential.MasterLabel,
            NamedCredential.NamespacePrefix,
            NamedCredential.Endpoint,
            NamedCredential.PrincipalType,
            NamedCredential.CalloutOptionsGenerateAuthorizationHeader,
            NamedCredential.CalloutOptionsAllowMergeFieldsInHeader,
            NamedCredential.CalloutOptionsAllowMergeFieldsInBody,
            NamedCredential.AuthProviderId,
            NamedCredential.JwtIssuer,
            NamedCredential.JwtFormulaSubject,
            NamedCredential.JwtTextSubject,
            NamedCredential.JwtValidityPeriodSeconds,
            NamedCredential.JwtAudience,
            NamedCredential.AuthTokenEndpointUrl};
    }
    
    /**
    * @description Method to fetch list of Named Credentials based on its name
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param String NamedCredential-Name 
    * @return List<NamedCredential> 
    **/
    public List<NamedCredential> selectNamedCredentialsByName(String namedCredential) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('DeveloperName = :namedCredential');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
}