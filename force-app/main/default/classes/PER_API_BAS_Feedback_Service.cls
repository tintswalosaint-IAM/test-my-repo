/**
 * @description       : API Service for Personalisation Event Alert Feedback loop
 * @test              : PER_API_BAS_Feedback_Service_Test
 * @author            : Sandile Mathe
 * @group             : API
 * @Created           : 17-02-2025
 *
  **/

public class PER_API_BAS_Feedback_Service extends sbgplatform.ApiGatewayService{

     // Constants
       private static final String NAMED_CREDENTIAL = 'API_Gateway_Personalisation';
       private static final String PATH_EVENT_FEEDBACK_SINGLE = '/smart-conversations/centaur-banker-history';

        public PER_API_BAS_Feedback_Service () {
           super(NAMED_CREDENTIAL);
       }

    /**
     * @description Method to send event update to NBA API
     * @param eventId
     * @param finalEmailContent
     * @author: Sandile Mathe
     */
    public void sendEventUpdate(String eventId, String finalEmailContent) {
        
        //Prepare Request Data
        String requestBody = '[{"eventId": ' + eventId + ', "finalEventContent": "' + finalEmailContent + '"}]';
		String response = (String) post(PATH_EVENT_FEEDBACK_SINGLE, requestBody);
    }
    
    private class ServiceException extends Exception {}
}