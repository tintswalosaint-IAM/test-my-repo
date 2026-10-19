/**
 * @description Public class to as part of post copy script to query metadata
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_PostCopyTask {
  /**
   * @description Method to query post copy metadata type
   *
   * @return List
   */
  public static List<CMN_PostCopyTask__mdt> getAll() {
    return [
      SELECT Id, DeveloperName, CMN_Active__c, CMN_OrderNumber__c
      FROM CMN_PostCopyTask__mdt
      WHERE CMN_Active__c = TRUE
      ORDER BY CMN_OrderNumber__c ASC
      LIMIT :CMN_DAL_SObjectDomain.LIMIT_NUMBER_OF_RECORDS
    ];
  }
}