/**
* @description Provides Query methods related to Investment Proposal object
*
* @see INVM_DAL_InvestmentProposal_TEST 
*
* 
*
* @date 2022
*/
public inherited sharing class INVM_DAL_InvestmentProposal {
    @TestVisible
    private static final String SOBJECT_NAME = Investment_Proposal__c.SObjectType.getDescribe().getLocalName();
    
    public static final Set <String> SOBJECT_FIELDS = new Set<String>
    {
        Investment_Proposal__c.Id.getDescribe().getName(),
            Investment_Proposal__c.Name.getDescribe().getName(),
            Investment_Proposal__c.INVM_AdditionalConsiderations__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_Background__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_GeneratedOn__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_IncomeRequirements__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_InvestmentHorizon__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_InvestmentObjective__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_InvestmentProposalGenerated__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_TypeOfPortfolio__c.getDescribe().getName(),
            Investment_Proposal__c.Lead__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ManagementFees__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_MarketDrawdowns__c.getDescribe().getName(),
            Investment_Proposal__c.OwnerId.getDescribe().getName(),
            Investment_Proposal__c.INVM_ProposalDate__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ProposedMandate__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_RiskProfile__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_TotalExpenseRatio__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ProposedRiskMandate__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_PreparedByTitle__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_SummaryOfQualifications__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ReferralName__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ReferralRole__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ReferralSurname__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_LeadId__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_ClientResponse__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_LatestInvestmentProposal__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_Status__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_packageId__c.getDescribe().getName(),
            Investment_Proposal__c.INVM_DocumentId__c.getDescribe().getName(),            
            Investment_Proposal__c.LastModifiedDate.getDescribe().getName(),
            Investment_Proposal__c.INVM_RespondedDate__c.getDescribe().getName(),
            'Lead__r.Status',
            'Lead__r.Name', 
            'Lead__r.Email',
            'Owner.Phone', 
            'Owner.Email',
            'owner.Name',
            'toLabel(lead__r.Salutation)',
            'INVM_InvestmentAmount__c',
            'CurrencyIsoCode'
            };
                
                /**
* @description Will return all the Foobar objects in the system
*
* @return A list of Foobar objects
*/
	@TestVisible
    private static List<Investment_Proposal__c> getAll()
    {
		return CMN_DAL_Search.getAll(SOBJECT_NAME);
    }
    
    /**
* @description Select by Id (will use default fields)
*
* @param ids as input
*
* @return List of foobar sobjects with default fields
*/
    public static List<Investment_Proposal__c> selectByIds(Set<Id> ids)
    {
        
        return (List<Investment_Proposal__c>)CMN_DAL_SObjectSelector.findById(SOBJECT_NAME, ids, SOBJECT_FIELDS);
    }
    
    
    public static Investment_Proposal__c  selectIPByLead(Id leadId)
    {
        Investment_Proposal__c InvP = [Select Id ,INVM_ClientResponse__c , INVM_GeneratedOn__c From Investment_Proposal__c Where INVM_LeadId__c  =: leadId];
        return InvP;
    }
    
    public static Investment_Proposal__c  selectIPByPackageDocumentId(String packageId, String documentId)
    {
        try{
            Investment_Proposal__c InvP = [Select Id, Lead__r.Id, Lead__r.OwnerId, Owner.Name, INVM_ProposedMandate__c, Lead__r.Name, INVM_SentDate__c, OwnerId, INVM_Status__c , Lead__r.Status from Investment_Proposal__c Where INVM_PackageId__c	 =: packageId  AND INVM_DocumentId__c =: documentId And Lead__r.Status <> :INVM_Constants.UNQUALIFIED Limit 1] ;
            return InvP;
        }catch(Exception Ex){
            return null;
        }
        
    }
    
    
}