/**
 * @description Test Class for ICS_UTIL_HttpMultipartForm
 * @author Sizwe November
 * @date September 2024
 */
@IsTest
public with sharing class ICS_UTIL_HttpMultipartForm_Test {
 
    @isTest
    static void testResolveMimeType() {
        
        String fileName = ' John-Johns-ProofofLoan-1.txt';
		String expectedMimeType = 'text/plain';
        Test.startTest();
        String mimeType = ICS_UTIL_HttpMultipartForm.resolveMimeType(fileName);
        Test.stopTest();

        Assert.areEqual(expectedMimeType, mimeType, 'Mimetype returned');
    }
    
    @isTest
    static void testWriteFile() {
        
        String key = 'file';
        String fileName = 'John-Johns-ProofofLoan-1.txt';
        Blob fileContent = Blob.valueof('1');
        String boundary = '--icssbdsx12A3GF';
        String expectedResults = 'ICS_UTIL_HttpMultipartForm:[boundary=--icssbdsx12A3GF, form=2d2d2d2d69637373626473783132413347460d0a436f6e74656e742'+
            						'd446973706f736974696f6e3a20666f726d2d646174613b206e616d653d2266696c65223b2066696c656e616d653d224a6f686e2d4a6f686e'+
            						'732d50726f6f666f664c6f616e2d312e747874223b0d0a436f6e74656e742d547970653a20746578742f706c61696e3b0d0a0d0a310d0a]';
        Test.startTest();
        ICS_UTIL_HttpMultipartForm httpMultipartForm = new ICS_UTIL_HttpMultipartForm (boundary);
        ICS_UTIL_HttpMultipartForm httpMultipartFormResults = httpMultipartForm.writeFile(key, fileName, fileContent);
        Test.stopTest();
        Assert.areEqual(expectedResults, String.valueOf(httpMultipartFormResults), 'HttpMultipartForm successful');
    }
 	
    @isTest
    static void testBuild() {
        
        String boundary = '--icssbdsx12A3GF';
        String expectedResults = 'ICS_UTIL_HttpMultipartForm:[boundary=--icssbdsx12A3GF, form=null]';
        Test.startTest();
        ICS_UTIL_HttpMultipartForm httpMultipartFormResults = ICS_UTIL_HttpMultipartForm.build(boundary);
        Test.stopTest();
        Assert.areEqual(expectedResults, String.valueOf(httpMultipartFormResults), 'HttpMultipartForm successful');
    }    
    
    @isTest
    static void testWriteParam() {
        
        String key = 'id';
        String value = 'abcvOty57656';
        String boundary = '--icssbdsx12A3GF';
        String expectedResults = 'ICS_UTIL_HttpMultipartForm:[boundary=--icssbdsx12A3GF, form=2d2d2d2d69637373626473783132413347460d0a436f6e7465'+
            					 '6e742d446973706f736974696f6e3a20666f726d2d646174613b206e616d653d226964223b0d0a0d0a616263764f747935373635360d0a]';
        Test.startTest();
        ICS_UTIL_HttpMultipartForm httpMultipartForm = new ICS_UTIL_HttpMultipartForm (boundary);
        ICS_UTIL_HttpMultipartForm httpMultipartFormResults = httpMultipartForm.writeParam(key, value);
        Test.stopTest();
        Assert.areEqual(expectedResults, String.valueOf(httpMultipartFormResults), 'HttpMultipartForm successful');
    }
    
    @isTest
    static void testFormAsBlob() {
        
        String boundary = '--icssbdsx12A3GF';
        String expectedResults = 'LS0tLWljc3NiZHN4MTJBM0dGLS0=';
        Test.startTest();
        ICS_UTIL_HttpMultipartForm httpMultipartForm = new ICS_UTIL_HttpMultipartForm (boundary);
        Blob httpMultipartFormResults = httpMultipartForm.getFormAsBlob();
        Test.stopTest();
        Assert.areEqual(expectedResults,EncodingUtil.base64Encode(httpMultipartFormResults), 'HttpMultipartForm successful');
    }
  
}