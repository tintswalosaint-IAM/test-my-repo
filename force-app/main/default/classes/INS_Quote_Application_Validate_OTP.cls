/**
 * @description       : SFP-26913 Invocable Class to validate OTP
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
public with sharing class INS_Quote_Application_Validate_OTP {

  /**
 * @description       : SFP-26913 Invocable Method to validate OTP
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @param returnedResponse
 * @return listOfStringOfResponse
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
    @InvocableMethod(label='Validate OTP' description='Validate OTP by using API' category='Account')
    public static List<String> validateOTP(List<String> returnedResponse) 
    {
        List<String> listOfStringOfResponse = new List<String>();

        /*Index 0 - Account Number
          Indec 1 - Account Name
          Index 2 - Mobile Number
          Index 3 - Status Code
          Index 4 - Status Message
          Index 5 - Request Id
          Index 6 - OTP Code
        */
        List<String> splittedParameters = returnedResponse.get(0).split(',');

        SRV_INS_Quote_Application.INS_ValidateOTPResponse validateOTPResponse = SRV_INS_Quote_Application.getInstance().validateOTP(splittedParameters.get(5) , splittedParameters.get(0), splittedParameters.get(6));
        
        listOfStringOfResponse.add(validateOTPResponse.statusCode);
        
        return listOfStringOfResponse;
    }
}