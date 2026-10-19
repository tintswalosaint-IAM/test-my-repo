/**
 * @description       : SFP-35988 Class for actual API call for sending SMS
 * @author            : Aliaksei Koval
 * @last modified on  : 06-27-2025
 * @last modified by  : Aliaksei Koval
**/
public inherited sharing class SVC_API_SendSMS extends sbgplatform.ApiGatewayService{
    
    private static final String PATH_SEND_SMS = '/central-messaging/communication/outbound';
    private static final String NAMED_CREDENTIALS = 'CHNW_PPB_SAS_ComplaintsManagementN';

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_API_SendSMS');
    
    private SVC_API_SendSMS() {
        super(NAMED_CREDENTIALS);
    }

    private static List<FeedItem> feedItemsToCreate = new List<FeedItem>();
    
    /**
    * @description Method for sending SMS to customer
    * @param body 
    * @param recordId 
    **/
    @future(callout=true)
    public static void sendSMS(String body, String recordId) {
        SVC_API_SendSMS service = new SVC_API_SendSMS();

        try {
            String resp = (String)service.post(PATH_SEND_SMS, body);

            SVC_DTO_SMSRestResponse response = (SVC_DTO_SMSRestResponse)JSON.deserialize(resp, SVC_DTO_SMSRestResponse.class);
            handleResponse(response, recordId);
        } catch(Exception e) {
            LOGGER.error('Error processing request: ' + e.getMessage(), new String[] {'Class: SVC_API_SendSMS', 'Method: sendSMS'});
            prepareFeedItem(recordId, 'Failed to send SMS: ' + e.getMessage());
            if(!feedItemsToCreate.isEmpty() && Schema.sObjectType.FeedItem.isCreateable()) {
                insert feedItemsToCreate;
            }
        }
    }

    /**
     * @description Handles the API response
     * @param response The HTTP response
     * @param recordId The record ID
     */
    private static void handleResponse(SVC_DTO_SMSRestResponse response, String recordId) {
        if (response != null) {
            for(SVC_DTO_SMSRestResponse.Message msg : response.messages){
                prepareFeedItem(recordId, 'SMS Message was sent to a customer: ' + msg.messageBody);
            }
        } else {
            prepareFeedItem(recordId, 'Failed to send SMS');
        }
        if(!feedItemsToCreate.isEmpty() && Schema.sObjectType.FeedItem.isCreateable()) {
            insert feedItemsToCreate;
        }
    }
    
    /**
     * @description Creates a success feed item
     * @param recordId The record ID
     * @param message The success message
     */
    private static void prepareFeedItem(String recordId, String message) {
        feedItemsToCreate.add( new FeedItem(
            ParentId = recordId,
            Body = message,
            Type = 'TextPost'
        ));
    }

}