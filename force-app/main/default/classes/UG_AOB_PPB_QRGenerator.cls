/**
 * @description       : 
 * @author            : jagadish Thummala
 * @group             : 
 * @last modified on  : 10-15-2025
 * @last modified by  : jagadish Thummala
**/
public with sharing class UG_AOB_PPB_QRGenerator {
    private static final Integer TOKEN_EXPIRY_MINUTES = 3;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('UG_AOB_PPB_QRGenerator');

    /**
     * @description Generate time-based token without storing customer data
     */
    @AuraEnabled
    public static String generateTimeBasedToken() {
        try {
            // Create token with current timestamp and unique session
            Map<String, Object> tokenData = new Map<String, Object>{
                'timestamp' => System.currentTimeMillis(),
                'sessionId' => generateUniqueSessionId(),
                'expiry' => System.currentTimeMillis() + (TOKEN_EXPIRY_MINUTES * 60 * 1000)
            };
            
            // Encode token
            String jsonData = JSON.serialize(tokenData);
            Blob tokenBlob = Blob.valueOf(jsonData);
            return EncodingUtil.base64Encode(tokenBlob); // Fixed method name
            
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_QRGenerator.generateTimeBasedToken', e);
            throw new AuraHandledException('Token generation failed: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validate time-based token on Experience Site
     */
    @AuraEnabled
    public static Boolean validateTimeBasedToken(String token) {
        try {
            if (String.isBlank(token)) {
                return false;
            }
            
            // Decode token
            Map<String, Object> tokenData = decodeToken(token);
            Long expiry = (Long) tokenData.get('expiry');
            Long currentTime = System.currentTimeMillis();
            
            // Check if token is still valid (within 3 minutes)
            return currentTime <= expiry;
            
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_QRGenerator.validateTimeBasedToken', e);
            return false;

        }
    }
    
    /**
     * @description Check if token is from a valid timeframe (additional security)
     */
    @AuraEnabled
    public static Boolean isTokenTimeValid(String token, Long clientTimestamp) {
        try {
            Map<String, Object> tokenData = decodeToken(token);
            Long tokenTimestamp = (Long) tokenData.get('timestamp');
            
            // Allow small time difference for network delays (30 seconds)
            Long timeDifference = Math.abs(clientTimestamp - tokenTimestamp);
            return timeDifference <= 30000; // 30 seconds tolerance
            
        } catch (Exception e) {
            return false;
        }
    }
    
    // PRIVATE HELPER METHODS
    
    private static String generateUniqueSessionId() {
        return EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 16) + 
               String.valueOf(System.currentTimeMillis()).substring(8);
    }
    
    private static Map<String, Object> decodeToken(String token) {
        try {
            Blob decodedBlob = EncodingUtil.base64Decode(token); 
            String jsonData = decodedBlob.toString();
            return (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid token format');
        }
    }
}