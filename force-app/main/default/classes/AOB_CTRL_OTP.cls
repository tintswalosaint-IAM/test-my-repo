/**
 * Controller to prepare data that will be displayed in OTP screen
 * 
 * <p>DBP-1638-1639-1640-1641</p> 
 * 
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 * 
 * @date Dec 4th 2020 
 */
public with sharing class AOB_CTRL_OTP {
	public static final String SERVICE_NAME = AOB_CTRL_OTP.class.getName();
    /** 
    * Method used to call API to get an access token to be able to call APIs
    * @return	String
    */
    @AuraEnabled
    public static String callAccessToken(){ 
        try{
            return AOB_CTRL_PersonalDetails.callGetToken();
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, SERVICE_NAME + ':callAccessToken');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /**
     * Method used to call API to get OTP
     * @param	phoneNumber customer's phone number
     * @param   applicationId application identifier
     * @return	AOB_SRV_OTP.OTPResponse json response from the API
     */
    @AuraEnabled
    public static AOB_SRV_OTP.OTPResponse callGetOTP(String phoneNumber, Id applicationId) {
        AOB_SRV_OTP.OTPResponse resp = new AOB_SRV_OTP.OTPResponse();
        try {
            if (!AOB_SRV_OTP.checkOTPAttempts(applicationId, false, false)) {
                throw new AuraHandledException('Tech_MaxOtpAttempts');
            }
            String response = AOB_SRV_OTP.callOTP(phoneNumber, '', '', 'GEN', applicationId);
            XmlStreamReader reader = new XmlStreamReader(response);
            XmlStreamReader readerCode = new XmlStreamReader(response);
            resp.qName = AOB_Utils.readXMLResponse(reader, 'otp_qname');
            resp.code = AOB_Utils.readXMLResponse(readerCode, 'vers_v_response_code');
            resp.message = AOB_SRV_OTP.getOTPMessage().get(resp.code);
            // encrypt otp
            return resp;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, SERVICE_NAME + ':callGetOTP');
            if (error instanceof AuraHandledException) {
                throw error;
            }
            throw new AuraHandledException(error.getMessage());
        }
    }
    /**
    * Method used to call API to get open applications
    * @param   applicationId application identifier
    * @return applicationId
    */  
    @AuraEnabled
    public static String callSetContractedSign(String applicationId){
        String response;
        try{
            response = AOB_SRV_OpenApplications.callSetContractedSign(applicationId);
        }
        catch(Exception error)
		{
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_OTP.callSetContractedSign');
			throw new AuraHandledException(error.getMessage());
		}
        return response;
    }
    /**
    * Method used to call Get Customer API + get dynamic values
    * @return	AOB_DTO_OTP
    */
    @AuraEnabled
    public static AOB_DTO_OTP generateData(){
        AOB_DTO_OTP otpData = new AOB_DTO_OTP();  
        String phoneNumber = '';
        String callCenter = '';
        List<Account> accs = [SELECT Id, AOB_CommerceSiteId__c 
                              FROM Account 
                              WHERE PersonContactId 
                              IN (SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId())];
        if(!accs.isEmpty()){
            callCenter = AOB_Utils.getCountrySetting(accs[0].AOB_CommerceSiteId__c).AOB_CallCenterPhoneNumber__c;
        }
        try{
            phoneNumber = AOB_SRV_OTP.callGetCustomer();
            otpData.phoneNumber = phoneNumber;
            if(phoneNumber != null){
                phoneNumber = phoneNumber.replace(phoneNumber.substring(2,6),'******');
                otpData.cryptedNumber = phoneNumber;
            }
            otpData.callCenter = callCenter;
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, SERVICE_NAME + ':generateData');
            throw new AuraHandledException(error.getMessage());
        }
        return otpData;
    } 
    /**
    * Method used to call OTP API to validate OTP
    * @param	phoneNumber
    * @param	num
    * @param	qname 
    * @param    applicationId application identifier
    * @return	String code from validate OTP
    */
    @AuraEnabled 
    public static String callValidateOTP(String phoneNumber, String num, String qname, Id applicationId){
        try{   
            if(!AOB_SRV_OTP.checkOTPAttempts(applicationId, false, true)){
                throw new AuraHandledException('Tech_MaxOtpAttempts');
            }
            string response = AOB_SRV_OTP.callOTP(phoneNumber,num,qname,'VAL',applicationId); 
            XmlStreamReader reader = new XmlStreamReader(response);
            String code = AOB_Utils.readXMLResponse(reader,'vers_v_response_code');
            if((String.isBlank(code) || code != 'OK')){
                if(!AOB_SRV_OTP.checkOTPAttempts(applicationId, false, false)){
                    throw new AuraHandledException('Tech_MaxOtpAttempts');
                }
                else if(AOB_SRV_OTP.checkResendOtp(applicationId)){
                    throw new AuraHandledException('Tech_MaxAttemptsToResendOtp');
                }
            }
            return AOB_SRV_OTP.getOTPMessage().get(code);       
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, SERVICE_NAME + ':callValidateOTP');
            if(error instanceof AuraHandledException){
                throw error;
            }
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description Create legal options case if condition is met
     * @param   applicationId application identifier
     * @return 	Case the new created case
     */
    @AuraEnabled
    public static Case createLegalOptionsCase(Id applicationId) {
        Case createdCase;
        try{
            String flowNames = AOB_Utils.getApplicationFlowNames(applicationId);
            if(String.isNotBlank(flowNames) && !flowNames.contains(AOB_Constants.DOCUMENT_UPLOAD)){
                createdCase = DOC_SRV_Document.createLegalOptionsCase(applicationId);
            }
        }
        catch(Exception exc){
            CMN_UTIL_Logger.error(exc, SERVICE_NAME + ':uploadFiles');
            throw exc;
        }
        return createdCase;
    }

    /** 
    * Method used to check if the user can call OTP API to validate OTP
    * @param   applicationId application identifier
    * @return Boolean true if user has left attempts, otherwise false
    */
    @AuraEnabled 
    public static Boolean checkOTPAttempts(Id applicationId){
        if(!AOB_SRV_OTP.checkOTPAttempts(applicationId, true, false)){
            throw new AuraHandledException('Tech_MaxOtpAttempts');
        }
        return true;
    }
}