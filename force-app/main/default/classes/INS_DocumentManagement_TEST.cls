/**
 * @description : Test class for DocumentManagement
 * @author: Dhiraj Prajapati
 *
**/
@isTest
public class INS_DocumentManagement_TEST {

    @isTest
    static Void testDocumentExtension() {
        INS_API_ESBDocumentRepositoryManager esbDM = new INS_API_ESBDocumentRepositoryManager();

        INS_UTIL_File testFile = new INS_UTIL_File();
        ContentVersion cv = INS_DocumentManagementTestFactory_TEST.createContentVersion(INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id);
        insert cv;
        Claim cl = INS_DocumentManagementTestFactory_TEST.createClaim();
        testFile.setRecordId(cl.Id);

        Test.startTest();
            DocumentImplementorDummy implementor = new DocumentImplementorDummy();
            implementor.setFile(testFile);
            List<INS_UTIL_Taxonomy> taxonomyLst1 = esbDM.getTaxonomies();
            List<INS_UTIL_Taxonomy> taxonomyLst2 = implementor.getTaxonomies();
            INS_UTIL_DocumentInfo info = implementor.send();
        Test.stopTest();
        Assert.areEqual(taxonomyLst1, taxonomyLst2);
        Assert.areEqual(testFile.getRecordId(), cl.Id);
        Assert.areEqual(null, info, 'Should not be populated!');
    }

    //Extending the class here to mock method calls
    private class DocumentImplementorDummy extends INS_UTIL_DocumentManagement {}
}