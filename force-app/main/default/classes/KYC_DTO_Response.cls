/***************************************************************************************
@Name of the Class :KYC_DTO_Response
@Description :SFP-40755 Response  DTO Class  for Mule soft APIS
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
* Last Modified : SFP-43257 - Added kraTransactionId variable in the response, added by Irshad
****************************************************************************************/
public with sharing class KYC_DTO_Response {
    private static final String SUCCESS = 'Success';
    private static final String FAILED = 'Failed';
    private static final String DISPLAY_ERROR_MESSAGE = 'We are currently experiencing technical difficulties with processing your request. Please try again later. If the problem persists, please contact us (Error code XXX)';
    private static final String TECHNICAL_DISPLAY_ERROR_MESSAGE = 'Technical errors were experienced during the verification process, please re-try by accessing the same link. (Error code: XXX)';

    @AuraEnabled
    public String status;
    @AuraEnabled
    public String response;
    @AuraEnabled
    public String responseErrorMessage ='';
    @AuraEnabled
    public String assementResponse = '';
    @AuraEnabled
    public Id partyScreeningSummaryId;

    @AuraEnabled
    public String kraStatusMessage;
    @AuraEnabled
    public String kraPin;
    @AuraEnabled
    public String kraTransactionId; // SFP-43257: Added
    @AuraEnabled
    public String risk;
    
    public KYC_DTO_Response (Map<String,Object> jsonRes,String response) {
        object errorObject = jsonRes.get('error');
        if(errorObject instanceof Map<String,Object>){
            this.status = FAILED;
            this.responseErrorMessage = getErrorMessage(String.valueOf(((Map<String,Object>) errorObject).get('errorCode')));
        } else {
            this.status = SUCCESS;
            this.response = response;
            Map<String, Object> assessmentResult = (Map<String, Object>) jsonRes.get('assessmentResult');
            this.risk = (String) assessmentResult?.get('result');
        }
        // // SFP-43257: Added  to Extract TransactionId
         this.kraTransactionId = (String) jsonRes.get('TransactionId');
        // Extract kraInformation
        Map<String,Object> kraInformation = (Map<String,Object>) jsonRes.get('kraInformation');
        if (kraInformation != null) {
            String statusMessage = (String) kraInformation.get('StatusMessage');

            // Determine kraStatusMessage based on statusMessage
            if (statusMessage == 'VALID ID') {
                this.kraStatusMessage = 'Accepted';
                // Extract the kraPin only if available
                this.kraPin = (String) kraInformation.get('KraPin');
            }
            else if (statusMessage == 'Invalid ID') {
                this.kraStatusMessage = 'Rejected';
                // kraPin might be null or not returned if Invalid ID
                this.kraPin = null;
            }
        }
    }
    public KYC_DTO_Response (String status,Integer reponseCode) {
        this.responseErrorMessage = getErrorMessage(String.valueOf(reponseCode));
        this.status = status;
    }

    /**
    * @description This method to get error message from error code
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param errorCode
    * @return String
    **/
    public static  String getErrorMessage(String errorCode){
        String responseErrorMessages = '';
        switch on errorCode {
            when '400' {
                responseErrorMessages = DISPLAY_ERROR_MESSAGE;
            }   when '401' {
                responseErrorMessages = DISPLAY_ERROR_MESSAGE;
            }   when '403' {
                responseErrorMessages = DISPLAY_ERROR_MESSAGE;
            }   when '500' {
                responseErrorMessages = TECHNICAL_DISPLAY_ERROR_MESSAGE;
            }   when '503' {
                responseErrorMessages = TECHNICAL_DISPLAY_ERROR_MESSAGE;
            }
        }
        responseErrorMessages = responseErrorMessages.replace('XXX', errorCode);
        return responseErrorMessages;
    }
}