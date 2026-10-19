/**
* @description       : SFP-54443 - Selector Class for InfoAuthorizationRequest
* @author            : Amlendu Bajpai
* @last modified on  : 01-04-2026
**/
public inherited sharing class SEL_InfoAuthorizationRequest extends sbgplatform.fflib_SObjectSelector {
	/**
     * Default Constructor
     */
    public SEL_InfoAuthorizationRequest() {}

    public SEL_InfoAuthorizationRequest(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }

    /**
     * @description Return SObject Type
     */
    public override Schema.SObjectType getSObjectType() {
        return InfoAuthorizationRequest.sObjectType;
    }

    /**
     * @description Fields to be queried
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            InfoAuthorizationRequest.Id,
            InfoAuthorizationRequest.SourceRecordId,
            InfoAuthorizationRequest.Name,
            InfoAuthorizationRequest.CreatedDate,
            InfoAuthorizationRequest.ResponseStatus,
            InfoAuthorizationRequest.SBFC_SigningHub_Document_Number__c,
            InfoAuthorizationRequest.SBFC_FileNet_Signed_Disclosure_GUID__c,
            InfoAuthorizationRequest.SBFC_FileNet_Evidence_Report_GUID__c,
            InfoAuthorizationRequest.RequestedDateTime,
            InfoAuthorizationRequest.ExpirationDateTime
        };
    }
	public InfoAuthorizationRequest selectById(String InfoAuthReqId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id = :InfoAuthReqId');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setlimit(1);
        List<InfoAuthorizationRequest> records = (List<InfoAuthorizationRequest>) Database.query(fieldQueryFactory.toSOQL());
        return records.isEmpty() ? null : records[0];
    }
    public InfoAuthorizationRequest selectBySourceRecordId(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('SourceRecordId = :accountId');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setlimit(1);
        List<InfoAuthorizationRequest> records = (List<InfoAuthorizationRequest>) Database.query(fieldQueryFactory.toSOQL());

        return records.isEmpty() ? null : records[0];
    }
    public List<InfoAuthorizationRequest> selectBySignedDocNumber(String docNumber) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('SBFC_SigningHub_Document_Number__c = :docNumber');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setlimit(1);
        List<InfoAuthorizationRequest> records = (List<InfoAuthorizationRequest>) Database.query(fieldQueryFactory.toSOQL());

        return records;
    }
}