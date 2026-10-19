/**
 * @description Contains utility methods to support PING OAUTH and OIDC (with PKCE) methods
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaff
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date October 2020
 */
public class CMN_UTIL_OAuth {
  private static final Integer CODE_LENGTH = 128;
  private static final String SECURE_HASH_ALGORITHM = 'SHA-256';

  /**
   * @description generates random 128 character ASCII digit and letters verifier code as part of PKCE
   * used by PING
   *
   * @return code e.g. xZ31323yhaASGFDGDF..... (128)
   */
  public static String generateRandomCode() {
    return CMN_UTIL_String.generateRandomString(CODE_LENGTH);
  }

  /**
   * @description generates SHA-256 has of input random string e.g. verifier code as part of PKCE
   * note this is not url param friendly so see generateChallenge
   *
   * @param value hash of input value
   *
   * @return String hash (not url friendly) e.g. HsaFcD6Qz+R1DBccrWf+Vm1dytXHolG1snFtSLj54OQ=
   */
  public static String generateHash(String value) {
    Blob verifierCode = Blob.valueOf(value);

    Blob hash = Crypto.generateDigest(SECURE_HASH_ALGORITHM, verifierCode);

    String challenge = EncodingUtil.base64Encode(hash);

    return challenge;
  }

  /**
   * @description returned url friendly hash
   *
   * @param value to hash
   *
   * @return String hash (url friendly) e.g. HsaFcD6_zAR1DBcc-Wf9Vm1dytXHolG1snFtSLj54OQ
   */
  public static String generateChallenge(String value) {
    return generateHash(value)
      .replace('+', '-')
      .replace('/', '_')
      .replace('=', CMN_UTIL_String.EMPTY);
  }

  /**
   * @description returned alphanumeric hash (e.g. to use as cache key)
   * <p/>
   * Low probability that a duplicate will be produced.
   *
   * @param value to hash
   *
   * @return String hash (url friendly) e.g. HsaFcD6QzAR1DBccrWf9Vm1dytXHolG1snFtSLj54OQ
   */
  public static String generateAlphanumericHash(String value) {
    return generateHash(value)
      .replace('+', CMN_UTIL_String.EMPTY)
      .replace('/', CMN_UTIL_String.EMPTY)
      .replace('=', CMN_UTIL_String.EMPTY);
  }
}