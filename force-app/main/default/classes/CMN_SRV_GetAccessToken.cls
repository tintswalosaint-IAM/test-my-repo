/**
* @description This class is used as call the OTP api
* @author Ruchi 
* Story Number :SFP-24630
* @date June 2023
*/ 
public without sharing class CMN_SRV_GetAccessToken {
    
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_SRV_GetAccessToken');
  private static final String TRACKING_NUMBER = 'AR16144194801651301198233';
   
   /**
    * @description This method is used as call the accessToken 
    * @return String
    */
    public static String getAccessToken(){

        BCB_GetAccessToken customerServiceCall = new BCB_GetAccessToken();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(BCB_GetAccessToken.SERVICE_NAME);
        customerServiceCall.process(obj);   
        DTOAccessToken accessToken=(DTOAccessToken) System.JSON.deserialize(customerServiceCall.getResponseBody(), DTOAccessToken.class);
        String accesToken=accessToken.access_token;
        return accesToken;
    }

     
    /**
    * @description This method is used as call the sendOtp 
    * @param applicationId
    * @return String
    */
    @AuraEnabled
    public static String sendOTP(String applicationId){
         try{
           
            String moblieNumber;
            String phoneOtp = AOB_OtpHandler.generateOtpForPhone();
            Application_Participant__c appliactionParticipant=new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            List<Application__c> applicationList = new SEL_Application().selectAppsById(appliactionParticipant.Application__c);
            moblieNumber=appliactionParticipant.CNGCU_Phone__c;
            AOB_DTO_Body requestBody= new AOB_DTO_Body();
            requestBody.cellphoneNumber='256'+moblieNumber.replaceFirst('^0+', '');
            requestBody.message='Dear Customer, please use OTP '+phoneOtp+'to complete Stanbic Bank Account On-Boarding Application.';
            requestBody.trackingNumber=TRACKING_NUMBER;
            requestBody.countryISO='UG';
            requestBody.sourceSystem='SF';
            String accessToken=getAccessToken();
            String jsonbody=Json.serialize(requestBody);
           CMN_API_SendOTP customerServiceCall = new CMN_API_SendOTP(jsonbody,accessToken);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_SendOTP.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            AOB_DTO_OTPResponse response= new AOB_DTO_OTPResponse();    
            if(customerServiceCall.getResponseStatusCode()==200){
                BCB_FlowController.createVerificationRecordForParticipant(appliactionParticipant,'Sms Alert	', 'Success');
                response.otp=phoneOtp;
                response.statusCode=customerServiceCall.getResponseStatusCode();
               return Json.serialize(response);    
             }else{
                BCB_FlowController.createVerificationRecordForParticipant(appliactionParticipant,'Sms Alert', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');           
                response.otp=null;
                response.statusCode=customerServiceCall.getResponseStatusCode();
                 return Json.serialize(response);
          }
        }catch(Exception ex){
          LOGGER.error(ex.getMessage(), new String[] {'sendOTP',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
       }
        
    }
        /**
    * @description This method is used to send SMS on callout
    * @param applicationId
    * @return String
    */
    @AuraEnabled
    public static String sendSMSonCongrats(String applicationId){
         try{
            
            Application_Participant__c appliactionParticipant=new SEL_ApplicationParticipant().selectApplicationParticipant(applicationId);
            string moblieNumber=appliactionParticipant.CNGCU_Phone__c;
            string customerName = appliactionParticipant.CNGCU_First_Name__c +' '+ appliactionParticipant.CNGCU_Last_Name__c;
            AOB_DTO_Body requestBody= new AOB_DTO_Body();
            requestBody.cellphoneNumber='256'+moblieNumber.replaceFirst('^0+', '');
            requestBody.message= 'Dear '+customerName +', Congratulations, you have successfully completed the online account opening process! Welcome to Our Stanbic Enterprise Banking Family!';
            requestBody.trackingNumber=TRACKING_NUMBER;
            requestBody.countryISO='UG';
            requestBody.sourceSystem='SF';
            String accessToken=getAccessToken();
            String jsonbody=Json.serialize(requestBody);
           CMN_API_SendOTP customerServiceCall = new CMN_API_SendOTP(jsonbody,accessToken);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_SendOTP.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            AOB_DTO_OTPResponse response= new AOB_DTO_OTPResponse();    
            if(customerServiceCall.getResponseStatusCode()==200){
           
                response.statusCode=customerServiceCall.getResponseStatusCode();
               return Json.serialize(response);    
             }else{
                response.otp=null;
                response.statusCode=customerServiceCall.getResponseStatusCode();
                 return Json.serialize(response);
          }
        }catch(Exception ex){
          LOGGER.error(ex.getMessage(), new String[] {'sendOTP',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
       }
        
    }
    /**
    * @description This method is used as call the sendOtp 
    * @return String
    * @param applicationId
    */
    @AuraEnabled
    public static String sendEmailOTP(String applicationId){
        try{
            String emailOtp = AOB_OtpHandler.generateOtpForPhone();
            Application_Participant__c appliactionParticipant=new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            AOB_DTO_OTPResponse response= new AOB_DTO_OTPResponse();
            if(appliactionParticipant.CNGCU_Email__c != null) {
                    CMN_Email_Send.sendEmailWithTemplate(appliactionParticipant,emailOtp);
                    response.otp=emailOtp;
                    return Json.serialize(response);    
            }else{
                    response.otp=null;
                    return Json.serialize(response);
                }
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'sendEmailOTP',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
     /**
    * @description This method is used to update Increments attemps 
    * @param applicationId
    * @return decimal
    */
    @auraEnabled
    public static decimal incrementRetryApplication(id applicationId) {
        try {
            decimal returnNumber;
            List<Application_Participant__c> praticipantsToUpdate=new List<Application_Participant__c>();
            Application_Participant__c appRec=new SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);   
                    if (appRec.AOB_Retry_Count__c == null) {
                        appRec.AOB_Retry_Count__c = 0;  
                    }
                    appRec.AOB_Retry_Count__c++;
                    returnNumber = appRec.AOB_Retry_Count__c;
                    if(appRec.AOB_Retry_Count__c==3){
                        appRec.AOB_Retry_Count__c=0;   
                    }
                    praticipantsToUpdate.add(appRec);
            if(praticipantsToUpdate.size()>0){
                update praticipantsToUpdate; 
            }
           return returnNumber;
        } catch (Exception ex) {            
            LOGGER.error(ex.getMessage(), new String[] {'incrementRetryApplication',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }     
    }
    
    
    /**
    * @description This method is used to update  Status 
    * @param applicationId
    * @return Integer
    */
    @AuraEnabled
    public static Integer updateOTPStatus(String applicationId){
        try{
        List<Application_Participant__c> appliactionParticipant=[select id,Application__c,Application__r.AOB_UG_BCB_Stage__c, Application__r.AOB_BCCEntityType__c,CNGCU_Email__c,CNGCU_Phone__c ,AOB_Signatory__c,AOB_KeyContactPerson__c from Application_Participant__c where Application__c=:applicationId];
        for(Application_Participant__c app:appliactionParticipant) {
        app.Application__r.AOB_UG_BCB_Stage__c='Strong Auth';    
        }
        update  appliactionParticipant;
        return 200;
            } catch (Exception ex) {LOGGER.error(ex.getMessage(), new String[] {'updateOTPStatus',ex.getMessage()}, ex);throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    
   /**
    * @description This method is used to update Increments attemps 
    * @param applicationId
    * @return decimal
    */
    @auraEnabled
    public static decimal incrementRetryApplicationpartipant(String applicationId) {
        try {
            Application_Participant__c appRec = [select id,AOB_TECH_OTPATTEMS__c,AOB_Retry_Count__c,Application__c,CNGCU_Phone__c ,AOB_Signatory__c,AOB_KeyContactPerson__c,CNGCU_Email__c from Application_Participant__c where Id=:applicationId];
            if (appRec.AOB_Retry_Count__c == null) {
                appRec.AOB_Retry_Count__c = 0;
            }
            appRec.AOB_Retry_Count__c++;
            decimal returnNumber = appRec.AOB_Retry_Count__c;
            if(appRec.AOB_Retry_Count__c==3){
                appRec.AOB_Retry_Count__c=0;
                
            }
            update appRec;
            return returnNumber;
        } catch (Exception ex) {
            
            LOGGER.error(ex.getMessage(), new String[] {'incrementRetryApplicationpartipant',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }     
    }
    
/**
* @description wrapper for AOB_DTO_Body
*/ 
    public class AOB_DTO_Body{
        
        public String cellphoneNumber;
        public String message;
        public String trackingNumber;
        public String countryISO;
        public String sourceSystem;
        public String protocol;
        public string emailAddress;
    }
    
/**
* @description wrapper for DTOAccessToken
*/ 
    public class DTOAccessToken{
        public String token_type;
        public String access_token;
        public String scope;
        public Integer expires_in;
        public Integer consented_on;
        public String metadata;
        
    }

/**
* @description wrapper for AOB_DTO_OTPResponse
*/ 
    public class AOB_DTO_OTPResponse{
        public string otp;
        public Integer statusCode;
    }

/**
* @description wrapper for AOB_DTO_OTPEmail
*/ 
    public class AOB_DTO_OTPEmail{
        public String corpname;	
        public String emailAdress;	
        public String subject;	
        public String message;	
        public String callcennumb;	
        public String trackingNumber;	
        public String countryISO;	
        public String sourceSystem;	
        public String protocol;	
        
    }
    
}