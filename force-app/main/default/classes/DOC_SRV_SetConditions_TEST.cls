/**
 * Test Class for DOC_SRV_SetConditions
 * 
 * <p>DBP-2295</p>
 * 
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 * 
 * @date Feb 26th 2021
 */
@IsTest
public class DOC_SRV_SetConditions_TEST {
	
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        System.runAs(communityUser){ 
            AOB_application__c newApplication = AOB_DAL_TestFactory.createApplication();
            // Create Document on new Application
            DOC_Document__c newDocument = new DOC_Document__c();
            newDocument.AOB_Application__c = newApplication.Id;
            newDocument.DOC_ConditionCode__c = 'CONTR';
            newDocument.Name = 'Contract Test Document';
            newDocument.DOC_DocumentGUID__c = '000100000000000000000000000502577336';
            insert newDocument;
            // Create Condition Key on new Document
            DOC_ConditionKey__c newConditionKey = new DOC_ConditionKey__c();
            newConditionKey.DOC_Document__c = newDocument.Id;
            newConditionKey.DOC_PartnerFunction__c = '00000001';
            newConditionKey.DOC_itemGuid__c = '0200200000161EDB89AE4DD94B970485';
            newConditionKey.DOC_recordId__c = '0200200000161EDB89AE4E85F345E4DA';
            newConditionKey.name = 'Condition Key Test';
            insert newConditionKey;
        }
        
    }
     
    /**
	 * @description Method used to Test setConditions API 
	 */
    @isTest
    public static void setConditions_Test(){
        //Get newly created Test Application
        User apiUser = AOB_DAL_TestFactory.createUser('System Administrator', false);
        AOB_application__c newApp = [SELECT Id FROM AOB_application__c LIMIT 1];
        DOC_Document__c newDocument = [SELECT Id,DOC_DocumentGUID__c FROM DOC_Document__c LIMIT 1];
        System.runAs(apiUser){ 
            Test.startTest();         
            newDocument.DOC_DocumentGUID__c = '0001000000880000000000000000502577336';
            update newDocument;
            System.assertEquals(newDocument.DOC_DocumentGUID__c,'0001000000880000000000000000502577336');
            Test.stopTest();
        }
    }
 }