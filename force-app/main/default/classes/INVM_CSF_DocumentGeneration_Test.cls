@IsTest(SeeAllData=false)
Private class INVM_CSF_DocumentGeneration_Test {
    @isTest
    private static void testGetAccessTokenAndGenerateDocument() {
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
            
            Investment_Proposal__c anotherIP = lstInvP[0];
            anotherIP.Lead__c = lead.Id;
            anotherIP.INVM_PreparedByTitle__c = 'Portfolio Manager';
            anotherIP.INVM_SummaryOfQualifications__c ='IAS';
            anotherIP.INVM_ReferralRole__c='role';
            anotherIP.INVM_ReferralName__c ='ref name';
            anotherIP.INVM_ReferralSurname__c ='surname';
            anotherIP.INVM_Background__c='background';
            anotherIP.INVM_InvestmentAmount__c = 50000;
            anotherIP.INVM_InvestmentObjective__c = 'Capital Preservation';
            anotherIP.INVM_RiskProfile__c = 'Low Risk';
            anotherIP.INVM_IncomeRequirements__c ='Yes';
            anotherIP.INVM_InvestmentHorizon__c = 'Medium-term (3 to 5 years)';
            anotherIP.INVM_TypeOfPortfolio__c='Trust';
            anotherIP.INVM_AdditionalConsiderations__c='add';
            anotherIP.INVM_ProposedMandate__c='RSA Portfolio';
            anotherIP.INVM_ManagementFees__c=12;
            anotherIP.INVM_TotalExpenseRatio__c=2;
            update anotherIP;
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(anotherIP.Id);
            
            INVM_SigningHub_SendInvestmentProposal.callSHServiceToSendInvestmentProposal(existingIP.Id);
            
            String s = INVM_SigningHub_API_SendInvProposal.getSigningHubRequestBody(existingIP.Id);
            //Step 5.1 - Get Access Token  
            CMN_DTO_AuthenticationResponse token = INVM_CSF_API_DocumentGeneration.getAccessToken('document prod write');
            system.assert(token!= null);
            
            //Step 5.2 - getDocument Template  
            List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{existingIP.Id});
            HttpResponse responseCSFTemplate = INVM_CSF_API_DocumentGeneration.getDocumentTemplate(token.access_token,lstInvProp);
            system.assert(responseCSFTemplate!= null);
            //INVM_CreatePackageAPIResponse apiResponse = INVM_CreatePackageAPIResponse.parse(INVM_SigningHub_API_SendInvProposal.sendInvestmentProposal(token.access_token,existingIP.Id).getBody());
            
        }
    }
    
    @isTest
    private static void testError() {
        Test.startTest();
        Exception e;
        CMN_UTIL_Logger.error(e, 'CSF_DocumentGeneration.callCSFServiceToGeneratePDF');
        String strMockError = '{"status":500,"body":{"exceptionType":"System.AssertException","isUserDefinedException":false,"message":"Assertion Failed: Expected: null, Actual: System.HttpResponse[Status=OK, StatusCode=200]","stackTrace":"Class.INVM_BankingDetailsService.getBankDetailByBPID: line 33, column 1"},"headers":{},"ok":false,"statusText":"Server Error","errorType":"fetchResponse"}';
        
        INVM_CSF_DocumentGeneration.sendExceptionEmail(strMockError);
        
        INVM_SigningHub_SendInvestmentProposal.sendExceptionEmail(strMockError);
        
        CMN_DTO_AuthenticationResponse token = INVM_CSF_API_DocumentGeneration.getAccessToken(null);        
        Test.stopTest();
        system.assert(token!= null);
        
       /* Exception e;
        CMN_UTIL_Logger.error(e, 'INVM_BankingDetailsService.callCSFServiceToGeneratePDF');
        String strMockError = '{"status":500,"body":{"exceptionType":"System.AssertException","isUserDefinedException":false,"message":"Assertion Failed: Expected: null, Actual: System.HttpResponse[Status=OK, StatusCode=200]","stackTrace":"Class.INVM_BankingDetailsService.getBankDetailByBPID: line 33, column 1"},"headers":{},"ok":false,"statusText":"Server Error","errorType":"fetchResponse"}';
        Test.startTest();
        INVM_BankingDetailsService.sendExceptionEmail(strMockError);
        Test.stopTest();
        System.assertEquals(strMockError, INVM_BankingDetailsService.stringError);*/
    }
    
    @isTest
    private static void testValidationAlreadySentForApproval() {
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
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(existingIP.Id);
            
            String error =  INVM_CSF_DocumentGeneration.getSendingErrors(existingIP.Id);
        }
    }
    
    @isTest
    private static void testGenerateTemplateWhenLeadStatusIsUnqualified() {
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
            String error =  INVM_CSF_DocumentGeneration.getSendingErrors(existingIP.Id);
            system.assertEquals('Lead is Unqualified, so you cannot Generate Investment Proposal Document. Please update lead to Nurturing.', error);
        }
    }
    
     @isTest
    private static void testGenerateTemplateWhenLeadStatusIsQualified() {
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
            insert lead;
            //Step3 - Auto creation od Investment Proposal record
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
            //Step 5 - Generate Investment Proposal Document  
            String error =  INVM_CSF_DocumentGeneration.getSendingErrors(lstInvP[0].Id);
            system.assertEquals('Please fill in all the required fields in the Investment Proposal record before generating the document.', error);
            
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
            
            String error1 =  INVM_CSF_DocumentGeneration.getSendingErrors(existingIP.Id);
            system.assertEquals('Because the lead is qualified, you are unable to Generate an investment proposal document.', error1);
        }
    }
    
}