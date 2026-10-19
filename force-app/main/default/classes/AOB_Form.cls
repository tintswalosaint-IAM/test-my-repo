/**
* @description Class used as Wrapper Class to display form info
*
* @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
public class AOB_Form{
    /** @description title */
    @AuraEnabled
    public String title { get; set; }
    /** @description subtitle */
    @AuraEnabled
    public String subtitle { get; set; }
    /** @description sections */
    @AuraEnabled
    public List<AOB_DTO_Section> sections { get; set; }
    /** @description popup */
    @AuraEnabled
    public String popup { get; set; } 
}