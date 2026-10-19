/**
* @description Class used as Wrapper Class to display section info
*
* @author Yashwanth Tikkisetti (yaswanth.tikkisetti@standardbank.co.za)
*
* @date July 2022
*/
public class AOB_Section{
    @AuraEnabled
    /** @description fields from screenfield object */ 
     public List<AOB_Field> fields { get; set; } 
     @AuraEnabled
    /** @description identifier parameter */ 
    public Id identifier { get; set; }
    @AuraEnabled
    /** @description rank for the order */ 
    public Decimal rank { get; set; }
    @AuraEnabled 
    /** @description largeDeviceColumns parameter */ 
    public Decimal largeDeviceColumns { get; set; }
    @AuraEnabled
    /** @description  mediumDeviceColumns parameter */ 
    public Decimal mediumDeviceColumns { get; set; }
    @AuraEnabled
    /** @description smallDeviceColumns parameter */ 
    public Decimal smallDeviceColumns { get; set; }
    @AuraEnabled
    /** @description title parameter */ 
    public String title { get;set; }
    @AuraEnabled
    /** @description gridClass parameter */ 
    public String gridClass { get;set; }
 
}