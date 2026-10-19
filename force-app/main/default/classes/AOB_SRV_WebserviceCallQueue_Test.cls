@IsTest
public inherited sharing class AOB_SRV_WebserviceCallQueue_Test {
  /**
   * @description Testing the creation of api errors cases
   */
  @IsTest
  private static void createTechnicalErrorCases_Test() {
    Account acc = CMN_DAL_DataFactory.insertAccount();
    AOB_Application__c app = CMN_DAL_DataFactory.insertApplication(acc.Id);
    List<CMN_WebserviceCallQueue__c> webservices = new List<CMN_WebserviceCallQueue__c>();
    for (Integer i = 0; i < 100; i++) {
      webservices.add(
        CMN_DAL_DataFactory.newWebserviceQueue(
          'Failed',
          app.Id,
          '40' + i,
          'AOB_TestServiceName'
        )
      );
    }
    Test.startTest();
    insert webservices;
    Test.stopTest();
    List<Case> errorCases = [
      SELECT Id
      FROM Case
      WHERE AOB_Application__c = :app.Id
    ];
    System.assertEquals(webservices.size(), errorCases.size());
  }
}