/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :BCB_CTRL_FileUpload_Test
@description       :Test Class for dealing with FileUpload
@Last Modified By  :Lokesh Bothsa  
@Last Modified On  :25-05-2023
@Modification description : SFP-26345
***************************************************************************************/
@istest
public class BCB_CTRL_FileUpload_Test {
    /**
    * @description TestMethod for createContentVersionTest
    *
    */
    @isTest
    static void createContentVersionTest() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_GroupName__c='test';
        applicationList[0].AOB_RegistrationNumber__c='123456789';
        insert applicationList;
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].Application__c=applicationList[0].id;
        insert lstApp;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        String base64='Test Content';
        String filename='upload signature.pdf';
        Boolean isParticipant=true;
        contentVersion=BCB_CTRL_FileUpload.createContentVersion(base64,filename);
        cdl=BCB_CTRL_FileUpload.createContentLink(contentVersion.Id, cdl.LinkedEntityId);
        BCB_CTRL_FileUpload.getapplicationId(lstApp[0].id);
        String result = BCB_CTRL_FileUpload.uploadFileApplication(base64, filename, lstApp[0].id, document.Document_Type__c, isParticipant);
        BCB_CTRL_FileUpload.releatedFilesApplication(lstApp[0].id,isParticipant);
        BCB_CTRL_FileUpload.deleteDocumentFiles(cdl.id);
        BCB_CTRL_FileUpload.getRelatedFilesByRecordId(cdl.LinkedEntityId);
        BCB_CTRL_FileUpload.getExistcustomer(applicationList[0].AOB_RegistrationNumber__c);
        BCB_CTRL_FileUpload.getExistcustomerGroup(applicationList[0].AOB_GroupName__c);
        Assert.areNotEqual(null, cdl,'Test');
        Assert.areNotEqual(null, result,'Test'); 
        
    }
     /**
    * @description TestMethod for createContentVersionTest
    *
    */
    @isTest
    static void createContentVersionelseTest() {
        try{
            List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
            applicationList[0].AOB_GroupName__c='test';
            applicationList[0].AOB_RegistrationNumber__c='123456789';
            insert applicationList;
            List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
            lstApp[0].Application__c=applicationList[0].id;
            insert lstApp;
            Application_Document__c document = new Application_Document__c();
            document.Document_Type__c = 'upload signature';
            document.Application_Participant__c = lstApp[0].Id;
            insert document;
            ContentVersion cv = new ContentVersion();
            cv.VersionData =Blob.valueOf('Test Content');
            cv.Title ='upload signature';
            cv.PathOnClient = 'upload signature.pdf';
            insert cv;
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            cdl.ContentDocumentId = contentVersion.ContentDocumentId;
            cdl.LinkedEntityId = document.Id;
            cdl.ShareType = 'V';
            insert cdl;
            String base64='Test Content';
            String filename='upload signature.pdf';
            Boolean isParticipant=true;
            contentVersion=BCB_CTRL_FileUpload.createContentVersion(base64,filename);
            cdl=BCB_CTRL_FileUpload.createContentLink(contentVersion.Id, cdl.LinkedEntityId);
            BCB_CTRL_FileUpload.getapplicationId(lstApp[0].id);
            String result = BCB_CTRL_FileUpload.uploadFileApplication(base64, filename, document.id, document.Document_Type__c, isParticipant);
            Assert.areNotEqual(null, result,'Test'); 
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
        
    }   
    
}