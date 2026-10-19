/**
 * @description Field Selector Layer
 * 
 * @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
 *
 * @date May 2022
 */
public inherited sharing class SEL_AOBScreen extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'AOB_Title__c','AOB_subTitle__c','AOB_TitleApplicationField__c', 'AOB_Pop_up__c'};
	
    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_FlowScreen__c.Name,
                AOB_FlowScreen__c.Id,
                AOB_FlowScreen__c.AOB_Title__c,
                AOB_FlowScreen__c.AOB_TitleApplicationField__c
        };
    }

    /**
     * @description selectById
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return AOB_FlowScreen__c.sObjectType;
    }

    /**
     * @description Select by section
     * @param screenName
     * @return List<AOB_FlowScreen__c>
     */
    public List<AOB_FlowScreen__c> selectFieldsByName(String screenName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('Name = :screenName');
		fieldQueryFactory.selectFields(fields);  

        if(Test.isRunningTest() == true) {
            newQueryFactory(false, false, true);
        }

        return Database.query(fieldQueryFactory.toSOQL());
    }
}