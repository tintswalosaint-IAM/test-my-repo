/**
 * @description       : SFP-54443 - Selector Class for AuthorizationForm
 * @author            : Gigyasu Jain
 * @last modified on  : 02-04-2026
**/
public inherited sharing class SEL_AuthorizationForm extends sbgplatform.fflib_SObjectSelector {

    public SEL_AuthorizationForm() {}

    public SEL_AuthorizationForm(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }

    public override Schema.SObjectType getSObjectType() {
        return AuthorizationForm.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AuthorizationForm.Id,
            AuthorizationForm.Name,
            AuthorizationForm.DefaultAuthFormTextId
        };
    }

    /**
     * @description Returns the AuthorizationForm matching the given name.
     */
    public List<AuthorizationForm> selectByName(String formName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, true, true);
        qf.setCondition('Name = :formName');
        qf.selectFields(getSObjectFieldList());
        qf.setLimit(1);
        return (List<AuthorizationForm>) Database.query(qf.toSOQL());
    }
}