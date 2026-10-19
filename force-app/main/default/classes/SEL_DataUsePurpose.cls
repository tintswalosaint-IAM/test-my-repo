/**
 * @description       : Selector Class for DataUsePurpose
 * @author            : Gigyasu Jain
 * @last modified on  : 02-04-2026
**/
public inherited sharing class SEL_DataUsePurpose extends sbgplatform.fflib_SObjectSelector {

    public SEL_DataUsePurpose() {}

    public SEL_DataUsePurpose(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }

    public override Schema.SObjectType getSObjectType() {
        return DataUsePurpose.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            DataUsePurpose.Id,
            DataUsePurpose.Name,
            DataUsePurpose.LegalBasisId,
            DataUsePurpose.IsActive
                
        };
    }

    /**
     * @description Returns the DataUsePurpose matching the given name (or null if none).
     */
    public List<DataUsePurpose> selectByName(String purposeName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, true, true);
        qf.setCondition('Name = :purposeName');
        qf.selectFields(getSObjectFieldList());
        qf.setLimit(1);
        return (List<DataUsePurpose>) Database.query(qf.toSOQL());
    }
}