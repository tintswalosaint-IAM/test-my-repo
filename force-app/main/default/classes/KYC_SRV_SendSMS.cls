/***************************************************************************************
@Name of the Class :KYC_SRV_SendSMS
@Description : SFP-40754 Class used for calling SMS API.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date oct 08 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_SendSMS {
    public static final String SERVICE_NAME = KYC_SRV_SendSMS.class.getName();
    public static final String SALESFORCE = 'Salesforce';
    public static final String VERIFICATION = 'Verification';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    private KYC_SRV_SendSMS() {

    }
    
    /**
     * @description method used to call RAASCustomer API
     * @param partyProfileIds 
     */
    public static Integer sendSMS(set<Id> partyProfileIds) {
        try{
            List<PartyProfile> partyProfileDetails = new SEL_PartyProfile().selectByIds(partyProfileIds);
            if(partyProfileDetails.isEmpty()){
                throw new KYC_SRV_SendSMSException('The Party Profile list is empty');
            }else{
                
                String reqbody;
                String transactionId=UUID.randomUUID().toString();
                KYC_DTO_SendSMS sendSMS= new KYC_DTO_SendSMS();
                sendSMS.cellphoneNumber=partyProfileDetails[0].PrimaryPhone;
                
                KYC_DTO_Correspondence correspondence= new KYC_DTO_Correspondence();
                correspondence.channelId=SALESFORCE;
                correspondence.correspondenceType=VERIFICATION;
                correspondence.correspondenceContent=KYC_customlabel__mdt.getInstance('SMS_Message').Description__c+' '+KYC_customlabel__mdt.getInstance('KYC_SIte_Url').Description__c+partyProfileDetails[0].id;
                correspondence.templateReference='';
                correspondence.customerReference=partyProfileDetails[0].Id;
                sendSMS.correspondence=correspondence;
                reqbody=JSON.Serialize(sendSMS);
                KYC_API_SendSMS sendSMSServiceCall = new KYC_API_SendSMS(reqbody,partyProfileDetails[0],transactionId);
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_SendSMS.SERVICE_NAME);
                sendSMSServiceCall.process(obj);
                if(Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable()){
                    insert obj;
                }
                return sendSMSServiceCall.getResponseStatusCode();
            }
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new KYC_SRV_SendSMSException(ex);
        }

    }
   
  /**
   * @description custom Exception 
   */  
   public class KYC_SRV_SendSMSException extends Exception {}

    public class KYC_DTO_SendSMS { 
        public String cellphoneNumber;
        public KYC_DTO_Correspondence correspondence;
    }
    
     public class KYC_DTO_Correspondence {
        public String channelId;
        public String correspondenceType;
        public String correspondenceContent ;
        public String templateReference ;
        public String customerReference;
    }

   
}