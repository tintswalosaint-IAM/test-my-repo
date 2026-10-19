/**
 * @description       : SFP-26913 Invocable Class to generate and send OTP to the Customer
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
public with sharing class INS_Quote_Application_Invocable {
    
/**
 * @description       : Invocable Method to call create-otp API to generate and send OTP to the Customer
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @param accountNumbers
 * @return listOfStringOfResponse
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
    @InvocableMethod(label='Send OTP' description='Send an OTP to the user' category='Account')
    public static List<String> sendOTP(List<String> accountNumbers) 
    {
        List<String> listOfStringOfResponse = new List<String>();
        String requestId = CMN_UTIL_Random.randomNumeric(13);

        SRV_INS_Quote_Application.INS_GenerateOTPResults generateOTPResponse = SRV_INS_Quote_Application.getInstance().generateOTP(requestId,accountNumbers.get(0));
        
        listOfStringOfResponse.add(generateOTPResponse.accountNumber+','+generateOTPResponse.accountName+','+generateOTPResponse.mobile+','+generateOTPResponse.statusCode+','+generateOTPResponse.statusDescription+','+requestID);

        return listOfStringOfResponse;
    }
}