/**
 * @description Selector class for the BusinessBrand SObject
 * @author Shams Arifeen
 * @date 2026-06-26
 * @user story SFP-58864
 */
public inherited sharing class SEL_BusinessBrand extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Returns the SObject type for this selector
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return BusinessBrand.SObjectType;
    }

    /**
     * @description Returns the default field list
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            BusinessBrand.Id,
            BusinessBrand.Name
        };
    }

    /**
     * @description Fetches a single BusinessBrand record by Name
     * @param name String
     * @return BusinessBrand
     */
    public BusinessBrand selectByName(String name) {
        if (String.isBlank(name)) {
            return null;
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Name = :name');
        fieldQueryFactory.setLimit(1);
        List<BusinessBrand> results = Database.query(fieldQueryFactory.toSOQL());
        return results.isEmpty() ? null : results[0];
    }
}