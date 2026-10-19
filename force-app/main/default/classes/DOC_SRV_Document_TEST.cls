@isTest
public class DOC_SRV_Document_TEST {

	@TestSetup
	static void testSetUp(){
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.contactId)];
		Map<String,String> objectData = new Map<string,string>{'AOB_Customer__c'=> acc.id};
        System.runAs(communityUser){
            AOB_Application__c app = (AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',objectData);
            insert app;
            objectData = new  Map<String,String>{'AOB_Application__c'=> app.Id};
            DOC_Document__c doc =(DOC_Document__c) AOB_DAL_TesTFactory.genericObjectCreation('DOC_Document__c',objectData);
            insert doc;
        }
    }
	/** 
    * @description Updates Custom Object Document with master content doc link TEST
    */
	@isTest
    public static void updateDocuments_Test(){

		User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
		List<DOC_Document__c> docs=[SELECT Id,DOC_MasterContentId__c FROM DOC_Document__c LIMIT 1];
		Map<Id,Id> mapIdToId = new Map<Id,Id>{docs[0].Id => communityUser.Id };
		
        System.runAs(communityUser) {
            Test.startTest();
            DOC_SRV_Document.updateDocuments(mapIdToId);
            Test.stopTest();
			docs = [SELECT Id,DOC_MasterContentId__c FROM DOC_Document__c WHERE Id = :docs[0].Id];
            System.assertNotEquals(null, docs, 'No document found');
            System.assertEquals(communityUser.Id, docs[0].DOC_MasterContentId__c, 'No document found');
		}
    }
	/**
    * @description create Documents Case TEST
    */
	@isTest
    public static void createDocumentsCase_Test(){

		User communityUser = [SELECT Id , contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc=[SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.contactId)];
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
		
        System.runAs(communityUser) {
            Test.startTest();
          	Case ca = DOC_SRV_Document.createDocumentsCase(app.Id);
            Test.stopTest();
          }
    }

	/**
    * @description create Legal Options Case Test
    */
	@isTest
    public static void createLegalOptionsCase_Test(){
		User communityUser = [SELECT Id , contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc = [SELECT Id ,AOB_ProminentInfluentialPerson__c FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.contactId)];
		acc.AOB_ProminentInfluentialPerson__c = true;
		update acc;
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
        System.runAs(communityUser) {
            Test.startTest();
          	Case ca = DOC_SRV_Document.createLegalOptionsCase(app.Id);
            Test.stopTest();
            System.assertNotEquals(null, ca, 'No case found');
        }
    }
	/**
    * @description upload Documents 2 Test
    */
	@isTest
    public static void uploadDocuments2_Test(){
		User communityUser = [SELECT Id , contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc = [SELECT Id ,AOB_ProminentInfluentialPerson__c FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.contactId)];
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
            Test.startTest();
          	List<DOC_Document__c>  docs = DOC_SRV_Document.uploadDocuments('[{"conditionCode": "conditionCode","conditionDescription": "conditionDescription","fileName": "fileName.txt","fileData": "fileData"}]',app.Id);
            Test.stopTest();
            System.assertNotEquals(null, docs, 'No docs found');
    }
    /**
    * @description assign Case to Queue Test
    */
	@isTest
    public static void assignCaseToQueue_Test(){
    	User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.contactId)];
		Map<String,String> objectData = new Map<string,string>{'AOB_Customer__c'=> acc.id};
        System.runAs(communityUser){
            AOB_Application__c app = (AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',objectData);
        	Test.startTest();
        		Case ca = DOC_SRV_Document.createDocumentsCase(app.Id);
        		DOC_SRV_Document.assignCaseToQueue('DOCUMENT',ca.Id,app.Id);
        	Test.stopTest();
        	List<Case> cases = [SELECT Id, OwnerId FROM Case WHERE Id = :ca.Id];
            System.assertNotEquals(null, cases, 'No case found');
       
        }
    }
    
     /**
    * @description assign addDocumentsToCase Test
    */
	@isTest
    public static void addDocumentsToCase_Test(){
      User communityUser = AOB_DAL_TestFactory.createCommunityUser();
      Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.contactId)];
	  Map<String,String> objectData = new Map<string,string>{'AOB_Customer__c'=> acc.id};
      System.runAs(communityUser){
            AOB_Application__c app = (AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',objectData);  
 	  		Case ca = DOC_SRV_Document.createDocumentsCase(app.Id);	
      		List<DOC_Document__c> createdDocuments = new List<DOC_Document__c>();
            objectData = new  Map<String,String>{'AOB_Application__c'=> app.Id};
            DOC_Document__c doc =(DOC_Document__c) AOB_DAL_TesTFactory.genericObjectCreation('DOC_Document__c',objectData);
      		createdDocuments.add(doc); 
          	try {
                Test.startTest();  
                    List<DOC_Document__c> docList = DOC_SRV_Document.addDocumentsToCase(ca.Id,createdDocuments);
                Test.stopTest();
                System.assertNotEquals(null, docList, 'No docs found');
            } catch (Exception e) {
                System.debug(e);
            }
      }   
    }   
}