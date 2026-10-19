/**
 * Test class of AOB_CTRL_DocumentUpload
 * 
 * <p>DBP-1467</p> 
 * 
 * @author Achraf ABOUL (aaboul@salesforce.com)
 * 
 * @date Dec 30th 2020 
 */
@IsTest
public with sharing class AOB_CTRL_DocumentUpload_Test {
    /**
	 * @description Test setup method to insert all Test data
	 */
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
        
    }
    
    /**
	 * @description Method used to Test callgetAccessToken 
	 */
    @IsTest
    public static void callgetAccessToken_Test(){
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            string token = AOB_CTRL_DocumentUpload.callAccessToken();
            Test.stopTest();
            system.assertEquals(token,'AAIkYzc0NmM');
        }
    }
    /**
	 * @description Method used to Test getDocumentsToUpload 
	 */
    @IsTest
    public static void getDocumentsToUpload_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) { 
            Test.startTest();
            AOB_DTO_Documents response = (AOB_DTO_Documents) JSON.deserialize(AOB_CTRL_DocumentUpload.getDocumentsToUpload(), AOB_DTO_Documents.class);
            Test.stopTest();
            system.assertNotEquals(response,null);
        }
    }
    
    /**
	 * @description Method used to Test uploadFiles 
	 */
    @IsTest
    public static void uploadFiles_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Test.startTest();
        Integer response = AOB_CTRL_DocumentUpload.uploadFiles('[{"conditionCode": "conditionCode","conditionDescription": "conditionDescription","fileName": "fileName.txt","fileData": "fileData"}]', app.Id);
        List<DOC_Document__c> uploadedDocuments = [SELECT Id FROM DOC_Document__c WHERE AOB_Application__c = :app.Id];
        system.assertEquals(response, 1);
        system.assertEquals(uploadedDocuments.size(), 1);
        Test.stopTest();
	}
}