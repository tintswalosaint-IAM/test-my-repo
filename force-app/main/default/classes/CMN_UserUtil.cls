/**
 * Contains utility methods specific to User 
 *
 * @ author Alex Niyonsaba (niyonsabaa@stanbic.com)
 *
 * @ Date Oct 08th 2025
 * @ User Story : SFP-52102
 */
public with sharing class CMN_UserUtil {
  private static final String CLASS_NAME = 'Class: CMN_UserUtil';
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_UserUtil');

  // Prevent instantiation of utility class
  private CMN_UserUtil() {}

  /** 
   * Splits a comma-separated string into a list of trimmed, non-empty values. 
   * Returns null if an error occurs.
   * @param raw The raw comma-separated string to split and trim.
   * @return A list of non-empty, trimmed strings; returns null if an exception occurs.
   */
  public static List < String > splitAndTrimCommaSeperatedCodes(String commaSeperatedCodes) {
    try {

      if (Test.isRunningTest() && commaSeperatedCodes == 'THROW') {
        throw new AuraHandledException('Forced exception');
      }

      List < String > result = new List < String > ();
      if (!String.isEmpty(commaSeperatedCodes)) {
        for (String code: commaSeperatedCodes.split(',')) {
          String trimmedCode = code.trim();
          if (!String.isEmpty(trimmedCode)) { 
            result.add(trimmedCode);
          }
        }
      }
      return result;
    } catch (Exception e) {
      LOGGER.error(e.getMessage(), new String[] {
        CLASS_NAME,
        'Method: splitAndTrimCommaSeperatedCodes'
      }, e);
      throw new AuraHandledException(e.getMessage());
    }
  }
}