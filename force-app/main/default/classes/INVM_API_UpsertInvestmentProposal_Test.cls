/**
* @description Tests the INVM_API_UpsertInvestmentProposal
*
* @see INVM_API_UpsertInvestmentProposal
*
* @author Wipro
*
* @date July 2022
*/
@IsTest(SeeAllData = false)
Private class INVM_API_UpsertInvestmentProposal_Test {
    
    /**
* @description Sets up the RestContext Objects
*
* @param dtoRequest The Investment Proposal Upsert Request DTO
*
* @see INVM_API_UpsertInvestmentProposal.DTO_Request
*/
    private static void setupRestContextApprove(INVM_API_UpsertInvestmentProposal.DTO_Request dtoRequest)
    {
        dtoRequest.documentId = '1234';
        dtoRequest.packageId = '2345';
        dtoRequest.clientResponse = 'COMPLETED';
        dtoRequest.strAddtionalComments = 'I am good';
        
        CMN_API_InboundTestHelper.setupRestContext(dtoRequest);
    }
    
    private static void setupRestContextDecline(INVM_API_UpsertInvestmentProposal.DTO_Request dtoRequest)
    {
        dtoRequest.documentId = '1234';
        dtoRequest.packageId = '2345';
        dtoRequest.clientResponse = 'DECLINED';
        dtoRequest.strAddtionalComments = 'I am not happy';
        
        CMN_API_InboundTestHelper.setupRestContext(dtoRequest);
    }
    
    @IsTest
    private static void isApproveConsentCaptured()
    {
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        
        Test.startTest();
        System.runAs(investmentManagerUser)
        {
            
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = INVM_Constants.LEADNURTURING;
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
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(existingIP.Id);
            
            list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
            
            for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: existingIP.Id Order by SystemModStamp desc]) {
                lstCntDocsToDelete.add(new ContentDocument(Id = iterator.ContentDocumentId));
            }
            System.assertEquals(1, lstCntDocsToDelete.size());
            
            Investment_Proposal__c anotherIP = existingIP;
            anotherIP.Lead__c = lead.Id;
            anotherIP.INVM_PreparedByTitle__c = 'Portfolio Manager';
            anotherIP.INVM_SummaryOfQualifications__c ='IAS';
            anotherIP.INVM_ReferralRole__c='role';
            anotherIP.INVM_ReferralName__c ='ref name';
            anotherIP.INVM_ReferralSurname__c ='surname';
            anotherIP.INVM_Background__c='background';
            anotherIP.INVM_InvestmentAmount__c = 10000;
            anotherIP.INVM_InvestmentObjective__c = 'Capital Preservation';
            anotherIP.INVM_RiskProfile__c = 'Low Risk';
            anotherIP.INVM_IncomeRequirements__c ='Yes';
            anotherIP.INVM_InvestmentHorizon__c = 'Medium-term (3 to 5 years)';
            anotherIP.INVM_TypeOfPortfolio__c='Trust';
            anotherIP.INVM_AdditionalConsiderations__c='add 2';
            anotherIP.INVM_ProposedMandate__c='RSA Portfolio';
            anotherIP.INVM_ManagementFees__c=12;
            anotherIP.INVM_TotalExpenseRatio__c=2;
            update anotherIP;
            
            INVM_CSF_DocumentGeneration.callCSFServiceToGeneratePDF(anotherIP.Id);
            
            for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: existingIP.Id Order by SystemModStamp desc]) {
                lstCntDocsToDelete.add(new ContentDocument(Id = iterator.ContentDocumentId));
            }
            System.assertEquals(3, lstCntDocsToDelete.size());
            
            lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
 
            Investment_Proposal__c invP = lstInvP[0];
            invp.INVM_DocumentId__c = '1234';
            invp.INVM_PackageId__c= '2345';
            invp.INVM_Status__c ='Sent For Approval';
            update invp;
            
            
            lstInvP = [Select Id, INVM_GeneratedOn__c,INVM_Status__c, INVM_SentDate__c, INVM_PackageId__c, INVM_DocumentId__c,INVM_ClientComments__c,INVM_ClientResponse__c,  INVM_Client_RespondedDate__c  From Investment_Proposal__c Where INVM_PackageId__c = '2345' and  INVM_DocumentId__c = '1234'];
            System.assertEquals(1, lstInvP.size()); 
            Investment_Proposal__c ip = lstInvP[0];
            ip.INVM_ClientResponse__c = 'APPROVED';
            ip.INVM_ClientComments__c = 'I am good';
            ip.INVM_Status__c = 'Received Response';
            update ip;
            INVM_API_UpsertInvestmentProposal.deleteOlderInvestmentProposals(existingIP.Id);
            Investment_Proposal__c ip1 = lstInvP[0];
            ip1.INVM_ClientResponse__c = 'APPROVED';
            ip1.INVM_ClientComments__c = 'I am good';
            ip1.INVM_Status__c = 'Received Response';
            update ip1;
            INVM_API_UpsertInvestmentProposal.DTO_Request dtoRequest = new INVM_API_UpsertInvestmentProposal.DTO_Request();
            
            setupRestContextApprove(dtoRequest);
            INVM_URL_InvestmentProposal.upsertInvestmentProposal();
            
             lstInvP = [Select Id, INVM_GeneratedOn__c,INVM_Status__c, INVM_SentDate__c, INVM_PackageId__c, INVM_DocumentId__c,INVM_ClientComments__c,INVM_ClientResponse__c,  INVM_Client_RespondedDate__c  From Investment_Proposal__c Where INVM_PackageId__c = '2345' and  INVM_DocumentId__c = '1234'];
            System.assertEquals(1, lstInvP.size());
            System.assertEquals('APPROVED', lstInvP[0].INVM_ClientResponse__c); 
            
        }
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void isDeclineConsentCaptured()
    {
        User investmentManagerUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_INVESTMENT_MANAGER);
        Test.startTest();
        System.runAs(investmentManagerUser)
        {
            
            Account account = new Account();
            account.LastName = 'AccTest1';
            insert account;
            
            Lead lead = new Lead();
            lead.LastName = 'Last Name';
            lead.FirstName='First Name';
            lead.status = 'New';
            lead.Company='Lead Company';
            lead.RecordTypeId =Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
            lead.FinServ__RelatedAccount__c = account.Id;
            insert lead;
            
            List<Investment_Proposal__c> lstInvP = [Select Id From Investment_Proposal__c Where Lead__c =: lead.Id];
            System.assertEquals(1, lstInvP.size());
            
            Investment_Proposal__c invP = lstInvP[0];
            invp.INVM_DocumentId__c = '1234';
            invp.INVM_PackageId__c= '2345';
            invp.INVM_Status__c ='Sent For Approval';
            update invp;
            
            lstInvP = [Select Id, INVM_GeneratedOn__c,INVM_Status__c, INVM_SentDate__c, INVM_PackageId__c, INVM_DocumentId__c,INVM_ClientComments__c,INVM_ClientResponse__c,  INVM_Client_RespondedDate__c  From Investment_Proposal__c Where INVM_PackageId__c = '2345' and  INVM_DocumentId__c = '1234'];
            System.assertEquals(1, lstInvP.size()); 
            Investment_Proposal__c ip = lstInvP[0];
            ip.INVM_ClientResponse__c = 'Decline';
            ip.INVM_ClientComments__c = 'Not Interested';
            ip.INVM_Status__c = 'Received Response';
            update ip;
            
            INVM_API_UpsertInvestmentProposal.DTO_Request dtoRequest = new INVM_API_UpsertInvestmentProposal.DTO_Request();
            
            setupRestContextDecline(dtoRequest);
            
            INVM_URL_InvestmentProposal.upsertInvestmentProposal();
            
            lstInvP = [Select Id, INVM_GeneratedOn__c,INVM_Status__c, INVM_SentDate__c, INVM_PackageId__c, INVM_DocumentId__c,INVM_ClientComments__c,INVM_ClientResponse__c,  INVM_Client_RespondedDate__c  From Investment_Proposal__c Where INVM_PackageId__c = '2345' and  INVM_DocumentId__c = '1234'];
            System.assertEquals(1, lstInvP.size());
            System.assertEquals('Decline', lstInvP[0].INVM_ClientResponse__c); 
            
        }
        
        Test.stopTest();
    }
    
}