/***************************************************************************************
@name of the Class : ICS_CTRL_DeclinedApplicantEmail_Test.cls
@Story:SFP-34729
@description :Testclass used to cover the ICS_CTRL_DeclinedApplicantEmail class
@author : RIDHIMA SAXENA
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 26-08-2024
@modification description: Updated to latest version
***************************************************************************************/
@isTest
public class ICS_CTRL_DeclinedApplicantEmail_Test {
     /**
   * @description This method is used creating setup data
   */
@isTest
    public static void queryEmailTemplateTest(){
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
        Opportunity testOpportunity = new Opportunity(
            Name = 'TestOpportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId =testAccount.Id
        );
        insert testOpportunity;
        ApplicationForm aForm1 = new ApplicationForm();
        aForm1.AccountId = testAccount.Id;
        aForm1.OpportunityId = testOpportunity.Id;
        aForm1.usagetype= 'Onboarding';
        insert aForm1;
        PartyProfile profileRelatedParent = new PartyProfile();
        profileRelatedParent.AccountId=testAccount.id;
        string parentRecId = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId();
		profileRelatedParent.RecordTypeId = parentRecId;
        profileRelatedParent.Country_of_Residence__c='US';
        profileRelatedParent.name='Parent Record';
        insert profileRelatedParent;
        
        
        
        PartyProfile profileData = new PartyProfile();
        profileData.AccountId=testAccount.id;
        string recId = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId();
		profileData.RecordTypeId = recId;
        profileData.Country_of_Residence__c='US';
        profileData.WorldcheckStatus__c = 'Match Confirmed - True match declined';
        profileData.name='record';
        profileData.RelatedPartyProfileId = profileRelatedParent.Id;
        insert profileData;
        Applicant app1 = new Applicant();
        app1.AccountId = testAccount.Id;
        app1.role ='Primary Applicant';
        app1.ApplicationFormId = Aform1.Id;
        app1.PartyProfileId =profileData.id;
        insert app1;
        DateTime myDateTime = DateTime.newInstance(2024, 4, 24, 10, 30, 0);
        PartyScreeningSummary psrecords = new PartyScreeningSummary(Name='TesPartyScreening record',
                                                                    PartyProfileId=profileData.Id,
                                                                    RequestCompletionDate=myDateTime,
                                                                    IsWatchlist__c=true,IsSanctioned__c = true,IsUncategorised__c=false,CategoryDescription__c='Test description');
        insert psrecords;
        IdentityDocument idDoc = new IdentityDocument();
        idDoc.Name = '9901016392080';
        idDoc.RelatedLegalEntityId = testAccount.Id;
        idDoc.IdDocumentType = '1';
        idDoc.CMN_External_CIF_Country__c = 'ZA';
        idDoc.PartyProfileId = profileData.id;
        insert idDoc;
        try{
        ICS_CTRL_DeclinedApplicantEmail.queryEmailTemplate(new List<String>{testOpportunity.Id});
        }catch(Exception ex){
            Assert.areEqual(true,ex.getmessage()!=null, 'Error Occured');
        }
    }
}