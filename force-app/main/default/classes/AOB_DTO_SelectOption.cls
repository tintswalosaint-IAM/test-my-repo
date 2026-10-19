/**
 * @description Class used as Wrapper Class to display select options
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 */
public class AOB_DTO_SelectOption {
  /**
  * @description value
  * @return String
  */
  @AuraEnabled
  public string value { get; set; }
  /**
  * @description label
  * @return String
  */
  @AuraEnabled
  public string label { get; set; }
  /**
  * @description enabled
  * @return String
  */
  @AuraEnabled
  public boolean enabled { get; set; }
  /**
  * @description selected
  * @return String
  */
  @AuraEnabled
  public boolean selected { get; set; }
  /**
  * @description isDefault
  * @return String
  */
  @AuraEnabled
  public boolean isDefault { get; set; }
  /**
  * @description value
  * @return String
  */
  @AuraEnabled
  public String currency_Z { get; set; }
  public AOB_DTO_SelectOption() {
  }
  /**
  * @description constructor with 2 params
  * @param a
  * @param b
  */
  public AOB_DTO_SelectOption(string a, string b) {
    this.value = a;
    this.label = b;
    this.enabled = true;
    this.selected = false;
    this.isDefault = false;
  }

  /**
  * @description constructor with 2 params
  * @param a
  * @param b
  * @param isDefault
  */
  public AOB_DTO_SelectOption(string a, string b, boolean isDefault) {
    this.value = a;
    this.label = b;
    this.enabled = true;
    this.selected = false;
    this.isDefault = isDefault;
  }
}