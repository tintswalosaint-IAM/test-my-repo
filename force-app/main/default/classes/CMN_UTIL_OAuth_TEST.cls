/**
 * @description Tests the CMN_UTIL_OAuth methods
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaff
 * @see CMN_UTIL_OAuth
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date October 2020
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_OAuth_TEST {
  /**
   * @description tests that a random 128 length code is generated.
   */
  @IsTest
  private static void generateRandomCode() {
    System.assert(CMN_UTIL_OAuth.generateRandomCode().length() == 128);
  }

  /**
   * @description tests that hash is not alphanumerics but conforms to SHA256 algorithm
   */
  @IsTest
  private static void generateHash() {
    String returned = CMN_UTIL_OAuth.generateHash(
      CMN_UTIL_OAuth.generateRandomCode()
    );
    System.assert(!CMN_UTIL_String.isAlphanumeric(returned));
  }

  /**
   * @description tests for a url friendly hash challenge without url specific characters e.g. + / =
   */
  @IsTest
  private static void generateChallenge() {
    String returned = CMN_UTIL_OAuth.generateChallenge(
      CMN_UTIL_OAuth.generateRandomCode()
    );
    Boolean hasInvalidChar = CMN_UTIL_String.containsAny(returned, '+/=');
    System.assertEquals(
      false,
      hasInvalidChar,
      'Challenge is not generated correctly.'
    );
  }

  /**
   * @description tests to ensure hash only contains numbers and letters
   */
  @IsTest
  private static void generateAlphanumericHash() {
    String returned = CMN_UTIL_OAuth.generateAlphanumericHash(
      CMN_UTIL_OAuth.generateRandomCode()
    );
    System.assert(CMN_UTIL_String.isAlphanumeric(returned));
  }
}