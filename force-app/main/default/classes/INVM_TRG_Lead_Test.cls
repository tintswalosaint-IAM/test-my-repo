/**
* @description Tests the SVC_TRH_Case class
*
* @see SVC_TRH_Case
*
* @author Accenture
*
* @date July 2021
*/
@IsTest(SeeAllData = false)
private class INVM_TRG_Lead_Test {
    private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;
    public static final String  UNQUALIFIED = 'UnQualified';
    @IsTest
    private static void isLeadStatusHasChangedToUnqualified()
    {
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        Test.startTest();
        System.runAs(investmentManagerUser)
        {
            
            // create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            insert lead;
            //Check Investment Proposal record
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
            //Step 4 - update existing Investment proposal
            Investment_Proposal__c existingIP = lstInvP[0];
            existingIP.Lead__c = lead.Id;
            existingIP.INVM_PreparedByTitle__c = 'Portfolio Manager';
            existingIP.INVM_SummaryOfQualifications__c ='IAS';
            existingIP.INVM_ReferralRole__c='role';
            existingIP.INVM_ReferralName__c ='ref name';
            existingIP.INVM_ReferralSurname__c ='surname';
            existingIP.INVM_Background__c='background';
            existingIP.INVM_InvestmentAmount__c = 10000;
            existingIP.INVM_InvestmentObjective__c = 'Capital Preservation';
            existingIP.INVM_RiskProfile__c = 'Low Risk';
            existingIP.INVM_IncomeRequirements__c ='Yes';
            existingIP.INVM_InvestmentHorizon__c = 'Medium-term (3 to 5 years)';
            existingIP.INVM_TypeOfPortfolio__c='Trust';
            existingIP.INVM_AdditionalConsiderations__c='add';
            existingIP.INVM_ProposedMandate__c='RSA Portfolio';
            existingIP.INVM_ManagementFees__c=12;
            existingIP.INVM_TotalExpenseRatio__c=2;
            update existingIP;
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(existingIP.Id);
            
            List<Lead> lstLead = [Select Id, Status From Lead Where FinServ__RelatedAccount__c =: account.Id];
            System.assertEquals(1, lstLead.size());
            
            Lead theLead = lstLead[0];
            System.assertEquals('Nurturing', theLead.status);
            
            theLead.Status = 'UnQualified';
            update theLead;
            
            lstLead = [Select Id, Status From Lead Where FinServ__RelatedAccount__c =: account.Id];
            System.assertEquals(1, lstLead.size());
            System.assertEquals('UnQualified', theLead.status);
            
            lstInvP = [Select Id, INVM_GeneratedOn__c,INVM_Status__c, INVM_SentDate__c, INVM_PackageId__c, INVM_DocumentId__c,INVM_ClientComments__c,INVM_ClientResponse__c,  INVM_Client_RespondedDate__c  From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size()); 
            Investment_Proposal__c ip = lstInvP[0];
            System.assertEquals(null, ip.INVM_GeneratedOn__c);
            System.assertEquals(null, ip.INVM_Status__c);
            System.assertEquals(null, ip.INVM_SentDate__c);
            System.assertEquals(null, ip.INVM_PackageId__c);
            System.assertEquals(null, ip.INVM_DocumentId__c);
            System.assertEquals(null, ip.INVM_Client_RespondedDate__c);
            System.assertEquals(null, ip.INVM_ClientComments__c);
            System.assertEquals(null, ip.INVM_ClientResponse__c);
            
        }
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void isLeadStatusHasChangedToQualified()
    {
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        Test.startTest();
        System.runAs(investmentManagerUser)
        {
            
            // create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            insert lead;
            //Check Investment Proposal record
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
            //Step 4 - update existing Investment proposal
            Investment_Proposal__c existingIP = lstInvP[0];
            existingIP.Lead__c = lead.Id;
            existingIP.INVM_PreparedByTitle__c = 'Portfolio Manager';
            existingIP.INVM_SummaryOfQualifications__c ='IAS';
            existingIP.INVM_ReferralRole__c='role';
            existingIP.INVM_ReferralName__c ='ref name';
            existingIP.INVM_ReferralSurname__c ='surname';
            existingIP.INVM_Background__c='background';
            existingIP.INVM_InvestmentAmount__c = 10000;
            existingIP.INVM_InvestmentObjective__c = 'Capital Preservation';
            existingIP.INVM_RiskProfile__c = 'Low Risk';
            existingIP.INVM_IncomeRequirements__c ='Yes';
            existingIP.INVM_InvestmentHorizon__c = 'Medium-term (3 to 5 years)';
            existingIP.INVM_TypeOfPortfolio__c='Trust';
            existingIP.INVM_AdditionalConsiderations__c='add';
            existingIP.INVM_ProposedMandate__c='RSA Portfolio';
            existingIP.INVM_ManagementFees__c=12;
            existingIP.INVM_TotalExpenseRatio__c=2;
            update existingIP;
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(existingIP.Id);
            
            List<Lead> lstLead = [Select Id, Status From Lead Where FinServ__RelatedAccount__c =: account.Id];
            System.assertEquals(1, lstLead.size());
            
            Lead theLead = lstLead[0];
            System.assertEquals('Nurturing', theLead.status);
            
            theLead.Status = 'Qualified';
            update theLead;
            
            lstLead = [Select Id, Status From Lead Where FinServ__RelatedAccount__c =: account.Id];
            System.assertEquals(1, lstLead.size());
            System.assertEquals('Qualified', lstLead[0].status);
            
            lstInvP = [Select Id, INVM_GeneratedOn__c,INVM_Status__c, INVM_SentDate__c, INVM_PackageId__c, INVM_DocumentId__c,INVM_ClientComments__c,INVM_ClientResponse__c,  INVM_Client_RespondedDate__c  From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size()); 
            Investment_Proposal__c ip = lstInvP[0];
        }
        
        Test.stopTest();
        
    }
}