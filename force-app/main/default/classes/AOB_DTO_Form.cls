/**
* @description Class used as Wrapper Class to display form info
*
* @author Yashwanth Tikkisetti (yash.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
public class AOB_DTO_Form{
    /**
    * @description title
    * @return String
    */
    @AuraEnabled
    public String title { get; set; }
    /**
    * @description subtitle
    * @return String
    */
    @AuraEnabled
    public String subtitle { get; set; }
    /**
    * @description sections
    * @return List<AOB_DTO_Section>
    */
    @AuraEnabled
    public List<AOB_DTO_Section> sections { get; set; }
   
}