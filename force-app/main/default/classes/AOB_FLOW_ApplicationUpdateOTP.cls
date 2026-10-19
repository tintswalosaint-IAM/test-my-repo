/**
 * Class used to Perform an update on application record for OTP Screen
 *
 * <p>DBP-1621s</p>
 *
 * @author (aessbai@salesforce.com)
 *
 * @date DEC 20th 2020
 */
public class AOB_FLOW_ApplicationUpdateOTP {
  private static final string CURRENTSTEP = 'AOB_OTP';

  /**
   * @description updates application record based on progress
   *
   * @param application Ids
   */
  @InvocableMethod(
    Label='OTP Update Application'
    Description='Updates Application record to indicate next step'
  )
  public static void updateApplication(List<string> applicationIds) {
    /*AOB_SRV_ApplicationManagement.updateApplication(
      applicationIds,
      CURRENTSTEP,
      null
    );*/
  }
}