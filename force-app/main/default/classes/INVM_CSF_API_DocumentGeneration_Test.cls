@IsTest(SeeAllData=false)
Private class INVM_CSF_API_DocumentGeneration_Test {
    @isTest
    private static void testGetAccessTokenAndGenerateDocument() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            INVM_Constants.testStrings();   
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            
            Lead lead = new Lead();
            lead.Salutation = '041';
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            insert lead;
            
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
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
            
            CMN_DTO_AuthenticationResponse token = INVM_CSF_API_DocumentGeneration.getAccessToken('document prod write');
            System.assert(token!= null);
            
            List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{lstInvP[0].Id});
            HttpResponse responseCSFTemplate = INVM_CSF_API_DocumentGeneration.getDocumentTemplate(token.access_token,lstInvProp);
            System.assert(responseCSFTemplate!= null);
            System.assertEquals(1, lstInvProp.size());
            String s = INVM_CSF_API_DocumentGeneration.getRequestBodyForDocumentGeneration(lstInvProp);
            
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testError() {
       
        Exception e;
        CMN_UTIL_Logger.error(e, 'CSF_DocumentGeneration.callCSFServiceToGeneratePDF');
        String strMockError = '{"status":500,"body":{"exceptionType":"System.AssertException","isUserDefinedException":false,"message":"Assertion Failed: Expected: null, Actual: System.HttpResponse[Status=OK, StatusCode=200]","stackTrace":"Class.INVM_BankingDetailsService.getBankDetailByBPID: line 33, column 1"},"headers":{},"ok":false,"statusText":"Server Error","errorType":"fetchResponse"}';
        Test.startTest();
        INVM_CSF_DocumentGeneration.sendExceptionEmail(strMockError);
        Test.stopTest();
        System.assertEquals(strMockError, INVM_CSF_DocumentGeneration.stringError);
    }
    
    @isTest
    private static void testGetAccessTokenAndSendDocument() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            
            Lead lead = new Lead();
            lead.Salutation = '041';
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            insert lead;
            
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
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
            
            CMN_DTO_AuthenticationResponse token = INVM_CSF_API_DocumentGeneration.getAccessToken('document prod write');
            System.assert(token!= null);
            
            List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{existingIP.Id});
            HttpResponse responseCSFTemplate = INVM_CSF_API_DocumentGeneration.getDocumentTemplate(token.access_token,lstInvProp);
            System.assert(responseCSFTemplate!= null);
            String s = INVM_CSF_API_DocumentGeneration.getRequestBodyForDocumentGeneration(lstInvProp);
            String s1 = INVM_CSF_API_DocumentGeneration.getRequestBodyForDocumentGeneration(null);
            System.assert(s1 == null);
        }
        
        Test.stopTest();
    }
    @isTest
    private static void testGenerateDocumentWhenLeadUnqualified() {
        Test.startTest();
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        System.runAs(investmentManagerUser)
        {
            
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = INVM_Constants.UNQUALIFIED;
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            lead.Email = 'demo@test.com';
            insert lead;
            
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
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
            upsert existingIP;
            
            lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
 
            String errorMes = INVM_CSF_DocumentGeneration.getSendingErrors(lstInvP[0].Id);
            String err = String.format(System.Label.INVM_LeadUnqualified,
                                       new List<String>{'Generate'});
            System.assertEquals(err, errorMes);

        }
    }
}