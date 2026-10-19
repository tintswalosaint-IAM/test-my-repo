/**
*  @description wrapperClass dealing with screen buttons
*
*
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date june 2022
*/
public without sharing class AOB_ScreenButtonWrapper{
    @AuraEnabled
     /** @description attribute **/
    public String label {get; set;}
    @AuraEnabled
    /** @description attribute **/
    public String variant {get; set;}
    @AuraEnabled
    /** @description attribute **/
    public String buttonJSFunction {get; set;}
    @AuraEnabled
    /** @description attribute **/
    public Boolean isApexCall {get; set;}
    
}