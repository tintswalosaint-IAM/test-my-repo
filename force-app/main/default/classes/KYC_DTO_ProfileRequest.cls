/**
* @description       : Controller to request for KYC Process
* @author            : NAGENDRAPRASAD MYLAVARAPU
* @last modified on  : 02-04-2024
* @last modified by  : Nagendra Mylavarapu
*/
public class KYC_DTO_ProfileRequest{
 
    
    @Auraenabled
    @InvocableVariable(label = 'Client Details')
    public KYC_DTO_ClientDetails clientDetails;
    
    @Auraenabled
    @InvocableVariable(label = 'Checks')
    public KYC_DTO_Checks checks;

    /**
    * @description This is constrctor
    * @author Nagendra Mylavarapu | 23-04-2024 
    **/   
    public KYC_DTO_ProfileRequest(){
        checks = new KYC_DTO_Checks();
    }
}