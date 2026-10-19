/**
 * @description       : Selector for Financial Acount Share object
 * @author            : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @group             : Selector
 * @user story        : SFP-54179
 */
public inherited sharing class SEL_FinServ_FinancialAccount_Share extends sbgplatform.fflib_SObjectSelector {
  /**
   * @description Implementation method for Financial Acount Share Object as part of fflib framweork
   * @return Schema.SObjectType
   **/
  public override Schema.SObjectType getSObjectType() {
    return FinServ__FinancialAccount__Share.sObjectType;
  }

  /**
   * @description Returns list of Financial Acount Share fields
   *
   * @return list of SObjectField
   */
  public override List < SObjectField > getSObjectFieldList() {
    return new List < Schema.SObjectField > {
      FinServ__FinancialAccount__Share.Id
    };
  }

  /**
   * @description Gets financial account manual shares for a specific set of user Ids and Parent Ids
   * @author Alex Niyonsaba | 10th Nov 2025
   * @param userIds
   * @param financialAccountIds
   * @return List<FinServ__FinancialAccount__Share> 
   **/
  public List < FinServ__FinancialAccount__Share > selectManualSharesByParentIdAndUserId(Set < Id > userIds, Set < Id > financialAccountIds) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('UserOrGroupId in: userIds AND ParentId IN: financialAccountIds AND RowCause = \'Manual\' AND AccessLevel = \'Read\' AND IsDeleted = false')
      .toSOQL()
    );
  }

  /**
   * @description Gets financial account manual shares for a specific set of user Ids
   * @author Alex Niyonsaba | 10th Nov 2025
   * @param userIds
   * @return List<FinServ__FinancialAccount__Share> 
   **/
  public List < FinServ__FinancialAccount__Share > selectManualSharesByUserId(Set < Id > userIds) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('UserOrGroupId in: userIds AND RowCause = \'Manual\' AND AccessLevel = \'Read\' AND IsDeleted = false')
      .toSOQL()
    );
  }

  /**
   * @description Gets financial account manual shares for a specific set of Parent Ids
   * @author Alex Niyonsaba | 10th Nov 2025
   * @param financialAccountIds
   * @return List<FinServ__FinancialAccount__Share> 
   **/
  public List < FinServ__FinancialAccount__Share > selectManualSharesByParentId(Set < Id > financialAccountIds) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition(' ParentId IN: financialAccountIds AND RowCause = \'Manual\' AND AccessLevel = \'Read\' AND IsDeleted = false')
      .toSOQL()
    );
  }
}