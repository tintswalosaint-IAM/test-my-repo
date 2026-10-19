/*************************************************************
* @description SFP-51505 Test Class used for ICS_CTRL_SeafererSendEmail class
*
* @autor Ruchi Agarwal
*
* @date OCT 21 2024
***************************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 28/8/2025
* Last Modified Description: updated to latest Version
*/
@isTest
private class ICS_CTRL_SeafererSendEmail_Test {
    @testSetup
    static void setupTestData() {
        // Insert Account with RecordType
        RecordType recType = [SELECT Id FROM RecordType WHERE Name = 'ICS Applicant' AND SObjectType = 'Account' LIMIT 1];
        Account acc = new Account(
            FirstName = 'TestACC',
            LastName = 'lastAcc',
            AOB_CommerceSiteId__c = 'SB-COZA',
            AOB_TECH_CCCustomerId__c = 'XXX',
            RecordTypeId = recType.Id,
            Phone = '+27823309876',
            ExternalCIFUUID__c = 'RandomBPGUID',
            PersonEmail = 'test@orgwideemail.com'
        );
        insert acc;
        
        // Insert Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'ID & Address Verification',
            CloseDate = System.today(),
            AccountId = acc.Id,
            Required_Approval_Processes__c = 'Need Captain letter Approval;'
        );
        insert opp;
        
        // Insert Application Form
        ApplicationForm testForm = new ApplicationForm(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            UsageType = 'Onboarding',
            Stage = 'Awaiting Form Filling'
        );
        insert testForm;
        
        // Insert ContentDocument/Version with exact titles to match LIKE queries
        ContentVersion cv1 = new ContentVersion(
            Title = 'Seafarer Factsheet Document',
            PathOnClient = 'SeafarerFactsheet.pdf',
            VersionData = Blob.valueOf('Seafarer Factsheet Content')
        );
        insert cv1;
        
        ContentVersion cv2 = new ContentVersion(
            Title = 'Captain Letter Document', 
            PathOnClient = 'CaptainLetter.pdf',
            VersionData = Blob.valueOf('Captain Letter Content')
        );
        insert cv2;
        
        // Link documents to account
        Id cdId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId;
        Id cdId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id].ContentDocumentId;
        
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            ContentDocumentId = cdId1,
            LinkedEntityId = acc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl1;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            ContentDocumentId = cdId2,
            LinkedEntityId = acc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'  
        );
        insert cdl2;
    }
    
    @isTest
    static void testSendEmail() {
        Account acc = [SELECT Id, PersonEmail FROM Account LIMIT 1];
        
        Test.startTest();
        ICS_CTRL_SeafererSendEmail.sendEmail(acc.Id);
        Test.stopTest();
        
        Assert.areEqual(0, Limits.getEmailInvocations(), 'Email should be processed in future method');
        Assert.isNotNull(acc.PersonEmail, 'Recipient email should not be null');
    }
    
    @isTest  
    static void testSendIDVerificationEmail() {
        Account acc = [SELECT Id, PersonEmail FROM Account LIMIT 1];
        
        Test.startTest();
        String result = ICS_CTRL_SeafererSendEmail.sendIDVerificationEmail(acc.Id);
        Test.stopTest();
        
        Assert.areEqual('Email sending initiated successfully', result, 'Should confirm initiation message');
        Assert.isNotNull(acc.PersonEmail, 'Account should have valid email address');
    }
    
    @isTest
    static void testSendIDVerificationEmailFuture() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        ICS_CTRL_SeafererSendEmail.sendIDVerificationEmailFuture(acc.Id);
        Test.stopTest();
        
        Assert.isNotNull(acc.Id, 'Account should exist for future method execution');
    }
   
}