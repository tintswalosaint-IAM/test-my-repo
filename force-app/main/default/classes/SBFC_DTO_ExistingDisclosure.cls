/**
 * @description       : DTO used to return existing disclosure details
 *                      for the Generate Disclosure reuse functionality.
 * @Created Date      : 06-28-2026
 * @author            : Gigyasu Jain
 **/
public class SBFC_DTO_ExistingDisclosure {

    @AuraEnabled
    public String plannerName;
   
    @AuraEnabled
    public Boolean hasDisclosure;

    @AuraEnabled
    public String documentName;

    @AuraEnabled
    public Datetime createdDate;

    @AuraEnabled
    public Id contentDocumentId;

    @AuraEnabled
    public Id infoAuthorizationRequestId;

}