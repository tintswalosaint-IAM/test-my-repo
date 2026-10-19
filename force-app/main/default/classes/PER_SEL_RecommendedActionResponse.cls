/**
 * @description       : Select for sbgpers__Recommended_Action_Response__c
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 04-03-2024
 * @last modified by  : Derek Hughes
**/
public inherited sharing class PER_SEL_RecommendedActionResponse extends sbgplatform.fflib_SObjectSelector {

    public PER_SEL_RecommendedActionResponse () {
        super();
    }

    /**
     * @description Implementation method for Application Object as part of fflib framweork
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return sbgpers__Recommended_Action_Response__c.sObjectType;
    }

    /**
     * @description Returns list of User fields
     *
     * @return list of SObjectField
     */
    public override List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            sbgpers__Recommended_Action_Response__c.Id, 
            sbgpers__Recommended_Action_Response__c.Name, 
            sbgpers__Recommended_Action_Response__c.sbgpers__Category__c, 
            sbgpers__Recommended_Action_Response__c.sbgpers__Country_Code__c, 
            sbgpers__Recommended_Action_Response__c.sbgpers__Reason__c, 
            sbgpers__Recommended_Action_Response__c.sbgpers__Response__c, 
            sbgpers__Recommended_Action_Response__c.sbgpers__Sub_Category__c 
        };
    }

    public List<sbgpers__Recommended_Action_Response__c> selectByCountryCode(String countryCode) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('sbgpers__Country_Code__c = :countryCode')
                .toSOQL()
        );
    }
  
    
}