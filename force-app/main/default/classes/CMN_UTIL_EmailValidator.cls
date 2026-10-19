/**
 * @description Email validation utility class
 *
 * @author Raymond Magezi
 *
 * @date February 2026
 *
 * @see CMN_UTIL_EmailValidator_TEST
 *
 * @history 23-02-2026  Raymond Magezi  Extracted from CMN_QUEUE_SendEscalationEmails
 * @history 16-04-2026  Raymond Magezi  Converted documentation to Javadoc standard - SFP-55654
 */
public inherited sharing class CMN_UTIL_EmailValidator {
    private CMN_UTIL_EmailValidator() {}
    
    private static final String EMAIL_REGEX = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    
    /**
     * @description Validates email address format
     *
     * @param email Email address to validate
     *
     * @return Boolean true if valid format, false otherwise
     */
    public static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        
        Pattern pattern = Pattern.compile(EMAIL_REGEX);
        Matcher matcher = pattern.matcher(email);
        
        return matcher.matches();
    }
    
    /**
     * @description Validates list of CC email addresses
     *
     * @param ccAddresses List of CC email addresses
     *
     * @return Boolean true if all valid, false otherwise
     */
    public static Boolean areValidCcAddresses(List<String> ccAddresses) {
        if (ccAddresses == null) {
            return true;
        }
        
        for (String ccEmail : ccAddresses) {
            if (String.isNotBlank(ccEmail) && !isValidEmail(ccEmail)) {
                return false;
            }
        }
        return true;
    }
}