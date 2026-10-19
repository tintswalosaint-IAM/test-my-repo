/**
 * @description : Test class for DocumentManagementHelper
 * @author : Jaco de Lange
 *
 * @last modified on : 11-12-2024
**/
@isTest
public class INS_DocumentManagementHelper_TEST {

   @isTest
   public static void testGetRecord() {
     INS_UTIL_DocumentManagementHelper dh = new INS_UTIL_DocumentManagementHelper();
        Account acc = INS_DocumentManagementTestFactory_TEST.createAccount();
        Claim cl = INS_DocumentManagementTestFactory_TEST.createClaim();
        InsurancePolicy ip = INS_DocumentManagementTestFactory_TEST.createInsurancePolicy(acc.Id);
        Case c = INS_DocumentManagementTestFactory_TEST.createCase();
     
        Test.startTest();
          dh.getRecord(cl.Id);
          dh.getRecord(ip.Id);
          dh.getRecord(c.Id);
        Test.stopTest();
        Assert.areEqual('TestClaim', cl.Name, 'matching claim');
        Assert.areEqual('TestPolicy', ip.Name, 'matching policy');
        Assert.areEqual('TestCase', c.Subject, 'matching case');
   }

   @isTest
   public static void testGetTaxonomy() {
     INS_UTIL_DocumentManagementHelper dh = new INS_UTIL_DocumentManagementHelper();
        Document_Upload_Configuration__mdt docType = INS_DocumentManagementTestFactory_TEST.getDocumentType();
        Test.startTest();
        INS_UTIL_Taxonomy record = dh.getTaxonomy(docType.Id);
        Test.stopTest();
        Assert.areEqual(record.documentTypeId, docType.Document_Type_Id__c, 'matching records');
   }

   @isTest
   public static void testGetPayLoad() {
        INS_UTIL_File testFile = new INS_UTIL_File();
        INS_UTIL_DocumentManagementHelper dh = new INS_UTIL_DocumentManagementHelper();
        ContentVersion cv = INS_DocumentManagementTestFactory_TEST.createContentVersion(INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id);
        insert cv;
        Document_Upload_Configuration__mdt docType = INS_DocumentManagementTestFactory_TEST.getDocumentType();
        Claim cl = INS_DocumentManagementTestFactory_TEST.createClaim();
        testFile.setRecordId(cl.Id);
        Test.startTest();
          dh.getPayLoad(testFile.setFile(cv), dh.getTaxonomy(docType.Id));
        Test.stopTest();
        Assert.areEqual('doc upload', cv.Title, 'matching title');
        Assert.areEqual('TestClaim', cl.Name, 'matching claim');
   }
}