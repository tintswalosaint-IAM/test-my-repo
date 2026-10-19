/**
 * @description Class used as Wrapper Class to display select options
 *
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 */
public class AOB_SelectOption {
  @AuraEnabled
  /** @description smallDeviceColumns parameter */ 
  public string value { get; set; }
  @AuraEnabled
  /** @description smallDeviceColumns parameter */ 
  public string label { get; set; }
  @AuraEnabled
  /** @description smallDeviceColumns parameter */ 
  public boolean enabled { get; set; }
  @AuraEnabled
  /** @description smallDeviceColumns parameter */ 
  public boolean selected { get; set; }
  @AuraEnabled
  /** @description smallDeviceColumns parameter */ 
  public boolean isDefault { get; set; }
  @AuraEnabled
  /** @description smallDeviceColumns parameter */ 
  public String currencyZ { get; set; }
  /** 
    * @description This method used for main callout that is SMSAlert API 
    * @param a
    * @param b
  */
  public AOB_SelectOption(string a, string b) {
    this.value = a;
    this.label = b;
    this.enabled = true;
    this.selected = false;
    this.isDefault = false;
  }
   /** 
    * @description This method used for main callout that is SMSAlert API 
    * @param a
    * @param b
    * @param isDefault
  */ 
  public AOB_SelectOption(string a, string b, boolean isDefault) {
    this.value = a;
    this.label = b;
    this.enabled = true;
    this.selected = false;
    this.isDefault = isDefault;
  }
}