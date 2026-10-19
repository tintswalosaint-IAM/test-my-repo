/**
 * @description       : To generate session ID and publish approval event
 * @author            : jagadish Thummala
 * User Story ID       : SFP-28286
 * @last modified on  : 11-03-2025
 * @last modified by  : jagadish Thummala
**/
public without sharing class UG_AOB_PPB_ApprovalEventController {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('UG_AOB_PPB_ApprovalEventController');
    /**
    * @description 
    * @author jagadish Thummala | 10-14-2025 
    * @param status 
    * @param sessionId 
    * @param consentData 
    * @return string 
    **/
    @AuraEnabled
    public static string publishApprovalEvent(String status, String sessionId, String consentData) {
        try {            
            PPB_Terms_and_Condtions_Approval_Status__e approvalEvent = new PPB_Terms_and_Condtions_Approval_Status__e(
                Status__c = status,
                Session_Id__c = sessionId,
                Consent_Map__c = consentData,
                Timestamp__c = System.now()
            );
            
            Database.SaveResult result = EventBus.publish(approvalEvent);
            
            if (result.isSuccess()) {
                return result.id;
            } else {
                String errorMessage = 'Failed to publish approval event';
                if (result.getErrors().size() > 0) {
                    errorMessage += ': ' + result.getErrors()[0].getMessage();
                }
                throw new AuraHandledException(errorMessage);
                 
            }
            
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_ApprovalEventController.publishApprovalEvent' ,e.getMessage());
            throw new AuraHandledException('Error publishing event: ' + e.getMessage());
        }
    }
    
    /**
    * @description 
    * @author jagadish Thummala | 10-14-2025 
    * @return String 
    **/
  @AuraEnabled
    public static String generateSessionId() {
        try {
            // Generate timestamp component
            Long timestamp = System.currentTimeMillis();
            
            // Generate secure random component using Crypto class
            Integer randomInt = Math.abs(Crypto.getRandomInteger());
            String randomPart = String.valueOf(randomInt).substring(0, 6);
            
            // Handle edge case where random number has fewer than 6 digits
            while (randomPart.length() < 6) {
                randomPart += String.valueOf(Math.abs(Crypto.getRandomInteger())).substring(0, 1);
            }
                        
            return  String.valueOf(timestamp) + '_' + randomPart;
            
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_ApprovalEventController.generateSessionId' ,e.getMessage());
            throw new AuraHandledException('Unable to generate session ID. Please try again.');
        }
    }

}