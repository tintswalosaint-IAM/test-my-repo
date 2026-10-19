/**
* Contains the OTP API functions
*
* <p>DBP-1638-1639-1640-1641</p>
*
* @author Asmae ESSBAI (aessbai@salesforce.com)
*
* @date Dec 4th 2020
*/
public with sharing class AOB_SRV_OTP {
    public static final String SERVICE_NAME = AOB_SRV_OTP.class.getName();
    public static final String ERR_2001 = 'Technical error. Please try again later';
    public static final String ERR_1001 = 'Invalid OTP';
    public static final String ERR_1021 = 'OTP regenerated after 3 invalid attempts';
    public static final String ERR_1022 = 'for generate - invalid delivery type for the others not error - returned after 3rd incorrect OTP entered and new one sent';
    public static final String ERR_1023 = 'Your OTP has expired and a new one has been sent';
    public static final String ERR_1025 = 'NO OTP SPECIFIED VALIDATE FUNCTION.';
    public static final String ERR_1026 = 'You have Exceeded the number of attempts you can enter your OTP. Please contact your branch.';
    public static final String ERR_1030 = 'NO QNAME SPECIFIED VALIDATE*DELETE FUNCTION';
    public static final String ERR_1040 = 'INVALID MESSAGE TYPE SPECIFIED';
    public static final String ERR_2042 = 'INVALID FUNCTION SPECIFIED';
    public static final String ERR_4001 = 'INVALID CARD NUMBER SPECIFIED';
    public static final String ERR_7666 = 'There is a possible security issue with your profile. Please call us on 0800 222 050 (South Africa) or +27 10 249 0070 (International) to confirm your details.';
    /**
* @description Calls Get OTP / Validate OTP API
* @param cellPhone
* @param num
* @param qName
* @param function
* @param applicationId
* @return a string containing the response of the API
*/
    public static string callOTP(
        String CellPhone,
        String num,
        String qName,
        String function,
        Id applicationId
    ) {
        AOB_API_OTP customerServiceCall = new AOB_API_OTP();
        String productCat = '';
        String code = '27';
        List<AOB_ApplicationLineItem__c> appLI = [
            SELECT
            Id,
            AOB_Product__r.AOB_ProductCategory__c,
            AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c
            FROM AOB_ApplicationLineItem__c
            WHERE AOB_Application__c = :applicationId
        ];
        if (!appLI.isEmpty()) {
            productCat = appLI[0].AOB_Product__r.AOB_ProductCategory__c;
            code = AOB_Utils.getCountrySetting(
                appLI[0].AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c
            )
                .AOB_Code__c;
        }
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_FUNCTION_NAME}',
            function
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_DELIVERY_TYPE}',
            'S'
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_CONTRY_CODE}',
            code
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_CELL_NO}',
            CellPhone
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_OTP}',
            num
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_QNAME}',
            qName
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_EMAIL}',
            ''
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_CONTENT}',
            productCat
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_OTP.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        String result = customerServiceCall.responseBody;
        return result;
    }
    /**
* @description OTP error message
* @return Map<String,String>
*/
    public static Map<String, String> getOTPMessage() {
        Map<String, String> otpMap = new Map<String, String>();
        otpMap.put('0000', 'OK');
        otpMap.put('2001', ERR_2001);
        otpMap.put('1001', ERR_1001);
        otpMap.put('1021', ERR_1021);
        otpMap.put('1022', ERR_1022);
        otpMap.put('1023', ERR_1023);
        otpMap.put('1025', ERR_1025);
        otpMap.put('1026', ERR_1026);
        otpMap.put('1030', ERR_1030);
        otpMap.put('1040', ERR_1040);
        otpMap.put('2042', ERR_2042);
        otpMap.put('4001', ERR_4001);
        otpMap.put('7666', ERR_7666);
        return otpMap;
    }
    /**
* @description Calls GetCustomer API
* @return a string containing SAP phone number
*/
    public static String callGetCustomer() {
        AOB_DTO_PersonalContact contactDTO = AOB_SRV_CustomerInfo.callGetCustomerAPIContact();
        return contactDTO.phoneNumber;
    }
    /**
* Method used to check if the user can call OTP API to validate OTP
* @return true , otherwise false
*/
    public static Boolean checkOTPAttempts(
        Id applicationId,
        Boolean updateAttempt,
        Boolean isAttemptAlreadyIncremented
    ) {
        final String MAX_ATTEMPTS_DEVELOPER_NAME = 'Max_Attempts';
        
        AOB_Application__c applicationFromDB = [
            SELECT Id, AOB_TECH_OTPAttempts__c
            FROM AOB_Application__c
            WHERE Id = :applicationId
        ];
        final List<AOB_AppSettings__mdt> techSettings = [
            SELECT MasterLabel, AOB_Value__c
            
            FROM AOB_AppSettings__mdt
            WHERE DeveloperName = :MAX_ATTEMPTS_DEVELOPER_NAME
        ];
        Decimal attemptsNumber = isAttemptAlreadyIncremented
            ? (applicationFromDB.AOB_TECH_OTPAttempts__c - 1)
            : applicationFromDB.AOB_TECH_OTPAttempts__c;
        if (attemptsNumber < Decimal.valueOf(techSettings[0].AOB_Value__c)) {
            if (updateAttempt) {
                applicationFromDB.AOB_TECH_OTPAttempts__c += 1;
                update applicationFromDB;
            }
            return true;
        }
        CMN_UTIL_Logger.error(
            'You\'ve reached the maximum OTP attempts',
            SERVICE_NAME + ':checkOTPAttempts'
        );
        return false;
    }
    /**
* Method used to ge document ID from set Contracted sign
* @param response
* @return document GUID
*/
    public static String getGUID(String response) {
        Map<String,Object> result = (Map<String, Object>)System.JSON.deserializeUntyped(response);
        List<Object> contracts = (List<Object>)result.get('contractSignedStatus');
        if(contracts == null){
            return 'KO';
        }else{
            Map<String,Object> contractInfo = (Map<String,Object>)contracts.get(0);
            return (String)contractInfo.get('documentLink');
        }
    }
    /**
* Method used to check if the user exceeded the number of attempts to resend otp
* @return true , otherwise false
*/
    public static Boolean checkResendOtp(Id applicationId) {
        final String ATTEMTS_TO_RESEND_OTP_DEVELOPER_NAME = 'Attempts_To_Resend_Otp';
        
        AOB_Application__c applicationFromDB = [
            SELECT Id, AOB_TECH_OTPAttempts__c
            FROM AOB_Application__c
            WHERE Id = :applicationId
        ];
        final List<AOB_AppSettings__mdt> techSettings = [
            SELECT MasterLabel, AOB_Value__c
            FROM AOB_AppSettings__mdt
            WHERE DeveloperName = :ATTEMTS_TO_RESEND_OTP_DEVELOPER_NAME
        ];
        if (
            applicationFromDB.AOB_TECH_OTPAttempts__c ==
            Decimal.valueOf(techSettings[0].AOB_Value__c)
        ) {
            CMN_UTIL_Logger.error(
                'You\'ve reached the maximum OTP attempts',
                SERVICE_NAME + ':checkOTPAttempts'
            );
            return true;
        }
        return false;
    }
    /**
* @description Wrapper class for OTPResponse
*/
    public class OTPResponse {
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String qName {get;set;}
        @AuraEnabled
        public String message {get;set;}
    }
}