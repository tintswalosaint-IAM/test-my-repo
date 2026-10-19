/**
* @description Document Info API response
* @author Gnitsevich Anton
* @date June 2022
*/
public with sharing class CMN_DTO_CustomerDocInfoResponse {
    
    @AuraEnabled public String docCategoryDesc { get; set; }
    @AuraEnabled public String docCategoryCode { get; set; }
    @AuraEnabled public String cnttURL { get; set; }
    @AuraEnabled public String cnttId { get; set; }
    @AuraEnabled public String docTitle { get; set; }
    @AuraEnabled public String docType { get; set; }
    @AuraEnabled public String docTypeName { get; set; }
    @AuraEnabled public String docTypeDesc { get; set; }
    @AuraEnabled public String docContentType { get; set; }
    @AuraEnabled public String docContentTypeName { get; set; }
    @AuraEnabled public String createdDt { get; set; }
    @AuraEnabled public String docContLastUpdateDt { get; set; }
    @AuraEnabled public String creationUserID { get; set; }
    @AuraEnabled public String lastChangeUserID { get; set; }
    @AuraEnabled public String path { get; set; }
    @AuraEnabled public String language { get; set; }
    @AuraEnabled public List<CMN_DTO_CustomerDocInfoResponse> additionalDoc { get; set; }
}