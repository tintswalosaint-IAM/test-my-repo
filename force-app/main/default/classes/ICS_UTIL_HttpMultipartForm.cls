/**
 * @description Helper class for HTTP Multipart Form handling
 * @author Gnitsevich Anton
 * @date January 2023
 */
public with sharing class ICS_UTIL_HttpMultipartForm {
    private final String boundary;
    private  String form;

    /**
 	* @description ICS_UTIL_HttpMultipartForm constructor
 	* @param boundary  
 	*/
    public ICS_UTIL_HttpMultipartForm(String boundary) {
        
        this.boundary = boundary;
    }
	
     /**
 	* @description Method to assign boundry
     * @param boundary Multipart boundry
     * @return ICS_UTIL_HttpMultipartForm 
     */
    public static ICS_UTIL_HttpMultipartForm build(String boundary) {
        
        return new ICS_UTIL_HttpMultipartForm(boundary);
    }
	
 	/* @description Method for write footer
     * @return ICS_UTIL_HttpMultipartForm 
     */
    private ICS_UTIL_HttpMultipartForm writeFooter() {
        
        this.form += EncodingUtil.convertToHex(Blob.valueOf('--' + boundary + '--'));
        this.form = this.form.removeStart('null');
		return this;
    }

      /**
     * @description This method sends the document to DSX for storage
     * @param key JSON key
     * @param value JSON value
     * @return ICS_UTIL_HttpMultipartForm Multiform part request
     */
    public ICS_UTIL_HttpMultipartForm writeParam(String key, String value) {

        String body = '--' + boundary;
        body += '\r\nContent-Disposition: form-data; name="' + key + '";\r\n\r\n' + value + '\r\n';
        this.form += EncodingUtil.convertToHex(Blob.valueOf(body));
        this.form = this.form.removeStart('null');
        return this;
    }

    /**
     * @description This method sends the document to DSX for storage
     * @param key JSON key
     * @param fileName Document file name
     * @param fileContent Content of the document/file
     * @return ICS_UTIL_HttpMultipartForm Multiform part request
     */
    public ICS_UTIL_HttpMultipartForm writeFile(String key, String fileName, Blob fileContent) {

        String mimeType = resolveMimeType(fileName);
        String content = '--' + boundary;
        content += '\r\nContent-Disposition: form-data; name="' + key + '"; filename="' + fileName + '";\r\nContent-Type: ' + mimeType + ';\r\n\r\n';
        content = EncodingUtil.convertToHex(Blob.valueOf(content));
        content += EncodingUtil.convertToHex(fileContent);
        content += EncodingUtil.convertToHex(Blob.valueOf('\r\n'));
        this.form += content;
        this.form = this.form.removeStart('null');
        return this;
    }

     /**
     * @description Converts to String
     * @return String
     */
    public String getFormAsString() {
        this.writeFooter();
        this.form = this.form.removeStart('null');
        return this.form;
    }

     /**
     * @description Converts to Blob
     * @return Blob
     */
    public Blob getFormAsBlob() {
        return EncodingUtil.convertFromHex(this.getFormAsString());
    }
    
     /**
     * @description Returns mime type of the document
     * @param fileName Filename of the document
     * @return String
     */    
    public static String resolveMimeType(String fileName) {
        String fileExtension = fileName.substringAfterLast('.');
        String mimeType =  ICS_UTIL_DSXMimeType.getMimeType(fileExtension);
        return mimeType;
    }
}