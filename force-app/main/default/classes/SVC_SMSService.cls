/**
 * @description       : Class with invocable method for sending SMS
 * @User Story        : SFP-35988
 * @author            : Aliaksei Koval
 * @last modified on  : 06-20-2025
 * @last modified by  : Aliaksei Koval
**/
public inherited sharing class SVC_SMSService {

    @testVisible
    private SVC_SMSService(){}

    public class MessageInputs {
        @InvocableVariable public String recordId;
    }

    /**
    * @description Invocable method to be used in the flow to send the SMS to a ustomer
    * @param requests
    **/
    @InvocableMethod(Label='Send SMS Message' Description='Send SMS message to a customer')
    public static void sendMessage(List<MessageInputs> requests) {
        if(requests.size() > 1){
            throw new InvalidParameterValueException('Too many arguments', String.valueOf(requests.size()));
        }
        String body = prepareSMSData(requests[0].recordId);
        SVC_API_SendSMS.sendSMS(body, requests[0].recordId);
    }

    /**
    * @description Preparing data for SMS
    * @return String
    **/
    private static String prepareSMSData(String recordId){
        String body;
        if(((ID)recordId).getsobjecttype() == Schema.Case.getSObjectType()){
            body = JSON.serialize(SVC_CaseSMSDataService.prepareSMSRequest(recordId));
        }
        return body;
    }
}