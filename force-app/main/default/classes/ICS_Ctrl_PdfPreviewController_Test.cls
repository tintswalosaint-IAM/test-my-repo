/**
* @description Class used as test class to display PDF
*
* Story:SFP-48980
*
* @author Ikyatha Naidu
*
* @date May 2025
* @last modified on  : 12-05-2025
* @last modified by  : Ikyatha Naidu
* @Modification Description : Initial Version

*/
@isTest
public class ICS_Ctrl_PdfPreviewController_Test {
     @TestSetup
    static void setupData() {        
       Account acc= ICS_DAL_TestFactory.createAccount();
        List<Contentversion> versionInfo = ICS_DAL_TestFactory.createContentVersion();
        versionInfo =[select id,contentdocumentid from ContentVersion where id=:versionInfo[0].id ];
         ICS_DAL_TestFactory.createContentDocumentLink(acc.id,versionInfo[0].contentdocumentid);
        
    }
 @isTest
    static void testInsertData() {
        test.starttest();
        Account acc  =[select id from Account limit 1];
        ICS_Ctrl_PdfPreviewController.getContentVersion(acc.id);
         string urlInfo = ICS_Ctrl_PdfPreviewController.getContentDocumentUrl(acc.id);
        Assert.areEqual(true, urlInfo !=null, 'urlInfo should not be null');
        test.stoptest();
       
    }
    @isTest
    static void testInsertDataEmpty() {
         test.starttest();
        ContentVersion versionInfo = ICS_Ctrl_PdfPreviewController.getContentVersion('');
         ICS_Ctrl_PdfPreviewController.getContentDocumentUrl('');
        Assert.areEqual(true, versionInfo ==null, 'versionData is null');
        test.stoptest();
       
    }
}