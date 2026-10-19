/**
* @description This class is used as call the OTP api
* @author Dayakar 
* @date Jan 5th 2021
*/
public without sharing class AOB_SRV_GetAccessToken {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_GetAccessToken');
    private static final String SOLE_PROP = 'Sole Proprietor';
    private static final String SOCTY = 'SOCTY';
    private static final String CHECK_NEW = 'New';
    private static final String EXIST = 'EXIST';
    private static final String OTP_MSG_START = 'Hello, please use OTP (';
    private static final String OTP_MSG_END = ') to complete Stanbic Account On-Boarding Application.';
    private static final String TRACKING_NUMBER = 'AR16144194801651301198233';
    private static final String BW = 'BW';
    private static final String SF = 'SF';
    private static final String SMS = 'SMS';
    private static final String OTP_MSG = 'Dear customer, the one time password (OTP)  is ';
    private static final String Email = 'Email';
    private static final String STATUS_CODE = 'StatusCode';
    private static final String OTP_VERIFIED = 'OTP Verified';
    
    /**
* @description This method is used as call the accessToken 
* @return String
*/
    public static String getAccessToken(){
        try{
            AOB_BOTs_GetAccessToken customerServiceCall = new AOB_BOTs_GetAccessToken();
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTs_GetAccessToken.SERVICE_NAME);
            customerServiceCall.process(obj);   
            DTOAccessToken accessToken=(DTOAccessToken) System.JSON.deserialize(customerServiceCall.getResponseBody(), DTOAccessToken.class);
            String accesToken=accessToken.access_token;
            return accesToken;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getAccessToken',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /**
    * @description This method is used as call the sendOtp 
    * @param String applicationId
    * @return String
    */
    @AuraEnabled
    public static String sendOTP(String applicationId,String Checkdirector){
        try{
            String emailOtp = AOB_OtpHandler.generateOtpForPhone();
            String moblieNumber;
            String email;
            if(Checkdirector== CHECK_NEW){
                List<Application_Participant__c> appliactionParticipant=new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
                for(Application_Participant__c app:appliactionParticipant) {
                    if(app.AOB_KeyContactPerson__c==true){
                        moblieNumber=app.CNGCU_Phone__c;
                        email=app.CNGCU_Email__c;
                        break;
                    }else if(app.Application__r.AOB_BCCEntityType__c== SOLE_PROP){
                        moblieNumber=app.CNGCU_Phone__c;
                        email=app.CNGCU_Email__c;
                        break;
                    }else if(app.Application__r.AOB_Schema_Code__c == SOCTY && app.AOB_KeyContactPerson__c==true){
                        moblieNumber=app.CNGCU_Phone__c;
                        email=app.CNGCU_Email__c;
                        break;
                    }else if(app.Application__r.AOB_Schema_Code__c == SOCTY){
                        moblieNumber=app.CNGCU_Phone__c;
                        email=app.CNGCU_Email__c;
                        break;
                    }
                    
                } 
            }else if(Checkdirector == EXIST){
                Application_Participant__c appliactionParticipant=new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(applicationId);
                moblieNumber=appliactionParticipant.CNGCU_Phone__c;
                email=appliactionParticipant.CNGCU_Email__c;
            }
            moblieNumber=moblieNumber.removeStart('+');
            AOB_DTO_Body requestBody= new AOB_DTO_Body();
            requestBody.cellphoneNumber=moblieNumber;
            requestBody.message=OTP_MSG_START+emailOtp+OTP_MSG_END;
            requestBody.trackingNumber= TRACKING_NUMBER;
            requestBody.countryISO=BW;
            requestBody.sourceSystem=SF;
            requestBody.protocol=SMS;
            requestBody.emailAddress=email;
            String accessToken=getAccessToken();
            String jsonbody=Json.serialize(requestBody);
            AOB_API_SendOTP customerServiceCall = new AOB_API_SendOTP(jsonbody,accessToken);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_SendOTP.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            AOB_DTO_OTPResponse response= new AOB_DTO_OTPResponse();    
            if(customerServiceCall.getResponseStatusCode()==200){
                response.otp=emailOtp; 
                response.statusCode=customerServiceCall.getResponseStatusCode();
                response.moblienum=moblieNumber;
                return Json.serialize(response);    
            }else{
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
* @description This method is used as call the sendOtp 
* @return String
* @param applicationId
*/
    @AuraEnabled
    public static String sendEmailOTP(String applicationId){
        try{
            String emailOtp = AOB_OtpHandler.generateOtpForPhone();
            String emailid;
            String moblieNumber;
            List<Application_Participant__c> appliactionParticipant=new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);            
            for(Application_Participant__c app:appliactionParticipant) {
                if(app.AOB_KeyContactPerson__c==true){
                    moblieNumber=app.CNGCU_Phone__c;
                    emailid=app.CNGCU_Email__c;
                }else if(app.Application__r.AOB_BCCEntityType__c==SOLE_PROP){
                    moblieNumber=app.CNGCU_Phone__c;
                    emailid=app.CNGCU_Email__c;
                }
                
            }
            moblieNumber=moblieNumber.removeStart('+');
            AOB_DTO_Body requestBody= new AOB_DTO_Body();
            requestBody.cellphoneNumber=moblieNumber;
            requestBody.message=OTP_MSG+emailOtp;
            requestBody.trackingNumber=TRACKING_NUMBER;
            requestBody.countryISO=BW;
            requestBody.sourceSystem=SF;
            requestBody.protocol=Email;
            requestBody.emailAddress=emailid;   
            String accessToken=getAccessToken();
            String jsonbody=Json.serialize(requestBody);
            AOB_API_SendOTP customerServiceCall = new AOB_API_SendOTP(jsonbody,accessToken);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_SendOTP.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            AOB_DTO_OTPResponse response= new AOB_DTO_OTPResponse();    
            if(customerServiceCall.getResponseStatusCode()==200){
                Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                response.otp=emailOtp;
                response.statusCode=(Integer)responseData.get(STATUS_CODE);
                response.moblienum=moblieNumber;
                return Json.serialize(response);    
            }else{
                response.otp=null;
                response.statusCode=customerServiceCall.getResponseStatusCode();
                return Json.serialize(response);
            }
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'sendEmailOTP',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
* @description This method is used to update Otp attemps 
* @return decimal
* @param applicationId
*/
    @auraEnabled
    public static decimal OTPAttemps(String applicationId) {
        try {
            decimal returnNumber;
            List<Application_Participant__c> appRec=new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            List<Application_Participant__c> keyParticipantUpdate=new List<Application_Participant__c>();
            List<Application_Participant__c> solePropUpdate=new List<Application_Participant__c>();
            for(Application_Participant__c app:appRec) {
                if(app.AOB_KeyContactPerson__c==true){
                    if (app.AOB_TECH_OTPATTEMS__c == null) {
                        app.AOB_TECH_OTPATTEMS__c = 0;
                    }
                    app.AOB_TECH_OTPATTEMS__c++;
                    returnNumber = app.AOB_TECH_OTPATTEMS__c;
                    if(app.AOB_TECH_OTPATTEMS__c==3){
                        app.AOB_TECH_OTPATTEMS__c=0;
                    }
                    keyParticipantUpdate.add(app);
                }
                if(app.Application__r.AOB_BCCEntityType__c==SOLE_PROP){
                    if (app.AOB_TECH_OTPATTEMS__c == null) {
                        app.AOB_TECH_OTPATTEMS__c = 0;
                    }
                    app.AOB_TECH_OTPATTEMS__c++;
                    returnNumber = app.AOB_TECH_OTPATTEMS__c;
                    if(app.AOB_TECH_OTPATTEMS__c==3){
                        
                        app.AOB_TECH_OTPATTEMS__c=0;
                        
                    }
                    solePropUpdate.add(app);
                }
            }
            if(keyParticipantUpdate.size()>0){
                Update keyParticipantUpdate;
            }
            if(solePropUpdate.size()>0){
                Update solePropUpdate;
            }
            return returnNumber;
        } catch (Exception ex) {
            
            LOGGER.error(ex.getMessage(), new String[] {'OTPAttemps',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    } 
    
    /**
* @description This method is used to update Increments attemps 
* @return decimal
* @param applicationId
*/
    @auraEnabled
    public static decimal incrementRetryApplication(id applicationId) {
        try {
            decimal returnNumber;
            List<Application_Participant__c> praticipantsToUpdate=new List<Application_Participant__c>();
            List<Application_Participant__c> appRec=new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
            for(Application_Participant__c app:appRec) {
                if(app.AOB_KeyContactPerson__c==true){    
                    if (app.AOB_Retry_Count__c == null) {
                        app.AOB_Retry_Count__c = 0;
                    }
                    app.AOB_Retry_Count__c++;
                    returnNumber = app.AOB_Retry_Count__c;
                    if(app.AOB_Retry_Count__c==3){
                        app.AOB_Retry_Count__c=0;
                    }
                    praticipantsToUpdate.add(app);
                }
            }
            if(praticipantsToUpdate.size()>0){
                update praticipantsToUpdate; 
            }
            return returnNumber;
        } catch (Exception ex) {
            
            LOGGER.error(ex.getMessage(), new String[] {'incrementRetryApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }     
    }
    
    
    /**
* @description This method is used to update  Status 
* @return decimal
* @param applicationId
*/
    @AuraEnabled
    public static Integer updateOTPStatus(String applicationId){
        try{
            List<Application_Participant__c> updateList= new  List<Application_Participant__c>();
            List<Application_Participant__c> appliactionParticipant=[select id,Application__c,Application__r.AOB_BCCEntityType__c,CNGCU_Email__c,CNGCU_Phone__c ,AOB_Signatory__c,AOB_KeyContactPerson__c,Application__r.AOB_Schema_Code__c from Application_Participant__c where Application__c=:applicationId];
            for(Application_Participant__c app:appliactionParticipant) {
                if(app.AOB_KeyContactPerson__c==true){
                    app.AOB_Stage__c=OTP_VERIFIED;
                    updateList.add(app);
                }else if(app.Application__r.AOB_BCCEntityType__c==SOLE_PROP){
                    app.AOB_Stage__c=OTP_VERIFIED;
                    updateList.add(app);
                }else if(app.Application__r.AOB_Schema_Code__c == SOCTY){
                    app.AOB_Stage__c=OTP_VERIFIED;
                    updateList.add(app); 
                } 
            }
            update  updateList;
            return 200;
        } catch (Exception ex) {
            
            LOGGER.error(ex.getMessage(), new String[] {'updateOTPStatus',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
    }
    
    
    /**
* @description This method is used to update Increments attemps 
* @return decimal
* @param applicationId
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
        public String moblienum;
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