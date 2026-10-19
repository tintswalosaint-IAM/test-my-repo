/**
 * @description       : API Service for Personalisation Event Alert
 * @test              : PER_API_BAS_Service_Test
 * @author            : Sandile Mathe
 * @group             : API
 * @Created           : 13-05-2024
 * 
 * 2025-07-16 Derek         Converted to use Integration Framework base class  
 **/
public class PER_API_BAS_Service extends sbgplatform.ApiGatewayService {
       // Constants
       private static final String NAMED_CREDENTIAL = 'API_Gateway_Personalisation';
       private static final String PATH_EVENT_ALERT_SINGLE = '/smart-conversations/centaur-banker';

       public PER_API_BAS_Service () {
           super(NAMED_CREDENTIAL);
       }
    
       /**
       * @description Sends the API call for the specified country and returns the response as a list of DTOs
       * @author Sandile Mathe
       * @param aeNumber 
       * @return List<BAS_DTO_EventAlertsResponse> 
       **/
       public List<BAS_DTO_EventAlertsResponse> getEventAlertsByAENumber( String aeNumber) {
  
              //Prepare Request Data
              String requestBody = '{"aeNumber":"{0}"}';
              requestBody = requestBody.replace('{0}', aeNumber);
           
              setResponseDtoType(List<BAS_DTO_EventAlertsResponse>.class);
           
              List<BAS_DTO_EventAlertsResponse> dto = (List<BAS_DTO_EventAlertsResponse>) post(PATH_EVENT_ALERT_SINGLE, requestBody);
           
              return dto;
         }
   
       private class ServiceException extends Exception {}

}