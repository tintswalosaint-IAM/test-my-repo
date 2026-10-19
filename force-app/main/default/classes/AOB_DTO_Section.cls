/**
* @description Class used as Wrapper Class to display section info
*
* @author Yashwanth Tikkisetti (yaswanth.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
public class AOB_DTO_Section{
    /**
    * @description rank
    * @return Decimal
    */
    @AuraEnabled 
    public Decimal rank { get; set; }
    /**
    * @description largeDeviceColumns
    * @return Decimal
    */
    @AuraEnabled 
    public Decimal largeDeviceColumns { get; set; }
    /**
    * @description value
    * @return String
    */
    @AuraEnabled
    public Decimal mediumDeviceColumns { get; set; }
    /**
    * @description smallDeviceColumns
    * @return Decimal
    */
    @AuraEnabled
    public Decimal smallDeviceColumns { get; set; }
    public Id identifier;
    /**
    * @description title
    * @return String
    */
    @AuraEnabled
    public String title { get;set; }
    /**
    * @description sectionName
    * @return String
    */
    @AuraEnabled
    public String sectionName { get;set; }
    /**
    * @description gridClass
    * @return String
    */
    @AuraEnabled
    public String gridClass { get;set; }
    /**
    * @description fields
    * @return List<AOB_DTO_Field>
    */
    @AuraEnabled
    public List<AOB_DTO_Field> fields { get; set; } 
}