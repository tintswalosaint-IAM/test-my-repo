@IsTest(SeeAllData=false)
Private class INVM_SigningHub_SendInvProposal_Test {
    
     
    
    @isTest
    private static void testGetAccessTokenAndSendDocument() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
             
            
            // Step 1 - create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // Step 2 - create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            insert lead; 
            //Step3 - Auto creation od Investment Proposal record
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.id];
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
             INVM_SigningHub_SendInvestmentProposal.getSendingErrors(existingIP.Id);
            //Step 5 - Generate Investment Proposal Document  
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(existingIP.Id);
            lstInvP = [Select Id, INVM_Status__c From Investment_Proposal__c Where Id =: existingIP.Id];
            System.assertEquals(1, lstInvP.size());
            
            INVM_SigningHub_SendInvestmentProposal.callSHServiceToSendInvestmentProposal(existingIP.Id);
            lstInvP = [Select Id, INVM_Status__c From Investment_Proposal__c Where Id =: existingIP.Id];
            System.assertEquals(1, lstInvP.size());     
        }
    }
    
    @isTest
    private static void testSendDocumentWithLeadQualified() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            // Step 1 - create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // Step 2 - create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = INVM_Constants.LEADQUALIFIED;
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            lead.Email = 'demo@test.com';
            insert lead;
            //Step3 - Auto creation od Investment Proposal record
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
            //Step 5 - Generate Investment Proposal Document  
            String errorMes = INVM_SigningHub_SendInvestmentProposal.getSendingErrors(existingIP.Id);
            System.assertEquals('Because the lead is qualified, you are unable to Send an investment proposal document.', errorMes);
            
        }
    }
    
    @isTest
    private static void testSendDocumentWithLeadUnQualified() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            // Step 1 - create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // Step 2 - create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = INVM_Constants.UNQUALIFIED;
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            lead.Email = 'demo@test.com';
            insert lead;
            //Step3 - Auto creation od Investment Proposal record
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
            //Step 5 - Generate Investment Proposal Document  
            String errorMes = INVM_SigningHub_SendInvestmentProposal.getSendingErrors(existingIP.Id);
            System.assertEquals('Lead is Unqualified, so you cannot Send Investment Proposal Document. Please update lead to Nurturing.', errorMes);
            
        }
    }
    
    @isTest
    private static void testErrorSendDocument() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            // Step 1 - create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // Step 2 - create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            lead.Email = 'demo@test.com';
            insert lead;
            //Step3 - Auto creation od Investment Proposal record
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
            //Step 5 - Generate Investment Proposal Document  
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(existingIP.Id);
            
            INVM_SigningHub_SendInvestmentProposal.callSHServiceToSendInvestmentProposal(existingIP.Id);
            INVM_SigningHub_SendInvestmentProposal.getSendingErrors(existingIP.Id);
            
			INVM_SigningHub_SendInvestmentProposal.updateInvestmentProposalRecord('1','2',existingIP.Id);          
        }
    }
    @isTest
    private static void testNoFileWhileSendDocument() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            // Step 1 - create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // Step 2 - create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            lead.Email = 'demo@test.com';
            insert lead;
            //Step3 - Auto creation od Investment Proposal record
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
            //Step 5 - Generate Investment Proposal Document  
            
            INVM_SigningHub_SendInvestmentProposal.getSendingErrors(existingIP.Id);
            
		
        }
    }
    
    @isTest
    private static void testWebService() {
        
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            // Step 1 - create account
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            // Step 2 - create Lead
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            lead.Email = 'demo@test.com';
            insert lead;
            //Step3 - Auto creation od Investment Proposal record
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
            
           CMN_WebserviceSetting__mdt obj = INVM_CSF_API_DocumentGeneration.webServiceSetting;
           system.assert(obj!= null);
		
        }
    }
}