/**
 * @description: wrapper class to hold Content Version and external Document Id
 *
 * @author: Dhiraj Prajapti
 *
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|

 THIS CODE IS CONTROLLED BY THE INSURANCE TEAM
 For any changes requied please contact the Insurance team.
**/
public class INS_UTIL_DocumentInfo {

    @AuraEnabled
    public String externalDocumentId {get;set;}
    @AuraEnabled
    public String contentVersionId {get;set;}
    @AuraEnabled
    public Boolean isSuccess {get;set;}
    @AuraEnabled
    public String message {get;set;}

    public INS_UTIL_DocumentInfo(String documentId, String message) {
        this.externalDocumentId = documentId;
        this.message = message;
        this.isSuccess = String.isBlank(this.message);
    }
}