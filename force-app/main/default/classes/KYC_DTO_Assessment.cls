public class KYC_DTO_Assessment {
    
    @AuraEnabled
    @InvocableVariable(label = 'PEP Screening')
    public Boolean PEP_Screening;
    
    @AuraEnabled
    @InvocableVariable(label = 'CRA')
    public Boolean CRA;
    
    @AuraEnabled
    @InvocableVariable(label = 'Screening')
    public Boolean screening;
    
}