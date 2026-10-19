/**
 * Contains DATA used in OTP sceen
 *
 * <p>DBP-1638-1639-1640-1641</p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Dec 22th 2020
 */
public with sharing class AOB_DTO_OTP {
  @AuraEnabled
  public String phoneNumber { get; set; }
  @AuraEnabled
  public String callCenter { get; set; }
  @AuraEnabled
  public String cryptedNumber { get; set; }
}