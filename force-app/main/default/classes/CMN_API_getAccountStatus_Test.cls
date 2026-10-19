/**
 * @description Test class to test the Inbound API call
 * 
 * 
 * 
 * @author muvhuso.nekhubvi@standardbank.co.za
 *
 * @date October 2022
 */
@IsTest(SeeAllData=false)
public class CMN_API_getAccountStatus_Test {
    
    @TestSetup
    public static void testSetUp() {
        Account acc = AOB_DAL_TesTFactory.createPersonAccount();
    }
    
    @IsTest
	private static void getAccountStatusEnquire()
    {
         Account acc = [SELECT Id , ExternalIdentifier__pc from Account LIMIT 1];
         acc.ExternalIdentifier__pc = 'ZA10111';
         acc.DR_Retain_Until_Date__pc = system.today();
         update acc;
        
        IdentityDocument idDoc = new IdentityDocument();
        idDoc.Name = '9901016392080';
        idDoc.RelatedLegalEntityId = acc.Id;
        idDoc.IdDocumentType = '1';
        idDoc.CMN_External_CIF_Country__c = 'ZA';
        insert idDoc;
       
        
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'enquire';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10111';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
        List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Success', accInfObjList[0].results, 'Success');
		Test.stopTest();
        
         
    }
    
    @IsTest
	private static void getAccountStatusDelete()
    {
         Account acc = [SELECT Id , ExternalIdentifier__pc from Account LIMIT 1];
         acc.ExternalIdentifier__pc = 'ZA10111';
         acc.DR_Retain_Until_Date__pc = system.today();
         update acc;
        
        
        IdentityDocument idDoc = new IdentityDocument();
        idDoc.Name = '9901016392080';
        idDoc.RelatedLegalEntityId = acc.Id;
        idDoc.IdDocumentType = '1';
        idDoc.CMN_External_CIF_Country__c = 'ZA';
        insert idDoc;
       
        
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'delete';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10111';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
        List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Success', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    }
    
     @IsTest
	private static void getAccountStatusNotFound()
    { 
        Account acc = [SELECT Id , ExternalIdentifier__pc from Account LIMIT 1];
        acc.ExternalIdentifier__pc = 'ZA10113';
        acc.DR_Retain_Until_Date__pc = system.today();
        update acc;
        
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'delete';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10111';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Not Found', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    }
    
      @IsTest
	private static void getAccountStatusNoteligiblefordeletion()
    {
        Account acc = [SELECT Id , ExternalIdentifier__pc from Account LIMIT 1];
        acc.ExternalIdentifier__pc = 'ZA10113';
        acc.DR_Retain_Until_Date__pc = system.today().addyears(5);
        acc.DR_Retain_Until__c = system.today();
        update acc;
        
        
        
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'delete';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10113';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Not eligible for deletion', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    }
}