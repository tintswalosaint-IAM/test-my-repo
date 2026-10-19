public class KYC_DTO_IdChecks {
    @AuraEnabled
    @InvocableVariable(label = 'ID Validation')
    public Boolean idValidation;
    
    @AuraEnabled
    @InvocableVariable(label = 'IDV')
    public Boolean idv;
    
    @AuraEnabled
    @InvocableVariable(label = 'Assessment Details')
    public KYC_DTO_Assessment assessment;    
}