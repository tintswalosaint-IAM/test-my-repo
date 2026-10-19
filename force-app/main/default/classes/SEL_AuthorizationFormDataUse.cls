/**
 * @description       : SFP-54443 - Selector Class for AuthorizationFormDataUse
 * @author            : Gigyasu Jain
 * @last modified on  : 02-04-2026
**/
public inherited sharing class SEL_AuthorizationFormDataUse extends sbgplatform.fflib_SObjectSelector {

    public SEL_AuthorizationFormDataUse() {}


    public SEL_AuthorizationFormDataUse(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }

    public override Schema.SObjectType getSObjectType() {
        return AuthorizationFormDataUse.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AuthorizationFormDataUse.Id,
            AuthorizationFormDataUse.Name,
            AuthorizationFormDataUse.DataUsePurposeId,
            AuthorizationFormDataUse.AuthorizationFormId
        };
    }

    /**
     * @description Returns the AuthorizationFormDataUse matching the given name.
     */
    public List<AuthorizationFormDataUse> selectByName(String dataUseName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, true, true);
        qf.setCondition('Name = :dataUseName');
        qf.selectFields(getSObjectFieldList());
        qf.setLimit(1);
        return (List<AuthorizationFormDataUse>) Database.query(qf.toSOQL());
    }
}