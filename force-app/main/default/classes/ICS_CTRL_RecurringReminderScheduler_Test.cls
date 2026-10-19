/***************************************************************************************
@name of the Class : ICS_CTRL_RecurringReminderScheduler_Test.cls
@Story:SFP-34730
@description :Testclass used to cover the ICS_CTRL_RecurringReminderSchedulerClass class
@author : RIDHIMA SAXENA
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 26-08-2024
@modification description: Updated to latest version
***************************************************************************************/
@isTest
private class ICS_CTRL_RecurringReminderScheduler_Test {
      /**
   * @description This method is used creating setup data
   */
    @isTest
    static void testSchedulerMethod() {
        Account testAccount = new Account(
            FirstName = 'Test11',
            LastName = 'Account',
            PersonEmail = 'test@example.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
          insert testAccount;
         Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        List<Sales_Codes__c> salesCodes = ICS_DAL_TestFactory.createTestDataSalesCode();
		 RecordType oppRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'ICS Applicant' LIMIT 1];
        Opportunity opp=new Opportunity(
             Name = 'Test Opp',
            StageName = 'Application form',
            RecordTypeId = oppRecType.Id,
            AccountId = testAccount.Id,
               CloseDate = Date.today().addDays(30),
              Sales_Code__c = salesCodes[0].Id 
        );
            insert opp;
         ApplicationForm testForm = new ApplicationForm(
            AccountId = testAccount.Id,
             OpportunityId = opp.Id,
            Stage = 'Awaiting Verification',
             usagetype='Onboarding'
        );
        insert testForm;
        Test.startTest();
        testForm.Stage = 'Awaiting Form Filling';
        update testForm;
        Test.stopTest();
        ApplicationFormHistory appHis = new ApplicationFormHistory();
        appHis.Field = 'Stage';
         appHis.ApplicationFormId = testForm.Id;
         Insert appHis;
        ApplicationFormHistory ah =  [Select  Field, OldValue, NewValue ,id from ApplicationFormHistory where ApplicationFormId = :testForm.Id];
        Test.setCreatedDate(appHis.Id,system.now().addDays(-5));
        Test.setCreatedDate(ah.Id,system.now().addDays(-5));
        Map<String, Id> accountContactIds = new Map<String, Id>(); 
        Map<String, Id> accountIDS = new Map<String, Id>();
        List<Applicant> applicants = new List<Applicant>();
        Applicant testApplicant = new Applicant( Email = 'applicant@example.com',ApplicationFormId=testForm.Id,AccountId=testAccount.Id);
        applicants.add(testApplicant);
        if(applicants != null) {
		for (Applicant applicant : applicants) {
                accountContactIds.put(applicant.Account.PersonEmail, applicant.Account.PersonContactId);
                accountIDS.put(applicant.Account.PersonEmail , applicant.AccountId);
        }
        insert applicants;
        }
        ICS_CTRL_RecurringReminderSchedulerClass schedulableInstance = new ICS_CTRL_RecurringReminderSchedulerClass();
        schedulableInstance.execute(null);
        database.executebatch(new ICS_CTRL_RecurringReminderSchedulerClass() , 1);
        Assert.areEqual(0, Limits.getEmailInvocations(), 'Email should be sent');

    }
}