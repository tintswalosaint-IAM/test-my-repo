/**
 * @description       : SFP-26913 Service class to make callouts to the generate and validate OTP
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
public with sharing class SRV_INS_Quote_Application implements IService{ 

    private final String CHANNELID = 'UGCH';
    /**
    * @description       : Returns instance of SRV_INS_Quote_Application service class
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @return IService
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public static IService getInstance() {
        try {
        return (IService)ORG_Application.service.newInstance(IService.class);
    } catch (Exception e) {
        // Handle the exception (e.g., throw a API  exception to UI )        
        throw new AOB_CustomException('Error creating service instance: ' + e.getMessage());
     }
   }

    
    /**
     * @description : interface of IService
    */
    public interface IService {

    /**
    * @description       : Generate OTP and returns INS_GenerateOTPResults instance
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @param requestId
    * @param accountNumber
    * @return INS_GenerateOTPResults
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    INS_GenerateOTPResults generateOTP(String requestId , String accountNumber);

    /**
    * @description       : Validate OTP and returns INS_GenerateOTPResults instance
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @param requestId
    * @param accountNumber
    * @param otpCode
    * @return INS_ValidateOTPResponse
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    INS_ValidateOTPResponse validateOTP(String requestId , String accountNumber, String otpCode);

    }

    /**
    * @description       : Generate OTP and returns INS_GenerateOTPResults instance
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @param requestId
    * @param accountNumber 
    * @return INS_GenerateOTPResults
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public INS_GenerateOTPResults generateOTP(String requestId , String accountNumber){

        String accessToken = INS_Quote_Helper.getAccessToken('OTP');

        INS_RequestOTP payloadData = new INS_RequestOTP();
        payloadData.requestId = requestId;
        payloadData.accountNumber = accountNumber.trim();

        Blob data = Blob.valueOf(JSON.serialize(payloadData));
        blob result = System.Crypto.signWithCertificate('RSA-SHA256', data,'sbg_salesforce_mulesoft_non_prod');

        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:INS_Generate_and_Validate_OTP/simple-mandate/v1.0/create-otp');
        request.setMethod('POST');
        request.setHeader('x-signature', EncodingUtil.base64Encode(result));
        request.setHeader('X-IBM-Client-Id', '{!$Credential.INS_Generate_OTP.Client_Id}');
        request.setHeader('x-ibm-client-secret', '{!$Credential.INS_Generate_OTP.Client_Secret}');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('x-channel-id', this.CHANNELID);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Scopes', 'create'); 
        
        request.setBody(JSON.serialize(payloadData));
        
        Http http = new Http();
        HttpResponse response = http.send(request);
             if (response.getStatusCode() == 200) {
                // Handle successful response
                INS_GenerateOTPResults generateOTPResponse = (INS_GenerateOTPResults)JSON.deserialize(response.getBody(), INS_GenerateOTPResults.class);
        		return generateOTPResponse;
            } else {
                throw new AOB_CustomException('Error: ' + response.getBody());
            }
    }

    /**
    * @description       : Validate OTP and returns INS_GenerateOTPResults instance
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @param requestId
    * @param accountNumber
    * @param otpCode
    * @return INS_ValidateOTPResponse
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public INS_ValidateOTPResponse validateOTP(String requestId , String accountNumber, String otpCode){

        INS_ValidateOTPPayload payloadData = new INS_ValidateOTPPayload();
        payloadData.requestId = requestId;
        payloadData.passCode = otpCode.trim();
        payloadData.accountNumber = accountNumber.trim();

        String accessToken = INS_Quote_Helper.getAccessToken('OTP');
        Blob data = Blob.valueOf(JSON.serialize(payloadData));
        blob result = System.Crypto.signWithCertificate('RSA-SHA256', data,'sbg_salesforce_mulesoft_non_prod');

        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:INS_Generate_and_Validate_OTP/simple-mandate/v1.0/check-otp');
        request.setMethod('POST');
        request.setHeader('x-signature', EncodingUtil.base64Encode(result));
        request.setHeader('X-IBM-Client-Id', '{!$Credential.INS_Generate_OTP.Client_Id}');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('x-channel-id', this.CHANNELID);
        request.setHeader('Content-Type', 'application/json');
        
        request.setBody(JSON.serialize(payloadData));
        
        Http http = new Http();
        HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Handle successful response
                INS_ValidateOTPResponse validateOTPResponse = (INS_ValidateOTPResponse)JSON.deserialize(response.getBody(), INS_ValidateOTPResponse.class);
        		return validateOTPResponse;
            } else {
                throw new AOB_CustomException('Error: ' + response.getBody());
            }
    }

    /**
    * @description       : Class to set returned Access Token
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public class INS_CalloutResults{
    /**
     * @description : accessToken getter setter
     */
        public String access_token { get; set; }
    }

    /**
    * @description       : Class to set returned create-otp API response
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public class INS_GenerateOTPResults{
        public String accountNumber;
        public String accountName;
        public String mobile;
        public String statusCode;
        public String statusDescription;
    }

    /**
    * @description       : Class to set the create-otp payload
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public class INS_RequestOTP{
        public String requestId;
        public String accountNumber;
    }

    /**
    * @description       : Class to set the check-otp payload
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public class INS_ValidateOTPPayload{
        public String requestId;
        public String passCode;
        public String accountNumber;
    }

    /**
    * @description       : Class to set returned check-otp API response
    * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
    * @group             : Cloudsmiths
    * @last modified on  : 11-09-2023
    * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
    **/
    public class INS_ValidateOTPResponse{
        public String mobile;
        public String statusCode;
        public String statusDescription;
        public String approvedRequestId;
        public String accountNumber;
    }
}