/**
 * @description Test class to test the Outbound API call
 *
 * <p></p>
 *
 * @author mbourhi@salesforce.com
 *
 * @date 2020
 */
@isTest
public class AOB_QUEUE_GetBranches_TEST {
  /**
   * @description This method is used to test callGetToken methd
   */
  @isTest
  public static void AOB_GetBranches_Test() {
    AOB_QUEUE_GetBranches queuable = new AOB_QUEUE_GetBranches('fakeToken');
    Test.startTest();
    ID jobID = System.enqueueJob(queuable);
    Test.stopTest();
    system.assertEquals(
      [
          SELECT id
          FROM AOB_ReferencedData__c
          WHERE AOB_SAPField__c = :AOB_QUEUE_GetBranches.FIELD_NAME
        ]
        .size(),
      3
    );
  }
}