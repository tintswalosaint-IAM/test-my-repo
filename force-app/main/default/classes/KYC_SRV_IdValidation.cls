/***************************************************************************************
@Name of the Class :KYC_SRV_IdValidation
@Description :SFP-32817 Class used to call IdValidation API.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date oct 08 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_IdValidation {
    public static final String SERVICE_NAME = KYC_SRV_IdValidation.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);

    private KYC_SRV_IdValidation(){
       
    }
    /**
    * @description method used to call IdValidation API
    * @param ppId 
    * @return KYC_DTO_Response 
    */
    public static KYC_DTO_Response callIdValidation(String ppId){
        try{
            KYC_DTO_Response response;
            PartyProfile pProfile = new SEL_PartyProfile().selectById(ppId);
            KYC_DTO_IdValidation kdI= new KYC_DTO_IdValidation();
            kdI.identificationType = 'IdentityNumber';
            kdI.countryOfIssue = pProfile.WI_IdentificationDocumentIssuingCountry__c;
            if(pProfile.WI_IdentificationDocumentIssuingCountry__c=='UG'){ 
                kdI.documentCardNumber = pProfile.CMN_CardNumber__c;
            }else{
                kdI.documentCardNumber='null';
            }
            kdI.firstName = pProfile.FirstName;
            kdI.lastName=pProfile.LastName;
            if(pProfile.DateOfBirth != null){
                kdI.dateOfBirth=String.valueOf(pProfile.DateOfBirth);
            }
            
            KYC_API_IdValidation customerServiceCall = new KYC_API_IdValidation(JSON.serialize(kdI) ,pProfile);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_IdValidation.SERVICE_NAME);
            customerServiceCall.process(obj);
            if(Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable()){
                insert obj;
            }
            if (customerServiceCall.getResponseStatusCode()== 201 || customerServiceCall.getResponseStatusCode() == 200 ) {
                Map<String,Object> jsonRes=(Map<String,Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                response = new KYC_DTO_Response(jsonRes,(String) jsonRes.get('Result'));
                return response;
                
            }else{
                response = new KYC_DTO_Response('Failed',customerServiceCall.getResponseStatusCode());
                return response;
            }
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new KYC_SRV_IdValidationException(ex.getMessage());
        }
    }
    
    /**
     * @description custom Exception 
     */  
    public class KYC_SRV_IdValidationException extends Exception {}


/***************************************************************************************
    @Name of the Class :KYC_DTO_IdValidation
    @Description : This is wrapper class for converting Salesforce Object into parameter for api	
    @Author :Dayakar 
    @Created Date :sept 09 2024
****************************************************************************************/  
 public  class  KYC_DTO_IdValidation{
    public String identificationType;
    public String countryOfIssue;
    public String documentCardNumber;
    public String firstName;
    public String lastName;
    public String dateOfBirth;
  
 }
}