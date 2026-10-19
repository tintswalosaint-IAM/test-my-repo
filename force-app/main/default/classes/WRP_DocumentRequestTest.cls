/**
 * @description       : WRP_DocumentRequestTest Wrapper test
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-19-2024
 * @last modified by  : Jaco de Lange
**/
@isTest
public class WRP_DocumentRequestTest {

    @isTest
    static void testConstructor() {
        // Test constructor
        Test.startTest();
        WRP_DocumentRequest documentRequest = new WRP_DocumentRequest();
        Test.stopTest();
        // Assert that the instance is not null
        Assert.areNotEqual(null, documentRequest, 'WRP Document request wrapper is null');
    }

    @isTest
    static void testDocumentRequestClass() {
        // Test DocumentRequest class instantiation
        Test.startTest();
        WRP_DocumentRequest.DocumentRequest docRequest = new WRP_DocumentRequest.DocumentRequest();
        Test.stopTest();
        // Assert that the instance is not null
        Assert.areNotEqual(null, docRequest, 'Document request wrapper is null');
    }
 }