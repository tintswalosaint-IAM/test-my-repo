/**
 * @description Service class for transforming and validating email requests
 *
 * @author Raymond Magezi
 *
 * @date February 2026
 *
 * @see CMN_SVC_EmailRequestTransformer_TEST
 *
 * @history 23-02-2026  Raymond Magezi  Extracted from CMN_QUEUE_SendEscalationEmails
 * @history 16-04-2026  Raymond Magezi  Converted documentation to Javadoc standard - SFP-55654
 */
public inherited sharing class CMN_SVC_EmailRequestTransformer {
    private CMN_SVC_EmailRequestTransformer() {}
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_SVC_EmailRequestTransformer.class.getName());
    
    /**
     * @description Transforms EmailRequest to DTO_SendEmailRequest
     *
     * @param requests List of EmailRequest objects
     *
     * @return List of DTO_SendEmailRequest
     */
    public static List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> transform(List<CMN_QUEUE_SendEscalationEmails.EmailRequest> requests) {
        List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> emailDtos = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>();
        
        for (CMN_QUEUE_SendEscalationEmails.EmailRequest req : requests) {
            if (!isValid(req)) {
                LOGGER.warn('transform: Skipping invalid request - To: {0}', new Object[]{req?.toAddress});
                continue;
            }
            
            CMN_FLOW_SendEmail.DTO_SendEmailRequest emailReq = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
            emailReq.toAddress = req.toAddress;
            emailReq.ccAddress = filterValidEmails(req.ccAddresses);
            emailReq.templateUniqueName = req.templateName;
            emailReq.orgWideEmailAddress = req.orgWideEmail;
            emailReq.whatId = req.caseId;
            
            emailDtos.add(emailReq);
        }
        
        LOGGER.debug('transform: Transformed {0} valid request(s)', new Object[]{emailDtos.size()});
        return emailDtos;
    }
    
    /**
     * @description Validates EmailRequest
     *
     * @param req EmailRequest to validate
     *
     * @return Boolean true if valid, false otherwise
     */
    public static Boolean isValid(CMN_QUEUE_SendEscalationEmails.EmailRequest req) {
        return req != null 
            && hasRequiredFields(req) 
            && CMN_UTIL_EmailValidator.isValidEmail(req.toAddress);
    }
    
    /**
     * @description Validates DTO_SendEmailRequest
     *
     * @param req DTO_SendEmailRequest to validate
     *
     * @return Boolean true if valid, false otherwise
     */
    public static Boolean isValidDto(CMN_FLOW_SendEmail.DTO_SendEmailRequest req) {
        return req != null 
            && String.isNotBlank(req.toAddress) 
            && CMN_UTIL_EmailValidator.isValidEmail(req.toAddress) 
            && String.isNotBlank(req.whatId) 
            && String.isNotBlank(req.templateUniqueName);
    }
    
    private static Boolean hasRequiredFields(CMN_QUEUE_SendEscalationEmails.EmailRequest req) {
        if (String.isBlank(req.toAddress) || String.isBlank(req.caseId) || String.isBlank(req.templateName)) {
            LOGGER.debug('hasRequiredFields: Required field missing');
            return false;
        }
        return true;
    }
    
    /**
     * @description Filters out invalid email addresses from CC list
     *
     * @param ccAddresses List of CC email addresses
     *
     * @return List of valid CC email addresses
     */
    private static List<String> filterValidEmails(List<String> ccAddresses) {
        if (ccAddresses == null || ccAddresses.isEmpty()) {
            return new List<String>();
        }
        List<String> validEmails = new List<String>();
        for (String email : ccAddresses) {
            if (String.isNotBlank(email) && CMN_UTIL_EmailValidator.isValidEmail(email)) {
                validEmails.add(email);
            }
        }
        return validEmails;
    }
}