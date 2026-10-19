/**
 * @description       : SFP-54443 - Selector Class for DataUseLegalBasis
 * @author            : Gigyasu Jain
 * @last modified on  : 02-04-2026
**/
public inherited sharing class SEL_DataUseLegalBasis extends sbgplatform.fflib_SObjectSelector {
	/**
     * Default Constructor
     */
    public SEL_DataUseLegalBasis() {}
	
    public SEL_DataUseLegalBasis(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }
	/**
     * @description Return SObject Type
     */
    public override Schema.SObjectType getSObjectType() {
        return DataUseLegalBasis.sObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            DataUseLegalBasis.Id,
            DataUseLegalBasis.Name
        };
    }

    /**
     * @description Returns the DataUseLegalBasis matching the given name.
     */
    public List<DataUseLegalBasis> selectByName(String legalBasisName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(false, true, true);
        qf.setCondition('Name = :legalBasisName');
        qf.selectFields(getSObjectFieldList());
        qf.setLimit(1);
        return (List<DataUseLegalBasis>) Database.query(qf.toSOQL());
    }
}