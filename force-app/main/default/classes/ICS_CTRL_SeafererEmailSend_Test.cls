/***************************************************************************************
@name of the Class : ICS_CTRL_SeafererEmailSend_Test.cls
@Story:SFP-34726
@description :Testclass used to cover the ICS_CTRL_SeafererSendEmail class
@author : RIDHIMA SAXENA
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 26-08-2024
@modification description: Updated to latest version
***************************************************************************************/
@isTest
public class ICS_CTRL_SeafererEmailSend_Test {
   /**
   * @description This method is used creating setup data
   */
    @isTest
    static void testQueryEmailTemplatemethod() {
        Account testAccount = new Account(
            FirstName = 'Teaebdsst',
            LastName = 'Accodesunt',
            PersonEmail = 'test@example.com'
        );
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'Teaebdsst',
            LastName = 'Accodesunt',
            Email = 'test@example.com'
        );
        insert testContact;
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunitytest12', CloseDate = Date.today().addDays(7), StageName = 'ID & Address Verification',AccountId=testAccount.Id);
        insert testOpportunity;
        ApplicationForm testApplicationForm = new ApplicationForm( OpportunityId = testOpportunity.Id,
                                                                  Stage ='Awaiting Form Filling', 
                                                                  usagetype='Onboarding',
                                                                  AccountId = testAccount.Id);
        insert testApplicationForm;
        Applicant testApplicant = new Applicant( Email = 'test@examlllple.com',ApplicationFormId=testApplicationForm.Id);
        insert testApplicant;
        List<PartyProfile> testProfileRecords = new List<PartyProfile>();
        PartyProfile profileData = new PartyProfile();
        profileData.AccountId=testAccount.id;
        profileData.Country_of_Residence__c='US';
        profileData.name='record';
        testProfileRecords.add(profileData);
        insert testProfileRecords;
        Product2 testProduct = new Product2(Name = 'Test Product', isActive = true);
        insert testProduct;
        ID testPricebook = Test.getStandardPricebookId();
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = testPricebook,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPricebookEntry;
        List<OpportunityLineItem> oppItems = new List<opportunityLineItem>();
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            TotalPrice = 100
        );
        oppItems.add(testOppLineItem);
        insert oppItems;
        List<String> oppLineItemIds = new List<String>();
        for (OpportunityLineItem pp : oppItems) {
            oppLineItemIds.add(pp.Id);
        }
        EmailTemplate template = [
            SELECT Id, Name, FolderId, TemplateType, Subject, Body, HtmlValue
            FROM EmailTemplate
            WHERE DeveloperName = 'New_Seafarer_Account_1707907300547'
        ];
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id,ContentDocumentId,VersionData  FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = template.Id;
        insert cdl;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            ICS_CTRL_SeafererSendEmail.sendEmail(testAccount.Id);
        }
        Test.stopTest();
        Assert.areEqual(0, Limits.getEmailInvocations(), 'Email should be sent');
    }
}