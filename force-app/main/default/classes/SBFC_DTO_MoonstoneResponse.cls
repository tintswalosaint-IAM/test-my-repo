/**
 * @description       : This DTO class is used to deserialize the response from Moonstone Disclosure API,including status and the Base64-encoded disclosure PDF.
 * @Created Date      : 01-26-2026
 * @author            : Gigyasu Jain
 * @group             : 
 * @last modified on  : 01-26-2026
 * @last modified by  : Gigyasu Jain
**/

public class SBFC_DTO_MoonstoneResponse {
    
    @AuraEnabled
    public String status;

    @AuraEnabled
    public String msg;

    @AuraEnabled
    public Data data;

    public class Data {
        @AuraEnabled
        public String base64pdf;
    }

}