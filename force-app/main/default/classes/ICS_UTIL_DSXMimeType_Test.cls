/**
 * @description Test Class for ICS_UTIL_DSXMimeType
 * @author Sizwe November
 * @date September 2024
 */
@IsTest
public with sharing class ICS_UTIL_DSXMimeType_Test {
 
    @isTest
    static void testTextFile() {
        
        String fileExtension = 'txt';
		String expectedMimeType = 'text/plain';
        Test.startTest();
        String mimeType = ICS_UTIL_DSXMimeType.getMimeType(fileExtension);
        Test.stopTest();

        Assert.areEqual(expectedMimeType, mimeType, 'text file');
    }
    
    @isTest
    static void testPDF() {
        
        String fileExtension = 'pdf';
		String expectedMimeType = 'application/pdf';
        Test.startTest();
        String mimeType = ICS_UTIL_DSXMimeType.getMimeType(fileExtension);
        Test.stopTest();

        Assert.areEqual(expectedMimeType, mimeType, 'pdf file');
    }
   
    @isTest
    static void testDocument() {
        
        String fileExtension = 'doc';
		String expectedMimeType = 'application/octet-stream';
        Test.startTest();
        String mimeType = ICS_UTIL_DSXMimeType.getMimeType(fileExtension);
        Test.stopTest();

        Assert.areEqual(expectedMimeType, mimeType, 'word document');
    }
    
    @isTest
    static void testExcelFile() {
        
        String fileExtension = 'xlsx';
		String expectedMimeType = 'application/octet-stream';
        Test.startTest();
        String mimeType = ICS_UTIL_DSXMimeType.getMimeType(fileExtension);
        Test.stopTest();

        Assert.areEqual(expectedMimeType, mimeType, 'excel document');
    }
    
    @isTest
    static void testImage() {
        
        String fileExtension = 'jpeg';
		String expectedMimeType = 'image/jpeg';
        Test.startTest();
        String mimeType = ICS_UTIL_DSXMimeType.getMimeType(fileExtension);
        Test.stopTest();

        Assert.areEqual(expectedMimeType, mimeType, 'image format');
    }
    
  
}