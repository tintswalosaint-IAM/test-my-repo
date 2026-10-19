/**
 * @Name of the Class : SEL_FinServ_FinancialAccount
 * @description       : Selector Class for Financial Account
 * @last modified on  : 2025-06-30
 * @last modified by  : Sizwe November
 * @edited by         : Raymond Magezi - Added searchByCIF, searchByAccountNumber, and searchByPrimaryOwner methods
 * @last modified by : Raymond Magezi 
 * @date modified on : 2025-09-16
 *
 * @ Last Modified By : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Modification description : Updated to add a searchRestricetdFinancialAcountsByCountry test method and Improving Code coverage
 * @ User Story : SFP-52104
 *
 * @ Last Modified By : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Modification description : Updated the searchRestrictedFinancialAccountsByCountry() method
 * @ Last Modified on 10th Nov 2025
 * @ User Story : SFP-54179
 **/
public inherited sharing class SEL_FinServ_FinancialAccount extends sbgplatform.fflib_SObjectSelector {
  private static Set < String > fields = new Set < String > {
    'FinServ__PrimaryOwner__c',
    'ExternalCIFId__c',
    'CurrencyIsoCode',
    'Name',
    'FinServ__FinancialAccountNumber__c',
    'FinServ__OverdraftLinkedAccount__c',
    'FinServ__OverdraftLinkedAccount__r.ExternalCIFId__c',
    'FinServ__OverdraftLinkedAccount__r.Name',
    'Id',
    'CMN_AccessRestrictionCode__c'
  };

  /**
   * @description Implementation method for Account Object as part of fflib framweork
   * @return Schema.SObjectType 
   */
  public override Schema.SObjectType getSObjectType() {
    return FinServ__FinancialAccount__c.sObjectType;
  }

  /**
   * @description Method to get list of fields to be part of response
   * @return List<Schema.SObjectField> 
   **/
  public override List < Schema.SObjectField > getSObjectFieldList() {
    return new List < Schema.SObjectField > {
      FinServ__FinancialAccount__c.Id,
      FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c
    };
  }
  /**
   * @description Method to fetch   list of FinServ__FinancialAccount__c based on Parameters 
   * @param AccountIds
   * @return FinServ__FinancialAccount__c
   **/
  public list < FinServ__FinancialAccount__c > selectByPrimaryOwnerIds(set < id > AccountIds) {

    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('FinServ__PrimaryOwner__c IN :AccountIds');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Method to search FinancialAccount by CIF number
   * @param cifNumber
   * @return List<FinServ__FinancialAccount__c>
   **/
  public List < FinServ__FinancialAccount__c > searchByCIF(String cifNumber) {
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('ExternalCIFId__c LIKE \'' + String.escapeSingleQuotes('%' + cifNumber + '%') + '\'');
    fieldQueryFactory.selectFields(fields);
    fieldQueryFactory.setOrdering('ExternalCIFId__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
    fieldQueryFactory.setLimit(10);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Method to search FinancialAccount by account number or name
   * @param accountNumber
   * @return List<FinServ__FinancialAccount__c>
   **/
  public List < FinServ__FinancialAccount__c > searchByAccountNumber(String accountNumber) {
    String searchPattern = String.escapeSingleQuotes('%' + accountNumber + '%');
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('(Name LIKE \'' + searchPattern + '\' OR FinServ__FinancialAccountNumber__c LIKE \'' + searchPattern + '\')');
    fieldQueryFactory.selectFields(fields);
    fieldQueryFactory.setOrdering('Name', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
    fieldQueryFactory.setLimit(10);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Method to search FinancialAccount by Primary Owner
   * @param searchTerm
   * @return List<FinServ__FinancialAccount__c>
   **/
  public List < FinServ__FinancialAccount__c > searchByPrimaryOwner(String searchTerm) {
    String searchPattern = String.escapeSingleQuotes('%' + searchTerm + '%');
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('FinServ__PrimaryOwner__r.Name LIKE \'' + searchPattern + '\'');
    fieldQueryFactory.selectFields(fields);
    fieldQueryFactory.setOrdering('FinServ__PrimaryOwner__r.Name', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
    fieldQueryFactory.setLimit(10);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Method to search search Restricetd Financial Acounts By Country
   * @param country
   * @param restrictionCodes
   * @return List<FinServ__FinancialAccount__c>
   **/
  public List < FinServ__FinancialAccount__c > searchRestricetdFinancialAcountsByCountry(String country, Set < String > restrictionCodes) {
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('ExternalCIFCountry__c = :country AND CMN_AccessRestrictionCode__c IN :restrictionCodes');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
  }
}