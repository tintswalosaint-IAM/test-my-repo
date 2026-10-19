/**
 * @description       : SFP-54443 - Selector Class for AuthorizationFormText
 * @author            : Gigyasu Jain
 * @last modified on  : 02-04-2026
**/
public inherited sharing class SEL_AuthorizationFormText extends sbgplatform.fflib_SObjectSelector {

    public SEL_AuthorizationFormText() {}


    public SEL_AuthorizationFormText(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }

    public override Schema.SObjectType getSObjectType() {
        return AuthorizationFormText.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            AuthorizationFormText.Id,
            AuthorizationFormText.Name,
            AuthorizationFormText.Locale,
            AuthorizationFormText.AuthorizationFormId,
            AuthorizationFormText.IsActive,
            AuthorizationFormText.SummaryAuthFormText             
                
        };
    }

    /**
     * @description Returns the AuthorizationFormText matching the given name.
     */
    public List<AuthorizationFormText> selectByName(String textName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, true, true);
        qf.setCondition('Name = :textName');
        qf.selectFields(getSObjectFieldList());
        qf.setLimit(1);
        return (List<AuthorizationFormText>) Database.query(qf.toSOQL());
    }
}