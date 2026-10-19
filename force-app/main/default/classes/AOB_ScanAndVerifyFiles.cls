/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_ScanAndVerifyFiles
@ Description       :For dealing with scanning and verifying the files to be uploaded to the external systems
@ Last Modified By  :Jagadish Thummala.
@ Last Modified On  :15/02/2024.
@ Modification Description : SFP-31036
***************************************************************************************/
 /**
    * @description For dealing with scanning and verifying the files to be uploaded to the external systems
 */
public without sharing class AOB_ScanAndVerifyFiles {

    private static final String HEADER_CONTENT_TYPE = 'Content-Type';
    private static final String HEADER_CONNECTION = 'Connection';
    private static final String HEADER_CONNECTION_VALUE = 'keep-alive';
    private static final String HEADER_CONTENT_LENGTH = 'Content-Length';
    private static final String HTTP_METHOD_POST = 'POST';
    private final static string BOUNDARY = '1ff13444ed8140c7a32fc4e6451aa76d';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_ScanAndVerifyFiles');


    //using for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';

    /** 
    * @description This method used for invocableMethod
    * @param applicationList
    * @param documentList
    * @return Returns a callout response in map format for remaining processing
    */
    public static String invocableMethod(List<Application__c> applicationList, List<ContentVersion> documentList)  { 
        if(applicationList.isEmpty() == false && documentList.isEmpty() == false) {
            Map<String, Object> responseObject = verifySelectedFile(applicationList, documentList);
            return JSON.serialize(responseObject);
        }
        return null;
    }
    /** 
    * @description This method used for makeDSXCallOut
    * @param applicationRecords
    * @param documentList
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> verifySelectedFile(List<Application__c> applicationRecords, List<ContentVersion> documentList) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();

        String body = '';
        body += writeBoundary();
        if(Test.isRunningTest() == false) {
            body += writeBlobBodyParameter('file', String.valueOf(documentList[0].VersionData), documentList[0].Title);
        } else {
            body += writeBlobBodyParameter('file', String.valueOf(documentList[0].Description), documentList[0].Title);
        }
        body += writeBoundary(null);
        Blob formBlob = EncodingUtil.base64Decode(body);

        NamedCredential namedCredentialRecord = AOB_APIHandler.getMcAfeeCredentials();
        
        //Set Request Details
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader(HEADER_CONTENT_TYPE, getContentType());
        httpRequest.setHeader(HEADER_CONNECTION, HEADER_CONNECTION_VALUE);
        httpRequest.setHeader(HEADER_CONTENT_LENGTH, String.valueOf(formBlob.size()));
        httpRequest.setEndpoint(namedCredentialRecord.Endpoint);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setTimeout(120000);
        
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (System.Test.isRunningTest()) {
                if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                }
            }
          
            httpResponse = http.Send(httpRequest);
            if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                
                responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS'};
            } else {
                String errorMessage = 'File format is not supported';
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'CMN_fileScreening',ex.getMessage()}, ex);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
        }

        return responseToReturnObject;
    }

    /**
     * @description Returns the request's content type for multipart/form-data requests.
     * @return returns the concatenated boundary
     */
    public static string getContentType() {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + BOUNDARY + '"';
    }

    /**
     * @description Pad the value with spaces until the base64 encoding is no longer padded.
     * @param value
     * @param valueCrLf64
     * @param lineBreaks
     * @return valueCrLf64
     */
    private static string safelyPad(
        string value,
        string valueCrLf64,
        string lineBreaks) {
        string valueCrLf = '';
        blob valueCrLfBlob = null;

        while (valueCrLf64.endsWith('=')) {
            value += ' ';
            valueCrLf = value + lineBreaks;
            valueCrLfBlob = blob.valueOf(valueCrLf);
            valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }

        return valueCrLf64;
    }

    /**
     * @description Write a boundary between parameters to the form's body.
     * @return returns the encoded base 64 string
     */
    public static string writeBoundary() {
        string value = '--' + Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);
       return EncodingUtil.base64Encode(valueBlob);
    }

    /**
     * @description Write a boundary at the end of the form's body.
     * @param ending
     * @return concatenated the write boundary with encoded text
     */
    public static string writeBoundary(
        EndingType ending) {
        string value = '';

        if (ending == EndingType.CR) {
            value += '\n';
        } else if (ending == EndingType.NONE) {
            value += '\r\n';
        }

        value += '--' + Boundary + '--';
        blob valueBlob = blob.valueOf(value);
        return EncodingUtil.base64Encode(valueBlob);
    }

    /**
     *  @description Helper enum indicating how a file's base64 padding was replaced.
     */
    public enum EndingType {
        CR,
        CRLF,
        NONE
    }

    /**
     * @description Write a boundary at the end of the form's body.
     * @param key
     * @param file64
     * @param fileName
     * @return concatenated the write boundary with encoded text
     */
    public static string writeBlobBodyParameter(string key, string file64, string fileName) {
        
        String mimeType = resolveMimeType(fileName);
        
        string contentDisposition = 'Content-Disposition: form-data; name="' + key + '"; filename="'+fileName+'"';
        string contentDispositionCrLf = contentDisposition + '\r\n';
        blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        string contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        string content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n');
        
        string contentTypeHeader = 'Content-Type: ' + mimeType;
        string contentTypeCrLf = contentTypeHeader + '\r\n\r\n';
        blob contentTypeCrLfBlob = blob.valueOf(contentTypeCrLf);
        string contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);
        content += SafelyPad(contentTypeHeader, contentTypeCrLf64, '\r\n\r\n');
        
        String last4Bytes = file64.substring(file64.length()-4,file64.length());

        // Avoid padding the file data with spaces, which SafelyPad does
        EndingType ending = EndingType.NONE;
        if (last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            file64 = file64.substring(0,file64.length()-4) + last4Bytes;
            ending = EndingType.CRLF;
        } else if (last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            file64 = file64.substring(0,file64.length()-4) + last4Bytes;
            ending = EndingType.CR;
        }
               
        content += file64;
        
        content += WriteBoundary(ending);
        return content;
    }
    
    /**
     * @description to resolve Mime Type
     * @param fileName
     * @return identifies and resolves the mime type
     */
    private static String resolveMimeType(String fileName) {
        String fileType = fileName.substringAfterLast('.');
        String mimeType = 'image/png'; // fallback value
        if (fileType.equalsIgnoreCase('png')) {
            mimeType = 'image/png';
        } else if (fileType.equalsIgnoreCase('jpeg') || fileType.equalsIgnoreCase('jpg')) {
            mimeType = 'image/jpg';
        } else if (fileType.equalsIgnoreCase('pgm')) {
            mimeType = 'image/x-portable-graymap';
        } else if (fileType.equalsIgnoreCase('ppm')) {
            mimeType = 'image/x-portable-pixmap';            
        }
        return mimeType;
    }
   /** 
    * @description This method used for invocableMethod
    * @param documentList
    * @return Returns a callout response in map format for remaining processing
    */
    public static String invocableMethodWithDocumentList( List<ContentVersion> documentList)  { 
        if( documentList.isEmpty() == false) {
            List<Application__c> app = new List<Application__c>();
            Map<String, Object> responseObject = verifySelectedFile(app, documentList);
            return JSON.serialize(responseObject);
        }
        return null;
    }
    
}