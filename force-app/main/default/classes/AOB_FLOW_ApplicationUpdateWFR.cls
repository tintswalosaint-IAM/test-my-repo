/**
 * Class used to Perform an update on application record for WFR
 *
 * <p>DBP-1459</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date DEC 18th 2020
 */
public with sharing class AOB_FLOW_ApplicationUpdateWFR {
  private static final String CURRENTSTEP = 'AOB_WebFaceRecognition';

  /**
   * @description updates application record based on progress
   *
   * @param application Ids
   */
  @InvocableMethod(
    Label='WFR Update Application'
    Description='Updates Application record to indicate next step'
  )
  public static void updateApplication(List<String> applicationIds) {
    /*AOB_SRV_ApplicationManagement.updateApplication(
      applicationIds,
      CURRENTSTEP,
      null
    );*/
  }
}