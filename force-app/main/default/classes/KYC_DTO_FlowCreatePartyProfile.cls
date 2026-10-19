public class KYC_DTO_FlowCreatePartyProfile {
    
    @InvocableVariable(label = 'Client Details')
    public KYC_DTO_ClientDetails clientDetails;
    
    @InvocableVariable(label = 'Checks Details')
    public KYC_DTO_IdChecks checks;
    
}